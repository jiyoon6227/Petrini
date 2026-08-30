package com.petcare.petcare.member.auth.exception;

/**
 * 로그인 차단 예외 — 탈퇴(WITHDRAWN) 등 로그인 불가 STATUS_CD
 * - 박유정 / 2026-07-22
 * - 정지(SUSPENDED)는 로그인 허용 → Controller에서 /member/cs 리다이렉트
 */
public class MemberLoginBlockedException extends RuntimeException {

    private final String errorCode;

    public MemberLoginBlockedException(String errorCode) {
        super(errorCode);
        this.errorCode = errorCode;
    }

    public String getErrorCode() {
        return errorCode;
    }
}
