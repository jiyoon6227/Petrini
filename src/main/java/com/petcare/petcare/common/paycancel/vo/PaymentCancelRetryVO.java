package com.petcare.petcare.common.paycancel.vo;

import java.util.Date;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PaymentCancelRetryVO {

    private Long retryId;           // PK — RETRY_ID
    private String paymentKey;      // 토스 paymentKey — PAYMENT_KEY
    private String orderId;         // 토스 orderId — ORDER_ID
    private String payMethod;       // TOSS / BILLING — PAY_METHOD
    private Long cancelAmount;      // 취소 금액 — CANCEL_AMOUNT
    private String cancelReason;    // 취소 사유 — CANCEL_REASON
    private String idempotencyKey;  // 멱등키 (재시도 시 같은 값) — IDEMPOTENCY_KEY
    private String statusCd;        // PENDING / PROCESSING / SUCCESS / FAILED — STATUS_CD
    private Integer attemptCnt;     // 재처리 시도 횟수 — ATTEMPT_CNT
    private String lastError;       // 마지막 실패 사유 — LAST_ERROR
    private Date regDate;           // 등록일 — REG_DATE
    private Date processDate;       // 마지막 처리일 — PROCESS_DATE
}
