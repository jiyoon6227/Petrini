package com.petcare.petcare.common.interceptor;

import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/* 모든 응답에 보안 헤더 추가 (Spring Security 미사용이라 직접 설정) */
@Component
public class SecurityHeaderInterceptor implements HandlerInterceptor {
    @Override
    public boolean preHandle(HttpServletRequest request,
                              HttpServletResponse response,
                              Object handler) throws Exception {
        // MIME 타입 스니핑 차단
        response.setHeader("X-Content-Type-Options", "nosniff");
 
        // iframe 삽입 차단 (클릭재킹 방지)
        response.setHeader("X-Frame-Options", "DENY");
 
        // 브라우저 내장 XSS 필터 활성화 (구형 브라우저 대응)
        response.setHeader("X-XSS-Protection", "1; mode=block");
 
        // 캐시 저장 방지 (공용 PC 정보 유출 방지)
        response.setHeader("Cache-Control", "no-store");
 
        // Referrer 정보 최소화 (URL 민감 정보 유출 방지)
        response.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");
 
        return true;
    }
}
