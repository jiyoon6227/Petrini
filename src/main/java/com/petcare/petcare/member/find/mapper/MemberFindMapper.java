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
