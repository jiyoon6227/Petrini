/**
 * 2026/08/11 장우철 — 관리자 주문 목록 (전 사업자)
 * 참고: TB_ORDER + TB_MEMBER + TB_BUSINESS + TB_PAYMENT
 */
package com.petcare.petcare.admin.store.vo;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class AdminStoreOrderVO {
    private Long orderId;
    private String orderNo;
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
