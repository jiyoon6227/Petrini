/**
 * 역할: 재능나눔 참여 신청 데이터 객체
 *
 * - 박유정 / 2026-08-10 — STEP 2 (일반 회원 → TB_TALENT_APPLY)
 *
 * 참고 테이블
 * - TB_TALENT_APPLY
 * - TB_MEMBER (JOIN — nickname, memberName, phone)
 * - TB_TALENT (JOIN — title)
 *
 * [STATUS_CD]
 * - PENDING   신청함 (병원 확인 대기)
 * - CONFIRMED 병원 확인 완료
 * - CANCELLED 취소
 */

package com.petcare.petcare.give.talent.vo;

import java.time.LocalDateTime;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class GiveTalentApplyVO {

    // ── TB_TALENT_APPLY 컬럼 ─────────────────────────────────────

    private Long applyId;           // APPLY_ID — 신청 번호 (PK)
    private Long talentId;          // TALENT_ID — 재능나눔 글 FK
    private Long memberNo;          // MEMBER_NO — 신청 회원 FK
    private String message;         // MESSAGE — 신청 메시지 (선택)
    private String statusCd;        // STATUS_CD — PENDING / CONFIRMED / CANCELLED
    private LocalDateTime regDate;  // REG_DATE — 신청일
    private LocalDateTime confirmDate; // CONFIRM_DATE — 병원 확인일

    // ── 조회 전용 (JOIN) ─────────────────────────────────────────

    private String nickname;        // TB_MEMBER.NICKNAME
    private String memberName;      // TB_MEMBER.MEMBER_NAME
    private String phone;           // TB_MEMBER.PHONE
    private String talentTitle;     // TB_TALENT.TITLE
}
