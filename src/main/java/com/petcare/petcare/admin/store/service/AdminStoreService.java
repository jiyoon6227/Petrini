/**
 * 역할: 관리자 쇼핑몰(상품·주문) 관리 비즈니스 로직 (interface)
 *
 * 담당 화면
 * - admin/store/product-list.jsp 상품 목록
 * - admin/store/product-form.jsp 상품 등록·수정
 * - admin/store/order-list.jsp 주문 목록
 * - admin/store/order-detail.jsp 주문 상세
 * - admin/store/category.jsp  카테고리 관리
 *
 * 구현할 기능 예시
 * - 상품 목록·등록·수정·삭제
 * - 주문 목록·상세 조회
 * - 주문 상태 변경
 * - 카테고리 관리
 *
 * 연결
 * - 구현: AdminStoreServiceImpl
 * - 호출: AdminStoreController
 * - DB: AdminStoreMapper
 *
 * 참고 테이블
 * - TB_PRODUCT
 * - TB_ORDER
 * - TB_ORDER_ITEM
 * - TB_CATEGORY
 */

package com.petcare.petcare.admin.store.service;

import java.util.List;

import com.petcare.petcare.admin.store.vo.AdminReviewReportVO;
import com.petcare.petcare.admin.store.vo.AdminStoreOrderVO;
import com.petcare.petcare.admin.store.vo.AdminStoreProductVO;

public interface AdminStoreService {

    //지윤 26.07.21 추가: 대기중인 리뷰 삭제요청 목록
    List<AdminReviewReportVO> getPendingReviewReports();

    //지윤 26.07.21 추가: 승인 - 리뷰 실제 삭제 + 요청 DONE 처리
    void approveReviewReport(Long reportId, Long reviewId, Long adminNo);

    //지윤 26.07.21 추가: 반려 - 리뷰는 그대로 두고 요청만 DONE 처리 (블라인드 자동 해제됨)
    void rejectReviewReport(Long reportId, Long adminNo);

    // 2026/08/11 장우철 — 전 사업자 상품/주문 목록
    List<AdminStoreProductVO> getProductList(String keyword, String statusCd, int page, int size);

    int getProductCount(String keyword, String statusCd);

    List<AdminStoreOrderVO> getOrderList(String keyword, String statusCd, int page, int size);

    int getOrderCount(String keyword, String statusCd);

    AdminStoreOrderVO getOrderDetail(Long orderId);
}
