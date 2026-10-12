package com.petcare.petcare.common.config;


import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.Configuration;

/**
 * Spring Cache 활성화 (공공 API 등 응답 캐싱)
 */
@Configuration
@EnableCaching   // 캐시 활성화
public class CacheConfig {
}
