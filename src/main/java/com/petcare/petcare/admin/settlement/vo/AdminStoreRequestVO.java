/**
 * 역할: 관리자 쇼핑 중간정산 요청 목록용 VO
 * 2026/08/05 장우철 — 쇼핑 정산 S11
 *
 * TB_SETTLEMENT_REQUEST + TB_BUSINESS(+상품명) JOIN
 */
package com.petcare.petcare.admin.settlement.vo;

import java.util.Date;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@ToString
@NoArgsConstructor
public class AdminStoreRequestVO {

    private Long requestId;
    private Long bizNo;
    private String bizName;
    private String requestScope;   // ALL / PRODUCT
    private Long productId;
    private String productName;
    private Date targetStart;
    private Date targetEnd;
    private String statusCd;       // REQUESTED / APPROVED / REJECTED / CANCELED
    private String requestMemo;
    private String rejectReason;
    private Date requestedAt;
    private Date approvedAt;
    private Date rejectedAt;
}
