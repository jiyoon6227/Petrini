package com.petcare.petcare.common.util;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

/* 컨트롤러 메서드 호출 파라미터·실행 시간·예외를 SLF4J로 자동 로깅 (System.out 대신 레벨·파일 관리) */
@Aspect
@Component
public class LoggingAspect {
    private static final Logger log = LoggerFactory.getLogger(LoggingAspect.class);

    /* 모든 컨트롤러 메서드 (..controller.. 하위 패키지 포함, service 패키지는 제외) */
    @Pointcut("execution(* com.petcare.petcare..controller..*(..))")
    public void controllerMethod(){}

    /**
     * 모든 서비스 메서드에 적용
     *
     * 서비스까지 로깅하고 싶으면 이 Pointcut 을 사용
     * (아래 @Around 에서 controllerMethod() 대신 이걸 참조하면 됨)
     */
    @Pointcut("execution(* com.petcare.petcare..service..*(..))")
    public void serviceMethod(){}

    // @Around pointcut 이름은 controllerMethod
    @Around("controllerMethod()")
    public Object logAround(ProceedingJoinPoint joinPoint) throws Throwable {
        // 메서드 정보 추출
        String className = joinPoint.getTarget().getClass().getSimpleName();
        // 예: "StoreShopController"

        String methodName = joinPoint.getSignature().getName();
        // 예: "addToCart"

        Object[] args = joinPoint.getArgs();
        // 예: [42, "7", 1, 15000, HttpSession@xxx]

        // 실행 전 로깅
        log.info("[요청] {}.{}() | 파라미터: {}",
                className, methodName, summarizeArgs(args));

        long startTime = System.currentTimeMillis();
        try {
            // 실제 메서드 실행
            Object result = joinPoint.proceed();

            // 실행 후 로깅
            long elapsed = System.currentTimeMillis() - startTime;
            log.info("[응답] {}.{}() | {}ms",
                    className, methodName, elapsed);

            return result;
        } 
        catch (Exception e) {
            // 예외 발생 시 로깅
            long elapsed = System.currentTimeMillis() - startTime;
            log.error("[에러] {}.{}() | {}ms | {}",
                    className, methodName, elapsed, e.getMessage());

            throw e;  // 예외를 다시 던져서 기존 예외 처리 흐름 유지
        }
    }
    
    /**
     * 파라미터 요약 — HttpSession, MultipartFile 등은 타입명만 표시
     *
     * 로그에 세션 객체 전체가 출력되면 가독성이 떨어지고,
     * 민감 정보(비밀번호 등)가 노출될 수 있으므로 요약 처리
     */
    private String summarizeArgs(Object[] args) {
        if (args == null || args.length == 0) {
            return "없음";
        }

        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < args.length; i++) {
            if (i > 0) {
                sb.append(", ");
            }

            if (args[i] == null) {
                sb.append("null");
            } else {
                String typeName = args[i].getClass().getSimpleName();
                // HttpSession, HttpServletRequest 등은 타입명만
                if (typeName.contains("Session")
                        || typeName.contains("Request")
                        || typeName.contains("Response")
                        || typeName.contains("Multipart")) {
                    sb.append("[").append(typeName).append("]");
                } else {
                    // 나머지는 toString() (너무 길면 자름)
                    String value = args[i].toString();
                    if (value.length() > 100) {
                        value = value.substring(0, 100) + "...";
                    }
                    sb.append(value);
                }
            }
        }
        return sb.toString();
    }
}
