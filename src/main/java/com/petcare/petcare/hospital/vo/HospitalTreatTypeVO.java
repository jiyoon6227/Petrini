/**
 * 역할: 병원 진료유형 (TB_HOSPITAL_TREAT_TYPE)
 *
 * 참고 테이블: TB_HOSPITAL_TREAT_TYPE
 * DB 컬럼명은 팀 VO 규칙(camelCase)에 맞게 작성
 */
package com.petcare.petcare.hospital.vo;

import java.util.Date;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class HospitalTreatTypeVO {

    // 2026/07/16 장우철 고도화작업 — 진료유형 VO
    private Long treatTypeId;
    private Long hospitalId;
    private String typeName;
    private Integer durationMin;
    private String statusCd;   // Y / N
    private Integer sortOrdr;
    private Date regDate;
}
