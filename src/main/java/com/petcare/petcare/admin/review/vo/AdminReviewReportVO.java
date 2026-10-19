package com.petcare.petcare.admin.review.vo;

import java.util.Date;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class AdminReviewReportVO {

    // TB_REVIEW_REPORT (고객 리뷰 신고)

    private Long reportId;        // REPORT_ID — 신고 번호
    private Long reviewId;        // REVIEW_ID — 신고된 리뷰 (리뷰 삭제 후 NULL)
    private Long bizNo;           // BIZ_NO — 리뷰 대상 사업자
    private String reason;        // REASON — 신고 사유
    private String statusCd;      // STATUS_CD — PENDING/DELETED/REJECTED/CLOSED
    private String rejectReason;  // REJECT_REASON — 관리자 반려 사유
    private Date regDate;         // REG_DATE — 신고일
    private Date processDate;     // PROCESS_DATE — 처리일

    // 조회 전용 (JOIN)

    private String reporterNickname; // 신고자 닉네임
    private String reviewType;       // R.REVIEW_TYPE — PRODUCT/HOSPITAL/STAY
    private Long targetId;           // R.TARGET_ID — 상품/병원/숙소 ID (평점 갱신용)
    private Double reviewRating;     // R.RATING
    private String reviewContent;    // R.CONTENT
    private String reviewerNickname; // 리뷰 작성자 닉네임
    private String targetName;       // 상품/병원/숙소명
    private String bizName;          // B.BIZ_NAME
}
