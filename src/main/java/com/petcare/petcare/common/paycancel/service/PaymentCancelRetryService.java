package com.petcare.petcare.common.paycancel.service;

import java.util.List;

import com.petcare.petcare.common.paycancel.vo.PaymentCancelRetryVO;

public interface PaymentCancelRetryService {

    // 실패 건 PENDING 저장 (주문 트랜잭션과 별개). 이미 같은 결제키가 있으면 false
    boolean registerPending(PaymentCancelRetryVO vo);

    // PENDING 목록
    List<PaymentCancelRetryVO> getPendingList();

    // 선점 성공 여부
    boolean claim(Long retryId);

    // 취소 완료
    void markSuccess(Long retryId);

    // 다시 PENDING (시도 횟수 +1)
    void markRetry(Long retryId, String lastError);

    // 최종 실패 (시도 횟수 +1)
    void markFailed(Long retryId, String lastError);

    // PROCESSING 으로 오래 멈춘 건 되돌리기, 되돌린 건수 반환
    int releaseStuck(int stuckMinutes);
}
