package com.petcare.petcare.common.interceptor;

import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import com.petcare.petcare.member.vo.MemberVO;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/** 정지 회원은 /member/cs/**, 로그아웃, 정적 리소스만 허용 (그 외 /member/cs?restricted=1) */
@Component
public class SuspendedMemberInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request,
                             HttpServletResponse response,
                             Object handler) throws Exception {

        HttpSession session = request.getSession(false);
        if (session == null) {
            return true;
        }               
        
        Object obj = session.getAttribute("memberInfo");
        if (!(obj instanceof MemberVO member)) {
            return true;
        } 
        if (!"SUSPENDED".equals(member.getStatus())) {
            return true;
        }

        String uri = request.getRequestURI();
        // context-path 포함 URI 대비 (예: /petcare/member/cs)
        String contextPath = request.getContextPath();
        if (contextPath != null && !contextPath.isEmpty() && uri.startsWith(contextPath)) {
            uri = uri.substring(contextPath.length());
        }
        if (uri.isEmpty()) {
            uri = "/";
        }

        // 정지 회원 허용 경로 (/member/cs, 로그아웃, 정적 파일)
        // cart/noti count Ajax 가 HTML 리다이렉트되면 헤더 뱃지에 페이지 소스가 덤프됨
        if (uri.startsWith("/member/cs")
                || uri.equals("/member/logout")
                || uri.startsWith("/resources/")
                || uri.startsWith("/upload/")
                || uri.equals("/store/cart/count")
                || uri.equals("/mypage/notifications/count")) {
            return true;
        }

        String redirectUrl = request.getContextPath() + "/member/cs?restricted=1";
        response.sendRedirect(redirectUrl);
        return false;
    }
}