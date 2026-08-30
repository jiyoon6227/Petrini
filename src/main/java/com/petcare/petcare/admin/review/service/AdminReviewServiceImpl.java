/**
 * 역할: AdminReviewService 구현체 (@Service)
 *
 * - 박유정 / 2026-07-24
 * - 2026/08/11 장우철 — 쇼핑(TB_REVIEW_REPORT) 삭제요청 통합 처리
 */

package com.petcare.petcare.admin.review.service;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.admin.review.mapper.AdminReviewMapper;
import com.petcare.petcare.admin.review.vo.AdminReviewDeleteRequestVO;
import com.petcare.petcare.admin.store.service.AdminStoreService;

@Service
public class AdminReviewServiceImpl implements AdminReviewService {

    private static final Logger log = LoggerFactory.getLogger(AdminReviewServiceImpl.class);

    private final AdminReviewMapper adminReviewMapper;
    private final AdminReviewApproveTxService approveTxService;
    private final AdminReviewSideEffectService sideEffectService;
    private final AdminStoreService adminStoreService;
    private static final int PAGE_SIZE = 10;

    public AdminReviewServiceImpl(AdminReviewMapper adminReviewMapper,
                                  AdminReviewApproveTxService approveTxService,
                                  AdminReviewSideEffectService sideEffectService,
                                  AdminStoreService adminStoreService) {
        this.adminReviewMapper = adminReviewMapper;
        this.approveTxService = approveTxService;
        this.sideEffectService = sideEffectService;
        this.adminStoreService = adminStoreService;
    }

    @Override
    public List<AdminReviewDeleteRequestVO> getReviewDeleteRequestList(
            String keyword, String statusCd, int page) {
        int safePage = page < 1 ? 1 : page;
        int offset = (safePage - 1) * PAGE_SIZE;
        return adminReviewMapper.selectAdminReviewDeleteRequestList(
                keyword, statusCd, offset, PAGE_SIZE);
    }

    @Override
    public int getReviewDeleteRequestCount(String keyword, String statusCd) {
        return adminReviewMapper.selectAdminReviewDeleteRequestCount(keyword, statusCd);
    }

    @Override
    public int getPendingReviewDeleteCount() {
        return adminReviewMapper.countPendingReviewDeleteRequest();
    }

    @Override
    public void approveReviewDeleteRequest(long requestId, long adminNo, String sourceCd) {
        log.info("리뷰 삭제 승인 시작 requestId={}, adminNo={}, sourceCd={}", requestId, adminNo, sourceCd);
        if (isStoreReport(sourceCd)) {
            AdminReviewDeleteRequestVO req =
                    adminReviewMapper.selectAdminStoreReviewReportDetail(requestId);
            if (req == null) {
                throw new IllegalArgumentException("REQUEST_NOT_FOUND");
            }
            if (!"PENDING".equals(req.getStatusCd())) {
                throw new IllegalStateException("REQUEST_NOT_PENDING");
            }
            if (req.getReviewId() == null) {
                throw new IllegalStateException("REVIEW_NOT_FOUND");
            }
            adminStoreService.approveReviewReport(requestId, req.getReviewId(), adminNo);
            sideEffectService.afterApprove(req);
        } else {
            AdminReviewDeleteRequestVO req = approveTxService.approve(requestId, adminNo);
            sideEffectService.afterApprove(req);
        }
        log.info("리뷰 삭제 승인 완료 requestId={}", requestId);
    }

    @Override
    @Transactional(timeout = 15)
    public void rejectReviewDeleteRequest(long requestId, String rejectReason, long adminNo, String sourceCd) {
        if (rejectReason == null || rejectReason.isBlank()) {
            throw new IllegalArgumentException("REJECT_REASON_REQUIRED");
        }
        String reason = rejectReason.trim();

        if (isStoreReport(sourceCd)) {
            AdminReviewDeleteRequestVO req =
                    adminReviewMapper.selectAdminStoreReviewReportDetail(requestId);
            if (req == null) {
                throw new IllegalArgumentException("REQUEST_NOT_FOUND");
            }
            if (!"PENDING".equals(req.getStatusCd())) {
                throw new IllegalStateException("REQUEST_NOT_PENDING");
            }
            adminStoreService.rejectReviewReport(requestId, adminNo);
            sideEffectService.afterReject(req, reason);
            return;
        }

        AdminReviewDeleteRequestVO req =
                adminReviewMapper.selectAdminReviewDeleteRequestDetail(requestId);
        if (req == null) {
            throw new IllegalArgumentException("REQUEST_NOT_FOUND");
        }
        if (!"PENDING".equals(req.getStatusCd())) {
            throw new IllegalStateException("REQUEST_NOT_PENDING");
        }

        int updated = adminReviewMapper.updateReviewDeleteRequestRejected(
                requestId, adminNo, reason);
        if (updated == 0) {
            throw new IllegalStateException("REQUEST_NOT_PENDING");
        }
        sideEffectService.afterReject(req, reason);
    }

    private boolean isStoreReport(String sourceCd) {
        return "REPORT".equalsIgnoreCase(sourceCd != null ? sourceCd.trim() : "");
    }
}
