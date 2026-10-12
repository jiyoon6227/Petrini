/** TB_ADMIN 조회 결과용 (TB_MEMBER와 컬럼이 다름), 세션에는 MemberVO(role=ADMIN) 사용 */

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
