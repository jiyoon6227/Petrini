package com.petcare.petcare.mypage.home.mapper;

import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface MypageHomeMapper {

    // 이용중인 쿠폰 수 (미사용)
    int countUsableCoupon(Long memberNo);

    // 관심상품 수 (상품 찜)
    int countFavoriteProduct(Long memberNo);
}
