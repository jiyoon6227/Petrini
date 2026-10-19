package com.petcare.petcare.admin.review.vo;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AdminReviewDeleteRequestVO {

    // TB_REVIEW_DELETE_REQUEST

    private Long requestId;       // REQUEST_ID — 요청 번호
    private Long reviewId;        // REVIEW_ID — 대상 리뷰 번호
    private String reviewType;    // REVIEW_TYPE — 리뷰 유형 (HOSPITAL/STAY/PRODUCT)
    private Long targetId;        // TARGET_ID — 병원/숙소/상품 ID
    private Long bizNo;           // BIZ_NO — 요청 사업자 번호
    private String requestReason; // REQUEST_REASON — 삭제 요청 사유
    private String statusCd;      // STATUS_CD — 처리 상태 (PENDING/APPROVED/REJECTED/CANCELED)
    private Date reqDate;         // REQ_DATE — 요청일
    private Long adminNo;         // ADMIN_NO — 처리 관리자 번호
    private Date processDate;     // PROCESS_DATE — 처리일
    private String rejectReason;  // REJECT_REASON — 관리자 반려 사유

    // 조회 전용 (JOIN)

    private String hospitalName;     // 대상명 — 병원/숙소/상품명
    private String bizName;          // B.BIZ_NAME — 사업자명
    private Double reviewRating;     // R.RATING — 리뷰 평점
    private String reviewContent;    // R.CONTENT — 리뷰 내용
    private String reviewerNickname; // M.NICKNAME — 리뷰 작성자 닉네임
    private Date reviewRegDate;      // R.REG_DATE — 리뷰 작성일

    // 이 리뷰에 걸린 고객 신고 (건수 + 펼치기용 목록)
    private Integer reportCount;
    private List<AdminReviewReportVO> reports = new ArrayList<>();
}
