package com.petcare.petcare.admin.main.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.petcare.petcare.admin.controller.AdminBaseController;
import com.petcare.petcare.member.vo.MemberVO;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/admin")
public class AdminAuthController extends AdminBaseController {

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

        String id = loginId.trim();
        if (!isAdminAccount(id)) {
            return "redirect:/admin/login?error=invalid";
        }

        MemberVO member = new MemberVO();
        member.setMemberId(id);
        member.setEmail(id);
        member.setMemberName("관리자");
        member.setRole("ADMIN");
        session.setAttribute("memberInfo", member);

        return "redirect:/admin";
    }
}
