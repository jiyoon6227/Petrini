/**
 * 역할: 동물병원 URL 처리 → Service 호출 → JSP 반환
 *
 * 연결
 * - Service: HospitalService
 *
 * SQL·비즈니스 로직은 넣지 말 것 → Service로 위임
 * return 경로는 담당 JSP와 동일하게 맞출 것
 */

package com.petcare.petcare.hospital.controller;

import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.time.LocalDate;
import java.time.ZoneId;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.petcare.petcare.common.config.controller.CommonConfigController;
import com.petcare.petcare.common.external.service.KakaoMapService;
import com.petcare.petcare.file.service.FileService;
import com.petcare.petcare.file.vo.FileVO;
import com.petcare.petcare.hospital.service.HospitalService;
import com.petcare.petcare.hospital.vo.HospitalVO;
import com.petcare.petcare.hospital.vo.HospitalDoctorVO;
import com.petcare.petcare.hospital.vo.HospitalTreatTypeVO;
import com.petcare.petcare.hospital.vo.ReservationVO;
import com.petcare.petcare.member.vo.MemberVO;

import jakarta.servlet.http.HttpSession;

@Controller("hospitalController")
@RequestMapping("/hospital")
public class HospitalController extends CommonConfigController {

    @Autowired
    private KakaoMapService kakaoMapService;
    @Autowired
    private HospitalService hospitalService;
    @Autowired
    private FileService fileService;

    @GetMapping({"", "/"})
    public String hospital(@ModelAttribute("search") HospitalVO searchVO, Model model) throws Exception {
        List<HospitalVO> hospitalList = hospitalService.getHospitalListBySearch(searchVO);
        kakaoMapService.addMapAttributes(model, hospitalList);
        
        model.addAttribute("hospitalList", hospitalList);
        model.addAttribute("skipAutoMarkers", "true");
        return "hospital/list";
    }

    // ── 병원 상세 ─────────────────────────────────────
    @GetMapping("/detail")
    public String detail(@RequestParam String id, Model model) throws Exception {
        Long hospitalId = Long.parseLong(id);
        HospitalVO hospital = hospitalService.getHospitalById(Long.parseLong(id));
        List<FileVO> imgList = fileService.getFileList("HOSPITAL", hospitalId);

        if (hospital != null && hospital.getLat() != null) {
            List<HospitalVO> singleList = new ArrayList<>();
            singleList.add(hospital); 
            kakaoMapService.addMapAttributes(model, singleList);
            // → markersJson에 1개만 들어감 → kakaomap.jsp가 상세모드로 자동 동작
        }

        model.addAttribute("hospital", hospital);
        model.addAttribute("imgList", imgList);
        // 2026/07/13 장우철 — 더미 리뷰 대신 DB 리뷰 목록
        model.addAttribute("reviewList", hospitalService.getHospitalReviews(hospitalId));

        // 2026/08/11 장우철 — 병원 상세 예약카드: 대표의사(정렬1) 기준 오늘 남은 슬롯 표시
        int todayAvailableSlots = 0;
        try {
            List<HospitalDoctorVO> doctors = hospitalService.getActiveDoctorsForReserve(hospitalId);
            List<HospitalTreatTypeVO> treatTypes = hospitalService.getActiveTreatTypesForReserve(hospitalId);
            if (doctors != null && !doctors.isEmpty()
                    && treatTypes != null && !treatTypes.isEmpty()) {
                Long repDoctorId = doctors.get(0).getDoctorId();
                Long repTreatTypeId = treatTypes.get(0).getTreatTypeId();
                LocalDate today = LocalDate.now(ZoneId.of("Asia/Seoul"));
                Date todayDate = java.sql.Date.valueOf(today);
                List<String> times = hospitalService.getAvailableReserveTimes(
                        hospitalId, repDoctorId, repTreatTypeId, todayDate);
                todayAvailableSlots = times != null ? times.size() : 0;
            }
        } catch (Exception ignored) {
            todayAvailableSlots = 0;
        }
        model.addAttribute("todayAvailableSlots", todayAvailableSlots);

        return "hospital/detail";
    }

    // 2026-07-10 장우철 — 병원 예약 폼 (F1~F2) hospitalId 필수 + 펫 목록
    @GetMapping("/reserve")
    public String reserve(@RequestParam("id") String id,
                          HttpSession session,
                          Model model) throws Exception {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null) {
            return "redirect:/login";
        }

        Long hospitalId = Long.parseLong(id);
        HospitalVO hospital = hospitalService.getHospitalById(hospitalId);
        if (hospital == null) {
            return "redirect:/hospital";
        }

        model.addAttribute("hospitalId", hospitalId);
        model.addAttribute("hospital", hospital);
        model.addAttribute("petList", hospitalService.getPetListForReserve(member.getMemberNo()));
        // 2026/07/16 장우철 — 예약 UI: 활성 의사·진료유형
        model.addAttribute("doctorList", hospitalService.getActiveDoctorsForReserve(hospitalId));
        model.addAttribute("treatTypeList", hospitalService.getActiveTreatTypesForReserve(hospitalId));
        return "hospital/reserve";

        /* [변경 전] 2026-07-10 장우철 — id 하드코딩·목업만
        model.addAttribute("id", id);
        */
    }

    // 2026/07/20 장우철 — 예약 날짜 정기 휴무 확인 (Ajax)
    @GetMapping("/reserve/day-check")
    @ResponseBody
    public Map<String, Object> reserveDayCheck(@RequestParam("hospitalId") Long hospitalId,
                                               @RequestParam("resvDate")
                                               @DateTimeFormat(pattern = "yyyy-MM-dd") Date resvDate,
                                               HttpSession session) {
        if (session.getAttribute("memberInfo") == null) {
            return apiFail("로그인이 필요합니다.");
        }
        try {
            return apiOk(hospitalService.checkReserveDate(hospitalId, resvDate));
        } catch (IllegalArgumentException e) {
            return apiFail(e.getMessage());
        } catch (Exception e) {
            return apiFail("예약 가능 여부를 확인하지 못했습니다.");
        }
    }

    // 2026/07/16 장우철 — 예약 가능 시간 (Ajax)
    @GetMapping("/reserve/times")
    @ResponseBody
    public Map<String, Object> reserveTimes(@RequestParam("hospitalId") Long hospitalId,
                                            @RequestParam("doctorId") Long doctorId,
                                            @RequestParam("treatTypeId") Long treatTypeId,
                                            @RequestParam("resvDate") @DateTimeFormat(pattern = "yyyy-MM-dd") Date resvDate,
                                            HttpSession session) {
        if (session.getAttribute("memberInfo") == null) {
            return apiFail("로그인이 필요합니다.");
        }
        try {
            return apiOk(hospitalService.getAvailableReserveTimes(
                    hospitalId, doctorId, treatTypeId, resvDate));
        } catch (IllegalArgumentException | IllegalStateException e) {
            return apiFail(e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            String msg = e.getMessage() != null ? e.getMessage() : e.getClass().getSimpleName();
            return apiFail("예약 가능 시간을 불러오지 못했습니다: " + msg);
        }
    }

    // 2026/07/16 장우철 — 펫 단계 이동 시 시간 선점 (Ajax)
    @PostMapping("/reserve/hold")
    @ResponseBody
    public Map<String, Object> reserveHold(@RequestParam("hospitalId") Long hospitalId,
                                           @RequestParam("doctorId") Long doctorId,
                                           @RequestParam("treatTypeId") Long treatTypeId,
                                           @RequestParam("resvDate") @DateTimeFormat(pattern = "yyyy-MM-dd") Date resvDate,
                                           @RequestParam("resvTime") String resvTime,
                                           HttpSession session) {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null) {
            return apiFail("로그인이 필요합니다.");
        }
        try {
            Long holdId = hospitalService.createReserveHold(
                    hospitalId, member.getMemberNo(), doctorId, treatTypeId, resvDate, resvTime);
            Map<String, Object> data = new LinkedHashMap<>();
            data.put("holdId", holdId);
            return apiOk(data);
        } catch (IllegalArgumentException | IllegalStateException e) {
            return apiFail(e.getMessage());
        } catch (Exception e) {
            return apiFail("예약 시간 선점에 실패했습니다.");
        }
    }

    // 2026/07/20 장우철 — 2단계 이전 클릭 시 hold 해제 (Ajax)
    @PostMapping("/reserve/hold/release")
    @ResponseBody
    public Map<String, Object> releaseReserveHold(@RequestParam("hospitalId") Long hospitalId,
                                                  HttpSession session) {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null) {
            return apiFail("로그인이 필요합니다.");
        }
        try {
            hospitalService.releaseMemberReserveHolds(hospitalId, member.getMemberNo());
            return apiOk(null);
        } catch (Exception e) {
            return apiFail("예약 선점 해제에 실패했습니다.");
        }
    }

    // 2026-07-10 장우철 — 병원 예약 저장 (F2)
    // 2026-07-11 장우철 — resvDate 는 VO @DateTimeFormat 으로 바인딩 (별도 String 파싱 제거)
    @PostMapping("/reserve")
    public String saveReserve(@ModelAttribute ReservationVO vo,
                              @RequestParam("hospitalId") Long hospitalId,
                              HttpSession session,
                              RedirectAttributes rttr) throws Exception {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null) {
            return "redirect:/login";
        }

        vo.setMemberNo(member.getMemberNo());
        vo.setTargetId(String.valueOf(hospitalId));

        if (vo.getHoldId() == null) {
            rttr.addFlashAttribute("errorMsg", "예약 일정이 만료되었습니다. 처음부터 다시 선택해 주세요.");
            return "redirect:/hospital/reserve?id=" + hospitalId;
        }
        if (vo.getPetId() == null) {
            rttr.addFlashAttribute("errorMsg", "반려동물을 선택해 주세요.");
            return "redirect:/hospital/reserve?id=" + hospitalId;
        }

        try {
            Long resvId = hospitalService.createHospitalReservation(vo);
            if (resvId == null) {
                rttr.addFlashAttribute("errorMsg", "예약 저장에 실패했습니다. 잠시 후 다시 시도해 주세요.");
                return "redirect:/hospital/reserve?id=" + hospitalId;
            }
            return "redirect:/hospital/complete?resvId=" + resvId;
        } catch (IllegalArgumentException | IllegalStateException e) {
            rttr.addFlashAttribute("errorMsg", e.getMessage());
            return "redirect:/hospital/reserve?id=" + hospitalId;
        }
    }

    private Map<String, Object> apiOk(Object data) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("ok", true);
        m.put("data", data);
        return m;
    }

    private Map<String, Object> apiFail(String msg) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("ok", false);
        m.put("msg", msg);
        return m;
    }

    // 2026-07-10 장우철 — 예약 완료 (F3)
    @GetMapping("/complete")
    public String complete(@RequestParam("resvId") Long resvId, Model model) throws Exception {
        ReservationVO reservation = hospitalService.getReservationById(resvId);
        model.addAttribute("reservation", reservation);
        return "hospital/complete";
    }
}
