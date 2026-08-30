/**
 * 역할: 관리자 대시보드·통계용 데이터 객체
 *
 * - 박유정 / 2026-07-29 — Phase 1: 승인 대기 사업자 목록
 * - 박유정 / 2026-07-30 — ADMIN-01: 대시보드 통계·차트·최근주문
 *
 * 참고 테이블
 * - TB_MEMBER, TB_ORDER, TB_RESERVATION, TB_BUSINESS
 */

package com.petcare.petcare.admin.main.vo;

import java.util.List;

import com.petcare.petcare.admin.biz.vo.AdminBizVO;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AdminMainVO {

    // ── 사업자 승인 대기 / 2026-07-29 박유정 ───────────────────

    private List<AdminBizVO> pendingBizList; // (목록) — 승인 대기 사업자 (최대 5건)

    // ── 대시보드 상단 통계 카드 / 2026-07-30 박유정 ─────────────

    private int todayNewMemberCount;     // (집계) — 오늘 신규 가입자 (TB_MEMBER)
    private int todayOrderCount;         // (집계) — 오늘 주문 수 (TB_ORDER)
    private long todaySalesAmount;       // (집계) — 오늘 매출 원 (JSP 백만원 변환)
    private int pendingReservationCount; // (집계) — 미처리 예약 (PENDING+CONFIRMED)

    // ── 최근 주문 / 2026-07-30 박유정 ───────────────────────────

    private List<AdminMainOrderVO> recentOrderList; // (목록) — 최근 주문 (최대 5건)

    // ── 회원 현황 도넛 / 2026-07-30 박유정 ─────────────────────

    private int memberGeneralCount;    // (집계) — 일반회원 (탈퇴 제외, 사업자 미승인)
    private int memberBizCount;        // (집계) — 사업자 (TB_BUSINESS APPROVED)
    private int memberWithdrawnCount;  // (집계) — 탈퇴 (STATUS_CD=WITHDRAWN)

    // ── 매출 차트 / 2026-07-30 박유정 ───────────────────────────

    private List<AdminMainSalesDayVO> weeklySalesList;  // (목록) — 주간 매출 (최근 7일)
    private List<AdminMainSalesDayVO> monthlySalesList; // (목록) — 월간 매출 (이번 달)
}
