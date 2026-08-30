/**
 * 역할: 관리자 사업자 승인·재능나눔 승인 비즈니스 로직 (interface)
 *
 * 담당 화면
 * - admin/biz/list.jsp      사업자 승인 목록
 * - admin/biz/detail.jsp    사업자 신청 상세
 */

package com.petcare.petcare.admin.biz.service;

import java.util.List;
import java.util.Map;

import com.petcare.petcare.admin.biz.vo.AdminBizVO;
import com.petcare.petcare.biz.vo.BizCouponVO;
import com.petcare.petcare.file.vo.FileVO;

public interface AdminBizService {

    // 2026-07-09 장우철 — 사업자 승인 목록·상세·처리 API
    // 2026/07/28 장우철 — bizType: ALL 또는 HOSPITAL/STAY/STORE/GROOMING/STUDIO (승인/관리 필터)
    List<AdminBizVO> getBizApplyList(String statusCd, String bizType);

    AdminBizVO getBizApplyDetail(Long bizNo);

    Map<String, Integer> getBizStatusCounts();

    List<FileVO> getBizAuthFiles(Long bizNo);

    List<FileVO> getBizLicenseFiles(Long bizNo);

    void approveBiz(Long bizNo);

    void rejectBiz(Long bizNo, String rejectReason);

    //HYJ 26.07.29 쿠폰관리
    List<BizCouponVO> getCouponListByStatus(String approvalStatus);

    BizCouponVO getCouponDetail(Long couponId);

    Map<String, Integer> getCouponStatusCounts();

    void approveCoupon(Long couponId);

    void rejectCoupon(Long couponId, String rejectReason);

    // 2026-08-13 박유정 — 탭별 목록 (review / published / exhausted)
    List<BizCouponVO> getCouponListByTab(String tab, String status);
    Map<String, Integer> getCouponTabCounts();
}
