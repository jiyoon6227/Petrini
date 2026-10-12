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
