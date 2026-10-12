package com.petcare.petcare.mypage.reserve.vo;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public class StayReviewRegisterResult {

    private final Long reviewId;
    private final long earnedPoint;
    private final boolean pointEarned;
}
