package com.petcare.petcare.common.util;

import static org.junit.jupiter.api.Assertions.assertArrayEquals;
import static org.junit.jupiter.api.Assertions.assertEquals;

import java.util.Arrays;
import java.util.Collections;

import org.junit.jupiter.api.Test;

/** 쿠폰 비율 배분 */
class CouponShareAllocatorTest {

    @Test
    void 금액비율로_배분() {
        long[] shares = CouponShareAllocator.allocate(3000, Arrays.asList(25000L, 15000L));
        assertArrayEquals(new long[] {1875, 1125}, shares);
    }

    @Test
    void 나머지_1원은_마지막_항목() {
        long[] shares = CouponShareAllocator.allocate(1000, Arrays.asList(10000L, 10000L, 10000L));
        assertArrayEquals(new long[] {333, 333, 334}, shares);
        assertEquals(1000L, Arrays.stream(shares).sum());
    }

    @Test
    void 배분합은_항상_쿠폰액() {
        long[] shares = CouponShareAllocator.allocate(4999, Arrays.asList(12345L, 6789L, 1L, 9999L));
        assertEquals(4999L, Arrays.stream(shares).sum());
    }

    @Test
    void 쿠폰이_합계보다_크면_합계로_제한() {
        long[] shares = CouponShareAllocator.allocate(50000, Arrays.asList(10000L, 20000L));
        assertArrayEquals(new long[] {10000, 20000}, shares);
    }

    @Test
    void 쿠폰_없음_또는_항목_없음() {
        assertArrayEquals(new long[] {0, 0}, CouponShareAllocator.allocate(0, Arrays.asList(1000L, 2000L)));
        assertEquals(0, CouponShareAllocator.allocate(1000, Collections.emptyList()).length);
        assertEquals(0, CouponShareAllocator.allocate(1000, null).length);
    }

    @Test
    void 단일항목은_전액() {
        assertArrayEquals(new long[] {3000}, CouponShareAllocator.allocate(3000, Collections.singletonList(40000L)));
    }
}
