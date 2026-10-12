package com.petcare.petcare.main.banner.scheduler;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.petcare.petcare.main.banner.service.BannerExpiryService;

@Component
public class BannerExpiryScheduler {

    private static final Logger log = LoggerFactory.getLogger(BannerExpiryScheduler.class);

    private final BannerExpiryService bannerExpiryService;

    public BannerExpiryScheduler(BannerExpiryService bannerExpiryService) {
        this.bannerExpiryService = bannerExpiryService;
    }

    @Scheduled(cron = "0 0 0 * * *") // 매일 00:00
    public void expirePastEndDateBanners() {
        log.info("=== 배너 자동 만료 스케줄러 시작 ===");
        int count = bannerExpiryService.expirePastEndDateBanners();
        log.info("=== 배너 자동 만료 스케줄러 완료: {}건 처리 ===", count);
    }
}
