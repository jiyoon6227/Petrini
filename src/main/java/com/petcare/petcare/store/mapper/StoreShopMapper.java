/**
 * 역할: 쇼핑몰 DB 접근 (MyBatis interface)
 *
 * XML: resources/mybatis/mapper/store/StoreShopMapper.xml
 * namespace: com.petcare.petcare.store.mapper.StoreShopMapper
 *
 * 쿼리 예시
 * - selectProductList
 * - selectProductDetail
 * - selectCartItems
 * - insertOrder
 *
 * 참고 테이블
 * - TB_PRODUCT
 * - TB_CART
 * - TB_ORDER
 *
 * SQL은 XML에만 작성 (@Select 등 어노테이션 사용 X)
 * 메서드명은 Service에서 호출하는 이름과 동일하게
 */

package com.petcare.petcare.store.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.store.vo.StoreShopVO;
import com.petcare.petcare.store.vo.CategoryVO;
import com.petcare.petcare.store.vo.OptionVO;
import com.petcare.petcare.store.vo.ReviewVO;
import com.petcare.petcare.store.vo.QnaVO;
import com.petcare.petcare.store.vo.CartItemVO;
import com.petcare.petcare.store.vo.CouponVO;
import com.petcare.petcare.store.vo.BrandVO;

@Mapper
public interface StoreShopMapper {

    //지윤 26.07.06 카테고리/검색어/정렬/페이지네이션 파라미터(offset, size) 추가
    //지윤 26.07.12 가격대(minPrice/maxPrice)·브랜드(brand) 필터 파라미터 추가
    //지윤 26.07.30 수정: brand String -> List<String> (MyBatis foreach로 IN절 처리)
    List<StoreShopVO> selectProductList(@Param("categoryId") Long categoryId, @Param("keyword") String keyword,
                                         @Param("minPrice") Integer minPrice, @Param("maxPrice") Integer maxPrice,
                                         @Param("brand") List<String> brand,
                                         @Param("sort") String sort, @Param("offset") int offset, @Param("size") int size,
                                         @Param("bizNo") Long bizNo);

    int selectProductCount(@Param("categoryId") Long categoryId, @Param("keyword") String keyword,
                            @Param("minPrice") Integer minPrice, @Param("maxPrice") Integer maxPrice,
                            @Param("brand") List<String> brand, @Param("bizNo") Long bizNo);

    List<BrandVO> selectBrandCounts(@Param("categoryId") Long categoryId, @Param("keyword") String keyword,
                                     @Param("minPrice") Integer minPrice, @Param("maxPrice") Integer maxPrice,
                                     @Param("bizNo") Long bizNo);

    //지윤 26.07.06 카테고리 트리 전체 조회
    List<CategoryVO> selectCategoryTree();

    //지윤 26.07.07 상품 상세 조회
   StoreShopVO selectProductDetail(@Param("productId") Long productId);

   //지윤 26.07.07 상품 이미지 목록 조회
   List<String> selectProductImages(@Param("productId") Long productId);

   //지윤 26.07.07 상품 옵션 목록 조회
   List<OptionVO> selectProductOptions(@Param("productId") Long productId);

   //지윤 26.07.07 상품 리뷰 목록 조회
   List<ReviewVO> selectProductReviews(@Param("productId") Long productId);

   //지윤 26.07.23 추가: 리뷰 첨부 이미지 목록
   List<String> selectReviewImages(@Param("reviewId") Long reviewId);

   //지윤 26.07.07 상품 Q&A 목록 조회
   List<QnaVO> selectProductQna(@Param("productId") Long productId);

   //지윤 26.07.08 장바구니 목록 조회 (상품/옵션 정보 조인)
   List<CartItemVO> selectCartItems(@Param("memberNo") Long memberNo);

   //지윤 26.07.08 이 회원의 장바구니(CART_ID) 조회, 없으면 null
   Long selectCartIdByMember(@Param("memberNo") Long memberNo);

   //지윤 26.07.08 신규 장바구니 생성
   void insertCart(@Param("memberNo") Long memberNo);

   //지윤 26.07.08 이미 담긴 상품+옵션인지 확인 (있으면 그 CART_ITEM_ID, 없으면 null)
   Long selectExistingCartItemId(@Param("cartId") Long cartId, @Param("productId") Long productId, @Param("optionId") Long optionId);

   //지윤 26.07.08 기존 항목 수량 추가
   void updateCartItemQtyAdd(@Param("cartItemId") Long cartItemId, @Param("addQty") int addQty);

   //지윤 26.07.08 새 항목 추가
   void insertCartItem(@Param("cartId") Long cartId, @Param("productId") Long productId, @Param("optionId") Long optionId, @Param("qty") int qty, @Param("price") int price);

   //지윤 26.07.08 장바구니 수량 변경
   void updateCartItemQty(@Param("cartItemId") Long cartItemId, @Param("qty") int qty);

   //지윤 26.07.08 장바구니 항목 삭제
   void deleteCartItem(@Param("cartItemId") Long cartItemId);

   //지윤 26.07.08 장바구니 항목 여러 개 한번에 삭제 (선택삭제/전체삭제용)
   void deleteCartItems(@Param("cartItemIds") java.util.List<Long> cartItemIds);

   //지윤 26.07.08 헤더 장바구니 뱃지용 - 회원의 장바구니 항목 개수
   int selectCartItemCount(@Param("memberNo") Long memberNo);

   //지윤 26.07.09 회원 보유쿠폰 목록 조회 (미사용 쿠폰만)
   List<CouponVO> selectMemberCoupons(@Param("memberNo") Long memberNo);

   //지윤 07.09 상품 바로구매 -> 주문페이지
   CartItemVO selectDirectOrderItem(@Param("productId") Long productId,
                                 @Param("optionId") Long optionId);

   //지윤 26.07.09 장바구니에서 체크한 항목들로 주문페이지 이동
   List<CartItemVO> selectCartItemsByIds(@Param("cartItemIds") java.util.List<Long> cartItemIds);

   //지윤 26.07.10 상품 Q&A 문의 등록
   void insertProductQna(@Param("productId") Long productId, @Param("memberNo") Long memberNo, @Param("question") String question, @Param("optionId") Long optionId);

   //지윤 26.07.12 상품 Q&A 삭제 (본인 글 + 답변 미완료 건만). 삭제된 row수 반환 (0이면 실패 원인 구분용)
   int deleteProductQna(@Param("qnaId") Long qnaId, @Param("memberNo") Long memberNo);

   //지윤 26.07.13 주문 저장 (결제 완료 시)
   //지윤 26.07.21 수정: 배송 요청사항(deliveryMemo) 파라미터 추가
   //지윤 26.07.23 수정: 사용한 회원쿠폰(memberCouponId) 파라미터 추가 (취소 시 복구용)
   void insertOrder(@Param("orderId") Long orderId, @Param("orderNo") String orderNo, @Param("memberNo") Long memberNo,
                  @Param("totalAmount") Integer totalAmount, @Param("deliveryFee") Integer deliveryFee,
                  @Param("discountAmount") Integer discountAmount, @Param("pointUsed") Integer pointUsed,
                  @Param("payAmount") Integer payAmount, @Param("recvName") String recvName,
                  @Param("recvPhone") String recvPhone, @Param("zipCode") String zipCode,
                  @Param("addr1") String addr1, @Param("addr2") String addr2, @Param("bizNo") Long bizNo,
                  @Param("deliveryMemo") String deliveryMemo, @Param("memberCouponId") Long memberCouponId);

//지윤 26.07.29 추가: 주문번호(ORDER_NO) 뒷자리로 쓸 다음 ORDER_ID를 미리 조회 (PK라 절대 안 겹침)
Long selectNextOrderId();

    //지윤 26.07.13 방금 저장한 주문의 ORDER_ID 조회 (ORDER_NO는 UNIQUE라 이걸로 되짚어 조회)
    Long selectOrderIdByOrderNo(@Param("orderNo") String orderNo);

    //지윤 26.07.13 주문상품 저장 (주문 1건당 여러 번 호출)
    void insertOrderItem(@Param("orderId") Long orderId, @Param("productId") Long productId,
                          @Param("optionId") Long optionId, @Param("optionColor") String optionColor,
                          @Param("optionSize") String optionSize, @Param("productName") String productName,
                          @Param("qty") Integer qty, @Param("unitPrice") Integer unitPrice, @Param("totalPrice") Integer totalPrice);

    //지윤 26.07.13 결제내역 저장
    void insertPayment(@Param("orderId") Long orderId, @Param("payMethod") String payMethod,
                        @Param("payAmount") Integer payAmount, @Param("tossPaymentKey") String tossPaymentKey,
                        @Param("tossOrderId") String tossOrderId);

    //지윤 26.07.13 쿠폰 사용 처리
    void updateCouponUsed(@Param("memberCouponId") Long memberCouponId);

    //지윤 26.07.13 포인트 차감
    // 2026/07/27 장우철 — 잔액 부족이면 0건 (음수 방지). 반환값: 성공 1 / 실패 0
    int updateMemberPointBalance(@Param("memberNo") Long memberNo, @Param("pointUsed") Integer pointUsed);

    // 2026/07/27 장우철 — 주문·결제 시 DB 실제 보유 포인트 조회
    Long selectMemberPointBalance(@Param("memberNo") Long memberNo);

    //지윤 26.07.13 포인트 사용 이력 저장
    void insertPointHistory(@Param("memberNo") Long memberNo, @Param("pointUsed") Integer pointUsed, @Param("orderId") Long orderId);
    
    //지윤 26.07.12 방금 등록한 문의의 QNA_ID 조회 (등록 직후 화면에 삭제버튼 바로 붙이기 위함)
    Long selectLatestQnaId(@Param("productId") Long productId, @Param("memberNo") Long memberNo);

    //지윤 26.07.13 주문 완료 시 재고 차감 - 옵션 있는 상품용 (TB_PRODUCT_OPTION.STOCK_QTY)
    void updateOptionStock(@Param("optionId") Long optionId, @Param("qty") Integer qty);

    //지윤 26.07.15 추가: 재고 0 되면 자동 품절 처리
    int checkAndSetSoldout(@Param("productId") Long productId);

    //지윤 26.07.16 추가: 품절 알림 보낼 사업자 회원번호 조회
    Long selectBizMemberNoByBizNo(@Param("bizNo") Long bizNo);

    //지윤 26.08.05 추가: 품절 이메일 발송 대상 사업자 이메일 조회

    String selectBizEmailByBizNo(@Param("bizNo") Long bizNo);

    //지윤 26.08.05 추가: 품절 이메일 인사말용 사업자명 조회
    String selectBizNameByBizNo(@Param("bizNo") Long bizNo);

    //지윤 26.07.21 추가: 유저가 리뷰 신고 (TB_REVIEW_REPORT, REPORTER_TYPE='USER')
    //본인이 같은 리뷰를 이미 신고했으면 조용히 0건 처리 (SQL에서 중복 검증)
    void insertUserReviewReport(@Param("reviewId") Long reviewId, @Param("reporterNo") Long reporterNo,
                                 @Param("bizNo") Long bizNo, @Param("reason") String reason);

    //지윤 26.07.21 추가: 같은 유저가 같은 리뷰를 이미 신고했는지 확인
    int selectUserReportExists(@Param("reviewId") Long reviewId, @Param("reporterNo") Long reporterNo);

    //지윤 26.07.21 추가: 신고할 리뷰가 속한 상품의 BIZ_NO 조회
    Long selectBizNoByReviewId(@Param("reviewId") Long reviewId);

    //지윤 26.07.21 추가: 리뷰 삭제 전 TB_REVIEW_REPORT FK 참조 해제
    void clearReviewReportsByReviewId(@Param("reviewId") Long reviewId);

    //지윤 26.07.21 추가: 본인이 작성한 상품 리뷰 삭제 (삭제 row 수)
    int deleteProductReview(@Param("reviewId") Long reviewId, @Param("memberNo") Long memberNo);

    // HYJ 26.08.13 옵션 재고를 조회하면서 행 잠금 (SELECT FOR UPDATE)
    Integer selectOptionStockForUpdate(@Param("optionId") Long optionId);
}