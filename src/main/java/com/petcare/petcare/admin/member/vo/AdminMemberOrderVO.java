/**
 * 역할: 관리자 회원 상세 — 최근 주문 1건
 *
 * - 박유정 / 2026-07-21 STEP 11
 *
 * 참고 테이블
 * - TB_ORDER
 * - TB_ORDER_ITEM
 *
 * [ORDER_STATUS]
 * - PAID / SHIPPING / DELIVERED / CANCEL 등
 */

package com.petcare.petcare.admin.member.vo;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AdminMemberOrderVO {

    // ── TB_ORDER 컬럼 ──────────────────────────────────────────

    private Long orderId;            // ORDER_ID — 주문 번호 (PK)
    private String orderNo;          // ORDER_NO — 주문번호 (화면 표시)
    private String orderStatus;      // ORDER_STATUS — 주문 상태
    private Long payAmount;            // PAY_AMOUNT — 실결제 금액
    private String orderDate;          // ORDER_DATE — 주문일

    // ── 조회 전용 (TB_ORDER_ITEM) ──────────────────────────────

    private String firstProductName;   // PRODUCT_NAME — 대표 상품명 (첫 항목)
    private Integer itemCount;         // (집계) — 주문 상품 건수
}
