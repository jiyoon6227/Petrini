package com.petcare.petcare.admin.review.service;

import java.util.List;

import com.petcare.petcare.admin.review.vo.AdminReviewDeleteRequestVO;
import com.petcare.petcare.admin.review.vo.AdminReviewReportVO;

public interface AdminReviewService {

    // 삭제 요청 목록 (검색·필터·페이징, 각 행에 고객 신고 목록 포함)
    List<AdminReviewDeleteRequestVO> getReviewDeleteRequestList(
            String keyword, String statusCd, int page);

    // 목록 총 건수
    int getReviewDeleteRequestCount(String keyword, String statusCd);

    // PENDING 건수 (sidebar 배지용)
    int getPendingReviewDeleteCount();

    // 삭제 요청 승인 (리뷰 삭제)
    void approveReviewDeleteRequest(long requestId, long adminNo);

    // 삭제 요청 반려 (반려 사유 + 알림)
    void rejectReviewDeleteRequest(long requestId, String rejectReason, long adminNo);

    // 고객 신고 목록 (검색·필터·페이징)
    List<AdminReviewReportVO> getReviewReportList(String keyword, String statusCd, int page);

    // 고객 신고 총 건수
    int getReviewReportCount(String keyword, String statusCd);

    // 고객 신고 PENDING 건수 (탭 배지용)
    int getPendingReviewReportCount();

    // 고객 신고된 리뷰 삭제
    void deleteReviewByReport(long reportId, long adminNo);

    // 고객 신고 반려 (사유 필수)
    void rejectReviewReport(long reportId, String rejectReason, long adminNo);
}
