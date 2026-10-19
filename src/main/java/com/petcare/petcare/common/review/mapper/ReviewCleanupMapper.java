package com.petcare.petcare.common.review.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ReviewCleanupMapper {

    // 리뷰에 걸린 고객 신고 정리: PENDING은 pendingStatus로 바꾸고, 전부 REVIEW_ID를 비움 (FK 해제)
    int closeReportsByReviewId(@Param("reviewId") Long reviewId,
                               @Param("pendingStatus") String pendingStatus,
                               @Param("adminNo") Long adminNo);

    // 리뷰에 걸린 PENDING 삭제요청을 newStatus로 변경 (APPROVED / CANCELED)
    int closePendingDeleteRequestsByReviewId(@Param("reviewId") Long reviewId,
                                             @Param("newStatus") String newStatus,
                                             @Param("adminNo") Long adminNo);
}
