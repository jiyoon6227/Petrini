package com.petcare.petcare.mypage.home.service;

public interface MypageHomeService {

    // 이용중인 쿠폰 수
    int countUsableCoupon(Long memberNo);

    // 관심상품 수
    int countFavoriteProduct(Long memberNo);
}
