/**
 * 역할: 병원 의사 (TB_HOSPITAL_DOCTOR)
 *
 * 참고 테이블: TB_HOSPITAL_DOCTOR
 * DB 컬럼명은 팀 VO 규칙(camelCase)에 맞게 작성
 */
package com.petcare.petcare.hospital.vo;

import java.util.Date;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class HospitalDoctorVO {

    // 2026/07/16 장우철 고도화작업 — 의사 VO
    private Long doctorId;
    private Long hospitalId;
    private String doctorName;
    private String specialty;
    private String statusCd;   // Y / N
    private Integer sortOrdr;
    private Date regDate;
}
