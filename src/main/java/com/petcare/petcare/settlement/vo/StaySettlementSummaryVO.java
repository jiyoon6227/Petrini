/**
 * 역할: 사업자 정산 상단 요약 3칸 (예정/완료/수수료)
 * 2026/07/30 장우철 — 숙소 정산 구현순서 2-1
 */
package com.petcare.petcare.settlement.vo;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@ToString
@NoArgsConstructor
public class StaySettlementSummaryVO {

    private Long pendingAmount; // 정산 예정액 (미지급): 미정산 DONE 예약 + 저장됐지만 미지급 건
    private Long paidAmount;    // 정산 완료액 (이번 달 입금): 이번 달 PAY_STATUS=DONE 합
    private Long totalFeeAmount; // 누적 플랫폼 수수료: 해당 사업자 정산 수수료 합
}
