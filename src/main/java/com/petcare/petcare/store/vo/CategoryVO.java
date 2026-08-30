package com.petcare.petcare.store.vo;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import lombok.NoArgsConstructor;

//지윤 26.07.06 카테고리 트리(TB_PRODUCT_CATEGORY) 조회용 VO
@Getter @Setter
@ToString
@NoArgsConstructor
public class CategoryVO {
    private Long categoryId;
    private Long parentId;
    private String categoryName;
    private Integer depth;
    private String categoryPath;   //지윤 26.07.15 추가: "강아지 > 사료 > 퍼피" 형태 전체 경로
}