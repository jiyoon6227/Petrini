package com.petcare.petcare.biz.store.vo;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import lombok.NoArgsConstructor;

//지윤 26.07.20 주문 상세 - 상품 목록 한 줄용 VO
@Getter @Setter
@ToString
@NoArgsConstructor
public class BizOrderItemVO {
    private Long orderItemId;
    private Long productId;
    private Long optionId;   //지윤 26.07.22 추가: 취소승인 시 재고복구용
    private String productName;
    private String optionColor;
    private String optionSize;
    private Integer qty;
    private Integer unitPrice;
    private Integer totalPrice;
    private String thumbnailUrl; // 지윤 26.08.07: 주문상세 화면 상품 썸네일 표시용

    // 2026/08/04 장우철 — 상품단위 환불
    private String returnStatusCd;
    private String returnReasonCd;
    private String claimReason;
    private Integer returnFeeAmount;
    private String returnFeePayer;
    private Integer refundAmount;
    private String returnRejectReason;
    private java.util.Date returnRequestedAt;
    private java.util.Date returnApprovedAt;
    private java.util.Date returnRejectedAt;
    private java.util.Date returnDoneAt;
}
