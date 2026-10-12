/** dayLabel·salesAmount는 화면별 의미가 다름 (대시보드: 요일·일별 매출(원), 통계: 월·구분·건수) */

package com.petcare.petcare.admin.main.vo;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AdminMainSalesDayVO {

    private String dayLabel;    // (집계) — X축 라벨 (요일·일·월·구분)
    private long salesAmount;   // (집계) — 값 (원/명/건 — 화면별 단위 변환)
}
