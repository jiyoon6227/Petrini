/** 조회 시점(목록/API)과 스케줄러(매일 자정) 양쪽에서 호출 */

package com.petcare.petcare.main.banner.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.main.banner.mapper.MainBannerMapper;

@Service
public class BannerExpiryService {

    @Autowired
    private MainBannerMapper mainBannerMapper;

    // 종료일이 지난 ACTIVE 배너를 EXPIRED로 변경
    @Transactional
    public int expirePastEndDateBanners() {
        return mainBannerMapper.expirePastEndDateBanners();
    }
}
