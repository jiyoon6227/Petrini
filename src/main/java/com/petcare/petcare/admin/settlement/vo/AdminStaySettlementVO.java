package com.petcare.petcare.admin.settlement.vo;

import java.util.Date;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@ToString
@NoArgsConstructor
public class AdminStaySettlementVO {

    private Long settleId;           // 정산 ID
    private Long bizNo;              // 사업자번호
    private String bizName;          // 사업장명 (TB_BUSINESS.BIZ_NAME)
    private String settleMonth;      // 정산월 YYYY-MM
    private Date periodStart;        // 집계 시작
    private Date periodEnd;          // 집계 종료
    private Long totalSales;         // 확정 매출
    private Long couponDiscountAmount; // 사업자 부담 쿠폰
    private Long productSalesAmount; // 상품매출 (쇼핑, 택배비 제외)
    private Long deliveryFeeAmount;  // 택배비 합 (쇼핑)
    private Long totalFee;           // 수수료
    private Long settleAmount;       // 실지급 정산금
    private Double feeRate;          // 수수료율
    private String settleStatus;     // 정산 상태
    private String payStatus;        // WAIT / DONE / FAIL
    private Date payDate;            // 지급일
    private String requestType;      // REGULAR / ADHOC
    private String requestScope;     // ALL / ROOM

    // 정산 계좌 (TB_BUSINESS)
    private String settleBank;       // 은행명
    private String settleAccount;    // 계좌번호
    private String settleHolder;     // 예금주
}
