/**
 * 역할: 마이페이지 포인트 비즈니스 로직 (interface)
 *
 * 담당 화면
 * - mypage/points.jsp         포인트
 *
 * 구현할 기능 예시
 * - 포인트 잔액·내역 조회
 *
 * 연결
 * - 구현: MypagePointServiceImpl
 * - 호출: MypagePointController
 * - DB: MypagePointMapper
 *
 * 참고 테이블
 * - TB_POINT
 * - TB_POINT_HISTORY
 */

package com.petcare.petcare.mypage.point.service;

import java.util.List;
import com.petcare.petcare.mypage.point.vo.MypagePointVO;

public interface MypagePointService {

    //지윤 26.07.29 추가: 보유 포인트 잔액
    int getPointBalance(Long memberNo);

    //지윤 26.07.29 추가: 이번 달 적립 합계
    int getThisMonthEarnedPoint(Long memberNo);

    //지윤 26.07.29 추가: 포인트 내역 목록
    List<MypagePointVO> getPointHistory(Long memberNo);
}
