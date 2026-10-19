package com.petcare.petcare.admin.review.controller;

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

import com.petcare.petcare.admin.controller.AdminBaseController;
import com.petcare.petcare.admin.review.service.AdminReviewService;
import com.petcare.petcare.member.vo.MemberVO;

import jakarta.servlet.http.HttpSession;

@Controller("adminReviewController")
@RequestMapping("/admin/review")
public class AdminReviewController extends AdminBaseController {

    private static final Logger log = LoggerFactory.getLogger(AdminReviewController.class);

    private static final String TAB_REQUEST = "request";
    private static final String TAB_REPORT  = "report";

    @Autowired
    private AdminReviewService adminReviewService;

    // adminNo 없으면 memberNo로 처리자 식별
    private long resolveAdminNo(MemberVO admin) {
        if (admin.getAdminNo() != null) {
            return admin.getAdminNo();
        }
        if (admin.getMemberNo() != null) {
            return admin.getMemberNo();
        }
        return 0L;
    }

    // 리뷰 관리 목록 (tab=request 사업자 삭제요청 / tab=report 고객 신고)
    @GetMapping("/list")
    public String reviewDeleteRequestList(HttpSession session,
            @RequestParam(defaultValue = TAB_REQUEST) String tab,
            @RequestParam(defaultValue = "") String keyword,
            @RequestParam(required = false) String statusCd,
            @RequestParam(defaultValue = "1") int page,
            Model model) {

        if (getAdmin(session) == null)
            return redirectToLogin();

        // 파라미터 없음=첫 진입(PENDING), ALL/빈값=상태 전체
        if (statusCd == null) {
            statusCd = "PENDING";
        }

        boolean reportTab = TAB_REPORT.equals(tab);
        if (reportTab) {
            model.addAttribute("list",
                    adminReviewService.getReviewReportList(keyword, statusCd, page));
            model.addAttribute("totalCount",
                    adminReviewService.getReviewReportCount(keyword, statusCd));
        } else {
            model.addAttribute("list",
                    adminReviewService.getReviewDeleteRequestList(keyword, statusCd, page));
            model.addAttribute("totalCount",
                    adminReviewService.getReviewDeleteRequestCount(keyword, statusCd));
        }
        model.addAttribute("tab", reportTab ? TAB_REPORT : TAB_REQUEST);
        model.addAttribute("pendingRequestCount", adminReviewService.getPendingReviewDeleteCount());
        model.addAttribute("pendingReportCount", adminReviewService.getPendingReviewReportCount());
        model.addAttribute("keyword", keyword);
        model.addAttribute("statusCd", statusCd);
        model.addAttribute("page", page);

        return "admin/review/list";
    }

    // 삭제 요청 승인 (리뷰 삭제) — 병원·숙소·쇼핑 공통
    @PostMapping("/approve")
    public String approveReviewDeleteRequest(HttpSession session,
            @RequestParam long requestId,
            RedirectAttributes rttr) {
        MemberVO admin = getAdmin(session);
        if (admin == null)
            return redirectToLogin();

        try {
            adminReviewService.approveReviewDeleteRequest(requestId, resolveAdminNo(admin));
            rttr.addFlashAttribute("successMsg", "리뷰가 삭제(승인) 처리되었습니다.");
            return listRedirect(TAB_REQUEST, "APPROVED");
        } catch (IllegalArgumentException | IllegalStateException e) {
            log.warn("리뷰 삭제 승인 거부 requestId={}: {}", requestId, e.getMessage());
            rttr.addFlashAttribute("errorMsg", "처리할 수 없는 요청입니다.");
            return listRedirect(TAB_REQUEST, "PENDING");
        } catch (Exception e) {
            log.error("리뷰 삭제 승인 실패 requestId={}", requestId, e);
            rttr.addFlashAttribute("errorMsg", "승인 처리 중 오류가 발생했습니다." + errorDetail(e));
            return listRedirect(TAB_REQUEST, "PENDING");
        }
    }

    // 삭제 요청 반려 (반려 사유 필수 + 사업자 알림)
    @PostMapping("/reject")
    public String rejectReviewDeleteRequest(HttpSession session,
            @RequestParam long requestId,
            @RequestParam String rejectReason,
            RedirectAttributes rttr) {
        MemberVO admin = getAdmin(session);
        if (admin == null)
            return redirectToLogin();

        if (rejectReason == null || rejectReason.isBlank()) {
            rttr.addFlashAttribute("errorMsg", "반려 사유를 입력해 주세요.");
            return listRedirect(TAB_REQUEST, "PENDING");
        }

        try {
            adminReviewService.rejectReviewDeleteRequest(
                    requestId, rejectReason.trim(), resolveAdminNo(admin));
            rttr.addFlashAttribute("successMsg", "삭제 요청이 반려되었습니다.");
            return listRedirect(TAB_REQUEST, "REJECTED");
        } catch (IllegalArgumentException | IllegalStateException e) {
            rttr.addFlashAttribute("errorMsg", "처리할 수 없는 요청입니다.");
            return listRedirect(TAB_REQUEST, "PENDING");
        } catch (Exception e) {
            log.error("리뷰 삭제 반려 실패 requestId={}", requestId, e);
            rttr.addFlashAttribute("errorMsg", "반려 처리 중 오류가 발생했습니다.");
            return listRedirect(TAB_REQUEST, "PENDING");
        }
    }

    // 고객 신고된 리뷰 삭제
    @PostMapping("/report/delete")
    public String deleteReviewByReport(HttpSession session,
            @RequestParam long reportId,
            RedirectAttributes rttr) {
        MemberVO admin = getAdmin(session);
        if (admin == null)
            return redirectToLogin();

        try {
            adminReviewService.deleteReviewByReport(reportId, resolveAdminNo(admin));
            rttr.addFlashAttribute("successMsg", "신고된 리뷰를 삭제했습니다.");
            return listRedirect(TAB_REPORT, "DELETED");
        } catch (IllegalArgumentException | IllegalStateException e) {
            log.warn("고객 신고 리뷰 삭제 거부 reportId={}: {}", reportId, e.getMessage());
            rttr.addFlashAttribute("errorMsg", "처리할 수 없는 신고입니다.");
            return listRedirect(TAB_REPORT, "PENDING");
        } catch (Exception e) {
            log.error("고객 신고 리뷰 삭제 실패 reportId={}", reportId, e);
            rttr.addFlashAttribute("errorMsg", "삭제 처리 중 오류가 발생했습니다." + errorDetail(e));
            return listRedirect(TAB_REPORT, "PENDING");
        }
    }

    // 고객 신고 반려 (반려 사유 필수)
    @PostMapping("/report/reject")
    public String rejectReviewReport(HttpSession session,
            @RequestParam long reportId,
            @RequestParam String rejectReason,
            RedirectAttributes rttr) {
        MemberVO admin = getAdmin(session);
        if (admin == null)
            return redirectToLogin();

        if (rejectReason == null || rejectReason.isBlank()) {
            rttr.addFlashAttribute("errorMsg", "반려 사유를 입력해 주세요.");
            return listRedirect(TAB_REPORT, "PENDING");
        }

        try {
            adminReviewService.rejectReviewReport(reportId, rejectReason.trim(), resolveAdminNo(admin));
            rttr.addFlashAttribute("successMsg", "신고를 반려했습니다.");
            return listRedirect(TAB_REPORT, "REJECTED");
        } catch (IllegalArgumentException | IllegalStateException e) {
            rttr.addFlashAttribute("errorMsg", "처리할 수 없는 신고입니다.");
            return listRedirect(TAB_REPORT, "PENDING");
        } catch (Exception e) {
            log.error("고객 신고 반려 실패 reportId={}", reportId, e);
            rttr.addFlashAttribute("errorMsg", "반려 처리 중 오류가 발생했습니다.");
            return listRedirect(TAB_REPORT, "PENDING");
        }
    }

    private String listRedirect(String tab, String statusCd) {
        return "redirect:/admin/review/list?tab=" + tab + "&statusCd=" + statusCd;
    }

    private String errorDetail(Exception e) {
        String err = e.getMessage();
        if (err == null && e.getCause() != null) {
            err = e.getCause().getMessage();
        }
        return err != null ? " (" + err + ")" : "";
    }
}
