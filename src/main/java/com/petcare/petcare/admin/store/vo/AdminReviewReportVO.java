package com.petcare.petcare.admin.store.vo;

import java.util.Date;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class AdminReviewReportVO {

    private Long reportId;
    private Long reviewId;
    private String reason;      // 사업자가 입력한 삭제 사유
    private Date regDate;       // 요청 접수일

    // 조회용 조인
    private Long bizNo;
    private String bizName;     // TB_BUSINESS.BIZ_NAME
    private String productName;
    private String content;     // 원본 리뷰 내용
    private Double rating;
    private String nickname;    // 리뷰 작성자
}