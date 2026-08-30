/**
 * 역할: 관리자 대시보드·통계 URL 처리 → Service 호출 → JSP 반환
 *
 * 연결
 * - Service: AdminMainService
 * - 상속: AdminBaseController (관리자 로그인 체크)
 *
 * SQL·비즈니스 로직은 넣지 말 것 → Service로 위임
 * return 경로는 담당 JSP와 동일하게 맞출 것
 *
 * - 박유정 / 2026-07-29 — Phase 1: 승인 대기 사업자
 * - 박유정 / 2026-07-30 — ADMIN-01 대시보드 / ADMIN-04 통계 Phase 1
 * - 박유정 / 2026-07-31 — ADMIN-04 통계 Phase 5-C: /stats/export CSV
 */

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
    
    // ── ADMIN-01 대시보드 ──────────────────────────────────
    @GetMapping({"", "/"})
    public String dashboard(HttpSession session, Model model) {
        if (getAdmin(session) == null) 
            return redirectToLogin();

        // 2026-07-30 박유정 — ADMIN-01: 대시보드 요약 (통계·차트·최근주문·승인대기) → JSP summary
        model.addAttribute("summary", adminMainService.getDashboardSummary());  
        return "admin/dashboard";
    }

    // ── ADMIN-04 통계 ──────────────────────────────────────
    @GetMapping("/stats")
    public String stats(HttpSession session, Model model) {
        if (getAdmin(session) == null) 
            return redirectToLogin();
        
        // 2026-07-30 박유정 — ADMIN-04: 통계 요약 → JSP stats
        model.addAttribute("stats", adminMainService.getStatsSummary());
        return "admin/stats/index";
    }    

    // 2026-07-31 박유정 — Phase 5-C: 통계 CSV(Excel)보내기 → stats_YYYYMMDD.csv
    @GetMapping("/stats/export")
    public void exportStats(HttpSession session, HttpServletResponse response) throws IOException {
        if (getAdmin(session) == null) {
            response.sendRedirect("/admin/login");
            return;
        }

        // 2026-07-31 박유정 — 파일명·Content-Type (회원 export 와 동일 패턴)
        String fileName = "stats_"
                + LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE) + ".csv";
        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader("Content-Disposition",
                "attachment; filename=\"" + fileName + "\"");

        adminMainService.exportStatsCsv(response.getOutputStream());
    }
}
