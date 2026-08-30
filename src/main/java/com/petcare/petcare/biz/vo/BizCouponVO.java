package com.petcare.petcare.biz.vo;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import lombok.NoArgsConstructor;

/**
 * 쿠폰 마스터 VO (TB_COUPON)
 * 사업자 쿠폰 신청 / 관리자 승인 화면에서 공용 사용
 */
@Getter @Setter
@ToString
@NoArgsConstructor
public class BizCouponVO {

    // TB_COUPON
    private Long   couponId;         // 쿠폰 ID (PK)
    private String couponCode;       // 쿠폰 코드 (UK)
    private String couponName;       // 쿠폰명
    private String couponType;       // 할인 유형 (FIXED / RATE)
    private Integer discountValue;   // 할인값 (정액=원, 정률=%)
    private Integer maxDiscountAmt;  // 정률(RATE) 쿠폰 최대 할인금액 (FIXED는 NULL) // 지윤 26.08.11 추가
    private Integer minOrderAmt;     // 최소 주문 금액

    private Integer totalBudget;     // 총 예산
    private Integer issuedBudget;    // 소진 예산
    private Integer totalQty;        // 발급 가능 총 수량
    private Integer issuedQty;       // 발급된 수량

    private String useStartDate;     // 사용 시작일 (YYYYMMDD)
    private String useEndDate;       // 사용 종료일 (YYYYMMDD)

    // 2026/08/01 장우철 — DDL BIZ_MEMBER_NO NUMBER (구 BIZ_MEMBER_ID 문자열 → TB_BUSINESS.BIZ_NO)
    private Long   bizMemberNo;      // 신청 사업자번호 (TB_BUSINESS.BIZ_NO)
    private String approvalStatus;   // 승인 상태 (PENDING / APPROVED / REJECTED)
    private String rejectReason;     // 반려 사유
    private String approvalDate;     // 승인/반려 처리일

    private String statusCd;         // 쿠폰 운영 상태 (ACTIVE / INACTIVE / EXHAUSTED)
    private String regDate;          // 신청일시
    private String modDate;          // 수정일시

    // 조인 조회용 (목록 표시)
    private String bizName;          // 사업자명 (TB_BUSINESS.BIZ_NAME)
    private String memberName;       // 회원명
}
