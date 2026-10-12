package com.petcare.petcare.mypage.home.service;

import com.petcare.petcare.mypage.home.mapper.MypageHomeMapper;
import org.springframework.stereotype.Service;

@Service
public class MypageHomeServiceImpl implements MypageHomeService {

    private final MypageHomeMapper mypageHomeMapper;

    public MypageHomeServiceImpl(MypageHomeMapper mypageHomeMapper) {
        this.mypageHomeMapper = mypageHomeMapper;
    }

    // 이용중인 쿠폰 = STATUS_CD 'UNUSED' (1회성 미사용)
    @Override
    public int countUsableCoupon(Long memberNo) {
        if (memberNo == null) {
            return 0;
        }
        return mypageHomeMapper.countUsableCoupon(memberNo);
    }

    // 관심상품 = TB_FAVORITE 상품 찜만
    @Override
    public int countFavoriteProduct(Long memberNo) {
        if (memberNo == null) {
            return 0;
        }
        return mypageHomeMapper.countFavoriteProduct(memberNo);
    }
}
