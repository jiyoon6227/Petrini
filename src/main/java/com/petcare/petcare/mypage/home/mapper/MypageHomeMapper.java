/**
 * 역할: 마이페이지 홈 DB 접근 (MyBatis interface)
 *
 * XML: resources/mybatis/mapper/mypage/home/MypageHomeMapper.xml
 * namespace: com.petcare.petcare.mypage.home.mapper.MypageHomeMapper
 *
 * 2026/07/08 장우철 — 마이페이지 B단계
 * - countUsableCoupon   : TB_MEMBER_COUPON (STATUS_CD = UNUSED)
 * - countFavoriteProduct: TB_FAVORITE (FAV_TYPE = PRODUCT)
 *
 * SQL은 XML에만 작성 (@Select 등 어노테이션 사용 X)
 */

package com.petcare.petcare.mypage.home.mapper;

import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface MypageHomeMapper {

    // 2026/07/08 장우철 — 이용중인 쿠폰 수 (미사용)
    int countUsableCoupon(Long memberNo);

    // 2026/07/08 장우철 — 관심상품 수 (상품 찜)
    int countFavoriteProduct(Long memberNo);
}
