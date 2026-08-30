/**
 * 2026/07/27 장우철 — 회원가입 세션 임시저장 VO
 *
 * 용도
 * - 토스 카드등록으로 /join 을 떠날 때 폼·약관·이메일인증 상태 보관
 * - 복귀 후 join.jsp 가 GET /join/draft 로 읽어 화면 복원
 *
 * 세션 키: "joinDraft" (MemberAuthController)
 * 주의: password 는 서버 세션에만 잠시 보관, 가입 성공 시 삭제
 */
package com.petcare.petcare.member.auth.vo;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class JoinDraftVO {

    /** 복귀 후 열 step (보통 2) */
    private Integer step;

    // ── Step1 약관 ──
    private Boolean agreeService;
    private Boolean agreePrivacy;
    private Boolean agreeLocation;
    private Boolean agreeMarketing;

    // ── Step2 기본정보 ──
    private String memberId;      // input#id
    private String email;
    private String password;
    private String passwordConfirm;
    private String memberName;
    private String phone;
    private String birthDate;
    private String gender;
    private String zipcode;
    private String addr1;
    private String addr2;

    // ── 이메일 인증 플래그 (JS 변수 복원용) ──
    private Boolean emailChecked;
    private Boolean emailVerified;
    // 2026/08/11 장우철 — 아이디 중복확인 플래그 (카드등록 왕복 시 복원)
    private Boolean idChecked;
}
