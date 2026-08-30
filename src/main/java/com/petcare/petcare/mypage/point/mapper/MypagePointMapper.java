/**
 * 역할: 마이페이지 포인트 DB 접근 (MyBatis interface)
 *
 * XML: resources/mybatis/mapper/mypage/point/MypagePointMapper.xml
 * namespace: com.petcare.petcare.mypage.point.mapper.MypagePointMapper
 *
 * 쿼리 예시
 * - selectPointBalance
 * - selectPointHistory
 *
 * 참고 테이블
 * - TB_POINT
 * - TB_POINT_HISTORY
 *
 * SQL은 XML에만 작성 (@Select 등 어노테이션 사용 X)
 * 메서드명은 Service에서 호출하는 이름과 동일하게
 */

package com.petcare.petcare.mypage.point.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import com.petcare.petcare.mypage.point.vo.MypagePointVO;

@Mapper
public interface MypagePointMapper {

    //지윤 26.07.29 추가: 마이페이지 상단 "보유 포인트" 카드용 - 현재 잔액
    int selectPointBalance(@Param("memberNo") Long memberNo);

    //지윤 26.07.29 추가: "이번 달 적립" 카드용 - 이번 달에 EARN(적립)된 합계 (REFUND는 제외)
    int selectThisMonthEarnedPoint(@Param("memberNo") Long memberNo);

    //지윤 26.07.29 추가: 포인트 내역 테이블 (최신순)
    List<MypagePointVO> selectPointHistory(@Param("memberNo") Long memberNo);
}