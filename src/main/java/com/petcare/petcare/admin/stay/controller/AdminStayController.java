/**
 * 역할: 관리자 숙소 관리 URL
 * 2026/08/13 장우철
 * - GET /admin/stay/list
 * - GET /admin/stay/detail
 */
package com.petcare.petcare.admin.stay.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.petcare.petcare.admin.controller.AdminBaseController;
import com.petcare.petcare.admin.stay.service.AdminStayService;
import com.petcare.petcare.admin.stay.vo.AdminStayVO;
import com.petcare.petcare.stay.vo.StayRoomVO;

import jakarta.servlet.http.HttpSession;

@Controller("adminStayController")
@RequestMapping("/admin/stay")
public class AdminStayController extends AdminBaseController {

    @Autowired
    private AdminStayService adminStayService;

    @GetMapping({ "", "/list" })
    public String list(HttpSession session,
                       @RequestParam(value = "status", required = false, defaultValue = "ALL") String status,
                       @RequestParam(value = "keyword", required = false, defaultValue = "") String keyword,
                       Model model) {
        if (getAdmin(session) == null) {
            return redirectToLogin();
        }
        List<AdminStayVO> list = adminStayService.getStayList(status, keyword);
        Map<String, Integer> statusCounts = adminStayService.getStatusCounts();
        model.addAttribute("list", list);
        model.addAttribute("status", status);
        model.addAttribute("keyword", keyword);
        model.addAttribute("statusCounts", statusCounts);
        return "admin/stay/list";
    }

    @GetMapping("/detail")
    public String detail(HttpSession session,
                         @RequestParam("stayId") Long stayId,
                         Model model,
                         RedirectAttributes rttr) {
        if (getAdmin(session) == null) {
            return redirectToLogin();
        }
        AdminStayVO stay = adminStayService.getStayDetail(stayId);
        if (stay == null) {
            rttr.addFlashAttribute("errorMsg", "숙소를 찾을 수 없습니다.");
            return "redirect:/admin/stay/list";
        }
        List<StayRoomVO> rooms = adminStayService.getRoomList(stayId);
        model.addAttribute("stay", stay);
        model.addAttribute("rooms", rooms);
        return "admin/stay/detail";
    }
}
