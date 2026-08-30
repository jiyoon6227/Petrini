/**
 * 역할: 관리자 사업자 관리 DB 접근 (MyBatis interface)
 *
 * XML: resources/mybatis/mapper/admin/biz/AdminBizMapper.xml
 */

package com.petcare.petcare.admin.biz.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.admin.biz.vo.AdminBizVO;
import com.petcare.petcare.biz.vo.BizCouponVO;

@Mapper
public interface AdminBizMapper {

    // 2026-07-09 장우철 — 사업자 신청 목록 (상태 탭 필터)
    // 2026/07/28 장우철 — APPROVED(승인/관리) 탭에서 업종(bizType) 추가 필터
    List<AdminBizVO> selectBizApplyList(@Param("statusCd") String statusCd,
                                        @Param("bizType") String bizType);

    // 2026-07-09 장우철 — 사업자 신청 상세 1건
    // 이유: admin/biz/detail.jsp 에서 bizNo 기준으로 기본정보 + 최신 AUTH 이력 표시
    AdminBizVO selectBizApplyDetail(@Param("bizNo") Long bizNo);

    // 2026-07-09 장우철 — 탭 뱃지용 건수
    // 이유: list.jsp 상단 "대기 N건" 을 DB 실제 건수로 표시
    int countBizApplyByStatus(@Param("statusCd") String statusCd);

    // 2026-07-09 장우철 — TB_BUSINESS 승인/반려 상태 변경
    // 이유: USER 신청 시 insertBusiness 가 넣은 TB_BUSINESS.STATUS_CD 를 관리자가 갱신
    int updateBusinessStatus(@Param("bizNo") Long bizNo,
                             @Param("statusCd") String statusCd);

    // 2026-07-09 장우철 — TB_BUSINESS_AUTH 최신 신청 건 상태 변경
    // 이유: MypageBiz applyBusiness 가 PENDING 으로 넣은 AUTH 이력도 같이 APPROVED/REJECTED 처리
    int updateBusinessAuthStatus(@Param("bizNo") Long bizNo,
                                 @Param("statusCd") String statusCd);

    // 2026-07-09 장우철 — TB_BUSINESS_AUTH 최신 건 반려 (REJECT_REASON 저장)
    // 이유: DATABASE_TABLE.sql TB_BUSINESS_AUTH.REJECT_REASON 컬럼에 관리자 입력 사유 보관
    int updateBusinessAuthReject(@Param("bizNo") Long bizNo,
                                 @Param("statusCd") String statusCd,
                                 @Param("rejectReason") String rejectReason);

    // 2026-07-09 장우철 — BIZ_ID(=회원 이메일)로 MEMBER_NO 조회
    // 이유: 반려 알림은 TB_NOTIFICATION.MEMBER_NO 대상으로만 INSERT
    Long selectMemberNoByBizId(@Param("bizId") String bizId);

    //HYJ 26.07.29 쿠폰 관리
    // 2026-08-13 박유정 — 승인(ACTIVE) / 소진(EXHAUSTED) 등 STATUS_CD까지 필터
    List<BizCouponVO> selectCouponListFiltered(@Param("approvalStatus") String approvalStatus,
                                               @Param("statusCd") String statusCd);
    int countCouponFiltered(@Param("approvalStatus") String approvalStatus,
                            @Param("statusCd") String statusCd);

    // 상태별 건수
    int countCouponByStatus(@Param("approvalStatus") String approvalStatus);

    // 쿠폰 상세
    BizCouponVO selectCouponById(@Param("couponId") Long couponId);

    // 승인 처리
    int updateCouponApproval(@Param("couponId") Long couponId,
                             @Param("approvalStatus") String approvalStatus,
                             @Param("statusCd") String statusCd);

    // 반려 처리
    int updateCouponReject(@Param("couponId") Long couponId,
                           @Param("approvalStatus") String approvalStatus,
                           @Param("rejectReason") String rejectReason);
}
