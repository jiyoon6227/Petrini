/**
 * 역할: HospitalHospitalService 구현체 (@Service)
 */

package com.petcare.petcare.hospital.service;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.petcare.petcare.hospital.mapper.HospitalMapper;
import com.petcare.petcare.hospital.vo.HospitalDoctorVO;
import com.petcare.petcare.hospital.vo.HospitalPetVO;
import com.petcare.petcare.hospital.vo.HospitalResvExceptionVO;
import com.petcare.petcare.hospital.vo.HospitalResvHoldVO;
import com.petcare.petcare.hospital.vo.HospitalReviewVO;
import com.petcare.petcare.hospital.vo.HospitalTimeBlockVO;
import com.petcare.petcare.hospital.vo.HospitalTreatTypeVO;
import com.petcare.petcare.hospital.vo.HospitalVO;
import com.petcare.petcare.hospital.vo.ReservationVO;
import com.petcare.petcare.mypage.notify.service.MypageNotifyService;

@Service
public class HospitalServiceImpl implements HospitalService {

    private static final ZoneId ZONE = ZoneId.of("Asia/Seoul");
    private static final DateTimeFormatter TIME_FMT = DateTimeFormatter.ofPattern("HH:mm");
    private static final String[] DAY_LABELS = {"월", "화", "수", "목", "금", "토", "일"};
    private static final int HOLD_TTL_MINUTES = 5; // 2026/07/20 장우철 — 선점 유효 5분

    @Autowired
    private HospitalMapper hospitalMapper;
    @Autowired
    private ObjectMapper objectMapper;
    @Autowired
    private MypageNotifyService mypageNotifyService;

    @Override
    public List<HospitalVO> getHospitalList() throws Exception {
        return hospitalMapper.selectHospitalList();
    }

    @Override
    public List<HospitalVO> getHospitalListBySearch(HospitalVO searchVO) throws Exception {
        return hospitalMapper.selectHospitalListBySearch(searchVO);
    }

    @Override
    public HospitalVO getHospitalById(Long hospitalId) throws Exception {
        return hospitalMapper.selectHospitalById(hospitalId);
    }

    @Override
    @Transactional(readOnly = true)
    public List<HospitalPetVO> getPetListForReserve(Long memberNo) throws Exception {
        return hospitalMapper.selectPetListByMemberNo(memberNo);
    }

    @Override
    @Transactional(readOnly = true)
    public List<HospitalDoctorVO> getActiveDoctorsForReserve(Long hospitalId) throws Exception {
        if (hospitalId == null) {
            return List.of();
        }
        return hospitalMapper.selectActiveDoctorList(hospitalId);
    }

    @Override
    @Transactional(readOnly = true)
    public List<HospitalTreatTypeVO> getActiveTreatTypesForReserve(Long hospitalId) throws Exception {
        if (hospitalId == null) {
            return List.of();
        }
        return hospitalMapper.selectActiveTreatTypeList(hospitalId);
    }

    // 2026/07/16 장우철 — HOURS_JSON·예외·점유 반영 가능 시작시각 목록
    // noRollbackFor: hold 테이블 미존재 등 조회 실패를 catch 해도 트랜잭션 롤백 마킹 방지
    @Override
    @Transactional(readOnly = true, noRollbackFor = Exception.class)
    public List<String> getAvailableReserveTimes(Long hospitalId, Long doctorId, Long treatTypeId,
                                                 Date resvDate) throws Exception {
        validateScheduleParams(hospitalId, doctorId, treatTypeId, resvDate);

        HospitalVO hospital = hospitalMapper.selectHospitalById(hospitalId);
        if (hospital == null) {
            throw new IllegalArgumentException("병원 정보를 찾을 수 없습니다.");
        }
        HospitalTreatTypeVO treatType = hospitalMapper.selectTreatType(hospitalId, treatTypeId);
        if (treatType == null || (treatType.getStatusCd() != null && !"Y".equalsIgnoreCase(treatType.getStatusCd()))) {
            throw new IllegalArgumentException("선택한 진료 유형을 사용할 수 없습니다.");
        }
        HospitalDoctorVO doctor = hospitalMapper.selectDoctor(hospitalId, doctorId);
        if (doctor == null || (doctor.getStatusCd() != null && !"Y".equalsIgnoreCase(doctor.getStatusCd()))) {
            throw new IllegalArgumentException("선택한 의사를 예약할 수 없습니다.");
        }

        Integer durationObj = treatType.getDurationMin();
        if (durationObj == null || durationObj <= 0) {
            throw new IllegalArgumentException("진료 소요 시간 정보가 올바르지 않습니다.");
        }
        int durationMin = durationObj;
        int intervalMin = resolveIntervalMin(hospitalId);
        LocalDate date = toLocalDate(resvDate);

        List<TimeRange> openWindows = resolveOpenWindows(hospital, doctorId, date, intervalMin);
        if (openWindows.isEmpty()) {
            // 2026/07/20 장우철 — 정기 휴무(HOURS_JSON에 없는 요일)면 명확한 메시지
            String closedMsg = resolveRegularClosedMessage(hospital, date);
            if (closedMsg != null) {
                throw new IllegalStateException(closedMsg);
            }
            return List.of();
        }

        List<HospitalResvExceptionVO> exceptions = loadExceptionsSafe(hospitalId, resvDate);
        List<TimeRange> closeBlocks = resolveCloseBlocks(exceptions, doctorId);
        List<TimeRange> lunchBlocks = resolveLunchBlocks(hospital, date, exceptions, doctorId);

        List<HospitalTimeBlockVO> occupied = loadOccupiedBlocksSafe(hospitalId, doctorId, resvDate);

        List<String> slots = new ArrayList<>();
        LocalTime nowCutoff = null;
        if (date.equals(LocalDate.now(ZONE))) {
            nowCutoff = LocalTime.now(ZONE);
        }
        for (TimeRange window : openWindows) {
            LocalTime cursor = window.start();
            while (!cursor.plusMinutes(durationMin).isAfter(window.end())) {
                if (nowCutoff != null && !cursor.isAfter(nowCutoff)) {
                    cursor = cursor.plusMinutes(intervalMin);
                    continue;
                }
                String start = formatTime(cursor);
                String end = formatTime(cursor.plusMinutes(durationMin));
                if (!overlapsAny(start, end, lunchBlocks)
                        && !overlapsAny(start, end, closeBlocks)
                        && !overlapsOccupied(start, end, occupied)) {
                    slots.add(start);
                }
                cursor = cursor.plusMinutes(intervalMin);
            }
        }
        return slots;
    }

    // 2026/07/20 장우철 — 예약 날짜 정기 휴무 여부 (유저 날짜 선택)
    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> checkReserveDate(Long hospitalId, Date resvDate) throws Exception {
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("closed", false);
        if (hospitalId == null || resvDate == null) {
            throw new IllegalArgumentException("일정 정보가 올바르지 않습니다.");
        }
        LocalDate date = toLocalDate(resvDate);
        if (date.isBefore(LocalDate.now(ZONE))) {
            result.put("closed", true);
            result.put("message", "과거 날짜는 예약할 수 없습니다.");
            return result;
        }
        HospitalVO hospital = hospitalMapper.selectHospitalById(hospitalId);
        if (hospital == null) {
            throw new IllegalArgumentException("병원 정보를 찾을 수 없습니다.");
        }
        String closedMsg = resolveRegularClosedMessage(hospital, date);
        if (closedMsg != null) {
            result.put("closed", true);
            result.put("message", closedMsg);
        }
        return result;
    }

    // 2026/07/16 장우철 — 펫 단계 이동 시 임시 선점
    // 2026/07/20 장우철 — 의사 행 FOR UPDATE 로 동시 선점 race 방지
    @Override
    @Transactional
    public Long createReserveHold(Long hospitalId, Long memberNo, Long doctorId, Long treatTypeId,
                                  Date resvDate, String resvTime) throws Exception {
        cleanupExpiredHoldsSafe();
        validateScheduleParams(hospitalId, doctorId, treatTypeId, resvDate);
        if (resvTime == null || resvTime.isBlank()) {
            throw new IllegalArgumentException("예약 시간을 선택해 주세요.");
        }

        HospitalTreatTypeVO treatType = hospitalMapper.selectTreatType(hospitalId, treatTypeId);
        if (treatType == null || !"Y".equalsIgnoreCase(treatType.getStatusCd())) {
            throw new IllegalArgumentException("선택한 진료 유형을 사용할 수 없습니다.");
        }
        HospitalDoctorVO doctor = hospitalMapper.selectDoctor(hospitalId, doctorId);
        if (doctor == null || !"Y".equalsIgnoreCase(doctor.getStatusCd())) {
            throw new IllegalArgumentException("선택한 의사를 예약할 수 없습니다.");
        }

        String startTime = resvTime.trim();
        int durationMin = treatType.getDurationMin();
        String endTime = calcEndTime(startTime, durationMin);

        List<String> available = getAvailableReserveTimes(hospitalId, doctorId, treatTypeId, resvDate);
        if (!available.contains(startTime)) {
            throw new IllegalStateException("선택한 시간은 더 이상 예약할 수 없습니다. 다시 선택해 주세요.");
        }

        lockDoctorSchedule(hospitalId, doctorId);

        try {
            hospitalMapper.deleteHoldsByMember(hospitalId, memberNo);
        } catch (Exception e) {
            System.out.println("[reserve/hold] 기존 선점 삭제 스킵: " + e.getMessage());
        }

        assertNoScheduleOverlap(hospitalId, doctorId, resvDate, startTime, endTime, null);

        HospitalResvHoldVO hold = new HospitalResvHoldVO();
        hold.setHospitalId(hospitalId);
        hold.setDoctorId(doctorId);
        hold.setTreatTypeId(treatTypeId);
        hold.setMemberNo(memberNo);
        hold.setResvDate(resvDate);
        hold.setResvTime(startTime);
        hold.setDurationMin(durationMin);
        hold.setEndTime(endTime);
        hold.setExpireDate(Date.from(
                java.time.LocalDateTime.now(ZONE).plusMinutes(HOLD_TTL_MINUTES)
                        .atZone(ZONE).toInstant()));
        try {
            hospitalMapper.insertResvHold(hold);
        } catch (Exception e) {
            throw new IllegalStateException(
                    "예약 선점 테이블이 없습니다. sql/hospital_resv_alter.sql 을 실행해 주세요.");
        }
        return hold.getHoldId();
    }

    // 2026/07/16 장우철 — 선점 기반 최종 예약 저장
    @Override
    @Transactional
    public Long createHospitalReservation(ReservationVO vo) throws Exception {
        cleanupExpiredHoldsSafe();
        if (vo.getHoldId() != null) {
            return finalizeReservationFromHold(vo);
        }
        return createHospitalReservationDirect(vo);
    }

    private Long finalizeReservationFromHold(ReservationVO vo) throws Exception {
        if (vo.getMemberNo() == null) {
            throw new IllegalArgumentException("로그인이 필요합니다.");
        }

        HospitalResvHoldVO hold;
        try {
            hold = hospitalMapper.selectResvHoldByIdForUpdate(vo.getHoldId());
        } catch (Exception e) {
            throw new IllegalStateException("예약 선점이 만료되었습니다. 일정부터 다시 선택해 주세요.");
        }
        if (hold == null || !hold.getMemberNo().equals(vo.getMemberNo())) {
            throw new IllegalStateException("예약 선점이 만료되었습니다. 일정부터 다시 선택해 주세요.");
        }

        if (vo.getPetId() == null) {
            // 2026/07/20 장우철 — 제출 실패 시 hold 해제 → 다른 회원 재선택 가능
            releaseHoldSafe(hold.getHoldId());
            throw new IllegalArgumentException("반려동물을 선택해 주세요.");
        }

        lockDoctorSchedule(hold.getHospitalId(), hold.getDoctorId());

        vo.setTargetId(String.valueOf(hold.getHospitalId()));
        vo.setResvDate(hold.getResvDate());
        vo.setResvTime(hold.getResvTime());
        vo.setDoctorId(hold.getDoctorId());
        vo.setTreatTypeId(hold.getTreatTypeId());
        vo.setDurationMin(hold.getDurationMin());
        vo.setEndTime(hold.getEndTime());

        try {
            assertNoScheduleOverlap(
                    hold.getHospitalId(), hold.getDoctorId(), hold.getResvDate(),
                    hold.getResvTime(), hold.getEndTime(), hold.getHoldId());
        } catch (IllegalStateException e) {
            releaseHoldSafe(hold.getHoldId());
            throw e;
        }

        vo.setResvType("HOSPITAL");
        vo.setStatusCd("PENDING");
        if (vo.getResvNo() == null || vo.getResvNo().isBlank()) {
            vo.setResvNo(buildResvNo());
        }
        try {
            hospitalMapper.insertReservation(vo);
        } catch (Exception e) {
            releaseHoldSafe(hold.getHoldId());
            throw e;
        }
        releaseHoldSafe(hold.getHoldId());
        // 2026/08/07 장우철 — 병원 신규 예약 → 사업자 알림
        notifyHospitalBizNewReserve(vo);
        return vo.getResvId();
    }

    private Long createHospitalReservationDirect(ReservationVO vo) throws Exception {
        if (vo.getTargetId() == null || vo.getTargetId().isBlank()) {
            throw new IllegalArgumentException("병원 정보가 올바르지 않습니다.");
        }
        Long hospitalId = Long.parseLong(vo.getTargetId());

        if (vo.getTreatTypeId() == null) {
            throw new IllegalArgumentException("진료 유형을 선택해 주세요.");
        }
        if (vo.getDoctorId() == null) {
            throw new IllegalArgumentException("의사를 선택해 주세요.");
        }
        if (vo.getResvDate() == null || vo.getResvTime() == null || vo.getResvTime().isBlank()) {
            throw new IllegalArgumentException("예약 날짜·시간을 확인해 주세요.");
        }

        HospitalTreatTypeVO treatType = hospitalMapper.selectTreatType(hospitalId, vo.getTreatTypeId());
        if (treatType == null || !"Y".equalsIgnoreCase(treatType.getStatusCd())) {
            throw new IllegalArgumentException("선택한 진료 유형을 사용할 수 없습니다.");
        }

        HospitalDoctorVO doctor = hospitalMapper.selectDoctor(hospitalId, vo.getDoctorId());
        if (doctor == null || !"Y".equalsIgnoreCase(doctor.getStatusCd())) {
            throw new IllegalArgumentException("선택한 의사를 예약할 수 없습니다.");
        }

        Integer durationMin = treatType.getDurationMin();
        if (durationMin == null || durationMin <= 0) {
            throw new IllegalArgumentException("진료 소요 시간 정보가 올바르지 않습니다.");
        }

        String startTime = vo.getResvTime().trim();
        String endTime = calcEndTime(startTime, durationMin);
        vo.setDurationMin(durationMin);
        vo.setEndTime(endTime);

        lockDoctorSchedule(hospitalId, vo.getDoctorId());
        assertNoScheduleOverlap(
                hospitalId, vo.getDoctorId(), vo.getResvDate(), startTime, endTime, null);

        vo.setResvType("HOSPITAL");
        vo.setStatusCd("PENDING");
        vo.setResvTime(startTime);
        if (vo.getResvNo() == null || vo.getResvNo().isBlank()) {
            vo.setResvNo(buildResvNo());
        }
        hospitalMapper.insertReservation(vo);
        // 2026/08/07 장우철 — 병원 신규 예약 → 사업자 알림
        notifyHospitalBizNewReserve(vo);
        return vo.getResvId();
    }

    /** 2026/08/07 장우철 — PENDING 예약 생성 시 병원 사업자 알림 */
    private void notifyHospitalBizNewReserve(ReservationVO vo) {
        try {
            if (vo == null || vo.getTargetId() == null || vo.getTargetId().isBlank()) {
                return;
            }
            Long hospitalId = Long.parseLong(vo.getTargetId());
            HospitalVO hospital = hospitalMapper.selectHospitalById(hospitalId);
            if (hospital == null || hospital.getMemberNo() == null) {
                return;
            }
            String hospitalName = hospital.getName() != null ? hospital.getName() : "병원";
            mypageNotifyService.sendHospitalReserveToBizNotification(
                    hospital.getMemberNo(), hospitalName, vo.getResvDate(), vo.getResvTime(), vo.getResvId());
        } catch (Exception ignored) {
            // 알림 실패해도 예약은 유지
        }
    }

    @Override
    @Transactional(readOnly = true)
    public ReservationVO getReservationById(Long resvId) throws Exception {
        return hospitalMapper.selectReservationById(resvId);
    }

    @Override
    @Transactional(readOnly = true)
    public List<HospitalReviewVO> getHospitalReviews(Long hospitalId) throws Exception {
        if (hospitalId == null) {
            return List.of();
        }
        return hospitalMapper.selectHospitalReviews(hospitalId);
    }

    // 2026/07/20 장우철 — 만료 hold 일괄 삭제 (스케줄·예약 API 공용)
    @Override
    @Transactional
    public int cleanupExpiredHolds() throws Exception {
        return hospitalMapper.deleteExpiredHolds();
    }

    // 2026/07/20 장우철 — 2단계 이전: 본인 hold 해제 (다른 회원 즉시 재선택)
    @Override
    @Transactional
    public void releaseMemberReserveHolds(Long hospitalId, Long memberNo) throws Exception {
        if (hospitalId == null || memberNo == null) {
            return;
        }
        try {
            hospitalMapper.deleteHoldsByMember(hospitalId, memberNo);
        } catch (Exception e) {
            System.out.println("[reserve/hold] 선점 해제 스킵: " + e.getMessage());
        }
    }

    /** 2026/07/20 장우철 — 동시예약 방지: 의사 단위 직렬화 */
    private void lockDoctorSchedule(Long hospitalId, Long doctorId) throws Exception {
        Long locked = hospitalMapper.lockDoctorForUpdate(hospitalId, doctorId);
        if (locked == null) {
            throw new IllegalArgumentException("선택한 의사를 예약할 수 없습니다.");
        }
    }

    /** 2026/07/20 장우철 — 겹침 시 사용자 메시지 (락 이후 재검사) */
    private void assertNoScheduleOverlap(Long hospitalId, Long doctorId, Date resvDate,
                                         String resvTime, String endTime, Long excludeHoldId) {
        int overlap = countOverlapSafe(hospitalId, doctorId, resvDate, resvTime, endTime, excludeHoldId);
        if (overlap > 0) {
            throw new IllegalStateException("선택한 시간에 이미 예약이 있습니다. 다른 시간을 선택해 주세요.");
        }
    }

    /** 2026/07/20 장우철 — hold 해제 (실패·완료 공통) */
    private void releaseHoldSafe(Long holdId) {
        if (holdId == null) {
            return;
        }
        try {
            hospitalMapper.deleteResvHoldById(holdId);
        } catch (Exception e) {
            System.out.println("[reserve/hold] 선점 해제 스킵: " + e.getMessage());
        }
    }

    private int resolveIntervalMin(Long hospitalId) {
        try {
            Integer interval = hospitalMapper.selectResvIntervalMin(hospitalId);
            return interval != null && interval > 0 ? interval : 15;
        } catch (Exception e) {
            // 2026/07/16 장우철 — RESV_INTERVAL_MIN 미적용 DB도 기본 15분으로 동작
            return 15;
        }
    }

    private List<HospitalResvExceptionVO> loadExceptionsSafe(Long hospitalId, Date resvDate) {
        try {
            return hospitalMapper.selectResvExceptionsByDate(hospitalId, resvDate);
        } catch (Exception e) {
            return List.of();
        }
    }

    private List<HospitalTimeBlockVO> loadOccupiedBlocksSafe(Long hospitalId, Long doctorId, Date resvDate) {
        List<HospitalTimeBlockVO> occupied = new ArrayList<>();
        try {
            List<HospitalTimeBlockVO> reservations =
                    hospitalMapper.selectOccupiedReservationBlocks(hospitalId, doctorId, resvDate);
            if (reservations != null) {
                occupied.addAll(reservations);
            }
        } catch (Exception e) {
            // 2026/07/16 장우철 — DOCTOR_ID/END_TIME 미적용 시 점유 없이 슬롯만 표시
            System.out.println("[reserve/times] 예약 점유 조회 실패(스키마 확인): " + e.getMessage());
        }
        try {
            List<HospitalTimeBlockVO> holds =
                    hospitalMapper.selectOccupiedHoldBlocks(hospitalId, doctorId, resvDate);
            if (holds != null) {
                occupied.addAll(holds);
            }
        } catch (Exception e) {
            // 2026/07/16 장우철 — TB_HOSPITAL_RESV_HOLD 미생성 시 무시
            System.out.println("[reserve/times] 선점 점유 조회 실패(hold 테이블 확인): " + e.getMessage());
        }
        return occupied;
    }

    private void cleanupExpiredHoldsSafe() {
        try {
            cleanupExpiredHolds();
        } catch (Exception e) {
            System.out.println("[reserve] hold 만료 정리 스킵: " + e.getMessage());
        }
    }

    private int countOverlapSafe(Long hospitalId, Long doctorId, Date resvDate,
                                 String resvTime, String endTime, Long excludeHoldId) {
        try {
            return hospitalMapper.countOverlappingWithHolds(
                    hospitalId, doctorId, resvDate, resvTime, endTime, excludeHoldId);
        } catch (Exception e) {
            try {
                return hospitalMapper.countOverlappingReservations(
                        hospitalId, doctorId, resvDate, resvTime, endTime);
            } catch (Exception e2) {
                System.out.println("[reserve] 겹침 조회 스킵: " + e2.getMessage());
                return 0;
            }
        }
    }

    private void validateScheduleParams(Long hospitalId, Long doctorId, Long treatTypeId,
                                        Date resvDate) {
        if (hospitalId == null || doctorId == null || treatTypeId == null || resvDate == null) {
            throw new IllegalArgumentException("일정 정보가 올바르지 않습니다.");
        }
        LocalDate date = toLocalDate(resvDate);
        if (date.isBefore(LocalDate.now(ZONE))) {
            throw new IllegalArgumentException("과거 날짜는 예약할 수 없습니다.");
        }
    }

    // 2026/07/16 장우철 — REPLACE 우선, 없으면 HOURS_JSON 요일
    private List<TimeRange> resolveOpenWindows(HospitalVO hospital, Long doctorId,
                                               LocalDate date, int defaultInterval) throws Exception {
        List<HospitalResvExceptionVO> exceptions = loadExceptionsSafe(hospital.getHospitalId(), toDate(date));

        List<TimeRange> replaceWindows = new ArrayList<>();
        for (HospitalResvExceptionVO exc : exceptions) {
            if (!"REPLACE".equalsIgnoreCase(exc.getExcType())) {
                continue;
            }
            if (exc.getDoctorId() != null && !exc.getDoctorId().equals(doctorId)) {
                continue;
            }
            LocalTime start = parseTime(exc.getStartTime());
            LocalTime end = parseTime(exc.getEndTime());
            if (start != null && end != null && start.isBefore(end)) {
                replaceWindows.add(new TimeRange(start, end));
            }
        }
        if (!replaceWindows.isEmpty()) {
            return replaceWindows;
        }

        JsonNode dayNode = resolveDayHoursNode(hospital.getHoursJson(), date);
        if (dayNode == null || dayNode.isMissingNode() || dayNode.isNull()) {
            // 해당 요일 휴무(JSON에 없음) → 슬롯 없음
            return List.of();
        }
        LocalTime open = parseTime(dayNode.path("open").asText(null));
        LocalTime close = parseTime(dayNode.path("close").asText(null));
        if (open == null || close == null || !open.isBefore(close)) {
            return List.of();
        }
        return List.of(new TimeRange(open, close));
    }

    private List<TimeRange> resolveCloseBlocks(List<HospitalResvExceptionVO> exceptions,
                                               Long doctorId) {
        List<TimeRange> blocks = new ArrayList<>();
        for (HospitalResvExceptionVO exc : exceptions) {
            if (!"CLOSE".equalsIgnoreCase(exc.getExcType())) {
                continue;
            }
            if (exc.getDoctorId() != null && !exc.getDoctorId().equals(doctorId)) {
                continue;
            }
            LocalTime start = parseTime(exc.getStartTime());
            LocalTime end = parseTime(exc.getEndTime());
            if (start != null && end != null && start.isBefore(end)) {
                blocks.add(new TimeRange(start, end));
            }
        }
        return blocks;
    }

    private List<TimeRange> resolveLunchBlocks(HospitalVO hospital, LocalDate date,
                                               List<HospitalResvExceptionVO> exceptions,
                                               Long doctorId) throws Exception {
        if (hasReplaceForDoctor(exceptions, doctorId)) {
            return List.of();
        }
        JsonNode dayNode = resolveDayHoursNode(hospital.getHoursJson(), date);
        if (dayNode == null) {
            return List.of();
        }
        LocalTime lunchStart = parseTime(dayNode.path("lunchStart").asText(null));
        LocalTime lunchEnd = parseTime(dayNode.path("lunchEnd").asText(null));
        if (lunchStart == null || lunchEnd == null || !lunchStart.isBefore(lunchEnd)) {
            return List.of();
        }
        return List.of(new TimeRange(lunchStart, lunchEnd));
    }

    private boolean hasReplaceForDoctor(List<HospitalResvExceptionVO> exceptions, Long doctorId) {
        for (HospitalResvExceptionVO exc : exceptions) {
            if ("REPLACE".equalsIgnoreCase(exc.getExcType())
                    && (exc.getDoctorId() == null || exc.getDoctorId().equals(doctorId))) {
                return true;
            }
        }
        return false;
    }

    private JsonNode resolveDayHoursNode(String hoursJson, LocalDate date) throws Exception {
        if (hoursJson == null || hoursJson.isBlank()) {
            return null;
        }
        JsonNode root = objectMapper.readTree(hoursJson);
        String dayKey = DAY_LABELS[date.getDayOfWeek().getValue() - 1];
        JsonNode dayNode = root.path(dayKey);
        if (!dayNode.isMissingNode() && !dayNode.isNull()) {
            return dayNode;
        }
        // 2026/07/20 장우철 — JSON에 없는 요일 = 정기 휴무 (공휴일 키로 대체하지 않음)
        return null;
    }

    /** 2026/07/20 장우철 — HOURS_JSON 기준 정기 휴무 메시지 (없으면 null) */
    private String resolveRegularClosedMessage(HospitalVO hospital, LocalDate date) throws Exception {
        JsonNode dayNode = resolveDayHoursNode(hospital.getHoursJson(), date);
        if (dayNode == null || dayNode.isMissingNode() || dayNode.isNull()) {
            String dayName = DAY_LABELS[date.getDayOfWeek().getValue() - 1];
            return dayName + "요일은 정기 휴무일입니다.";
        }
        return null;
    }

    private boolean overlapsOccupied(String start, String end, List<HospitalTimeBlockVO> occupied) {
        for (HospitalTimeBlockVO block : occupied) {
            if (block.getStartTime() == null || block.getEndTime() == null) {
                continue;
            }
            if (overlaps(start, end, block.getStartTime(), block.getEndTime())) {
                return true;
            }
        }
        return false;
    }

    private boolean overlapsAny(String start, String end, List<TimeRange> ranges) {
        for (TimeRange range : ranges) {
            if (overlaps(start, end, formatTime(range.start()), formatTime(range.end()))) {
                return true;
            }
        }
        return false;
    }

    private boolean overlaps(String aStart, String aEnd, String bStart, String bEnd) {
        return aStart.compareTo(bEnd) < 0 && aEnd.compareTo(bStart) > 0;
    }

    private LocalTime parseTime(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return LocalTime.parse(value.trim(), DateTimeFormatter.ofPattern("H:mm"));
        } catch (DateTimeParseException e) {
            return null;
        }
    }

    private String formatTime(LocalTime time) {
        return time.format(TIME_FMT);
    }

    private LocalDate toLocalDate(Date date) {
        // 2026/07/16 장우철 — 타임존 보정 (java.util.Date 자정 바인딩 → 전날로 밀리는 문제 방지)
        Calendar cal = Calendar.getInstance();
        cal.setTime(date);
        return LocalDate.of(cal.get(Calendar.YEAR), cal.get(Calendar.MONTH) + 1, cal.get(Calendar.DAY_OF_MONTH));
    }

    private Date toDate(LocalDate date) {
        return Date.from(date.atStartOfDay(ZONE).toInstant());
    }

    private String buildResvNo() {
        String datePart = LocalDate.now(ZONE).format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        long suffix = System.currentTimeMillis() % 10000;
        return "R" + datePart + String.format("%04d", suffix);
    }

    private String calcEndTime(String startTime, int durationMin) {
        try {
            LocalTime start = LocalTime.parse(startTime, DateTimeFormatter.ofPattern("H:mm"));
            return start.plusMinutes(durationMin).format(TIME_FMT);
        } catch (DateTimeParseException e) {
            throw new IllegalArgumentException("예약 시간 형식이 올바르지 않습니다.");
        }
    }

    private record TimeRange(LocalTime start, LocalTime end) {}
}
