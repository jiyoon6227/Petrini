package com.petcare.petcare.mypage.reserve.vo;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

/**
 * 2026-07-28 박유정 — 숙소 리뷰 등록 결과 (포인트 적립 포함)
 */
@Getter
@RequiredArgsConstructor
public class StayReviewRegisterResult {

    private final Long reviewId;
    private final long earnedPoint;
    private final boolean pointEarned;
}
