/**
 * 역할: 쇼핑몰 상품·주문 데이터 객체
 *
 * 필드 예시
 * - productId, productName, price, quantity, orderId
 *
 * 참고 테이블
 * - TB_PRODUCT
 * - TB_CART
 * - TB_ORDER
 *
 * DB 컬럼명은 팀 VO 규칙(camelCase)에 맞게 작성
 */

package com.petcare.petcare.store.vo;

import java.util.List;

import org.springframework.stereotype.Component;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter @Setter
@ToString
@NoArgsConstructor
@Component("storeShopVO")
public class StoreShopVO {

    // ===== 상품 목록/상세 (TB_PRODUCT) =====
    private Long productId;
    private String productCd;
    private String productName;
    private String brandName;
    private Long categoryId;
    private String categoryName;
    private Integer price;
    private Integer salePrice;
    private Integer discountRate;
    private Integer stockQty;
    private String thumbnailUrl;
    private String description;
    private Double avgRating;
    private Integer reviewCount;
    private String tags; //지윤 26.07.21 추가: 상품 특징 태그, 쉼표 구분 문자열 (사업자가 등록/수정 시 입력)

    //지윤 26.07.07 상품 상세 이미지 목록
    private List<String> imageList;

    //지윤 26.07.07 상품 옵션 목록
    private List<OptionVO> optionList;

    //지윤 26.07.07 상품 리뷰 목록 + 별점 분포(막대그래프용 %)
   private List<ReviewVO> reviewList;
   private Integer rating5Percent;
   private Integer rating4Percent;
   private Integer rating3Percent;
   private Integer rating2Percent;
   private Integer rating1Percent;

   //지윤 26.07.07 상품 Q&A 목록
   private List<QnaVO> qnaList;
}
