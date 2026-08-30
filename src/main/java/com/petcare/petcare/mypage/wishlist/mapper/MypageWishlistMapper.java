/**
 * 역할: 마이페이지 찜 DB (TB_FAVORITE)
 * 2026/08/13 장우철
 */
package com.petcare.petcare.mypage.wishlist.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.mypage.wishlist.vo.MypageWishlistVO;

@Mapper
public interface MypageWishlistMapper {

    List<MypageWishlistVO> selectMyWishlist(@Param("memberNo") Long memberNo);

    List<String> selectMyWishKeys(@Param("memberNo") Long memberNo);

    int countFavorite(@Param("memberNo") Long memberNo,
                      @Param("favType") String favType,
                      @Param("targetId") Long targetId);

    int insertFavorite(MypageWishlistVO vo);

    int deleteFavorite(@Param("memberNo") Long memberNo,
                       @Param("favType") String favType,
                       @Param("targetId") Long targetId);
}
