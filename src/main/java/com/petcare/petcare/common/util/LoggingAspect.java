package com.petcare.petcare.common.util;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

/*
 * 역할: AOP 로 컨트롤러·서비스 메서드의 실행 정보를 자동 로깅
 * 
 * [AOP(Aspect-Oriented Programming) 란]
 * 여러 클래스에 공통으로 적용되는 기능(로깅, 트랜잭션, 보안 등)을
 * 각 클래스에 코드를 넣지 않고, 별도 클래스에서 한 번에 처리하는 기법
 * 
 * [왜 AOP 로깅을 하는가]
 * - System.out.println 은 콘솔에만 출력되고, 로그 파일에 남지 않음
 * - 로그 레벨(DEBUG/INFO/WARN/ERROR) 구분이 안 됨
 * - 운영 환경에서 System.out 은 성능 저하 원인 (동기 I/O)
 * - SLF4J + Logback 은 로그 파일 자동 분할, 레벨별 필터링, 비동기 처리 지원
 * 
 * [이 클래스가 하는 일]
 * 1. 모든 Controller 메서드 호출 시 → 어떤 메서드가 어떤 파라미터로 호출됐는지 로깅
 * 2. 메서드 실행 완료 시 → 실행 시간(ms) 로깅
 * 3. 예외 발생 시 → 에러 로그 자동 기록
 *
 * [적용 범위 — Pointcut]
 * - com.petcare.petcare.*.controller..* → 모든 도메인의 컨트롤러
 * - com.petcare.petcare..*.controller..* → 하위 패키지의 컨트롤러도 포함
 *   (예: store.controller, community.post.controller 등)
 */
@Aspect
@Component
public class LoggingAspect {
    private static final Logger log = LoggerFactory.getLogger(LoggingAspect.class);

    /*
     * 모든 컨트롤러 메서드에 적용
     * execution(* com.petcare.petcare..controller..*(..))
     *         │  └─ 패키지 경로 (.. = 하위 패키지 포함)
     *         └─ 반환 타입 (* = 모든 타입)
     * 
     * 매칭 예시:
     *   ✅ StoreShopController.addToCart()
     *   ✅ CommunityPostController.writeSubmit()
     *   ✅ AdminMemberController.list()
     *   ❌ StoreShopServiceImpl.addToCart() → service 는 매칭 안 됨
     */
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

    // 2026/08/10 장우철 — @Around pointcut 이름 불일치(controllerMethods → controllerMethod) 수정
    @Around("controllerMethod()")
    public Object logAround(ProceedingJoinPoint joinPoint) throws Throwable {
        // ── 메서드 정보 추출 ──
        String className = joinPoint.getTarget().getClass().getSimpleName();
        // 예: "StoreShopController"

        String methodName = joinPoint.getSignature().getName();
        // 예: "addToCart"

        Object[] args = joinPoint.getArgs();
        // 예: [42, "7", 1, 15000, HttpSession@xxx]

        // ── 실행 전 로깅 ──
        log.info("[요청] {}.{}() | 파라미터: {}",
                className, methodName, summarizeArgs(args));

        long startTime = System.currentTimeMillis();
        try {
            // ── 실제 메서드 실행 ──
            Object result = joinPoint.proceed();

            // ── 실행 후 로깅 ──
            long elapsed = System.currentTimeMillis() - startTime;
            log.info("[응답] {}.{}() | {}ms",
                    className, methodName, elapsed);

            return result;
        } 
        catch (Exception e) {
            // ── 예외 발생 시 로깅 ──
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
