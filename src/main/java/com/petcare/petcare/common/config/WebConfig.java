/**
 * 역할: 정적 리소스 + 로컬 업로드 파일 URL 매핑, Interceptor 등록
 *
 * - 박유정 / 2026-07-07 — /upload/** → file.upload-dir (give/report 사진 서빙)
 * - 박유정 / 2026-07-22 — SuspendedMemberInterceptor 등록 (정지 회원 고객센터 외 차단)
 * - gcs.enabled=true 이면 /upload/** 는 UploadFileController(GCS)가 처리 — 2026/07/21 장우철
 */

package com.petcare.petcare.common.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import com.petcare.petcare.common.interceptor.SuspendedMemberInterceptor;
import com.petcare.petcare.common.interceptor.CsrfTokenInterceptor;
import com.petcare.petcare.common.interceptor.JoinDraftScopeInterceptor;
import com.petcare.petcare.common.interceptor.SecurityHeaderInterceptor;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    // mypage/biz 등 다른 패키지에서 webConfig.uploadDir 로 접근 → public 유지
    @Value("${file.upload-dir}")
    public String uploadDir;

    @Value("${gcs.enabled:false}")
    private boolean gcsEnabled;

    @Autowired
    private SuspendedMemberInterceptor suspendedMemberInterceptor; // 2026-07-22 박유정 — 정지 회원 Interceptor

    // 2026/07/27 장우철 — 가입 임시저장은 join/빌링 왕복에서만 유지
    @Autowired
    private JoinDraftScopeInterceptor joinDraftScopeInterceptor;

    //HYJ 26.08.06 보안적용
    @Autowired
    private CsrfTokenInterceptor csrfTokenInterceptor;
    @Autowired
    private SecurityHeaderInterceptor securityHeaderInterceptor;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/resources/**")
                .addResourceLocations("/resources/")
                .setCachePeriod(0);

        // [로컬 /upload 매핑 — gcs.enabled=false 일 때만] 2026/07/21 장우철
        if (!gcsEnabled) {
            String location = uploadDir.endsWith("/") ? uploadDir : uploadDir + "/";
            registry.addResourceHandler("/upload/**")
                    .addResourceLocations("file:" + location)
                    .setCachePeriod(0);
        }
    }

    // 2026-07-22 박유정 — 정지 회원 고객센터 외 접근 차단
    // 2026/07/27 장우철 — 가입 draft 는 join·billing 외 이동 시 폐기
    @Override
    public void addInterceptors(InterceptorRegistry registry) {

        //HYJ 26.08.06 add순서 중요! 보안쪽 제일 먼저
        registry.addInterceptor(securityHeaderInterceptor)
        .addPathPatterns("/**")
        .excludePathPatterns(
                "/resources/**",
                "/upload/**",
                "/favicon.ico"
        );

        registry.addInterceptor(csrfTokenInterceptor)
        .addPathPatterns("/**")
        .excludePathPatterns(
                "/resources/**",
                "/upload/**",
                "/favicon.ico",
                "/find/**"
        );  

        registry.addInterceptor(joinDraftScopeInterceptor)
                .addPathPatterns("/**")
                .excludePathPatterns(
                        "/resources/**",
                        "/upload/**",
                        "/favicon.ico"
                );

        registry.addInterceptor(suspendedMemberInterceptor)
                .addPathPatterns("/**")
                .excludePathPatterns(
                        "/login", "/join", "/join/**",
                        "/oauth/**",
                        "/admin/**",
                        "/resources/**",
                        "/upload/**",
                        "/favicon.ico"
                );
    }
}
