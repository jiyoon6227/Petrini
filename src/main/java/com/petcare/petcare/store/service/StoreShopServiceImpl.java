/**
 * 역할: StoreShopService 구현체 (@Service)
 *
 * 구현 내용
 * - Controller에서 넘어온 요청 처리
 * - Mapper 호출하여 DB 조회·수정
 * - 비즈니스 규칙 검증 및 결과 반환
 *
 * 연결
 * - implements: StoreShopService
 * - 사용: StoreShopMapper
 *
 * 비즈니스 로직은 여기에 작성 (Controller, Mapper에 직접 작성 X)
 */

package com.petcare.petcare.store.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.mypage.notify.service.MypageNotifyService;
import com.petcare.petcare.file.service.FileService;
import com.petcare.petcare.store.mapper.StoreShopMapper;
import com.petcare.petcare.store.vo.BrandVO;
import com.petcare.petcare.store.vo.CartItemVO;
import com.petcare.petcare.store.vo.CategoryVO;
import com.petcare.petcare.store.vo.CouponVO;
import com.petcare.petcare.store.vo.OrderTempVO;
import com.petcare.petcare.store.vo.ReviewVO;
import com.petcare.petcare.store.vo.StoreShopVO;
import java.util.Collections;

@Service
public class StoreShopServiceImpl implements StoreShopService {

    @Autowired
    private StoreShopMapper storeShopMapper;

    @Autowired
    private com.petcare.petcare.coupon.mapper.CouponMapper couponMapper;

    @Autowired
    private FileService fileService;

    @Autowired
    private MypageNotifyService mypageNotifyService;

    //지윤 26.08.05 추가: 품절 시 사업자에게 이메일 알림 보내기 위해 주입
    @Autowired
    private com.petcare.petcare.member.auth.service.EmailService emailService;

    //지윤 26.07.06 페이지당 상품 개수 (요구사항 고정값)
    private static final int PAGE_SIZE = 12;

    //지윤 26.07.06 카테고리/검색어/정렬/페이지네이션 파라미터(pageNo) 추가, 26.07.12 가격대·브랜드 필터 파라미터 추가
    @Override
    public List<StoreShopVO> getProductList(Long categoryId, String keyword, Integer minPrice, Integer maxPrice, List<String> brand, String sort, int pageNo, Long bizNo) {
        int offset = (pageNo - 1) * PAGE_SIZE;
        List<StoreShopVO> list = storeShopMapper.selectProductList(categoryId, keyword, minPrice, maxPrice, brand, sort, offset, PAGE_SIZE, bizNo);
        for (StoreShopVO p : list) {
            if (p.getPrice() != null && p.getSalePrice() != null && p.getPrice() > 0) {
                int rate = (int) Math.round((p.getPrice() - p.getSalePrice()) * 100.0 / p.getPrice());
                p.setDiscountRate(rate);
            } else {
                p.setDiscountRate(0);
            }
        }
        return list;
    }

//지윤 26.07.06 총 페이지 수 계산 (전체개수 / 12, 나머지 있으면 올림)
//지윤 26.07.12 가격대·브랜드 필터 파라미터 추가
@Override
public int getTotalPages(Long categoryId, String keyword, Integer minPrice, Integer maxPrice, List<String> brand, Long bizNo) {
    int totalCount = storeShopMapper.selectProductCount(categoryId, keyword, minPrice, maxPrice, brand, bizNo);
    return (int) Math.ceil(totalCount / (double) PAGE_SIZE);
}

@Override
public int getTotalCount(Long categoryId, String keyword, Integer minPrice, Integer maxPrice, List<String> brand, Long bizNo) {
    return storeShopMapper.selectProductCount(categoryId, keyword, minPrice, maxPrice, brand, bizNo);
}

  @Override
  public List<BrandVO> getBrandList(Long categoryId, String keyword, Integer minPrice, Integer maxPrice, Long bizNo) {
      return storeShopMapper.selectBrandCounts(categoryId, keyword, minPrice, maxPrice, bizNo);
  }

//지윤 26.07.06 카테고리 트리는 가공 없이 그대로 전달
  @Override
  public List<CategoryVO> getCategoryTree() {
      return storeShopMapper.selectCategoryTree();
  }

//지윤 26.07.07 상품 상세 조회 + 할인율 계산 (목록조회와 동일한 계산 로직)
//지윤 26.07.07 이미지 목록도 같이 조회해서 product에 채워넣도록 수정
@Override
public StoreShopVO getProductDetail(Long productId) {
    StoreShopVO product = storeShopMapper.selectProductDetail(productId);
    if (product != null) {
        if (product.getPrice() != null && product.getSalePrice() != null && product.getPrice() > 0) {
            int rate = (int) Math.round((product.getPrice() - product.getSalePrice()) * 100.0 / product.getPrice());
            product.setDiscountRate(rate);
        } else {
            product.setDiscountRate(0);
        }
        product.setImageList(storeShopMapper.selectProductImages(productId));
        product.setOptionList(storeShopMapper.selectProductOptions(productId));

//지윤 26.07.07 리뷰 목록 조회 + 별점별 비율(%) 계산 (별점 막대그래프용)
List<ReviewVO> reviews = storeShopMapper.selectProductReviews(productId);
//지윤 26.07.23 추가: 리뷰마다 첨부 이미지 목록도 같이 채워넣음
for (ReviewVO r : reviews) {
    r.setImageUrls(storeShopMapper.selectReviewImages(r.getReviewId()));
}
product.setReviewList(reviews);
int[] count = new int[6]; // index 1~5 사용
for (ReviewVO r : reviews) {
    int star = (int) Math.round(r.getRating());
    if (star >= 1 && star <= 5) count[star]++;
}
int total = reviews.size();
product.setRating5Percent(total == 0 ? 0 : count[5] * 100 / total);
product.setRating4Percent(total == 0 ? 0 : count[4] * 100 / total);
product.setRating3Percent(total == 0 ? 0 : count[3] * 100 / total);
product.setRating2Percent(total == 0 ? 0 : count[2] * 100 / total);
product.setRating1Percent(total == 0 ? 0 : count[1] * 100 / total);

//지윤 26.07.07 Q&A 목록 조회
product.setQnaList(storeShopMapper.selectProductQna(productId));
    }
    return product;
}

//지윤 26.07.08 장바구니 목록은 가공 없이 그대로 전달
@Override
public List<CartItemVO> getCartItems(Long memberNo) {
    return storeShopMapper.selectCartItems(memberNo);
}

//지윤 26.07.08 장바구니 담기 1)회원 장바구니 없으면 생성 2)같은 상품+옵션 있으면 수량합산 3)없으면 새 줄 추가
@Override
public void addToCart(Long memberNo, Long productId, Long optionId, int qty, int price) {
    Long cartId = storeShopMapper.selectCartIdByMember(memberNo);
    if (cartId == null) {
        storeShopMapper.insertCart(memberNo);
        cartId = storeShopMapper.selectCartIdByMember(memberNo);
    }

    Long existingItemId = storeShopMapper.selectExistingCartItemId(cartId, productId, optionId);
    if (existingItemId != null) {
        storeShopMapper.updateCartItemQtyAdd(existingItemId, qty);
    } else {
        storeShopMapper.insertCartItem(cartId, productId, optionId, qty, price);
    }
}

//지윤 26.07.08 장바구니 수량 변경 (최소 1개)
@Override
public void updateCartItemQty(Long cartItemId, int qty) {
    if (qty < 1) qty = 1;
    storeShopMapper.updateCartItemQty(cartItemId, qty);
}

//지윤 26.07.08 장바구니 항목 삭제
@Override
public void deleteCartItem(Long cartItemId) {
    storeShopMapper.deleteCartItem(cartItemId);
}

//지윤 26.07.08 장바구니 항목 여러 개 한번에 삭제
@Override
public void deleteCartItems(java.util.List<Long> cartItemIds) {
    if (cartItemIds == null || cartItemIds.isEmpty()) return;
    storeShopMapper.deleteCartItems(cartItemIds);
}

//지윤 26.07.08 헤더 장바구니 뱃지용
@Override
public int getCartItemCount(Long memberNo) {
    return storeShopMapper.selectCartItemCount(memberNo);
}

//지윤 26.07.09 회원 보유쿠폰은 가공 없이 그대로 전달
@Override
public List<CouponVO> getMemberCoupons(Long memberNo) {
    return storeShopMapper.selectMemberCoupons(memberNo);
}

// 2026-08-13 박유정 — 주문 상품 사업자에 맞는 쿠폰만 (숙소 결제와 동일 개념)
@Override
public List<CouponVO> getMemberCouponsForOrder(Long memberNo, List<Long> bizNos) {
    if (memberNo == null || bizNos == null || bizNos.isEmpty()) {
        return Collections.emptyList();
    }
    return couponMapper.selectMemberCouponsByBizNos(memberNo, bizNos);
}

//지윤 07.09 바로구매 클릭 시 해당상품 주문페이지로 이동
@Override
public List<CartItemVO> getDirectOrderItem(Long productId, Long optionId, int qty) {
    CartItemVO item = storeShopMapper.selectDirectOrderItem(productId, optionId);
    item.setQty(qty);
    return java.util.List.of(item);
}

//지윤 26.07.09 장바구니에서 체크한 항목들로 주문페이지 이동
@Override
public List<CartItemVO> getCartOrderItems(java.util.List<Long> cartItemIds) {
    return storeShopMapper.selectCartItemsByIds(cartItemIds);
}
//지윤 26.07.10 상품 Q&A 문의 등록
//지윤 26.07.12 수정: 등록 직후 QNA_ID 조회해서 반환하도록 변경 (프론트에서 삭제버튼 바로 붙이기 위함)
@Override
public Long addProductQna(Long productId, Long memberNo, String question, Long optionId) {
    storeShopMapper.insertProductQna(productId, memberNo, question, optionId);
    return storeShopMapper.selectLatestQnaId(productId, memberNo);
}

//지윤 26.07.12 상품 Q&A 삭제 (본인 글 + 답변 미완료 건만). 삭제된 row수가 0이면 실패(본인 아니거나 답변 이미 달림)
@Override
public boolean deleteProductQna(Long qnaId, Long memberNo) {
    return storeShopMapper.deleteProductQna(qnaId, memberNo) > 0;
}

//지윤 26.07.13 결제 완료 처리 (주문/주문상품/결제내역 저장 + 쿠폰/포인트 반영 + 장바구니 정리)
//@Transactional: 중간에 하나라도 실패하면 전부 롤백됨
//지윤 26.07.30 수정: 장바구니에 여러 사업자 상품이 섞여도, TB_ORDER를 사업자(BIZ_NO)별로 각각 생성하도록 전면 수정.
//쿠폰은 발급 사업자 몫에만, 포인트는 상품금액 비례로 각 주문에 나눠 배분함.
@Override
@Transactional
public String completeOrder(OrderTempVO p, String tossPaymentKey, String tossOrderId, String payMethod) {
    // 2026/08/11 장우철 — 빌링/위젯 구분 저장 (취소·환불 시 시크릿 분기용). 미지정이면 TOSS
    if (payMethod == null || payMethod.isBlank()) {
        payMethod = "TOSS";
    }
    final String resolvedPayMethod = payMethod.trim().toUpperCase();

    //1) 상품을 사업자(BIZ_NO)별로 묶음 (LinkedHashMap이라 처음 등장한 순서 유지)
    java.util.Map<Long, java.util.List<CartItemVO>> groups = new java.util.LinkedHashMap<>();
    for (CartItemVO item : p.getOrderItems()) {
        groups.computeIfAbsent(item.getBizNo(), k -> new java.util.ArrayList<>()).add(item);
    }

    //2) 포인트를 상품금액 비례로 배분할 때 반올림 오차를 마지막 그룹이 흡수하도록 미리 계산
    int totalProductAmt = p.getProductTotal();
    int remainingPoint = p.getPointUsed() != null ? p.getPointUsed() : 0;
    int groupIndex = 0;
    int groupCount = groups.size();

    java.util.List<String> orderNos = new java.util.ArrayList<>();

    for (java.util.Map.Entry<Long, java.util.List<CartItemVO>> entry : groups.entrySet()) {
        groupIndex++;
        Long bizNo = entry.getKey();
        java.util.List<CartItemVO> items = entry.getValue();

        int groupSubtotal = 0;
        for (CartItemVO item : items) {
            groupSubtotal += item.getPrice() * item.getQty();
        }
        int groupDeliveryFee = (groupSubtotal >= 50000) ? 0 : 3000;

        //지윤 26.07.30 수정: 쿠폰은 발급 사업자(couponBizNo)와 이 그룹의 bizNo가 일치할 때만 적용
        int groupCouponDiscount = 0;
        if (p.getCouponBizNo() != null && bizNo != null
                && bizNo.equals(Long.valueOf(p.getCouponBizNo()))) {
            groupCouponDiscount = p.getCouponDiscount() != null ? p.getCouponDiscount() : 0;
        }

        //지윤 26.07.30 추가: 포인트는 상품금액 비례 배분, 마지막 그룹은 나머지 전부(반올림 오차 흡수)
        int groupPointUsed;
        if (groupIndex == groupCount) {
            groupPointUsed = remainingPoint;
        } else {
            groupPointUsed = totalProductAmt == 0 ? 0
                    : (int) ((long) (p.getPointUsed() != null ? p.getPointUsed() : 0) * groupSubtotal / totalProductAmt);
            remainingPoint -= groupPointUsed;
        }

        int groupDiscountAmount = groupCouponDiscount + groupPointUsed;
        int groupFinalTotal = Math.max(0, groupSubtotal + groupDeliveryFee - groupDiscountAmount);

        //지윤 26.07.29 수정: 밀리초 나머지(ts % 10000) 방식은 10초마다 값이 반복되어 ORDER_NO(UNIQUE 제약)가 겹칠 위험이 있었음
        //-> 뒷자리를 "실제 PK가 될 ORDER_ID"로 교체 (MAX+1 방식, 이 프로젝트 공통 채번 규칙이라 절대 안 겹침)
        Long orderId = storeShopMapper.selectNextOrderId();
        String datePart = new java.text.SimpleDateFormat("yyyyMMdd").format(new java.util.Date());
        String orderNo = "ORD" + datePart + "-" + String.format("%06d", orderId);
        orderNos.add(orderNo);

        Long groupMemberCouponId = groupCouponDiscount > 0 ? p.getCouponMemberCouponId() : null;

        storeShopMapper.insertOrder(orderId, orderNo, p.getMemberNo(), groupSubtotal, groupDeliveryFee,
                groupDiscountAmount, groupPointUsed, groupFinalTotal,
                p.getRecvName(), p.getRecvPhone(), p.getZipCode(), p.getAddr1(), p.getAddr2(), bizNo,
                p.getDeliveryMemo(), groupMemberCouponId);

        //지윤 26.07.21 추가: 주문 접수 즉시 사업자에게 알림 (알림함 "주문" 탭). 대표 상품명은 이 그룹 첫 상품 기준
        Long bizMemberNoForOrder = storeShopMapper.selectBizMemberNoByBizNo(bizNo);
        mypageNotifyService.sendNewOrderNotification(bizMemberNoForOrder, orderNo,
                items.get(0).getProductName(), items.size());

        for (CartItemVO item : items) {
            storeShopMapper.insertOrderItem(orderId, item.getProductId(), item.getOptionId(),
                    item.getOptionColor(), item.getOptionSize(), item.getProductName(),
                    item.getQty(), item.getPrice(), item.getPrice() * item.getQty());

            //지윤 26.07.13 추가: 주문 확정된 만큼 재고 차감 (옵션 있으면 옵션 재고, 없으면 상품 재고)
            //지윤 26.07.15 수정: 옵션 재고 깎을 때도 상품 전체 재고를 같이 깎아야 목록/상태 표시가 맞음
            //HYJ 26.08.13 재고수량 lock
            if (item.getOptionId() != null) {
                if (item.getOptionId() != null) {
                    // 1) 재고를 조회하면서 행 잠금 (다른 주문은 여기서 대기)
                    Integer currentStock = storeShopMapper.selectOptionStockForUpdate(item.getOptionId());
                
                    // 2) 재고가 부족하면 예외 발생 → @Transactional이 전체 롤백
                    if (currentStock == null || currentStock < item.getQty()) {
                        throw new RuntimeException(
                            "'" + item.getProductName() + "' 상품의 재고가 부족합니다. (남은 재고: "
                            + (currentStock != null ? currentStock : 0) + "개)");
                    }
                
                    // 3) 재고 충분하면 차감
                    storeShopMapper.updateOptionStock(item.getOptionId(), item.getQty());
                }
            }

    //지윤 26.07.15 수정: 차감 후 상품 전체 재고가 0이면 자동 품절 처리
    //지윤 26.07.16 수정: 방금 품절로 "새로 바뀐" 경우에만(반환값>0) 사업자에게 알림 전송
        int soldoutJustNow = storeShopMapper.checkAndSetSoldout(item.getProductId());
        if (soldoutJustNow > 0) {
    // 기존: 인앱 알림(알림함)
    Long bizMemberNo = storeShopMapper.selectBizMemberNoByBizNo(item.getBizNo());
    mypageNotifyService.sendProductSoldoutNotification(bizMemberNo, item.getProductName(), item.getProductId());

    //지윤 26.08.05 추가: 인앱 알림뿐 아니라 이메일로도 품절 안내
    //사업자 승인 알림(sendApproveNotice)이랑 완전히 같은 패턴 - EmailService.send()를 재사용
    try {
        String bizEmail = storeShopMapper.selectBizEmailByBizNo(item.getBizNo());
        if (bizEmail != null && !bizEmail.isBlank()) {
            String bizName = storeShopMapper.selectBizNameByBizNo(item.getBizNo());
            emailService.sendSoldoutNotice(bizEmail, bizName, item.getProductName());
        }
    } catch (Exception e) {
        //이메일 발송(외부 SMTP 의존)이 실패해도 결제/재고차감 같은 핵심 흐름은 절대 막히면 안 되므로
        //예외를 여기서 잡아서 흐름은 계속 진행시키고, 로그만 남김
        e.printStackTrace();
    }
}
        }

        //지윤 26.07.30 수정: 토스 결제 1건에 대해, 사업자 수만큼 TB_PAYMENT도 각각 생성 (같은 paymentKey/orderId 공유, orderId 컬럼만 다름)
        // 2026/08/11 장우철 — PAY_METHOD에 BILLING/TOSS/POINT 실제 수단 저장 (기존 하드코딩 TOSS 제거)
        storeShopMapper.insertPayment(orderId, resolvedPayMethod, groupFinalTotal, tossPaymentKey, tossOrderId);

        //지윤 26.07.30 수정: 포인트 사용 이력도 그룹(주문)별로 나눠서 남김
        if (groupPointUsed > 0) {
            storeShopMapper.insertPointHistory(p.getMemberNo(), groupPointUsed, orderId);
        }
    }

    //쿠폰 사용처리, 포인트 잔액 차감은 결제 1건당 한 번만
    if (p.getCouponMemberCouponId() != null && p.getCouponDiscount() != null && p.getCouponDiscount() > 0) {
        storeShopMapper.updateCouponUsed(p.getCouponMemberCouponId());
    }

    if (p.getPointUsed() != null && p.getPointUsed() > 0) {
        // 2026/07/27 장우철 — DB 잔액 부족이면 차감 실패 → 트랜잭션 롤백
        int updated = storeShopMapper.updateMemberPointBalance(p.getMemberNo(), p.getPointUsed());
        if (updated != 1) {
            throw new RuntimeException("보유 포인트가 부족합니다.");
        }
    }

    if (p.getCartItemIds() != null && !p.getCartItemIds().isEmpty()) {
        storeShopMapper.deleteCartItems(p.getCartItemIds());
    }

    //지윤 26.07.30 수정: 주문이 여러 건으로 쪼개질 수 있어서 쉼표로 이어붙여 반환 (order-complete 화면엔 그대로 표시됨)
    return String.join(", ", orderNos);
}

// 2026/07/27 장우철 — DB 실제 보유 포인트
@Override
public Long getMemberPointBalance(Long memberNo) {
    Long bal = storeShopMapper.selectMemberPointBalance(memberNo);
    return bal != null ? bal : 0L;
}

//지윤 26.07.21 추가: 유저 리뷰 신고 - 같은 유저가 같은 리뷰 중복 신고 못 하게 막음
@Override
public boolean reportReview(Long reviewId, Long reporterNo, String reason) {
    if (storeShopMapper.selectUserReportExists(reviewId, reporterNo) > 0) {
        return false;
    }
    Long bizNo = storeShopMapper.selectBizNoByReviewId(reviewId);
    storeShopMapper.insertUserReviewReport(reviewId, reporterNo, bizNo, reason);
    return true;
}

//지윤 26.07.21 추가: 본인 상품 리뷰 삭제 (신고 FK 해제 + 첨부 사진 + TB_REVIEW)
@Override
@Transactional
public boolean deleteProductReview(Long reviewId, Long memberNo) {
    storeShopMapper.clearReviewReportsByReviewId(reviewId);
    try {
        fileService.deleteFilesByRef("REVIEW", reviewId);
    } catch (Exception e) {
        throw new RuntimeException("리뷰 첨부 파일 삭제 실패", e);
    }
    return storeShopMapper.deleteProductReview(reviewId, memberNo) > 0;
}
}