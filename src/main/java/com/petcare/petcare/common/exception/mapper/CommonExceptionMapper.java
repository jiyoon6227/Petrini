/**
 * 역할: 예외 로그 DB 접근 (MyBatis interface)
 *
 * XML: resources/mybatis/mapper/common/exception/CommonExceptionMapper.xml
 * namespace: com.petcare.petcare.common.exception.mapper.CommonExceptionMapper
 *
 * 쿼리 예시
 * - insertErrorLog
 *
 * 참고 테이블
 * - TB_ERROR_LOG
 *
 * SQL은 XML에만 작성 (@Select 등 어노테이션 사용 X)
 * 메서드명은 Service에서 호출하는 이름과 동일하게
 */

package com.petcare.petcare.common.exception.mapper;

import org.apache.ibatis.annotations.Mapper;


@Mapper
public interface CommonExceptionMapper {}
