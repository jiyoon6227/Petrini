/**
 * 역할: 사업자 쇼핑몰 DB 접근 (MyBatis interface)
 *
 * XML: resources/mybatis/mapper/biz/store/BizStoreMapper.xml
 * namespace: com.petcare.petcare.biz.store.mapper.BizStoreMapper
 *
 * 쿼리 예시
 * - selectBizDashboard
 * - selectProductList
 * - updateProduct
 * - selectOrderList
 * - updateOrderStatus
 * - selectReviewList
 *
 * 참고 테이블
 * - TB_PRODUCT
 * - TB_ORDER
 * - TB_ORDER_ITEM
 * - TB_REVIEW
 *
 * SQL은 XML에만 작성 (@Select 등 어노테이션 사용 X)
 * 메서드명은 Service에서 호출하는 이름과 동일하게
 */

package com.petcare.petcare.biz.store.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.biz.store.vo.BizOrderVO;
import com.petcare.petcare.biz.store.vo.BizProductVO;
import com.petcare.petcare.store.vo.CategoryVO;
import com.petcare.petcare.store.vo.OptionVO;
import com.petcare.petcare.biz.store.vo.BizReviewVO;
import com.petcare.petcare.biz.store.vo.BizOrderItemVO;
import com.petcare.petcare.biz.store.vo.BizDeliveryVO;
import com.petcare.petcare.biz.vo.BizCouponVO;

@Mapper
public interface BizStoreMapper {

    //지윤 26.07.14 로그인 ID(BIZ_ID)로 BIZ_NO 조회
    //세션(MemberVO)엔 bizNo가 없고 로그인 ID(=BIZ_ID)만 있어서, 매 요청마다 TB_BUSINESS에서 되짚어 조회함
    Long selectBizNoByBizId(@Param("bizId") String bizId);

    //지윤 26.07.14 사업자 상품목록 조회
    //로그인한 사업자(bizNo)가 등록한 상품만, 상품명 검색(keyword)/카테고리명(categoryName)/상태(statusCd) 필터 적용
    //offset/size로 페이지네이션 처리 (한 페이지에 몇 개씩 보여줄지)
    //2026/08/06 장우철: categoryId → categoryName (동일 명칭 카테고리 통합 필터)
    List<BizProductVO> selectProductList(@Param("bizNo") Long bizNo, @Param("keyword") String keyword,
                                          @Param("categoryName") String categoryName, @Param("statusCd") String statusCd,
                                          @Param("offset") int offset, @Param("size") int size);

    //지윤 26.07.14 상품목록 전체 개수 조회 (페이지네이션에서 "총 몇 페이지"를 계산하기 위함, 필터 조건은 목록 조회와 동일)
    int selectProductCount(@Param("bizNo") Long bizNo, @Param("keyword") String keyword,
                            @Param("categoryName") String categoryName, @Param("statusCd") String statusCd);

    //지윤 26.07.14 상품 등록 시 사용할 다음 PRODUCT_ID를 미리 조회
    //PRODUCT_CD("P-0025" 형식)를 만들려면 새 ID값이 먼저 필요해서, INSERT 전에 이 값부터 뽑음
    Long selectNextProductId();

    //지윤 26.07.14 상품 등록 (실제 TB_PRODUCT에 새 상품 저장)
    //지윤 26.07.16 수정: STOCK_QTY 컬럼 삭제 -> 재고는 이제 TB_PRODUCT_OPTION에서만 관리
    void insertProduct(@Param("productId") Long productId, @Param("productCd") String productCd,
                        @Param("productName") String productName, @Param("bizNo") Long bizNo,
                        @Param("categoryId") Long categoryId, @Param("price") Integer price,
                        @Param("salePrice") Integer salePrice,
                        @Param("description") String description, @Param("brandName") String brandName,
                        @Param("statusCd") String statusCd, @Param("tags") String tags);

    //지윤 26.07.14 상품 등록 시 이미지 URL도 같이 저장 (TB_FILE에 REF_TYPE='PRODUCT'로 저장)
    void insertProductImage(@Param("productId") Long productId, @Param("fileUrl") String fileUrl,
                             @Param("originName") String originName);

    //지윤 26.07.14 상품 상세 1건 조회 (수정 모달 열 때, 기존 값 채워서 보여주기 위함)
    //bizNo 조건도 같이 걸어서, 다른 사업자 상품 ID를 넣어도 조회 자체가 안 되게 막음
    BizProductVO selectProductDetail(@Param("productId") Long productId, @Param("bizNo") Long bizNo);

    //지윤 26.07.14 상품 수정
    //WHERE절에 bizNo도 같이 걸어서 본인이 등록한 상품만 수정되게 함 (다른 사업자 상품 ID로 요청 보내도 0건 수정되고 조용히 끝남)
    //statusCd도 같이 받아서 판매중/품절/입고대기/판매중지 상태를 강제로 바꿀 수 있게 함
    //지윤 26.07.16 수정: STOCK_QTY 컬럼 삭제
    int updateProduct(@Param("productId") Long productId, @Param("bizNo") Long bizNo,
    @Param("productName") String productName, @Param("categoryId") Long categoryId,
    @Param("price") Integer price, @Param("salePrice") Integer salePrice,
    @Param("description") String description,
    @Param("brandName") String brandName, @Param("statusCd") String statusCd, @Param("tags") String tags);

    //지윤 26.07.14 상품 등록/수정 폼의 카테고리 드롭다운용
    //최하위(4단계) 카테고리만 조회 (TB_PRODUCT.CATEGORY_ID가 실제로 참조하는 단계라서 그것만 골라옴)
    List<CategoryVO> selectLeafCategories();

    //2026/08/06 장우철: 상품목록 필터 드롭다운용 카테고리명(중복 제거)
    List<String> selectFilterCategoryNames();

    //지윤 26.07.15 상품 옵션 목록 조회 (목록/상세 화면에서 옵션별(색상, 사이즈) 재고 나눠서 보여줄 때 사용)
    List<OptionVO> selectProductOptions(@Param("productId") Long productId);

    //지윤 26.07.15 옵션 등록 시 다음 OPTION_ID 조회 (SEQ_PRODUCT_OPTION 시퀀스 있으면 이 메서드 SQL만 바꾸면 됨)
    Long selectNextOptionId();

    //지윤 26.07.15 상품 옵션 등록 (등록/수정 공통으로 사용)
    void insertProductOption(@Param("optionId") Long optionId, @Param("productId") Long productId,
                              @Param("optionColor") String optionColor, @Param("optionSize") String optionSize,
                              @Param("addPrice") Integer addPrice, @Param("stockQty") Integer stockQty);

    //지윤 26.07.24 추가: 상품수정 시 OPTION_ID 기준 옵션 upsert 처리용
    void updateProductOptionById(@Param("optionId") Long optionId, @Param("optionColor") String optionColor,
                                  @Param("optionSize") String optionSize, @Param("addPrice") Integer addPrice,
                                  @Param("stockQty") Integer stockQty);
    int selectOrderItemCountByOption(@Param("optionId") Long optionId);
    void deleteProductOptionById(@Param("optionId") Long optionId);
    

    //지윤 26.07.15 상품 옵션 전체 삭제 (수정 시 기존 옵션 지우고 새로 등록하는 방식이라 필요)
    void deleteProductOptions(@Param("productId") Long productId);

    //지윤 26.07.20 추가: 사업자 주문 목록 조회
    List<BizOrderVO> selectOrderList(@Param("bizNo") Long bizNo, @Param("statusCd") String statusCd);

    //지윤 26.07.20 추가: 상태별 주문 개수 (탭 숫자 표시용)
    List<java.util.Map<String, Object>> selectOrderStatusCounts(@Param("bizNo") Long bizNo);

    //지윤 26.07.20 추가: 주문 상세 조회
    BizOrderVO selectOrderDetail(@Param("orderId") Long orderId, @Param("bizNo") Long bizNo);

    //지윤 26.07.20 추가: 주문 상세 - 상품 목록
    List<BizOrderItemVO> selectOrderItems(@Param("orderId") Long orderId);

    //지윤 26.07.20 추가: 주문 상태 변경 (본인 주문만, 수정된 row수 반환)
    int updateOrderStatus(@Param("orderId") Long orderId, @Param("bizNo") Long bizNo, @Param("orderStatus") String orderStatus);

    //지윤 26.07.27 추가: 배송조회(스마트택배 API) 시점에 실제 배송완료(level=6) 확인되면 자동 DONE 처리
    //이미 DONE이면 WHERE절에서 걸러져서 0건 UPDATE됨 -> DELIVERED_AT 중복 갱신 방지용 가드
    int autoCompleteOrderStatus(@Param("orderId") Long orderId, @Param("bizNo") Long bizNo);

    //지윤 26.07.28 추가: 배송조회 시 level 2~5(이동중)인데 아직 PAID/READY인 주문을 SHIPPING으로 자동승격
    //이미 SHIPPING/DONE/CANCEL이면 WHERE절에서 0건 (역행 방지)
    int autoElevateToShipping(@Param("orderId") Long orderId, @Param("bizNo") Long bizNo);

    //지윤 26.07.28 추가: 자동동기화 스케줄러(DeliveryAutoSyncScheduler, 기본 비활성화)가 순회할 대상 목록
    //조건: DONE/CANCEL 아니고, 송장번호+택배사코드 둘 다 등록된 주문 (전체 사업자 대상)
    List<java.util.Map<String, Object>> selectOrdersNeedingSync();

    //지윤 26.07.27 추가: TB_ORDER_DELIVERY.DELIVERY_STATUS만 갱신 (courier/tracking 값은 안 건드림)
    int updateDeliveryStatusOnly(@Param("orderId") Long orderId, @Param("deliveryStatus") String deliveryStatus);

    //지윤 26.07.22 추가: 취소신청 대기중 건수 (탭 숫자용)
    int selectClaimPendingCount(@Param("bizNo") Long bizNo);

    //지윤 26.07.23 추가: 오늘 신규 주문 건수 (홈 대시보드용)
    int selectTodayNewOrderCount(@Param("bizNo") Long bizNo);
    
    //지윤 26.07.22 추가: 취소신청 승인/반려
    int updateClaimApprove(@Param("orderId") Long orderId, @Param("bizNo") Long bizNo, @Param("refundAmount") Integer refundAmount);
    int updateClaimReject(@Param("orderId") Long orderId, @Param("bizNo") Long bizNo);

    //지윤 26.07.22 추가: 취소승인 후속처리 (결제상태/재고/포인트/쿠폰)
    int updatePaymentCancelStatus(@Param("orderId") Long orderId);
    int restoreStock(@Param("optionId") Long optionId, @Param("qty") Integer qty);
    int restoreProductStatusIfNeeded(@Param("productId") Long productId);
    int selectMemberPointBalance(@Param("memberNo") Long memberNo);
    int restoreMemberPoint(@Param("memberNo") Long memberNo, @Param("newBalance") Integer newBalance);
    int insertPointRefundHistory(@Param("memberNo") Long memberNo, @Param("pointAmount") Integer pointAmount,
                                  @Param("balanceAfter") Integer balanceAfter, @Param("orderId") Long orderId);
    int restoreCoupon(@Param("memberCouponId") Long memberCouponId);

    //지윤 26.07.21 추가: 배송 단계(READY_AT/SHIPPING_AT/DELIVERED_AT)별 시각 자동 기록 - 타임라인용
    void updateDeliveryTimestamp(@Param("orderId") Long orderId, @Param("bizNo") Long bizNo, @Param("column") String column);

    //지윤 26.07.20 추가: 배송정보(TB_ORDER_DELIVERY) 존재 여부 확인
    int selectDeliveryExists(@Param("orderId") Long orderId);

    //지윤 26.07.20 추가: 배송정보 신규 등록
    //지윤 26.07.24 수정: courierCode 파라미터 추가 (택배사 API 연동용)
    void insertOrderDelivery(@Param("orderId") Long orderId, @Param("bizNo") Long bizNo,
                              @Param("courierName") String courierName, @Param("courierCode") String courierCode,
                              @Param("trackingNo") String trackingNo, @Param("deliveryStatus") String deliveryStatus);

    //지윤 26.07.20 추가: 배송정보 수정
    //지윤 26.07.24 수정: courierCode 파라미터 추가
    void updateOrderDelivery(@Param("orderId") Long orderId, @Param("courierName") String courierName,
                              @Param("courierCode") String courierCode,
                              @Param("trackingNo") String trackingNo, @Param("deliveryStatus") String deliveryStatus);

    //지윤 26.07.20 추가: 배송관리 목록 조회 (택배사/상태/키워드 필터)
    List<BizDeliveryVO> selectDeliveryList(@Param("bizNo") Long bizNo, @Param("carrier") String carrier,
                                            @Param("statusCd") String statusCd, @Param("keyword") String keyword);

    //지윤 26.07.20 추가: 일괄등록 시 주문번호로 ORDER_ID 조회 (본인 사업자 주문 아니면 null)
    Long selectOrderIdByOrderNo(@Param("orderNo") String orderNo, @Param("bizNo") Long bizNo);

    //지윤 26.07.20 추가: 리뷰관리 목록 (내 상품에 달린 리뷰 + 삭제요청 상태)
    List<BizReviewVO> selectBizReviewList(@Param("bizNo") Long bizNo);

    //지윤 26.07.20 추가: 답글 저장 (본인 상품 리뷰만 수정되게 상품 BIZ_NO까지 조건에 포함)
    int updateReviewBizReply(@Param("reviewId") Long reviewId, @Param("bizNo") Long bizNo, @Param("bizReply") String bizReply);

    //지윤 26.07.20 추가: 삭제요청 대상 리뷰가 본인 상품 리뷰인지 확인
    int selectReviewOwnedByBiz(@Param("reviewId") Long reviewId, @Param("bizNo") Long bizNo);

    //지윤 26.07.20 추가: 이미 대기중인 삭제요청이 있는지 확인 (중복 요청 방지)
    int selectPendingReportExists(@Param("reviewId") Long reviewId);

    //지윤 26.07.20 추가: 리뷰 삭제요청 등록 (TB_REVIEW_REPORT, REPORTER_TYPE='BIZ')
    void insertReviewDeleteRequest(@Param("reviewId") Long reviewId, @Param("bizNo") Long bizNo, @Param("reason") String reason);

    //지윤 26.07.21 추가: 사이드바 "주문관리" 뱃지용 - 결제완료(PAID) 상태 주문 개수
    int selectPaidOrderCount(@Param("bizNo") Long bizNo);

    //지윤 26.07.21 추가: Q&A관리 목록 (내 상품에 달린 질문 전체, 미답변 우선)
    java.util.List<com.petcare.petcare.biz.store.vo.BizQnaVO> selectBizQnaList(@Param("bizNo") Long bizNo);

    //지윤 26.07.21 추가: Q&A 답변 등록/수정 (본인 상품 질문만 수정되게 상품 BIZ_NO까지 조건에 포함)
    int updateQnaAnswer(@Param("qnaId") Long qnaId, @Param("bizNo") Long bizNo, @Param("answer") String answer);

    //지윤 26.07.23 추가: 사업자 정보 조회
    com.petcare.petcare.biz.store.vo.BizInfoVO selectBusinessInfo(@Param("bizNo") Long bizNo);

    //지윤 26.07.23 추가: 사업자 정보 수정
    void updateBusinessInfo(@Param("bizNo") Long bizNo, @Param("shopName") String shopName, @Param("ceoName") String ceoName,
                             @Param("bizRegNo") String bizRegNo, @Param("bizType") String bizType,
                             @Param("addr") String addr, @Param("addrDetail") String addrDetail,
                             @Param("phone") String phone);

    //2026/08/06 장우철 — 정산 계좌 조회/변경
    com.petcare.petcare.biz.store.vo.BizInfoVO selectSettleAccount(@Param("bizNo") Long bizNo);
    int updateSettleAccount(@Param("bizNo") Long bizNo,
                            @Param("settleBank") String settleBank,
                            @Param("settleBankCode") String settleBankCode,
                            @Param("settleAccount") String settleAccount,
                            @Param("settleHolder") String settleHolder);

    // 2026/08/04 장우철 — 상품단위 환불
    java.util.List<com.petcare.petcare.biz.store.vo.BizReturnVO> selectReturnList(
            @Param("bizNo") Long bizNo, @Param("statusCd") String statusCd);
    int selectReturnRequestedCount(@Param("bizNo") Long bizNo);
    com.petcare.petcare.biz.store.vo.BizReturnVO selectReturnDetail(
            @Param("orderItemId") Long orderItemId, @Param("bizNo") Long bizNo);
    java.util.List<String> selectReturnPhotoUrls(@Param("orderItemId") Long orderItemId);
    int approveReturn(@Param("orderItemId") Long orderItemId, @Param("bizNo") Long bizNo);
    int rejectReturn(@Param("orderItemId") Long orderItemId, @Param("bizNo") Long bizNo,
                     @Param("rejectReason") String rejectReason);
    int completeReturn(@Param("orderItemId") Long orderItemId, @Param("bizNo") Long bizNo,
                       @Param("refundAmount") Integer refundAmount);
    void addPaymentRefundAmt(@Param("orderId") Long orderId, @Param("refundAmount") Integer refundAmount);

    List<BizCouponVO> selectCouponListByBizNo(@Param("bizMemberNo") Long bizMemberNo);
    BizCouponVO selectCouponById(@Param("couponId") Long couponId);
    int insertCoupon(BizCouponVO vo);
    int updateCoupon(BizCouponVO vo);
    int deleteCoupon(
        @Param("couponId") Long couponId,
        @Param("bizMemberNo") Long bizMemberNo
);

// 지윤 26.08.06: 쇼핑몰 사업자 쿠폰 조기 마감
int closeCoupon(
        @Param("couponId") Long couponId,
        @Param("bizMemberNo") Long bizMemberNo
);
}














    