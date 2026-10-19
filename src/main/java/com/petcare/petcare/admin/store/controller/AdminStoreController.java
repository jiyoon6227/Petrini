package com.petcare.petcare.admin.store.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.petcare.petcare.admin.controller.AdminBaseController;
import com.petcare.petcare.admin.store.service.AdminStoreService;

import jakarta.servlet.http.HttpSession;

@Controller("adminStoreController")
@RequestMapping("/admin/store")
public class AdminStoreController extends AdminBaseController {

    @Autowired
    private AdminStoreService adminStoreService;

    // 상품 관리 (전 사업자)
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

    // 주문 관리 (전 사업자)
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
