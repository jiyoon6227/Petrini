package com.petcare.petcare.mypage.wishlist.service;

import java.util.List;

import com.petcare.petcare.mypage.wishlist.vo.MypageWishlistVO;

public interface MypageWishlistService {

    List<MypageWishlistVO> getMyWishlist(Long memberNo);

    List<String> getMyWishKeys(Long memberNo);

    /** @return true면 찜된 상태, false면 해제 */
    boolean toggle(Long memberNo, String favType, Long targetId);
}
