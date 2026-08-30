/**
 * 역할: 로그인 시 TB_ADMIN 조회 결과를 담는 VO
 *
 * 2026/07/07 장우철 (신규)
 * 생성 이유:
 * - 관리자도 유저 홈(/login)에서 동일하게 로그인하도록 확장하면서,
 *   TB_MEMBER 와는 컬럼이 다른 TB_ADMIN 조회 결과를 따로 담기 위해 생성.
 * - 관리자 로그인 ID(ADMIN_ID)는 이메일 형식이 아니라 일반 아이디(admin).
 *
 * 사용 위치
 * - MemberAuthMapper(selectAdminByLoginId) → MemberAuthServiceImpl(login)
 *
 * 참고 테이블: TB_ADMIN
 *
 * ※ 세션(memberInfo)에는 MemberVO(role=ADMIN)를 사용하고,
 *   이 VO는 DB 조회·비밀번호 검증 단계에서만 사용
 */

package com.petcare.petcare.member.auth.vo;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AdminAuthVO {

    private Long   adminNo;    // 관리자번호 (PK) — TB_ADMIN.ADMIN_NO
    private String adminId;    // 관리자 로그인 ID (이메일 아님) — TB_ADMIN.ADMIN_ID
    private String adminPwd;   // 비밀번호 BCrypt 해시 — TB_ADMIN.ADMIN_PWD (세션에 넣지 않음)
    private String adminName;  // 관리자 이름 — TB_ADMIN.ADMIN_NAME
    private Long   roleId;     // 권한그룹 ID — TB_ADMIN.ROLE_ID (TB_ADMIN_ROLE FK)
    private String statusCd;   // 관리자 상태 — TB_ADMIN.STATUS_CD (NORMAL만 로그인 허용)
}
