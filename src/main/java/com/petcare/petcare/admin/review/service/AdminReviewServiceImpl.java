package com.petcare.petcare.admin.review.service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.admin.review.mapper.AdminReviewMapper;
import com.petcare.petcare.admin.review.vo.AdminReviewDeleteRequestVO;
import com.petcare.petcare.admin.review.vo.AdminReviewReportVO;

@Service
public class AdminReviewServiceImpl implements AdminReviewService {

    private static final Logger log = LoggerFactory.getLogger(AdminReviewServiceImpl.class);

    private final AdminReviewMapper adminReviewMapper;
    private final AdminReviewApproveTxService approveTxService;
    private final AdminReviewSideEffectService sideEffectService;
    private static final int PAGE_SIZE = 10;

    public AdminReviewServiceImpl(AdminReviewMapper adminReviewMapper,
                                  AdminReviewApproveTxService approveTxService,
                                  AdminReviewSideEffectService sideEffectService) {
        this.adminReviewMapper = adminReviewMapper;
        this.approveTxService = approveTxService;
        this.sideEffectService = sideEffectService;
    }

    @Override
    public List<AdminReviewDeleteRequestVO> getReviewDeleteRequestList(
            String keyword, String statusCd, int page) {
        List<AdminReviewDeleteRequestVO> list = adminReviewMapper.selectAdminReviewDeleteRequestList(
                keyword, statusCd, offsetOf(page), PAGE_SIZE);
        attachReports(list);
        return list;
    }

    // 신고가 걸린 리뷰만 모아서 한 번에 조회한 뒤 행마다 붙임
    private void attachReports(List<AdminReviewDeleteRequestVO> list) {
        List<Long> reviewIds = new ArrayList<>();
        for (AdminReviewDeleteRequestVO vo : list) {
            if (vo.getReportCount() != null && vo.getReportCount() > 0 && !reviewIds.contains(vo.getReviewId())) {
                reviewIds.add(vo.getReviewId());
            }
        }
        if (reviewIds.isEmpty()) {
            return;
        }
        Map<Long, List<AdminReviewReportVO>> byReview = adminReviewMapper
                .selectReviewReportsByReviewIds(reviewIds).stream()
                .collect(Collectors.groupingBy(AdminReviewReportVO::getReviewId));
        for (AdminReviewDeleteRequestVO vo : list) {
            List<AdminReviewReportVO> reports = byReview.get(vo.getReviewId());
            if (reports != null) {
                vo.setReports(reports);
            }
        }
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
    public void approveReviewDeleteRequest(long requestId, long adminNo) {
        log.info("리뷰 삭제 승인 시작 requestId={}, adminNo={}", requestId, adminNo);
        AdminReviewDeleteRequestVO req = approveTxService.approve(requestId, adminNo);
        sideEffectService.afterApprove(req);
        log.info("리뷰 삭제 승인 완료 requestId={}", requestId);
    }

    @Override
    @Transactional(timeout = 15)
    public void rejectReviewDeleteRequest(long requestId, String rejectReason, long adminNo) {
        String reason = requireReason(rejectReason);

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

    @Override
    public List<AdminReviewReportVO> getReviewReportList(String keyword, String statusCd, int page) {
        return adminReviewMapper.selectAdminReviewReportList(keyword, statusCd, offsetOf(page), PAGE_SIZE);
    }

    @Override
    public int getReviewReportCount(String keyword, String statusCd) {
        return adminReviewMapper.selectAdminReviewReportCount(keyword, statusCd);
    }

    @Override
    public int getPendingReviewReportCount() {
        return adminReviewMapper.countPendingReviewReport();
    }

    @Override
    public void deleteReviewByReport(long reportId, long adminNo) {
        log.info("고객 신고 리뷰 삭제 시작 reportId={}, adminNo={}", reportId, adminNo);
        AdminReviewReportVO report = requirePendingReport(reportId);
        if (report.getReviewId() == null) {
            throw new IllegalStateException("REVIEW_NOT_FOUND");
        }
        List<AdminReviewDeleteRequestVO> approvedRequests = approveTxService.deleteByReport(report, adminNo);

        // 같은 리뷰에 걸려 있던 삭제요청은 승인 처리됐으니 사업자에게 승인 알림
        for (AdminReviewDeleteRequestVO req : approvedRequests) {
            sideEffectService.notifyApprove(req);
        }
        sideEffectService.refreshRating(report.getReviewType(), report.getTargetId());
        log.info("고객 신고 리뷰 삭제 완료 reportId={}", reportId);
    }

    @Override
    @Transactional(timeout = 15)
    public void rejectReviewReport(long reportId, String rejectReason, long adminNo) {
        String reason = requireReason(rejectReason);
        requirePendingReport(reportId);
        int updated = adminReviewMapper.updateReviewReportRejected(reportId, adminNo, reason);
        if (updated == 0) {
            throw new IllegalStateException("REPORT_NOT_PENDING");
        }
    }

    private AdminReviewReportVO requirePendingReport(long reportId) {
        AdminReviewReportVO report = adminReviewMapper.selectAdminReviewReportDetail(reportId);
        if (report == null) {
            throw new IllegalArgumentException("REPORT_NOT_FOUND");
        }
        if (!"PENDING".equals(report.getStatusCd())) {
            throw new IllegalStateException("REPORT_NOT_PENDING");
        }
        return report;
    }

    private String requireReason(String rejectReason) {
        if (rejectReason == null || rejectReason.isBlank()) {
            throw new IllegalArgumentException("REJECT_REASON_REQUIRED");
        }
        return rejectReason.trim();
    }

    private int offsetOf(int page) {
        int safePage = page < 1 ? 1 : page;
        return (safePage - 1) * PAGE_SIZE;
    }
}
