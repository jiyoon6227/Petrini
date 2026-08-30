/**
 * 2026/07/27 장우철 — 토스 빌링 자동결제 승인 결과 VO
 *
 * TossBillingService.approveBilling 성공 시 paymentKey·orderId 전달
 * → TB_PAYMENT.TOSS_PAYMENT_KEY / TOSS_ORDER_ID 저장용
 */
package com.petcare.petcare.common.billing.vo;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class BillingApproveResultVO {

    private String paymentKey;  // 토스 paymentKey
    private String orderId;     // 요청한 orderId
    private String method;      // 결제수단 (참고)
    private Integer totalAmount;
}
