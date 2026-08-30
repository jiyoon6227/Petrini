package com.petcare.petcare.biz.store.vo;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import lombok.NoArgsConstructor;

//지윤 26.07.20 배송관리 목록용 VO (TB_ORDER + TB_ORDER_DELIVERY 조인 결과)
@Getter @Setter
@ToString
@NoArgsConstructor
public class BizDeliveryVO {
    private Long orderId;
    private String orderNo;
    private String buyerName;
    private String courierName;
    private String courierCode;   //지윤 26.07.24 추가: 스마트택배 API 택배사 코드
    private String trackingNo;
    private String orderStatus;   //READY / SHIPPING / DONE
    private String shipDate;      //TB_ORDER_DELIVERY.REGISTERED_AT (송장 등록한 날, 없으면 null)
    private boolean delayed;      //SHIPPING 상태로 3일 이상 지난 경우 true (자바에서 계산)
}