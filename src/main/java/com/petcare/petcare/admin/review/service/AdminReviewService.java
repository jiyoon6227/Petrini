/**
 * 역할: 관리자 리뷰 삭제 요청 비즈니스 로직 (interface)
 *
 * - 박유정 / 2026-07-24
 *
 * 담당 화면
 * - admin/review/list.jsp  삭제 요청 목록
 *
 * 연결
 * - 구현: AdminReviewServiceImpl
 * - 호출: AdminReviewController
 * - DB: AdminReviewMapper
 */

package com.petcare.petcare.admin.review.service;

import java.util.List;

import com.petcare.petcare.admin.review.vo.AdminReviewDeleteRequestVO;

public interface AdminReviewService {

    // 2026-07-24 박유정 — 삭제 요청 목록 (검색·필터·페이징)
    List<AdminReviewDeleteRequestVO> getReviewDeleteRequestList(
            String keyword, String statusCd, int page);

    // 2026-07-24 박유정 — 목록 총 건수
    int getReviewDeleteRequestCount(String keyword, String statusCd);

    // 2026-07-24 박유정 — PENDING 건수 (sidebar 배지용)
    int getPendingReviewDeleteCount();

    // 2026-07-24 박유정 — 삭제 요청 승인 (리뷰 삭제)
    // 2026/08/11 장우철 — sourceCd: DELETE_REQ | REPORT
    void approveReviewDeleteRequest(long requestId, long adminNo, String sourceCd);

    // 2026-07-24 박유정 — 삭제 요청 반려 (반려 사유 + 알림)
    void rejectReviewDeleteRequest(long requestId, String rejectReason, long adminNo, String sourceCd);
}
