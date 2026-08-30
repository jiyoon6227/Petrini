/**
 * 역할: 게시글 댓글 데이터 객체
 *
 * - 박유정 / 2026-07-09
 *
 * 담당 화면
 * - community/detail.jsp      커뮤니티 게시글 상세 댓글
 * - give/report/detail.jsp   분실·보호 신고 상세 댓글
 *
 * 참고 테이블
 * - TB_POST_COMMENT
 */

package com.petcare.petcare.community.comment.vo;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CommunityCommentVO {

    private Long commentId;        // COMMENT_ID — 댓글 ID
    private Long postId;           // POST_ID — 게시글 ID
    private Long parentId;         // PARENT_ID — 부모 댓글 ID (일반댓글 null)
    private Long memberNo;         // MEMBER_NO — 작성자 회원번호
    private String body;           // BODY — 댓글 본문
    private String isDeleted;      // IS_DELETED — 삭제 여부 (Y/N)
    private LocalDateTime regDate; // REG_DATE — 등록일

    // JOIN TB_MEMBER — 화면 표시용
    private String nickname;       // NICKNAME — 작성자 닉네임
    //2026/08/06 장우철 — 댓글 아바타용 프로필 사진
    private String profileImgUrl;  // PROFILE_IMG_URL — TB_MEMBER

    // 대댓글 목록 — getCommentList() 에서 parentId 기준으로 묶음
    private List<CommunityCommentVO> replies = new ArrayList<>();  // (VO) — 대댓글 목록
}
