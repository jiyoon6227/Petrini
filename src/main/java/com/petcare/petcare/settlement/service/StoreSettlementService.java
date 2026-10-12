/**
 * 역할: 쇼핑 정산 계산·저장 (interface)
 * 쇼핑 정산
 * 사업자 요약/목록/상세 · 중간요청
 *
 * 구현: StoreSettlementServiceImpl
 */
package com.petcare.petcare.settlement.service;

import java.util.Date;
import java.util.List;

import com.petcare.petcare.biz.store.vo.BizProductVO;
import com.petcare.petcare.settlement.vo.StoreSettlementItemVO;
import com.petcare.petcare.settlement.vo.StoreSettlementRequestVO;
import com.petcare.petcare.settlement.vo.StoreSettlementSummaryVO;
import com.petcare.petcare.settlement.vo.StoreSettlementVO;

public interface StoreSettlementService {

    void fillItemAmounts(StoreSettlementItemVO item);

    StoreSettlementVO aggregateItems(Long bizNo, List<StoreSettlementItemVO> items);

    StoreSettlementVO buildStoreSettlementDraft(
            Long bizNo,
            Date periodStart,
            Date periodEnd,
            Long productId,
            String requestType,
            String requestScope);

    StoreSettlementVO saveStoreSettlement(StoreSettlementVO draft);

    StoreSettlementVO createAndSaveStoreSettlement(
            Long bizNo,
            Date periodStart,
            Date periodEnd,
            Long productId,
            String requestType,
            String requestScope);

    StoreSettlementSummaryVO getStoreSettlementSummary(Long bizNo);

    List<StoreSettlementVO> getStoreSettlementList(Long bizNo, String settleMonth, String statusCd);

    List<String> getStoreSettlementMonths(Long bizNo);

    List<StoreSettlementItemVO> getStoreSettlementItems(Long bizNo, Long settleId);

    List<BizProductVO> getProductsForSettlement(Long bizNo);

    StoreSettlementRequestVO createMidSettlementRequest(
            Long bizNo,
            String requestScope,
            Long productId,
            Date targetEnd,
            String requestMemo);

    StoreSettlementRequestVO getSettlementRequest(Long requestId);

    StoreSettlementVO approveMidSettlementRequest(Long requestId);

    void rejectMidSettlementRequest(Long requestId, String rejectReason);
}
