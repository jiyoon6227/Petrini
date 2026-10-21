package com.petcare.petcare.common.paycancel.scheduler;

import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import com.petcare.petcare.common.external.service.TossPaymentService;
import com.petcare.petcare.common.external.vo.TossCancelResultVO;
import com.petcare.petcare.common.external.vo.TossCancelResultVO.ResultType;
import com.petcare.petcare.common.external.vo.TossPaymentLookupVO;
import com.petcare.petcare.common.paycancel.service.PaymentCancelRetryService;
import com.petcare.petcare.common.paycancel.vo.PaymentCancelRetryVO;

/** 결제취소 재처리 스케줄러: 선점 → 조회 → 같은 멱등키로 재요청 → 결과 반영 */
@ExtendWith(MockitoExtension.class)
class PaymentCancelRetrySchedulerTest {

    @Mock
    private PaymentCancelRetryService paymentCancelRetryService;
    @Mock
    private TossPaymentService tossPaymentService;

    @InjectMocks
    private PaymentCancelRetryScheduler scheduler;

    @BeforeEach
    void setUp() {
        ReflectionTestUtils.setField(scheduler, "maxAttempts", 5);
        ReflectionTestUtils.setField(scheduler, "stuckMinutes", 30);
    }

    private static PaymentCancelRetryVO item(long id, String payMethod, int attemptCnt) {
        PaymentCancelRetryVO vo = new PaymentCancelRetryVO();
        vo.setRetryId(id);
        vo.setPaymentKey("pay-" + id);
        vo.setOrderId("order-" + id);
        vo.setPayMethod(payMethod);
        vo.setCancelAmount(15000L);
        vo.setCancelReason("주문 처리 실패로 결제 자동 취소");
        vo.setIdempotencyKey("idem-" + id);
        vo.setStatusCd("PENDING");
        vo.setAttemptCnt(attemptCnt);
        return vo;
    }

    private static TossPaymentLookupVO lookup(String status) {
        return new TossPaymentLookupVO(true, 200, status, null);
    }

    @Test
    void 조회결과_CANCELED면_재요청_없이_SUCCESS() {
        when(paymentCancelRetryService.getPendingList()).thenReturn(List.of(item(1L, "TOSS", 0)));
        when(paymentCancelRetryService.claim(1L)).thenReturn(true);
        when(tossPaymentService.getPayment("pay-1", false)).thenReturn(lookup("CANCELED"));

        scheduler.retryPendingCancels();

        verify(paymentCancelRetryService).markSuccess(1L);
        verify(tossPaymentService, never()).cancelPaymentWithKey(
                anyString(), anyString(), anyLong(), anyBoolean(), anyString());
    }

    @Test
    void 저장된_멱등키_사유_금액_결제방식_시크릿으로_재요청() {
        when(paymentCancelRetryService.getPendingList()).thenReturn(List.of(item(2L, "BILLING", 1)));
        when(paymentCancelRetryService.claim(2L)).thenReturn(true);
        when(tossPaymentService.getPayment("pay-2", true)).thenReturn(lookup("DONE"));
        when(tossPaymentService.cancelPaymentWithKey("pay-2", "주문 처리 실패로 결제 자동 취소", 15000L, true, "idem-2"))
                .thenReturn(new TossCancelResultVO(ResultType.ALREADY_CANCELED, 400, "ALREADY_CANCELED_PAYMENT", "m"));

        scheduler.retryPendingCancels();

        verify(paymentCancelRetryService).markSuccess(2L);
    }

    @Test
    void 실패하고_최대횟수_미만이면_다시_PENDING() {
        when(paymentCancelRetryService.getPendingList()).thenReturn(List.of(item(3L, "TOSS", 1)));
        when(paymentCancelRetryService.claim(3L)).thenReturn(true);
        when(tossPaymentService.getPayment("pay-3", false)).thenReturn(lookup("DONE"));
        when(tossPaymentService.cancelPaymentWithKey(anyString(), anyString(), anyLong(), anyBoolean(), anyString()))
                .thenReturn(new TossCancelResultVO(ResultType.RETRYABLE, 500, "PROVIDER_ERROR", "m"));

        scheduler.retryPendingCancels();

        verify(paymentCancelRetryService).markRetry(eq(3L), anyString());
        verify(paymentCancelRetryService, never()).markFailed(anyLong(), anyString());
    }

    @Test
    void 최대횟수_초과면_FAILED() {
        // 이미 4번 실패 → 이번이 5번째
        when(paymentCancelRetryService.getPendingList()).thenReturn(List.of(item(4L, "TOSS", 4)));
        when(paymentCancelRetryService.claim(4L)).thenReturn(true);
        when(tossPaymentService.getPayment("pay-4", false)).thenReturn(lookup("DONE"));
        when(tossPaymentService.cancelPaymentWithKey(anyString(), anyString(), anyLong(), anyBoolean(), anyString()))
                .thenReturn(new TossCancelResultVO(ResultType.NOT_RETRYABLE, 403, "FORBIDDEN_REQUEST", "m"));

        scheduler.retryPendingCancels();

        verify(paymentCancelRetryService).markFailed(eq(4L), anyString());
        verify(paymentCancelRetryService, never()).markRetry(anyLong(), anyString());
    }

    @Test
    void 이미_PROCESSING인_건은_선점_실패로_처리_안함() {
        when(paymentCancelRetryService.getPendingList()).thenReturn(List.of(item(5L, "TOSS", 0)));
        when(paymentCancelRetryService.claim(5L)).thenReturn(false);

        scheduler.retryPendingCancels();

        verify(tossPaymentService, never()).getPayment(anyString(), anyBoolean());
        verify(tossPaymentService, never()).cancelPaymentWithKey(
                anyString(), anyString(), anyLong(), anyBoolean(), anyString());
        verify(paymentCancelRetryService, never()).markSuccess(anyLong());
    }

    @Test
    void 한건_오류여도_나머지_계속_처리() {
        when(paymentCancelRetryService.getPendingList())
                .thenReturn(List.of(item(6L, "TOSS", 0), item(7L, "TOSS", 0)));
        when(paymentCancelRetryService.claim(6L)).thenThrow(new RuntimeException("DB 오류"));
        when(paymentCancelRetryService.claim(7L)).thenReturn(true);
        when(tossPaymentService.getPayment("pay-7", false)).thenReturn(lookup("CANCELED"));

        scheduler.retryPendingCancels();

        verify(paymentCancelRetryService).markSuccess(7L);
    }

    @Test
    void PROCESSING_정체건_복구를_먼저_호출() {
        when(paymentCancelRetryService.getPendingList()).thenReturn(List.of());

        scheduler.retryPendingCancels();

        verify(paymentCancelRetryService).releaseStuck(30);
        verify(paymentCancelRetryService, never()).claim(anyLong());
        verify(tossPaymentService, never()).getPayment(anyString(), anyBoolean());
    }
}
