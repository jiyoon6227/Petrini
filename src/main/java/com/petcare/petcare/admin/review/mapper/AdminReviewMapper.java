/**
 * 역할: 관리자 리뷰 삭제 요청 DB 접근 (MyBatis interface)
 *
 * - 박유정 / 2026-07-24
 *
 * XML: resources/mybatis/mapper/admin/review/AdminReviewMapper.xml
 * namespace: com.petcare.petcare.admin.review.mapper.AdminReviewMapper
 *
 * 참고 테이블
 * - TB_REVIEW_DELETE_REQUEST
 * - TB_REVIEW, TB_HOSPITAL, TB_BUSINESS, TB_MEMBER (JOIN)
 *
 * SQL은 XML에만 작성 (@Select 등 어노테이션 사용 X)
 */

package com.petcare.petcare.admin.review.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.admin.review.vo.AdminReviewDeleteRequestVO;

@Mapper
public interface AdminReviewMapper {

    // 2026-07-24 박유정 — 삭제 요청 목록 (검색·필터·페이징)
    List<AdminReviewDeleteRequestVO> selectAdminReviewDeleteRequestList(
            @Param("keyword") String keyword,
            @Param("statusCd") String statusCd,
            @Param("offset") int offset,
            @Param("limit") int limit);

    // 2026-07-24 박유정 — 목록 총 건수
    int selectAdminReviewDeleteRequestCount(
            @Param("keyword") String keyword,
            @Param("statusCd") String statusCd);

    // 2026-07-24 박유정 — PENDING 건수 (sidebar 배지용)
    int countPendingReviewDeleteRequest();

    // 2026-07-24 박유정 — 삭제 요청 단건 (승인/반려 시 검증)
    AdminReviewDeleteRequestVO selectAdminReviewDeleteRequestDetail(
            @Param("requestId") long requestId);

    // 2026/08/11 장우철 — 쇼핑(TB_REVIEW_REPORT) 삭제요청 단건
    AdminReviewDeleteRequestVO selectAdminStoreReviewReportDetail(
            @Param("reportId") long reportId);

    // 2026-07-24 박유정 — 승인 처리
    int updateReviewDeleteRequestApproved(
            @Param("requestId") long requestId,
            @Param("adminNo") long adminNo);

    // 2026-07-24 박유정 — 반려 처리 (REJECT_REASON 저장)
    int updateReviewDeleteRequestRejected(
            @Param("requestId") long requestId,
            @Param("adminNo") long adminNo,
            @Param("rejectReason") String rejectReason);

    // 2026-07-24 박유정 — 리뷰 삭제
    // 2026-07-27 박유정 — reviewType(STAY/HOSPITAL)별 테이블 분기
    int deleteReviewById(@Param("reviewId") long reviewId,
                         @Param("reviewType") String reviewType);

    // 2026-07-24 박유정 — 사업자 회원번호 (알림용)
    Long selectBizMemberNoByBizNo(@Param("bizNo") long bizNo);
}
