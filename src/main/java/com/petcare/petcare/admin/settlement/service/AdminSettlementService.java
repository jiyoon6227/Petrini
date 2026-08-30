/**
 * 역할: 관리자 정산 비즈니스 로직 (interface)
 * 2026/07/30 장우철 — 숙소 STAY
 * 2026/08/05 장우철 — 쇼핑 STORE S11
 *
 * 담당 화면: admin/settlement/list.jsp
 */
package com.petcare.petcare.admin.settlement.service;

import java.util.List;

import com.petcare.petcare.admin.settlement.vo.AdminStayRequestVO;
import com.petcare.petcare.admin.settlement.vo.AdminStaySettlementVO;
import com.petcare.petcare.admin.settlement.vo.AdminStoreRequestVO;
import com.petcare.petcare.settlement.vo.SettlementBatchResultVO;
import com.petcare.petcare.settlement.vo.StaySettlementItemVO;
import com.petcare.petcare.settlement.vo.StaySettlementVO;
import com.petcare.petcare.settlement.vo.StoreSettlementItemVO;
import com.petcare.petcare.settlement.vo.StoreSettlementVO;

public interface AdminSettlementService {

    boolean isReady();

    int countStaySettlements(Long bizNo);

    List<AdminStaySettlementVO> getStaySettlementList(String statusCd);

    List<StaySettlementItemVO> getStaySettlementItems(Long settleId);

    int payStaySettlement(Long settleId);

    int payStaySettlements(List<Long> settleIds);

    int countStayMidRequestsRequested();

    List<AdminStayRequestVO> getStayRequestList(String statusCd);

    StaySettlementVO approveStayMidRequest(Long requestId);

    void rejectStayMidRequest(Long requestId, String rejectReason);

    // ===== STORE =====
    int countStoreSettlements(Long bizNo);

    List<AdminStaySettlementVO> getStoreSettlementList(String statusCd);

    List<StoreSettlementItemVO> getStoreSettlementItems(Long settleId);

    int payStoreSettlement(Long settleId);

    int payStoreSettlements(List<Long> settleIds);

    int countStoreMidRequestsRequested();

    List<AdminStoreRequestVO> getStoreRequestList(String statusCd);

    StoreSettlementVO approveStoreMidRequest(Long requestId);

    void rejectStoreMidRequest(Long requestId, String rejectReason);

    // ===== S12 배치 / FAIL =====
    SettlementBatchResultVO createMonthlySettlements(String settleMonth);

    SettlementBatchResultVO autoPayWaitingSettlements();

    int markStaySettlementFail(Long settleId);

    int markStoreSettlementFail(Long settleId);
}
