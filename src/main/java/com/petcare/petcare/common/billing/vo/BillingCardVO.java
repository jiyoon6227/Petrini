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
    private String cardNumber;    // 마스킹 번호 (예: 1234) — CARD_NUMBER
    private String statusCd;      // ACTIVE / DELETED — STATUS_CD
    private Date regDate;         // 등록일 — REG_DATE
}
