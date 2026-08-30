/**
 * 2026/08/13 장우철 — 찜 토글 (있으면 삭제, 없으면 INSERT)
 */
package com.petcare.petcare.mypage.wishlist.service;

import java.util.Collections;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.petcare.petcare.mypage.wishlist.mapper.MypageWishlistMapper;
import com.petcare.petcare.mypage.wishlist.vo.MypageWishlistVO;

@Service
public class MypageWishlistServiceImpl implements MypageWishlistService {

    @Autowired
    private MypageWishlistMapper mypageWishlistMapper;

    @Override
    public List<MypageWishlistVO> getMyWishlist(Long memberNo) {
        if (memberNo == null) {
            return Collections.emptyList();
        }
        return mypageWishlistMapper.selectMyWishlist(memberNo);
    }

    @Override
    public List<String> getMyWishKeys(Long memberNo) {
        if (memberNo == null) {
            return Collections.emptyList();
        }
        return mypageWishlistMapper.selectMyWishKeys(memberNo);
    }

    @Override
    public boolean toggle(Long memberNo, String favType, Long targetId) {
        if (memberNo == null || favType == null || targetId == null) {
            throw new IllegalArgumentException("찜 정보가 올바르지 않습니다.");
        }
        String type = normalizeType(favType);
        if (mypageWishlistMapper.countFavorite(memberNo, type, targetId) > 0) {
            mypageWishlistMapper.deleteFavorite(memberNo, type, targetId);
            return false;
        }
        MypageWishlistVO vo = new MypageWishlistVO();
        vo.setMemberNo(memberNo);
        vo.setFavType(type);
        vo.setTargetId(targetId);
        mypageWishlistMapper.insertFavorite(vo);
        return true;
    }

    static String normalizeType(String favType) {
        String u = favType.trim().toUpperCase();
        if ("STORE".equals(u) || "PRODUCT".equals(u)) {
            return "PRODUCT";
        }
        if ("STAY".equals(u) || "HOTEL".equals(u) || "LODGE".equals(u)) {
            return "LODGE";
        }
        if ("HOSPITAL".equals(u)) {
            return "HOSPITAL";
        }
        throw new IllegalArgumentException("지원하지 않는 찜 유형입니다.");
    }
}
