package com.petcare.petcare.mypage.reserve.service;

import java.util.HashMap;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.mypage.reserve.mapper.MypageReserveMapper;

/**
 * 2026-07-28 박유정 — 리뷰 포인트 적립 (별도 트랜잭션)
 * 리뷰 INSERT와 분리해 TB_POINT 락이 리뷰 등록을 막지 않게 함
 */
@Service
public class MypageReservePointService {

    private static final Logger log = LoggerFactory.getLogger(MypageReservePointService.class);

    @Autowired
    private MypageReserveMapper mypageReserveMapper;

    @Transactional(propagation = Propagation.REQUIRES_NEW, timeout = 10)
    public boolean earnStayReviewPoint(Long memberNo, long pointAmount, Long reviewId,
                                       long currentBalance) {
        if (memberNo == null || pointAmount <= 0 || reviewId == null) {
            return false;
        }
        try {
            Map<String, Object> balanceParam = new HashMap<>();
            balanceParam.put("memberNo", memberNo);
            balanceParam.put("pointAmount", pointAmount);
            mypageReserveMapper.addMemberPointBalance(balanceParam);

            long balanceAfter = currentBalance + pointAmount;

            Map<String, Object> pointParam = new HashMap<>();
            pointParam.put("memberNo", memberNo);
            pointParam.put("pointAmount", pointAmount);
            pointParam.put("balanceAfter", balanceAfter);
            pointParam.put("refType", "STAY_REVIEW");
            pointParam.put("refId", String.valueOf(reviewId));
            mypageReserveMapper.insertReviewPoint(pointParam);
            return true;
        } catch (Exception e) {
            log.warn("숙소 리뷰 포인트 적립 실패: memberNo={}, reviewId={}", memberNo, reviewId, e);
            return false;
        }
    }
}
