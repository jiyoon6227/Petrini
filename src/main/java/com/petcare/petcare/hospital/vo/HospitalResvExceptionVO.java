/**
 * 역할: 병원 예약예외 (TB_HOSPITAL_RESV_EXCEPTION)
 *
 * 참고 테이블: TB_HOSPITAL_RESV_EXCEPTION, TB_HOSPITAL_DOCTOR
 * DB 컬럼명은 팀 VO 규칙(camelCase)에 맞게 작성
 */
package com.petcare.petcare.hospital.vo;

import java.util.Date;

import org.springframework.format.annotation.DateTimeFormat;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class HospitalResvExceptionVO {

    // 2026/07/16 장우철 고도화작업 — 예약예외 VO
    private Long excId;
    private Long hospitalId;
    private Long doctorId;       // null = 공통
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private Date excDate;
    private String excType;      // CLOSE / REPLACE
    private String startTime;
    private String endTime;
    private Integer intervalMin;
    private String memo;
    private String statusCd;     // Y / N
    private Date regDate;

    // JOIN / 화면용
    private String doctorName;
    private String excDateStr;   // yyyy-MM-dd
}
