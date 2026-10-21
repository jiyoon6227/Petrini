package com.petcare.petcare.common.paycancel.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.petcare.petcare.common.external.service.TossPaymentService;
import com.petcare.petcare.common.external.vo.TossCancelResultVO;
import com.petcare.petcare.common.external.vo.TossCancelResultVO.ResultType;
import com.petcare.petcare.common.paycancel.service.OrderPaymentAutoCancelService.Outcome;
import com.petcare.petcare.common.paycancel.vo.PaymentCancelRetryVO;

/** 주문 저장 실패 후 자동취소: 즉시 재시도 + 재처리 테이블 저장 */
@ExtendWith(MockitoExtension.class)
class OrderPaymentAutoCancelServiceTest {

    private static final String PAYMENT_KEY = "tgen_pay_001";
    private static final String ORDER_ID = "order-001";
    private static final String REASON = "주문 처리 실패로 결제 자동 취소";

    @Mock
    private TossPaymentService tossPaymentService;
    @Mock
    private PaymentCancelRetryService paymentCancelRetryService;

    private OrderPaymentAutoCancelService service;

    @BeforeEach
    void setUp() {
        // 테스트에서는 재시도 대기 없이
        service = new OrderPaymentAutoCancelService(tossPaymentService, paymentCancelRetryService, 0);
    }

    private static TossCancelResultVO result(ResultType type, int status, String code) {
        return new TossCancelResultVO(type, status, code, "msg");
    }

    @Test
    void 첫시도_RETRYABLE_두번째_성공이면_테이블_저장_안함() {
        when(tossPaymentService.cancelPaymentWithKey(anyString(), anyString(), anyLong(), anyBoolean(), anyString()))
                .thenReturn(result(ResultType.RETRYABLE, 0, null))
                .thenReturn(result(ResultType.SUCCESS, 200, null));

        Outcome outcome = service.cancelAfterOrderFailure(PAYMENT_KEY, ORDER_ID, "TOSS", 15000L, REASON);

        assertEquals(Outcome.CANCELED, outcome);
        ArgumentCaptor<String> keys = ArgumentCaptor.forClass(String.class);
        verify(tossPaymentService, times(2)).cancelPaymentWithKey(
                eq(PAYMENT_KEY), eq(REASON), eq(15000L), eq(false), keys.capture());
        List<String> used = keys.getAllValues();
        assertEquals(used.get(0), used.get(1)); // 같은 멱등키
        verify(paymentCancelRetryService, never()).registerPending(any());
    }

    @Test
    void NOT_RETRYABLE_4xx면_즉시_재시도_안함() {
        when(tossPaymentService.cancelPaymentWithKey(anyString(), anyString(), anyLong(), anyBoolean(), anyString()))
                .thenReturn(result(ResultType.NOT_RETRYABLE, 403, "FORBIDDEN_REQUEST"));

        Outcome outcome = service.cancelAfterOrderFailure(PAYMENT_KEY, ORDER_ID, "TOSS", 15000L, REASON);

        verify(tossPaymentService, times(1)).cancelPaymentWithKey(
                anyString(), anyString(), anyLong(), anyBoolean(), anyString());
        // 실패는 그대로 재처리 대기열에 저장
        assertEquals(Outcome.QUEUED, outcome);
        verify(paymentCancelRetryService, times(1)).registerPending(any());
    }

    @Test
    void ALREADY_CANCELED_PAYMENT면_성공_처리() {
        when(tossPaymentService.cancelPaymentWithKey(anyString(), anyString(), anyLong(), anyBoolean(), anyString()))
                .thenReturn(result(ResultType.ALREADY_CANCELED, 400, "ALREADY_CANCELED_PAYMENT"));

        Outcome outcome = service.cancelAfterOrderFailure(PAYMENT_KEY, ORDER_ID, "TOSS", 15000L, REASON);

        assertEquals(Outcome.CANCELED, outcome);
        verify(tossPaymentService, times(1)).cancelPaymentWithKey(
                anyString(), anyString(), anyLong(), anyBoolean(), anyString());
        verify(paymentCancelRetryService, never()).registerPending(any());
    }

    @Test
    void 두번_다_실패하면_같은_멱등키로_PENDING_저장() {
        when(tossPaymentService.cancelPaymentWithKey(anyString(), anyString(), anyLong(), anyBoolean(), anyString()))
                .thenReturn(result(ResultType.RETRYABLE, 500, "PROVIDER_ERROR"))
                .thenReturn(result(ResultType.RETRYABLE, 0, null));

        Outcome outcome = service.cancelAfterOrderFailure(PAYMENT_KEY, ORDER_ID, "TOSS", 15000L, REASON);

        assertEquals(Outcome.QUEUED, outcome);
        ArgumentCaptor<String> keys = ArgumentCaptor.forClass(String.class);
        verify(tossPaymentService, times(2)).cancelPaymentWithKey(
                anyString(), anyString(), anyLong(), anyBoolean(), keys.capture());
        ArgumentCaptor<PaymentCancelRetryVO> saved = ArgumentCaptor.forClass(PaymentCancelRetryVO.class);
        verify(paymentCancelRetryService).registerPending(saved.capture());

        PaymentCancelRetryVO vo = saved.getValue();
        assertEquals(keys.getAllValues().get(0), keys.getAllValues().get(1));
        assertEquals(keys.getAllValues().get(0), vo.getIdempotencyKey());
        assertEquals(PAYMENT_KEY, vo.getPaymentKey());
        assertEquals(ORDER_ID, vo.getOrderId());
        assertEquals("TOSS", vo.getPayMethod());
        assertEquals(15000L, vo.getCancelAmount());
        assertEquals(REASON, vo.getCancelReason());
    }

    @Test
    void 테이블_저장도_실패하면_QUEUE_FAILED() {
        when(tossPaymentService.cancelPaymentWithKey(anyString(), anyString(), anyLong(), anyBoolean(), anyString()))
                .thenReturn(result(ResultType.RETRYABLE, 0, null));
        doThrow(new RuntimeException("DB down")).when(paymentCancelRetryService).registerPending(any());

        Outcome outcome = service.cancelAfterOrderFailure(PAYMENT_KEY, ORDER_ID, "TOSS", 15000L, REASON);

        assertEquals(Outcome.QUEUE_FAILED, outcome);
    }
}
