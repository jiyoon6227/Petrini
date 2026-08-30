/**
 * 역할: 숙소 정산 계산·저장 (interface)
 * 2026/07/30 장우철 — 숙소 정산 구현순서 1-4 / 1-5 / 1-6 / 4-2~4-5
 *
 * 담당
 * - 건별 수수료/실정산금 계산
 * - 대상 조회(1-3) + 합산 → 정산 마스터 초안(저장 전)
 * - 마스터 + ITEM 트랜잭션 저장
 * - 중복 정산 방지(저장 직전 RESV_ID 재검사) → 4-5 월정산 제외도 동일 경로
 * - 중간정산 요청 등록(4-2) / 승인 시 부분정산 생성(4-4)
 *
 * 구현: StaySettlementServiceImpl
 * 호출: BizStayController / AdminSettlementService
 * DB: StaySettlementMapper
 */
package com.petcare.petcare.settlement.service;

import java.util.Date;
import java.util.List;

import com.petcare.petcare.settlement.vo.StaySettlementItemVO;
import com.petcare.petcare.settlement.vo.StaySettlementRequestVO;
import com.petcare.petcare.settlement.vo.StaySettlementSummaryVO;
import com.petcare.petcare.settlement.vo.StaySettlementVO;

public interface StaySettlementService {

    void fillItemAmounts(StaySettlementItemVO item);

    StaySettlementVO aggregateItems(Long bizNo, List<StaySettlementItemVO> items);

    /**
     * 기간·객실 조건으로 미정산 대상 조회(1-3) + 계산(1-4) 한 정산 초안
     * 이미 ITEM 에 들어간 예약은 조회에서 제외 (4-5)
     */
    StaySettlementVO buildStaySettlementDraft(
            Long bizNo,
            Date periodStart,
            Date periodEnd,
            Long roomId,
            String requestType,
            String requestScope);

    StaySettlementVO saveStaySettlement(StaySettlementVO draft);

    StaySettlementVO createAndSaveStaySettlement(
            Long bizNo,
            Date periodStart,
            Date periodEnd,
            Long roomId,
            String requestType,
            String requestScope);

    StaySettlementSummaryVO getStaySettlementSummary(Long bizNo);

    List<StaySettlementVO> getStaySettlementList(Long bizNo, String settleMonth, String statusCd);

    List<String> getStaySettlementMonths(Long bizNo);

    List<StaySettlementItemVO> getStaySettlementItems(Long bizNo, Long settleId);

    /**
     * 4-2 중간정산 요청 등록
     * - TARGET_START = targetEnd 가 속한 달의 1일 (고정)
     * - TARGET_END   = 컷오프일
     * - STATUS_CD    = REQUESTED
     * - 미정산 대상 0건이면 요청 불가 (승인 시 검사와 이중 방어)
     */
    StaySettlementRequestVO createMidSettlementRequest(
            Long bizNo,
            String requestScope,
            Long roomId,
            Date targetEnd,
            String requestMemo);

    StaySettlementRequestVO getSettlementRequest(Long requestId);

    /**
     * 4-4 승인 → TB_SETTLEMENT + ITEM 생성 + REQUEST APPROVED
     * (4-5: 미정산 조회가 이미 정산된 RESV 제외)
     */
    StaySettlementVO approveMidSettlementRequest(Long requestId);

    /** 4-3 거절 */
    void rejectMidSettlementRequest(Long requestId, String rejectReason);
}
