package com.petcare.petcare.common.review.service;

import org.springframework.stereotype.Service;

import com.petcare.petcare.common.review.mapper.ReviewCleanupMapper;

/**
 * 리뷰 삭제 직전 정리 (TB_REVIEW DELETE와 같은 트랜잭션 안에서 호출)
 * - 고객 신고: FK(REVIEW_ID) 해제 + PENDING 건 상태 마감
 * - 사업자 삭제요청: PENDING 건 상태 마감
 */
@Service
public class ReviewCleanupService {

    private final ReviewCleanupMapper reviewCleanupMapper;

    public ReviewCleanupService(ReviewCleanupMapper reviewCleanupMapper) {
        this.reviewCleanupMapper = reviewCleanupMapper;
    }

    // 관리자가 리뷰를 삭제할 때 (삭제요청 승인, 고객 신고 탭 삭제)
    public void beforeAdminDelete(Long reviewId, Long adminNo) {
        reviewCleanupMapper.closeReportsByReviewId(reviewId, "DELETED", adminNo);
        reviewCleanupMapper.closePendingDeleteRequestsByReviewId(reviewId, "APPROVED", adminNo);
    }

    // 작성자가 본인 리뷰를 삭제할 때
    public void beforeWriterDelete(Long reviewId) {
        reviewCleanupMapper.closeReportsByReviewId(reviewId, "CLOSED", null);
        reviewCleanupMapper.closePendingDeleteRequestsByReviewId(reviewId, "CANCELED", null);
    }
}
