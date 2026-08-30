/**
 * 역할: 공통 설정 DB 접근 (MyBatis interface)
 *
 * XML: resources/mybatis/mapper/common/config/CommonConfigMapper.xml
 * namespace: com.petcare.petcare.common.config.mapper.CommonConfigMapper
 *
 * 쿼리 예시
 * - selectConfigList
 * - selectConfigByKey
 *
 * 참고 테이블
 * - TB_CONFIG
 *
 * SQL은 XML에만 작성 (@Select 등 어노테이션 사용 X)
 * 메서드명은 Service에서 호출하는 이름과 동일하게
 */

package com.petcare.petcare.common.config.mapper;

import org.apache.ibatis.annotations.Mapper;


@Mapper
public interface CommonConfigMapper {}
