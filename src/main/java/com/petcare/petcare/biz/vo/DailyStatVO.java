package com.petcare.petcare.biz.vo;

import lombok.Getter;
import lombok.Setter;

/**
 * 일별 통계 1행 (차트 데이터용)
 * MyBatis resultType으로 사용
 */
@Getter @Setter
public class DailyStatVO {
    private String dt;       // 'MM-DD' 형태
    private int resvCount;   // 해당 일 예약 건수 (전체, 취소 포함)
    private long revenue;    // 해당 일 매출 (숙소 등 결제 연동된 도메인용)
    private int doneCount;   // 지윤 26.08.13 추가: 진료완료 건수 (병원용)
    private int cancelCount; // 지윤 26.08.13 추가: 취소·노쇼 건수 (병원용)
}