package com.petcare.petcare.store.vo;

import java.util.Date;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import lombok.NoArgsConstructor;

// 상품 리뷰(TB_REVIEW) 조회용 VO
// 스토어 상품 리뷰 목록용 필드만 유지
@Getter @Setter
@ToString
@NoArgsConstructor
public class ReviewVO {
    private Long reviewId;
    private Long memberNo;
    private String nickname;
    private Double rating;
    private String content;
    private Date regDate;
    private String bizReply;
    private boolean blinded; // 사업자 삭제요청(PENDING) 걸린 리뷰인지
    private java.util.List<String> imageUrls; // 리뷰 첨부 이미지 목록
}