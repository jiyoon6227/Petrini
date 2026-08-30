/**
 * 역할: 병원 예약 임시 선점 (TB_HOSPITAL_RESV_HOLD)
 *
 * 참고 테이블: TB_HOSPITAL_RESV_HOLD
 */
package com.petcare.petcare.hospital.vo;

import java.util.Date;

import org.springframework.format.annotation.DateTimeFormat;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class HospitalResvHoldVO {

    // 2026/07/16 장우철 — 펫 단계 이동 시 시간 선점
    private Long holdId;
    private Long hospitalId;
    private Long doctorId;
    private Long treatTypeId;
    private Long memberNo;
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private Date resvDate;
    private String resvTime;
    private Integer durationMin;
    private String endTime;
    private Date expireDate;
    private Date regDate;
}
