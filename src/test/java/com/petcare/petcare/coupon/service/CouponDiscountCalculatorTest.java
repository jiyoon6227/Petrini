package com.petcare.petcare.coupon.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.util.LinkedHashMap;
import java.util.Map;

import org.junit.jupiter.api.Test;

import com.petcare.petcare.store.vo.CouponVO;

/** 쿠폰 할인액 재계산 (DB 미사용) */
class CouponDiscountCalculatorTest {

    private static final String TODAY = "20261013";

    private static CouponVO coupon(String type, int value, Integer maxAmt, int minOrder, String bizNo) {
        CouponVO c = new CouponVO();
        c.setCouponType(type);
        c.setDiscountValue(value);
        c.setMaxDiscountAmt(maxAmt);
        c.setMinOrderAmt(minOrder);
        c.setBizNo(bizNo);
        c.setUseStartDate("20261001");
        c.setUseEndDate("20261031");
        return c;
    }

    @Test
    void 정률쿠폰은_최대할인으로_제한() {
        CouponVO c = coupon("RATE", 10, 3000, 0, "1");
        assertEquals(3000L, CouponDiscountCalculator.discount(c, 50000));
        assertEquals(2000L, CouponDiscountCalculator.discount(c, 20000));
    }

    @Test
    void 정률쿠폰_최대할인_미설정이면_상한없음() {
        assertEquals(5000L, CouponDiscountCalculator.discount(coupon("RATE", 10, null, 0, "1"), 50000));
        assertEquals(5000L, CouponDiscountCalculator.discount(coupon("RATE", 10, 0, 0, "1"), 50000));
    }

    @Test
    void 정액쿠폰은_대상금액을_넘지_않음() {
        CouponVO c = coupon("FIXED", 5000, null, 0, "1");
        assertEquals(5000L, CouponDiscountCalculator.discount(c, 40000));
        assertEquals(3000L, CouponDiscountCalculator.discount(c, 3000));
    }

    @Test
    void 최소주문금액_미달이면_0() {
        CouponVO c = coupon("FIXED", 3000, null, 30000, "1");
        assertEquals(0L, CouponDiscountCalculator.discount(c, 29999));
        assertEquals(3000L, CouponDiscountCalculator.discount(c, 30000));
    }

    @Test
    void 사용기간_경계() {
        CouponVO c = coupon("FIXED", 1000, null, 0, "1");
        assertTrue(CouponDiscountCalculator.inUsePeriod(c, "20261001"));
        assertTrue(CouponDiscountCalculator.inUsePeriod(c, "20261031"));
        assertFalse(CouponDiscountCalculator.inUsePeriod(c, "20260930"));
        assertFalse(CouponDiscountCalculator.inUsePeriod(c, "20261101"));
    }

    @Test
    void 쇼핑쿠폰은_발급사업자_상품합계_기준() {
        Map<Long, Integer> subtotals = new LinkedHashMap<>();
        subtotals.put(1L, 40000);
        subtotals.put(2L, 100000);
        // 사업자1 합계 40,000 기준 10% (전체 140,000 기준 아님)
        CouponVO c = coupon("RATE", 10, null, 30000, "1");
        assertEquals(4000L, CouponDiscountCalculator.storeDiscount(c, subtotals, TODAY));
    }

    @Test
    void 쇼핑쿠폰_최소주문은_해당사업자_합계로_판단() {
        Map<Long, Integer> subtotals = new LinkedHashMap<>();
        subtotals.put(1L, 20000);
        subtotals.put(2L, 100000);
        CouponVO c = coupon("FIXED", 3000, null, 30000, "1");
        assertEquals(0L, CouponDiscountCalculator.storeDiscount(c, subtotals, TODAY));
    }

    @Test
    void 쇼핑쿠폰_주문에_발급사업자_상품이_없으면_0() {
        Map<Long, Integer> subtotals = new LinkedHashMap<>();
        subtotals.put(2L, 100000);
        assertEquals(0L, CouponDiscountCalculator.storeDiscount(coupon("FIXED", 3000, null, 0, "1"), subtotals, TODAY));
    }

    @Test
    void 쇼핑쿠폰_사용기간_밖이면_0() {
        Map<Long, Integer> subtotals = new LinkedHashMap<>();
        subtotals.put(1L, 50000);
        assertEquals(0L, CouponDiscountCalculator.storeDiscount(coupon("FIXED", 3000, null, 0, "1"), subtotals, "20261101"));
    }

    @Test
    void 숙소쿠폰_정상() {
        CouponVO c = coupon("FIXED", 10000, null, 50000, "7");
        assertEquals(10000L, CouponDiscountCalculator.stayDiscount(c, 7L, 120000, TODAY));
    }

    @Test
    void 숙소쿠폰_사용불가_사유별_예외() {
        CouponVO c = coupon("FIXED", 10000, null, 50000, "7");
        assertThrows(IllegalArgumentException.class,
                () -> CouponDiscountCalculator.stayDiscount(null, 7L, 120000, TODAY));
        assertThrows(IllegalArgumentException.class,
                () -> CouponDiscountCalculator.stayDiscount(c, 8L, 120000, TODAY));
        assertThrows(IllegalArgumentException.class,
                () -> CouponDiscountCalculator.stayDiscount(c, 7L, 120000, "20261101"));
        assertThrows(IllegalArgumentException.class,
                () -> CouponDiscountCalculator.stayDiscount(c, 7L, 40000, TODAY));
    }
}
