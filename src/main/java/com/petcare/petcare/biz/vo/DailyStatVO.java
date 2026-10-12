package com.petcare.petcare.biz.vo;

import lombok.Getter;
import lombok.Setter;

@Getter @Setter
public class DailyStatVO {
    private String dt;       // 'MM-DD' 형태
    private int resvCount;   // 해당 일 예약 건수 (전체, 취소 포함)
    private long revenue;    // 해당 일 매출 (숙소 등 결제 연동된 도메인용)
    private int doneCount;   // 진료완료 건수 (병원용)
    private int cancelCount; // 취소·노쇼 건수 (병원용)
}