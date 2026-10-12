package com.petcare.petcare.admin.reservation.vo;

import java.util.Date;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AdminStayReservationVO {
    private Long resvId;
    private String resvNo;
    private String resvType;
    private Long memberNo;
    private String memberName;
    private String memberEmail;
    private String targetId;
    private Long stayId;
    private String stayName;
    private String roomName;
    private Date checkinDate;
    private Date checkoutDate;
    private Integer nightCnt;
    private Long totalAmount;
    private String statusCd;
    private String rejectReason;
    private Long cancelFeeAmt;
    private Long refundAmt;
    private Date cancelAt;
    private Date regDate;
    private String petName;
    // 결제수단·결제일 (TB_PAYMENT)
    private String payMethod;
    private Date payDate;
}
