package com.petcare.petcare.member.find.service;

public interface MemberFindService {
    /**
     * 아이디 찾기 (이름 + 전화번호)
     * @return 마스킹된 이메일(아이디). 없으면 null
     */
    String findMemberId(String memberName, String phone);
    
    /**
     * 비밀번호 찾기 (이메일 + 이름)
     * 임시 비밀번호를 생성하여 DB 저장 + 이메일 발송
     * @return null이면 성공, 문자열이면 오류 메시지
     */
    String resetPassword(String email, String memberName);    
}
