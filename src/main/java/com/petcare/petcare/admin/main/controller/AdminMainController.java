package com.petcare.petcare.admin.main.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.petcare.petcare.admin.controller.AdminBaseController;

import jakarta.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.ui.Model;

import com.petcare.petcare.admin.main.service.AdminMainService;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

import jakarta.servlet.http.HttpServletResponse;

@Controller("adminController")
@RequestMapping("/admin")
public class AdminMainController extends AdminBaseController {

    @Autowired
    private AdminMainService adminMainService;
    
    // 대시보드
    @GetMapping({"", "/"})
    public String dashboard(HttpSession session, Model model) {
        if (getAdmin(session) == null) 
            return redirectToLogin();

        // 대시보드 요약 (통계·차트·최근주문·승인대기) → JSP summary
        model.addAttribute("summary", adminMainService.getDashboardSummary());  
        return "admin/dashboard";
    }

    // 통계
    @GetMapping("/stats")
    public String stats(HttpSession session, Model model) {
        if (getAdmin(session) == null) 
            return redirectToLogin();
        
        // 통계 요약 → JSP stats
        model.addAttribute("stats", adminMainService.getStatsSummary());
        return "admin/stats/index";
    }    

    // 통계 CSV(Excel)보내기 → stats_YYYYMMDD.csv
    @GetMapping("/stats/export")
    public void exportStats(HttpSession session, HttpServletResponse response) throws IOException {
        if (getAdmin(session) == null) {
            response.sendRedirect("/admin/login");
            return;
        }

        // 파일명·Content-Type (회원 export 와 동일 패턴)
        String fileName = "stats_"
                + LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE) + ".csv";
        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader("Content-Disposition",
                "attachment; filename=\"" + fileName + "\"");

        adminMainService.exportStatsCsv(response.getOutputStream());
    }
}
