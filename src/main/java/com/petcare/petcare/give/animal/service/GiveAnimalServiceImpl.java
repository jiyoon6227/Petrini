package com.petcare.petcare.give.animal.service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.petcare.petcare.give.animal.vo.GiveAnimalListResult;
import com.petcare.petcare.give.vo.AbandonmentVO;

@Service
public class GiveAnimalServiceImpl implements GiveAnimalService {

    // 정부 유기동물 API 기본 주소
    private static final String BASE_URL =
            "https://apis.data.go.kr/1543061/abandonmentPublicService_v2/abandonmentPublic_v2";
    private static final int PAGE_SIZE = 20;      // 한 페이지에 20마리
    private static final int SEARCH_DAYS = 30;    // 최근 30일 데이터만 조회

    @Value("${public.service-api-key}")
    private String serviceKey;  // application.properties 에 있는 API 키

    private final ObjectMapper objectMapper = new ObjectMapper();

    // [최적화 1 - 캐싱] 같은 검색 조건으로 다시 조회하면 API 대신 저장값 사용 (Controller 의 "조건 후 조회"와 함께 씀)
    // - 첫 조회: 느릴 수 있음 → Controller 가 search=false 일 때 API 자체를 안 부름
    // - 같은 조건 재조회: 여기 캐시가 빠르게 응답
    @Override
    @Cacheable(
        value = "animalList", 
        key = "T(java.util.Objects).toString(#sido, '') + '_' + " +
              "T(java.util.Objects).toString(#upkind, '') + '_' + " +
              "T(java.util.Objects).toString(#state, '') + '_' + #pageNo"
    )
    public GiveAnimalListResult getAnimalList(
            String sido, String upkind, String state, int pageNo) {
        try {
            DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyyMMdd");
            String bgnde = LocalDate.now().minusDays(SEARCH_DAYS).format(fmt);
            String endde = LocalDate.now().format(fmt);

            StringBuilder url = new StringBuilder(BASE_URL);
            url.append("?serviceKey=").append(URLEncoder.encode(serviceKey, StandardCharsets.UTF_8));
            url.append("&bgnde=").append(bgnde);
            url.append("&endde=").append(endde);
            url.append("&pageNo=").append(pageNo);
            url.append("&numOfRows=").append(PAGE_SIZE);
            url.append("&_type=json");
            
            if (sido != null && !sido.isBlank()) {
                url.append("&upr_cd=").append(sido.trim());
            }
        
            if (upkind != null && !upkind.isBlank()) {
                url.append("&upkind=").append(upkind.trim());
            }
            if (state != null && !state.isBlank()) {
                url.append("&state=").append(state.trim());
            }

            // 2~3. API 호출 후 JSON → VO 리스트
            JsonNode body = readApiBody(url.toString());
            int totalCount = body.path("totalCount").asInt(0);
            JsonNode items = body.path("items").path("item");

            List<AbandonmentVO> animals = new ArrayList<>();
            if (items.isArray()) {
                for (JsonNode item : items) {
                    animals.add(AbandonmentVO.parseItem(item, fmt));
                }
            } else if (items.isObject() && !items.isEmpty()) {
                animals.add(AbandonmentVO.parseItem(items, fmt));
            }

            GiveAnimalListResult result = new GiveAnimalListResult();
            result.setAnimals(animals);
            result.setTotalCount(totalCount);
            result.setPageNo(pageNo);
            result.setTotalPages((int) Math.ceil((double) totalCount / PAGE_SIZE));
            result.setApiError(false);
            return result;
        } catch (Exception e) {
            e.printStackTrace();
            return GiveAnimalListResult.error(e.getMessage());
        }
    }

    // 상세는 desertionNo 기준 캐싱
    @Override
    @Cacheable(value = "animalDetail", key = "#desertionNo")
    public AbandonmentVO getAnimalDetail(String desertionNo) throws Exception {
        StringBuilder url = new StringBuilder(BASE_URL);
        url.append("?serviceKey=").append(URLEncoder.encode(serviceKey, StandardCharsets.UTF_8));
        url.append("&desertion_no=").append(URLEncoder.encode(desertionNo, StandardCharsets.UTF_8));
        url.append("&_type=json");

        JsonNode items = readApiBody(url.toString()).path("items").path("item");
        JsonNode item = items.isArray() ? items.get(0) : items;
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyyMMdd");
        return AbandonmentVO.parseItem(item, fmt);
    }

    /** API 호출 → JSON 에서 본문(body) 부분만 꺼냄 */
    private JsonNode readApiBody(String apiUrl) throws Exception {
        String json = callApi(apiUrl);
        return objectMapper.readTree(json).path("response").path("body");
    }

    /** 정부 API 서버에 GET 요청 보내고, 응답 문자열 받기 */
    private String callApi(String apiUrl) throws Exception {
        HttpURLConnection conn = (HttpURLConnection) new URL(apiUrl).openConnection();
        conn.setRequestMethod("GET");
        conn.setConnectTimeout(10000);
        conn.setReadTimeout(30000);
        conn.setRequestProperty("Accept", "application/json");
        if (conn.getResponseCode() != 200) {
            throw new RuntimeException("API 오류: HTTP " + conn.getResponseCode());
        }
        try (BufferedReader br = new BufferedReader(
                new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                sb.append(line);
            }
            return sb.toString();
        }
    }
}