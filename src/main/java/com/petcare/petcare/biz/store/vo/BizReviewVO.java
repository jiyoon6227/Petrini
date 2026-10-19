package com.petcare.petcare.biz.store.vo;

import java.util.Date;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class BizReviewVO {

    private Long reviewId;
    private Long productId;      // TARGET_ID
    private Long memberNo;
    private Double rating;
    private String content;
    private String bizReply;
    private Date regDate;

    // 조회용 조인
    private String nickname;
    private String productName;
    private String optionColor;  // ORDER_ITEM_ID로 조인한 실제 구매 옵션
    private String optionSize;
    private String thumbnailUrl; // 상품 썸네일 (리뷰카드 UI 개선)

    // 가장 최근 삭제요청 (TB_REVIEW_DELETE_REQUEST, 요청 없으면 null)
    private String deleteReqStatus;     // PENDING/APPROVED/REJECTED/CANCELED
    private String deleteRejectReason;  // 관리자 반려 사유

    // 고객 신고 건수 (TB_REVIEW_REPORT)
    private Integer reportCount;
}