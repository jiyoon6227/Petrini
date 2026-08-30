package com.petcare.petcare.store.vo;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import lombok.NoArgsConstructor;

//지윤 26.07.07 상품 옵션(TB_PRODUCT_OPTION) 조회용 VO
@Getter @Setter
@ToString
@NoArgsConstructor
public class OptionVO {
    private Long optionId;
    private Long productId;
    private String optionColor;
    private String optionSize;
    private Integer addPrice;
    private Integer stockQty;
}