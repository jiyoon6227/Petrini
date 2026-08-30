package com.petcare.petcare.store.vo;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import lombok.NoArgsConstructor;

//지윤 26.07.09 회원 보유쿠폰(TB_MEMBER_COUPON + TB_COUPON 조인) 조회용 VO
//2026/08/01 장우철 — yeju 머지: bizNo(지윤 주문서) + 쿠폰함/발급 필드(yeju) 모두 유지
@Getter @Setter
@ToString
@NoArgsConstructor
public class CouponVO {
    private Long memberCouponId;
    private Long couponId;
    private String couponName;
    private String couponType;
    private Integer discountValue;
    private Integer maxDiscountAmt; // 정률(RATE) 쿠폰 최대 할인금액 (FIXED는 NULL) // 지윤 26.08.11 추가
    private Integer minOrderAmt;
    private String bizNo; //지윤 26.07.30 추가: 이 쿠폰이 어느 사업자 발급인지
    private String bizType;      //2026.08.06 지윤 추가: HOSPITAL/STAY/STORE 등 업종
    private Long targetId;       //2026.08.06 지윤 추가: HOSPITAL→hospitalId, STAY→stayId

    //HYJ 26.07.31
    private String  couponCode;
    private Integer totalBudget;
    private Integer issuedBudget;
    private Integer totalQty;
    private Integer issuedQty;
    private String  useStartDate;     // YYYYMMDD
    private String  useEndDate;       // YYYYMMDD
    private String  statusCd;         // ACTIVE / INACTIVE / EXHAUSTED
    private String  bizName;          // 사업자명 (조인)

    // TB_MEMBER_COUPON (보유 쿠폰 조회 시)
    private String  memberCouponStatus;  // UNUSED / USED / EXPIRED
    private String  usedDate;
    private String  regDate;             // 쿠폰 받은 날짜

    // 화면 표시용
    private boolean alreadyClaimed;      // 이미 받았는지 여부
}
