package com.petcare.petcare.settlement.vo;

import java.util.Date;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@ToString
@NoArgsConstructor
public class StaySettlementRequestVO {

    private Long requestId;              // 요청 ID (PK)
    private Long bizNo;                  // 요청 사업자번호

    private String requestScope;         // 요청범위 (ALL/ROOM/PRODUCT)
    private Long roomId;                 // 객실 ID (ROOM일 때)
    private Long productId;              // 상품 ID (PRODUCT일 때, 쇼핑)

    private Date targetStart;            // 요청 대상 시작일
    private Date targetEnd;              // 요청 대상 종료일

    private String statusCd;             // 요청상태 (REQUESTED/APPROVED/REJECTED/CANCELED)

    private String requestMemo;          // 사업자 요청 메모
    private String rejectReason;         // 관리자 거절 사유

    private Date requestedAt;            // 요청일시
    private Date approvedAt;             // 승인일시
    private Date rejectedAt;             // 거절일시
}
