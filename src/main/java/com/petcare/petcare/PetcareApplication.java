package com.petcare.petcare;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.scheduling.annotation.EnableScheduling;

// 2026-07-21 박유정 — 기간 정지 만료 스케줄러 활성화 (MemberSuspendScheduler)
@EnableScheduling
@SpringBootApplication
public class PetcareApplication extends SpringBootServletInitializer {

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(PetcareApplication.class);
    }

    public static void main(String[] args) {
        SpringApplication.run(PetcareApplication.class, args);
    }
}
