/**
 * 역할: 펫맵 DB 접근 (MyBatis interface)
 *
 * XML: resources/mybatis/mapper/petmap/PetmapMapMapper.xml
 * namespace: com.petcare.petcare.petmap.mapper.PetmapMapMapper
 *
 * 쿼리 예시
 * - selectBusinessByRegion
 * - selectBusinessByCategory
 *
 * 참고 테이블
 * - TB_BUSINESS
 *
 * SQL은 XML에만 작성 (@Select 등 어노테이션 사용 X)
 * 메서드명은 Service에서 호출하는 이름과 동일하게
 */

package com.petcare.petcare.petmap.mapper;

import org.apache.ibatis.annotations.Mapper;


@Mapper
public interface PetmapMapMapper {}
