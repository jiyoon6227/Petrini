/**
 * 역할: 배너 종료일 경과 자동 만료 처리
 *
 * 2026-08-06 박유정
 * - END_DATE < 오늘 인 ACTIVE 배너 → STATUS_CD = EXPIRED
 * - 조회 시점(목록/API) 및 스케줄러에서 호출
 *
 * 연결
 * - MainBannerMapper.expirePastEndDateBanners()
 * - BannerExpiryScheduler (매일 자정)
 */

package com.petcare.petcare.main.banner.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.main.banner.mapper.MainBannerMapper;

@Service
public class BannerExpiryService {

    @Autowired
    private MainBannerMapper mainBannerMapper;

    // 2026-08-06 박유정 — 종료일이 지난 ACTIVE 배너를 EXPIRED로 변경
    @Transactional
    public int expirePastEndDateBanners() {
        return mainBannerMapper.expirePastEndDateBanners();
    }
}
