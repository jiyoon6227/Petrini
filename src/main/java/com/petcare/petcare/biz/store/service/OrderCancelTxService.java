package com.petcare.petcare.biz.store.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.biz.store.mapper.BizStoreMapper;
import com.petcare.petcare.biz.store.vo.BizOrderItemVO;
import com.petcare.petcare.biz.store.vo.BizOrderVO;

@Service
public class OrderCancelTxService {

    @Autowired
    private BizStoreMapper bizStoreMapper;

    @Transactional
    public void applyCancelToDb(BizOrderVO order, Long bizNo) {
        Long orderId = order.getOrderId();

        bizStoreMapper.updateClaimApprove(orderId, bizNo, order.getPayAmount());
        bizStoreMapper.updatePaymentCancelStatus(orderId);

        List<BizOrderItemVO> items = bizStoreMapper.selectOrderItems(orderId);
        for (BizOrderItemVO item : items) {
            if (item.getOptionId() != null) {
                bizStoreMapper.restoreStock(item.getOptionId(), item.getQty());
            }
            //지윤 26.07.23 추가: 재고 복구로 다시 재고가 생겼으면 품절 상태 자동 해제
            bizStoreMapper.restoreProductStatusIfNeeded(item.getProductId());
        }

        if (order.getPointUsed() != null && order.getPointUsed() > 0) {
            int currentBalance = bizStoreMapper.selectMemberPointBalance(order.getMemberNo());
            int newBalance = currentBalance + order.getPointUsed();
            bizStoreMapper.restoreMemberPoint(order.getMemberNo(), newBalance);
            bizStoreMapper.insertPointRefundHistory(order.getMemberNo(), order.getPointUsed(), newBalance, orderId);
        }

        if (order.getMemberCouponId() != null) {
            bizStoreMapper.restoreCoupon(order.getMemberCouponId());
        }
    }
}