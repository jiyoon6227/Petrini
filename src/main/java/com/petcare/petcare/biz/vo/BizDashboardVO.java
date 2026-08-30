/**
 * 역할: 사업자 대시보드 요약 데이터 객체 (숙소·병원 공용)
 *
 * 참고 테이블
 * - TB_RESERVATION
 * - TB_REVIEW
 * - TB_STAY_ROOM (숙소용)
 */
package com.petcare.petcare.biz.vo;

import java.util.List;

import lombok.Getter;
import lombok.Setter;

@Getter @Setter
public class BizDashboardVO {

    // ── 요약 카드 ──
    private int todayResvCount;       // 오늘 예약(체크인) 건수
    private int todayResvYesterday;   // 어제 예약 건수 (비교용)
    private int todayCancelCount;     // 지윤 26.08.13 추가: 오늘 취소·노쇼 건수 (병원용)
    private int pendingCount;         // 대기(진료 대기 / 체크아웃 예정) 건수
    private int pendingYesterday;     // 어제 대기 건수
    private int doneCount;            // 완료(진료 완료 / 체크아웃) 건수
    private int doneYesterday;        // 어제 완료 건수
    private long monthRevenue;        // 이번 달 매출
    private long monthRevenueYesterday; // 어제까지의 이번달 매출 (비교용)
    private int monthDoneCount;       // 지윤 26.08.13 추가: 이번 달 진료완료 건수 (병원용, 매출 대체)
    private int monthDoneYesterday;   // 지윤 26.08.13 추가: 어제까지의 이번 달 진료완료 건수

    // ── 상태 현황 (도넛 차트) ──
    private int totalStatusCount;
    private int statusConfirmed;
    private int statusPending;
    private int statusDone;
    private int statusCancel;
    // 숙소 전용
    private int statusCheckin;
    private int statusCheckout;

    // ── 차트 데이터 (일별) ──
    private List<String> chartLabels;      // ["08-01", "08-02", ...]
    private List<Integer> chartResvCounts; // [3, 5, 2, ...]
    private List<Long> chartRevenues;      // [150000, 300000, ...]
    private List<Integer> chartDoneCounts;   // 지윤 26.08.13 추가: 진료완료 건수 (병원용)
    private List<Integer> chartCancelCounts; // 지윤 26.08.13 추가: 취소·노쇼 건수 (병원용)

    // ── 차이값 계산 헬퍼 (JSP에서 사용) ──
    public int getResvDiff() { return todayResvCount - todayResvYesterday; }
    public int getPendingDiff() { return pendingCount - pendingYesterday; }
    public int getDoneDiff() { return doneCount - doneYesterday; }
    public long getRevenueDiff() { return monthRevenue - monthRevenueYesterday; }
    public int getMonthDoneDiff() { return monthDoneCount - monthDoneYesterday; }
}
