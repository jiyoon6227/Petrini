/**
 * 역할: 쇼핑몰(사용자) 비즈니스 로직 (interface)
 *
 * 담당 화면
 * - store/list.jsp            상품 목록
 * - store/detail.jsp          상품 상세
 * - store/cart.jsp            장바구니
 * - store/order.jsp           주문
 * - store/payment.jsp         결제
 * - store/order-complete.jsp  주문 완료
 *
 * 구현할 기능 예시
 * - 상품 목록·상세 조회
 * - 장바구니·주문·결제 처리
 *
 * 연결
 * - 구현: StoreShopServiceImpl
 * - 호출: StoreShopController
 * - DB: StoreShopMapper
 *
 * 참고 테이블
 * - TB_PRODUCT
 * - TB_CART
 * - TB_ORDER
 */

package com.petcare.petcare.store.service;

import java.util.List;

import com.petcare.petcare.store.vo.StoreShopVO;
import com.petcare.petcare.store.vo.CategoryVO;
import com.petcare.petcare.store.vo.CartItemVO;
import com.petcare.petcare.store.vo.CouponVO;
import com.petcare.petcare.store.vo.BrandVO;
import com.petcare.petcare.store.vo.OrderTempVO;

public interface StoreShopService {
//지윤 26.07.06 카테고리/검색어/정렬/페이지네이션 파라미터
//지윤 26.07.12 가격대(minPrice/maxPrice)·브랜드(brand) 필터 파라미터 추가
//지윤 26.07.30 수정: brand String -> List<String> (다중선택)
List<StoreShopVO> getProductList(Long categoryId, String keyword, Integer minPrice, Integer maxPrice, List<String> brand, String sort, int pageNo, Long bizNo);

int getTotalPages(Long categoryId, String keyword, Integer minPrice, Integer maxPrice, List<String> brand, Long bizNo);

int getTotalCount(Long categoryId, String keyword, Integer minPrice, Integer maxPrice, List<String> brand, Long bizNo);

List<BrandVO> getBrandList(Long categoryId, String keyword, Integer minPrice, Integer maxPrice, Long bizNo);

//지윤 26.07.06 카테고리 트리 조회
List<CategoryVO> getCategoryTree();

//지윤 26.07.07 상품 상세 조회
StoreShopVO getProductDetail(Long productId);

//지윤 26.07.08 장바구니 목록 조회
List<CartItemVO> getCartItems(Long memberNo);

//지윤 26.07.08 장바구니 담기 (같은 상품+옵션 있으면 수량 합침, 없으면 새로 추가)
void addToCart(Long memberNo, Long productId, Long optionId, int qty, int price);

//지윤 26.07.08 장바구니 수량 변경
void updateCartItemQty(Long cartItemId, int qty);

//지윤 26.07.08 장바구니 항목 삭제
void deleteCartItem(Long cartItemId);

//지윤 26.07.08 장바구니 항목 여러 개 한번에 삭제 (선택삭제/전체삭제용)
void deleteCartItems(java.util.List<Long> cartItemIds);

//장바구니 숫자뱃지
int getCartItemCount(Long memberNo);

//지윤 26.07.09 회원 보유쿠폰 목록 조회
List<CouponVO> getMemberCoupons(Long memberNo);

// 2026-08-13 박유정 — 주문 상품 사업자(BIZ_NO)에 해당하는 보유 쿠폰만
List<CouponVO> getMemberCouponsForOrder(Long memberNo, java.util.List<Long> bizNos);

//지윤 26.07.09 바로구매 클릭 시 해당 상품 주문페이지 이동
List<CartItemVO> getDirectOrderItem(Long productId, Long optionId, int qty);

//지윤 26.07.09 장바구니에서 체크한 항목들로 주문페이지 이동
List<CartItemVO> getCartOrderItems(java.util.List<Long> cartItemIds);

//지윤 26.07.12 수정: 등록 직후 삭제버튼 붙이려면 새로 생긴 QNA_ID가 필요해서 void -> Long으로 변경
Long addProductQna(Long productId, Long memberNo, String question, Long optionId);

//지윤 26.07.12 상품 Q&A 삭제 (본인 글 + 답변 미완료 건만). 성공 여부 반환
boolean deleteProductQna(Long qnaId, Long memberNo);

//지윤 26.07.13 결제 완료 시 주문/주문상품/결제내역 저장 + 쿠폰사용처리 + 포인트차감 + 주문한 장바구니항목 삭제를 한 트랜잭션으로 처리. 생성된 ORDER_NO 반환
/** @param payMethod TOSS(위젯) / BILLING(등록카드) / POINT 등 — TB_PAYMENT.PAY_METHOD */
String completeOrder(OrderTempVO orderTemp, String tossPaymentKey, String tossOrderId, String payMethod);

// 2026/07/27 장우철 — DB 실제 보유 포인트
Long getMemberPointBalance(Long memberNo);

//지윤 26.07.21 추가: 유저 리뷰 신고. 이미 신고한 경우 false
boolean reportReview(Long reviewId, Long reporterNo, String reason);

//지윤 26.07.21 추가: 본인이 작성한 상품 리뷰 삭제
boolean deleteProductReview(Long reviewId, Long memberNo);
}