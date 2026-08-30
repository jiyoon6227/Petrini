/**
 * 역할: 예약·선점 점유 구간 (가능시간 계산용)
 */
package com.petcare.petcare.hospital.vo;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class HospitalTimeBlockVO {

    // 2026/07/16 장우철 — [startTime, endTime) 점유
    private String startTime;
    private String endTime;
    private Long holdId;
}
