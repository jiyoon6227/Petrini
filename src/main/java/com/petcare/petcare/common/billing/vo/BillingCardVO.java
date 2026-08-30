/**
 * 2026/07/27 장우철 — TB_BILLING_CARD (토스 빌링키/등록카드) VO
 *
 * 역할
 * - 회원(MEMBER) / 관리자(ADMIN) 등록카드 1건을 담음
 * - 카드등록·결제(Ajax) Service / Mapper 에서 공통 사용
 *
 * 참고 테이블: TB_BILLING_CARD
 */
package com.petcare.petcare.common.billing.vo;

import java.util.Date;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class BillingCardVO {

    private Long billingCardId;   // PK — BILLING_CARD_ID
    private String ownerType;     // MEMBER / ADMIN — OWNER_TYPE
    private Long ownerNo;         // MEMBER_NO 또는 ADMIN_NO — OWNER_NO
    private String customerKey;   // 토스 customerKey — CUSTOMER_KEY
    private String billingKey;    // 토스 billingKey (서버 전용) — BILLING_KEY
    private String cardCompany;   // 카드사명 — CARD_COMPANY
    private String cardNumber;    // 마스킹 번호 (예: ****1234) — CARD_NUMBER
    private String statusCd;      // ACTIVE / DELETED — STATUS_CD
    private Date regDate;         // 등록일 — REG_DATE
}
