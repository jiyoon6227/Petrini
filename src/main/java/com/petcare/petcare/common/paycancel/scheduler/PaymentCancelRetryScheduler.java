package com.petcare.petcare.common.paycancel.scheduler;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.petcare.petcare.common.external.service.TossPaymentService;
import com.petcare.petcare.common.external.vo.TossCancelResultVO;
import com.petcare.petcare.common.external.vo.TossPaymentLookupVO;
import com.petcare.petcare.common.paycancel.service.PaymentCancelRetryService;
import com.petcare.petcare.common.paycancel.vo.PaymentCancelRetryVO;

@Component
public class PaymentCancelRetryScheduler {

    private static final Logger log = LoggerFactory.getLogger(PaymentCancelRetryScheduler.class);

    @Autowired
    private PaymentCancelRetryService paymentCancelRetryService;

    @Autowired
    private TossPaymentService tossPaymentService;

    @Value("${payment.cancel-retry.max-attempts:5}")
    private int maxAttempts;

    @Value("${payment.cancel-retry.stuck-minutes:30}")
    private int stuckMinutes;

    /** 기본 10분마다 — 주문 저장 실패 후 자동취소 못 한 결제 재취소 */
    @Scheduled(fixedDelayString = "${payment.cancel-retry.fixed-delay-ms:600000}",
               initialDelayString = "${payment.cancel-retry.initial-delay-ms:60000}")
    public void retryPendingCancels() {
        try {
            int released = paymentCancelRetryService.releaseStuck(stuckMinutes);
            if (released > 0) {
                log.warn("===== 결제취소 재처리: PROCESSING 정체 {}건 PENDING 복구 =====", released);
            }

            List<PaymentCancelRetryVO> list = paymentCancelRetryService.getPendingList();
            if (list == null || list.isEmpty()) {
                return;
            }
            log.info("===== 결제취소 재처리 시작: {}건 =====", list.size());
            for (PaymentCancelRetryVO item : list) {
                // 한 건이 실패해도 나머지는 계속 처리
                try {
                    processOne(item);
                } catch (Exception e) {
                    log.error("결제취소 재처리 중 오류 - retryId={}, paymentKey={}",
                            item.getRetryId(), item.getPaymentKey(), e);
                    try {
                        recordFailure(item, "재처리 중 오류: " + e.getMessage());
                    } catch (Exception ignore) {
                        // PROCESSING 으로 남으면 stuck-minutes 뒤 PENDING 으로 복구됨
                    }
                }
            }
            log.info("===== 결제취소 재처리 종료 =====");
        } catch (Exception e) {
            log.error("===== 결제취소 재처리 오류: {} =====", e.getMessage(), e);
        }
    }

    void processOne(PaymentCancelRetryVO item) {
        // 다른 서버/스레드가 먼저 잡았으면 건너뜀
        if (!paymentCancelRetryService.claim(item.getRetryId())) {
            return;
        }

        boolean billing = TossPaymentService.isBillingPayMethod(item.getPayMethod());

        // 이미 취소돼 있으면 재요청 없이 완료 처리
        TossPaymentLookupVO lookup = tossPaymentService.getPayment(item.getPaymentKey(), billing);
        if (lookup.isCanceled()) {
            paymentCancelRetryService.markSuccess(item.getRetryId());
            log.info("결제취소 재처리 완료(이미 취소됨) - retryId={}, paymentKey={}",
                    item.getRetryId(), item.getPaymentKey());
            return;
        }

        // 처음 요청과 같은 멱등키·사유·금액·시크릿으로 재요청
        TossCancelResultVO result = tossPaymentService.cancelPaymentWithKey(
                item.getPaymentKey(), item.getCancelReason(), item.getCancelAmount(),
                billing, item.getIdempotencyKey());
        if (result.isCanceled()) {
            paymentCancelRetryService.markSuccess(item.getRetryId());
            log.info("결제취소 재처리 완료 - retryId={}, paymentKey={}, result={}",
                    item.getRetryId(), item.getPaymentKey(), result.getType());
            return;
        }

        recordFailure(item, result.toSummary());
    }

    private void recordFailure(PaymentCancelRetryVO item, String error) {
        int attempt = (item.getAttemptCnt() == null ? 0 : item.getAttemptCnt()) + 1;
        if (attempt >= maxAttempts) {
            paymentCancelRetryService.markFailed(item.getRetryId(), error);
            // 관리자 알림 기능이 없어 로그로 남김 → 수동 환불 대상
            log.error("결제취소 재처리 최종 실패(수동 환불 필요) - retryId={}, paymentKey={}, orderId={}, amount={}, 시도={}회, 사유={}",
                    item.getRetryId(), item.getPaymentKey(), item.getOrderId(), item.getCancelAmount(),
                    attempt, error);
        } else {
            paymentCancelRetryService.markRetry(item.getRetryId(), error);
            log.warn("결제취소 재처리 실패(다음 주기 재시도) - retryId={}, paymentKey={}, 시도={}/{}회, 사유={}",
                    item.getRetryId(), item.getPaymentKey(), attempt, maxAttempts, error);
        }
    }
}
