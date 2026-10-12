package com.petcare.petcare.hospital.vo;

import java.util.Date;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class HospitalTreatTypeVO {

    // 진료유형 VO
    private Long treatTypeId;
    private Long hospitalId;
    private String typeName;
    private Integer durationMin;
    private String statusCd;   // Y / N
    private Integer sortOrdr;
    private Date regDate;
}
