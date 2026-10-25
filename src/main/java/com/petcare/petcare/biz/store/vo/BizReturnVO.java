package com.petcare.petcare.biz.store.vo;

import java.util.Date;
import java.util.List;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@ToString
@NoArgsConstructor
public class BizReturnVO {
    private Long orderItemId;
    private Long orderId;
    private String orderNo;      // 사업자 주문번호
    private String orderGroupNo; // 주문번호 (결제 단위)
    private String orderStatus;
    private Long memberNo;
    private String buyerName;
    private String buyerPhone;
    private Date orderDate;

    private Long productId;
    private Long optionId;
    private String productName;
    private String optionColor;
    private String optionSize;
    private Integer qty;
    private Integer unitPrice;
    private Integer totalPrice;

    private String returnStatusCd;
    private String returnReasonCd;
    private String claimReason;
    private Integer returnFeeAmount;
    private String returnFeePayer;
    private Integer refundAmount;
    private String returnRejectReason;
    private Date returnRequestedAt;
    private Date returnApprovedAt;
    private Date returnRejectedAt;
    private Date returnDoneAt;

    private String tossPaymentKey;
    private String payMethod; // BILLING 여부 (토스 취소 시크릿 분기)
    private Integer payAmount;
    private Integer pointUsed;
    private Long memberCouponId;
    // 주문 결제 내역·이 상품 환불 배분
    private Integer orderProductTotal;
    private Integer deliveryFee;
    private Integer discountAmount;
    private Integer orderCouponAmount;
    private String couponName;
    private Integer itemCouponAmount;
    private Integer itemPointAmount;
    private Integer itemPayAmount;
    private Integer userReturnFee;
    private Integer returnShipReimburse;
    private Integer paidRefundAmt;
    private Boolean lastItemRefund;
    private Integer expectCardRefund;

    private String courierName;
    private String trackingNo;

    /** 상품이상 첨부 사진 URL */
    private List<String> photoUrls;
}
