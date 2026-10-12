package com.petcare.petcare.mypage.order.vo;

import java.util.List;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import lombok.NoArgsConstructor;

// 마이페이지 주문내역 조회용 VO
@Getter @Setter
@ToString
@NoArgsConstructor
public class MypageOrderVO {
    private Long orderId;
    private String orderNo;
    private String orderGroupId; // 같은 결제(TOSS_ORDER_ID)로 묶인 여러 사업자 주문을 화면에서 하나로 그룹핑하기 위한 키
    private String orderDate;
    private String orderStatus;   //PAID/READY/SHIPPING/DONE/CANCEL
    private Integer payAmount;
    private String bizName; // 상세보기에서 사업자별 소계 섹션 헤더용
    private List<MypageOrderItemVO> itemList;
    private String ordererName; // 주문정보 섹션의 "주문자" (TB_MEMBER.NICKNAME)

   // 주문상세보기(/mypage/orders/detail) 결제내역/배송지 표시용
    private Integer totalAmount;
    private Integer deliveryFee;
    private Integer discountAmount;
    private Integer pointUsed;
    private String recvName;
    private String recvPhone;
    private String zipCode;
    private String addr1;
    private String addr2;

   // 배송정보 (TB_ORDER_DELIVERY, 등록 전이면 둘 다 null)
   private String courierName;
   private String courierCode;   // 마이페이지 배송조회(스마트택배 API 호출)용
   private String trackingNo;
   private String deliveryMemo;

    // 배송 단계별 시각 (타임라인용)
    private java.util.Date readyAt;
    private java.util.Date shippingAt;
    private java.util.Date deliveredAt;

    // 주문취소 신청/처리 상태 (TB_ORDER 클레임 컬럼)
    private String claimStatus;         // PENDING/DONE/REJECTED (신청 안 했으면 null)
    private String cancelReason;        // 유저가 신청 시 입력한 사유
    private Integer refundAmount;       // 실제 환불된 금액 (DONE일 때만 값 있음)
    private java.util.Date requestedAt; // 취소 신청일시

    // 구매확정 여부 (Y=적립금 지급완료)
    private String confirmYn;

    // 목록/상세 뱃지 (CANCEL_REQUEST/REFUND_DONE/PARTIAL_REFUND/REFUND_PROGRESS 또는 주문상태)
    private String statusBadge;
}