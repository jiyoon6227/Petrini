package com.petcare.petcare.hospital.vo;

import java.util.Date;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class HospitalDoctorVO {

    // 의사 VO
    private Long doctorId;
    private Long hospitalId;
    private String doctorName;
    private String specialty;
    private String statusCd;   // Y / N
    private Integer sortOrdr;
    private Date regDate;
}
