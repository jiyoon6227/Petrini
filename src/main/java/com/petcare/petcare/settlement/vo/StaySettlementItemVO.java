/**
 * 역할: 정산 상세 (TB_SETTLEMENT_ITEM) — 숙소=예약 1건 / 쇼핑=주문상품 1건
 * 2026/07/30 장우철 — 숙소 정산 구현순서 1-2 VO
 *
 * 참고 테이블: TB_SETTLEMENT_ITEM
 * 중복방지: UX_SETTLE_ITEM_RESV / UX_SETTLE_ITEM_ORDER_ITEM
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
public class StaySettlementItemVO {

    private Long settleItemId;           // 정산상세 ID (PK)
    private Long settleId;               // 정산마스터 ID (TB_SETTLEMENT)

    // ----- 숙소용 -----
    private Long resvId;                 // 예약 ID
    private Long roomId;                 // 객실 ID
    private Date checkinDate;            // 체크인 날짜
    private Date checkoutDate;           // 체크아웃 날짜
    private Long resvAmount;             // 예약 원금(숙소)

    // ----- 쇼핑용 (숙소 구현 단계에서는 보통 null) -----
    private Long orderId;                // 주문 ID
    private Long orderItemId;            // 주문상품 ID (중복정산 방지 핵심)
    private Long productId;              // 상품 ID
    private Date confirmedAt;            // 구매확정 시각
    private Long itemSalesAmount;        // 상품매출 (택배 제외)
    private Long deliveryFeeAmount;      // 이 건 배송비
    private Long returnFeeAmount;        // 반품 택배비
    private String returnFeePayer;       // 반품택배비 부담자 (USER/BIZ)

    // ----- 공통 계산/상태 -----
    private Double feeRate;              // 건별 수수료율(%)
    private Long feeAmount;              // 건별 수수료
    private Long settleAmount;           // 건별 실정산금

    private String statusCd;             // 상세상태 (INCLUDED/HOLD/EXCLUDED/REFUNDED)
    private String holdReason;           // 보류/제외 사유
    // 2026/07/31 장우철 — STAY(숙박완료) / CANCEL_FEE(취소수수료·위약금)
    private String itemType;

    private Date regDate;                // 등록일

    // ----- 조회 표시용 (JOIN, DB 컬럼 아님) -----
    private String resvNo;               // 예약번호 (화면 표시)
    private String roomName;             // 객실명 (화면 표시)
}
