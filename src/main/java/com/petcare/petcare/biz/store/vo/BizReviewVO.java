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
    private String optionColor;  //지윤 26.07.22 복원: ORDER_ITEM_ID로 조인한 실제 구매 옵션
    private String optionSize;
    private String thumbnailUrl; //지윤 26.07.22 추가: 상품 썸네일 (리뷰카드 UI 개선)

    // 삭제요청 상태 (TB_REVIEW_REPORT.STATUS_CD, 요청 없으면 null)
    private String reportStatus;

    //지윤 26.07.21 추가: 유저 신고 정보 (REPORTER_TYPE='USER' 건수/신고자 목록)
    private Integer reportCount;
    private String reporterNames; // 쉼표로 구분된 신고자 닉네임 목록
}