/**
 * 역할: 통합 검색 비즈니스 로직 (interface)
 *
 * 담당 화면
 * - search/result.jsp         검색 결과
 * - 헤더 자동완성 (AJAX)
 *
 * 연결
 * - 구현: SearchResultServiceImpl
 * - 호출: SearchResultController
 * - DB: SearchResultMapper
 *
 * 참고 테이블
 * - TB_PRODUCT
 * - TB_HOSPITAL
 * - TB_STAY
 * - TB_POST
 */

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
