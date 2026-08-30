package com.petcare.petcare.coupon.service;

import java.util.List;

import com.petcare.petcare.store.vo.CouponVO;
import com.petcare.petcare.store.vo.StoreShopVO;

public interface CouponService {

    // 받을 수 있는 쿠폰 목록
    List<CouponVO> getAvailableCoupons(Long memberNo, String today);

    // 보유 쿠폰 목록
    List<CouponVO> getMyCoupons(Long memberNo);

    // 사용 가능 보유 쿠폰 개수
    int countUsableCoupons(Long memberNo);

    // 쿠폰 받기
    void claimCoupon(Long memberNo, Long couponId);

    // 지윤 26.08.06: 쿠폰과 발급 사업자 정보 조회
    CouponVO getCouponTarget(Long couponId);

    // 지윤 26.08.06: 쿠폰 적용 상품 검색 및 정렬
    List<StoreShopVO> getCouponProducts(
    String bizNo,
    String sort,
    String keyword
);
}
