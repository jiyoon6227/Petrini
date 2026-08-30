/**
 * 역할: 관리자 컨트롤러 공통 헬퍼 (세션·권한 체크)
 *
 * 연결
 * - 상속: AdminCMSController, AdminMemberController 등 관리자 Controller
 *
 * SQL·비즈니스 로직은 넣지 말 것 → Service로 위임
 * return 경로는 담당 JSP와 동일하게 맞출 것
 */
package com.petcare.petcare.admin.controller;

import com.petcare.petcare.member.vo.MemberVO;

import jakarta.servlet.http.HttpSession;

// @Controller("adminController")
// @RequestMapping("/admin")
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

    protected boolean isAdminAccount(String loginId) {
        if (loginId == null) {
            return false;
        }
        String id = loginId.trim();
        return "admin".equalsIgnoreCase(id) || "admin@petcare.com".equalsIgnoreCase(id);
    }
}
