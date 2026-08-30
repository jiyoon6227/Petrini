/**
 * 역할: 관리자 인증 DB 접근 (MyBatis interface)
 *
 * XML: resources/mybatis/mapper/admin/main/AdminAuthMapper.xml
 * namespace: com.petcare.petcare.admin.main.mapper.AdminAuthMapper
 *
 * 쿼리 예시
 * - selectAdminByLoginId
 *
 * 참고 테이블
 * - TB_MEMBER
 *
 * SQL은 XML에만 작성 (@Select 등 어노테이션 사용 X)
 * 메서드명은 Service에서 호출하는 이름과 동일하게
 */

package com.petcare.petcare.admin.main.mapper;

import org.apache.ibatis.annotations.Mapper;


@Mapper
public interface AdminAuthMapper {}
