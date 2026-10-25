package com.petcare.petcare.admin.member.vo;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AdminMemberOrderVO {

    // TB_ORDER 컬럼

    private Long orderId;            // ORDER_ID — 주문 번호 (PK)
    private String orderNo;          // ORDER_NO — 사업자 주문번호 (화면 보조 표시)
    private String orderGroupNo;     // ORDER_GROUP_NO — 주문번호 (결제 단위, 화면 표시)
    private String orderStatus;      // ORDER_STATUS — 주문 상태
    private Long payAmount;            // PAY_AMOUNT — 실결제 금액
    private String orderDate;          // ORDER_DATE — 주문일

    // 조회 전용 (TB_ORDER_ITEM)

    private String firstProductName;   // PRODUCT_NAME — 대표 상품명 (첫 항목)
    private Integer itemCount;         // (집계) — 주문 상품 건수
}
