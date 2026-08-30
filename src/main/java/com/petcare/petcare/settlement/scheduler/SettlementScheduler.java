/**
 * 역할: 정산 스케줄러 — 매월 1일 월정산 생성 / 매월 15일 더미 자동지급
 * 2026/08/05 장우철 — S12 (숙소·쇼핑)
 *
 * cron: 초 분 시 일 월 요일
 * - 1일 02:00 → 전월 REGULAR 월정산
 * - 15일 03:00 → WAIT 더미 지급
 */
package com.petcare.petcare.settlement.scheduler;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.petcare.petcare.settlement.service.SettlementBatchService;
import com.petcare.petcare.settlement.vo.SettlementBatchResultVO;

@Component
public class SettlementScheduler {

    @Autowired
    private SettlementBatchService settlementBatchService;

    /** 매월 1일 02:00 — 전월 월정산 생성 (숙소+쇼핑) */
    @Scheduled(cron = "0 0 2 1 * *")
    public void createMonthlySettlements() {
        System.out.println("===== 월정산 자동생성 시작 =====");
        try {
            SettlementBatchResultVO r = settlementBatchService.createMonthlySettlements(null);
            System.out.println("===== 월정산 자동생성 종료: month=" + r.getSettleMonth()
                    + " stayCreated=" + r.getStayCreated()
                    + " storeCreated=" + r.getStoreCreated()
                    + " staySkip=" + r.getStaySkipped()
                    + " storeSkip=" + r.getStoreSkipped()
                    + " stayFail=" + r.getStayFailed()
                    + " storeFail=" + r.getStoreFailed()
                    + " =====");
        } catch (Exception e) {
            System.out.println("===== 월정산 자동생성 오류: " + e.getMessage() + " =====");
        }
    }

    /** 매월 15일 03:00 — WAIT 더미 자동지급 (숙소+쇼핑). FAIL은 제외 */
    @Scheduled(cron = "0 0 3 15 * *")
    public void autoPaySettlements() {
        System.out.println("===== 정산 자동지급(더미) 시작 =====");
        try {
            SettlementBatchResultVO r = settlementBatchService.autoPayWaitingSettlements();
            System.out.println("===== 정산 자동지급(더미) 종료: stayPaid=" + r.getStayPaid()
                    + " storePaid=" + r.getStorePaid() + " =====");
        } catch (Exception e) {
            System.out.println("===== 정산 자동지급 오류: " + e.getMessage() + " =====");
        }
    }
}
