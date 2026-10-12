package com.petcare.petcare.mypage.point.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import com.petcare.petcare.mypage.point.vo.MypagePointVO;

@Mapper
public interface MypagePointMapper {

    // 마이페이지 상단 "보유 포인트" 카드용 - 현재 잔액
    int selectPointBalance(@Param("memberNo") Long memberNo);

    // "이번 달 적립" 카드용 - 이번 달에 EARN(적립)된 합계 (REFUND는 제외)
    int selectThisMonthEarnedPoint(@Param("memberNo") Long memberNo);

    // 포인트 내역 테이블 (최신순)
    List<MypagePointVO> selectPointHistory(@Param("memberNo") Long memberNo);
}