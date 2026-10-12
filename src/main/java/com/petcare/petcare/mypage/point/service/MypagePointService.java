package com.petcare.petcare.mypage.point.service;

import java.util.List;
import com.petcare.petcare.mypage.point.vo.MypagePointVO;

public interface MypagePointService {

    // 보유 포인트 잔액
    int getPointBalance(Long memberNo);

    // 이번 달 적립 합계
    int getThisMonthEarnedPoint(Long memberNo);

    // 포인트 내역 목록
    List<MypagePointVO> getPointHistory(Long memberNo);
}
