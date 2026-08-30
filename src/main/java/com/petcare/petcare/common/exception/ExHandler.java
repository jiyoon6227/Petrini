/**
 * 역할: 전역 예외 처리 (@ControllerAdvice)
 *
 * - 박유정 / 2026-07-09
 *
 * [예외 처리 흐름]
 * 1. Ajax API 요청 (/like/toggle 등) → JSON "error" 반환
 * 2. 일반 페이지 요청 → redirect (커뮤니티는 /community?error=server)
 * 3. favicon / .well-known → 404 무시
 *
 * 수정 이유
 * - 기존: 모든 예외를 "error" 문자열로 반환 → 로그인 후 화면에 error 만 표시됨
 * - 변경: API 와 페이지 요청 분리 처리
 */

package com.petcare.petcare.common.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.resource.NoResourceFoundException;

import jakarta.servlet.http.HttpServletRequest;

@ControllerAdvice
public class ExHandler {

    @ExceptionHandler(NoResourceFoundException.class)
    public ResponseEntity<Void> handleNoResource(NoResourceFoundException e, HttpServletRequest request) {
        String uri = request.getRequestURI();
        String path = e.getResourcePath();
        if (uri.contains(".well-known")
                || uri.endsWith("/favicon.ico")
                || (path != null && path.endsWith("favicon.ico"))) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.notFound().build();
    }

    @ExceptionHandler(Exception.class)
    public Object handleException(Exception e, HttpServletRequest request) {
        String uri = request.getRequestURI();
        if (uri.contains(".well-known") || uri.endsWith("/favicon.ico")) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("not_found");
        }
    
        logException(e, request);
    
        if (isApiRequest(request)) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("error");
        }
    
        // redirect:/ 대신 에러 페이지 직접 반환 (무한 루프 방지)
        ModelAndView mav = new ModelAndView();
        if (uri.startsWith("/community")) {
            mav.setViewName("redirect:/community?error=server");
        } else {
            mav.setViewName("error/500");  // error/500.jsp를 만들어두거나
            mav.setStatus(HttpStatus.INTERNAL_SERVER_ERROR);
        }
        return mav;
    }

    private boolean isApiRequest(HttpServletRequest request) {
        String uri = request.getRequestURI();
        if (uri.contains("/like/toggle")
                || uri.contains("/join/check-email")
                || uri.contains("/cart/updateQty")
                || uri.contains("/cart/delete")
                || uri.contains("/cart/count")) {
            return true;
        }
        if ("XMLHttpRequest".equals(request.getHeader("X-Requested-With"))) {
            return true;
        }
        String accept = request.getHeader("Accept");
        return accept != null
                && accept.contains("application/json")
                && !accept.contains("text/html");
    }

    private void logException(Exception e, HttpServletRequest request) {
        System.out.println("===== 예외 발생 =====");
        System.out.println("요청 URL : " + request.getRequestURI());
        System.out.println("예외 메시지 : " + e.getMessage());
        StackTraceElement[] stackTrace = e.getStackTrace();
        for (StackTraceElement element : stackTrace) {
            if (element.getClassName().startsWith("com.petcare.petcare")) {
                System.out.println("오류 위치 : " + element.getClassName()
                        + "." + element.getMethodName()
                        + " (line " + element.getLineNumber() + ")");
                break;
            }
        }
        System.out.println("====================");
    }
}
