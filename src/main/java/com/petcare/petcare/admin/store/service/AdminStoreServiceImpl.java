/**
 * 역할: AdminStoreService 구현체 (@Service)
 *
 * 연결
 * - implements: AdminStoreService
 * - 사용: AdminStoreMapper
 */

package com.petcare.petcare.admin.store.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.admin.store.mapper.AdminStoreMapper;
import com.petcare.petcare.admin.store.vo.AdminReviewReportVO;
import com.petcare.petcare.admin.store.vo.AdminStoreOrderVO;
import com.petcare.petcare.admin.store.vo.AdminStoreProductVO;

@Service
public class AdminStoreServiceImpl implements AdminStoreService {

    @Autowired
    private AdminStoreMapper adminStoreMapper;

    // 대기중인 리뷰 삭제요청 목록
    @Override
    public List<AdminReviewReportVO> getPendingReviewReports() {
        return adminStoreMapper.selectPendingReviewReports();
    }

    // FK 참조 때문에 신고 참조를 먼저 끊고 리뷰 삭제 (ORA-02292 방지)
    @Override
    @Transactional
    public void approveReviewReport(Long reportId, Long reviewId, Long adminNo) {
        adminStoreMapper.updateReportApproved(reportId, adminNo);
        // 같은 리뷰에 다른 신고(예: 유저신고 여러 건)가 더 걸려있어도 그것들의 REVIEW_ID도 마저 비워야
        //TB_REVIEW 삭제할 때 ORA-02292(자식 레코드 발견) 안 남
        adminStoreMapper.clearAllReportRefsByReviewId(reviewId);
        adminStoreMapper.deleteReview(reviewId);
    }

    // 반려 - 리뷰는 그대로 두고 요청만 DONE 처리
    @Override
    public void rejectReviewReport(Long reportId, Long adminNo) {
        adminStoreMapper.updateReportDone(reportId, adminNo);
    }

    // 전 사업자 상품 목록
    @Override
    @Transactional(readOnly = true)
    public List<AdminStoreProductVO> getProductList(String keyword, String statusCd, int page, int size) {
        int safePage = page < 1 ? 1 : page;
        int safeSize = size < 1 ? 20 : size;
        int offset = (safePage - 1) * safeSize;
        return adminStoreMapper.selectAdminProductList(blankToNull(keyword), blankToNull(statusCd), offset, safeSize);
    }

    @Override
    @Transactional(readOnly = true)
    public int getProductCount(String keyword, String statusCd) {
        return adminStoreMapper.selectAdminProductCount(blankToNull(keyword), blankToNull(statusCd));
    }

    @Override
    @Transactional(readOnly = true)
    public List<AdminStoreOrderVO> getOrderList(String keyword, String statusCd, int page, int size) {
        int safePage = page < 1 ? 1 : page;
        int safeSize = size < 1 ? 20 : size;
        int offset = (safePage - 1) * safeSize;
        return adminStoreMapper.selectAdminOrderList(blankToNull(keyword), blankToNull(statusCd), offset, safeSize);
    }

    @Override
    @Transactional(readOnly = true)
    public int getOrderCount(String keyword, String statusCd) {
        return adminStoreMapper.selectAdminOrderCount(blankToNull(keyword), blankToNull(statusCd));
    }

    @Override
    @Transactional(readOnly = true)
    public AdminStoreOrderVO getOrderDetail(Long orderId) {
        if (orderId == null) {
            return null;
        }
        return adminStoreMapper.selectAdminOrderDetail(orderId);
    }

    private String blankToNull(String s) {
        return (s == null || s.isBlank()) ? null : s.trim();
    }
}
