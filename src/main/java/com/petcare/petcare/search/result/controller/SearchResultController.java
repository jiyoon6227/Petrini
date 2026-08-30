/**
 * 역할: 통합 검색 URL 처리 → Service 호출 → JSP 반환
 *
 * 연결
 * - Service: SearchResultService
 *
 * SQL·비즈니스 로직은 넣지 말 것 → Service로 위임
 * return 경로는 담당 JSP와 동일하게 맞출 것
 */

package com.petcare.petcare.search.result.controller;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.petcare.petcare.search.SearchItem;
import com.petcare.petcare.search.SearchSection;
import com.petcare.petcare.search.result.service.SearchResultService;

@Controller
public class SearchResultController {

    private final SearchResultService searchService;

    public SearchResultController(SearchResultService searchService) {
        this.searchService = searchService;
    }

    /** 검색 결과 페이지 */
    @GetMapping("/search")
    public String search(@RequestParam(required = false, defaultValue = "") String q, Model model) {
        String keyword = q == null ? "" : q.trim();
        List<SearchSection> sections = searchService.search(keyword);

        model.addAttribute("keyword", keyword);
        model.addAttribute("sections", sections);
        model.addAttribute("totalCount", searchService.countResults(sections));
        return "search/result";
    }

    /**
     * 자동완성 API (AJAX)
     * GET /search/autocomplete?q=키워드
     * 응답: { ok: true, data: [ { category, title, meta, url }, ... ] }
     */
    @GetMapping("/search/autocomplete")
    @ResponseBody
    public Map<String, Object> autocomplete(@RequestParam(required = false, defaultValue = "") String q) {
        Map<String, Object> result = new LinkedHashMap<>();
        String keyword = q == null ? "" : q.trim();

        if (keyword.length() < 1) {
            result.put("ok", true);
            result.put("data", List.of());
            return result;
        }

        List<SearchSection> sections = searchService.autocomplete(keyword);

        // SearchSection → 평탄화된 리스트로 변환
        List<Map<String, String>> items = new ArrayList<>();
        for (SearchSection section : sections) {
            for (SearchItem item : section.getItems()) {
                Map<String, String> row = new LinkedHashMap<>();
                row.put("category", item.getCategoryLabel());
                row.put("title", item.getTitle());
                row.put("meta", item.getMeta());
                row.put("url", item.getUrl());
                items.add(row);
            }
        }

        result.put("ok", true);
        result.put("data", items);
        return result;
    }
}
