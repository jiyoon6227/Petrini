/**
 * 역할: 정산 배치 (월정산 생성 · 15일 더미 자동지급) — 숙소/쇼핑 공용
 * 2026/08/05 장우철 — S12
 *
 * 규칙
 * - 월정산: REQUEST_TYPE=REGULAR, 전월 1일~말일, 사업자당 월 1건
 * - 중간정산으로 이미 ITEM 잡힌 건은 엔진 NOT EXISTS 로 제외
 * - 15일 지급: PAY_STATUS=WAIT 만 더미 DONE (FAIL은 관리자 수동입금)
 */
package com.petcare.petcare.settlement.service;

import java.util.Calendar;
import java.util.Date;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.admin.settlement.mapper.AdminSettlementMapper;
import com.petcare.petcare.admin.settlement.service.AdminSettlementService;
import com.petcare.petcare.settlement.mapper.StaySettlementMapper;
import com.petcare.petcare.settlement.mapper.StoreSettlementMapper;
import com.petcare.petcare.settlement.vo.SettlementBatchResultVO;

@Service
public class SettlementBatchService {

    @Autowired
    private StaySettlementService staySettlementService;

    @Autowired
    private StoreSettlementService storeSettlementService;

    @Autowired
    private StaySettlementMapper staySettlementMapper;

    @Autowired
    private StoreSettlementMapper storeSettlementMapper;

    @Autowired
    private AdminSettlementMapper adminSettlementMapper;

    @Autowired
    @Lazy
    private AdminSettlementService adminSettlementService;

    /**
     * 지정월(YYYY-MM) 월정산 생성. null 이면 전월.
     */
    public SettlementBatchResultVO createMonthlySettlements(String settleMonthYyyyMm) {
        Period period = resolveMonthPeriod(settleMonthYyyyMm);
        SettlementBatchResultVO result = new SettlementBatchResultVO();
        result.setSettleMonth(period.settleMonth);

        List<Long> stayBizNos = staySettlementMapper.selectApprovedStayBizNos();
        if (stayBizNos != null) {
            for (Long bizNo : stayBizNos) {
                try {
                    if (staySettlementMapper.countRegularByBizAndMonth(bizNo, period.settleMonth) > 0) {
                        result.setStaySkipped(result.getStaySkipped() + 1);
                        continue;
                    }
                    staySettlementService.createAndSaveStaySettlement(
                            bizNo, period.start, period.end, null, "REGULAR", "ALL");
                    result.setStayCreated(result.getStayCreated() + 1);
                } catch (IllegalArgumentException e) {
                    // 대상 0건 등 — 정상 스킵
                    result.setStaySkipped(result.getStaySkipped() + 1);
                } catch (Exception e) {
                    result.setStayFailed(result.getStayFailed() + 1);
                    System.out.println("===== 숙소 월정산 실패 bizNo=" + bizNo + ": " + e.getMessage() + " =====");
                }
            }
        }

        List<Long> storeBizNos = storeSettlementMapper.selectApprovedStoreBizNos();
        if (storeBizNos != null) {
            for (Long bizNo : storeBizNos) {
                try {
                    if (storeSettlementMapper.countRegularByBizAndMonth(bizNo, period.settleMonth) > 0) {
                        result.setStoreSkipped(result.getStoreSkipped() + 1);
                        continue;
                    }
                    storeSettlementService.createAndSaveStoreSettlement(
                            bizNo, period.start, period.end, null, "REGULAR", "ALL");
                    result.setStoreCreated(result.getStoreCreated() + 1);
                } catch (IllegalArgumentException e) {
                    result.setStoreSkipped(result.getStoreSkipped() + 1);
                } catch (Exception e) {
                    result.setStoreFailed(result.getStoreFailed() + 1);
                    System.out.println("===== 쇼핑 월정산 실패 bizNo=" + bizNo + ": " + e.getMessage() + " =====");
                }
            }
        }

        return result;
    }

    /**
     * WAIT 상태 정산 전부 더미 지급 (숙소+쇼핑). FAIL은 제외.
     */
    @Transactional
    public SettlementBatchResultVO autoPayWaitingSettlements() {
        SettlementBatchResultVO result = new SettlementBatchResultVO();

        List<Long> stayIds = adminSettlementMapper.selectStayWaitSettleIds();
        if (stayIds != null) {
            for (Long id : stayIds) {
                try {
                    int n = adminSettlementService.payStaySettlement(id);
                    if (n > 0) {
                        result.setStayPaid(result.getStayPaid() + 1);
                    }
                } catch (Exception e) {
                    System.out.println("===== 숙소 자동지급 실패 settleId=" + id + ": " + e.getMessage() + " =====");
                }
            }
        }

        List<Long> storeIds = adminSettlementMapper.selectStoreWaitSettleIds();
        if (storeIds != null) {
            for (Long id : storeIds) {
                try {
                    int n = adminSettlementService.payStoreSettlement(id);
                    if (n > 0) {
                        result.setStorePaid(result.getStorePaid() + 1);
                    }
                } catch (Exception e) {
                    System.out.println("===== 쇼핑 자동지급 실패 settleId=" + id + ": " + e.getMessage() + " =====");
                }
            }
        }

        return result;
    }

    private Period resolveMonthPeriod(String settleMonthYyyyMm) {
        Calendar cal = Calendar.getInstance();
        if (settleMonthYyyyMm != null && settleMonthYyyyMm.matches("\\d{4}-\\d{2}")) {
            int year = Integer.parseInt(settleMonthYyyyMm.substring(0, 4));
            int month = Integer.parseInt(settleMonthYyyyMm.substring(5, 7)); // 1-12
            cal.set(Calendar.YEAR, year);
            cal.set(Calendar.MONTH, month - 1);
        } else {
            // 전월
            cal.add(Calendar.MONTH, -1);
        }
        cal.set(Calendar.DAY_OF_MONTH, 1);
        truncate(cal);
        Date start = cal.getTime();

        String settleMonth = String.format("%04d-%02d",
                cal.get(Calendar.YEAR), cal.get(Calendar.MONTH) + 1);

        cal.set(Calendar.DAY_OF_MONTH, cal.getActualMaximum(Calendar.DAY_OF_MONTH));
        truncate(cal);
        Date end = cal.getTime();

        Period p = new Period();
        p.settleMonth = settleMonth;
        p.start = start;
        p.end = end;
        return p;
    }

    private void truncate(Calendar cal) {
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
    }

    private static class Period {
        String settleMonth;
        Date start;
        Date end;
    }
}
