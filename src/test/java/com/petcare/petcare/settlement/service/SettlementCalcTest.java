package com.petcare.petcare.settlement.service;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.util.Arrays;
import java.util.Map;

import org.junit.jupiter.api.Test;

import com.petcare.petcare.settlement.vo.OrderCouponBaseVO;
import com.petcare.petcare.settlement.vo.StaySettlementItemVO;
import com.petcare.petcare.settlement.vo.StaySettlementVO;
import com.petcare.petcare.settlement.vo.StoreSettlementItemVO;
import com.petcare.petcare.settlement.vo.StoreSettlementVO;

/** 정산 공식: (매출 − 쿠폰) − 수수료(쿠폰 차감 후 기준) + 택배비 */
class SettlementCalcTest {

    private final StoreSettlementServiceImpl store = new StoreSettlementServiceImpl();
    private final StaySettlementServiceImpl stay = new StaySettlementServiceImpl();

    private static StoreSettlementItemVO storeItem(long sales, long coupon, long delivery) {
        StoreSettlementItemVO it = new StoreSettlementItemVO();
        it.setItemSalesAmount(sales);
        it.setCouponDiscountAmount(coupon);
        it.setDeliveryFeeAmount(delivery);
        it.setFeeRate(5.0);
        return it;
    }

    private static OrderCouponBaseVO base(long orderId, long orderItemId, long amount, long coupon) {
        OrderCouponBaseVO b = new OrderCouponBaseVO();
        b.setOrderId(orderId);
        b.setOrderItemId(orderItemId);
        b.setItemAmount(amount);
        b.setCouponDiscount(coupon);
        return b;
    }

    @Test
    void 쇼핑_예시_계획서_수치() {
        // A 25,000 / B 15,000, 쿠폰 3,000(포인트 2,000은 플랫폼 부담이라 제외), 택배 3,000, 수수료 5%
        StoreSettlementItemVO a = storeItem(25000, 1875, 3000);
        StoreSettlementItemVO b = storeItem(15000, 1125, 0);
        store.fillItemAmounts(a);
        store.fillItemAmounts(b);

        assertEquals(1156L, a.getFeeAmount());
        assertEquals(24969L, a.getSettleAmount());
        assertEquals(694L, b.getFeeAmount());
        assertEquals(13181L, b.getSettleAmount());
    }

    @Test
    void 쇼핑_마스터_합산() {
        StoreSettlementVO m = store.aggregateItems(1L,
                Arrays.asList(storeItem(25000, 1875, 3000), storeItem(15000, 1125, 0)));
        assertEquals(40000L, m.getProductSalesAmount());
        assertEquals(3000L, m.getCouponDiscountAmount());
        assertEquals(1850L, m.getTotalFee());
        assertEquals(38150L, m.getSettleAmount());
    }

    @Test
    void 쇼핑_쿠폰없으면_기존공식과_같음() {
        StoreSettlementItemVO it = storeItem(20000, 0, 3000);
        store.fillItemAmounts(it);
        assertEquals(1000L, it.getFeeAmount());
        assertEquals(22000L, it.getSettleAmount());
    }

    @Test
    void 쇼핑_쿠폰은_상품매출을_넘지_않음() {
        StoreSettlementItemVO it = storeItem(1000, 5000, 0);
        store.fillItemAmounts(it);
        assertEquals(1000L, it.getCouponDiscountAmount());
        assertEquals(0L, it.getSettleAmount());
    }

    @Test
    void 주문쿠폰_주문상품별_배분() {
        Map<Long, Long> shares = StoreSettlementServiceImpl.allocateOrderCoupons(Arrays.asList(
                base(100, 12, 15000, 3000),
                base(100, 11, 25000, 3000),
                base(200, 21, 10000, 1000),
                base(200, 22, 10000, 1000),
                base(200, 23, 10000, 1000),
                base(300, 31, 8000, 0)));
        // ORDER_ITEM_ID 순 배분, 나머지는 마지막(가장 큰 ID)
        assertEquals(1875L, shares.get(11L));
        assertEquals(1125L, shares.get(12L));
        assertEquals(333L, shares.get(21L));
        assertEquals(333L, shares.get(22L));
        assertEquals(334L, shares.get(23L));
        assertEquals(0L, shares.get(31L));
    }

    @Test
    void 숙소_쿠폰차감_후_수수료() {
        StaySettlementItemVO it = new StaySettlementItemVO();
        it.setResvAmount(120000L);
        it.setCouponDiscountAmount(10000L);
        it.setFeeRate(10.0);
        stay.fillItemAmounts(it);
        assertEquals(11000L, it.getFeeAmount());
        assertEquals(99000L, it.getSettleAmount());
    }

    @Test
    void 숙소_위약금은_쿠폰차감_0() {
        StaySettlementItemVO it = new StaySettlementItemVO();
        it.setItemType("CANCEL_FEE");
        it.setResvAmount(30000L);
        it.setCouponDiscountAmount(0L);
        it.setFeeRate(10.0);
        stay.fillItemAmounts(it);
        assertEquals(3000L, it.getFeeAmount());
        assertEquals(27000L, it.getSettleAmount());
    }

    @Test
    void 숙소_마스터_합산() {
        StaySettlementItemVO a = new StaySettlementItemVO();
        a.setResvAmount(120000L);
        a.setCouponDiscountAmount(10000L);
        a.setFeeRate(10.0);
        StaySettlementItemVO b = new StaySettlementItemVO();
        b.setResvAmount(80000L);
        b.setFeeRate(10.0);
        StaySettlementVO m = stay.aggregateItems(1L, Arrays.asList(a, b));
        assertEquals(200000L, m.getTotalSales());
        assertEquals(10000L, m.getCouponDiscountAmount());
        assertEquals(19000L, m.getTotalFee());
        assertEquals(171000L, m.getSettleAmount());
    }
}
