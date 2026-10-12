/**
 * 화면 표기: PAY_STATUS WAIT 지급대기 / DONE 지급완료, SETTLE_STATUS PENDING 지급 전 / PAID 지급 처리
 * REQUEST.STATUS REQUESTED/APPROVED/REJECTED → 요청대기/요청승인/요청거절, REQUEST_TYPE REGULAR 월정산 / ADHOC 중간정산
 */
package com.petcare.petcare.settlement.vo;

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
public class StaySettlementVO {

    // PK / 연결
    private Long settleId;               // 정산 ID (PK)
    private Long bizNo;                  // 사업자번호
    private Long requestId;              // 중간정산 요청 ID (없으면 null)
    private Long resvId;                 // 예약 ID (예전 단건용, 묶음/쇼핑은 null)

    // 유형·상태
    private String settleType;           // 기존유형 (COMMISSION/FEE/PARTNER 등)
    private String bizType;              // 사업자유형 (STAY/STORE)
    private String settleStatus;         // 정산상태 (PENDING/REQUESTED/HOLD/PAID/REJECTED)
    private String payStatus;            // 지급상태 (WAIT/DONE/FAIL)
    private String requestType;          // 요청유형 (REGULAR=정기 / ADHOC=중간)
    private String requestScope;         // 요청범위 (ALL/ROOM/PRODUCT)

    // 기간·범위
    private String settleMonth;          // 정산기준월 (YYYY-MM, 숙소=체크아웃월)
    private Date periodStart;            // 집계 시작일
    private Date periodEnd;              // 집계 종료일
    private Long roomId;                 // 숙소 특정객실 중간정산용 객실ID
    private Long productId;              // 쇼핑 특정상품 중간정산용 상품ID

    // 금액
    private Long payAmount;              // 실결제금액 (호환)
    private Double feeRate;              // 적용 수수료율(%)
    private Long feeAmount;              // 수수료 금액
    private Long totalSales;             // 정산 대상 총액
    private Long totalFee;               // 합계 수수료
    private Long settleAmount;           // 실지급 정산금
    private Long annualFee;              // 연회비 (호환)
    private Long productSalesAmount;     // 상품매출 (택배비 제외, 쇼핑)
    private Long deliveryFeeAmount;      // 택배비 합 (패스스루, 쇼핑)
    private Long returnFeeAmount;        // 반품택배비 합 (사업자 부담분 등)

    // 일시·사유
    private Date regDate;                // 등록일
    private Date applyDate;              // 신청일 (호환)
    private Date payDate;                // 지급일
    private Date requestedAt;            // 중간정산 요청일시
    private Date approvedAt;             // 승인일시
    private String rejectReason;         // 거절사유

    // 상세 목록 (1-5 저장 트랜잭션·화면 상세용)
    private List<StaySettlementItemVO> items; // 정산 상세 ITEM 목록
}
