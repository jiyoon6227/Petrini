/**
 * 역할: 메인 홈 DB 접근 (MyBatis interface)
 *
 * XML: resources/mybatis/mapper/main/home/MainHomeMapper.xml
 * namespace: com.petcare.petcare.main.home.mapper.MainHomeMapper
 *
 * 쿼리 예시
 * - selectMainSections
 *
 * 참고 테이블
 * - TB_BANNER
 * - TB_PRODUCT
 *
 * SQL은 XML에만 작성 (@Select 등 어노테이션 사용 X)
 * 메서드명은 Service에서 호출하는 이름과 동일하게
 */

package com.petcare.petcare.main.home.mapper;

import org.apache.ibatis.annotations.Mapper;


@Mapper
public interface MainHomeMapper {}
