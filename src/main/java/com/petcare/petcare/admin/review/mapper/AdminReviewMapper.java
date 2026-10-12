package com.petcare.petcare.admin.review.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.admin.review.vo.AdminReviewDeleteRequestVO;

@Mapper
public interface AdminReviewMapper {

    // 삭제 요청 목록 (검색·필터·페이징)
    List<AdminReviewDeleteRequestVO> selectAdminReviewDeleteRequestList(
            @Param("keyword") String keyword,
            @Param("statusCd") String statusCd,
            @Param("offset") int offset,
            @Param("limit") int limit);

    // 목록 총 건수
    int selectAdminReviewDeleteRequestCount(
            @Param("keyword") String keyword,
            @Param("statusCd") String statusCd);

    // PENDING 건수 (sidebar 배지용)
    int countPendingReviewDeleteRequest();

    // 삭제 요청 단건 (승인/반려 시 검증)
    AdminReviewDeleteRequestVO selectAdminReviewDeleteRequestDetail(
            @Param("requestId") long requestId);

    // 쇼핑(TB_REVIEW_REPORT) 삭제요청 단건
    AdminReviewDeleteRequestVO selectAdminStoreReviewReportDetail(
            @Param("reportId") long reportId);

    // 승인 처리
    int updateReviewDeleteRequestApproved(
            @Param("requestId") long requestId,
            @Param("adminNo") long adminNo);

    // 반려 처리 (REJECT_REASON 저장)
    int updateReviewDeleteRequestRejected(
            @Param("requestId") long requestId,
            @Param("adminNo") long adminNo,
            @Param("rejectReason") String rejectReason);

    // 리뷰 삭제
    // reviewType(STAY/HOSPITAL)별 테이블 분기
    int deleteReviewById(@Param("reviewId") long reviewId,
                         @Param("reviewType") String reviewType);

    // 사업자 회원번호 (알림용)
    Long selectBizMemberNoByBizNo(@Param("bizNo") long bizNo);
}
