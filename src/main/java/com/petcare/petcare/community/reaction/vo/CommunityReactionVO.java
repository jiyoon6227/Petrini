package com.petcare.petcare.community.reaction.vo;

import java.time.LocalDateTime;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CommunityReactionVO {

    private Long likeId;           // LIKE_ID — 좋아요 ID
    private Long postId;           // POST_ID — 게시글 ID
    private Long memberNo;         // MEMBER_NO — 좋아요 누른 회원번호
    private LocalDateTime regDate; // REG_DATE — 등록일
}
