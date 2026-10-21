package com.petcare.petcare.common.paycancel.service;

import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.petcare.petcare.common.external.service.TossPaymentService;
import com.petcare.petcare.common.external.vo.TossCancelResultVO;
import com.petcare.petcare.common.paycancel.vo.PaymentCancelRetryVO;

/**
 * 주문 저장 실패 후 결제 자동취소
 * 1) 멱등키 1개로 취소 요청 → RETRYABLE 이면 잠시 뒤 같은 멱등키로 1번 더
 * 2) 그래도 실패면 같은 멱등키로 TB_PAYMENT_CANCEL_RETRY 에 PENDING 저장 (스케줄러가 재처리)
 */
@Service
public class OrderPaymentAutoCancelService {

    private static final Logger log = LoggerFactory.getLogger(OrderPaymentAutoCancelService.class);

    public enum Outcome {
        CANCELED,      // 취소 완료 (이미 취소된 경우 포함)
        QUEUED,        // 재처리 테이블에 저장됨 → 환불 진행 중
        QUEUE_FAILED   // 재처리 테이블 저장도 실패 → 수동 환불 필요
    }

    private final TossPaymentService tossPaymentService;
    private final PaymentCancelRetryService paymentCancelRetryService;
    private final long retryDelayMs;

    public OrderPaymentAutoCancelService(TossPaymentService tossPaymentService,
                                         PaymentCancelRetryService paymentCancelRetryService,
                                         @Value("${payment.cancel-retry.immediate-delay-ms:1000}") long retryDelayMs) {
        this.tossPaymentService = tossPaymentService;
        this.paymentCancelRetryService = paymentCancelRetryService;
        this.retryDelayMs = retryDelayMs;
    }

    public Outcome cancelAfterOrderFailure(String paymentKey, String orderId, String payMethod,
                                           Long cancelAmount, String cancelReason) {
        boolean billing = TossPaymentService.isBillingPayMethod(payMethod);
        String idempotencyKey = UUID.randomUUID().toString();

        TossCancelResultVO result = tossPaymentService.cancelPaymentWithKey(
                paymentKey, cancelReason, cancelAmount, billing, idempotencyKey);

        if (result.isRetryable()) {
            sleepQuietly(retryDelayMs);
            result = tossPaymentService.cancelPaymentWithKey(
                    paymentKey, cancelReason, cancelAmount, billing, idempotencyKey);
        }

        if (result.isCanceled()) {
            return Outcome.CANCELED;
        }

        PaymentCancelRetryVO vo = new PaymentCancelRetryVO();
        vo.setPaymentKey(paymentKey);
        vo.setOrderId(orderId);
        vo.setPayMethod(billing ? "BILLING" : "TOSS");
        vo.setCancelAmount(cancelAmount);
        vo.setCancelReason(cancelReason);
        vo.setIdempotencyKey(idempotencyKey);
        vo.setLastError(result.toSummary());

        try {
            paymentCancelRetryService.registerPending(vo);
        } catch (Exception e) {
            log.error("결제 자동취소 실패 + 재처리 저장 실패 (수동 환불 필요) - paymentKey={}, orderId={}, amount={}, 취소 실패 사유={}",
                    paymentKey, orderId, cancelAmount, result.toSummary(), e);
            return Outcome.QUEUE_FAILED;
        }

        log.error("결제 자동취소 실패 → 재처리 대기 저장 - paymentKey={}, orderId={}, amount={}, 취소 실패 사유={}",
                paymentKey, orderId, cancelAmount, result.toSummary());
        return Outcome.QUEUED;
    }

    private static void sleepQuietly(long ms) {
        if (ms <= 0) return;
        try {
            Thread.sleep(ms);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}
