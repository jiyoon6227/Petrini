package com.petcare.petcare.admin.main.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.petcare.petcare.admin.controller.AdminBaseController;
import com.petcare.petcare.common.util.LoginAttemptUtil;
import com.petcare.petcare.member.auth.exception.MemberLoginBlockedException;
import com.petcare.petcare.member.auth.service.MemberAuthService;
import com.petcare.petcare.member.vo.MemberVO;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/admin")
public class AdminAuthController extends AdminBaseController {

    @Autowired
    private MemberAuthService memberAuthService;

    @GetMapping("/login")
    public String loginForm(HttpSession session) {
        if (getAdmin(session) != null) {
            return "redirect:/admin";
        }
        return "admin/login";
    }

    @PostMapping("/login")
    public String loginPost(
            @RequestParam(required = false) String loginId,
            @RequestParam(required = false) String loginPw,
            HttpSession session) {

        if (loginId == null || loginId.isBlank() || loginPw == null || loginPw.isBlank()) {
            return "redirect:/admin/login?error=empty";
        }

        // 잠금 상태 확인
        if (LoginAttemptUtil.isLocked(loginId)) {
            long remaining = LoginAttemptUtil.getRemainingLockMinutes(loginId);
            return "redirect:/admin/login?error=locked&minutes=" + remaining;
        }

        MemberVO member;
        try {
            member = memberAuthService.login(loginId, loginPw);
        } catch (MemberLoginBlockedException e) {
            // 탈퇴 회원
            return "redirect:/admin/login?error=invalid";
        }

        if (member == null) {
            // 실패 기록
            LoginAttemptUtil.recordFailure(loginId);
            int remaining = LoginAttemptUtil.getRemainingAttempts(loginId);
            if (remaining == 0) {
                return "redirect:/admin/login?error=locked&minutes=30";
            }
            return "redirect:/admin/login?error=invalid&remaining=" + remaining;
        }

        // 관리자 외 계정 차단
        if (!"ADMIN".equals(member.getRole())) {
            return "redirect:/admin/login?error=invalid";
        }

        LoginAttemptUtil.resetAttempts(loginId);
        session.setAttribute("memberInfo", member);

        return "redirect:/admin";
    }
}
