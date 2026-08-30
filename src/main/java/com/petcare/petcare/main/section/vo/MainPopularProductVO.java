package com.petcare.petcare.main.section.vo;

import lombok.Getter;
import lombok.Setter;

/*
 *  2026/07/06 장우철 추가
 *  메인페이지 인기상품 데이터
 */
@Getter
@Setter
public class MainPopularProductVO {

    private Long productId;
    private String productName;
    private String brandName;
    private Long price;
    private Long salePrice;
    private String imageUrl;
    private int discountRate;
}
