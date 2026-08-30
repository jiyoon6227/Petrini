package com.petcare.petcare.mypage.reserve.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.mypage.reserve.mapper.MypageReserveMapper;

/**
 * 2026-07-28 박유정 — 숙소 평점 요약 갱신 (리뷰 INSERT와 분리)
 */
@Service
public class MypageReserveRatingService {

    private static final Logger log = LoggerFactory.getLogger(MypageReserveRatingService.class);

    @Autowired
    private MypageReserveMapper mypageReserveMapper;

    @Transactional(propagation = Propagation.REQUIRES_NEW, timeout = 10)
    public void refreshHospitalRating(Long hospitalId) {
        if (hospitalId == null) {
            return;
        }
        try {
            mypageReserveMapper.updateHospitalRatingSummary(hospitalId);
        } catch (Exception e) {
            log.warn("병원 평점 요약 갱신 실패: hospitalId={}", hospitalId, e);
        }
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW, timeout = 10)
    public void refreshStayRating(Long stayId) {
        if (stayId == null) {
            return;
        }
        try {
            mypageReserveMapper.updateStayRatingSummary(stayId);
        } catch (Exception e) {
            log.warn("숙소 평점 요약 갱신 실패: stayId={}", stayId, e);
        }
    }
}
