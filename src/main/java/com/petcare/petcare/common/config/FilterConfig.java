package com.petcare.petcare.common.config;

import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Configuration;

import com.petcare.petcare.common.filter.XssFilter;

/** FilterRegistrationBean으로 등록 (@WebFilter는 필터 순서 보장 안 됨), order 낮을수록 먼저 실행 */

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
