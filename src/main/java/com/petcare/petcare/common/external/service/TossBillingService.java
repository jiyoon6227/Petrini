/**
 * 2026/07/27 장우철 — 토스 자동결제(빌링) API 연동
 *
 * 키
 * - toss.billing.client-key / toss.billing.secret-key  (API 개별 연동 키)
 * - 결제위젯 키(toss.client-key / toss.secret-key) 와 섞지 않음
 *
 * API
 * - 빌링키 발급: POST /v1/billing/authorizations/issue
 * - 자동결제 승인: POST /v1/billing/{billingKey}
 *
 * 이후 Ajax
 * - 카드등록 콜백 → issueBillingKey → BillingCardService.registerCard
 * - 등록카드 결제 → approveBilling (결제창 없이)
 */
package com.petcare.petcare.common.external.service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.LinkedHashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.petcare.petcare.common.billing.vo.BillingApproveResultVO;
import com.petcare.petcare.common.billing.vo.BillingIssueResultVO;

@Service
public class TossBillingService {

    // 2026/07/27 장우철 — 빌링 전용 클라이언트/시크릿 키 (위젯 키와 분리)
    @Value("${toss.billing.client-key}")
    private String billingClientKey;

    @Value("${toss.billing.secret-key}")
    private String billingSecretKey;

    private final ObjectMapper objectMapper = new ObjectMapper();

    // 2026/07/27 장우철 — 프론트 requestBillingAuth 용 클라이언트 키
    public String getBillingClientKey() {
        return billingClientKey;
    }

    /**
     * 2026/07/27 장우철 — authKey + customerKey 로 빌링키 발급
     * @return 성공 시 BillingIssueResultVO, 실패 시 null (에러 메시지는 outError 에 담음)
     */
    public BillingIssueResultVO issueBillingKey(String authKey, String customerKey, StringBuilder outError) {
        try {
            String body = objectMapper.writeValueAsString(Map.of(
                    "authKey", authKey,
                    "customerKey", customerKey
            ));

            HttpResult result = postJson("https://api.tosspayments.com/v1/billing/authorizations/issue", body);
            JsonNode json = objectMapper.readTree(result.body);

            if (result.status == 200) {
                BillingIssueResultVO vo = new BillingIssueResultVO();
                vo.setBillingKey(json.path("billingKey").asText(null));
                vo.setCustomerKey(json.path("customerKey").asText(customerKey));
                vo.setMethod(json.path("method").asText(null));

                JsonNode card = json.path("card");
                if (!card.isMissingNode() && !card.isNull()) {
                    // 토스 응답: card.company / card.number (마스킹)
                    vo.setCardCompany(firstNonBlank(
                            card.path("company").asText(null),
                            card.path("issuerCode").asText(null)));
                    vo.setCardNumber(card.path("number").asText(null));
                }
                return vo;
            }

            if (outError != null) {
                outError.append(json.path("message").asText("토스 빌링키 발급이 거절되었습니다."));
            }
            return null;
        } catch (Exception e) {
            if (outError != null) {
                outError.append("토스 빌링키 발급 중 오류: ").append(e.getMessage());
            }
            return null;
        }
    }

    /**
     * 2026/07/27 장우철 — 등록카드(빌링키) 자동결제 승인
     * @return 성공 시 paymentKey 포함 VO, 실패 시 null (outError 에 메시지)
     */
    public BillingApproveResultVO approveBilling(String billingKey, String customerKey, int amount,
                                                 String orderId, String orderName,
                                                 StringBuilder outError) {
        try {
            Map<String, Object> payload = new LinkedHashMap<>();
            payload.put("customerKey", customerKey);
            payload.put("amount", amount);
            payload.put("orderId", orderId);
            payload.put("orderName", orderName);

            String body = objectMapper.writeValueAsString(payload);
            String url = "https://api.tosspayments.com/v1/billing/" + billingKey;

            HttpResult result = postJson(url, body);
            JsonNode json = objectMapper.readTree(result.body);

            if (result.status == 200) {
                BillingApproveResultVO vo = new BillingApproveResultVO();
                vo.setPaymentKey(json.path("paymentKey").asText(null));
                vo.setOrderId(json.path("orderId").asText(orderId));
                vo.setMethod(json.path("method").asText(null));
                if (json.path("totalAmount").canConvertToInt()) {
                    vo.setTotalAmount(json.path("totalAmount").asInt());
                }
                return vo;
            }

            if (outError != null) {
                outError.append(json.path("message").asText("토스 자동결제 승인이 거절되었습니다."));
            }
            return null;
        } catch (Exception e) {
            if (outError != null) {
                outError.append("토스 자동결제 승인 중 오류: ").append(e.getMessage());
            }
            return null;
        }
    }

    // 2026/07/27 장우철 — Basic auth + JSON POST 공통
    private HttpResult postJson(String urlStr, String body) throws Exception {
        URL url = new URL(urlStr);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setConnectTimeout(8000);
        conn.setReadTimeout(15000);

        String encodedAuth = Base64.getEncoder()
                .encodeToString((billingSecretKey + ":").getBytes(StandardCharsets.UTF_8));
        conn.setRequestProperty("Authorization", "Basic " + encodedAuth);
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setDoOutput(true);

        try (OutputStream os = conn.getOutputStream()) {
            os.write(body.getBytes(StandardCharsets.UTF_8));
        }

        int status = conn.getResponseCode();
        InputStreamReader isr = new InputStreamReader(
                status >= 200 && status < 300 ? conn.getInputStream() : conn.getErrorStream(),
                StandardCharsets.UTF_8);
        BufferedReader br = new BufferedReader(isr);
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = br.readLine()) != null) {
            sb.append(line);
        }
        br.close();
        return new HttpResult(status, sb.toString());
    }

    private static String firstNonBlank(String a, String b) {
        if (a != null && !a.isBlank()) {
            return a;
        }
        if (b != null && !b.isBlank()) {
            return b;
        }
        return null;
    }

    private static class HttpResult {
        final int status;
        final String body;

        HttpResult(int status, String body) {
            this.status = status;
            this.body = body;
        }
    }
}
