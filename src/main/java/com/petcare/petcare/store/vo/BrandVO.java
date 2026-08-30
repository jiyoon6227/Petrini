package com.petcare.petcare.store.vo;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import lombok.NoArgsConstructor;

//지윤 26.07.12 브랜드별 상품 수(TB_PRODUCT.BRAND_NAME 집계) 조회용 VO
@Getter @Setter
@ToString
@NoArgsConstructor
public class BrandVO {
    private String brandName;
    private Integer productCount;
}