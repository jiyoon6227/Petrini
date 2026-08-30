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

//지윤 26.07.21 수정: @Service 어노테이션이 원래 빠져있어서 스프링 빈으로 등록조차 안 되던 상태였음 - 추가함
@Service
public class AdminStoreServiceImpl implements AdminStoreService {

    @Autowired
    private AdminStoreMapper adminStoreMapper;

    //지윤 26.07.21 추가: 대기중인 리뷰 삭제요청 목록
    @Override
    public List<AdminReviewReportVO> getPendingReviewReports() {
        return adminStoreMapper.selectPendingReviewReports();
    }

    //지윤 26.07.21 수정: FK(TB_REVIEW_REPORT.REVIEW_ID) 참조 때문에 리뷰를 먼저 지우면 ORA-02292 남
    //-> 순서 반드시 "참조 끊기(updateReportApproved) -> 리뷰 삭제(deleteReview)"
    @Override
    @Transactional
    public void approveReviewReport(Long reportId, Long reviewId, Long adminNo) {
        adminStoreMapper.updateReportApproved(reportId, adminNo);
        //지윤 26.07.22 추가: 같은 리뷰에 다른 신고(예: 유저신고 여러 건)가 더 걸려있어도 그것들의 REVIEW_ID도 마저 비워야
        //TB_REVIEW 삭제할 때 ORA-02292(자식 레코드 발견) 안 남
        adminStoreMapper.clearAllReportRefsByReviewId(reviewId);
        adminStoreMapper.deleteReview(reviewId);
    }

    //지윤 26.07.21 추가: 반려 - 리뷰는 그대로 두고 요청만 DONE 처리
    @Override
    public void rejectReviewReport(Long reportId, Long adminNo) {
        adminStoreMapper.updateReportDone(reportId, adminNo);
    }

    // 2026/08/11 장우철 — 전 사업자 상품 목록
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
