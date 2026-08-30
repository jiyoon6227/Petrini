/**
 * 역할: 관리자 회원 상세 — 포인트 이력 1건
 *
 * - 박유정 / 2026-07-21 STEP 10
 *
 * 참고 테이블: TB_POINT
 *
 * [POINT_TYPE]
 * - EARN  적립
 * - USE   사용
 *
 * [REASON_CD]
 * - ADMIN_GRANT   관리자 지급
 * - ADMIN_DEDUCT  관리자 차감
 */

package com.petcare.petcare.admin.member.vo;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AdminMemberPointVO {

    // ── TB_POINT 컬럼 ──────────────────────────────────────────

    private Long pointId;         // POINT_ID — 포인트 이력 번호 (PK)
    private String pointType;     // POINT_TYPE — 유형 (EARN/USE)
    private Integer pointAmount;  // POINT_AMOUNT — 포인트 금액
    private Integer balanceAfter; // BALANCE_AFTER — 처리 후 잔액
    private String reasonCd;      // REASON_CD — 사유 코드
    private String reasonDetail;  // REF_ID — 관리자 입력 상세 사유
    private String regDate;       // REG_DATE — 처리일
}
