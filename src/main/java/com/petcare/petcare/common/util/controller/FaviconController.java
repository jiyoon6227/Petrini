/**
 * 역할: favicon.ico 정적 리소스 제공
 *
 * 연결
 * - 리소스: classpath:static/favicon.svg
 *
 * SQL·비즈니스 로직은 넣지 말 것 → Service로 위임
 * return 경로는 담당 JSP와 동일하게 맞출 것
 */
package com.petcare.petcare.common.util.controller;

import java.io.IOException;

import org.springframework.core.io.ClassPathResource;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

import jakarta.servlet.http.HttpServletResponse;

@Controller
public class FaviconController {

    @GetMapping("/favicon.ico")
    public void favicon(HttpServletResponse response) throws IOException {
        ClassPathResource resource = new ClassPathResource("static/favicon.svg");
        response.setContentType("image/svg+xml");
        response.setHeader(HttpHeaders.CACHE_CONTROL, "public, max-age=604800");
        resource.getInputStream().transferTo(response.getOutputStream());
    }
}
