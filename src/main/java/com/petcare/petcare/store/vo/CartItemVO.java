package com.petcare.petcare.store.vo;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import lombok.NoArgsConstructor;

// 장바구니 항목(TB_CART_ITEM + 상품정보 조인) 조회용 VO
@Getter @Setter
@ToString
@NoArgsConstructor
public class CartItemVO {
    private Long cartItemId;
    private Long cartId;
    private Long productId;
    private Long optionId;
    private String productName;
    private String brandName;
    private String thumbnailUrl;
    private String optionColor;
    private String optionSize;
    private Integer qty;
    private Integer price;
    private Integer stockQty;
    private Long bizNo; // 주문 저장 시 TB_ORDER.BIZ_NO 값
    private String bizName; // 장바구니 화면 사업자별 묶음 표시용
}