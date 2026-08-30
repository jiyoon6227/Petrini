package com.petcare.petcare.mypage.order.vo;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import lombok.NoArgsConstructor;

//지윤 26.07.20 마이페이지 주문내역 - 주문 상품 한 줄용 VO
@Getter @Setter
@ToString
@NoArgsConstructor
public class MypageOrderItemVO {
    private Long orderItemId;     //지윤 26.07.20 추가: 리뷰작성 시 어느 주문상품인지 식별용
    private Long productId;
    private String productName;
    private String optionColor;
    private String optionSize;
    private Integer qty;
    private Integer totalPrice;
    private String thumbnailUrl;
    private boolean reviewed;     //지윤 26.07.20 추가: 이미 리뷰 작성했는지 (버튼 상태 분기용)

    // 2026/08/04 장우철 — 송장 이후 상품단위 환불(RETURN_*)
    private String returnStatusCd;   // NONE/REQUESTED/REJECTED/RETURNING/DONE
    private String returnReasonCd;   // CHANGE_OF_MIND / DEFECT
    private String claimReason;      // 신청 본문
    private String confirmHoldYn;    // 환불중 확정 보류
    private Integer refundAmount;    // 실환불액
    private Integer returnFeeAmount; // 반품택배비
    private String returnRejectReason;
    // 2026/08/04 장우철 — 상품단위 구매확정 시각 (부분 확정·정산용)
    private java.util.Date confirmedAt;
}