package com.petcare.petcare.store.vo;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import lombok.NoArgsConstructor;

//지윤 26.07.08 장바구니 항목(TB_CART_ITEM + 상품정보 조인) 조회용 VO
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
    private Long bizNo; //지윤 26.07.13 추가: 주문 저장 시 TB_ORDER.BIZ_NO에 넣어야 해서 추가
    private String bizName; //지윤 26.07.30 추가: 장바구니 화면에서 사업자별로 묶어 보여주기 위해 추가
}