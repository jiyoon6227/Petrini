/**
 * 역할: 관리자 숙소 예약 URL
 * 2026/07/31 장우철
 * - GET  /admin/reservation/list
 * - GET  /admin/reservation/detail
 * - POST /admin/reservation/cancel  (전액 환불)
 */
package com.petcare.petcare.admin.reservation.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.petcare.petcare.admin.controller.AdminBaseController;
import com.petcare.petcare.admin.reservation.service.AdminReservationService;
import com.petcare.petcare.admin.reservation.vo.AdminStayReservationVO;

import jakarta.servlet.http.HttpSession;

@Controller("adminReservationController")
@RequestMapping("/admin/reservation")
public class AdminReservationController extends AdminBaseController {

    @Autowired
    private AdminReservationService adminReservationService;

    @GetMapping({ "", "/list" })
    public String list(HttpSession session,
                       @RequestParam(value = "status", required = false, defaultValue = "ALL") String status,
                       @RequestParam(value = "keyword", required = false, defaultValue = "") String keyword,
                       Model model) {
        if (getAdmin(session) == null) {
            return redirectToLogin();
        }
        List<AdminStayReservationVO> list =
                adminReservationService.getStayReservationList(status, keyword);
        Map<String, Integer> statusCounts = adminReservationService.getStatusCounts();
        model.addAttribute("list", list);
        model.addAttribute("status", status);
        model.addAttribute("keyword", keyword);
        model.addAttribute("statusCounts", statusCounts);
        return "admin/reservation/list";
    }

    @GetMapping("/detail")
    public String detail(HttpSession session,
                         @RequestParam("resvId") Long resvId,
                         Model model,
                         RedirectAttributes rttr) {
        if (getAdmin(session) == null) {
            return redirectToLogin();
        }
        AdminStayReservationVO detail = adminReservationService.getStayReservationDetail(resvId);
        if (detail == null) {
            rttr.addFlashAttribute("errorMsg", "예약을 찾을 수 없습니다.");
            return "redirect:/admin/reservation/list";
        }
        model.addAttribute("reservation", detail);
        return "admin/reservation/detail";
    }

    @PostMapping("/cancel")
    public String cancel(HttpSession session,
                         @RequestParam("resvId") Long resvId,
                         @RequestParam("cancelReason") String cancelReason,
                         RedirectAttributes rttr) {
        if (getAdmin(session) == null) {
            return redirectToLogin();
        }
        try {
            adminReservationService.cancelStayReservation(resvId, cancelReason);
            rttr.addFlashAttribute("successMsg", "예약을 취소하고 전액 환불 처리했습니다.");
        } catch (IllegalArgumentException | IllegalStateException e) {
            rttr.addFlashAttribute("errorMsg", e.getMessage());
        } catch (Exception e) {
            rttr.addFlashAttribute("errorMsg", "취소 처리 중 오류가 발생했습니다.");
        }
        return "redirect:/admin/reservation/detail?resvId=" + resvId;
    }
}
