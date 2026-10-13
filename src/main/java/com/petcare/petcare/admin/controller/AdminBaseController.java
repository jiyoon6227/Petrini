package com.petcare.petcare.admin.controller;

import com.petcare.petcare.member.vo.MemberVO;

import jakarta.servlet.http.HttpSession;

public class AdminBaseController {

    /** 관리자 권한 체크 헬퍼 */
    public MemberVO getAdmin(HttpSession session) {
        MemberVO m = (MemberVO) session.getAttribute("memberInfo");
        if (m == null || !"ADMIN".equals(m.getRole())) 
            return null;

        return m;
    }

    protected String redirectToLogin() {
        return "redirect:/admin/login";
    }
}
