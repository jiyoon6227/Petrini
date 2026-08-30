/**
 * 2026/07/15 — 카카오 로그인
 *
 * 역할: 카카오 API 에서 받은 사용자 정보를 담는 VO
 * 사용 위치: KakaoOAuthService → MemberAuthController
 */
package com.petcare.petcare.member.auth.vo;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class KakaoUserVO {

    private String kakaoId;       // 카카오 고유 사용자 ID (숫자 → 문자열 저장)
    private String nickname;      // 카카오 프로필 닉네임
    private String email;         // 카카오 계정 이메일 (동의 시에만 존재)
    private String profileImage;  // 프로필 이미지 URL (선택)
}
