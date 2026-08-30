package com.petcare.petcare.main.section.vo;

import lombok.Getter;
import lombok.Setter;
/*
 * 2026/07/06 장우철 생성
 * 메인페이지 커뮤니티 미리보기 데이터
 */
@Getter
@Setter
public class MainCommunityPreviewVO {

    private Long postId;
    private String title;
    private String bodyPreview;
    private String nickname;
    private String regDateLabel;
    private int commentCount;
    private String thumbUrl;           // FILE_URL — 목록 썸네일, TB_FILE 첫 사진
}
