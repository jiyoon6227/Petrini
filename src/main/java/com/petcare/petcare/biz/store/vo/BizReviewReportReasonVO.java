package com.petcare.petcare.biz.store.vo;

import java.util.Date;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

// 사업자 리뷰관리에 보여줄 고객 신고 사유 (신고자 정보 없이 익명)
@Getter
@Setter
@NoArgsConstructor
public class BizReviewReportReasonVO {

    private Long reviewId;
    private String reason;
    private Date regDate;
}
