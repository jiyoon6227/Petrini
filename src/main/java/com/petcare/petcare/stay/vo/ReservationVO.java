package com.petcare.petcare.stay.vo;

import java.util.Date;

import org.springframework.format.annotation.DateTimeFormat;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReservationVO {
    private Long    resvId;
    private String  resvNo;
    private String  resvType;       // HOSPITAL / STAY / GROOMING / STUDIO
    private Long    memberNo;
    private Long    petId;
    // 2026/08/11 장우철 — 숙소 다펫: 대표 PET_ID + 마리수
    private Integer petCnt;
    private String  targetId;
    private Long    roomId;
    private String  serviceName;

    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private Date    resvDate;
    private String  resvTime;

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

    private String  memberName;
    private String  petName;
    private String  petSpecies;
    private String  petBreed;
    private Integer petAge;

    private String  stayName;
    private String  stayAddr;
    private String  roomName;

    // 지윤 26.08.07: 쿠폰 적용 결제
    private Long    memberCouponId;
    private Long    couponDiscount;
    // 지윤 26.08.07: 결제 완료 화면에 정확한 실결제금액 표시용
    private Long    pointUsed;
}
