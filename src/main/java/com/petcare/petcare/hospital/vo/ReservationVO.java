package com.petcare.petcare.hospital.vo;

import java.util.Date;

import org.springframework.format.annotation.DateTimeFormat;

import com.fasterxml.jackson.annotation.JsonFormat;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReservationVO {

    // TB_RESERVATION 컬럼 (DATABASE_TABLE.sql 기준)
    private Long    resvId;
    private String  resvNo;
    private String  resvType;       // HOSPITAL / STAY / GROOMING / STUDIO
    private Long    memberNo;
    private Long    petId;
    private String  targetId;       // 병원 예약 시 HOSPITAL_ID (VARCHAR2)
    private Long    roomId;
    private String  serviceName;
    // 폼(yyyy-MM-dd) 바인딩용 DateTimeFormat (@JsonFormat 만으로는 MVC 변환 실패)
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    @JsonFormat(pattern = "yyyy-MM-dd", timezone = "Asia/Seoul")
    private Date    resvDate;
    private String  resvTime;
    // 병원 예약 고도화 (TB_RESERVATION TREAT_TYPE_ID·DOCTOR_ID·DURATION_MIN·END_TIME)
    private Long    treatTypeId;
    private Long    doctorId;
    private Integer durationMin;
    private String  endTime;
    private Long    holdId;       // 선점 ID (폼 전용, TB 미저장)
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private Date    checkinDate;
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private Date    checkoutDate;
    private Integer nightCnt;
    private String  symptoms;
    private String  requestMemo;
    private Long    totalAmount;
    private String  statusCd;       // PENDING / CONFIRMED / DONE / CANCEL / REJECTED
    private String  rejectReason;
    private Date    regDate;

    // 목록·상세·완료 화면 JOIN 표시용
    private String  memberName;
    private String  petName;
    private String  petSpecies;
    private String  petBreed;
    private Integer petAge;
    private String  hospitalName;  // 완료 화면 병원명 (H.NAME)
    private String  doctorName;    // JOIN 표시용 (D.DOCTOR_NAME)
    private String  treatTypeName; // JOIN 표시용 (T.TYPE_NAME)

    // 숙소용
    private String  stayName;
    private String  stayAddr;
    private String  roomName;
}