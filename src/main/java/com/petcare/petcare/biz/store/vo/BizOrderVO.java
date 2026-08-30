package com.petcare.petcare.biz.store.vo;

import java.util.List;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import lombok.NoArgsConstructor;

//지윤 26.07.20 사업자 주문목록/상세 조회용 VO
@Getter @Setter
@ToString
@NoArgsConstructor
public class BizOrderVO {
    private Long orderId;
    private String orderNo;
    private String orderStatus;
    private Integer payAmount;
    private String orderDate;
    private String buyerName;
    private String firstProductName;
    private Integer itemCount;

    //지윤 26.07.20 추가: 상세보기 전용 필드
    private String buyerPhone;
    private String buyerEmail;
    private String recvName;
    private String recvPhone;
    private String zipCode;
    private String addr1;
    private String addr2;
    private String payMethod;
    private String courierName;
    private String courierCode;   //지윤 26.07.27 추가: 스마트택배 API 코드 (orders.jsp 배송조회/드롭다운 API 연동용)
    private String trackingNo;
    private String deliveryStatus;
    private List<BizOrderItemVO> itemList;

    // 지윤 26.08.07: 상세화면에 결제금액 세부 내역(상품금액/배송비/쿠폰명) 표시용
    private Integer productTotal;   // TB_ORDER.TOTAL_AMOUNT (배송비·할인 반영 전 상품 합계)
    private Integer deliveryFee;
    private Integer discountAmount; // 쿠폰+포인트 할인 합계 (TB_ORDER.DISCOUNT_AMOUNT)
    private String  couponName;     // 사용한 쿠폰명 (없으면 null)

    //지윤 26.07.22 추가: 취소신청 정보 (취소신청 탭/상세용)
    private String claimStatus;    // PENDING/DONE/REJECTED
    private String cancelReason;   // 유저가 입력한 취소사유
    private String requestedAt;    // 취소 신청일시
    private Integer refundAmount;  // 실제 환불금액 (승인완료 시에만 값 있음)

    //지윤 26.07.22 추가: 취소승인 처리(토스취소/재고/포인트/쿠폰 복구)에 필요한 값
    private Long memberNo;
    private Integer pointUsed;
    private Long memberCouponId;
    private String tossPaymentKey;

    // 2026/08/04 장우철 — 환불신청/진행 상품 수 (목록 뱃지용)
    private Integer activeReturnCount;
    // 2026/08/13 장우철 — 환불완료 상품 수 / 목록·상세 뱃지
    private Integer doneReturnCount;
    private String statusBadge;
}