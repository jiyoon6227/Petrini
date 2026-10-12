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

    /** FAIL 표시 */
    int updateStaySettlementFail(@Param("settleId") Long settleId);

    List<Long> selectStayWaitSettleIds();

    int countStayRequestsRequested();

    List<AdminStayRequestVO> selectStayRequestList(@Param("statusCd") String statusCd);

    // STORE
    int countStoreSettlements(@Param("bizNo") Long bizNo);

    List<AdminStaySettlementVO> selectStoreSettlementList(@Param("statusCd") String statusCd);

    AdminStaySettlementVO selectStoreSettlementById(@Param("settleId") Long settleId);

    List<StoreSettlementItemVO> selectStoreSettlementItems(@Param("settleId") Long settleId);

    int updateStoreSettlementPaid(@Param("settleId") Long settleId);

    /** FAIL 표시 */
    int updateStoreSettlementFail(@Param("settleId") Long settleId);

    List<Long> selectStoreWaitSettleIds();

    int countStoreRequestsRequested();

    List<AdminStoreRequestVO> selectStoreRequestList(@Param("statusCd") String statusCd);
}
