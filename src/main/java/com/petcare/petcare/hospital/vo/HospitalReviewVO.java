/**
 * 역할: 병원 리뷰(TB_REVIEW, REVIEW_TYPE=HOSPITAL) 데이터 객체
 *
 * 2026/07/13 장우철 — 유저 리뷰 작성·병원 상세 리뷰 목록용
 */

package com.petcare.petcare.hospital.vo;

import java.util.Date;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class HospitalReviewVO {

    private Long reviewId;
    private Long targetId;       // HOSPITAL_ID
    private Long memberNo;
    private Long resvId;
    private Double rating;
    private String content;
    private String bizReply;
    private Date regDate;

    // 조회용 조인
    private String nickname;
    private String petName;
    private String petSpecies;
}
