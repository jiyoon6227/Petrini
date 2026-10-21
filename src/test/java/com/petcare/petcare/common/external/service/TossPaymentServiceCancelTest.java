package com.petcare.petcare.common.external.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import com.petcare.petcare.common.external.vo.TossCancelResultVO;
import com.petcare.petcare.common.external.vo.TossCancelResultVO.ResultType;
import com.petcare.petcare.common.external.vo.TossPaymentLookupVO;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;

/** 실제 토스 대신 로컬 가짜 서버로 취소·조회 응답 구분 확인 */
class TossPaymentServiceCancelTest {

    private HttpServer server;
    private TossPaymentService service;

    // 가짜 서버가 돌려줄 응답과 받은 요청 기록
    private volatile int responseStatus;
    private volatile String responseBody;
    private volatile long responseDelayMs;
    private final List<String> receivedBodies = new ArrayList<>();
    private final List<String> receivedIdemKeys = new ArrayList<>();
    private final List<String> receivedAuth = new ArrayList<>();

    @BeforeEach
    void setUp() throws IOException {
        server = HttpServer.create(new InetSocketAddress("127.0.0.1", 0), 0);
        server.createContext("/v1/payments/", this::handle);
        server.start();

        service = new TossPaymentService();
        ReflectionTestUtils.setField(service, "tossSecretKey", "widget_sk");
        ReflectionTestUtils.setField(service, "tossBillingSecretKey", "billing_sk");
        ReflectionTestUtils.setField(service, "tossApiBaseUrl", "http://127.0.0.1:" + server.getAddress().getPort());
        ReflectionTestUtils.setField(service, "cancelConnectTimeoutMs", 5000);
        ReflectionTestUtils.setField(service, "cancelReadTimeoutMs", 30000);
        responseDelayMs = 0;
    }

    @AfterEach
    void tearDown() {
        try {
            server.stop(0);
        } catch (IllegalStateException ignore) {
            // 연결 실패 테스트에서 이미 멈춘 경우
        }
    }

    private void handle(HttpExchange ex) throws IOException {
        String body = new String(ex.getRequestBody().readAllBytes(), StandardCharsets.UTF_8);
        synchronized (this) {
            receivedBodies.add(body);
            receivedIdemKeys.add(ex.getRequestHeaders().getFirst("Idempotency-Key"));
            receivedAuth.add(ex.getRequestHeaders().getFirst("Authorization"));
        }
        if (responseDelayMs > 0) {
            try { Thread.sleep(responseDelayMs); } catch (InterruptedException ignore) { }
        }
        byte[] out = responseBody == null ? new byte[0] : responseBody.getBytes(StandardCharsets.UTF_8);
        ex.sendResponseHeaders(responseStatus, out.length == 0 ? -1 : out.length);
        if (out.length > 0) {
            try (OutputStream os = ex.getResponseBody()) { os.write(out); }
        }
        ex.close();
    }

    private void respond(int status, String body) {
        responseStatus = status;
        responseBody = body;
    }

    private TossCancelResultVO cancel() {
        return service.cancelPaymentWithKey("pay-1", "주문 처리 실패로 결제 자동 취소", 15000L, false, "idem-1");
    }

    @Test
    void 성공_200() {
        respond(200, "{\"status\":\"CANCELED\"}");
        TossCancelResultVO r = cancel();
        assertEquals(ResultType.SUCCESS, r.getType());
        assertTrue(r.isCanceled());
    }

    @Test
    void ALREADY_CANCELED_PAYMENT는_성공으로_취급() {
        respond(400, "{\"code\":\"ALREADY_CANCELED_PAYMENT\",\"message\":\"이미 취소된 결제 입니다.\"}");
        TossCancelResultVO r = cancel();
        assertEquals(ResultType.ALREADY_CANCELED, r.getType());
        assertEquals(400, r.getHttpStatus());
        assertEquals("ALREADY_CANCELED_PAYMENT", r.getErrorCode());
        assertTrue(r.isCanceled());
    }

    @Test
    void 처리중_409는_RETRYABLE() {
        respond(409, "{\"code\":\"IDEMPOTENT_REQUEST_PROCESSING\",\"message\":\"처리 중\"}");
        assertEquals(ResultType.RETRYABLE, cancel().getType());
    }

    @Test
    void 서버오류_5xx는_바디가_없어도_RETRYABLE() {
        respond(503, null);
        TossCancelResultVO r = cancel();
        assertEquals(ResultType.RETRYABLE, r.getType());
        assertEquals(503, r.getHttpStatus());
    }

    @Test
    void 그외_4xx는_NOT_RETRYABLE() {
        respond(403, "{\"code\":\"FORBIDDEN_REQUEST\",\"message\":\"허용되지 않은 요청입니다.\"}");
        TossCancelResultVO r = cancel();
        assertEquals(ResultType.NOT_RETRYABLE, r.getType());
        assertFalse(r.isCanceled());
        assertFalse(r.isRetryable());
    }

    @Test
    void 응답_타임아웃은_RETRYABLE() {
        ReflectionTestUtils.setField(service, "cancelReadTimeoutMs", 200);
        responseDelayMs = 1500;
        respond(200, "{}");
        TossCancelResultVO r = cancel();
        assertEquals(ResultType.RETRYABLE, r.getType());
        assertEquals(0, r.getHttpStatus());
    }

    @Test
    void 연결_실패는_RETRYABLE() {
        server.stop(0);
        TossCancelResultVO r = cancel();
        assertEquals(ResultType.RETRYABLE, r.getType());
    }

    @Test
    void 재시도시_멱등키와_바디가_처음과_같음() {
        respond(500, "{\"code\":\"PROVIDER_ERROR\",\"message\":\"x\"}");
        cancel();
        cancel();
        assertEquals(2, receivedBodies.size());
        assertEquals(receivedBodies.get(0), receivedBodies.get(1));
        assertEquals("idem-1", receivedIdemKeys.get(0));
        assertEquals("idem-1", receivedIdemKeys.get(1));
        assertEquals("{\"cancelReason\":\"주문 처리 실패로 결제 자동 취소\",\"cancelAmount\":15000}", receivedBodies.get(0));
    }

    @Test
    void 결제방식에_맞는_시크릿_하나만_사용() {
        respond(200, "{}");
        service.cancelPaymentWithKey("pay-1", "r", 1000L, true, "idem-b");
        assertEquals(1, receivedAuth.size());
        assertEquals("Basic " + Base64.getEncoder().encodeToString("billing_sk:".getBytes(StandardCharsets.UTF_8)),
                receivedAuth.get(0));
    }

    @Test
    void 결제조회_CANCELED_확인() {
        respond(200, "{\"paymentKey\":\"pay-1\",\"status\":\"CANCELED\"}");
        TossPaymentLookupVO r = service.getPayment("pay-1", false);
        assertTrue(r.isOk());
        assertTrue(r.isCanceled());
        assertEquals("Basic " + Base64.getEncoder().encodeToString("widget_sk:".getBytes(StandardCharsets.UTF_8)),
                receivedAuth.get(0));
    }

    @Test
    void 결제조회_DONE이면_취소_아님() {
        respond(200, "{\"status\":\"DONE\"}");
        assertFalse(service.getPayment("pay-1", false).isCanceled());
    }

    @Test
    void 결제조회_실패는_취소_아님() {
        respond(404, "{\"code\":\"NOT_FOUND_PAYMENT\",\"message\":\"없음\"}");
        TossPaymentLookupVO r = service.getPayment("pay-1", false);
        assertFalse(r.isOk());
        assertFalse(r.isCanceled());
    }

    @Test
    void 결과구분_규칙() {
        assertEquals(ResultType.SUCCESS, TossPaymentService.classifyCancelResponse(200, null));
        assertEquals(ResultType.ALREADY_CANCELED, TossPaymentService.classifyCancelResponse(400, "ALREADY_CANCELED_PAYMENT"));
        assertEquals(ResultType.NOT_RETRYABLE, TossPaymentService.classifyCancelResponse(400, "INVALID_REQUEST"));
        assertEquals(ResultType.RETRYABLE, TossPaymentService.classifyCancelResponse(409, "IDEMPOTENT_REQUEST_PROCESSING"));
        assertEquals(ResultType.NOT_RETRYABLE, TossPaymentService.classifyCancelResponse(409, "OTHER"));
        assertEquals(ResultType.RETRYABLE, TossPaymentService.classifyCancelResponse(500, null));
        assertEquals(ResultType.NOT_RETRYABLE, TossPaymentService.classifyCancelResponse(404, "NOT_FOUND_PAYMENT"));
    }
}
