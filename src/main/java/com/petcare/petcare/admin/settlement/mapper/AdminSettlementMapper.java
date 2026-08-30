/**
 * 역할: 관리자 정산 DB 접근 (MyBatis) — 사업자 SettlementMapper 와 분리
 * 2026/07/30 장우철 — 숙소 정산 구현순서 3-1 ~ 3-5 / 4-3
 * 2026/08/05 장우철 — 쇼핑 STORE 탭 S11
 *
 * XML: resources/mybatis/mapper/admin/settlement/AdminSettlementMapper.xml
 */
package com.petcare.petcare.admin.settlement.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.admin.settlement.vo.AdminStayRequestVO;
import com.petcare.petcare.admin.settlement.vo.AdminStaySettlementVO;
import com.petcare.petcare.admin.settlement.vo.AdminStoreRequestVO;
import com.petcare.petcare.settlement.vo.StaySettlementItemVO;
import com.petcare.petcare.settlement.vo.StoreSettlementItemVO;

@Mapper
public interface AdminSettlementMapper {

    int ping();

    int countStaySettlements(@Param("bizNo") Long bizNo);

    List<AdminStaySettlementVO> selectStaySettlementList(@Param("statusCd") String statusCd);

    List<StaySettlementItemVO> selectStaySettlementItems(@Param("settleId") Long settleId);

    AdminStaySettlementVO selectStaySettlementById(@Param("settleId") Long settleId);

    int updateStaySettlementPaid(@Param("settleId") Long settleId);

    int updateStaySettlementPaidBatch(@Param("settleIds") List<Long> settleIds);

    /** 2026/08/05 장우철 — S12 FAIL 표시 */
    int updateStaySettlementFail(@Param("settleId") Long settleId);

    List<Long> selectStayWaitSettleIds();

    int countStayRequestsRequested();

    List<AdminStayRequestVO> selectStayRequestList(@Param("statusCd") String statusCd);

    // ===== STORE (S11) =====
    int countStoreSettlements(@Param("bizNo") Long bizNo);

    List<AdminStaySettlementVO> selectStoreSettlementList(@Param("statusCd") String statusCd);

    AdminStaySettlementVO selectStoreSettlementById(@Param("settleId") Long settleId);

    List<StoreSettlementItemVO> selectStoreSettlementItems(@Param("settleId") Long settleId);

    int updateStoreSettlementPaid(@Param("settleId") Long settleId);

    /** 2026/08/05 장우철 — S12 FAIL 표시 */
    int updateStoreSettlementFail(@Param("settleId") Long settleId);

    List<Long> selectStoreWaitSettleIds();

    int countStoreRequestsRequested();

    List<AdminStoreRequestVO> selectStoreRequestList(@Param("statusCd") String statusCd);
}
