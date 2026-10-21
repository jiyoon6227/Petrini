package com.petcare.petcare.common.paycancel.service;

import java.util.List;

import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.common.paycancel.mapper.PaymentCancelRetryMapper;
import com.petcare.petcare.common.paycancel.vo.PaymentCancelRetryVO;

@Service
public class PaymentCancelRetryServiceImpl implements PaymentCancelRetryService {

    private final PaymentCancelRetryMapper paymentCancelRetryMapper;

    public PaymentCancelRetryServiceImpl(PaymentCancelRetryMapper paymentCancelRetryMapper) {
        this.paymentCancelRetryMapper = paymentCancelRetryMapper;
    }

    // REQUIRES_NEW: 호출한 쪽 트랜잭션(롤백된 주문 저장 등)과 상관없이 바로 커밋
    @Override
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public boolean registerPending(PaymentCancelRetryVO vo) {
        try {
            return paymentCancelRetryMapper.insertRetryIfAbsent(vo) > 0;
        } catch (DuplicateKeyException e) {
            // 동시에 같은 결제키로 저장된 경우 (UK_CANCEL_RETRY_PAYKEY) → 이미 등록된 것으로 봄
            return false;
        }
    }

    @Override
    public List<PaymentCancelRetryVO> getPendingList() {
        return paymentCancelRetryMapper.selectPendingList();
    }

    @Override
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public boolean claim(Long retryId) {
        return paymentCancelRetryMapper.updateClaim(retryId) == 1;
    }

    @Override
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void markSuccess(Long retryId) {
        paymentCancelRetryMapper.updateSuccess(retryId);
    }

    @Override
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void markRetry(Long retryId, String lastError) {
        paymentCancelRetryMapper.updateRetry(retryId, lastError);
    }

    @Override
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void markFailed(Long retryId, String lastError) {
        paymentCancelRetryMapper.updateFailed(retryId, lastError);
    }

    @Override
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public int releaseStuck(int stuckMinutes) {
        return paymentCancelRetryMapper.updateReleaseStuck(stuckMinutes);
    }
}
