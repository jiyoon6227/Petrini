/**
 * 역할: 숙소 정산 조회·저장 (MyBatis)
 * 2026/07/30 장우철 — 숙소 정산 구현순서 1-3 / 1-5 / 1-6 / 4-2
 *
 * 쿼리
 * - selectUnsettleStayTargets : 월정산 / 중간정산(ALL) / 객실별(ROOM) 공용
 * - selectStayFeeRate         : 사업자 수수료율 조회
 * - insertSettlement          : TB_SETTLEMENT 저장 (SEQ_TB_SETTLEMENT)
 * - insertSettlementItem      : TB_SETTLEMENT_ITEM 저장 (SEQ_TB_SETTLEMENT_ITEM)
 * - insertSettlementRequest   : TB_SETTLEMENT_REQUEST 저장 (4-2)
 * - selectSettlementRequestById / countRequestedByBiz / countRoomOwnedByBiz
 * - updateSettlementRequestApproved / Rejected (4-3)
 *
 * 참고 테이블
 * - TB_RESERVATION, TB_STAY, TB_STAY_ROOM, TB_BUSINESS
 * - TB_SETTLEMENT, TB_SETTLEMENT_ITEM, TB_SETTLEMENT_REQUEST
 *
 * SQL은 XML에만 작성 (@Select 미사용)
 */
package com.petcare.petcare.settlement.mapper;

import java.util.Date;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.settlement.vo.StaySettlementItemVO;
import com.petcare.petcare.settlement.vo.StaySettlementRequestVO;
import com.petcare.petcare.settlement.vo.StaySettlementSummaryVO;
import com.petcare.petcare.settlement.vo.StaySettlementVO;

@Mapper
public interface StaySettlementMapper {

    /**
     * 정산 대상 예약 조회 (체크아웃 완료 + 미정산)
     *
     * @param bizNo       숙소 사업자번호
     * @param periodStart 집계 시작일 (포함, 체크아웃일 기준)
     * @param periodEnd   집계 종료일 (포함, 체크아웃일 기준)
     * @param roomId      객실 지정 시 해당 객실만 / null 이면 전체(ALL)
     */
    List<StaySettlementItemVO> selectUnsettleStayTargets(
            @Param("bizNo") Long bizNo,
            @Param("periodStart") Date periodStart,
            @Param("periodEnd") Date periodEnd,
            @Param("roomId") Long roomId);

    /**
     * 사업자 수수료율(%) — null 이면 숙소 기본 10 사용 권장(서비스에서 NVL)
     */
    Double selectStayFeeRate(@Param("bizNo") Long bizNo);

    /** 정산 마스터 1건 insert — settleId 는 selectKey 로 VO에 세팅 */
    int insertSettlement(StaySettlementVO vo);

    /** 정산 상세 1건 insert — settleItemId 는 selectKey 로 VO에 세팅 */
    int insertSettlementItem(StaySettlementItemVO vo);

    /**
     * 이미 TB_SETTLEMENT_ITEM 에 있는 예약 ID만 골라 반환 (1-6)
     * @param resvIds 검사할 예약 ID 목록 (비어 있으면 호출하지 말 것)
     */
    List<Long> selectAlreadySettledResvIds(@Param("resvIds") List<Long> resvIds);

    /**
     * 사업자 정산 상단 요약 (2-1)
     * - pendingAmount  : 미지급 예정액
     * - paidAmount     : 이번 달 입금 완료액
     * - totalFeeAmount : 누적 수수료
     */
    StaySettlementSummaryVO selectStaySettlementSummary(@Param("bizNo") Long bizNo);

    /**
     * 사업자 정산 목록 (2-2)
     * @param settleMonth YYYY-MM / null 또는 빈문자면 전체
     * @param statusCd    pending|done|all(null)
     */
    List<StaySettlementVO> selectStaySettlementList(
            @Param("bizNo") Long bizNo,
            @Param("settleMonth") String settleMonth,
            @Param("statusCd") String statusCd);

    /** 필터용 정산월 목록 (최신순) */
    List<String> selectStaySettlementMonths(@Param("bizNo") Long bizNo);

    /**
     * 정산 상세 ITEM 목록 (2-4)
     * settleId 가 해당 bizNo 소유인지 JOIN 으로 검증
     */
    List<StaySettlementItemVO> selectStaySettlementItems(
            @Param("bizNo") Long bizNo,
            @Param("settleId") Long settleId);

    /** 4-2 중간정산 요청 저장 — requestId 는 selectKey */
    int insertSettlementRequest(StaySettlementRequestVO vo);

    /** 요청 단건 */
    StaySettlementRequestVO selectSettlementRequestById(@Param("requestId") Long requestId);

    /** 사업자 REQUESTED 대기 건수 (중복 요청 방지) */
    int countRequestedByBiz(@Param("bizNo") Long bizNo);

    /** 객실이 해당 숙소 사업자 소유인지 */
    int countRoomOwnedByBiz(@Param("bizNo") Long bizNo, @Param("roomId") Long roomId);

    /** 4-3 승인 */
    int updateSettlementRequestApproved(@Param("requestId") Long requestId);

    /** 4-3 거절 */
    int updateSettlementRequestRejected(
            @Param("requestId") Long requestId,
            @Param("rejectReason") String rejectReason);

    /**
     * 5-2 동일 기간·범위 중복 (REQUESTED/APPROVED)
     */
    int countSamePeriodScopeRequest(
            @Param("bizNo") Long bizNo,
            @Param("requestScope") String requestScope,
            @Param("roomId") Long roomId,
            @Param("targetStart") Date targetStart,
            @Param("targetEnd") Date targetEnd);

    /** 5-4 알림: BIZ_NO → MEMBER_NO */
    Long selectMemberNoByBizNo(@Param("bizNo") Long bizNo);

    String selectBizNameByBizNo(@Param("bizNo") Long bizNo);

    /**
     * 2026/07/31 장우철 — R3-2: 환불승인 시 기존 정산 ITEM → REFUNDED
     * (미지급 마스터 합계도 차감)
     */
    int updateSettlementItemRefundedByResvId(
            @Param("resvId") Long resvId,
            @Param("holdReason") String holdReason);

    /** 환불 반영 후 미지급 정산 마스터 금액 재합산 */
    int recalcUnpaidSettlementTotalsByResvId(@Param("resvId") Long resvId);

    /** 2026/08/05 장우철 — S12: 승인된 숙소 사업자 목록 (월정산 배치) */
    List<Long> selectApprovedStayBizNos();

    /** 2026/08/05 장우철 — S12: 동일 월 REGULAR 존재 여부 (중복 월정산 방지) */
    int countRegularByBizAndMonth(@Param("bizNo") Long bizNo, @Param("settleMonth") String settleMonth);
}
