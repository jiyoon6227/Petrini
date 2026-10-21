package com.petcare.petcare.common.paycancel.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.common.paycancel.vo.PaymentCancelRetryVO;

@Mapper
public interface PaymentCancelRetryMapper {

    // 실패 건 저장 (같은 PAYMENT_KEY 가 있으면 저장 안 함 → 0 반환)
    int insertRetryIfAbsent(PaymentCancelRetryVO vo);

    // PENDING 목록 (등록 순)
    List<PaymentCancelRetryVO> selectPendingList();

    // 선점: PENDING → PROCESSING (1건 바뀌었을 때만 처리)
    int updateClaim(@Param("retryId") Long retryId);

    // 취소 완료
    int updateSuccess(@Param("retryId") Long retryId);

    // 실패 → 다시 PENDING (ATTEMPT_CNT+1)
    int updateRetry(@Param("retryId") Long retryId, @Param("lastError") String lastError);

    // 최대 횟수 초과 → FAILED (ATTEMPT_CNT+1)
    int updateFailed(@Param("retryId") Long retryId, @Param("lastError") String lastError);

    // PROCESSING 으로 오래 멈춘 건 → PENDING (처리 중 서버 종료 대비)
    int updateReleaseStuck(@Param("stuckMinutes") int stuckMinutes);
}
