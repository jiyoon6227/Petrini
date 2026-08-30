package com.petcare.petcare.member.vo;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;

import org.springframework.stereotype.Component;

/* 2026/07/06 장우철 (수정)
 * memberNo , nickname 추가
 */
@Getter @Setter
@Component("memberVO")
public class MemberVO {

    // ── 로그인·세션에서 사용 (TB_MEMBER 기준) ──
    private Long memberNo;          // 회원번호 (PK) — TB_MEMBER.MEMBER_NO
    private String memberId;        // 로그인 ID (이메일) — TB_MEMBER.MEMBER_ID
    private String email;           // 이메일 — TB_MEMBER.EMAIL
    private String password;        // 비밀번호 (BCrypt) — 가입·변경 시에만 사용, 세션에는 보통 미저장
    private String memberName;      // 회원 실명 — TB_MEMBER.MEMBER_NAME
    private String nickname;        // 닉네임 — TB_MEMBER.NICKNAME
    private String phone;           // 휴대폰 번호 — TB_MEMBER.PHONE
    private String zipcode;         // 우편번호 — TB_MEMBER.ZIP_CODE
    private String addr1;           // 기본 주소 — TB_MEMBER.ADDR1
    private String addr2;           // 상세 주소 — TB_MEMBER.ADDR2
    private LocalDate birthDate;    // 생년월일 (join.jsp용, TB_MEMBER 컬럼 없음 — 추후 확장)
    private String gender;          // 성별 M/F (join.jsp용, TB_MEMBER 컬럼 없음 — 추후 확장)

    // ── 권한·역할 (세션에서 화면 분기용) ──
    private String role;            // USER / BIZ / ADMIN
    private String bizType;         // 사업자 유형 HOSPITAL, STAY, STORE 등 (BIZ일 때)
    private Long   adminNo;         // 2026/07/07 장우철 추가 — 관리자번호 (role=ADMIN일 때, TB_ADMIN.ADMIN_NO)
    private String status;          // 화면용 상태 (ACTIVE 등, DB STATUS_CD와 별도 사용 가능)

    // 2026/07/08 장우철 — 마이페이지 DB 연동 (A단계)
    // TB_MEMBER.POINT_BALANCE — 로그인 시 세션에 담아 사이드바·마이홈 보유 포인트 표시
    private Long pointBalance;      // 보유 포인트 — TB_MEMBER.POINT_BALANCE (가입 시 0)

    // 약관 동의 (요구사항: 서비스(필수)·개인정보(필수)·마케팅(선택))
    private String agreeService;    // Y/N
    private String agreePrivacy;    // Y/N
    private String agreeLocation;   // Y/N (선택)
    private String agreeMarketing;  // Y/N (선택)

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    private String profileImgUrl;   // PROFILE_IMG_URL — 프로필 사진 URL (세션·사이드바 표시)
}
