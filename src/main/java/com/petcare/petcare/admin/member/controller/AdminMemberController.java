/**
 * 역할: 관리자 회원 URL 처리 → Service 호출 → JSP 반환
 *
 * - 박유정 / 2026-07-16 (목록·상세), 2026-07-20 (STEP 7·8)
 *
 * [화면 흐름]
 * 1. GET  /admin/member/list   → list.jsp (검색·필터·페이징)
 * 2. GET  /admin/member/detail → detail.jsp (기본정보 + 활동현황)
 * 3. POST /admin/member/suspend  → STATUS_CD = SUSPENDED (STEP 7)
 * 4. POST /admin/member/restore  → STATUS_CD = NORMAL     (STEP 7)
 * 5. POST /admin/member/withdraw → STATUS_CD = WITHDRAWN   (STEP 7)
 *
 * 연결
 * - Service: AdminMemberService
 * - 상속: AdminBaseController (관리자 로그인 체크)
 *
 * SQL·비즈니스 로직은 넣지 말 것 → Service로 위임
 * return 경로는 담당 JSP와 동일하게 맞출 것
 */

package com.petcare.petcare.admin.member.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.petcare.petcare.admin.controller.AdminBaseController;

import jakarta.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestParam;

import com.petcare.petcare.admin.member.service.AdminMemberService;

import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.petcare.petcare.admin.member.vo.AdminMemberVO;

import org.springframework.web.bind.annotation.PostMapping;

import java.util.List;

import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

@Controller("adminMemberController")
@RequestMapping("/admin/member")
public class AdminMemberController extends AdminBaseController {
   
    @Autowired
    private AdminMemberService adminMemberService;

    // 2026-07-16 박유정 — 관리자 회원 목록 (DB 연동)
    @GetMapping("/list")
    public String memberList(HttpSession session,
                             @RequestParam(defaultValue = "") String keyword,
                             @RequestParam(defaultValue = "") String statusCd,
                             @RequestParam(defaultValue = "") String roleType,
                             @RequestParam(defaultValue = "1") int page,
                             Model model) {
        if (getAdmin(session) == null)
            return redirectToLogin();

        model.addAttribute("list",
                adminMemberService.getAdminMemberList(keyword, statusCd, roleType, page));
        model.addAttribute("totalCount",
                adminMemberService.getAdminMemberCount(keyword, statusCd, roleType));
        model.addAttribute("keyword", keyword);
        model.addAttribute("statusCd", statusCd);
        model.addAttribute("roleType", roleType);
        model.addAttribute("page", page);

        return "admin/member/list";
    }

    // 2026-07-16 박유정 — 관리자 회원 상세 (기본정보 + STEP 8 활동현황)
    @GetMapping("/detail")
    public String memberDetail(HttpSession session,
                               @RequestParam long id,
                               Model model,
                               RedirectAttributes rttr) {
        if (getAdmin(session) == null)
            return redirectToLogin();

        AdminMemberVO member = adminMemberService.getAdminMemberDetail(id);
        if (member == null) {
            rttr.addFlashAttribute("errorMsg", "회원을 찾을 수 없습니다.");
            return "redirect:/admin/member/list";
        }
        model.addAttribute("member", member);
        model.addAttribute("pointList", adminMemberService.getAdminMemberPointHistory(id));
        model.addAttribute("orderList", adminMemberService.getAdminMemberRecentOrders(id));
        return "admin/member/detail";
    }
    // 2026-07-20 박유정 STEP 7 — 계정 정지
    // 2026-07-21 박유정 STEP ② — 기간 정지 (suspendType: DAY3/DAY7/PERMANENT)
    @PostMapping("/suspend")
    public String suspendMember(HttpSession session,
                                @RequestParam long memberNo,
                                @RequestParam(defaultValue = "PERMANENT") String suspendType,
                                RedirectAttributes rttr) {
        if (getAdmin(session) == null)
            return redirectToLogin();

        try {
            adminMemberService.suspendMember(memberNo, suspendType);
            rttr.addFlashAttribute("successMsg", "계정이 정지되었습니다.");
            return "redirect:/admin/member/detail?id=" + memberNo;
        } catch (IllegalArgumentException e) {
            switch (e.getMessage()) {
                case "INVALID_SUSPEND_TYPE" ->
                    rttr.addFlashAttribute("errorMsg", "정지 기간을 올바르게 선택해 주세요.");
                default ->
                    rttr.addFlashAttribute("errorMsg", "회원을 찾을 수 없습니다.");
            }
            return "redirect:/admin/member/detail?id=" + memberNo;
    
        } catch (Exception e) {
            rttr.addFlashAttribute("errorMsg", "정지 처리 중 오류가 발생했습니다.");
            return "redirect:/admin/member/detail?id=" + memberNo;
        }
    }

    // 2026-07-20 박유정 STEP 7 — 계정 복구
    @PostMapping("/restore")
    public String restoreMember(HttpSession session,
                                  @RequestParam long memberNo,
                                  RedirectAttributes rttr) {
        if (getAdmin(session) == null)
            return redirectToLogin();

        try {
            adminMemberService.restoreMember(memberNo);
            rttr.addFlashAttribute("successMsg", "계정이 복구되었습니다.");
            return "redirect:/admin/member/detail?id=" + memberNo;
        } catch (IllegalArgumentException e) {
            rttr.addFlashAttribute("errorMsg", "회원을 찾을 수 없습니다.");
            return "redirect:/admin/member/detail?id=" + memberNo;
        } catch (Exception e) {
            rttr.addFlashAttribute("errorMsg", "복구 처리 중 오류가 발생했습니다.");
            return "redirect:/admin/member/detail?id=" + memberNo;
        }
    }

    // 2026-07-20 박유정 STEP 7 — 강제 탈퇴
    @PostMapping("/withdraw")
    public String withdrawMember(HttpSession session,
                                 @RequestParam long memberNo,
                                 RedirectAttributes rttr) {
        if (getAdmin(session) == null)
            return redirectToLogin();

        try {
            adminMemberService.withdrawMember(memberNo);
            rttr.addFlashAttribute("successMsg", "강제 탈퇴 처리되었습니다.");
            return "redirect:/admin/member/list?statusCd=WITHDRAWN";
        } catch (IllegalArgumentException e) {
            rttr.addFlashAttribute("errorMsg", "회원을 찾을 수 없습니다.");
            return "redirect:/admin/member/detail?id=" + memberNo;
        } catch (Exception e) {
            rttr.addFlashAttribute("errorMsg", "탈퇴 처리 중 오류가 발생했습니다.");
            return "redirect:/admin/member/detail?id=" + memberNo;
        }
    }

    // 2026-07-21 박유정 STEP 9 — 등급 변경
    @PostMapping("/grade")
    public String updateMemberGrade(HttpSession session,
                                      @RequestParam long memberNo,
                                      @RequestParam String gradeCd,
                                      RedirectAttributes rttr) {
        if (getAdmin(session) == null)
            return redirectToLogin();

        try {
            adminMemberService.updateMemberGrade(memberNo, gradeCd);
            rttr.addFlashAttribute("successMsg", "등급이 변경되었습니다.");
            return "redirect:/admin/member/detail?id=" + memberNo;
        } catch (IllegalArgumentException e) {
            if ("INVALID_GRADE".equals(e.getMessage())) {
                rttr.addFlashAttribute("errorMsg", "올바른 등급을 선택해 주세요.");
            } else {
                rttr.addFlashAttribute("errorMsg", "회원을 찾을 수 없습니다.");
            }
            return "redirect:/admin/member/detail?id=" + memberNo;
        } catch (Exception e) {
            rttr.addFlashAttribute("errorMsg", "등급 변경 중 오류가 발생했습니다.");
            return "redirect:/admin/member/detail?id=" + memberNo;
        }
    }

    // 2026-07-21 박유정 STEP 10 — 포인트 지급·차감
    @PostMapping("/point")
    public String adjustMemberPoint(HttpSession session,
                                    @RequestParam long memberNo,
                                    @RequestParam String adjustType,
                                    @RequestParam int amount,
                                    @RequestParam(required = false) String reason,
                                    RedirectAttributes rttr) {
        if (getAdmin(session) == null)
            return redirectToLogin();

        try {
            adminMemberService.adjustMemberPoint(memberNo, adjustType, amount, reason);
            rttr.addFlashAttribute("successMsg", "포인트가 처리되었습니다.");
            return "redirect:/admin/member/detail?id=" + memberNo;
        } catch (IllegalArgumentException e) {
            switch (e.getMessage()) {
                case "INVALID_AMOUNT" ->
                    rttr.addFlashAttribute("errorMsg", "포인트는 1 이상 입력해 주세요.");
                case "INVALID_TYPE" ->
                    rttr.addFlashAttribute("errorMsg", "지급/차감 구분이 올바르지 않습니다.");
                case "INSUFFICIENT_POINT" ->
                    rttr.addFlashAttribute("errorMsg", "보유 포인트가 부족합니다.");
                default ->
                    rttr.addFlashAttribute("errorMsg", "회원을 찾을 수 없습니다.");
            }
            return "redirect:/admin/member/detail?id=" + memberNo;
        } catch (Exception e) {
            rttr.addFlashAttribute("errorMsg", "포인트 처리 중 오류가 발생했습니다.");
            return "redirect:/admin/member/detail?id=" + memberNo;
        }
    }

    // 2026-07-21 박유정 STEP 12 — 선택 회원 일괄 정지
    // 2026-07-21 박유정 STEP ② — 일괄 기간 정지 (suspendType)
    @PostMapping("/bulk-suspend")
    public String bulkSuspendMembers(HttpSession session,
                                    @RequestParam List<Long> memberNos,
                                    @RequestParam(defaultValue = "") String keyword,
                                    @RequestParam(defaultValue = "") String statusCd,
                                    @RequestParam(defaultValue = "") String roleType,
                                    @RequestParam(defaultValue = "1") int page,
                                    @RequestParam(defaultValue = "PERMANENT") String suspendType,
                                    RedirectAttributes rttr) {
        if (getAdmin(session) == null)
            return redirectToLogin();

        try {
            int count = adminMemberService.bulkSuspendMembers(memberNos, suspendType);
            rttr.addFlashAttribute("successMsg", count + "명이 정지되었습니다.");
            return "redirect:/admin/member/list?keyword=" + keyword
                    + "&statusCd=SUSPENDED&roleType=" + roleType + "&page=" + page;
        } catch (IllegalArgumentException e) {
            rttr.addFlashAttribute("errorMsg", "선택된 회원이 없습니다.");
            return "redirect:/admin/member/list?keyword=" + keyword
                    + "&statusCd=" + statusCd + "&roleType=" + roleType + "&page=" + page;
        } catch (Exception e) {
            rttr.addFlashAttribute("errorMsg", "일괄 정지 처리 중 오류가 발생했습니다.");
            return "redirect:/admin/member/list?keyword=" + keyword
                    + "&statusCd=" + statusCd + "&roleType=" + roleType + "&page=" + page;
        }
    }

    // 2026-07-22 박유정 — 선택 회원 일괄 복구
    @PostMapping("/bulk-restore")
    public String bulkRestoreMembers(HttpSession session,
                                     @RequestParam List<Long> memberNos,
                                     @RequestParam(defaultValue = "") String keyword,
                                     @RequestParam(defaultValue = "") String statusCd,
                                     @RequestParam(defaultValue = "") String roleType,
                                     @RequestParam(defaultValue = "1") int page,
                                     RedirectAttributes rttr) {
        if (getAdmin(session) == null)
            return redirectToLogin();

        try {
            int count = adminMemberService.bulkRestoreMembers(memberNos);
            rttr.addFlashAttribute("successMsg", count + "명이 복구되었습니다.");
            return "redirect:/admin/member/list?keyword=" + keyword
                    + "&statusCd=NORMAL&roleType=" + roleType + "&page=" + page;
        } catch (IllegalArgumentException e) {
            rttr.addFlashAttribute("errorMsg", "선택된 회원이 없습니다.");
            return "redirect:/admin/member/list?keyword=" + keyword
                    + "&statusCd=" + statusCd + "&roleType=" + roleType + "&page=" + page;
        } catch (Exception e) {
            rttr.addFlashAttribute("errorMsg", "일괄 복구 처리 중 오류가 발생했습니다.");
            return "redirect:/admin/member/list?keyword=" + keyword
                    + "&statusCd=" + statusCd + "&roleType=" + roleType + "&page=" + page;
        }
    }

    // 2026-07-21 박유정 STEP 12 — 선택 회원 일괄 탈퇴
    @PostMapping("/bulk-withdraw")
    public String bulkWithdrawMembers(HttpSession session,
                                     @RequestParam List<Long> memberNos,
                                     @RequestParam(defaultValue = "") String keyword,
                                     @RequestParam(defaultValue = "") String statusCd,
                                     @RequestParam(defaultValue = "") String roleType,
                                     @RequestParam(defaultValue = "1") int page,
                                      RedirectAttributes rttr) {
        if (getAdmin(session) == null)
            return redirectToLogin();

        try {
            int count = adminMemberService.bulkWithdrawMembers(memberNos);
            rttr.addFlashAttribute("successMsg", count + "명이 탈퇴 처리되었습니다.");
            return "redirect:/admin/member/list?keyword=" + keyword
                    + "&statusCd=WITHDRAWN&roleType=" + roleType + "&page=" + page;
        } catch (IllegalArgumentException e) {
            rttr.addFlashAttribute("errorMsg", "선택된 회원이 없습니다.");
            return "redirect:/admin/member/list?keyword=" + keyword
                    + "&statusCd=" + statusCd + "&roleType=" + roleType + "&page=" + page;
        } catch (Exception e) {
            rttr.addFlashAttribute("errorMsg", "일괄 탈퇴 처리 중 오류가 발생했습니다.");
            return "redirect:/admin/member/list?keyword=" + keyword
                    + "&statusCd=" + statusCd + "&roleType=" + roleType + "&page=" + page;
        }
    }

    // 2026-07-21 박유정 — 회원 목록 CSV(Excel)보내기
    @GetMapping("/export")
    public void exportMemberList(HttpSession session,
                                 @RequestParam(defaultValue = "") String keyword,
                                 @RequestParam(defaultValue = "") String statusCd,
                                 @RequestParam(defaultValue = "") String roleType,
                                 HttpServletResponse response) throws IOException {
        if (getAdmin(session) == null) {
            response.sendRedirect("/admin/login");
            return;
        }

        String fileName = "members_"
                + LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE) + ".csv";
        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader("Content-Disposition",
                "attachment; filename=\"" + fileName + "\"");

        adminMemberService.exportMemberCsv(keyword, statusCd, roleType, response.getOutputStream());
    }
}