package com.petcare.petcare.common.util;

import java.util.List;

/** 할인 금액을 항목 금액 비율로 배분 (정수 내림, 1원 오차는 마지막 항목) */
public final class CouponShareAllocator {

    private CouponShareAllocator() {}

    /**
     * @param benefit 배분할 총액 (항목 합계를 넘으면 합계로 제한)
     * @param amounts 항목 금액 (순서 = 배분 순서, 마지막 항목이 나머지)
     * @return 항목별 배분액
     */
    public static long[] allocate(long benefit, List<Long> amounts) {
        int n = amounts == null ? 0 : amounts.size();
        long[] shares = new long[n];
        if (n == 0 || benefit <= 0) {
            return shares;
        }
        long total = 0L;
        for (Long a : amounts) {
            total += Math.max(0L, a == null ? 0L : a);
        }
        if (total <= 0) {
            return shares;
        }
        long capped = Math.min(benefit, total);
        long allocated = 0L;
        for (int i = 0; i < n - 1; i++) {
            long amt = Math.max(0L, amounts.get(i) == null ? 0L : amounts.get(i));
            shares[i] = capped * amt / total;
            allocated += shares[i];
        }
        shares[n - 1] = capped - allocated;
        return shares;
    }
}
