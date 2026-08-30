/**
 * 역할: 유기동물 DB 접근 (MyBatis interface)
 *
 * XML: resources/mybatis/mapper/give/animal/GiveAnimalMapper.xml
 * namespace: com.petcare.petcare.give.animal.mapper.GiveAnimalMapper
 *
 * 쿼리 예시
 * - selectAdoptionInterestList
 * - insertAdoptionInterest
 *
 * 참고 테이블
 * - TB_ADOPTION_INTEREST
 *
 * SQL은 XML에만 작성 (@Select 등 어노테이션 사용 X)
 * 메서드명은 Service에서 호출하는 이름과 동일하게
 */

package com.petcare.petcare.give.animal.mapper;

import org.apache.ibatis.annotations.Mapper;


@Mapper
public interface GiveAnimalMapper {}
