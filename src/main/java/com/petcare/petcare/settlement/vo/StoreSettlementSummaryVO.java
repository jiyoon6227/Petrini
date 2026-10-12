/**
 * 역할: 쇼핑 사업자 정산 상단 요약 (예정/완료/수수료)
 * 쇼핑 정산 VO (사업자 화면 조회)
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
public class StoreSettlementSummaryVO {

    private Long pendingAmount;   // 정산 예정액 (미지급)
    private Long paidAmount;      // 정산 완료액
    private Long totalFeeAmount;  // 누적 플랫폼 수수료
}
