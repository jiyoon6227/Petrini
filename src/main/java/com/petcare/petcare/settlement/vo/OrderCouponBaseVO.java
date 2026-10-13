package com.petcare.petcare.settlement.vo;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

/** 쿠폰 배분 기준 (주문상품 금액 + 주문 쿠폰액) */
@Getter
@Setter
@ToString
@NoArgsConstructor
public class OrderCouponBaseVO {

    private Long orderId;
    private Long orderItemId;
    private Long itemAmount;
    private Long couponDiscount;
}
