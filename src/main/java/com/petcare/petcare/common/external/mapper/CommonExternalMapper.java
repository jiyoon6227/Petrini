/**
 * 역할: 외부 API 로그 DB 접근 (MyBatis interface)
 *
 * XML: resources/mybatis/mapper/common/external/CommonExternalMapper.xml
 * namespace: com.petcare.petcare.common.external.mapper.CommonExternalMapper
 *
 * 쿼리 예시
 * - (쿼리 없음 — 외부 API 연동)
 *
 * 참고 테이블
 * - (해당 없음)
 *
 * SQL은 XML에만 작성 (@Select 등 어노테이션 사용 X)
 * 메서드명은 Service에서 호출하는 이름과 동일하게
 */

package com.petcare.petcare.common.external.mapper;

import org.apache.ibatis.annotations.Mapper;


@Mapper
public interface CommonExternalMapper {}
