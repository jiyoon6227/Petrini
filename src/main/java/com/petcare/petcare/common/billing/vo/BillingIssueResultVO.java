/**
 * 2026/07/27 장우철 — 토스 빌링키 발급 API 응답 요약 VO
 *
 * 역할
 * - POST /v1/billing/authorizations/issue 성공 시 billingKey·카드정보 전달
 * - BillingCardService 가 TB_BILLING_CARD INSERT 전에 사용
 */
package com.petcare.petcare.common.billing.vo;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class BillingIssueResultVO {

    private String billingKey;    // 토스 발급 빌링키
    private String customerKey;   // 요청에 사용한 customerKey
    private String cardCompany;   // 카드사명 (card.company 등)
    private String cardNumber;    // 마스킹 카드번호 (card.number)
    private String method;        // 결제수단 (CARD 등, 참고용)
}
