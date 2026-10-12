package com.petcare.petcare.settlement.vo;

import java.util.Date;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@ToString
@NoArgsConstructor
public class StoreSettlementRequestVO {

    private Long requestId;
    private Long bizNo;

    private String requestScope;         // ALL / PRODUCT
    private Long roomId;                 // 쇼핑 null
    private Long productId;              // PRODUCT일 때

    private Date targetStart;
    private Date targetEnd;

    private String statusCd;             // REQUESTED / APPROVED / REJECTED / CANCELED

    private String requestMemo;
    private String rejectReason;

    private Date requestedAt;
    private Date approvedAt;
    private Date rejectedAt;
}
