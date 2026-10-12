package com.petcare.petcare.admin.biz.service;

import java.util.List;
import java.util.Map;

import com.petcare.petcare.admin.biz.vo.AdminBizVO;
import com.petcare.petcare.biz.vo.BizCouponVO;
import com.petcare.petcare.file.vo.FileVO;

public interface AdminBizService {

    // 사업자 승인 목록·상세·처리 API
    // bizType: ALL 또는 HOSPITAL/STAY/STORE/GROOMING/STUDIO (승인/관리 필터)
    List<AdminBizVO> getBizApplyList(String statusCd, String bizType);

    AdminBizVO getBizApplyDetail(Long bizNo);

    Map<String, Integer> getBizStatusCounts();

    List<FileVO> getBizAuthFiles(Long bizNo);

    List<FileVO> getBizLicenseFiles(Long bizNo);

    void approveBiz(Long bizNo);

    void rejectBiz(Long bizNo, String rejectReason);

    // 쿠폰관리
    List<BizCouponVO> getCouponListByStatus(String approvalStatus);

    BizCouponVO getCouponDetail(Long couponId);

    Map<String, Integer> getCouponStatusCounts();

    void approveCoupon(Long couponId);

    void rejectCoupon(Long couponId, String rejectReason);

    // 탭별 목록 (review / published / exhausted)
    List<BizCouponVO> getCouponListByTab(String tab, String status);
    Map<String, Integer> getCouponTabCounts();
}
