package com.petcare.petcare.common.external.service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

@Service
public class TossPaymentService {

    @Value("${toss.secret-key}")
    private String tossSecretKey;

    // 2026/08/01 장우철 — 빌링키 결제는 위젯 시크릿과 분리 (섞으면 cancel FORBIDDEN_REQUEST)
    @Value("${toss.billing.secret-key}")
    private String tossBillingSecretKey;

    public String cancelPayment(String paymentKey, String cancelReason) {
        return cancelPayment(paymentKey, cancelReason, null, false);
    }

    /**
     * 2026/07/31 장우철 — 숙소 부분환불: cancelAmount 있으면 해당 금액만 취소
     * @param cancelAmount null이면 전액 취소
     */
    public String cancelPayment(String paymentKey, String cancelReason, Long cancelAmount) {
        return cancelPayment(paymentKey, cancelReason, cancelAmount, false);
    }

    /**
     * 2026/08/01 장우철 — 빌링키로 승인된 결제는 billingSecret 으로 취소
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
            // 2026/07/31 장우철 — 토스 권장 멱등키 (중복 취소 방지)
            conn.setRequestProperty("Idempotency-Key", java.util.UUID.randomUUID().toString());
            conn.setDoOutput(true);

            String safeReason = cancelReason == null ? "취소" : cancelReason.replace("\"", "'");
            StringBuilder body = new StringBuilder("{\"cancelReason\":\"").append(safeReason).append("\"");
            if (cancelAmount != null && cancelAmount > 0) {
                body.append(",\"cancelAmount\":").append(cancelAmount);
            }
            body.append("}");
            try (OutputStream os = conn.getOutputStream()) {
                os.write(body.toString().getBytes(StandardCharsets.UTF_8));
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
     * 2026/08/11 장우철 — 카드 실결제 키가 아니면 토스 취소 스킵 (포인트·가짜키)
     */
    public static boolean isSkipCancelPaymentKey(String paymentKey) {
        if (paymentKey == null || paymentKey.isBlank()) return true;
        String k = paymentKey.trim();
        return k.startsWith("ZERO") || k.startsWith("POINT") || k.startsWith("BILLING-");
    }

    /**
     * 2026/08/11 장우철 — PAY_METHOD로 시크릿 선택.
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
