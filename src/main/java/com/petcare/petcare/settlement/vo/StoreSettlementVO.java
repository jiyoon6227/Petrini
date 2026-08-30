/**
 * 역할: 정산 마스터 (TB_SETTLEMENT) — 쇼핑(STORE) 매핑
 * 2026/08/04 장우철 — 쇼핑 정산 S8 VO
 *
 * 참고 테이블: TB_SETTLEMENT (BIZ_TYPE=STORE)
 */
package com.petcare.petcare.settlement.vo;

import java.util.Date;
import java.util.List;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@ToString
@NoArgsConstructor
public class StoreSettlementVO {

    private Long settleId;
    private Long bizNo;
    private Long requestId;
    private Long resvId;                 // 쇼핑은 null

    private String settleType;
    private String bizType;              // STORE
    private String settleStatus;         // PENDING / PAID 등
    private String payStatus;            // WAIT / DONE / FAIL
    private String requestType;          // REGULAR / ADHOC
    private String requestScope;         // ALL / PRODUCT

    private String settleMonth;          // YYYY-MM (구매확정월)
    private Date periodStart;
    private Date periodEnd;
    private Long roomId;                 // 쇼핑 null
    private Long productId;              // PRODUCT 중간정산 시

    private Long payAmount;
    private Double feeRate;
    private Long feeAmount;
    private Long totalSales;
    private Long totalFee;
    private Long settleAmount;
    private Long annualFee;
    private Long productSalesAmount;     // 상품매출 합 (택배 제외)
    private Long deliveryFeeAmount;      // 택배비 합 (패스스루)
    private Long returnFeeAmount;

    private Date regDate;
    private Date applyDate;
    private Date payDate;
    private Date requestedAt;
    private Date approvedAt;
    private String rejectReason;

    private List<StoreSettlementItemVO> items;
}
