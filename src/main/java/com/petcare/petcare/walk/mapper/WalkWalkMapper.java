/**
 * 역할: 산책로 DB 접근 (MyBatis interface)
 *
 * XML: resources/mybatis/mapper/walk/WalkWalkMapper.xml
 * namespace: com.petcare.petcare.walk.mapper.WalkWalkMapper
 *
 * 쿼리 예시
 * - selectWalkList
 * - selectWalkDetail
 *
 * 참고 테이블
 * - TB_WALK_COURSE
 *
 * SQL은 XML에만 작성 (@Select 등 어노테이션 사용 X)
 * 메서드명은 Service에서 호출하는 이름과 동일하게
 */

package com.petcare.petcare.walk.mapper;

import org.apache.ibatis.annotations.Mapper;


@Mapper
public interface WalkWalkMapper {}
