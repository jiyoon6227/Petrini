/**
 * 역할: SearchResultService 구현체 (@Service)
 *
 * 구현 내용
 * - 키워드 통합 검색 (상품·병원·숙소·커뮤니티)
 * - 자동완성 (영역별 최대 3건씩)
 * - 결과 페이지 (영역별 최대 20건씩)
 *
 * 연결
 * - 호출: SearchResultController
 * - 사용: SearchResultMapper
 */

package com.petcare.petcare.search.result.service;

import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Service;

import com.petcare.petcare.search.SearchItem;
import com.petcare.petcare.search.SearchSection;
import com.petcare.petcare.search.result.mapper.SearchResultMapper;
import com.petcare.petcare.search.result.vo.SearchResultVO;

@Service
public class SearchResultServiceImpl implements SearchResultService {

    private final SearchResultMapper searchMapper;

    public SearchResultServiceImpl(SearchResultMapper searchMapper) {
        this.searchMapper = searchMapper;
    }

    /**
     * 결과 페이지용 통합 검색 (영역별 최대 20건)
     */
    @Override
    public List<SearchSection> search(String keyword) {
        if (keyword == null || keyword.isBlank()) {
            return List.of();
        }
        return buildSections(keyword, 20);
    }

    /**
     * 자동완성용 통합 검색 (영역별 최대 3건)
     */
    @Override
    public List<SearchSection> autocomplete(String keyword) {
        if (keyword == null || keyword.isBlank()) {
            return List.of();
        }
        return buildSections(keyword, 3);
    }

    @Override
    public int countResults(List<SearchSection> sections) {
        int total = 0;
        for (SearchSection section : sections) {
            total += section.getItems().size();
        }
        return total;
    }

    // ── 내부 메서드 ──

    /**
     * 4개 영역(상품·병원·숙소·커뮤니티)을 검색하여
     * 결과가 있는 영역만 SearchSection 리스트로 반환
     */
    private List<SearchSection> buildSections(String keyword, int limit) {
        List<SearchSection> sections = new ArrayList<>();

        // 상품 — StoreShopController.detail: GET /store/detail?id=
        List<SearchResultVO> products = searchMapper.searchProducts(keyword, limit);
        if (!products.isEmpty()) {
            sections.add(new SearchSection("쇼핑", toItems(products, "store", "쇼핑", "/store/detail?id=")));
        }

        // 병원 — HospitalController.detail: GET /hospital/detail?id=
        List<SearchResultVO> hospitals = searchMapper.searchHospitals(keyword, limit);
        if (!hospitals.isEmpty()) {
            sections.add(new SearchSection("병원", toItems(hospitals, "hospital", "병원", "/hospital/detail?id=")));
        }

        // 숙소 — StayController.detail: GET /stay/detail?id=
        List<SearchResultVO> stays = searchMapper.searchStays(keyword, limit);
        if (!stays.isEmpty()) {
            sections.add(new SearchSection("숙소", toItems(stays, "stay", "숙소", "/stay/detail?id=")));
        }

        // 커뮤니티
        List<SearchResultVO> posts = searchMapper.searchPosts(keyword, limit);
        if (!posts.isEmpty()) {
            // CommunityPostController 상세 라우트: GET /community/detail?id=번호
            sections.add(new SearchSection("커뮤니티", toItems(posts, "community", "커뮤니티", "/community/detail?id=")));
        }

        return sections;
    }

    /**
     * SearchResultVO 리스트 → SearchItem 리스트 변환
     */
    private List<SearchItem> toItems(List<SearchResultVO> voList,
                                      String categoryKey,
                                      String categoryLabel,
                                      String urlPrefix) {
        List<SearchItem> items = new ArrayList<>();
        for (SearchResultVO vo : voList) {
            SearchItem item = new SearchItem();
            item.setCategoryKey(categoryKey);
            item.setCategoryLabel(categoryLabel);
            item.setTitle(vo.getName());
            item.setMeta(vo.getMeta() != null ? vo.getMeta() : "");
            item.setUrl(urlPrefix + vo.getId());
            item.setSearchText(vo.getName());
            items.add(item);
        }
        return items;
    }
}
