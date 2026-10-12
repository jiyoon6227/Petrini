package com.petcare.petcare.common.billing.vo;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class BillingApproveResultVO {

    private String paymentKey;  // 토스 paymentKey
    private String orderId;     // 요청한 orderId
    private String method;      // 결제수단 (참고)
    private Integer totalAmount;
}
