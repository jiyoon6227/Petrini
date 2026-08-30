/**
 * 역할: 마이페이지 홈 비즈니스 로직 (interface)
 *
 * 2026/07/08 장우철 — 마이페이지 B단계
 * - 마이홈 대시보드 요약 (쿠폰·관심상품 COUNT)
 *
 * 참고 테이블
 * - TB_MEMBER_COUPON (STATUS_CD: UNUSED / USED / EXPIRED)
 * - TB_FAVORITE (FAV_TYPE: PRODUCT / HOSPITAL / STAY / POI)
 */

package com.petcare.petcare.mypage.home.service;

public interface MypageHomeService {

    // 2026/07/08 장우철 — 이용중인 쿠폰 수
    int countUsableCoupon(Long memberNo);

    // 2026/07/08 장우철 — 관심상품 수
    int countFavoriteProduct(Long memberNo);
}
