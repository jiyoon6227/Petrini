/**
 * 역할: 게시글 댓글 비즈니스 로직 (interface)
 *
 * - 박유정 / 2026-07-09~10
 *
 * [getCommentList]
 * - 일반댓글 목록 + 각 댓글의 replies(대댓글)
 *
 * [insertComment]
 * - parentId null → 일반댓글
 * - parentId 있음 → 대댓글 (PARENT_ID INSERT)
 *
 * [deleteComment]
 * - 작성자 본인 → IS_DELETED='Y'
 *
 * [updateComment]
 * - 작성자 본인 → BODY UPDATE
 *
 * [getFirstTopComment] 2026-07-10 STEP 4
 * - LIFE 목록 vet-answer 미리보기용 첫 일반댓글 1건
 *
 * 담당 화면
 * - community/detail.jsp      커뮤니티 게시글 상세 댓글
 * - give/report/detail.jsp   분실·보호 신고 상세 댓글
 *
 * 참고 테이블
 * - TB_POST_COMMENT
 */

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

    // LIFE 목록 vet-answer — 첫 일반댓글 1건 / 2026-07-10 STEP 4
    CommunityCommentVO getFirstTopComment(long postId);

    // 2026-07-23 HYJ — 게시글 삭제 시 댓글 일괄 소프트 삭제 (LIFE)
    void softDeleteCommentsByPostId(long postId);

    // 2026-07-23 HYJ — 게시글 삭제 시 댓글 일괄 물리 삭제 (TOWN/SHARE)
    void hardDeleteCommentsByPostId(long postId);
}
