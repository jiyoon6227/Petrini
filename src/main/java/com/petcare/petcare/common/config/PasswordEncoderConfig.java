package com.petcare.petcare.common.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

@Configuration
public class PasswordEncoderConfig {

    /**
     * PasswordEncoder Bean 등록
     * → MemberAuthServiceImpl 생성자 주입으로 사용
     * MypageAccountServiceImpl 등 BCryptPasswordEncoder 직접 주입 대응
     */
    @Bean
    public BCryptPasswordEncoder bCryptPasswordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public PasswordEncoder passwordEncoder(BCryptPasswordEncoder bCryptPasswordEncoder) {
        return bCryptPasswordEncoder;
    }
}
