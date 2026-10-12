package com.petcare.petcare.admin.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

import com.petcare.petcare.admin.biz.service.AdminBizService;
import com.petcare.petcare.admin.cms.service.AdminCMSService;
import com.petcare.petcare.admin.inquiry.service.AdminInquiryService;
import com.petcare.petcare.admin.review.service.AdminReviewService;
import com.petcare.petcare.admin.settlement.service.AdminSettlementService;
import com.petcare.petcare.give.talent.service.GiveTalentService;
import com.petcare.petcare.member.vo.MemberVO;

import jakarta.servlet.http.HttpSession;

@ControllerAdvice(basePackages = "com.petcare.petcare.admin")
public class AdminSidebarAdvice {

    @Autowired
    private AdminBizService adminBizService;

    @Autowired
    private GiveTalentService giveTalentService;

    @Autowired
    private AdminSettlementService adminSettlementService;

    @Autowired
    private AdminReviewService adminReviewService;

    @Autowired
    private AdminCMSService adminCMSService;

    // 숙소 환불신청·1:1 문의 대기 건수 (AdminInquiryService)
    @Autowired
    private AdminInquiryService adminInquiryService;

    @ModelAttribute("pendingBizApproveCount")
    public int pendingBizApproveCount(HttpSession session) {
        MemberVO m = (MemberVO) session.getAttribute("memberInfo");
        if (m == null || !"ADMIN".equals(m.getRole())) {
            return 0;
        }
        try {
            Integer pending = adminBizService.getBizStatusCounts().get("PENDING");
            return pending != null ? pending : 0;
        } catch (Exception e) {
            return 0;
        }
    }

    @ModelAttribute("pendingTalentApproveCount")
    public int pendingTalentApproveCount(HttpSession session) {
        MemberVO m = (MemberVO) session.getAttribute("memberInfo");
        if (m == null || !"ADMIN".equals(m.getRole())) {
            return 0;
        }
        try {
            Integer pending = giveTalentService.getTalentStatusCounts().get("PENDING");
            return pending != null ? pending : 0;
        } catch (Exception e) {
            return 0;
        }
    }

    @ModelAttribute("pendingStaySettleRequestCount")
    public int pendingStaySettleRequestCount(HttpSession session) {
        MemberVO m = (MemberVO) session.getAttribute("memberInfo");
        if (m == null || !"ADMIN".equals(m.getRole())) {
            return 0;
        }
        try {
            return adminSettlementService.countStayMidRequestsRequested()
                    + adminSettlementService.countStoreMidRequestsRequested();
        } catch (Exception e) {
            return 0;
        }
    }

    @ModelAttribute("pendingReviewDeleteCount")
    public int pendingReviewDeleteCount(HttpSession session) {
        MemberVO m = (MemberVO) session.getAttribute("memberInfo");
        if (m == null || !"ADMIN".equals(m.getRole())) {
            return 0;
        }
        try {
            return adminReviewService.getPendingReviewDeleteCount();
        } catch (Exception e) {
            return 0;
        }
    }

    @ModelAttribute("pendingBannerCount")
    public int pendingBannerCount(HttpSession session) {
        MemberVO m = (MemberVO) session.getAttribute("memberInfo");
        if (m == null || !"ADMIN".equals(m.getRole())) {
            return 0;
        }
        try {
            return adminCMSService.getPendingBannerCount();
        } catch (Exception e) {
            return 0;
        }
    }

    @ModelAttribute("pendingCouponApproveCount")
    public int pendingCouponApproveCount(HttpSession session) {
        MemberVO m = (MemberVO) session.getAttribute("memberInfo");
        if (m == null || !"ADMIN".equals(m.getRole())) {
            return 0;
        }
        try {
            Integer pending = adminBizService.getCouponStatusCounts().get("PENDING");
            return pending != null ? pending : 0;
        } catch (Exception e) {
            return 0;
        }
    }

    // sidebar 숙소 환불신청 메뉴 배지 (WAIT 건수)
    @ModelAttribute("pendingStayRefundCount")
    public int pendingStayRefundCount(HttpSession session) {
        MemberVO m = (MemberVO) session.getAttribute("memberInfo");
        if (m == null || !"ADMIN".equals(m.getRole())) {
            return 0;
        }
        try {
            return adminInquiryService.countPendingStayRefund();
        } catch (Exception e) {
            return 0;
        }
    }

    // sidebar 1:1 문의 메뉴 배지 (WAIT 건수)
    @ModelAttribute("pendingGeneralInquiryCount")
    public int pendingGeneralInquiryCount(HttpSession session) {
        MemberVO m = (MemberVO) session.getAttribute("memberInfo");
        if (m == null || !"ADMIN".equals(m.getRole())) {
            return 0;
        }
        try {
            return adminInquiryService.countPendingGeneralInquiry();
        } catch (Exception e) {
            return 0;
        }
    }
}
