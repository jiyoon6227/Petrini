package com.petcare.petcare.store.vo;

import java.util.List;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import lombok.NoArgsConstructor;

//지윤 26.07.13 결제창(payment.jsp)으로 넘어가기 직전 계산한 주문정보를 세션에 잠깐 담아두는 용도.
//토스 위젯이 결제 인증 끝나면 우리 서버를 거치지 않고 order-complete로 바로 리다이렉트시키기 때문에,
//그 사이 주문정보(상품/배송지/쿠폰/포인트)를 세션에 저장해뒀다가 order-complete에서 꺼내 씀.
@Getter @Setter
@ToString
@NoArgsConstructor
public class OrderTempVO {
    private Long memberNo;
    private List<CartItemVO> orderItems;
    private Integer productTotal;
    private Integer deliveryFee;
    private Long couponMemberCouponId;   // 쓴 쿠폰 없으면 null
    private String couponBizNo;    //지윤 26.07.30 추가: 쿠폰이 어느 사업자 건지 (사업자 쪼개기용)
    private Integer couponDiscount;
    private Integer pointUsed;
    private Integer totalDiscount;
    private Integer finalTotal;
    private String recvName;
    private String recvPhone;
    private String zipCode;
    private String addr1;
    private String addr2;
    private String deliveryMemo;
    private List<Long> cartItemIds;      // 장바구니에서 온 주문이면 채워짐, 바로구매면 null
}