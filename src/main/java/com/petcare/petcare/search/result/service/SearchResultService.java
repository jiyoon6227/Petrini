package com.petcare.petcare.search.result.service;

import java.util.List;

import com.petcare.petcare.search.SearchSection;

public interface SearchResultService {

    /** 결과 페이지용 통합 검색 */
    List<SearchSection> search(String keyword);

    /** 자동완성용 통합 검색 (영역별 최대 3건) */
    List<SearchSection> autocomplete(String keyword);

    /** 섹션별 결과 합계 */
    int countResults(List<SearchSection> sections);
}
