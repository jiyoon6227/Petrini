package com.petcare.petcare.common.filter;

import java.io.IOException;


import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;

/*
@jakarta.servlet.annotation.WebFilter("/*")
public class XssFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
    }
}

    - @webconfig 사용시, SpringBoot에 자동으로 등록되기 때문에 FilterConfig 필요없음
    - Spring Boot는 기본적으로 @webconfig(tomcat 어노테이션) 자동으로 스캔하지 않기때문에 
      메인클래스에 @servletcomponentscan 설정 필요
*/

public class XssFilter implements Filter {
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // 필터 초기화 — 별도 설정 불필요
    }
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        String uri = httpRequest.getRequestURI();

        // 정적 리소스는 필터 제외 (파라미터 필터 불필요)
        if (uri.startsWith("/resources/") || 
            uri.startsWith("/upload/") || 
            uri.endsWith("/favicon.ico")) {
            chain.doFilter(request, response);
            return;
        }

        // XssRequestWrapper 로 감싸서 다음 필터/컨트롤러에 전달
        // → 이후 getParameter(), getParameterValues(), getHeader() 호출 시 자동 필터
        chain.doFilter(new XssRequestWrapper(httpRequest), response);
    }

    @Override
    public void destroy() {
        // 필터 종료 — 정리할 리소스 없음
    }
}
