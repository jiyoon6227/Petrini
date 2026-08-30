/**
 * 역할: 관리자 통계 페이지 데이터 객체
 *
 * - 박유정 / 2026-07-30 — ADMIN-04 Phase 1: admin/stats/index.jsp 요약 카드
 * - 박유정 / 2026-07-31 — ADMIN-04 Phase 2~5: 차트·전월대비·CSV export
 *
 * 참고 테이블
 * - TB_ORDER, TB_MEMBER, TB_RESERVATION
 */

package com.petcare.petcare.admin.main.vo;

import java.util.List;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AdminStatsVO {

    // ── 이번 달 요약 카드 / 2026-07-30 박유정 ───────────────────

    private long monthSalesAmount;      // (집계) — 이번 달 총 매출 (원)
    private int monthNewMemberCount;    // (집계) — 이번 달 신규 가입 (TB_MEMBER.JOIN_DATE)
    private int monthReservationCount;  // (집계) — 이번 달 예약 건수 (TB_RESERVATION.REG_DATE)
    private int monthOrderCount;        // (집계) — 이번 달 주문 수 (TB_ORDER.ORDER_DATE)

    // ── 차트 데이터 / 2026-07-31 박유정 ─────────────────────────

    private List<AdminMainSalesDayVO> monthlySalesTrendList;   // (목록) — 월별 매출 추이 (6개월)
    private List<AdminMainSalesDayVO> monthlyMemberTrendList; // (목록) — 월별 신규 가입 (6개월)
    private List<AdminMainSalesDayVO> categoryResvOrderList;  // (목록) — 업종별 예약/주문

    // ── 전월 대비 증감률 / 2026-07-31 박유정 ───────────────────

    private double monthSalesChangeRate;       // (계산) — 매출 증감률 (%)
    private double monthNewMemberChangeRate;   // (계산) — 신규 가입 증감률 (%)
    private double monthReservationChangeRate; // (계산) — 예약 증감률 (%)
    private double monthOrderChangeRate;       // (계산) — 주문 증감률 (%)
}
