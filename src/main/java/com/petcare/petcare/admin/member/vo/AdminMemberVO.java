/**
 * 역할: 관리자 회원 목록·상세 데이터 객체
 *
 * - 박유정 / 2026-07-16 (기본정보), 2026-07-20 (STEP 8 활동현황)
 * - 박유정 / 2026-07-21 (STEP 10 포인트 요약, STEP 11 주문)
 *
 * 참고 테이블
 * - TB_MEMBER, TB_BUSINESS
 * - TB_ORDER, TB_RESERVATION, TB_POST, TB_POST_REPORT
 * - TB_MEMBER_COUPON, TB_FAVORITE, TB_PET, TB_POINT
 */

package com.petcare.petcare.admin.member.vo;

import java.time.LocalDateTime;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AdminMemberVO {

    // ── TB_MEMBER 컬럼 ──────────────────────────────────────

    private Long memberNo;              // MEMBER_NO — 회원 번호 (PK)
    private String memberName;          // MEMBER_NAME — 이름
    private String email;               // EMAIL — 이메일
    private String phone;               // PHONE — 전화번호
    private String memberId;            // MEMBER_ID — 로그인 ID
    private String zipCode;             // ZIP_CODE — 우편번호
    private String addr1;               // ADDR1 — 주소
    private String addr2;               // ADDR2 — 상세주소
    private String gradeCd;             // GRADE_CD — 등급 (BRONZE/SILVER/GOLD)
    private Integer pointBalance;         // POINT_BALANCE — 보유 포인트
    private String statusCd;              // STATUS_CD — 상태 (NORMAL/정지/탈퇴)
    private LocalDateTime joinDate;       // JOIN_DATE — 가입일
    private LocalDateTime lastLoginDate;  // LAST_LOGIN_DATE — 최근 로그인
    private LocalDateTime suspendEndDate; // SUSPEND_END_DATE — 기간 정지 종료일 (NULL=영구)

    // ── 조회 전용 (JOIN·계산) ───────────────────────────────

    private String roleType;            // (계산) — GENERAL(일반) / BIZ(사업자)

    // ── 관리자 상세 활동 현황 / 2026-07-20 STEP 8 ─────────────

    private Integer orderCount;          // (집계) — 총 주문 수
    private Long totalPayAmount;         // (집계) — 총 결제 금액
    private Integer cancelCount;         // (집계) — 취소/반품 건수
    private Integer hospitalResvCount;   // (집계) — 병원 예약 수
    private Integer postCount;           // (집계) — 커뮤니티 게시글 수
    private Integer reportCount;         // (집계) — 신고 받은 횟수 (내 글 기준)
    private Integer usedCouponCount;     // (집계) — 사용 쿠폰 수
    private Integer favoriteCount;       // (집계) — 관심 상품 수
    private Integer petCount;            // (집계) — 등록 반려동물 수
    private String petNames;             // (집계) — 반려동물 이름 (쉼표 구분)

    // ── 관리자 상세 포인트 요약 / 2026-07-21 STEP 10 ──────────

    private Integer totalEarnPoint;    // (집계) — 총 적립 (TB_POINT EARN 합계)
    private Integer totalUsePoint;       // (집계) — 총 사용 (TB_POINT USE 합계)

    // ── 활동 누적 / HYJ 26.07.28 ─────────────────────────────

    private int posts;                   // POST_COUNT — 게시글 수 (TB_MEMBER)
    private int comments;                // COMMENT_COUNT — 댓글 수 (TB_MEMBER)
    private int adminPostDelCount;       // ADMIN_POST_DEL_COUNT — 관리자 게시글 삭제 횟수
    private int adminCommentDelCount;    // ADMIN_COMMENT_DEL_COUNT — 관리자 댓글 삭제 횟수
}
