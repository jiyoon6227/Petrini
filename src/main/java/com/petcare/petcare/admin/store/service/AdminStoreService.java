package com.petcare.petcare.admin.store.service;

import java.util.List;

import com.petcare.petcare.admin.store.vo.AdminReviewReportVO;
import com.petcare.petcare.admin.store.vo.AdminStoreOrderVO;
import com.petcare.petcare.admin.store.vo.AdminStoreProductVO;

public interface AdminStoreService {

    // 대기중인 리뷰 삭제요청 목록
    List<AdminReviewReportVO> getPendingReviewReports();

    // 승인 - 리뷰 실제 삭제 + 요청 DONE 처리
    void approveReviewReport(Long reportId, Long reviewId, Long adminNo);

    // 반려: 리뷰는 유지하고 요청만 DONE 처리 (블라인드 자동 해제)
    void rejectReviewReport(Long reportId, Long adminNo);

    // 전 사업자 상품/주문 목록
    List<AdminStoreProductVO> getProductList(String keyword, String statusCd, int page, int size);

    int getProductCount(String keyword, String statusCd);

    List<AdminStoreOrderVO> getOrderList(String keyword, String statusCd, int page, int size);

    int getOrderCount(String keyword, String statusCd);

    AdminStoreOrderVO getOrderDetail(Long orderId);
}
