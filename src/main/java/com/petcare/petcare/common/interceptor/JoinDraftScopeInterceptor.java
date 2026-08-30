/**
 * 2026/07/27 장우철 — 가입 임시저장(세션) 범위 제한
 *
 * 정책
 * - joinDraft / 가입 pending 카드는 「가입·토스 카드등록 왕복」에서만 유지
 * - 다른 HTML 페이지로 이동하면 폐기
 * - 주의: footer 장바구니/알림 count 같은 Ajax 는 지우면 안 됨
 *   → Sec-Fetch-Dest=document (또는 HTML 문서 요청) 일 때만 폐기
 */
package com.petcare.petcare.common.interceptor;

import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import com.petcare.petcare.common.billing.controller.BillingCardController;
import com.petcare.petcare.member.auth.controller.MemberAuthController;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@Component
public class JoinDraftScopeInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        String path = pathWithinApp(request);

        // 가입·빌링 콜백 경로에서는 유지
        if (path.startsWith("/join") || path.startsWith("/billing/card")) {
            return true;
        }

        // 2026/07/27 장우철 — Ajax/이미지 등은 유지, 실제 페이지 이동만 폐기
        if (!isDocumentNavigation(request)) {
            return true;
        }

        HttpSession session = request.getSession(false);
        if (session == null) {
            return true;
        }

        session.removeAttribute(MemberAuthController.SESSION_JOIN_DRAFT);
        session.removeAttribute(BillingCardController.SESSION_PENDING_CARD);
        return true;
    }

    /** 브라우저가 새 HTML 문서로 이동하는 요청인지 */
    private static boolean isDocumentNavigation(HttpServletRequest request) {
        String dest = request.getHeader("Sec-Fetch-Dest");
        if (dest != null) {
            return "document".equalsIgnoreCase(dest);
        }
        // 구형 브라우저: Accept 에 HTML 이 있을 때만 페이지 이동으로 간주
        String accept = request.getHeader("Accept");
        return accept != null && accept.contains("text/html");
    }

    private static String pathWithinApp(HttpServletRequest request) {
        String uri = request.getRequestURI();
        String ctx = request.getContextPath();
        if (ctx != null && !ctx.isEmpty() && uri.startsWith(ctx)) {
            uri = uri.substring(ctx.length());
        }
        if (uri == null || uri.isEmpty()) {
            return "/";
        }
        return uri;
    }
}
