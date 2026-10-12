package com.petcare.petcare.community.comment.service;

import java.util.List;

import com.petcare.petcare.community.comment.vo.CommunityCommentVO;
import com.petcare.petcare.member.vo.MemberVO;

public interface CommunityCommentService {

    List<CommunityCommentVO> getCommentList(long postId);

    int getCommentCount(long postId);

    void insertComment(long postId, String body, MemberVO loginMember);

    void insertComment(long postId, String body, MemberVO loginMember, Long parentId);

    void deleteComment(long commentId, long postId, MemberVO loginMember);

    void updateComment(long commentId, long postId, String body, MemberVO loginMember);

    // JSP 본인 댓글 버튼 표시용 — deleteComment 와 동일한 회원번호 조회
    Long resolveLoginMemberNo(MemberVO loginMember);

    // LIFE 목록 vet-answer — 첫 일반댓글 1건
    CommunityCommentVO getFirstTopComment(long postId);

    // 게시글 삭제 시 댓글 일괄 소프트 삭제 (LIFE)
    void softDeleteCommentsByPostId(long postId);

    // 게시글 삭제 시 댓글 일괄 물리 삭제 (TOWN/SHARE)
    void hardDeleteCommentsByPostId(long postId);
}
