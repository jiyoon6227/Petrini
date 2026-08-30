package com.petcare.petcare.petmap.controller;

import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.petcare.petcare.common.config.controller.CommonConfigController;
import com.petcare.petcare.common.external.service.KakaoMapService;
import com.petcare.petcare.petmap.vo.PetMapVO;

@Controller("petmapController")
@RequestMapping("/petmap")
public class PetmapMapController extends CommonConfigController {
    @Autowired
    private KakaoMapService kakaoMapService;
      
    String listUrl = "https://apis.data.go.kr/B551011/KorPetTourService2/areaBasedList2";
    String catUrl  = "https://apis.data.go.kr/B551011/KorPetTourService2/categoryCode2";

    // contenttypeid → 한글 라벨 매핑 (JSP에서 뱃지 표시용)
    private static final Map<String, String> TYPE_LABELS = new HashMap<>();
    static {
        TYPE_LABELS.put("12", "관광지");
        TYPE_LABELS.put("14", "문화시설");
        TYPE_LABELS.put("15", "축제/행사");
        TYPE_LABELS.put("25", "여행코스");
        TYPE_LABELS.put("28", "레포츠");
        TYPE_LABELS.put("32", "숙박");
        TYPE_LABELS.put("38", "쇼핑");
        TYPE_LABELS.put("39", "음식점");
    }

    @GetMapping({"", "/"})
    public String list(@RequestParam(defaultValue = "1") int pageNo,
                       @RequestParam(required = false) String contentTypeId,
                       @RequestParam(required = false) String areaCode,
                       @RequestParam(required = false) String cat1,
                       @RequestParam(required = false) String cat2,
                       @RequestParam(defaultValue = "false") boolean search,
                       Model model) {

        List<PetMapVO> places = new ArrayList<>();

        // ── 필터 상태를 JSP로 전달 (검색 전/후 모두) ──
        model.addAttribute("contentTypeId", contentTypeId != null ? contentTypeId : "");
        model.addAttribute("areaCode", areaCode != null ? areaCode : "");
        model.addAttribute("cat1", cat1 != null ? cat1 : "");
        model.addAttribute("cat2", cat2 != null ? cat2 : "");
        model.addAttribute("searched", search);
        model.addAttribute("typeLabels", TYPE_LABELS);

        // ★ [조회] 안 눌렀으면 API 호출 스킵 → 페이지 즉시 로딩
        if (!search) {
            model.addAttribute("places", places);
            model.addAttribute("totalCount", 0);
            model.addAttribute("pageNo", 1);
            model.addAttribute("totalPages", 0);
            kakaoMapService.addMapAttributes(model, places);
            model.addAttribute("skipAutoMarkers", "true");
            return "petmap/list";
        }

        // ── [조회] 눌렀을 때만 API 호출 ──
        try {
            StringBuilder sb = new StringBuilder(listUrl);
            sb.append("?serviceKey=").append(URLEncoder.encode(apiService.publicServiceApiKey, "UTF-8"));
            sb.append("&numOfRows=").append(commonUtilController.pageSize);
            sb.append("&pageNo=").append(pageNo);
            sb.append("&MobileOS=WIN");
            sb.append("&MobileApp=PetCare");
            sb.append("&_type=json");

            if (contentTypeId != null && !contentTypeId.isEmpty()) {
                sb.append("&contentTypeId=").append(contentTypeId);
            }
            if (areaCode != null && !areaCode.isEmpty()) {
                sb.append("&areaCode=").append(areaCode);
            }
            if (cat1 != null && !cat1.isEmpty()) {
                sb.append("&cat1=").append(cat1);
            }
            if (cat2 != null && !cat2.isEmpty()) {
                sb.append("&cat2=").append(cat2);
            }

            String json = apiService.callApi(sb.toString());
            ObjectMapper mapper = new ObjectMapper();
            JsonNode root = mapper.readTree(json);
            JsonNode body = root.path("response").path("body");
            int totalCount = body.path("totalCount").asInt(0);
            JsonNode items = body.path("items").path("item"); 
            
            if (items.isArray()) {
                for (JsonNode item : items) 
                    places.add(PetMapVO.parseItem(item));
            } 
            else if (items.isObject() && !items.isEmpty()) {
                places.add(PetMapVO.parseItem(items));
            }

            model.addAttribute("totalCount", totalCount);
            model.addAttribute("pageNo", pageNo);
            model.addAttribute("totalPages", (int) Math.ceil((double) totalCount / commonUtilController.pageSize));
        } 
        catch (Exception e) {
            model.addAttribute("totalCount", 0);
            model.addAttribute("pageNo", 1);
            model.addAttribute("totalPages", 0);
            model.addAttribute("errorMsg", e.getMessage());
        }

        // 하위 카테고리 목록 조회
        if (contentTypeId != null && !contentTypeId.isEmpty()) {
            List<Map<String, String>> cat1List = getCategoryCodes(contentTypeId, null);
            model.addAttribute("cat1List", cat1List);
        }
        if (cat1 != null && !cat1.isEmpty()) {
            List<Map<String, String>> cat2List = getCategoryCodes(contentTypeId, cat1);
            model.addAttribute("cat2List", cat2List);
        }

        kakaoMapService.addMapAttributes(model, places);
        model.addAttribute("skipAutoMarkers", "true");
        model.addAttribute("places", places);

        return "petmap/list";
    }

    private List<Map<String, String>> getCategoryCodes(String contentTypeId, String parentCat1) {
        List<Map<String, String>> result = new ArrayList<>();
        try {
            String encodedKey = URLEncoder.encode(apiService.publicServiceApiKey, "UTF-8");
            StringBuilder sb = new StringBuilder(catUrl);
            sb.append("?serviceKey=").append(encodedKey);
            sb.append("&MobileOS=WIN&MobileApp=PetCare&_type=json");
            sb.append("&contentTypeId=").append(contentTypeId);
            if (parentCat1 != null) {
                sb.append("&cat1=").append(parentCat1);
            }

            String json = apiService.callApi(sb.toString());
            ObjectMapper mapper = new ObjectMapper();
            JsonNode items = mapper.readTree(json)
                    .path("response").path("body").path("items").path("item");

            if (items.isArray()) {
                for (int i = 0; i < items.size(); i++) {
                    JsonNode item = items.get(i);
                    Map<String, String> code = new HashMap<>();
                    code.put("code", item.path("code").asText(""));
                    code.put("name", item.path("name").asText(""));
                    result.add(code);
                }
            } else if (items.isObject() && !items.isEmpty()) {
                Map<String, String> code = new HashMap<>();
                code.put("code", items.path("code").asText(""));
                code.put("name", items.path("name").asText(""));
                result.add(code);
            }
        } catch (Exception e) {
            // 빈 리스트 반환
        }
        return result;
    }
}