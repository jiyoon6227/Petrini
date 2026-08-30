/**
 * 역할: 아이디·비밀번호 찾기 데이터 객체
 *
 * 필드 예시
 * - memberId, email, memberName, phone
 *
 * 참고 테이블
 * - TB_MEMBER
 *
 * DB 컬럼명은 팀 VO 규칙(camelCase)에 맞게 작성
 */

package com.petcare.petcare.member.find.vo;

import lombok.Getter;
import lombok.Setter;

@Getter @Setter
public class MemberFindVO {
    private Long memberNo;
    private String memberId;
    private String memberName;
    private String email;
    private String phone;
}
