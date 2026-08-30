/**
 * 역할: 쇼핑 정산 조회·저장 (MyBatis)
 * 2026/08/04 장우철 — 쇼핑 정산 S8 (1-2~1-6)
 * 2026/08/05 장우철 — S9 사업자 화면 · S10 중간요청
 *
 * 참고 테이블
 * - TB_ORDER, TB_ORDER_ITEM, TB_PRODUCT, TB_BUSINESS
 * - TB_SETTLEMENT, TB_SETTLEMENT_ITEM, TB_SETTLEMENT_REQUEST
 */
package com.petcare.petcare.settlement.mapper;

import java.util.Date;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.biz.store.vo.BizProductVO;
import com.petcare.petcare.settlement.vo.StoreSettlementItemVO;
import com.petcare.petcare.settlement.vo.StoreSettlementRequestVO;
import com.petcare.petcare.settlement.vo.StoreSettlementSummaryVO;
import com.petcare.petcare.settlement.vo.StoreSettlementVO;

@Mapper
public interface StoreSettlementMapper {

    List<StoreSettlementItemVO> selectUnsettleStoreTargets(
            @Param("bizNo") Long bizNo,
            @Param("periodStart") Date periodStart,
            @Param("periodEnd") Date periodEnd,
            @Param("productId") Long productId);

    Double selectStoreFeeRate(@Param("bizNo") Long bizNo);

    int insertSettlement(StoreSettlementVO vo);

    int insertSettlementItem(StoreSettlementItemVO vo);

    List<Long> selectAlreadySettledOrderItemIds(@Param("orderItemIds") List<Long> orderItemIds);

    StoreSettlementSummaryVO selectStoreSettlementSummary(@Param("bizNo") Long bizNo);

    List<StoreSettlementVO> selectStoreSettlementList(
            @Param("bizNo") Long bizNo,
            @Param("settleMonth") String settleMonth,
            @Param("statusCd") String statusCd);

    List<String> selectStoreSettlementMonths(@Param("bizNo") Long bizNo);

    List<StoreSettlementItemVO> selectStoreSettlementItems(
            @Param("bizNo") Long bizNo,
            @Param("settleId") Long settleId);

    /** S10 중간요청 폼용 상품 */
    List<BizProductVO> selectProductsByBiz(@Param("bizNo") Long bizNo);

    int countProductOwnedByBiz(@Param("bizNo") Long bizNo, @Param("productId") Long productId);

    int insertSettlementRequest(StoreSettlementRequestVO vo);

    StoreSettlementRequestVO selectSettlementRequestById(@Param("requestId") Long requestId);

    int countRequestedByBiz(@Param("bizNo") Long bizNo);

    int countSamePeriodScopeRequest(
            @Param("bizNo") Long bizNo,
            @Param("requestScope") String requestScope,
            @Param("productId") Long productId,
            @Param("targetStart") Date targetStart,
            @Param("targetEnd") Date targetEnd);

    int updateSettlementRequestApproved(@Param("requestId") Long requestId);

    int updateSettlementRequestRejected(
            @Param("requestId") Long requestId,
            @Param("rejectReason") String rejectReason);

    Long selectMemberNoByBizNo(@Param("bizNo") Long bizNo);

    String selectBizNameByBizNo(@Param("bizNo") Long bizNo);

    /** 2026/08/05 장우철 — S12: 승인된 쇼핑 사업자 목록 (월정산 배치) */
    List<Long> selectApprovedStoreBizNos();

    /** 2026/08/05 장우철 — S12: 동일 월 REGULAR 존재 여부 */
    int countRegularByBizAndMonth(@Param("bizNo") Long bizNo, @Param("settleMonth") String settleMonth);
}
