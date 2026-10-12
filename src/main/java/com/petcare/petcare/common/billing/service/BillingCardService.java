package com.petcare.petcare.common.billing.service;

import java.util.List;

import com.petcare.petcare.common.billing.vo.BillingCardVO;
import com.petcare.petcare.common.billing.vo.BillingIssueResultVO;

public interface BillingCardService {

    // 활성 카드 목록
    List<BillingCardVO> getCardList(String ownerType, Long ownerNo);

    // 단건 조회
    BillingCardVO getCard(Long billingCardId);

    // 토스 발급 결과로 DB 저장 (등록)
    BillingCardVO registerCard(String ownerType, Long ownerNo, BillingIssueResultVO issueResult);

    // 논리삭제 (소유자 일치할 때만)
    boolean removeCard(Long billingCardId, String ownerType, Long ownerNo);
}
