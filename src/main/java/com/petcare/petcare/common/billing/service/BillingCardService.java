/**
 * 2026/07/27 장우철 — 등록카드(빌링키) 비즈니스 로직 (interface)
 *
 * 담당
 * - TB_BILLING_CARD 조회 / 등록 / 논리삭제
 * - 이후 Ajax Controller (가입·마이페이지·관리자·결제) 에서 호출
 *
 * 구현: BillingCardServiceImpl
 * DB: BillingCardMapper
 */
package com.petcare.petcare.common.billing.service;

import java.util.List;

import com.petcare.petcare.common.billing.vo.BillingCardVO;
import com.petcare.petcare.common.billing.vo.BillingIssueResultVO;

public interface BillingCardService {

    // 2026/07/27 장우철 — 활성 카드 목록
    List<BillingCardVO> getCardList(String ownerType, Long ownerNo);

    // 2026/07/27 장우철 — 단건 조회
    BillingCardVO getCard(Long billingCardId);

    // 2026/07/27 장우철 — 토스 발급 결과로 DB 저장 (등록)
    BillingCardVO registerCard(String ownerType, Long ownerNo, BillingIssueResultVO issueResult);

    // 2026/07/27 장우철 — 논리삭제 (소유자 일치할 때만)
    boolean removeCard(Long billingCardId, String ownerType, Long ownerNo);
}
