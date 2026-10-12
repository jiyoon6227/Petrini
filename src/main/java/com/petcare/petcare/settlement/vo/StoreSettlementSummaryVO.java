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
