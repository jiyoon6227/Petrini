package com.petcare.petcare.admin.main.vo;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AdminMainOrderVO {

    // TB_ORDER 컬럼

    private Long orderId;       // ORDER_ID — 주문 번호 (PK, 상세 링크용)
    private String orderNo;     // ORDER_NO — 주문번호 (#화면표시)
    private Long payAmount;     // PAY_AMOUNT — 실결제 금액 (원)
    private String orderStatus; // ORDER_STATUS — PAID/SHIPPING/CANCEL 등

    // 조회 전용 (TB_MEMBER JOIN)

    private String memberName;  // MEMBER_NAME — 주문자명
}
