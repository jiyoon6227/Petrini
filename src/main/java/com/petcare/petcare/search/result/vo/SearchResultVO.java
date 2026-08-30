/**
 * 역할: 통합 검색 결과 데이터 객체
 *
 * 참고 테이블
 * - TB_PRODUCT
 * - TB_HOSPITAL
 * - TB_STAY
 * - TB_POST
 *
 * DB 컬럼명은 팀 VO 규칙(camelCase)에 맞게 작성
 */

package com.petcare.petcare.search.result.vo;

public class SearchResultVO {

    private long id;
    private String name;
    private String meta;

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getMeta() {
        return meta;
    }

    public void setMeta(String meta) {
        this.meta = meta;
    }
}
