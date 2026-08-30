/**
 * 역할: 마이페이지 예약 URL 처리 → Service 호출 → JSP 반환
 *
 * 2026/07/11 장우철 — 예약 내역·상세 DB 연동 (2차)
 */

package com.petcare.petcare.mypage.reserve.controller;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.petcare.petcare.member.vo.MemberVO;
import com.petcare.petcare.mypage.reserve.service.MypageReserveService;
import com.petcare.petcare.mypage.reserve.vo.MypageReserveVO;
import com.petcare.petcare.mypage.reserve.vo.StayReviewRegisterResult;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/mypage")
public class MypageReserveController {

    private static final Logger log = LoggerFactory.getLogger(MypageReserveController.class);

    @Autowired
    private MypageReserveService mypageReserveService;

    // 2026/07/21 장우철 — type(전체/병원/숙소) + status(상태) 2단 필터
    @GetMapping("/reserve")
    public String reserve(@RequestParam(value = "status", required = false, defaultValue = "all") String status,
                          @RequestParam(value = "type", required = false, defaultValue = "all") String type,
                          HttpSession session,
                          Model model) {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null || member.getMemberNo() == null) {
            return "redirect:/login?redirect=/mypage/reserve";
        }
        List<MypageReserveVO> reservationList =
                mypageReserveService.getMyReservationList(member.getMemberNo(), status, type);
        model.addAttribute("statusFilter", status);
        model.addAttribute("typeFilter", type);
        model.addAttribute("reservationList", reservationList);
        return "mypage/reserve";
    }

    // 2026/07/11 장우철 — 예약 상세 (/mypage/reserve/detail?resvId=)
    // 2026-08-10 박유정 — resvType=TALENT 재능나눔 신청 상세 분기
    @GetMapping("/reserve/detail")
    public String reserveDetail(@RequestParam("resvId") Long resvId,
                                @RequestParam(value = "resvType", required = false) String resvType,
                                HttpSession session,
                                Model model) {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null || member.getMemberNo() == null) {
            String redirect = "/mypage/reserve/detail?resvId=" + resvId;
            if (resvType != null && !resvType.isBlank()) {
                redirect += "&resvType=" + resvType;
            }
            return "redirect:/login?redirect=" + redirect;
        }

        MypageReserveVO detail =
                mypageReserveService.getMyReservationDetail(member.getMemberNo(), resvId, resvType);
        if (detail == null) {
            return "redirect:/mypage/reserve?error=notfound";
        }
        model.addAttribute("reservation", detail);
        return "mypage/reserve-detail";
    }

    // 2026-08-10 박유정 — 재능나눔 참여 신청 취소
    @PostMapping("/reserve/talent-cancel")
    public String cancelTalentApply(@RequestParam("resvId") Long resvId,
                                    HttpSession session,
                                    RedirectAttributes rttr) {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null || member.getMemberNo() == null) {
            return "redirect:/login?redirect=/mypage/reserve/detail?resvId=" + resvId + "&resvType=TALENT";
        }
        try {
            mypageReserveService.cancelTalentApply(member.getMemberNo(), resvId);
            rttr.addFlashAttribute("msg", "재능나눔 신청이 취소되었습니다.");
        } catch (IllegalArgumentException | IllegalStateException e) {
            rttr.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/mypage/reserve/detail?resvId=" + resvId + "&resvType=TALENT";
    }

    // 2026/07/13 장우철 — 진료완료 예약 병원 리뷰·별점 등록
    @PostMapping("/reserve/review")
    public String addHospitalReview(@RequestParam("resvId") Long resvId,
                                    @RequestParam("rating") Double rating,
                                    @RequestParam("content") String content,
                                    HttpSession session,
                                    RedirectAttributes rttr) {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null || member.getMemberNo() == null) {
            return "redirect:/login?redirect=/mypage/reserve/detail?resvId=" + resvId;
        }

        try {
            mypageReserveService.addHospitalReview(member.getMemberNo(), resvId, rating, content);
            rttr.addFlashAttribute("msg", "리뷰가 등록되었습니다.");
        } catch (IllegalArgumentException | IllegalStateException e) {
            rttr.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/mypage/reserve/detail?resvId=" + resvId;
    }

    // HYJ 26.07.20 — 숙박완료 예약 숙소 리뷰·별점 등록
    @PostMapping("/reserve/stay-review")
    public String addStayReview(@RequestParam("resvId") Long resvId,
                                @RequestParam("rating") Double rating,
                                @RequestParam("content") String content,
                                HttpSession session,
                                RedirectAttributes rttr) {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null || member.getMemberNo() == null) {
            return "redirect:/login?redirect=/mypage/reserve/detail?resvId=" + resvId;
        }

        log.info("POST /mypage/reserve/stay-review resvId={}", resvId);

        try {
            StayReviewRegisterResult result = mypageReserveService.addStayReview(
                    member.getMemberNo(), resvId, rating, content, member.getPointBalance());

            // 2026-07-28 박유정 — 리뷰 포인트 적립 후 세션 잔액 갱신
            if (result.isPointEarned()) {
                long currentBalance = (member.getPointBalance() != null) ? member.getPointBalance() : 0;
                member.setPointBalance(currentBalance + result.getEarnedPoint());
                session.setAttribute("memberInfo", member);
            }

            String msg = "리뷰가 등록되었습니다.";
            // 2026-07-28 박유정 — 포인트 적립 시 안내 메시지
            if (result.isPointEarned()) {
                msg += " " + String.format("%,d", result.getEarnedPoint()) + "P가 적립되었습니다!";
            }
            rttr.addFlashAttribute("msg", msg);
        }
        catch (IllegalArgumentException | IllegalStateException e) {
            rttr.addFlashAttribute("errorMsg", e.getMessage());
        } catch (Exception e) {
            log.error("숙소 리뷰 등록 실패 resvId={}", resvId, e);
            String err = e.getMessage();
            if (err == null && e.getCause() != null) {
                err = e.getCause().getMessage();
            }
            rttr.addFlashAttribute("errorMsg",
                    "리뷰 등록 중 오류가 발생했습니다." + (err != null ? " (" + err + ")" : ""));
        }
        return "redirect:/mypage/reserve/detail?resvId=" + resvId;
    }

    // 2026/07/31 장우철 — 유저 숙소 예약 취소 (1-4·1-6)
    @PostMapping("/reserve/stay-cancel")
    public String cancelStayReservation(@RequestParam("resvId") Long resvId,
                                        @RequestParam("cancelReason") String cancelReason,
                                        HttpSession session,
                                        RedirectAttributes rttr) {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null || member.getMemberNo() == null) {
            return "redirect:/login?redirect=/mypage/reserve/detail?resvId=" + resvId;
        }
        try {
            mypageReserveService.cancelStayReservation(member.getMemberNo(), resvId, cancelReason);
            rttr.addFlashAttribute("msg", "예약이 취소되었습니다. 환불은 결제수단 정책에 따라 처리됩니다.");
        } catch (IllegalArgumentException | IllegalStateException e) {
            rttr.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/mypage/reserve/detail?resvId=" + resvId;
    }
}
