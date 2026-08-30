package com.petcare.petcare.common.interceptor;

import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/*
 * HYJ 26.08.07
 * 역할: 모든 HTTP 응답에 보안 헤더를 추가하는 인터셉터
 * 
 * [왜 보안 헤더가 필요한가]
 * 브라우저는 서버가 보낸 응답 헤더를 읽고, 보안 관련 동작을 결정함
 * 헤더가 없으면 브라우저가 기본값(보통허용)으로 동작 -> 공격에 취약
 * 헤더를 설정하면 브라우저에게 "이런건 차단해라"라고 지시할 수 있음
 * 
 * [각 헤더 설명]
 * 1. X-Content-Type-Options: nosniff
 *  -> 브라우저가 MIME 타입을 추측(sniffing)하지 못하게 함
 *  -> 예: 공격자가 .jpg 파일에 JavaScript를 숨겨도, 브라우저가 이미지로만 처리
 * 
 * 2. X-Frame-Options: DENY
 *  -> 이 페이지를 <iframe>으로 다른 사이트에 삽입하지 못하게 함
 *  -> 클릭재킹(ClickJacking) 공격 방지
 *  -> 예:  악성 사이트가 PetCare결제 페이지를 투명 iframe으로 띄우고
 *          사용자가 모르게 클릭하게 만드는 공격을 차단
 * 
 * 3. X-XSS-Protection: 1; mode=block
 *  -> 브라우저 내장 XSS 필터 활성화(구형 브라우저 대응)
 *  -> XSS가 감지되면 페이지 렌더링 자체를 차단
 *  -> 최신 브라우저는 CSP로 대체되었지만, IE/구형 Edgt 대응용으로 유지
 * 
 * 4. Cache-Control: no-store
 *  -> 민감한 페이지(마이페이지, 결제)가 브라우저 캐시에 저장되지 않게 함
 *  -> 공용PC에서 뒤로가기로 이전 사용자의 정보가 보이는 것 방지 
 * 
 * 5. Referrer-Policy: strict-origin-when-cross-origin
 *  -> 외부 사이트로 이동할 때 URL 전체가 아닌 도메인만 전달
 *  -> 예: /mypage/order?id=1234 -> 외부에는 https://petcare.com만 전달
 *  -> URL에 포함된 민감 정보(주문번호, 회원번호 등) 유출 방지
 * 
 * [Spring Security를 쓰면]
 * Sprign Security는 이 헤더들을 기본으로 자동 추가함
 * 현재 프로젝트는 Spring Security없이 운영 중이므로 직접 설정
 */
@Component
public class SecurityHeaderInterceptor implements HandlerInterceptor {
    @Override
    public boolean preHandle(HttpServletRequest request,
                              HttpServletResponse response,
                              Object handler) throws Exception {
        // [1] MIME 타입 스니핑 차단
        response.setHeader("X-Content-Type-Options", "nosniff");
 
        // [2] iframe 삽입 차단 (클릭재킹 방지)
        response.setHeader("X-Frame-Options", "DENY");
 
        // [3] 브라우저 내장 XSS 필터 활성화 (구형 브라우저 대응)
        response.setHeader("X-XSS-Protection", "1; mode=block");
 
        // [4] 캐시 저장 방지 (공용 PC 정보 유출 방지)
        response.setHeader("Cache-Control", "no-store");
 
        // [5] Referrer 정보 최소화 (URL 민감 정보 유출 방지)
        response.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");
 
        return true;
    }
}
