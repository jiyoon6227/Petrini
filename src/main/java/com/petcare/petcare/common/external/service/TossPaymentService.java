package com.petcare.petcare.common.external.service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.petcare.petcare.common.external.vo.TossCancelResultVO;
import com.petcare.petcare.common.external.vo.TossCancelResultVO.ResultType;
import com.petcare.petcare.common.external.vo.TossPaymentLookupVO;

@Service
public class TossPaymentService {

    @Value("${toss.secret-key}")
    private String tossSecretKey;

    // 빌링키 결제는 위젯 시크릿과 분리 (섞으면 cancel FORBIDDEN_REQUEST)
    @Value("${toss.billing.secret-key}")
    private String tossBillingSecretKey;

    // 취소 재처리용 메서드(cancelPaymentWithKey, getPayment)에만 적용
    @Value("${toss.api-base-url:https://api.tosspayments.com}")
    private String tossApiBaseUrl;

    @Value("${toss.cancel.connect-timeout-ms:5000}")
    private int cancelConnectTimeoutMs;

    @Value("${toss.cancel.read-timeout-ms:30000}")
    private int cancelReadTimeoutMs;

    public String cancelPayment(String paymentKey, String cancelReason) {
        return cancelPayment(paymentKey, cancelReason, null, false);
    }

    /**
     * 숙소 부분환불: cancelAmount 있으면 해당 금액만 취소
     * @param cancelAmount null이면 전액 취소
     */
    public String cancelPayment(String paymentKey, String cancelReason, Long cancelAmount) {
        return cancelPayment(paymentKey, cancelReason, cancelAmount, false);
    }

    /**
     * 빌링키로 승인된 결제는 billingSecret 으로 취소
     * @param billingPayment true면 toss.billing.secret-key 사용
     */
    public String cancelPayment(String paymentKey, String cancelReason, Long cancelAmount,
                                boolean billingPayment) {
        try {
            URL url = new URL("https://api.tosspayments.com/v1/payments/" + paymentKey + "/cancel");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");

            String secret = resolveCancelSecret(billingPayment);
            String encodedAuth = Base64.getEncoder()
                    .encodeToString((secret + ":").getBytes(StandardCharsets.UTF_8));
            conn.setRequestProperty("Authorization", "Basic " + encodedAuth);
            conn.setRequestProperty("Content-Type", "application/json");
            // 토스 권장 멱등키 (중복 취소 방지)
            conn.setRequestProperty("Idempotency-Key", java.util.UUID.randomUUID().toString());
            conn.setDoOutput(true);

            String body = buildCancelBody(cancelReason, cancelAmount);
            try (OutputStream os = conn.getOutputStream()) {
                os.write(body.getBytes(StandardCharsets.UTF_8));
            }

            int status = conn.getResponseCode();
            InputStreamReader isr = new InputStreamReader(
                    status == 200 ? conn.getInputStream() : conn.getErrorStream(), StandardCharsets.UTF_8);
            BufferedReader br = new BufferedReader(isr);
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) sb.append(line);
            br.close();

            if (status == 200) return null;

            JsonNode json = new ObjectMapper().readTree(sb.toString());
            String code = json.path("code").asText("");
            String message = json.path("message").asText("토스 결제취소 요청이 거절되었습니다.");
            if (code != null && !code.isBlank()) {
                return message + " [" + code + "]";
            }
            return message;

        } catch (Exception e) {
            return "토스 API 호출 중 오류가 발생했습니다: " + e.getMessage();
        }
    }

    /** PAY_METHOD=BILLING 이면 빌링 시크릿 사용 */
    public static boolean isBillingPayMethod(String payMethod) {
        return payMethod != null && "BILLING".equalsIgnoreCase(payMethod.trim());
    }

    /**
     * 카드 실결제 키가 아니면 토스 취소 스킵 (포인트·가짜키)
     */
    public static boolean isSkipCancelPaymentKey(String paymentKey) {
        if (paymentKey == null || paymentKey.isBlank()) return true;
        String k = paymentKey.trim();
        return k.startsWith("ZERO") || k.startsWith("POINT") || k.startsWith("BILLING-");
    }

    /**
     * PAY_METHOD로 시크릿 선택.
     * 과거 쇼핑 주문이 빌링인데 PAY_METHOD=TOSS 로 잘못 저장된 건 → FORBIDDEN 시 반대 시크릿 1회 재시도.
     */
    public String cancelPaymentSmart(String paymentKey, String cancelReason, Long cancelAmount,
                                     String payMethod) {
        if (isSkipCancelPaymentKey(paymentKey)) {
            return null;
        }
        boolean billing = isBillingPayMethod(payMethod);
        String err = cancelPayment(paymentKey, cancelReason, cancelAmount, billing);
        if (err != null && isSecretMismatchError(err)) {
            err = cancelPayment(paymentKey, cancelReason, cancelAmount, !billing);
        }
        return err;
    }

    private static boolean isSecretMismatchError(String err) {
        String e = err.toLowerCase();
        return e.contains("forbidden") || e.contains("허용되지 않은");
    }

    private String resolveCancelSecret(boolean billingPayment) {
        if (billingPayment) {
            if (tossBillingSecretKey == null || tossBillingSecretKey.isBlank()) {
                throw new IllegalStateException("toss.billing.secret-key 가 설정되어 있지 않습니다.");
            }
            return tossBillingSecretKey;
        }
        return tossSecretKey;
    }

    /** 취소 요청 바디. 같은 사유·금액이면 항상 같은 문자열 (재시도 시 바디 동일 보장) */
    static String buildCancelBody(String cancelReason, Long cancelAmount) {
        String safeReason = cancelReason == null ? "취소" : cancelReason.replace("\"", "'");
        StringBuilder body = new StringBuilder("{\"cancelReason\":\"").append(safeReason).append("\"");
        if (cancelAmount != null && cancelAmount > 0) {
            body.append(",\"cancelAmount\":").append(cancelAmount);
        }
        body.append("}");
        return body.toString();
    }

    /**
     * 멱등키를 밖에서 받아 결제취소 (주문 실패 후 자동취소·재처리용)
     * - 같은 결제는 처음부터 끝까지 같은 멱등키·사유·금액으로 보내야 토스가 중복 취소로 처리하지 않음
     * - 시크릿은 billingPayment 로 정한 하나만 사용 (반대 시크릿 재시도 없음)
     * - 연결 5초 / 응답 30초 타임아웃 (application.properties)
     */
    public TossCancelResultVO cancelPaymentWithKey(String paymentKey, String cancelReason, Long cancelAmount,
                                                   boolean billingPayment, String idempotencyKey) {
        HttpURLConnection conn = null;
        try {
            URL url = new URL(tossApiBaseUrl + "/v1/payments/" + paymentKey + "/cancel");
            conn = (HttpURLConnection) url.openConnection();
            conn.setConnectTimeout(cancelConnectTimeoutMs);
            conn.setReadTimeout(cancelReadTimeoutMs);
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Authorization", basicAuth(resolveCancelSecret(billingPayment)));
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setRequestProperty("Idempotency-Key", idempotencyKey);
            conn.setDoOutput(true);

            try (OutputStream os = conn.getOutputStream()) {
                os.write(buildCancelBody(cancelReason, cancelAmount).getBytes(StandardCharsets.UTF_8));
            }

            int status = conn.getResponseCode();
            String responseBody = readBody(conn, status);
            if (status == 200) {
                return new TossCancelResultVO(ResultType.SUCCESS, status, null, "취소 성공");
            }

            String code = null;
            String message = "토스 결제취소 요청이 거절되었습니다.";
            if (responseBody != null && !responseBody.isBlank()) {
                try {
                    JsonNode json = new ObjectMapper().readTree(responseBody);
                    code = json.path("code").asText(null);
                    message = json.path("message").asText(message);
                } catch (IOException ignore) {
                    // JSON이 아닌 응답(게이트웨이 오류 페이지 등)은 기본 메시지 사용
                }
            }
            return new TossCancelResultVO(classifyCancelResponse(status, code), status, code, message);

        } catch (IOException e) {
            // 타임아웃·연결 실패 등 네트워크 오류 → 토스에 도달했는지 알 수 없으므로 같은 멱등키로 재시도
            return new TossCancelResultVO(ResultType.RETRYABLE, 0, null,
                    "토스 API 통신 오류: " + e.getClass().getSimpleName() + " " + e.getMessage());
        } catch (Exception e) {
            // 시크릿 미설정 등 설정 오류
            return new TossCancelResultVO(ResultType.NOT_RETRYABLE, 0, null,
                    "토스 결제취소 요청 준비 중 오류: " + e.getMessage());
        } finally {
            if (conn != null) conn.disconnect();
        }
    }

    /** 응답 상태코드·토스 에러코드로 결과 구분 */
    static ResultType classifyCancelResponse(int status, String code) {
        if (status == 200) return ResultType.SUCCESS;
        if (status == 400 && "ALREADY_CANCELED_PAYMENT".equals(code)) return ResultType.ALREADY_CANCELED;
        if (status == 409 && "IDEMPOTENT_REQUEST_PROCESSING".equals(code)) return ResultType.RETRYABLE;
        if (status >= 500) return ResultType.RETRYABLE;
        return ResultType.NOT_RETRYABLE;
    }

    /**
     * 결제 조회 (GET /v1/payments/{paymentKey}) — status 가 CANCELED 인지 확인용
     * @param billingPayment true면 빌링 시크릿으로 조회
     */
    public TossPaymentLookupVO getPayment(String paymentKey, boolean billingPayment) {
        HttpURLConnection conn = null;
        try {
            URL url = new URL(tossApiBaseUrl + "/v1/payments/" + paymentKey);
            conn = (HttpURLConnection) url.openConnection();
            conn.setConnectTimeout(cancelConnectTimeoutMs);
            conn.setReadTimeout(cancelReadTimeoutMs);
            conn.setRequestMethod("GET");
            conn.setRequestProperty("Authorization", basicAuth(resolveCancelSecret(billingPayment)));

            int status = conn.getResponseCode();
            String responseBody = readBody(conn, status);
            JsonNode json = (responseBody == null || responseBody.isBlank())
                    ? null : new ObjectMapper().readTree(responseBody);
            if (status == 200) {
                return new TossPaymentLookupVO(true, status,
                        json != null ? json.path("status").asText(null) : null, null);
            }
            String message = json != null ? json.path("message").asText("결제 조회 실패") : "결제 조회 실패";
            return new TossPaymentLookupVO(false, status, null, message);

        } catch (Exception e) {
            return new TossPaymentLookupVO(false, 0, null, "토스 결제조회 오류: " + e.getMessage());
        } finally {
            if (conn != null) conn.disconnect();
        }
    }

    private static String basicAuth(String secret) {
        return "Basic " + Base64.getEncoder().encodeToString((secret + ":").getBytes(StandardCharsets.UTF_8));
    }

    /** 응답 바디 읽기 (5xx 등에서 에러 스트림이 없으면 null) */
    private static String readBody(HttpURLConnection conn, int status) throws IOException {
        InputStream in = status < 400 ? conn.getInputStream() : conn.getErrorStream();
        if (in == null) return null;
        try (BufferedReader br = new BufferedReader(new InputStreamReader(in, StandardCharsets.UTF_8))) {
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) sb.append(line);
            return sb.toString();
        }
    }

    /**
     * 토스 결제승인 API 호출 (결제위젯에서 인증 성공 후 반드시 호출해야 실제 결제가 완료됨)
     * @param paymentKey 위젯이 돌려준 paymentKey
     * @param orderId    위젯이 돌려준 orderId (토스 쪽 주문 식별자)
     * @param amount     결제 금액 (위젯에 표시했던 금액과 정확히 일치해야 함)
     * @return null이면 성공, 실패면 에러 메시지 문자열 반환
     */
    public String confirmPayment(String paymentKey, String orderId, int amount) {
        try {
            URL url = new URL("https://api.tosspayments.com/v1/payments/confirm");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");

            String encodedAuth = Base64.getEncoder().encodeToString((tossSecretKey + ":").getBytes(StandardCharsets.UTF_8));
            conn.setRequestProperty("Authorization", "Basic " + encodedAuth);
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setDoOutput(true);

            String body = "{\"paymentKey\":\"" + paymentKey + "\",\"orderId\":\"" + orderId + "\",\"amount\":" + amount + "}";
            try (OutputStream os = conn.getOutputStream()) {
                os.write(body.getBytes(StandardCharsets.UTF_8));
            }

            int status = conn.getResponseCode();
            InputStreamReader isr = new InputStreamReader(
                    status == 200 ? conn.getInputStream() : conn.getErrorStream(), StandardCharsets.UTF_8);
            BufferedReader br = new BufferedReader(isr);
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) sb.append(line);
            br.close();

            if (status == 200) return null; // 승인 성공

            JsonNode json = new ObjectMapper().readTree(sb.toString());
            return json.path("message").asText("토스 결제승인 요청이 거절되었습니다.");

        } catch (Exception e) {
            return "토스 승인 API 호출 중 오류가 발생했습니다: " + e.getMessage();
        }
    }
}
