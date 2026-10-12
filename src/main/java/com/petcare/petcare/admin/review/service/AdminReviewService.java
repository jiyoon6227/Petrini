package com.petcare.petcare.admin.review.service;

import java.util.List;

import com.petcare.petcare.admin.review.vo.AdminReviewDeleteRequestVO;

public interface AdminReviewService {

    // 삭제 요청 목록 (검색·필터·페이징)
    List<AdminReviewDeleteRequestVO> getReviewDeleteRequestList(
            String keyword, String statusCd, int page);

    // 목록 총 건수
    int getReviewDeleteRequestCount(String keyword, String statusCd);

    // PENDING 건수 (sidebar 배지용)
    int getPendingReviewDeleteCount();

    // 삭제 요청 승인 (리뷰 삭제)
    // sourceCd: DELETE_REQ | REPORT
    void approveReviewDeleteRequest(long requestId, long adminNo, String sourceCd);

    // 삭제 요청 반려 (반려 사유 + 알림)
    void rejectReviewDeleteRequest(long requestId, String rejectReason, long adminNo, String sourceCd);
}
