/**
 * 역할: BizHospitalService 구현체 (@Service)
 *
 * 구현 내용
 * - Controller에서 넘어온 요청 처리
 * - Mapper 호출하여 DB 조회·수정
 * - 비즈니스 규칙 검증 및 결과 반환
 *
 * 연결
 * - implements: BizHospitalService
 * - 사용: BizHospitalMapper
 *
 * 비즈니스 로직은 여기에 작성 (Controller, Mapper에 직접 작성 X)
 */

package com.petcare.petcare.biz.hospital.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.biz.hospital.mapper.BizHospitalMapper;
import com.petcare.petcare.common.external.service.KakaoMapService;
import com.petcare.petcare.hospital.util.MedicalRecordMemoParser;
import com.petcare.petcare.hospital.vo.HospitalDoctorVO;
import com.petcare.petcare.hospital.vo.HospitalResvExceptionVO;
import com.petcare.petcare.hospital.vo.HospitalReviewVO;
import com.petcare.petcare.hospital.vo.HospitalTreatTypeVO;
import com.petcare.petcare.hospital.vo.HospitalVO;
import com.petcare.petcare.hospital.vo.MedicalRecordVO;
import com.petcare.petcare.hospital.vo.ReservationVO;
import com.petcare.petcare.hospital.vo.ReviewDeleteRequestVO;
import com.petcare.petcare.mypage.notify.service.MypageNotifyService;

@Service
public class BizHospitalServiceImpl implements BizHospitalService {
    @Autowired
    private BizHospitalMapper bizHospitalMapper;
    @Autowired
    private KakaoMapService kakaoMapService;
    @Autowired
    private MypageNotifyService mypageNotifyService;

    @Override
    @Transactional(readOnly = true)
    public HospitalVO getHospitalByBizId(String bizId) {
        return bizHospitalMapper.selectHospitalByBizId(bizId);
    }

    // 2026-07-10 장우철 — merge 전 승인 계정 등 TB_HOSPITAL 미생성 시 보정 INSERT
    @Override
    @Transactional
    public HospitalVO resolveHospitalByBizId(String bizId) {
        if (bizId == null || bizId.isBlank()) {
            return null;
        }
        HospitalVO hospital = bizHospitalMapper.selectHospitalByBizId(bizId);
        if (hospital == null) {
            bizHospitalMapper.insertHospital(bizId);
            hospital = bizHospitalMapper.selectHospitalByBizId(bizId);
        }
        return hospital;
    }

    @Override
    @Transactional
    public void updateHospitalInfo(HospitalVO vo) {
        // 2026-07-10 장우철 — 주소 있으면 좌표 변환 (유저 목록 '상세보기'는 LAT 필수)
        if (vo.getAddr() != null && !vo.getAddr().isBlank()) {
            Map<String, Double> coords = kakaoMapService.geocodeAddress(vo.getAddr());
            if (coords != null) {
                vo.setLat(coords.get("lat"));
                vo.setLng(coords.get("lng"));
            }
        }

        bizHospitalMapper.updateHospitalInfo(vo);
    }

    // 2026-07-10 장우철 — 사업자 예약 목록 (F4)
    @Override
    @Transactional(readOnly = true)
    public List<ReservationVO> getReservationList(Long hospitalId, String tab) throws Exception {
        if (hospitalId == null) {
            return List.of();
        }
        String safeTab = (tab == null || "all".equals(tab)) ? null : tab;
        return bizHospitalMapper.selectReservationList(hospitalId, safeTab);
    }

    // 2026-07-10 장우철 — 사업자 예약 상세 모달 (F6)
    @Override
    @Transactional(readOnly = true)
    public ReservationVO getReservationDetail(Long hospitalId, Long resvId) throws Exception {
        return bizHospitalMapper.selectReservationDetail(resvId, hospitalId);
    }

    // 2026-07-10 장우철 — 사업자 예약 상태 변경 (F5)
    // 2026/07/11 장우철 — [변경 후] PENDING→CONFIRMED→DONE 전이 + 확정/취소 알림 + 취소 사유
    @Override
    @Transactional
    public void updateReservationStatus(Long hospitalId, Long resvId, String statusCd, String cancelReason)
            throws Exception {
        if (hospitalId == null || resvId == null || statusCd == null || statusCd.isBlank()) {
            throw new IllegalArgumentException("예약 상태 변경 정보가 올바르지 않습니다.");
        }

        String next = statusCd.trim().toUpperCase();
        if (!next.equals("PENDING") && !next.equals("CONFIRMED")
                && !next.equals("DONE") && !next.equals("CANCEL")) {
            throw new IllegalArgumentException("허용되지 않은 예약 상태입니다.");
        }

        ReservationVO current = bizHospitalMapper.selectReservationDetail(resvId, hospitalId);
        if (current == null) {
            throw new IllegalStateException("예약을 찾을 수 없거나 변경할 수 없습니다.");
        }

        String prev = current.getStatusCd() != null ? current.getStatusCd().trim().toUpperCase() : "";
        if (!isAllowedStatusTransition(prev, next)) {
            throw new IllegalStateException("현재 상태에서는 해당 처리가 불가합니다. (현재: " + prev + ")");
        }

        String rejectReason = null;
        if ("CANCEL".equals(next)) {
            if (cancelReason == null || cancelReason.isBlank()) {
                throw new IllegalArgumentException("취소 사유를 입력해 주세요.");
            }
            rejectReason = cancelReason.trim();
            if (rejectReason.length() > 500) {
                rejectReason = rejectReason.substring(0, 500);
            }
        }

        int updated = bizHospitalMapper.updateReservationStatus(resvId, hospitalId, next, rejectReason);
        if (updated == 0) {
            throw new IllegalStateException("예약을 찾을 수 없거나 변경할 수 없습니다.");
        }

        String hospitalName = bizHospitalMapper.selectHospitalNameById(hospitalId);
        if (hospitalName == null || hospitalName.isBlank()) {
            hospitalName = "병원";
        }
        if ("CONFIRMED".equals(next)) {
            mypageNotifyService.sendReserveConfirmNotification(
                    current.getMemberNo(), hospitalName, current.getResvDate(), current.getResvTime(), resvId);
        } else if ("CANCEL".equals(next)) {
            mypageNotifyService.sendReserveCancelNotification(
                    current.getMemberNo(), hospitalName, current.getResvDate(), current.getResvTime(),
                    rejectReason, resvId);
        } else if ("DONE".equals(next)) {
            // 2026/07/13 장우철 — 진료완료 알림 (상세·리뷰 작성으로 이동)
            mypageNotifyService.sendReserveDoneNotification(
                    current.getMemberNo(), hospitalName, current.getResvDate(), current.getResvTime(), resvId);
        }
    }

    /** 2026/07/11 장우철 — PENDING→CONFIRMED/CANCEL, CONFIRMED→DONE/CANCEL 만 허용 */
    private boolean isAllowedStatusTransition(String prev, String next) {
        if ("PENDING".equals(prev)) {
            return "CONFIRMED".equals(next) || "CANCEL".equals(next);
        }
        if ("CONFIRMED".equals(prev)) {
            return "DONE".equals(next) || "CANCEL".equals(next);
        }
        return false;
    }

    // 2026-07-10 장우철 — 사업자 예약 캘린더 (F7)
    @Override
    @Transactional(readOnly = true)
    public List<ReservationVO> getCalendarReservations(Long hospitalId, String fromDate, String toDate) throws Exception {
        if (hospitalId == null) {
            return List.of();
        }
        return bizHospitalMapper.selectReservationCalendarList(hospitalId, fromDate, toDate);
    }

    // 2026/07/11 장우철 — 사이드바 PENDING 배지
    @Override
    @Transactional(readOnly = true)
    public int countPendingReservations(Long hospitalId) throws Exception {
        if (hospitalId == null) {
            return 0;
        }
        return bizHospitalMapper.countPendingReservations(hospitalId);
    }

    // 2026/07/11 장우철 — 사이드바 캘린더 배지 (오늘 CONFIRMED)
    @Override
    @Transactional(readOnly = true)
    public int countTodayConfirmedReservations(Long hospitalId) throws Exception {
        if (hospitalId == null) {
            return 0;
        }
        return bizHospitalMapper.countTodayConfirmedReservations(hospitalId);
    }

    // 2026/07/13 장우철 — CONFIRMED 예약 → 진료기록 INSERT + DONE
    @Override
    @Transactional
    public void completeReservationWithRecord(Long hospitalId, MedicalRecordVO record) throws Exception {
        if (hospitalId == null || record == null || record.getResvId() == null) {
            throw new IllegalArgumentException("진료기록 정보가 올바르지 않습니다.");
        }
        if (record.getSymptoms() == null || record.getSymptoms().isBlank()) {
            throw new IllegalArgumentException("주증상을 입력해 주세요.");
        }
        if (record.getDiagnosis() == null || record.getDiagnosis().isBlank()) {
            throw new IllegalArgumentException("진단명을 입력해 주세요.");
        }

        ReservationVO current = bizHospitalMapper.selectReservationDetail(record.getResvId(), hospitalId);
        if (current == null) {
            throw new IllegalStateException("예약을 찾을 수 없습니다.");
        }
        if (!"CONFIRMED".equalsIgnoreCase(current.getStatusCd())) {
            throw new IllegalStateException("예약확정 상태에서만 진료완료·기록 저장이 가능합니다.");
        }
        if (bizHospitalMapper.countMedicalRecordByResvId(record.getResvId()) > 0) {
            throw new IllegalStateException("이미 진료기록이 등록된 예약입니다.");
        }

        record.setHospitalId(hospitalId);
        record.setPetId(current.getPetId());
        record.setMemberNo(current.getMemberNo());
        if (record.getVisitDate() == null) {
            record.setVisitDate(current.getResvDate() != null ? current.getResvDate() : new java.util.Date());
        }
        // 화면 보조항목(유형·체중 등)은 MEMO 앞에 붙여 보관
        record.setMemo(buildRecordMemo(record));

        bizHospitalMapper.insertMedicalRecord(record);
        updateReservationStatus(hospitalId, record.getResvId(), "DONE", null);
    }

    private String buildRecordMemo(MedicalRecordVO record) {
        StringBuilder sb = new StringBuilder();
        if (record.getTreatType() != null && !record.getTreatType().isBlank()) {
            sb.append("[유형:").append(record.getTreatType().trim()).append("] ");
        }
        if (record.getWeight() != null && !record.getWeight().isBlank()) {
            sb.append("[체중:").append(record.getWeight().trim()).append("kg] ");
        }
        if (record.getTemperature() != null && !record.getTemperature().isBlank()) {
            sb.append("[체온:").append(record.getTemperature().trim()).append("℃] ");
        }
        if (record.getHeartRate() != null && !record.getHeartRate().isBlank()) {
            sb.append("[심박:").append(record.getHeartRate().trim()).append("bpm] ");
        }
        if (record.getBreathRate() != null && !record.getBreathRate().isBlank()) {
            sb.append("[호흡:").append(record.getBreathRate().trim()).append("회/분] ");
        }
        if (record.getExamItems() != null && !record.getExamItems().isBlank()) {
            sb.append("[검사:").append(record.getExamItems().trim()).append("] ");
        }
        if (record.getNextVisit() != null && !record.getNextVisit().isBlank()) {
            sb.append("[다음방문:").append(record.getNextVisit().trim()).append("] ");
        }
        if (record.getMemo() != null && !record.getMemo().isBlank()) {
            sb.append(record.getMemo().trim());
        }
        String memo = sb.toString().trim();
        return memo.isEmpty() ? null : memo;
    }

    // 2026/07/13 장우철 — 진료기록 목록
    @Override
    @Transactional(readOnly = true)
    public List<MedicalRecordVO> getMedicalRecords(Long hospitalId, String keyword, Integer periodMonths)
            throws Exception {
        if (hospitalId == null) {
            return List.of();
        }
        String kw = (keyword == null || keyword.isBlank()) ? null : keyword.trim();
        List<MedicalRecordVO> list = bizHospitalMapper.selectMedicalRecords(hospitalId, kw, periodMonths);
        // 2026-07-28 박유정 — MEMO 태그 파싱 후 유형·신체계측·수의사메모 분리 (상세보기 모달용)
        for (MedicalRecordVO r : list) {
            MedicalRecordMemoParser.parse(r);
        }
        return list;
    }

    @Override
    @Transactional(readOnly = true)
    public MedicalRecordVO getMedicalRecordDetail(Long hospitalId, Long recordId) throws Exception {
        if (hospitalId == null || recordId == null) {
            return null;
        }
        MedicalRecordVO record = bizHospitalMapper.selectMedicalRecordDetail(hospitalId, recordId);
        // 2026-07-28 박유정 — MEMO 태그 파싱 (상세보기)
        if (record != null) {
            MedicalRecordMemoParser.parse(record);
        }
        return record;
    }

    // 2026/07/13 장우철 — 진료기록 작성 모달용
    @Override
    @Transactional(readOnly = true)
    public List<ReservationVO> getConfirmedWithoutRecord(Long hospitalId) throws Exception {
        if (hospitalId == null) {
            return List.of();
        }
        return bizHospitalMapper.selectConfirmedWithoutRecord(hospitalId);
    }

    // 2026/07/14 장우철 — 사업자 리뷰관리 목록
    @Override
    @Transactional(readOnly = true)
    public List<HospitalReviewVO> getBizHospitalReviews(Long hospitalId) throws Exception {
        if (hospitalId == null) {
            return List.of();
        }
        return bizHospitalMapper.selectBizHospitalReviews(hospitalId);
    }

    // 2026/07/14 장우철 — 답글 작성/수정 + 회원 알림
    @Override
    @Transactional
    public void saveReviewBizReply(Long hospitalId, Long reviewId, String bizReply) throws Exception {
        if (hospitalId == null || reviewId == null) {
            throw new IllegalArgumentException("리뷰 정보가 올바르지 않습니다.");
        }
        if (bizReply == null || bizReply.isBlank()) {
            throw new IllegalArgumentException("답글 내용을 입력해 주세요.");
        }
        String reply = bizReply.trim();
        if (reply.length() > 2000) {
            reply = reply.substring(0, 2000);
        }

        HospitalReviewVO current = bizHospitalMapper.selectBizHospitalReview(hospitalId, reviewId);
        if (current == null) {
            throw new IllegalStateException("리뷰를 찾을 수 없거나 권한이 없습니다.");
        }

        int updated = bizHospitalMapper.updateReviewBizReply(hospitalId, reviewId, reply);
        if (updated == 0) {
            throw new IllegalStateException("답글 저장에 실패했습니다.");
        }

        String hospitalName = bizHospitalMapper.selectHospitalNameById(hospitalId);
        mypageNotifyService.sendHospitalReviewReplyNotification(
                current.getMemberNo(), hospitalName, current.getResvId(), hospitalId);
    }

    // 2026-07-24 박유정 — 리뷰 삭제 요청 INSERT (PENDING 중복 체크 → TB_REVIEW_DELETE_REQUEST)
    @Override
    @Transactional
    public void requestReviewDelete(Long hospitalId, Long bizNo, Long reviewId, String requestReason) throws Exception {
        if (hospitalId == null || bizNo == null || reviewId == null) {
            throw new IllegalArgumentException("요청 정보가 올바르지 않습니다.");
        }
        if (requestReason == null || requestReason.isBlank()) {
            throw new IllegalArgumentException("삭제 요청 사유를 입력해 주세요.");
        }
        String reason = requestReason.trim();
        if (reason.length() > 500) {
            reason = reason.substring(0, 500);
        }

        HospitalReviewVO current = bizHospitalMapper.selectBizHospitalReview(hospitalId, reviewId);
        if (current == null) {
            throw new IllegalStateException("리뷰를 찾을 수 없거나 권한이 없습니다.");
        }

        if (bizHospitalMapper.countPendingReviewDeleteRequest(reviewId, bizNo) > 0) {
            throw new IllegalStateException("이미 삭제 요청이 접수된 리뷰입니다.");
        }

        ReviewDeleteRequestVO vo = new ReviewDeleteRequestVO();
        vo.setReviewId(reviewId);
        vo.setReviewType("HOSPITAL");
        vo.setTargetId(hospitalId);
        vo.setBizNo(bizNo);
        vo.setRequestReason(reason);
        vo.setStatusCd("PENDING");
        int inserted = bizHospitalMapper.insertReviewDeleteRequest(vo);
        if (inserted == 0) {
            throw new IllegalStateException("삭제 요청 접수에 실패했습니다.");
        }
    }

    // 2026-07-24 박유정 — 사업자 리뷰관리 삭제요청 탭 목록
    @Override
    @Transactional(readOnly = true)
    public List<ReviewDeleteRequestVO> getBizReviewDeleteRequests(Long hospitalId, Long bizNo) throws Exception {
        if (hospitalId == null || bizNo == null) {
            return List.of();
        }
        return bizHospitalMapper.selectBizReviewDeleteRequests(hospitalId, bizNo);
    }

    // 2026/07/16 장우철 고도화작업 — 병원 스케줄 CRUD
    @Override
    @Transactional(readOnly = true)
    public List<HospitalTreatTypeVO> getTreatTypeList(Long hospitalId) throws Exception {
        if (hospitalId == null) return List.of();
        return bizHospitalMapper.selectTreatTypeList(hospitalId);
    }

    @Override
    @Transactional
    public void saveTreatType(Long hospitalId, HospitalTreatTypeVO vo) throws Exception {
        if (hospitalId == null || vo == null) {
            throw new IllegalArgumentException("진료유형 정보가 올바르지 않습니다.");
        }
        if (vo.getTypeName() == null || vo.getTypeName().isBlank()) {
            throw new IllegalArgumentException("유형명을 입력해 주세요.");
        }
        if (vo.getDurationMin() == null || vo.getDurationMin() <= 0) {
            throw new IllegalArgumentException("소요 시간(분)은 1 이상으로 입력해 주세요.");
        }
        if (vo.getDurationMin() > 480) {
            throw new IllegalArgumentException("소요 시간(분)은 480분(8시간) 이하로 입력해 주세요.");
        }
        vo.setHospitalId(hospitalId);
        vo.setTypeName(vo.getTypeName().trim());
        if (vo.getStatusCd() == null || vo.getStatusCd().isBlank()) {
            vo.setStatusCd("Y");
        }
        if (vo.getTreatTypeId() == null) {
            bizHospitalMapper.insertTreatType(vo);
        } else {
            if (bizHospitalMapper.selectTreatType(hospitalId, vo.getTreatTypeId()) == null) {
                throw new IllegalStateException("진료유형을 찾을 수 없습니다.");
            }
            bizHospitalMapper.updateTreatType(vo);
        }
    }

    @Override
    @Transactional
    public void deleteTreatType(Long hospitalId, Long treatTypeId) throws Exception {
        if (hospitalId == null || treatTypeId == null) {
            throw new IllegalArgumentException("삭제 대상이 올바르지 않습니다.");
        }
        int n = bizHospitalMapper.deleteTreatType(hospitalId, treatTypeId);
        if (n == 0) {
            throw new IllegalStateException("진료유형을 찾을 수 없거나 이미 삭제되었습니다.");
        }
    }

    @Override
    @Transactional(readOnly = true)
    public List<HospitalDoctorVO> getDoctorList(Long hospitalId) throws Exception {
        if (hospitalId == null) return List.of();
        return bizHospitalMapper.selectDoctorList(hospitalId);
    }

    @Override
    @Transactional
    public void saveDoctor(Long hospitalId, HospitalDoctorVO vo) throws Exception {
        if (hospitalId == null || vo == null) {
            throw new IllegalArgumentException("의사 정보가 올바르지 않습니다.");
        }
        if (vo.getDoctorName() == null || vo.getDoctorName().isBlank()) {
            throw new IllegalArgumentException("의사명을 입력해 주세요.");
        }
        vo.setHospitalId(hospitalId);
        vo.setDoctorName(vo.getDoctorName().trim());
        if (vo.getSpecialty() != null) {
            vo.setSpecialty(vo.getSpecialty().trim());
        }
        if (vo.getStatusCd() == null || vo.getStatusCd().isBlank()) {
            vo.setStatusCd("Y");
        }
        if (vo.getDoctorId() == null) {
            bizHospitalMapper.insertDoctor(vo);
        } else {
            if (bizHospitalMapper.selectDoctor(hospitalId, vo.getDoctorId()) == null) {
                throw new IllegalStateException("의사를 찾을 수 없습니다.");
            }
            bizHospitalMapper.updateDoctor(vo);
        }
    }

    @Override
    @Transactional
    public void deleteDoctor(Long hospitalId, Long doctorId) throws Exception {
        if (hospitalId == null || doctorId == null) {
            throw new IllegalArgumentException("삭제 대상이 올바르지 않습니다.");
        }
        int n = bizHospitalMapper.deleteDoctor(hospitalId, doctorId);
        if (n == 0) {
            throw new IllegalStateException("의사를 찾을 수 없거나 이미 삭제되었습니다.");
        }
    }

    // 2026/07/16 장우철 고도화작업 — RESV_RULE 제거, 간격은 TB_HOSPITAL.RESV_INTERVAL_MIN
    @Override
    @Transactional(readOnly = true)
    public Integer getResvIntervalMin(Long hospitalId) throws Exception {
        if (hospitalId == null) return 15;
        Integer v = bizHospitalMapper.selectResvIntervalMin(hospitalId);
        return (v == null || v <= 0) ? 15 : v;
    }

    @Override
    @Transactional
    public void saveResvIntervalMin(Long hospitalId, Integer intervalMin) throws Exception {
        if (hospitalId == null) {
            throw new IllegalArgumentException("병원 정보가 올바르지 않습니다.");
        }
        if (intervalMin == null || intervalMin <= 0) {
            throw new IllegalArgumentException("예약 간격(분)을 1 이상 숫자로 입력해 주세요.");
        }
        if (intervalMin < 5 || intervalMin > 120) {
            throw new IllegalArgumentException("예약 간격은 5~120분 사이로 입력해 주세요.");
        }
        int n = bizHospitalMapper.updateResvIntervalMin(hospitalId, intervalMin);
        if (n == 0) {
            throw new IllegalStateException("병원을 찾을 수 없습니다.");
        }
    }

    private String normalizeTime(String t) {
        String v = t.trim();
        return v.length() >= 5 ? v.substring(0, 5) : v;
    }

    @Override
    @Transactional(readOnly = true)
    public List<HospitalResvExceptionVO> getResvExceptionList(Long hospitalId, String fromDate, String toDate)
            throws Exception {
        if (hospitalId == null) return List.of();
        return bizHospitalMapper.selectResvExceptionList(hospitalId, fromDate, toDate);
    }

    @Override
    @Transactional
    public void saveResvException(Long hospitalId, HospitalResvExceptionVO vo) throws Exception {
        if (hospitalId == null || vo == null) {
            throw new IllegalArgumentException("예외 정보가 올바르지 않습니다.");
        }
        if (vo.getExcDate() == null) {
            throw new IllegalArgumentException("예외 날짜를 입력해 주세요.");
        }
        if (vo.getExcType() == null || vo.getExcType().isBlank()) {
            throw new IllegalArgumentException("예외 유형을 선택해 주세요.");
        }
        String type = vo.getExcType().trim().toUpperCase();
        if (!"CLOSE".equals(type) && !"REPLACE".equals(type)) {
            throw new IllegalArgumentException("예외 유형은 CLOSE 또는 REPLACE 입니다.");
        }
        vo.setExcType(type);
        if (vo.getStartTime() == null || vo.getStartTime().isBlank()
                || vo.getEndTime() == null || vo.getEndTime().isBlank()) {
            throw new IllegalArgumentException("시작·종료 시각을 입력해 주세요.");
        }
        vo.setHospitalId(hospitalId);
        vo.setStartTime(normalizeTime(vo.getStartTime()));
        vo.setEndTime(normalizeTime(vo.getEndTime()));
        if (vo.getStartTime().compareTo(vo.getEndTime()) >= 0) {
            throw new IllegalArgumentException("종료 시각은 시작 시각보다 늦어야 합니다.");
        }
        if (vo.getStatusCd() == null || vo.getStatusCd().isBlank()) {
            vo.setStatusCd("Y");
        }
        if (vo.getDoctorId() != null
                && bizHospitalMapper.selectDoctor(hospitalId, vo.getDoctorId()) == null) {
            throw new IllegalArgumentException("해당 병원에 없는 의사입니다.");
        }
        if (vo.getExcId() == null) {
            bizHospitalMapper.insertResvException(vo);
        } else {
            if (bizHospitalMapper.selectResvException(hospitalId, vo.getExcId()) == null) {
                throw new IllegalStateException("예외를 찾을 수 없습니다.");
            }
            bizHospitalMapper.updateResvException(vo);
        }
    }

    @Override
    @Transactional
    public void deleteResvException(Long hospitalId, Long excId) throws Exception {
        if (hospitalId == null || excId == null) {
            throw new IllegalArgumentException("삭제 대상이 올바르지 않습니다.");
        }
        int n = bizHospitalMapper.deleteResvException(hospitalId, excId);
        if (n == 0) {
            throw new IllegalStateException("예외를 찾을 수 없거나 이미 삭제되었습니다.");
        }
    }

    // ── 대시보드 ──

    @Override
    public com.petcare.petcare.biz.vo.BizDashboardVO getDashboardData(Long hospitalId, int chartDays) throws Exception {
        com.petcare.petcare.biz.vo.BizDashboardVO dash = new com.petcare.petcare.biz.vo.BizDashboardVO();
        String today = java.time.LocalDate.now().toString();
        String yesterday = java.time.LocalDate.now().minusDays(1).toString();

        // 요약 카드
        dash.setTodayResvCount(bizHospitalMapper.countResvByDate(hospitalId, today));
        dash.setTodayResvYesterday(bizHospitalMapper.countResvByDate(hospitalId, yesterday));
        // 지윤 26.08.13 추가: 오늘 예약 카드 옆 괄호용
        dash.setTodayCancelCount(bizHospitalMapper.countCancelByDate(hospitalId, today));
        dash.setPendingCount(bizHospitalMapper.countPendingReservations(hospitalId));
        dash.setPendingYesterday(0);
        dash.setDoneCount(bizHospitalMapper.countDoneByDate(hospitalId, today));
        dash.setDoneYesterday(bizHospitalMapper.countDoneByDate(hospitalId, yesterday));
        dash.setMonthRevenue(bizHospitalMapper.sumMonthRevenue(hospitalId, today));
        dash.setMonthRevenueYesterday(bizHospitalMapper.sumMonthRevenue(hospitalId, yesterday));
        // 지윤 26.08.13 추가: 병원은 결제 연동이 없어 매출 대신 이번 달 진료완료 건수 사용
        dash.setMonthDoneCount(bizHospitalMapper.sumMonthDoneCount(hospitalId, today));
        dash.setMonthDoneYesterday(bizHospitalMapper.sumMonthDoneCount(hospitalId, yesterday));

        // 상태 현황 (도넛)
        java.util.List<java.util.Map<String, Object>> statusList = bizHospitalMapper.countByStatus(hospitalId);
        int total = 0;
        for (java.util.Map<String, Object> row : statusList) {
            String st = (String) row.get("STATUS_CD");
            int cnt = ((Number) row.get("CNT")).intValue();
            total += cnt;
            if ("CONFIRMED".equals(st)) dash.setStatusConfirmed(cnt);
            else if ("PENDING".equals(st)) dash.setStatusPending(cnt);
            else if ("DONE".equals(st)) dash.setStatusDone(cnt);
            else if ("CANCEL".equals(st) || "REJECTED".equals(st))
                dash.setStatusCancel(dash.getStatusCancel() + cnt);
        }
        dash.setTotalStatusCount(total);

        // 차트 (일별)
        // 지윤 26.08.13 수정: 매출 대신 진료완료/취소 건수로 변경
        java.util.List<com.petcare.petcare.biz.vo.DailyStatVO> dailyList = bizHospitalMapper.selectDailyStats(hospitalId, chartDays);
        java.util.List<String> labels = new java.util.ArrayList<>();
        java.util.List<Integer> counts = new java.util.ArrayList<>();
        java.util.List<Integer> doneCounts = new java.util.ArrayList<>();
        java.util.List<Integer> cancelCounts = new java.util.ArrayList<>();
        for (com.petcare.petcare.biz.vo.DailyStatVO d : dailyList) {
            labels.add(d.getDt());
            counts.add(d.getResvCount());
            doneCounts.add(d.getDoneCount());
            cancelCounts.add(d.getCancelCount());
        }
        dash.setChartLabels(labels);
        dash.setChartResvCounts(counts);
        dash.setChartDoneCounts(doneCounts);
        dash.setChartCancelCounts(cancelCounts);

        return dash;
    }

    // 지윤 26.08.13 추가: 일간/월간 버튼 전환용 - 차트 데이터만 따로 조회
    // period='monthly'면 최근 6개월(월 단위), 그 외(기본 daily)는 최근 7일(일 단위)
    @Override
    public java.util.List<com.petcare.petcare.biz.vo.DailyStatVO> getChartData(Long hospitalId, String period) {
        if ("monthly".equals(period)) {
            return bizHospitalMapper.selectMonthlyStats(hospitalId, 6);
        }
        return bizHospitalMapper.selectDailyStats(hospitalId, 7);
    }

    @Override
    public java.util.List<com.petcare.petcare.hospital.vo.ReservationVO> getTodayResvList(Long hospitalId) {
        return bizHospitalMapper.selectTodayResvList(hospitalId);
    }

    @Override
    public java.util.List<com.petcare.petcare.hospital.vo.HospitalReviewVO> getRecentReviews(Long hospitalId) {
        return bizHospitalMapper.selectRecentReviews(hospitalId);
    }
}
