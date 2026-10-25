package com.petcare.petcare.admin.store.vo;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class AdminStoreOrderVO {
    private Long orderId;
    private String orderNo;      // 사업자 주문번호
    private String orderGroupNo; // 주문번호 (결제 단위)
    private Long bizNo;
    private String bizName;
    private String buyerName;
    private String firstProductName;
    private Integer itemCount;
    private Integer payAmount;
    private String payMethod;
    private String orderStatus;
    private String orderDate;
}
