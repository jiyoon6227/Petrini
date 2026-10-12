package com.petcare.petcare.admin.main.vo;

import java.util.List;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AdminStatsVO {

    // 이번 달 요약 카드

    private long monthSalesAmount;      // (집계) — 이번 달 총 매출 (원)
    private int monthNewMemberCount;    // (집계) — 이번 달 신규 가입 (TB_MEMBER.JOIN_DATE)
    private int monthReservationCount;  // (집계) — 이번 달 예약 건수 (TB_RESERVATION.REG_DATE)
    private int monthOrderCount;        // (집계) — 이번 달 주문 수 (TB_ORDER.ORDER_DATE)

    // 차트 데이터

    private List<AdminMainSalesDayVO> monthlySalesTrendList;   // (목록) — 월별 매출 추이 (6개월)
    private List<AdminMainSalesDayVO> monthlyMemberTrendList; // (목록) — 월별 신규 가입 (6개월)
    private List<AdminMainSalesDayVO> categoryResvOrderList;  // (목록) — 업종별 예약/주문

    // 전월 대비 증감률

    private double monthSalesChangeRate;       // (계산) — 매출 증감률 (%)
    private double monthNewMemberChangeRate;   // (계산) — 신규 가입 증감률 (%)
    private double monthReservationChangeRate; // (계산) — 예약 증감률 (%)
    private double monthOrderChangeRate;       // (계산) — 주문 증감률 (%)
}
