package com.petcare.petcare.stay.vo;

import java.util.Date;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class StayReviewVO {
    private Long reviewId;
    private Long targetId;
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
