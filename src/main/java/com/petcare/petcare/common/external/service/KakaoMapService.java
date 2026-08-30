/**
 * 역할: 카카오맵 API 연동 서비스 (@Service)
 *
 * 구현 내용
 * - 주소 → 좌표 변환 (Kakao Local API)
 * - Model에 mapLat, mapLng, kakaoJsApiKey 속성 추가
 *
 * 연결
 * - 호출: HospitalHospitalController, StayStayController 등
 *
 * 비즈니스 로직은 여기에 작성 (Controller, Mapper에 직접 작성 X)
 */

package com.petcare.petcare.common.external.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.ui.Model;

import com.fasterxml.jackson.databind.ObjectMapper;

@Service
public class KakaoMapService {
    @Value("${kakao.rest-api-key}")
    private String kakaoRestApiKey;

    @Value("${kakao.js-api-key}")
    private String kakaoJsApiKey; 
    
    /**
     * 주소 → 위경도 변환 (Kakao Local REST API)
     * 반환: {lat: 37.xxx, lng: 126.xxx} 또는 변환 실패 시 null
     */
    public Map<String, Double> geocodeAddress(String address) {
        if (address == null || address.isBlank()) {
            return null;
        }
    
        try {
            // 카카오 주소 검색 API 호출
            String apiUrl = "https://dapi.kakao.com/v2/local/search/address.json?analyze_type=similar&query="
                          + java.net.URLEncoder.encode(address, "UTF-8");
        
            java.net.HttpURLConnection conn = (java.net.HttpURLConnection)
                    new java.net.URL(apiUrl).openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("Authorization", "KakaoAK " + kakaoRestApiKey);
        
            // 응답 읽기
            java.io.BufferedReader br = new java.io.BufferedReader(
                    new java.io.InputStreamReader(conn.getInputStream(), "UTF-8"));
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                sb.append(line);
            }
            br.close();
        
            // JSON 파싱 → documents[0].y(위도), documents[0].x(경도)
            com.fasterxml.jackson.databind.JsonNode documents =
                    new ObjectMapper().readTree(sb.toString()).path("documents");
        
            if (documents.isArray() && documents.size() > 0) {
                Map<String, Double> result = new HashMap<>();
                result.put("lat", documents.get(0).path("y").asDouble());
                result.put("lng", documents.get(0).path("x").asDouble());
                return result;
            }
        } catch (Exception e) {
            // 변환 실패 시 null 반환 → 기존 좌표 유지
        }
    
        return null;
    }

    //리스트 다중마커용
    public void addMapAttributes(Model model, List<? extends Mapperable> list) {
        model.addAttribute("kakaoJsApiKey", kakaoJsApiKey);

        ObjectMapper mapper = new ObjectMapper();
        List<Map<String, Object>> markers = new ArrayList<>();

        //위치정보 있는 병원만 JSON 변환
        for (Mapperable item : list) {
            if (item.getMarkerLat() != null && item.getMarkerLng() != null) {
                Map<String, Object> marker = new HashMap<>();
                marker.put("id", item.getMarkerId());
                marker.put("name", item.getMarkerName());
                marker.put("lat", item.getMarkerLat());
                marker.put("lng", item.getMarkerLng());
                markers.add(marker);
            }
        }

        try {
            //Java 객체(List, Map)를 JSON문자열로 변환
            // [{"id":1,"name":"서울동물병원","lat":37.55,"lng":126.97}]
            String strJson = mapper.writeValueAsString(markers);
            //Controller -> JSP 전달
            //${markerJson}
            model.addAttribute("markersJson", strJson);
        } 
        catch (Exception e) {
            model.addAttribute("markersJson", "[]");
        }

        if (!markers.isEmpty()) {
            model.addAttribute("mapLat", markers.get(0).get("lat"));
            model.addAttribute("mapLng", markers.get(0).get("lng"));
        } 
        else {
            setFallback(model);
        }
    }
    
    //위경도값 없을시
    private void setFallback(Model model) {
        model.addAttribute("mapLat", "37.5665");
        model.addAttribute("mapLng", "126.9780");
    }
}
