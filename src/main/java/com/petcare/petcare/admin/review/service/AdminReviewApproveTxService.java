package com.petcare.petcare.admin.review.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.admin.review.mapper.AdminReviewMapper;
import com.petcare.petcare.admin.review.vo.AdminReviewDeleteRequestVO;

/**
 * 2026-07-28 박유정 — 관리자 리뷰 삭제 승인 핵심 처리 (짧은 트랜잭션)
 */
@Service
public class AdminReviewApproveTxService {

    private final AdminReviewMapper adminReviewMapper;

    public AdminReviewApproveTxService(AdminReviewMapper adminReviewMapper) {
        this.adminReviewMapper = adminReviewMapper;
    }

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

        int deleted = adminReviewMapper.deleteReviewById(req.getReviewId(), req.getReviewType());
        if (deleted == 0) {
            throw new IllegalStateException("REVIEW_NOT_FOUND");
        }

        int updated = adminReviewMapper.updateReviewDeleteRequestApproved(requestId, adminNo);
        if (updated == 0) {
            throw new IllegalStateException("REQUEST_NOT_PENDING");
        }
        return req;
    }
}
