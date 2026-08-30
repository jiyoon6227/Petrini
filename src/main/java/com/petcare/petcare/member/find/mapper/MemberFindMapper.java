/**
 * 역할: 회원 찾기 DB 접근 (MyBatis interface)
 *
 * XML: resources/mybatis/mapper/member/find/MemberFindMapper.xml
 * namespace: com.petcare.petcare.member.find.mapper.MemberFindMapper
 *
 * 쿼리 예시
 * - selectMemberByEmail
 * - updatePassword
 *
 * 참고 테이블
 * - TB_MEMBER
 *
 * SQL은 XML에만 작성 (@Select 등 어노테이션 사용 X)
 * 메서드명은 Service에서 호출하는 이름과 동일하게
 */

package com.petcare.petcare.member.find.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.member.find.vo.MemberFindVO;


@Mapper
public interface MemberFindMapper {
    /** 아이디 찾기: 이름 + 전화번호로 회원 조회 */
    MemberFindVO selectByNameAndPhone(@Param("memberName") String memberName,
    @Param("phone") String phone);

    /** 비밀번호 찾기: 이메일 + 이름으로 회원 조회 */
    MemberFindVO selectByEmailAndName(@Param("email") String email,
            @Param("memberName") String memberName);
    
    /** 비밀번호 변경 (임시 비밀번호 저장) */
    int updatePassword(@Param("memberNo") Long memberNo,
    @Param("newPassword") String newPassword);
}
