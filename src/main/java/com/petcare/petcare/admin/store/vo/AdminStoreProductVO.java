/**
 * 2026/08/11 장우철 — 관리자 상품 목록 (전 사업자)
 * 참고: TB_PRODUCT + TB_BUSINESS + TB_PRODUCT_CATEGORY
 */
package com.petcare.petcare.admin.store.vo;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class AdminStoreProductVO {
    private Long productId;
    private String productName;
    private Long bizNo;
    private String bizName;
    private String categoryName;
    private Integer price;
    private Integer salePrice;
    private Integer stockQty;
    private String statusCd;
    private String thumbnailUrl;
    private String regDate;
}
