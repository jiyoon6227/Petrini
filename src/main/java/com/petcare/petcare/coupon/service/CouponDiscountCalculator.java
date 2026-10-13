package com.petcare.petcare.coupon.service;

import java.util.Map;

import com.petcare.petcare.store.vo.CouponVO;

/** 쿠폰 할인액 계산 (쇼핑·숙소 공용, DB 미사용) */
public final class CouponDiscountCalculator {

    private CouponDiscountCalculator() {}

    /** 사용기간 포함 여부 (yyyyMMdd 문자열 비교, 기간 미설정은 통과) */
    public static boolean inUsePeriod(CouponVO coupon, String todayYmd) {
        if (coupon == null || todayYmd == null) {
            return false;
        }
        String start = coupon.getUseStartDate();
        String end = coupon.getUseEndDate();
        if (start != null && !start.isBlank() && start.trim().compareTo(todayYmd) > 0) {
            return false;
        }
        return end == null || end.isBlank() || end.trim().compareTo(todayYmd) >= 0;
    }

    /** 대상 금액 기준 할인액 (최소주문 미달 0, 정률 상한, 대상 금액 초과 불가) */
    public static long discount(CouponVO coupon, long targetAmount) {
        if (coupon == null || targetAmount <= 0) {
            return 0L;
        }
        int minOrder = coupon.getMinOrderAmt() == null ? 0 : coupon.getMinOrderAmt();
        if (targetAmount < minOrder) {
            return 0L;
        }
        int value = coupon.getDiscountValue() == null ? 0 : coupon.getDiscountValue();
        long result;
        if ("RATE".equals(coupon.getCouponType())) {
            result = targetAmount * value / 100;
            Integer maxAmt = coupon.getMaxDiscountAmt();
            if (maxAmt != null && maxAmt > 0) {
                result = Math.min(result, maxAmt);
            }
        } else {
            result = value;
        }
        return Math.max(0L, Math.min(result, targetAmount));
    }

    /** 쇼핑 주문: 쿠폰 발급 사업자 상품 합계 기준 할인액 */
    public static long storeDiscount(CouponVO coupon, Map<Long, Integer> bizSubtotals, String todayYmd) {
        if (coupon == null || bizSubtotals == null || !inUsePeriod(coupon, todayYmd)) {
            return 0L;
        }
        Long couponBizNo = parseBizNo(coupon.getBizNo());
        if (couponBizNo == null) {
            return 0L;
        }
        Integer target = bizSubtotals.get(couponBizNo);
        return target == null ? 0L : discount(coupon, target);
    }

    /** 숙소 예약: 숙소 사업자 쿠폰만, 예약금 기준 할인액 (사용 불가면 예외) */
    public static long stayDiscount(CouponVO coupon, Long stayBizNo, long totalAmount, String todayYmd) {
        if (coupon == null) {
            throw new IllegalArgumentException("사용할 수 없는 쿠폰입니다.");
        }
        Long couponBizNo = parseBizNo(coupon.getBizNo());
        if (stayBizNo == null || couponBizNo == null || !stayBizNo.equals(couponBizNo)) {
            throw new IllegalArgumentException("이 숙소에는 사용할 수 없는 쿠폰입니다.");
        }
        if (!inUsePeriod(coupon, todayYmd)) {
            throw new IllegalArgumentException("사용기간이 아닌 쿠폰입니다.");
        }
        int minOrder = coupon.getMinOrderAmt() == null ? 0 : coupon.getMinOrderAmt();
        if (totalAmount < minOrder) {
            throw new IllegalArgumentException("최소 예약금액 미달로 쿠폰을 사용할 수 없습니다.");
        }
        return discount(coupon, totalAmount);
    }

    static Long parseBizNo(String bizNo) {
        if (bizNo == null || bizNo.isBlank()) {
            return null;
        }
        try {
            return Long.valueOf(bizNo.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
