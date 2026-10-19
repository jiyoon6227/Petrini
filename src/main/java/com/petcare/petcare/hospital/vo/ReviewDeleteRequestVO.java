package com.petcare.petcare.hospital.vo;

import java.util.Date;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReviewDeleteRequestVO {

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

    // 조회 전용 (LEFT JOIN, 승인 후 리뷰 삭제 시 null 가능)

    private String reviewerNickname; // M.NICKNAME — 리뷰 작성자 닉네임
    private Double reviewRating;     // R.RATING — 리뷰 평점
    private String reviewContent;    // R.CONTENT — 리뷰 내용
    private String targetName;       // 상품명 (쇼핑 삭제요청 이력, 병원·숙소는 null)
    private String thumbnailUrl;     // 상품 썸네일 (쇼핑 삭제요청 이력, 병원·숙소는 null)
}
