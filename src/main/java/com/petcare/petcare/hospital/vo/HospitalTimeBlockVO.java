package com.petcare.petcare.hospital.vo;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class HospitalTimeBlockVO {

    // [startTime, endTime) 점유
    private String startTime;
    private String endTime;
    private Long holdId;
}
