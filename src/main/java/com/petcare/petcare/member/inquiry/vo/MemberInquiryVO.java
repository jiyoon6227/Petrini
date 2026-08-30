/**
 * 역할: TB_INQUIRY 매핑 VO (회원·관리자 공통)
 * 2026/07/31 장우철
 */
package com.petcare.petcare.member.inquiry.vo;

import java.util.Date;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MemberInquiryVO {
    private Long inquiryId;
    private String inquiryType; // MEMBER / RESERVE / ETC
    private Long memberNo;
    private String memberName;
    private String memberEmail;
    private Long petId;
    private String title;
    private String body;
    private String refType;     // RESV / ORDER
    private Long refId;
    private String statusCd;    // WAIT / ANSWER / DONE / APPROVED / REJECTED (숙소환불 B)
    private String answer;
    private Long adminNo;
    private Date applyDate;
    private Date answerDate;
    private Date regDate;

    // 숙소 환불 연계 표시용
    private String resvNo;
    private String stayName;
    private String resvStatusCd;
    private Long totalAmount;
}
