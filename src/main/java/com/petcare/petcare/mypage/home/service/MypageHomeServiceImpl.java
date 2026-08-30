/**
 * 역할: MypageHomeService 구현체 (@Service)
 *
 * 2026/07/08 장우철 — 마이페이지 B단계
 * - Controller 요청 → Mapper COUNT 조회 → JSP 전달
 */

package com.petcare.petcare.mypage.home.service;

import com.petcare.petcare.mypage.home.mapper.MypageHomeMapper;
import org.springframework.stereotype.Service;

@Service
public class MypageHomeServiceImpl implements MypageHomeService {

    private final MypageHomeMapper mypageHomeMapper;

    public MypageHomeServiceImpl(MypageHomeMapper mypageHomeMapper) {
        this.mypageHomeMapper = mypageHomeMapper;
    }

    // 2026/07/08 장우철 — 이용중인 쿠폰 = STATUS_CD 'UNUSED' (1회성 미사용)
    @Override
    public int countUsableCoupon(Long memberNo) {
        if (memberNo == null) {
            return 0;
        }
        return mypageHomeMapper.countUsableCoupon(memberNo);
    }

    // 2026/07/08 장우철 — 관심상품 = TB_FAVORITE 상품 찜만
    @Override
    public int countFavoriteProduct(Long memberNo) {
        if (memberNo == null) {
            return 0;
        }
        return mypageHomeMapper.countFavoriteProduct(memberNo);
    }
}
