/**
 * 역할: 1:1 문의 URL 처리
 * 2026/07/31 장우철 — memberNo 기준 DB 연동 + 숙소 환불 작성 프리필
 */
package com.petcare.petcare.member.inquiry.controller;

import java.util.Optional;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.petcare.petcare.member.inquiry.service.MemberInquiryService;
import com.petcare.petcare.member.vo.InquiryVO;
import com.petcare.petcare.member.vo.MemberVO;
import com.petcare.petcare.mypage.reserve.service.MypageReserveService;
import com.petcare.petcare.mypage.reserve.vo.MypageReserveVO;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/member/cs")
public class MemberInquiryController {

    private final MemberInquiryService inquiryService;
    private final MypageReserveService mypageReserveService;

    public MemberInquiryController(MemberInquiryService inquiryService,
                                   MypageReserveService mypageReserveService) {
        this.inquiryService = inquiryService;
        this.mypageReserveService = mypageReserveService;
    }

    @GetMapping("/inquiry")
    public String inquiryList(HttpSession session, Model model) {
        MemberVO member = getMemberOrRedirect(session);
        if (member == null) {
            return "redirect:/login?redirect=/member/cs/inquiry";
        }
        model.addAttribute("inquiries", inquiryService.getListForSessionMember(member));
        return "member/cs-inquiry-list";
    }
    @GetMapping("/inquiry/write")
    public String inquiryWriteForm(HttpSession session,
                                   @RequestParam(value = "resvId", required = false) Long resvId,
                                   @RequestParam(value = "type", required = false) String type,
                                   Model model,
                                   RedirectAttributes rttr) {
        MemberVO member = getMemberOrRedirect(session);
        if (member == null) {
            String redirect = "/member/cs/inquiry/write";
            if (resvId != null) {
                redirect += "?resvId=" + resvId + "&type=stay_refund";
            }
            return "redirect:/login?redirect=" + redirect;
        }
        // 2026/08/06 장우철 — 진행중/거절 시 작성 폼 진입 차단
        // 2026-08-10 박유정 — getMyReservationDetail 3번째 인자(resvType) 추가 대응 (null=병원·숙소)
        if (resvId != null && "stay_refund".equalsIgnoreCase(type)) {
            MypageReserveVO detail = mypageReserveService.getMyReservationDetail(
                    member.getMemberNo(), resvId, null);
            if (detail == null || !"STAY".equalsIgnoreCase(detail.getResvType())) {
                rttr.addFlashAttribute("errorMsg", "숙소 예약을 찾을 수 없습니다.");
                return "redirect:/mypage/reserve";
            }
            if (!"CHECKIN".equalsIgnoreCase(detail.getStatusCd())) {
                rttr.addFlashAttribute("errorMsg", "체크인 상태에서만 환불 신청할 수 있습니다.");
                return "redirect:/mypage/reserve/detail?resvId=" + resvId;
            }
            if ("PENDING".equalsIgnoreCase(detail.getStayRefundStatus())) {
                rttr.addFlashAttribute("errorMsg", "이미 처리 중인 환불 신청이 있습니다.");
                return "redirect:/mypage/reserve/detail?resvId=" + resvId;
            }
            if ("APPROVED".equalsIgnoreCase(detail.getStayRefundStatus())) {
                rttr.addFlashAttribute("errorMsg", "이미 환불이 승인된 예약입니다. 재신청할 수 없습니다.");
                return "redirect:/mypage/reserve/detail?resvId=" + resvId;
            }
            if ("REJECTED".equalsIgnoreCase(detail.getStayRefundStatus())) {
                rttr.addFlashAttribute("errorMsg", "환불이 거절된 예약입니다. 재신청할 수 없습니다.");
                return "redirect:/mypage/reserve/detail?resvId=" + resvId;
            }
            model.addAttribute("stayRefund", true);
            model.addAttribute("resvId", resvId);
            model.addAttribute("reservation", detail);
        }
        return "member/cs-inquiry-write";
    }

    @PostMapping("/inquiry/write")
    public String inquiryWrite(
            @RequestParam String category,
            @RequestParam String title,
            @RequestParam String content,
            @RequestParam(value = "resvId", required = false) Long resvId,
            @RequestParam(value = "type", required = false) String type,
            HttpSession session,
            RedirectAttributes rttr) {

        MemberVO member = getMemberOrRedirect(session);
        if (member == null) {
            return "redirect:/login?redirect=/member/cs/inquiry/write";
        }

        if (category == null || category.isBlank()
                || title == null || title.isBlank()
                || content == null || content.isBlank()) {
            rttr.addFlashAttribute("errorMsg", "문의 유형, 제목, 내용을 모두 입력해 주세요.");
            return "redirect:/member/cs/inquiry/write";
        }

        InquiryVO inquiry;
        try {
            if (resvId != null && "stay_refund".equalsIgnoreCase(type)) {
                inquiry = inquiryService.createStayRefundInquiry(member, resvId, content);
            } else {
                inquiry = inquiryService.create(member, category, title, content);
            }
        } catch (IllegalArgumentException | IllegalStateException e) {
            rttr.addFlashAttribute("errorMsg", e.getMessage());
            if (resvId != null && "stay_refund".equalsIgnoreCase(type)) {
                return "redirect:/mypage/reserve/detail?resvId=" + resvId;
            }
            return "redirect:/member/cs/inquiry/write";
        }
        if (inquiry == null || inquiry.getId() <= 0) {
            rttr.addFlashAttribute("errorMsg", "문의 등록에 실패했습니다. 다시 로그인 후 시도해 주세요.");
            return "redirect:/member/cs/inquiry/write";
        }
        if (resvId != null && "stay_refund".equalsIgnoreCase(type)) {
            rttr.addFlashAttribute("msg", "환불 신청이 접수되었습니다. 관리자 검토 후 처리됩니다.");
            return "redirect:/mypage/reserve/detail?resvId=" + resvId;
        }
        rttr.addFlashAttribute("successMsg", "문의가 등록되었습니다.");
        return "redirect:/member/cs/inquiry/detail?id=" + inquiry.getId();
    }

    @GetMapping("/inquiry/detail")
    public String inquiryDetail(
            @RequestParam long id,
            HttpSession session,
            Model model) {

        MemberVO member = getMemberOrRedirect(session);
        if (member == null) {
            return "redirect:/login?redirect=/member/cs/inquiry/detail?id=" + id;
        }

        Optional<InquiryVO> inquiry = inquiryService.findForSessionMember(member, id);
        if (inquiry.isEmpty()) {
            return "redirect:/member/cs/inquiry";
        }

        model.addAttribute("inquiry", inquiry.get());
        return "member/cs-inquiry-detail";
    }

    private MemberVO getMemberOrRedirect(HttpSession session) {
        Object member = session.getAttribute("memberInfo");
        if (member instanceof MemberVO memberVO) {
            return memberVO;
        }
        return null;
    }
}
