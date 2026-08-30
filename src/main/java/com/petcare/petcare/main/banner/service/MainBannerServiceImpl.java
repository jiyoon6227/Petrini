/**
 * 역할: MainBannerService 구현체 (@Service)
 *
 * 구현 내용
 * - Controller에서 넘어온 요청 처리
 * - Mapper 호출하여 DB 조회·수정
 * - 비즈니스 규칙 검증 및 결과 반환
 *
 * 연결
 * - implements: MainBannerService
 * - 사용: MainBannerMapper
 *
 * 비즈니스 로직은 여기에 작성 (Controller, Mapper에 직접 작성 X)
 *
 * 2026-08-06 박유정 — API 조회 전 종료일 경과 배너 EXPIRED 처리
 * 2026-08-07 박유정 — 위치별 maxCount (MAIN_MID 1건, Oracle ROWNUM)
 */

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

    // ── 사용자: 위치별 활성 배너 ──
    @Override
    public List<MainBannerVO> getBannersByPosition(String positionCd) {
        // 2026-08-06 박유정 — 종료일 지난 배너 상태 동기화 후 조회
        bannerExpiryService.expirePastEndDateBanners();
        // 2026-08-07 박유정 — 위치별 최대 노출 수 (MAIN_MID 1건)
        int maxCount = BannerConstants.getMaxPerPosition(positionCd);
        List<MainBannerVO> result = mainBannerMapper.selectActiveBannersByPosition(
                positionCd, maxCount);
        return result;
    }
}
