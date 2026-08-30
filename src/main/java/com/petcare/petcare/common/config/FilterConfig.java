package com.petcare.petcare.common.config;

import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Configuration;

import com.petcare.petcare.common.filter.XssFilter;

/**
 * 역할: 서블릿 필터 등록 설정
 *
 * - HYJ / 2026-08-05 — XSS 필터 등록
 *
 * [왜 FilterRegistrationBean 을 쓰는가?]
 * - @WebFilter 어노테이션은 필터 순서(order) 보장이 안 됨
 * - FilterRegistrationBean 으로 등록하면 순서, URL 패턴, 이름을 명확히 제어 가능
 * - 향후 CSRF 필터 등 추가 시 순서 관리가 쉬움
 *
 * [필터 실행 순서]
 * order 값이 낮을수록 먼저 실행
 * 1 = XssFilter (가장 먼저 — 모든 파라미터 정화)
 * 2 = (향후) CsrfFilter
 * 3 = (향후) 추가 보안 필터
 */

@Configuration
public class FilterConfig {
    //Spring Boot에 XssFilter 명시적으로 등록
    public FilterRegistrationBean<XssFilter> xssFilterRegistration() {
        FilterRegistrationBean<XssFilter> registration = new FilterRegistrationBean<>();
        registration.setFilter(new XssFilter());
        registration.addUrlPatterns("/*");
        registration.setName("xssFilter");
        registration.setOrder(1);
        return registration;
    }
}
