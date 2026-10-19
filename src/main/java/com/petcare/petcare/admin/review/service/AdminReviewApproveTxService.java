package com.petcare.petcare.admin.review.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.admin.review.mapper.AdminReviewMapper;
import com.petcare.petcare.admin.review.vo.AdminReviewDeleteRequestVO;
import com.petcare.petcare.admin.review.vo.AdminReviewReportVO;
import com.petcare.petcare.common.review.service.ReviewCleanupService;

/**
 * 관리자 리뷰 삭제 핵심 처리 (짧은 트랜잭션)
 * 삭제요청 승인과 고객 신고 탭 삭제가 같은 순서로 리뷰를 지움:
 * 남은 신고·삭제요청 정리 → TB_REVIEW 삭제
 */
@Service
public class AdminReviewApproveTxService {

    private final AdminReviewMapper adminReviewMapper;
    private final ReviewCleanupService reviewCleanupService;

    public AdminReviewApproveTxService(AdminReviewMapper adminReviewMapper,
                                       ReviewCleanupService reviewCleanupService) {
        this.adminReviewMapper = adminReviewMapper;
        this.reviewCleanupService = reviewCleanupService;
    }

    // 사업자 삭제요청 승인
    @Transactional(timeout = 15)
    public AdminReviewDeleteRequestVO approve(long requestId, long adminNo) {
        AdminReviewDeleteRequestVO req =
                adminReviewMapper.selectAdminReviewDeleteRequestDetail(requestId);
        if (req == null) {
            throw new IllegalArgumentException("REQUEST_NOT_FOUND");
        }
        if (!"PENDING".equals(req.getStatusCd())) {
            throw new IllegalStateException("REQUEST_NOT_PENDING");
        }

        int updated = adminReviewMapper.updateReviewDeleteRequestApproved(requestId, adminNo);
        if (updated == 0) {
            throw new IllegalStateException("REQUEST_NOT_PENDING");
        }
        deleteReview(req.getReviewId(), req.getReviewType(), adminNo);
        return req;
    }

    // 고객 신고 탭에서 리뷰 삭제. 같은 리뷰의 대기 중 삭제요청은 승인 처리되므로 알림용으로 반환
    @Transactional(timeout = 15)
    public List<AdminReviewDeleteRequestVO> deleteByReport(AdminReviewReportVO report, long adminNo) {
        // 화면을 연 뒤 다른 관리자가 먼저 처리했을 수 있어서 트랜잭션 안에서 다시 확인
        AdminReviewReportVO current = adminReviewMapper.selectAdminReviewReportDetail(report.getReportId());
        if (current == null || !"PENDING".equals(current.getStatusCd()) || current.getReviewId() == null) {
            throw new IllegalStateException("REPORT_NOT_PENDING");
        }
        List<AdminReviewDeleteRequestVO> pendingRequests =
                adminReviewMapper.selectPendingDeleteRequestsByReviewId(report.getReviewId());
        deleteReview(report.getReviewId(), report.getReviewType(), adminNo);
        return pendingRequests;
    }

    private void deleteReview(Long reviewId, String reviewType, long adminNo) {
        reviewCleanupService.beforeAdminDelete(reviewId, adminNo);
        int deleted = adminReviewMapper.deleteReviewById(reviewId, reviewType);
        if (deleted == 0) {
            throw new IllegalStateException("REVIEW_NOT_FOUND");
        }
    }
}
