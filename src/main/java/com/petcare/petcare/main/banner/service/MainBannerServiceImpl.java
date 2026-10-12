package com.petcare.petcare.main.banner.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.petcare.petcare.main.banner.BannerConstants;
import com.petcare.petcare.main.banner.mapper.MainBannerMapper;
import com.petcare.petcare.main.banner.service.BannerExpiryService;
import com.petcare.petcare.main.banner.vo.MainBannerVO;

@Service
public class MainBannerServiceImpl implements MainBannerService {
    @Autowired 
    MainBannerMapper mainBannerMapper;

    @Autowired
    BannerExpiryService bannerExpiryService;

    // 사용자: 위치별 활성 배너
    @Override
    public List<MainBannerVO> getBannersByPosition(String positionCd) {
        // 종료일 지난 배너 상태 동기화 후 조회
        bannerExpiryService.expirePastEndDateBanners();
        // 위치별 최대 노출 수 (MAIN_MID 1건)
        int maxCount = BannerConstants.getMaxPerPosition(positionCd);
        List<MainBannerVO> result = mainBannerMapper.selectActiveBannersByPosition(
                positionCd, maxCount);
        return result;
    }
}
