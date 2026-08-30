package com.petcare.petcare.common.external.service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

@Service
public class SmartTrackerService {

    @Value("${smarttracker.api-key}")
    private String apiKey;

    /**
     * 지원 택배사 전체 목록 조회
     * @return [{id: "04", name: "CJ대한통운"}, ...] 형태의 리스트 (실패 시 빈 리스트)
     */
    public List<java.util.Map<String, String>> getCompanyList() {
        List<java.util.Map<String, String>> result = new ArrayList<>();
        try {
            String urlStr = "https://info.sweettracker.co.kr/api/v1/companylist?t_key=" + apiKey;
            URL url = new URL(urlStr);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");

            String body = readBody(conn);
            System.out.println("===== 택배사목록 API 원본 응답 =====");
            System.out.println(body);
            System.out.println("===================================");

            JsonNode root = new ObjectMapper().readTree(body);
            JsonNode companies = root.path("Company");
            for (JsonNode c : companies) {
                java.util.Map<String, String> item = new java.util.LinkedHashMap<>();
                item.put("id", c.path("Code").asText());
                item.put("name", c.path("Name").asText());
                result.add(item);
            }
        } catch (Exception e) {
            System.out.println("===== 택배사목록 API 에러 =====");
            e.printStackTrace();
        }
        return result;
    }

    /**
     * 운송장번호로 실시간 배송상태 조회
     * @param courierCode 스마트택배 택배사 코드 (예: "04")
     * @param trackingNo  운송장번호
     * @return 원본 JSON 응답 문자열 그대로 반환 (파싱은 화면 JS에서 처리)
     */
    public String getTrackingInfo(String courierCode, String trackingNo) {
        try {
            String params = "t_key=" + URLEncoder.encode(apiKey, StandardCharsets.UTF_8)
                    + "&t_code=" + URLEncoder.encode(courierCode, StandardCharsets.UTF_8)
                    + "&t_invoice=" + URLEncoder.encode(trackingNo, StandardCharsets.UTF_8);

            URL url = new URL("https://info.sweettracker.co.kr/api/v1/trackingInfo?" + params);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");

            return readBody(conn);
        } catch (Exception e) {
            return "{\"status\":false,\"msg\":\"조회 중 오류가 발생했습니다: " + e.getMessage() + "\"}";
        }
    }

    private String readBody(HttpURLConnection conn) throws Exception {
        int status = conn.getResponseCode();
        InputStreamReader isr = new InputStreamReader(
                status == 200 ? conn.getInputStream() : conn.getErrorStream(), StandardCharsets.UTF_8);
        BufferedReader br = new BufferedReader(isr);
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = br.readLine()) != null) sb.append(line);
        br.close();
        return sb.toString();
    }
}