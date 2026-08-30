/**
 * 역할: FAQ(자주 묻는 질문) 데이터 객체
 *
 * - 박유정 / 2026-08-11 — FAQ CMS (관리자 등록 · 회원 고객센터 노출)
 *
 * 참고 테이블
 * - TB_FAQ
 *
 * [CATEGORY_CD]
 * - SERVICE  서비스
 * - ORDER    주문/배송
 * - MEMBER   회원
 * - RESERVE  예약
 *
 * [VISIBLE_YN]
 * - Y  노출
 * - N  숨김
 */

package com.petcare.petcare.admin.cms.vo;

import java.util.Date;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class FaqVO {

    // ── TB_FAQ 컬럼 ──────────────────────────────────────────────

    private Long faqId;           // FAQ_ID — FAQ 번호 (PK)
    private String categoryCd;    // CATEGORY_CD — 카테고리 (SERVICE/ORDER/MEMBER/RESERVE)
    private String question;      // QUESTION — 질문
    private String answer;        // ANSWER — 답변
    private String visibleYn;     // VISIBLE_YN — 노출 여부 (Y/N)
    private Integer sortOrder;    // SORT_ORDER — 정렬 순서 (작을수록 위)
    private Date regDate;         // REG_DATE — 등록일
    private Date modDate;         // MOD_DATE — 수정일
}
