/**
 * 2026/07/27 장우철 — BillingCardService 구현체
 *
 * - TB_BILLING_CARD CRUD
 * - 삭제는 STATUS_CD=DELETED (물리 삭제 안 함)
 * - billingKey 는 화면/Ajax JSON 응답에 넣지 않도록 Controller 에서 마스킹 권장
 */
package com.petcare.petcare.common.billing.service;

import java.util.Collections;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.common.billing.mapper.BillingCardMapper;
import com.petcare.petcare.common.billing.vo.BillingCardVO;
import com.petcare.petcare.common.billing.vo.BillingIssueResultVO;

@Service
public class BillingCardServiceImpl implements BillingCardService {

    private final BillingCardMapper billingCardMapper;

    public BillingCardServiceImpl(BillingCardMapper billingCardMapper) {
        this.billingCardMapper = billingCardMapper;
    }

    // 2026/07/27 장우철 — 활성 카드 목록
    @Override
    public List<BillingCardVO> getCardList(String ownerType, Long ownerNo) {
        if (ownerType == null || ownerType.isBlank() || ownerNo == null) {
            return Collections.emptyList();
        }
        return billingCardMapper.selectBillingCardList(ownerType, ownerNo);
    }

    // 2026/07/27 장우철 — 단건
    @Override
    public BillingCardVO getCard(Long billingCardId) {
        if (billingCardId == null) {
            return null;
        }
        return billingCardMapper.selectBillingCard(billingCardId);
    }

    // 2026/07/27 장우철 — 발급 결과 INSERT
    @Override
    @Transactional
    public BillingCardVO registerCard(String ownerType, Long ownerNo, BillingIssueResultVO issueResult) {
        if (ownerType == null || ownerType.isBlank() || ownerNo == null || issueResult == null) {
            throw new IllegalArgumentException("카드 등록 파라미터가 올바르지 않습니다.");
        }
        if (issueResult.getBillingKey() == null || issueResult.getBillingKey().isBlank()
                || issueResult.getCustomerKey() == null || issueResult.getCustomerKey().isBlank()) {
            throw new IllegalArgumentException("빌링키 또는 customerKey 가 없습니다.");
        }

        BillingCardVO vo = new BillingCardVO();
        vo.setOwnerType(ownerType);
        vo.setOwnerNo(ownerNo);
        vo.setCustomerKey(issueResult.getCustomerKey());
        vo.setBillingKey(issueResult.getBillingKey());
        vo.setCardCompany(issueResult.getCardCompany());
        vo.setCardNumber(issueResult.getCardNumber());
        vo.setStatusCd("ACTIVE");

        billingCardMapper.insertBillingCard(vo);
        return vo;
    }

    // 2026/07/27 장우철 — 소유자 확인 후 논리삭제
    @Override
    @Transactional
    public boolean removeCard(Long billingCardId, String ownerType, Long ownerNo) {
        if (billingCardId == null || ownerType == null || ownerNo == null) {
            return false;
        }
        BillingCardVO card = billingCardMapper.selectBillingCard(billingCardId);
        if (card == null) {
            return false;
        }
        if (!ownerType.equals(card.getOwnerType()) || !ownerNo.equals(card.getOwnerNo())) {
            return false;
        }
        if (!"ACTIVE".equals(card.getStatusCd())) {
            return false;
        }
        return billingCardMapper.deleteBillingCard(billingCardId) > 0;
    }
}
