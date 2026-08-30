/**
 * 역할: 사업자 동물병원 URL 처리 → Service 호출 → JSP 반환
 *
 * - 박유정 / 2026-07-14 (재능나눔 신청 — 병원만 DB 연동)
 *
 * 연결
 * - Service: BizHospitalService, GiveTalentService
 * - 상속: BizBaseController (사업자 로그인 체크)
 *
 * SQL·비즈니스 로직은 넣지 말 것 → Service로 위임
 * return 경로는 담당 JSP와 동일하게 맞출 것
 */

package com.petcare.petcare.biz.hospital.controller;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.petcare.petcare.biz.controller.BizBaseController;
import com.petcare.petcare.biz.hospital.service.BizHospitalService;
import com.petcare.petcare.give.talent.service.GiveTalentService;
import com.petcare.petcare.give.talent.vo.GiveTalentVO;
import com.petcare.petcare.file.service.FileService;
import com.petcare.petcare.file.vo.FileVO;
import com.petcare.petcare.hospital.vo.HospitalDoctorVO;
import com.petcare.petcare.hospital.vo.HospitalResvExceptionVO;
import com.petcare.petcare.hospital.vo.HospitalReviewVO;
import com.petcare.petcare.hospital.vo.HospitalTreatTypeVO;
import com.petcare.petcare.hospital.vo.HospitalVO;
import com.petcare.petcare.hospital.vo.MedicalRecordVO;
import com.petcare.petcare.hospital.vo.ReservationVO;
import com.petcare.petcare.hospital.vo.ReviewDeleteRequestVO;
import com.petcare.petcare.member.vo.MemberVO;

import jakarta.servlet.http.HttpSession;

import org.springframework.beans.propertyeditors.CustomNumberEditor;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.InitBinder;

@Controller("bizHospitalController")
@RequestMapping("/biz/hospital")
public class BizHospitalController extends BizBaseController {

    @Autowired
    private BizHospitalService bizHospitalService;
    // 2026-07-14 박유정 — STEP 4 재능나눔 신청·이력 (biz/hospital/talent.jsp)
    @Autowired
    private GiveTalentService giveTalentService;
    @Autowired
    private FileService fileService;
    @Autowired
    private ObjectMapper objectMapper;
    // 2026/08/01 장우철 — 병원 쿠폰 (BizStayService 공용)
    @Autowired
    private com.petcare.petcare.biz.stay.service.BizStayService bizStayService;

    // 2026/07/11 장우철 — 모든 병원 사업자 화면에 PENDING 배지 건수 전달
    // [변경] sidebar_hospital.jsp 뱃지 5 고정
    @ModelAttribute("pendingReserveCount")
    public int pendingReserveCount(HttpSession session) {
        try {
            MemberVO member = getBizMember(session);
            if (member == null || member.getMemberId() == null) {
                return 0;
            }
            HospitalVO hospital = bizHospitalService.getHospitalByBizId(member.getMemberId());
            if (hospital == null || hospital.getHospitalId() == null) {
                return 0;
            }
            return bizHospitalService.countPendingReservations(hospital.getHospitalId());
        } catch (Exception e) {
            return 0;
        }
    }

    // 2026-08-10 박유정 — 재능나눔 참여 신청 확인 대기 건수 (사이드바 뱃지)
    @ModelAttribute("pendingTalentApplyCount")
    public int pendingTalentApplyCount(HttpSession session) {
        try {
            MemberVO member = getBizMember(session);
            if (member == null || member.getMemberId() == null) {
                return 0;
            }
            return giveTalentService.countPendingAppliesByBizId(member.getMemberId());
        } catch (Exception e) {
            return 0;
        }
    }

    // 2026/07/11 장우철 — 캘린더 메뉴: 오늘 예약확정(CONFIRMED) 건수
    @ModelAttribute("todayConfirmedCount")
    public int todayConfirmedCount(HttpSession session) {
        try {
            MemberVO member = getBizMember(session);
            if (member == null || member.getMemberId() == null) {
                return 0;
            }
            HospitalVO hospital = bizHospitalService.getHospitalByBizId(member.getMemberId());
            if (hospital == null || hospital.getHospitalId() == null) {
                return 0;
            }
            return bizHospitalService.countTodayConfirmedReservations(hospital.getHospitalId());
        } catch (Exception e) {
            return 0;
        }
    }

    // ════ 병원 (HOSPITAL) ════
    @GetMapping({"", "/"})
    public String hospitalDashboard(HttpSession session, Model model) throws Exception {

        MemberVO member = getBizMember(session);
        if (member == null)
            return "redirect:/login";

        HospitalVO hospital = bizHospitalService.resolveHospitalByBizId(member.getMemberId());
        model.addAttribute("hospital", hospital);
        //HYJ 26.08.06 대시보드
        model.addAttribute("dash", bizHospitalService.getDashboardData(hospital.getHospitalId(), 7));
        model.addAttribute("todayList", bizHospitalService.getTodayResvList(hospital.getHospitalId()));
        model.addAttribute("recentReviews", bizHospitalService.getRecentReviews(hospital.getHospitalId()));

        return "biz/hospital/dashboard";
    }

    // 지윤 26.08.13 추가: 일간/월간 버튼 전환용 - 차트 데이터만 JSON으로 반환
    @GetMapping("/dashboard/chart")
    @ResponseBody
    public List<com.petcare.petcare.biz.vo.DailyStatVO> hospitalDashboardChart(
            @RequestParam(defaultValue = "daily") String period,
            HttpSession session) throws Exception {

        MemberVO member = getBizMember(session);
        if (member == null)
            return new ArrayList<>();

        HospitalVO hospital = bizHospitalService.resolveHospitalByBizId(member.getMemberId());
        return bizHospitalService.getChartData(hospital.getHospitalId(), period);
    }

    // 2026-07-10 장우철 — 사업자 예약 관리 (F4)
    @GetMapping("/reserve")
    public String hospitalReserve(HttpSession session, Model model) throws Exception {
        MemberVO member = getBizMember(session);
        if (member == null) {
            return "redirect:/login";
        }

        HospitalVO hospital = bizHospitalService.resolveHospitalByBizId(member.getMemberId());
        if (hospital == null || hospital.getHospitalId() == null) {
            return "redirect:/mypage/biz";
        }

        model.addAttribute("hospital", hospital);
        model.addAttribute("reservationList",
                bizHospitalService.getReservationList(hospital.getHospitalId(), "all"));
        return "biz/hospital/reserve";
    }

    // 2026-07-10 장우철 — 사업자 예약 상태 변경 (F5)
    // 2026/07/11 장우철 — cancelReason: CANCEL 시 필수
    @PostMapping("/reserve/status")
    public String updateReservationStatus(@RequestParam("resvId") Long resvId,
                                          @RequestParam("statusCd") String statusCd,
                                          @RequestParam(value = "cancelReason", required = false) String cancelReason,
                                          HttpSession session,
                                          RedirectAttributes rttr) throws Exception {
        MemberVO member = getBizMember(session);
        if (member == null) {
            return "redirect:/login";
        }

        HospitalVO hospital = bizHospitalService.resolveHospitalByBizId(member.getMemberId());
        if (hospital == null || hospital.getHospitalId() == null) {
            return "redirect:/mypage/biz";
        }

        try {
            bizHospitalService.updateReservationStatus(
                    hospital.getHospitalId(), resvId, statusCd, cancelReason);
            rttr.addFlashAttribute("msg", "예약 상태가 변경되었습니다.");
        } catch (IllegalStateException | IllegalArgumentException e) {
            rttr.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/biz/hospital/reserve";
    }

    // 2026-07-10 장우철 — 사업자 예약 상세 모달 API (F6)
    @GetMapping("/reserve/detail")
    @ResponseBody
    public ReservationVO reservationDetail(@RequestParam("resvId") Long resvId,
                                           HttpSession session) throws Exception {
        MemberVO member = getBizMember(session);
        if (member == null) {
            return null;
        }

        HospitalVO hospital = bizHospitalService.resolveHospitalByBizId(member.getMemberId());
        if (hospital == null || hospital.getHospitalId() == null) {
            return null;
        }

        return bizHospitalService.getReservationDetail(hospital.getHospitalId(), resvId);
    }

    // 2026-07-10 장우철 — 사업자 예약 캘린더 (F7)
    @GetMapping("/calendar")
    public String hospitalCalendar(@RequestParam(value = "from", required = false) String fromDate,
                                   @RequestParam(value = "to", required = false) String toDate,
                                   HttpSession session,
                                   Model model) throws Exception {
        MemberVO member = getBizMember(session);
        if (member == null) {
            return "redirect:/login";
        }

        HospitalVO hospital = bizHospitalService.resolveHospitalByBizId(member.getMemberId());
        if (hospital == null || hospital.getHospitalId() == null) {
            return "redirect:/mypage/biz";
        }

        if (fromDate == null || fromDate.isBlank()) {
            fromDate = java.time.LocalDate.now().minusMonths(3).toString();
        }
        if (toDate == null || toDate.isBlank()) {
            toDate = java.time.LocalDate.now().plusMonths(6).toString();
        }

        model.addAttribute("hospital", hospital);
        model.addAttribute("calendarReservations",
                bizHospitalService.getCalendarReservations(hospital.getHospitalId(), fromDate, toDate));
        return "biz/hospital/calendar";
    }

    // 2026/07/16 장우철 고도화작업 — 병원 스케줄 화면
    @GetMapping("/schedule")
    public String hospitalSchedule(HttpSession session) {
        if (getBizMember(session) == null)
            return "redirect:/login";
        return "biz/hospital/schedule";
    }

    // 2026/07/16 장우철 고도화작업 — 스케줄 API 공통: 로그인·병원 해석
    private HospitalVO requireScheduleHospital(HttpSession session) throws Exception {
        MemberVO member = getBizMember(session);
        if (member == null || member.getMemberId() == null) {
            return null;
        }
        return bizHospitalService.resolveHospitalByBizId(member.getMemberId());
    }

    private Map<String, Object> scheduleFail(String msg) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("ok", false);
        m.put("message", msg);
        return m;
    }

    private Map<String, Object> scheduleOk(Object data) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("ok", true);
        m.put("data", data);
        return m;
    }

    @GetMapping("/schedule/treat-types")
    @ResponseBody
    public Map<String, Object> listTreatTypes(HttpSession session) throws Exception {
        HospitalVO hospital = requireScheduleHospital(session);
        if (hospital == null || hospital.getHospitalId() == null) {
            return scheduleFail("로그인이 필요합니다.");
        }
        return scheduleOk(bizHospitalService.getTreatTypeList(hospital.getHospitalId()));
    }

    @PostMapping("/schedule/treat-types/save")
    @ResponseBody
    public Map<String, Object> saveTreatType(@RequestBody HospitalTreatTypeVO vo,
                                             HttpSession session) throws Exception {
        HospitalVO hospital = requireScheduleHospital(session);
        if (hospital == null || hospital.getHospitalId() == null) {
            return scheduleFail("로그인이 필요합니다.");
        }
        try {
            bizHospitalService.saveTreatType(hospital.getHospitalId(), vo);
            return scheduleOk(bizHospitalService.getTreatTypeList(hospital.getHospitalId()));
        } catch (IllegalArgumentException | IllegalStateException e) {
            return scheduleFail(e.getMessage());
        }
    }

    @PostMapping("/schedule/treat-types/delete")
    @ResponseBody
    public Map<String, Object> deleteTreatType(@RequestParam("treatTypeId") Long treatTypeId,
                                               HttpSession session) throws Exception {
        HospitalVO hospital = requireScheduleHospital(session);
        if (hospital == null || hospital.getHospitalId() == null) {
            return scheduleFail("로그인이 필요합니다.");
        }
        try {
            bizHospitalService.deleteTreatType(hospital.getHospitalId(), treatTypeId);
            return scheduleOk(bizHospitalService.getTreatTypeList(hospital.getHospitalId()));
        } catch (IllegalArgumentException | IllegalStateException e) {
            return scheduleFail(e.getMessage());
        }
    }

    @GetMapping("/schedule/doctors")
    @ResponseBody
    public Map<String, Object> listDoctors(HttpSession session) throws Exception {
        HospitalVO hospital = requireScheduleHospital(session);
        if (hospital == null || hospital.getHospitalId() == null) {
            return scheduleFail("로그인이 필요합니다.");
        }
        return scheduleOk(bizHospitalService.getDoctorList(hospital.getHospitalId()));
    }

    @PostMapping("/schedule/doctors/save")
    @ResponseBody
    public Map<String, Object> saveDoctor(@RequestBody HospitalDoctorVO vo,
                                          HttpSession session) throws Exception {
        HospitalVO hospital = requireScheduleHospital(session);
        if (hospital == null || hospital.getHospitalId() == null) {
            return scheduleFail("로그인이 필요합니다.");
        }
        try {
            bizHospitalService.saveDoctor(hospital.getHospitalId(), vo);
            return scheduleOk(bizHospitalService.getDoctorList(hospital.getHospitalId()));
        } catch (IllegalArgumentException | IllegalStateException e) {
            return scheduleFail(e.getMessage());
        }
    }

    @PostMapping("/schedule/doctors/delete")
    @ResponseBody
    public Map<String, Object> deleteDoctor(@RequestParam("doctorId") Long doctorId,
                                            HttpSession session) throws Exception {
        HospitalVO hospital = requireScheduleHospital(session);
        if (hospital == null || hospital.getHospitalId() == null) {
            return scheduleFail("로그인이 필요합니다.");
        }
        try {
            bizHospitalService.deleteDoctor(hospital.getHospitalId(), doctorId);
            return scheduleOk(bizHospitalService.getDoctorList(hospital.getHospitalId()));
        } catch (IllegalArgumentException | IllegalStateException e) {
            return scheduleFail(e.getMessage());
        }
    }

    // 2026/07/16 장우철 고도화작업 — RESV_RULE 제거, 예약 시작 간격만 병원 컬럼으로
    @GetMapping("/schedule/interval")
    @ResponseBody
    public Map<String, Object> getInterval(HttpSession session) throws Exception {
        HospitalVO hospital = requireScheduleHospital(session);
        if (hospital == null || hospital.getHospitalId() == null) {
            return scheduleFail("로그인이 필요합니다.");
        }
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("resvIntervalMin", bizHospitalService.getResvIntervalMin(hospital.getHospitalId()));
        return scheduleOk(data);
    }

    @PostMapping("/schedule/interval/save")
    @ResponseBody
    public Map<String, Object> saveInterval(@RequestBody Map<String, Object> body,
                                            HttpSession session) throws Exception {
        HospitalVO hospital = requireScheduleHospital(session);
        if (hospital == null || hospital.getHospitalId() == null) {
            return scheduleFail("로그인이 필요합니다.");
        }
        try {
            Integer intervalMin = null;
            if (body.get("resvIntervalMin") != null && !String.valueOf(body.get("resvIntervalMin")).isBlank()) {
                intervalMin = Integer.valueOf(String.valueOf(body.get("resvIntervalMin")));
            }
            bizHospitalService.saveResvIntervalMin(hospital.getHospitalId(), intervalMin);
            Map<String, Object> data = new LinkedHashMap<>();
            data.put("resvIntervalMin", bizHospitalService.getResvIntervalMin(hospital.getHospitalId()));
            return scheduleOk(data);
        } catch (IllegalArgumentException | IllegalStateException e) {
            return scheduleFail(e.getMessage());
        }
    }

    @GetMapping("/schedule/exceptions")
    @ResponseBody
    public Map<String, Object> listExceptions(
            @RequestParam(value = "fromDate", required = false) String fromDate,
            @RequestParam(value = "toDate", required = false) String toDate,
            HttpSession session) throws Exception {
        HospitalVO hospital = requireScheduleHospital(session);
        if (hospital == null || hospital.getHospitalId() == null) {
            return scheduleFail("로그인이 필요합니다.");
        }
        return scheduleOk(bizHospitalService.getResvExceptionList(hospital.getHospitalId(), fromDate, toDate));
    }

    @PostMapping("/schedule/exceptions/save")
    @ResponseBody
    public Map<String, Object> saveException(@RequestBody Map<String, Object> body,
                                             HttpSession session) throws Exception {
        HospitalVO hospital = requireScheduleHospital(session);
        if (hospital == null || hospital.getHospitalId() == null) {
            return scheduleFail("로그인이 필요합니다.");
        }
        try {
            HospitalResvExceptionVO vo = new HospitalResvExceptionVO();
            if (body.get("excId") != null && !String.valueOf(body.get("excId")).isBlank()) {
                vo.setExcId(Long.valueOf(String.valueOf(body.get("excId"))));
            }
            Object doctorId = body.get("doctorId");
            if (doctorId != null && !String.valueOf(doctorId).isBlank()
                    && !"null".equalsIgnoreCase(String.valueOf(doctorId))
                    && !"common".equalsIgnoreCase(String.valueOf(doctorId))) {
                vo.setDoctorId(Long.valueOf(String.valueOf(doctorId)));
            }
            String dateStr = body.get("excDate") == null ? null : String.valueOf(body.get("excDate"));
            if (dateStr != null && !dateStr.isBlank()) {
                vo.setExcDate(new SimpleDateFormat("yyyy-MM-dd").parse(dateStr));
            }
            vo.setExcType(body.get("excType") == null ? null : String.valueOf(body.get("excType")));
            vo.setStartTime(body.get("startTime") == null ? null : String.valueOf(body.get("startTime")));
            vo.setEndTime(body.get("endTime") == null ? null : String.valueOf(body.get("endTime")));
            vo.setMemo(body.get("memo") == null ? null : String.valueOf(body.get("memo")));
            vo.setStatusCd(body.get("statusCd") == null ? "Y" : String.valueOf(body.get("statusCd")));

            bizHospitalService.saveResvException(hospital.getHospitalId(), vo);
            return scheduleOk(bizHospitalService.getResvExceptionList(hospital.getHospitalId(), null, null));
        } catch (IllegalArgumentException | IllegalStateException e) {
            return scheduleFail(e.getMessage());
        }
    }

    @PostMapping("/schedule/exceptions/delete")
    @ResponseBody
    public Map<String, Object> deleteException(@RequestParam("excId") Long excId,
                                               HttpSession session) throws Exception {
        HospitalVO hospital = requireScheduleHospital(session);
        if (hospital == null || hospital.getHospitalId() == null) {
            return scheduleFail("로그인이 필요합니다.");
        }
        try {
            bizHospitalService.deleteResvException(hospital.getHospitalId(), excId);
            return scheduleOk(bizHospitalService.getResvExceptionList(hospital.getHospitalId(), null, null));
        } catch (IllegalArgumentException | IllegalStateException e) {
            return scheduleFail(e.getMessage());
        }
    }

    @GetMapping("/records")
    public String hospitalRecords(@RequestParam(value = "keyword", required = false) String keyword,
                                  @RequestParam(value = "period", required = false) Integer period,
                                  HttpSession session,
                                  Model model) throws Exception {
        // 2026/07/13 장우철 — 진료기록 목록 DB 연동
        MemberVO member = getBizMember(session);
        if (member == null) {
            return "redirect:/login";
        }
        HospitalVO hospital = bizHospitalService.resolveHospitalByBizId(member.getMemberId());
        if (hospital == null || hospital.getHospitalId() == null) {
            return "redirect:/mypage/biz";
        }
        model.addAttribute("hospital", hospital);
        model.addAttribute("keyword", keyword);
        model.addAttribute("period", period);
        model.addAttribute("recordList",
                bizHospitalService.getMedicalRecords(hospital.getHospitalId(), keyword, period));
        // 2026/07/13 장우철 — 작성 모달: 확정·미기록 예약 선택
        model.addAttribute("writableReserves",
                bizHospitalService.getConfirmedWithoutRecord(hospital.getHospitalId()));
        return "biz/hospital/records";
    }

    // 2026/07/13 장우철 — 예약확정 → 진료기록 저장 + DONE
    @PostMapping("/records/complete")
    public String completeWithRecord(@RequestParam("resvId") Long resvId,
                                     @RequestParam("symptoms") String symptoms,
                                     @RequestParam("diagnosis") String diagnosis,
                                     @RequestParam(value = "prescription", required = false) String prescription,
                                     @RequestParam(value = "memo", required = false) String memo,
                                     @RequestParam(value = "vetName", required = false) String vetName,
                                     @RequestParam(value = "treatType", required = false) String treatType,
                                     @RequestParam(value = "weight", required = false) String weight,
                                     @RequestParam(value = "temperature", required = false) String temperature,
                                     @RequestParam(value = "examItems", required = false) String examItems,
                                     @RequestParam(value = "heartRate", required = false) String heartRate,
                                     @RequestParam(value = "breathRate", required = false) String breathRate,
                                     @RequestParam(value = "nextVisit", required = false) String nextVisit,
                                     @RequestParam(value = "redirect", required = false) String redirect,
                                     HttpSession session,
                                     RedirectAttributes rttr) throws Exception {
        MemberVO member = getBizMember(session);
        if (member == null) {
            return "redirect:/login";
        }
        HospitalVO hospital = bizHospitalService.resolveHospitalByBizId(member.getMemberId());
        if (hospital == null || hospital.getHospitalId() == null) {
            return "redirect:/mypage/biz";
        }

        MedicalRecordVO record = new MedicalRecordVO();
        record.setResvId(resvId);
        record.setSymptoms(symptoms);
        record.setDiagnosis(diagnosis);
        record.setPrescription(prescription);
        record.setMemo(memo);
        record.setVetName(vetName);
        record.setTreatType(treatType);
        record.setWeight(weight);
        record.setTemperature(temperature);
        record.setExamItems(examItems);
        record.setHeartRate(heartRate);
        record.setBreathRate(breathRate);
        record.setNextVisit(nextVisit);

        try {
            bizHospitalService.completeReservationWithRecord(hospital.getHospitalId(), record);
            rttr.addFlashAttribute("msg", "진료완료 및 진료기록이 저장되었습니다.");
        } catch (IllegalArgumentException | IllegalStateException e) {
            rttr.addFlashAttribute("errorMsg", e.getMessage());
        }
        // 2026/07/13 장우철 — 기록관리에서 작성 시 기록 목록으로, 아니면 예약관리로
        if ("records".equals(redirect)) {
            return "redirect:/biz/hospital/records";
        }
        return "redirect:/biz/hospital/reserve";
    }

    // 2026-07-14 박유정 — STEP 4 재능나눔 신청 (병원만 실제 DB 연동)
    // 이유: 타 방향(미용 등) 다른 사업자는 더미 화면 유지, 병원만 TB_TALENT INSERT
    @GetMapping("/talent")
    public String hospitalTalent(HttpSession session, Model model) {
        MemberVO member = getBizMember(session);
        if (member == null)
            return "redirect:/login";
        String bizId = member.getMemberId();
        model.addAttribute("talentList", giveTalentService.getTalentListByBizId(bizId));
        // 2026-08-10 박유정 — 참여 신청자 목록 (STEP 6)
        model.addAttribute("applyList", giveTalentService.getAppliesByBizId(bizId));
        return "biz/hospital/talent";
    }

    // 2026-07-14 박유정 — STEP 4 재능나눔 신청 POST → GiveTalentService.applyTalent (PENDING)
    // 2026-08-10 박유정 — thumbImage 대표 이미지 multipart 추가
    @PostMapping("/talent")
    public String hospitalTalentSubmit(@RequestParam String title,
                                       @RequestParam int capacity,
                                       @RequestParam String schedule,
                                       @RequestParam(required = false) String duration,
                                       @RequestParam String location,
                                       @RequestParam(required = false) String contact,
                                       @RequestParam String body,
                                       @RequestParam(value = "thumbImage", required = false) MultipartFile thumbImage,
                                       HttpSession session,
                                       RedirectAttributes rttr) {
        MemberVO member = getBizMember(session);
        if (member == null)
            return "redirect:/login";

        GiveTalentVO vo = new GiveTalentVO();
        vo.setTitle(title.trim());
        vo.setTalentType("HOSPITAL");
        vo.setCapacity(capacity);
        vo.setSchedule(schedule.trim());
        vo.setDuration(duration != null ? duration.trim() : null);
        vo.setLocation(location.trim());
        vo.setContact(contact != null ? contact.trim() : null);
        vo.setBody(body.trim());

        try {
            giveTalentService.applyTalent(member.getMemberId(), vo, thumbImage);
            rttr.addFlashAttribute("msg", "재능나눔 신청이 완료되었습니다.");
        } catch (IllegalStateException e) {
            String err = "신청할 수 없습니다.";
            if ("BIZ_NOT_APPROVED".equals(e.getMessage())) {
                err = "사업자 승인이 완료된 후 재능나눔을 신청할 수 있습니다.";
            } else if ("BIZ_NOT_FOUND".equals(e.getMessage())) {
                err = "등록된 사업자 정보를 찾을 수 없습니다.";
            }
            rttr.addFlashAttribute("errorMsg", err);
        } catch (IllegalArgumentException e) {
            rttr.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/biz/hospital/talent";
    }

    // 2026/07/14 장우철 — 사업자 리뷰관리 (DB 목록)
    @GetMapping("/reviews")
    public String hospitalReviews(HttpSession session, Model model) throws Exception {
        MemberVO member = getBizMember(session);
        if (member == null) {
            return "redirect:/login";
        }
        HospitalVO hospital = bizHospitalService.resolveHospitalByBizId(member.getMemberId());
        if (hospital == null || hospital.getHospitalId() == null) {
            return "redirect:/mypage/biz";
        }

        List<HospitalReviewVO> reviewList =
                bizHospitalService.getBizHospitalReviews(hospital.getHospitalId());

        // 2026-07-24 박유정 — 삭제요청 탭 + PENDING 뱃지용
        List<ReviewDeleteRequestVO> deleteRequests = List.of();
        if (hospital.getBizNo() != null) {
            deleteRequests = bizHospitalService.getBizReviewDeleteRequests(
                    hospital.getHospitalId(), hospital.getBizNo());
        }
        Set<Long> pendingReviewIds = new HashSet<>();
        for (ReviewDeleteRequestVO dr : deleteRequests) {
            if ("PENDING".equals(dr.getStatusCd()) && dr.getReviewId() != null) {
                pendingReviewIds.add(dr.getReviewId());
            }
        }

        SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");
        List<Map<String, Object>> rows = new ArrayList<>();
        for (HospitalReviewVO r : reviewList) {
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("id", r.getReviewId());
            row.put("author", (r.getNickname() != null && !r.getNickname().isBlank())
                    ? r.getNickname() : "회원");
            row.put("date", r.getRegDate() != null ? df.format(r.getRegDate()) : "");
            row.put("rating", r.getRating() != null ? r.getRating() : 0);
            row.put("content", r.getContent() != null ? r.getContent() : "");
            row.put("reply", r.getBizReply());
            row.put("deleteRequestPending", pendingReviewIds.contains(r.getReviewId()));
            rows.add(row);
        }

        List<Map<String, Object>> deleteRows = new ArrayList<>();
        for (ReviewDeleteRequestVO dr : deleteRequests) {
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("requestId", dr.getRequestId());
            row.put("reviewId", dr.getReviewId());
            row.put("author", (dr.getReviewerNickname() != null && !dr.getReviewerNickname().isBlank())
                    ? dr.getReviewerNickname() : "회원");
            row.put("rating", dr.getReviewRating() != null ? dr.getReviewRating() : 0);
            row.put("content", dr.getReviewContent() != null ? dr.getReviewContent() : "(삭제된 리뷰)");
            row.put("requestReason", dr.getRequestReason() != null ? dr.getRequestReason() : "");
            row.put("rejectReason", dr.getRejectReason());
            row.put("statusCd", dr.getStatusCd());
            row.put("reqDate", dr.getReqDate() != null ? df.format(dr.getReqDate()) : "");
            row.put("processDate", dr.getProcessDate() != null ? df.format(dr.getProcessDate()) : "");
            deleteRows.add(row);
        }

        model.addAttribute("hospital", hospital);
        model.addAttribute("reviewListJson", objectMapper.writeValueAsString(rows));
        model.addAttribute("deleteRequestListJson", objectMapper.writeValueAsString(deleteRows));
        return "biz/hospital/reviews";
    }

    // 2026/07/14 장우철 — 리뷰 답글 작성/수정
    @PostMapping("/reviews/reply")
    public String saveReviewReply(@RequestParam("reviewId") Long reviewId,
                                  @RequestParam("bizReply") String bizReply,
                                  HttpSession session,
                                  RedirectAttributes rttr) throws Exception {
        MemberVO member = getBizMember(session);
        if (member == null) {
            return "redirect:/login";
        }
        HospitalVO hospital = bizHospitalService.resolveHospitalByBizId(member.getMemberId());
        if (hospital == null || hospital.getHospitalId() == null) {
            return "redirect:/mypage/biz";
        }
        try {
            bizHospitalService.saveReviewBizReply(hospital.getHospitalId(), reviewId, bizReply);
            rttr.addFlashAttribute("msg", "답글이 저장되었습니다.");
        } catch (IllegalArgumentException | IllegalStateException e) {
            rttr.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/biz/hospital/reviews";
    }
    

    // 2026-07-24 박유정 — 리뷰 삭제 요청 (사유 입력 → TB_REVIEW_DELETE_REQUEST)
    @PostMapping("/reviews/delete-request")
    public String requestReviewDelete(@RequestParam("reviewId") Long reviewId,
                                      @RequestParam("requestReason") String requestReason,
                                      HttpSession session,
                                      RedirectAttributes rttr) throws Exception {
        MemberVO member = getBizMember(session);
        if (member == null) {
            return "redirect:/login";
        }
        HospitalVO hospital = bizHospitalService.resolveHospitalByBizId(member.getMemberId());
        if (hospital == null || hospital.getHospitalId() == null || hospital.getBizNo() == null) {
            return "redirect:/mypage/biz";
        }
        try {
            bizHospitalService.requestReviewDelete(
                    hospital.getHospitalId(),
                    hospital.getBizNo(),
                    reviewId,
                    requestReason);
            rttr.addFlashAttribute("msg", "삭제 요청이 접수되었습니다. 관리자 검토 후 처리됩니다.");
        } catch (IllegalArgumentException | IllegalStateException e) {
            rttr.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/biz/hospital/reviews";
    }
    
    @GetMapping("/contract")
    public String hospitalContract(HttpSession session) {
        if (getBizMember(session) == null)
            return "redirect:/login";
        return "biz/hospital/contract";
    }

    // 2026-07-10 장우철 yeju merge — 사업자 정보 조회 (info.jsp, yeju 간소 화면)
    @GetMapping("/info")
    public String hospitalInfo(HttpSession session, Model model) throws Exception {
        MemberVO member = getBizMember(session);
        if (member == null) {
            return "redirect:/login";
        }

        HospitalVO hospital = bizHospitalService.resolveHospitalByBizId(member.getMemberId());
        if (hospital == null) {
            return "redirect:/mypage/biz";
        }
        model.addAttribute("hospital", hospital);
        return "biz/hospital/info";
    }

    // 2026-07-10 장우철 yeju merge — 병원 정보 등록/수정 (profile.jsp, yeju DB)
    @GetMapping("/profile")
    public String hospitalProfile(HttpSession session, Model model) throws Exception {
        MemberVO member = getBizMember(session);
        if (member == null) {
            return "redirect:/login";
        }

        HospitalVO hospital = bizHospitalService.resolveHospitalByBizId(member.getMemberId());
        if (hospital == null || hospital.getHospitalId() == null) {
            return "redirect:/mypage/biz";
        }
        model.addAttribute("hospital", hospital);

        List<FileVO> imgList = fileService.getFileList("HOSPITAL", hospital.getHospitalId());
        model.addAttribute("imgList", imgList);
        return "biz/hospital/profile";
    }

    // 2026-07-10 장우철 yeju merge — yeju profile.jsp → POST /profile + resolveHospital
    @PostMapping("/profile")
    public String saveProfile(HospitalVO vo,
                              @RequestParam(value = "tagList", required = false) String[] tagList,
                              @RequestParam(value = "imgList", required = false) MultipartFile[] imgList,
                              @RequestParam(value = "deleteFileIds", required = false) Long[] deleteFileIds,
                              HttpSession session,
                              RedirectAttributes rttr) throws Exception {

        MemberVO member = getBizMember(session);
        if (member == null) {
            return "redirect:/login";
        }

        HospitalVO hospital = bizHospitalService.resolveHospitalByBizId(member.getMemberId());
        if (hospital == null || hospital.getHospitalId() == null) {
            rttr.addFlashAttribute("errorMsg", "병원 정보를 불러올 수 없습니다.");
            return "redirect:/biz/hospital/profile";
        }
        vo.setHospitalId(hospital.getHospitalId());

        // 2026-07-10 장우철 — 미전달 필드만 기존값 유지 (주소 있으면 Service에서 지오코딩)
        if (vo.getName() == null || vo.getName().isBlank()) {
            vo.setName(hospital.getName());
        }
        if (vo.getPhone() == null || vo.getPhone().isBlank()) {
            vo.setPhone(hospital.getPhone());
        }
        if (vo.getAddr() == null || vo.getAddr().isBlank()) {
            vo.setAddr(hospital.getAddr());
            if (vo.getLat() == null) {
                vo.setLat(hospital.getLat());
            }
            if (vo.getLng() == null) {
                vo.setLng(hospital.getLng());
            }
        }
        if (vo.getAddrDetail() == null) {
            vo.setAddrDetail(hospital.getAddrDetail());
        }

        // 체크 없으면 빈 문자열로 저장 (미선택 = 태그 없음)
        vo.setTagList(tagList != null ? String.join(",", tagList) : "");

        if (deleteFileIds != null) {
            for (Long fileId : deleteFileIds) {
                fileService.deleteFile(fileId);
            }
        }

        if (imgList != null) {
            for (MultipartFile img : imgList) {
                if (img == null || img.isEmpty()) {
                    continue;
                }
                fileService.uploadFile(img, "HOSPITAL", hospital.getHospitalId());
            }
        }

        bizHospitalService.updateHospitalInfo(vo);

        rttr.addFlashAttribute("msg", "저장되었습니다.");
        return "redirect:/biz/hospital/profile";
    }

    // ─────────────────────────────────────────────
    // HYJ 쿠폰 — 2026/08/01 장우철
    // 사이드바 /biz/hospital/coupon 진입용 (로직은 BizStayService 공용)
    // ─────────────────────────────────────────────
    @GetMapping({"/coupon", "/coupon/"})
    public String couponList(HttpSession session, Model model) {
        MemberVO member = getBizMember(session);
        if (member == null) return "redirect:/login";

        Long bizNo = bizStayService.getBizNo(member.getMemberId());
        if (bizNo == null) {
            model.addAttribute("errorMsg", "사업자 정보를 찾을 수 없습니다.");
            model.addAttribute("couponList", java.util.Collections.emptyList());
            model.addAttribute("bizPage", "coupon");
            return "biz/hospital/coupon";
        }
        model.addAttribute("couponList", bizStayService.getCouponList(bizNo));
        model.addAttribute("bizPage", "coupon");
        return "biz/hospital/coupon";
    }

    @PostMapping("/coupon/apply")
    public String applyCoupon(com.petcare.petcare.biz.vo.BizCouponVO vo,
                              HttpSession session,
                              RedirectAttributes rttr) {
        MemberVO member = getBizMember(session);
        if (member == null) return "redirect:/login";
        try {
            Long bizNo = bizStayService.getBizNo(member.getMemberId());
            if (bizNo == null) {
                rttr.addFlashAttribute("errorMsg", "사업자 정보를 찾을 수 없습니다.");
                return "redirect:/biz/hospital/coupon";
            }
            bizStayService.applyCoupon(bizNo, vo);
            rttr.addFlashAttribute("msg", "쿠폰 승인 신청이 완료되었습니다.");
        } catch (Exception e) {
            rttr.addFlashAttribute("errorMsg", "쿠폰 신청 중 오류가 발생했습니다.");
        }
        return "redirect:/biz/hospital/coupon";
    }

    @PostMapping("/coupon/update")
    public String updateCoupon(com.petcare.petcare.biz.vo.BizCouponVO vo,
                               HttpSession session,
                               RedirectAttributes rttr) {
        MemberVO member = getBizMember(session);
        if (member == null) return "redirect:/login";
        try {
            Long bizNo = bizStayService.getBizNo(member.getMemberId());
            if (bizNo == null) {
                rttr.addFlashAttribute("errorMsg", "사업자 정보를 찾을 수 없습니다.");
                return "redirect:/biz/hospital/coupon";
            }
            bizStayService.updateCoupon(bizNo, vo);
            rttr.addFlashAttribute("msg", "쿠폰 정보가 수정되었습니다.");
        } catch (IllegalStateException e) {
            if ("NOT_PENDING".equals(e.getMessage())) {
                rttr.addFlashAttribute("errorMsg", "승인 대기 상태의 쿠폰만 수정할 수 있습니다.");
            } else {
                rttr.addFlashAttribute("errorMsg", "수정 권한이 없습니다.");
            }
        } catch (Exception e) {
            rttr.addFlashAttribute("errorMsg", "수정 중 오류가 발생했습니다.");
        }
        return "redirect:/biz/hospital/coupon";
    }

    @PostMapping("/coupon/delete")
    public String deleteCoupon(@RequestParam Long couponId,
                               HttpSession session,
                               RedirectAttributes rttr) {
        MemberVO member = getBizMember(session);
        if (member == null) return "redirect:/login";
        try {
            Long bizNo = bizStayService.getBizNo(member.getMemberId());
            if (bizNo == null) {
                rttr.addFlashAttribute("errorMsg", "사업자 정보를 찾을 수 없습니다.");
                return "redirect:/biz/hospital/coupon";
            }
            bizStayService.deleteCoupon(bizNo, couponId);
            rttr.addFlashAttribute("msg", "쿠폰 신청이 삭제되었습니다.");
        } catch (IllegalStateException e) {
            if ("NOT_PENDING".equals(e.getMessage())) {
                rttr.addFlashAttribute("errorMsg", "승인 대기 상태의 쿠폰만 삭제할 수 있습니다.");
            } else {
                rttr.addFlashAttribute("errorMsg", "삭제 권한이 없습니다.");
            }
        } catch (Exception e) {
            rttr.addFlashAttribute("errorMsg", "삭제 중 오류가 발생했습니다.");
        }
        return "redirect:/biz/hospital/coupon";
    }

    /**
     * 지윤 26.08.07
     * 병원 쿠폰 조기 마감 (로직은 BizStayService 공용, store closeCoupon과 동일 패턴)
     */
    @PostMapping("/coupon/close")
    public String closeCoupon(@RequestParam Long couponId,
                              HttpSession session,
                              RedirectAttributes rttr) {
        MemberVO member = getBizMember(session);
        if (member == null) return "redirect:/login";
        try {
            Long bizNo = bizStayService.getBizNo(member.getMemberId());
            if (bizNo == null) {
                rttr.addFlashAttribute("errorMsg", "사업자 정보를 찾을 수 없습니다.");
                return "redirect:/biz/hospital/coupon";
            }
            bizStayService.closeCoupon(bizNo, couponId);
            rttr.addFlashAttribute("msg", "쿠폰이 조기 마감되었습니다.");
        } catch (IllegalStateException e) {
            if ("NOT_OWNER".equals(e.getMessage())) {
                rttr.addFlashAttribute("errorMsg", "본인이 등록한 쿠폰만 마감할 수 있습니다.");
            } else if ("NOT_APPROVED".equals(e.getMessage())) {
                rttr.addFlashAttribute("errorMsg", "승인된 쿠폰만 조기 마감할 수 있습니다.");
            } else if ("NOT_ACTIVE".equals(e.getMessage())) {
                rttr.addFlashAttribute("errorMsg", "현재 게시 중인 쿠폰만 조기 마감할 수 있습니다.");
            } else {
                rttr.addFlashAttribute("errorMsg", "쿠폰 조기 마감에 실패했습니다.");
            }
        } catch (Exception e) {
            rttr.addFlashAttribute("errorMsg", "쿠폰 조기 마감 중 오류가 발생했습니다.");
        }
        return "redirect:/biz/hospital/coupon";
    }

    // ─────────────────────────────────────────────

    // ─────────────────────────────────────────────
    // 2026/08/03 장우철 — 병원 배너 (yeju JSP·사이드바 추가, stay 공용 BizStayService)
    // ─────────────────────────────────────────────
    @GetMapping({"/banner", "/banner/"})
    public String bannerList(HttpSession session, Model model) {
        MemberVO member = getBizMember(session);
        if (member == null) return "redirect:/login";

        Long bizNo = bizStayService.getBizNo(member.getMemberId());
        if (bizNo == null) {
            model.addAttribute("errorMsg", "사업자 정보를 찾을 수 없습니다.");
            model.addAttribute("bannerList", java.util.Collections.emptyList());
            model.addAttribute("bizPage", "banner");
            return "biz/hospital/banner";
        }
        model.addAttribute("bannerList", bizStayService.getBannerList(bizNo));
        model.addAttribute("bizPage", "banner");
        return "biz/hospital/banner";
    }

    @GetMapping("/banner/form")
    public String bannerForm(HttpSession session, Model model) {
        if (getBizMember(session) == null) return "redirect:/login";
        model.addAttribute("bizPage", "banner");
        return "biz/hospital/banner-form";
    }

    @PostMapping("/banner")
    public String bannerSubmit(@RequestParam String title,
                               @RequestParam(required = false) String linkUrl,
                               @RequestParam String positionCd,
                               @RequestParam String startDate,
                               @RequestParam String endDate,
                               @RequestParam(required = false) MultipartFile bannerImage,
                               HttpSession session,
                               RedirectAttributes rttr) {
        MemberVO member = getBizMember(session);
        if (member == null) return "redirect:/login";
        try {
            Long bizNo = bizStayService.getBizNo(member.getMemberId());
            if (bizNo == null) {
                rttr.addFlashAttribute("errorMsg", "사업자 정보를 찾을 수 없습니다.");
                return "redirect:/biz/hospital/banner";
            }
            com.petcare.petcare.main.banner.vo.MainBannerVO banner =
                    new com.petcare.petcare.main.banner.vo.MainBannerVO();
            banner.setBizNo(bizNo);
            banner.setTitle(title);
            banner.setLinkUrl(linkUrl);
            banner.setPositionCd(positionCd);
            banner.setStartDate(startDate);
            banner.setEndDate(endDate);
            banner.setStatusCd("PENDING");
            bizStayService.applyBanner(banner, bannerImage);
            rttr.addFlashAttribute("msg", "배너 신청이 완료되었습니다. 관리자 승인 후 노출됩니다.");
        } catch (IllegalArgumentException e) {
            rttr.addFlashAttribute("errorMsg", e.getMessage());
        } catch (Exception e) {
            rttr.addFlashAttribute("errorMsg", "배너 신청 중 오류가 발생했습니다.");
        }
        return "redirect:/biz/hospital/banner";
    }

    /**
 * 재능나눔 참여 신청 확인
 * POST /biz/hospital/talent/confirm
 * 2026-08-10 박유정 — STEP 6
 */
@PostMapping("/talent/confirm")
public String hospitalTalentConfirm(@RequestParam long applyId,
                                    HttpSession session,
                                    RedirectAttributes rttr) {
    MemberVO member = getBizMember(session);
    if (member == null) {
        return "redirect:/login";
    }
    try {
        giveTalentService.confirmApply(applyId, member.getMemberId());
        rttr.addFlashAttribute("msg", "신청을 확인했습니다.");
    } catch (IllegalStateException e) {
        rttr.addFlashAttribute("errorMsg", "확인할 수 없습니다.");
    }
    return "redirect:/biz/hospital/talent";
}

/**
 * 재능나눔 모집 수동 마감
 * POST /biz/hospital/talent/close
 * 2026-08-10 박유정 — STEP 7-B
 */
@PostMapping("/talent/close")
public String hospitalTalentClose(@RequestParam long talentId,
                                  HttpSession session,
                                  RedirectAttributes rttr) {
    MemberVO member = getBizMember(session);
    if (member == null) {
        return "redirect:/login";
    }
    try {
        giveTalentService.closeRecruitment(talentId, member.getMemberId());
        rttr.addFlashAttribute("msg", "모집을 마감했습니다.");
    } catch (IllegalStateException e) {
        rttr.addFlashAttribute("errorMsg", "마감할 수 없습니다. (본인 글이 아니거나 이미 마감됨)");
    }
    return "redirect:/biz/hospital/talent";
}

// 2026-08-13 박유정 — 빈 숫자칸("") → null (Integer 바인딩 오류 방지)
@InitBinder
public void initBinder(WebDataBinder binder) {
    binder.registerCustomEditor(Integer.class, new CustomNumberEditor(Integer.class, true));
}
}
