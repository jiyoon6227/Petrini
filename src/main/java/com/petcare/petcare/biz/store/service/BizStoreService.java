/**
 * 역할: 사업자 쇼핑몰(상품·주문·배송) 비즈니스 로직 (interface)
 *
 * 담당 화면
 * - biz/store/dashboard.jsp   대시보드
 * - biz/store/products.jsp    상품 관리
 * - biz/store/inventory.jsp   재고 관리
 * - biz/store/orders.jsp      주문 관리
 * - biz/store/delivery.jsp    배송 관리
 * - biz/store/reviews.jsp     리뷰 관리
 * - biz/store/settlement.jsp  정산
 * - biz/store/info.jsp        매장 정보
 *
 * 구현할 기능 예시
 * - 사업자 대시보드 요약 조회
 * - 상품·재고 등록·수정
 * - 주문·배송 상태 관리
 * - 리뷰 조회·답변
 * - 정산 내역 조회
 *
 * 연결
 * - 구현: BizStoreServiceImpl
 * - 호출: BizStoreController
 * - DB: BizStoreMapper
 *
 * 참고 테이블
 * - TB_PRODUCT
 * - TB_ORDER
 * - TB_ORDER_ITEM
 * - TB_REVIEW
 */

package com.petcare.petcare.biz.store.service;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import com.petcare.petcare.biz.store.vo.BizDeliveryVO;
import com.petcare.petcare.biz.store.vo.BizOrderVO;
import com.petcare.petcare.biz.store.vo.BizProductVO;
import com.petcare.petcare.store.vo.CategoryVO;
import com.petcare.petcare.store.vo.OptionVO;

public interface BizStoreService {

    //지윤 26.07.14 로그인 ID로 BIZ_NO 조회
    Long getBizNo(String bizId);

    //지윤 26.07.15 사업자 상품목록 조회 (할인율 계산 + 옵션별 재고 포함)
    //2026/08/06 장우철: categoryId → categoryName
    List<BizProductVO> getProductList(Long bizNo, String keyword, String categoryName, String statusCd, int pageNo);

    //지윤 26.07.14 상품목록 총 페이지 수 (페이지네이션용)
    int getTotalPages(Long bizNo, String keyword, String categoryName, String statusCd);

    //지윤 26.07.14 상품 등록 (이미지 여러 장 같이 등록)
    void addProduct(BizProductVO product, List<OptionVO> options, MultipartFile image) throws Exception;

    //지윤 26.07.14 상품 상세 조회 (수정 모달 초기값 채우기용)
    BizProductVO getProductDetail(Long productId, Long bizNo);

    //지윤 26.07.14 상품 수정 (상태값 강제 변경 포함). 본인 상품 아니면 false 반환
    boolean updateProduct(BizProductVO product, List<OptionVO> options, MultipartFile image) throws Exception;

    //지윤 26.07.14 등록/수정 폼 카테고리 드롭다운 목록
    List<CategoryVO> getLeafCategories();

    //2026/08/06 장우철: 상품목록 필터용 카테고리명(중복 제거)
    List<String> getFilterCategoryNames();

    //지윤 26.07.15 상품목록 "총 N개" 표시용 전체 개수 조회
    int getTotalCount(Long bizNo, String keyword, String categoryName, String statusCd);

    //지윤 26.07.20 추가: 사업자 주문 목록 조회 (상태 필터)
    List<BizOrderVO> getOrderList(Long bizNo, String statusCd);

    //지윤 26.07.20 추가: 상태별 주문 개수 (탭에 숫자 표시용, key=상태코드, value=개수)
    java.util.Map<String, Integer> getOrderStatusCounts(Long bizNo);

    //지윤 26.07.20 추가: 주문 상세 조회 (상품목록까지 같이 채워서 반환)
    BizOrderVO getOrderDetail(Long orderId, Long bizNo);

    //지윤 26.07.22 추가: 취소신청 승인 (토스취소+재고/포인트/쿠폰 복구). null=성공, 실패면 에러메시지
    String approveOrderCancel(Long orderId, Long bizNo);

    //지윤 26.07.22 추가: 취소신청 반려
    boolean rejectOrderCancel(Long orderId, Long bizNo);

    //지윤 26.07.20 추가: 주문 상태 + 배송정보(택배사/송장번호) 한번에 저장. 본인 주문 아니면 false
    //지윤 26.07.24 수정: courierCode 파라미터 추가 (택배사 API 연동용, null 허용 - orders.jsp는 아직 안 보냄)
    boolean updateOrderStatus(Long orderId, Long bizNo, String orderStatus, String courierName, String courierCode, String trackingNo);

    //지윤 26.07.27 추가: 배송조회(스마트택배 API) 결과 level==6(배송완료) 확인 시 자동으로 주문상태 DONE 처리
    //이미 DONE이면 false 반환 (중복 처리 방지)
    boolean autoCompleteDeliveryIfDone(Long orderId, Long bizNo);

    //지윤 26.07.28 추가: 배송조회 시 level 2~5(이동중) 확인되면 PAID/READY인 주문을 SHIPPING으로 자동승격
    //이미 SHIPPING 이상이면 false 반환 (중복/역행 방지)
    boolean autoElevateToShippingIfNeeded(Long orderId, Long bizNo);

    //지윤 26.07.20 추가: 배송관리 목록 조회 (필터 적용됨, 지연여부 계산 포함)
    List<BizDeliveryVO> getDeliveryList(Long bizNo, String carrier, String statusCd, String keyword);

    //지윤 26.07.20 추가: 상단 요약카드용 - 전체(필터 미적용) 기준 상태별 개수 + 지연건수
    java.util.Map<String, Integer> getDeliverySummary(Long bizNo);

    //지윤 26.07.20 추가: 송장 일괄등록 (한 줄당 "주문번호,택배사코드,송장번호"). 성공건수/실패라인 반환
    java.util.Map<String, Object> bulkRegisterDelivery(Long bizNo, String bulkText);

    //지윤 26.07.20 추가: 리뷰관리 목록 조회 (내 상품 리뷰 + 삭제요청 상태 포함)
    List<com.petcare.petcare.biz.store.vo.BizReviewVO> getBizReviewList(Long bizNo);

    //지윤 26.07.20 추가: 답글 작성/수정. 본인 상품 리뷰 아니면 false
    boolean saveReviewBizReply(Long bizNo, Long reviewId, String bizReply);

    //지윤 26.07.20 추가: 리뷰 삭제요청 (관리자 승인 대기 등록). 본인 리뷰 아니거나 이미 요청중이면 실패 사유 반환
    void requestReviewDelete(Long bizNo, Long reviewId, String reason);

    //지윤 26.07.21 추가: 사이드바 "주문관리" 뱃지용 - 결제완료(PAID) 상태 주문 개수
    int getPaidOrderCount(Long bizNo);

    //지윤 26.07.23 추가: 오늘 신규 주문 건수 (홈 대시보드용)
    int getTodayNewOrderCount(Long bizNo);
    
    //지윤 26.07.21 추가: Q&A관리 목록 조회
    java.util.List<com.petcare.petcare.biz.store.vo.BizQnaVO> getBizQnaList(Long bizNo);

    //지윤 26.07.21 추가: Q&A 답변 등록/수정. 본인 상품 질문 아니면 false
    boolean saveQnaAnswer(Long bizNo, Long qnaId, String answer);

    //지윤 26.07.23 추가: 사업자 정보 조회
    com.petcare.petcare.biz.store.vo.BizInfoVO getBusinessInfo(Long bizNo);

    //지윤 26.07.23 추가: 사업자 정보 수정 (등록증 새로 올리면 기존 것 교체)
    void updateBusinessInfo(Long bizNo, com.petcare.petcare.biz.store.vo.BizInfoVO info, org.springframework.web.multipart.MultipartFile certFile) throws Exception;

    //2026/08/06 장우철 — 정산 계좌 조회/변경
    com.petcare.petcare.biz.store.vo.BizInfoVO getSettleAccount(Long bizNo);
    boolean updateSettleAccount(Long bizNo, String settleBank, String settleBankCode,
                                String settleAccount, String settleHolder);

    // 2026/08/04 장우철 — 상품단위 환불
    java.util.List<com.petcare.petcare.biz.store.vo.BizReturnVO> getReturnList(Long bizNo, String statusCd);
    int getReturnRequestedCount(Long bizNo);
    com.petcare.petcare.biz.store.vo.BizReturnVO getReturnDetail(Long orderItemId, Long bizNo);
    /** null=성공, 아니면 에러메시지 */
    String approveReturn(Long orderItemId, Long bizNo);
    String rejectReturn(Long orderItemId, Long bizNo, String rejectReason);
    String completeReturn(Long orderItemId, Long bizNo);

    List<com.petcare.petcare.biz.vo.BizCouponVO> getCouponList(Long bizNo);
    void applyCoupon(Long bizNo, com.petcare.petcare.biz.vo.BizCouponVO vo);
    void updateCoupon(Long bizNo, com.petcare.petcare.biz.vo.BizCouponVO vo);
    void deleteCoupon(Long bizNo, Long couponId);

// 지윤 26.08.06: 쇼핑몰 사업자 쿠폰 조기 마감
void closeCoupon(Long bizNo, Long couponId);
}