/**
 * 역할: 통합 검색 DB 접근 (MyBatis interface)
 *
 * XML: resources/mybatis/mapper/search/result/SearchResultMapper.xml
 * namespace: com.petcare.petcare.search.result.mapper.SearchResultMapper
 *
 * 참고 테이블
 * - TB_PRODUCT
 * - TB_HOSPITAL
 * - TB_STAY
 * - TB_POST
 *
 * SQL은 XML에만 작성 (@Select 등 어노테이션 사용 X)
 * 메서드명은 Service에서 호출하는 이름과 동일하게
 */

package com.petcare.petcare.search.result.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.search.result.vo.SearchResultVO;

@Mapper
public interface SearchResultMapper {

    /** 상품 검색 (상품명·브랜드명 LIKE) */
    List<SearchResultVO> searchProducts(@Param("keyword") String keyword,
                                        @Param("limit") int limit);

    /** 병원 검색 (병원명·주소 LIKE) */
    List<SearchResultVO> searchHospitals(@Param("keyword") String keyword,
                                         @Param("limit") int limit);

    /** 숙소 검색 (숙소명·주소 LIKE) */
    List<SearchResultVO> searchStays(@Param("keyword") String keyword,
                                     @Param("limit") int limit);

    /** 커뮤니티 게시글 검색 (제목 LIKE) */
    List<SearchResultVO> searchPosts(@Param("keyword") String keyword,
                                     @Param("limit") int limit);
}
