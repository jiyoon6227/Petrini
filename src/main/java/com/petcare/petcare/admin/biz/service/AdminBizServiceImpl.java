/**
 * 역할: AdminBizService 구현체 (@Service)
 *
 * 연결
 * - implements: AdminBizService
 * - 사용: AdminBizMapper, FileMapper
 */

package com.petcare.petcare.admin.biz.service;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.admin.biz.mapper.AdminBizMapper;
import com.petcare.petcare.admin.biz.vo.AdminBizVO;
import com.petcare.petcare.biz.hospital.mapper.BizHospitalMapper;
import com.petcare.petcare.biz.stay.mapper.BizStayMapper;
import com.petcare.petcare.biz.vo.BizCouponVO;
import com.petcare.petcare.file.mapper.FileMapper;
import com.petcare.petcare.file.vo.FileVO;
import com.petcare.petcare.mypage.notify.service.MypageNotifyService;

@Service
public class AdminBizServiceImpl implements AdminBizService {

    @Autowired
    private AdminBizMapper adminBizMapper;

    // 2026-07-09 장우철 — 신청 서류 조회용 (MypageBiz apply 시 REF_TYPE=BIZ_AUTH / BIZ_LICENSE)
    // 이유: 상세 화면에서 TB_FILE 메타를 그대로 재사용 (FK 없이 refType+refId 패턴)
    @Autowired
    private FileMapper fileMapper;

    //HYJ 26.07.09 사업자 승인 시, insert tb_hospital 필요
    @Autowired
    private BizHospitalMapper bizHospitalMapper;
    @Autowired
    private BizStayMapper bizStayMapper;

    // 2026-07-09 장우철 — 반려 알림 발송 (TB_NOTIFICATION)
    // 이유: rejectBiz 트랜잭션 안에서 해당 유저에게만 알림 INSERT
    @Autowired
    private MypageNotifyService mypageNotifyService;

    @Override
    public List<AdminBizVO> getBizApplyList(String statusCd, String bizType) {
        // 2026/07/28 장우철 — 승인/관리 탭 업종 필터 (null/ALL = 전체)
        return adminBizMapper.selectBizApplyList(statusCd, bizType);
    }

    @Override
    public AdminBizVO getBizApplyDetail(Long bizNo) {
        return adminBizMapper.selectBizApplyDetail(bizNo);
    }

    @Override
    public Map<String, Integer> getBizStatusCounts() {
        Map<String, Integer> counts = new HashMap<>();
        counts.put("PENDING", adminBizMapper.countBizApplyByStatus("PENDING"));
        counts.put("APPROVED", adminBizMapper.countBizApplyByStatus("APPROVED"));
        counts.put("REJECTED", adminBizMapper.countBizApplyByStatus("REJECTED"));
        return counts;
    }

    @Override
    public List<FileVO> getBizAuthFiles(Long bizNo) {
        return selectFilesByRef("BIZ_AUTH", bizNo);
    }

    @Override
    public List<FileVO> getBizLicenseFiles(Long bizNo) {
        return selectFilesByRef("BIZ_LICENSE", bizNo);
    }

    private List<FileVO> selectFilesByRef(String refType, Long bizNo) {
        try {
            FileVO query = new FileVO();
            query.setRefType(refType);
            query.setRefId(bizNo);
            return fileMapper.selectFileList(query);
        } catch (Exception e) {
            throw new IllegalStateException("FILE_LIST_FAILED", e);
        }
    }

    // 2026-07-09 장우철 — 승인 처리 (TB_BUSINESS + TB_BUSINESS_AUTH 동시 갱신)
    // 이유: USER 신청(applyBusiness)이 두 테이블에 PENDING 으로 넣으므로 승인도 쌍으로 맞춤
    // 후속: 로그인 시 TB_BUSINESS APPROVED 이면 세션 role=BIZ 세팅은 MemberAuth 쪽 별도 작업
    @Override
    @Transactional
    public void approveBiz(Long bizNo) {
        AdminBizVO biz = requirePendingBiz(bizNo);
        adminBizMapper.updateBusinessStatus(biz.getBizNo(), "APPROVED");
        adminBizMapper.updateBusinessAuthStatus(biz.getBizNo(), "APPROVED");

        //HYJ 26.07.09 병원 사업자인 경우, TB_HOSPITAL 빈 껍데기 INSERT
        if ("HOSPITAL".equals(biz.getBizType())) {
            bizHospitalMapper.insertHospital(biz.getBizId());
        }
        else if ("STAY".equals(biz.getBizType())) {
            bizStayMapper.insertStay(biz.getBizId());
        }

        // 2026-07-10 장우철 — 승인 알림 INSERT (반려와 동일하게 TB_NOTIFICATION, 이메일/푸시 후순위)
        Long memberNo = adminBizMapper.selectMemberNoByBizId(biz.getBizId());
        if (memberNo != null) {
            mypageNotifyService.sendBizApproveNotification(memberNo, biz.getBizName(), biz.getBizType());
        }
    }

    // 2026-07-09 장우철 — [변경 후] 반려 처리 + 사유 저장 + 유저 알림
    // 이유: DATABASE_TABLE.sql TB_BUSINESS_AUTH.REJECT_REASON / TB_NOTIFICATION 활용
    @Override
    @Transactional
    public void rejectBiz(Long bizNo, String rejectReason) {
        if (rejectReason == null || rejectReason.isBlank()) {
            throw new IllegalArgumentException("REJECT_REASON_REQUIRED");
        }
        AdminBizVO biz = requirePendingBiz(bizNo);
        String reason = rejectReason.trim();

        adminBizMapper.updateBusinessStatus(biz.getBizNo(), "REJECTED");
        adminBizMapper.updateBusinessAuthReject(biz.getBizNo(), "REJECTED", reason);

        Long memberNo = adminBizMapper.selectMemberNoByBizId(biz.getBizId());
        if (memberNo != null) {
            mypageNotifyService.sendBizRejectNotification(memberNo, biz.getBizName(), reason);
        }

        /* [변경 전] 2026-07-09 장우철 — STATUS 만 REJECTED, 사유·알림 없음
        adminBizMapper.updateBusinessStatus(biz.getBizNo(), "REJECTED");
        adminBizMapper.updateBusinessAuthStatus(biz.getBizNo(), "REJECTED");
        */
    }

    private AdminBizVO requirePendingBiz(Long bizNo) {
        if (bizNo == null) {
            throw new IllegalArgumentException("BIZ_NO_REQUIRED");
        }
        AdminBizVO biz = adminBizMapper.selectBizApplyDetail(bizNo);
        if (biz == null) {
            throw new IllegalArgumentException("BIZ_NOT_FOUND");
        }
        if (!"PENDING".equals(biz.getStatusCd())) {
            throw new IllegalStateException("BIZ_NOT_PENDING");
        }
        return biz;
    }

    //HYJ 26.07.29 쿠폰관리
    @Override
    public List<BizCouponVO> getCouponListByStatus(String approvalStatus) {
        // 2026-08-13 박유정 — selectCouponListFiltered 재사용 (Mapper Java 선언 통일)
        return adminBizMapper.selectCouponListFiltered(approvalStatus, null);
    }
    @Override
    public BizCouponVO getCouponDetail(Long couponId) {
        return adminBizMapper.selectCouponById(couponId);
    }

    @Override
    public Map<String, Integer> getCouponStatusCounts() {
        Map<String, Integer> counts = new LinkedHashMap<>();
        counts.put("PENDING",  adminBizMapper.countCouponByStatus("PENDING"));
        counts.put("APPROVED", adminBizMapper.countCouponByStatus("APPROVED"));
        counts.put("REJECTED", adminBizMapper.countCouponByStatus("REJECTED"));
        return counts;
    }

    // 2026-08-13 박유정 — 관리자승인 / 게시중(ACTIVE) / 예산소진(EXHAUSTED)
    @Override
    public List<BizCouponVO> getCouponListByTab(String tab, String status) {
        if ("published".equals(tab)) {
            return adminBizMapper.selectCouponListFiltered("APPROVED", "ACTIVE");
        }
        if ("exhausted".equals(tab)) {
            return adminBizMapper.selectCouponListFiltered("APPROVED", "EXHAUSTED");
        }
        // review (기본): PENDING / REJECTED
        if (status == null || status.isBlank() || "APPROVED".equals(status)) {
            status = "PENDING";
        }
        if (!"PENDING".equals(status) && !"REJECTED".equals(status)) {
            status = "PENDING";
        }
        return adminBizMapper.selectCouponListFiltered(status, null);
    }

    @Override
    public Map<String, Integer> getCouponTabCounts() {
        Map<String, Integer> counts = new LinkedHashMap<>();
        counts.put("PENDING",   adminBizMapper.countCouponFiltered("PENDING", null));
        counts.put("REJECTED",  adminBizMapper.countCouponFiltered("REJECTED", null));
        counts.put("PUBLISHED", adminBizMapper.countCouponFiltered("APPROVED", "ACTIVE"));
        counts.put("EXHAUSTED", adminBizMapper.countCouponFiltered("APPROVED", "EXHAUSTED"));
        return counts;
    }

    

    @Override
    public void approveCoupon(Long couponId) {
        BizCouponVO coupon = adminBizMapper.selectCouponById(couponId);
        if (coupon == null) {
            throw new IllegalArgumentException("COUPON_NOT_FOUND");
        }
        if (!"PENDING".equals(coupon.getApprovalStatus())) {
            throw new IllegalStateException("NOT_PENDING");
        }
        // 승인 → APPROVED + ACTIVE
        adminBizMapper.updateCouponApproval(couponId, "APPROVED", "ACTIVE");
    }

    @Override
    public void rejectCoupon(Long couponId, String rejectReason) {
        if (rejectReason == null || rejectReason.isBlank()) {
            throw new IllegalArgumentException("REJECT_REASON_REQUIRED");
        }
        BizCouponVO coupon = adminBizMapper.selectCouponById(couponId);
        if (coupon == null) {
            throw new IllegalArgumentException("COUPON_NOT_FOUND");
        }
        if (!"PENDING".equals(coupon.getApprovalStatus())) {
            throw new IllegalStateException("NOT_PENDING");
        }
        adminBizMapper.updateCouponReject(couponId, "REJECTED", rejectReason.trim());
    }
}
