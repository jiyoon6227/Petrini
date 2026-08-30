/**
 * 역할: 관리자 쇼핑몰 URL 처리 → Service 호출 → JSP 반환
 *
 * 연결
 * - Service: AdminStoreService
 * - 상속: AdminBaseController (관리자 로그인 체크)
 *
 * SQL·비즈니스 로직은 넣지 말 것 → Service로 위임
 * return 경로는 담당 JSP와 동일하게 맞출 것
 */

package com.petcare.petcare.admin.store.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.petcare.petcare.admin.controller.AdminBaseController;
import com.petcare.petcare.admin.store.service.AdminStoreService;
import com.petcare.petcare.member.vo.MemberVO;

import jakarta.servlet.http.HttpSession;

@Controller("adminStoreController")
@RequestMapping("/admin/store")
public class AdminStoreController extends AdminBaseController {

    @Autowired
    private AdminStoreService adminStoreService;

    // 2026/08/11 장우철 — 리뷰관리 메뉴 제거, 사업자 리뷰(/admin/review/list)로 통합
    @GetMapping("/review-report")
    public String reviewReport() {
        return "redirect:/admin/review/list?statusCd=PENDING";
    }

    @PostMapping("/review-report/{reportId}/approve")
    public String approveReviewReport(@PathVariable Long reportId, @RequestParam Long reviewId,
                                       HttpSession session, RedirectAttributes rttr) {
        MemberVO admin = getAdmin(session);
        if (admin == null) return redirectToLogin();

        adminStoreService.approveReviewReport(reportId, reviewId, admin.getMemberNo());
        rttr.addFlashAttribute("successMsg", "삭제 요청을 승인했습니다.");
        return "redirect:/admin/review/list?statusCd=APPROVED";
    }

    @PostMapping("/review-report/{reportId}/reject")
    public String rejectReviewReport(@PathVariable Long reportId, HttpSession session, RedirectAttributes rttr) {
        MemberVO admin = getAdmin(session);
        if (admin == null) return redirectToLogin();

        adminStoreService.rejectReviewReport(reportId, admin.getMemberNo());
        rttr.addFlashAttribute("successMsg", "삭제 요청을 반려했습니다.");
        return "redirect:/admin/review/list?statusCd=REJECTED";
    }

    // ── ADMIN-02 상품 관리 (2026/08/11 장우철 — 전 사업자 실데이터) ──
    @GetMapping("/product-list")
    public String productList(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String statusCd,
            @RequestParam(defaultValue = "1") int page,
            HttpSession session,
            Model model) {
        if (getAdmin(session) == null)
            return redirectToLogin();

        int size = 20;
        int total = adminStoreService.getProductCount(keyword, statusCd);
        int totalPages = total == 0 ? 1 : (int) Math.ceil(total / (double) size);
        if (page < 1) page = 1;
        if (page > totalPages) page = totalPages;

        model.addAttribute("productList", adminStoreService.getProductList(keyword, statusCd, page, size));
        model.addAttribute("totalCount", total);
        model.addAttribute("page", page);
        model.addAttribute("totalPages", totalPages);
        model.addAttribute("keyword", keyword);
        model.addAttribute("statusCd", statusCd);
        return "admin/store/product-list";
    }

    // ── ADMIN-02 주문 관리 (2026/08/11 장우철 — 전 사업자 실데이터) ──
    @GetMapping("/order-list")
    public String orderList(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String statusCd,
            @RequestParam(defaultValue = "1") int page,
            HttpSession session,
            Model model) {
        if (getAdmin(session) == null)
            return redirectToLogin();

        int size = 20;
        int total = adminStoreService.getOrderCount(keyword, statusCd);
        int totalPages = total == 0 ? 1 : (int) Math.ceil(total / (double) size);
        if (page < 1) page = 1;
        if (page > totalPages) page = totalPages;

        model.addAttribute("orderList", adminStoreService.getOrderList(keyword, statusCd, page, size));
        model.addAttribute("totalCount", total);
        model.addAttribute("page", page);
        model.addAttribute("totalPages", totalPages);
        model.addAttribute("keyword", keyword);
        model.addAttribute("statusCd", statusCd);
        return "admin/store/order-list";
    }

    // ── 상품 카테고리 관리 — 2026/08/11 장우철: 미사용(더미 카테고리만 사용) → 메뉴/라우트 제거
    // @GetMapping("/category") 삭제

    @GetMapping("/order-detail")
    public String orderDetail(
            @RequestParam(required = false) Long id,
            HttpSession session,
            Model model) {
        if (getAdmin(session) == null)
            return redirectToLogin();

        model.addAttribute("order", id != null ? adminStoreService.getOrderDetail(id) : null);
        return "admin/store/order-detail";
    }

    @GetMapping("/product-form")
    public String productForm(HttpSession session) {
        if (getAdmin(session) == null)
            return redirectToLogin();

        // 관리자 직접 등록은 사용하지 않음 — 목록으로 유도
        return "redirect:/admin/store/product-list";
    }
}
