/**
 * 역할: 정산 상세 (TB_SETTLEMENT_ITEM) — 쇼핑=주문상품 1건
 * 2026/08/04 장우철 — 쇼핑 정산 S8 VO
 *
 * 참고 테이블: TB_SETTLEMENT_ITEM
 * 중복방지: UX_SETTLE_ITEM_ORDER_ITEM
 */
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
public class StoreSettlementItemVO {

    private Long settleItemId;
    private Long settleId;

    // 숙소용 (쇼핑 단계에서는 null)
    private Long resvId;
    private Long roomId;
    private Date checkinDate;
    private Date checkoutDate;
    private Long resvAmount;

    // 쇼핑용
    private Long orderId;
    private Long orderItemId;
    private Long productId;
    private Date confirmedAt;
    private Long itemSalesAmount;
    private Long deliveryFeeAmount;
    private Long returnFeeAmount;
    private String returnFeePayer;

    private Double feeRate;
    private Long feeAmount;
    private Long settleAmount;

    private String statusCd;             // INCLUDED / HOLD / EXCLUDED / REFUNDED
    private String holdReason;
    private String itemType;             // ORDER_ITEM

    private Date regDate;

    // 조회 표시용 (JOIN)
    private String orderNo;
    private String productName;
}
