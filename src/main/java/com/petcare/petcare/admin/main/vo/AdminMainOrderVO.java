/**
 * 역할: 관리자 대시보드 — 최근 주문 1건
 *
 * - 박유정 / 2026-07-30 — Phase 3-A: dashboard.jsp 최근 주문 표
 *
 * 참고 테이블
 * - TB_ORDER
 * - TB_MEMBER (JOIN — memberName)
 */

package com.petcare.petcare.admin.main.vo;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AdminMainOrderVO {

    // ── TB_ORDER 컬럼 ──────────────────────────────────────────

    private Long orderId;       // ORDER_ID — 주문 번호 (PK, 상세 링크용)
    private String orderNo;     // ORDER_NO — 주문번호 (#화면표시)
    private Long payAmount;     // PAY_AMOUNT — 실결제 금액 (원)
    private String orderStatus; // ORDER_STATUS — PAID/SHIPPING/CANCEL 등

    // ── 조회 전용 (TB_MEMBER JOIN) ─────────────────────────────

    private String memberName;  // MEMBER_NAME — 주문자명
}
