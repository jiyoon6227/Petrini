/**
 * 2026/07/28 장우철 — 금결원 오픈뱅킹 (계좌실명조회)
 *
 * - mock=true  : 입력값으로 인증 성공 연출 (시뮬레이터 권한 없을 때)
 * - mock=false : testapi 토큰(oob) + /v2.0/inquiry/real_name 실호출
 *
 * properties
 * - kftc.openbanking.mock
 * - kftc.openbanking.base-url
 * - kftc.openbanking.client-id / client-secret
 */
package com.petcare.petcare.common.external.service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.concurrent.ThreadLocalRandom;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.petcare.petcare.common.external.vo.KftcRealNameResultVO;

@Service
public class KftcOpenBankingService {

    @Value("${kftc.openbanking.mock:true}")
    private boolean mock;

    @Value("${kftc.openbanking.base-url:https://testapi.openbanking.or.kr}")
    private String baseUrl;

    @Value("${kftc.openbanking.client-id:}")
    private String clientId;

    @Value("${kftc.openbanking.client-secret:}")
    private String clientSecret;

    private final ObjectMapper objectMapper = new ObjectMapper();

    // 2026/07/28 장우철 — 토큰 캐시 (oob 는 refresh 없음)
    private String cachedAccessToken;
    private String cachedClientUseCode;
    private long tokenExpireAtMs;

    public boolean isMock() {
        return mock;
    }

    /**
     * 2026/07/28 장우철 — 계좌실명조회
     * @param holderInfoType "1"=사업자번호, " "=생년월일6자리
     * @param holderInfo     사업자번호10자리 또는 생년월일6자리
     * @param expectedHolder 화면 입력 예금주 (mock 시 응답명으로 사용, real 시 참고)
     */
    public KftcRealNameResultVO inquireRealName(String bankCodeStd,
                                                String bankName,
                                                String accountNum,
                                                String holderInfoType,
                                                String holderInfo,
                                                String expectedHolder,
                                                StringBuilder outError) {
        KftcRealNameResultVO result = new KftcRealNameResultVO();
        result.setBankCodeStd(bankCodeStd);
        result.setBankName(bankName);
        result.setAccountNum(accountNum);
        result.setMock(mock);

        if (!StringUtils.hasText(bankCodeStd) || !StringUtils.hasText(accountNum)) {
            fail(result, outError, "은행과 계좌번호를 확인해 주세요.");
            return result;
        }
        if (!StringUtils.hasText(expectedHolder)) {
            fail(result, outError, "예금주를 입력해 주세요.");
            return result;
        }

        String digitsAcct = accountNum.replaceAll("[^0-9]", "");
        if (digitsAcct.length() < 8) {
            fail(result, outError, "계좌번호 형식이 올바르지 않습니다.");
            return result;
        }
        result.setAccountNum(digitsAcct);

        if (mock) {
            // 더미: 입력 예금주를 인증된 예금주로 확정
            result.setSuccess(true);
            result.setAccountHolderName(expectedHolder.trim());
            result.setMessage("계좌 인증 완료 (더미)");
            return result;
        }

        try {
            String token = getAccessToken(outError);
            if (token == null) {
                result.setSuccess(false);
                result.setMessage(outError != null && outError.length() > 0
                        ? outError.toString() : "토큰 발급에 실패했습니다.");
                return result;
            }

            String bankTranId = buildBankTranId();
            String tranDtime = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
            String type = StringUtils.hasText(holderInfoType) ? holderInfoType : "1";
            String info = holderInfo != null ? holderInfo.replaceAll("[^0-9]", "") : "";

            Map<String, Object> body = new LinkedHashMap<>();
            body.put("bank_tran_id", bankTranId);
            body.put("bank_code_std", bankCodeStd);
            body.put("account_num", digitsAcct);
            body.put("account_holder_info_type", type);
            body.put("account_holder_info", info);
            body.put("tran_dtime", tranDtime);

            HttpResult http = postJson(baseUrl + "/v2.0/inquiry/real_name",
                    objectMapper.writeValueAsString(body), token);
            JsonNode json = objectMapper.readTree(http.body);

            String rspCode = json.path("rsp_code").asText("");
            String bankRsp = json.path("bank_rsp_code").asText("");
            if ("A0000".equals(rspCode) && ("000".equals(bankRsp) || !StringUtils.hasText(bankRsp))) {
                String holderName = json.path("account_holder_name").asText(expectedHolder.trim());
                String respBankName = json.path("bank_name").asText(null);
                result.setSuccess(true);
                result.setAccountHolderName(holderName);
                if (StringUtils.hasText(respBankName)) {
                    result.setBankName(respBankName);
                }
                result.setMessage("계좌 인증 완료");
                return result;
            }

            String msg = firstNonBlank(
                    json.path("bank_rsp_message").asText(null),
                    json.path("rsp_message").asText(null),
                    "계좌 실명조회에 실패했습니다.");
            fail(result, outError, msg);
            return result;
        } catch (Exception e) {
            fail(result, outError, "계좌 실명조회 중 오류: " + e.getMessage());
            return result;
        }
    }

    private synchronized String getAccessToken(StringBuilder outError) throws Exception {
        long now = System.currentTimeMillis();
        if (StringUtils.hasText(cachedAccessToken) && now < tokenExpireAtMs - 60_000L) {
            return cachedAccessToken;
        }
        if (!StringUtils.hasText(clientId) || !StringUtils.hasText(clientSecret)
                || clientId.startsWith("여기에_")) {
            failMsg(outError, "금결원 Client ID/Secret 을 application.properties 에 설정하세요.");
            return null;
        }

        String form = "client_id=" + URLEncoder.encode(clientId, StandardCharsets.UTF_8)
                + "&client_secret=" + URLEncoder.encode(clientSecret, StandardCharsets.UTF_8)
                + "&grant_type=client_credentials"
                + "&scope=oob";

        HttpResult http = postForm(baseUrl + "/oauth/2.0/token", form);
        JsonNode json = objectMapper.readTree(http.body);
        String accessToken = json.path("access_token").asText(null);
        if (!StringUtils.hasText(accessToken)) {
            failMsg(outError, firstNonBlank(
                    json.path("rsp_message").asText(null),
                    json.path("error_description").asText(null),
                    "토큰 발급 실패"));
            return null;
        }

        cachedAccessToken = accessToken;
        cachedClientUseCode = json.path("client_use_code").asText("");
        long expiresIn = json.path("expires_in").asLong(3600L);
        tokenExpireAtMs = now + Math.max(60L, expiresIn) * 1000L;
        return cachedAccessToken;
    }

    /** 이용기관코드(10) + U + 난수(9) */
    private String buildBankTranId() {
        String org = StringUtils.hasText(cachedClientUseCode) ? cachedClientUseCode : "M000000000";
        if (org.length() > 10) {
            org = org.substring(0, 10);
        } else if (org.length() < 10) {
            org = String.format("%-10s", org).replace(' ', '0');
        }
        int n = ThreadLocalRandom.current().nextInt(100_000_000, 1_000_000_000);
        return org + "U" + n;
    }

    private HttpResult postJson(String url, String jsonBody, String bearerToken) throws Exception {
        HttpURLConnection conn = (HttpURLConnection) new URL(url).openConnection();
        conn.setRequestMethod("POST");
        conn.setConnectTimeout(15000);
        conn.setReadTimeout(20000);
        conn.setDoOutput(true);
        conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
        conn.setRequestProperty("Accept", "application/json");
        if (StringUtils.hasText(bearerToken)) {
            conn.setRequestProperty("Authorization", "Bearer " + bearerToken);
        }
        byte[] bytes = jsonBody.getBytes(StandardCharsets.UTF_8);
        try (OutputStream os = conn.getOutputStream()) {
            os.write(bytes);
        }
        return readResponse(conn);
    }

    private HttpResult postForm(String url, String formBody) throws Exception {
        HttpURLConnection conn = (HttpURLConnection) new URL(url).openConnection();
        conn.setRequestMethod("POST");
        conn.setConnectTimeout(15000);
        conn.setReadTimeout(20000);
        conn.setDoOutput(true);
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8");
        conn.setRequestProperty("Accept", "application/json");
        byte[] bytes = formBody.getBytes(StandardCharsets.UTF_8);
        try (OutputStream os = conn.getOutputStream()) {
            os.write(bytes);
        }
        return readResponse(conn);
    }

    private HttpResult readResponse(HttpURLConnection conn) throws Exception {
        int status = conn.getResponseCode();
        BufferedReader reader = new BufferedReader(new InputStreamReader(
                status >= 400 && conn.getErrorStream() != null
                        ? conn.getErrorStream()
                        : conn.getInputStream(),
                StandardCharsets.UTF_8));
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            sb.append(line);
        }
        reader.close();
        return new HttpResult(status, sb.toString());
    }

    private void fail(KftcRealNameResultVO result, StringBuilder outError, String msg) {
        result.setSuccess(false);
        result.setMessage(msg);
        failMsg(outError, msg);
    }

    private void failMsg(StringBuilder outError, String msg) {
        if (outError != null) {
            outError.setLength(0);
            outError.append(msg);
        }
    }

    private String firstNonBlank(String... values) {
        if (values == null) {
            return null;
        }
        for (String v : values) {
            if (StringUtils.hasText(v)) {
                return v;
            }
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
