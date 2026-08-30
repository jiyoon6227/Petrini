package com.petcare.petcare.common.interceptor;

import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import com.petcare.petcare.common.util.CsrfTokenUtil;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@Component
public class CsrfTokenInterceptor implements HandlerInterceptor {
    /** AJAX 에서 토큰을 보낼 때 사용하는 HTTP 헤더 이름 */
    private static final String CSRF_HEADER_NAME = "X-CSRF-TOKEN";   

    public boolean preHandle(HttpServletRequest request, 
                             HttpServletResponse response,
                             Object handler) throws Exception {
        /*
        GET  → 조회만 한다.
        POST → 등록한다.
        PUT  → 수정한다.
        DELETE → 삭제한다.
        Spring Security는 "개발자가 HTTP 규칙을 지킨다"는 전제를 가지고 있습니다.
        이 규칙을 지킨다고 가정하기 때문에 GET은 CSRF 검사를 생략합니다.
         */

        // GET, HEAD, OPTIONS 는 검증 불필요
        String method = request.getMethod();
        if ("GET".equalsIgnoreCase(method) ||
            "HEAD".equalsIgnoreCase(method) ||
            "OPTIONS".equalsIgnoreCase(method)) {
            return true;
        }

        // POST, PUT, DELETE, PATCH → 토큰 검증 필요
        HttpSession session = request.getSession(false);
        if (session == null) {
            // 세션 자체가 없으면 로그인 안 한 상태 → 통과
            // (로그인/회원가입 POST 는 세션 없이 올 수 있음)
            return true;
        }

        // 1순위: form hidden field 에서 토큰 가져오기
        String requestToken = request.getParameter(CsrfTokenUtil.CSRF_TOKEN_KEY);

        // 2순위: AJAX header 에서 토큰 가져오기
        if (requestToken == null || requestToken.isEmpty()) {
            requestToken = request.getHeader(CSRF_HEADER_NAME);
        }

        if (CsrfTokenUtil.isValid(session, requestToken)) {
            return true;
        }

        response.sendError(HttpServletResponse.SC_FORBIDDEN, "CSRF 토큰이 유효하지 않습니다.");
        return false;
    }

    /**
     * 응답 후처리 — JSP 에서 사용할 수 있도록 request attribute 에 토큰 설정
     *
     * 모든 요청에 대해 실행되므로, 어떤 JSP 에서든 ${_csrf} 로 토큰 접근 가능
     */
    public void postHandle(HttpServletRequest request, HttpServletResponse response,
                           Object handler, ModelAndView modelAndView) throws Exception {
        //
        HttpSession session = request.getSession(false);
        if (session != null) {
            String token = CsrfTokenUtil.getOrCreateToken(session);
            request.setAttribute(CsrfTokenUtil.CSRF_TOKEN_KEY, token);
        }
    }
}
