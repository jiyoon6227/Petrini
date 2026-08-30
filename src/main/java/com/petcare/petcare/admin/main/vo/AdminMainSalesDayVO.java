/**
 * 역할: 대시보드·통계 차트 1일치(1구간) 데이터
 *
 * - 박유정 / 2026-07-30 — Phase 3-C: salesChart (대시보드)
 * - 박유정 / 2026-07-31 — ADMIN-04: stats 차트 재사용
 *
 * dayLabel / salesAmount 는 화면별로 의미가 달라짐
 * - 대시보드: 요일·일별 매출(원)
 * - 통계: 월·구분·건수 등 (Service/JSP에서 단위 변환)
 */

package com.petcare.petcare.admin.main.vo;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AdminMainSalesDayVO {

    private String dayLabel;    // (집계) — X축 라벨 (요일·일·월·구분)
    private long salesAmount;   // (집계) — 값 (원/명/건 — 화면별 단위 변환)
}
