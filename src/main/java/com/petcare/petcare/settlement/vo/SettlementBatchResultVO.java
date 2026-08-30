/**
 * 역할: 월정산 생성·15일 자동지급 배치 결과
 * 2026/08/05 장우철 — S12
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
public class SettlementBatchResultVO {

    private String settleMonth;   // YYYY-MM
    private int stayCreated;
    private int staySkipped;      // 대상없음 / 이미 REGULAR 있음
    private int stayFailed;
    private int storeCreated;
    private int storeSkipped;
    private int storeFailed;
    private int stayPaid;
    private int storePaid;

    public int getTotalCreated() {
        return stayCreated + storeCreated;
    }

    public int getTotalPaid() {
        return stayPaid + storePaid;
    }
}
