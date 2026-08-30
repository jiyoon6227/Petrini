/**
 * 2026/07/07 장우철 — join(회원가입) 이메일 중복 확인 응답 VO
 *
 * GET /join/check-email → join.jsp [중복 확인] Ajax 에 JSON 으로 반환
 */
package com.petcare.petcare.member.auth.vo;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class EmailCheckResultVO {

    private final boolean available; // 가입 가능 여부 — true: 사용 가능, false: 중복 또는 형식 오류
    private final String message;    // join.jsp 에 보여줄 안내 문구
}
