/**
 * 쇼핑 상품단위 환불
 * - 쿠폰·포인트는 상품금액에만 배분 (배송비에는 안 씀)
 * - 주문 배송비는 환불하지 않음
 * - 단순변심: 이 상품 실결제만 (반송비는 유저 선불, 환불금 미차감)
 * - 상품이상: 이 상품 실결제 + 반송 3,000원 (카드 잔액 한도)
 * - 쿠폰 복구는 주문 상품이 모두 환불(DONE)될 때만
 */
package com.petcare.petcare.biz.store.service;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

import com.petcare.petcare.biz.store.vo.BizOrderItemVO;
import com.petcare.petcare.common.util.CouponShareAllocator;
import com.petcare.petcare.biz.store.vo.BizReturnVO;

public final class StoreItemRefundCalculator {

    public static final int RETURN_SHIP_FEE = 3000;

    private StoreItemRefundCalculator() {}

    public static void fill(BizReturnVO target, List<BizOrderItemVO> orderItems) {
        if (target == null) {
            return;
        }
        int productTotal = 0;
        if (orderItems != null) {
            for (BizOrderItemVO it : orderItems) {
                productTotal += nvl(it.getTotalPrice());
            }
        }
        if (productTotal <= 0) {
            productTotal = nvl(target.getOrderProductTotal());
        }
        target.setOrderProductTotal(productTotal);

        int discount = nvl(target.getDiscountAmount());
        int pointAll = nvl(target.getPointUsed());
        int couponRaw = Math.max(0, discount - pointAll);
        int coupon = Math.min(couponRaw, productTotal);
        int pointForItems = Math.min(pointAll, Math.max(0, productTotal - coupon));
        target.setOrderCouponAmount(coupon);

        int itemPrice = nvl(target.getTotalPrice());
        int itemCoupon = 0;
        int itemPoint = 0;
        if (productTotal > 0 && orderItems != null && !orderItems.isEmpty()) {
            itemCoupon = share(coupon, target.getOrderItemId(), orderItems);
            itemPoint = share(pointForItems, target.getOrderItemId(), orderItems);
        }
        target.setItemCouponAmount(itemCoupon);
        target.setItemPointAmount(itemPoint);

        int itemPay = Math.max(0, itemPrice - itemCoupon - itemPoint);
        target.setItemPayAmount(itemPay);

        boolean defect = isBizPaysReturnFee(target);
        target.setUserReturnFee(defect ? 0 : RETURN_SHIP_FEE);
        target.setReturnShipReimburse(defect ? RETURN_SHIP_FEE : 0);

        boolean last = isLastRemaining(target.getOrderItemId(), orderItems);
        target.setLastItemRefund(last);

        int raw = itemPay + (defect ? RETURN_SHIP_FEE : 0);
        int remaining = Math.max(0, nvl(target.getPayAmount()) - nvl(target.getPaidRefundAmt()));
        target.setExpectCardRefund(Math.min(raw, remaining));
    }

    static boolean isBizPaysReturnFee(BizReturnVO target) {
        String payer = target.getReturnFeePayer();
        String reason = target.getReturnReasonCd();
        return "BIZ".equalsIgnoreCase(payer) || "DEFECT".equalsIgnoreCase(reason);
    }

    /** 정산과 같은 배분 (ORDER_ITEM_ID 순, 1원 오차는 마지막 상품) */
    private static int share(int benefit, Long itemId, List<BizOrderItemVO> items) {
        if (benefit <= 0 || itemId == null || items == null || items.isEmpty()) {
            return 0;
        }
        List<BizOrderItemVO> sorted = new ArrayList<>(items);
        sorted.sort(Comparator.comparing(BizOrderItemVO::getOrderItemId,
                Comparator.nullsLast(Comparator.naturalOrder())));
        List<Long> amounts = new ArrayList<>();
        for (BizOrderItemVO it : sorted) {
            amounts.add((long) nvl(it.getTotalPrice()));
        }
        long[] shares = CouponShareAllocator.allocate(benefit, amounts);
        for (int i = 0; i < sorted.size(); i++) {
            if (itemId.equals(sorted.get(i).getOrderItemId())) {
                return (int) shares[i];
            }
        }
        return 0;
    }

    /** 이 상품까지 환불 완료되면 주문 상품이 전부 DONE인지 (쿠폰 복구용) */
    private static boolean isLastRemaining(Long itemId, List<BizOrderItemVO> items) {
        if (items == null || items.isEmpty()) {
            return true;
        }
        for (BizOrderItemVO it : items) {
            if (itemId != null && itemId.equals(it.getOrderItemId())) {
                continue;
            }
            if (!"DONE".equals(it.getReturnStatusCd())) {
                return false;
            }
        }
        return true;
    }

    private static int nvl(Integer v) {
        return v == null ? 0 : v;
    }
}
