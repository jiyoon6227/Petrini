/**
 * 역할: 게시글 댓글 DB 접근 (MyBatis interface)
 *
 * - 박유정 / 2026-07-09~10
 *
 * 쿼리
 * - selectAllCommentsByPostId   일반 + 대댓글 전체
 * - selectCommentById         부모 댓글 검증
 * - selectCommentCountByPostId 댓글 총 개수
 * - insertComment             PARENT_ID 포함 INSERT
 * - softDeleteComment         IS_DELETED='Y'
 * - updateCommentBody         BODY 수정 (작성자 본인) — 2026-07-14
 *
 * XML: resources/mybatis/mapper/community/comment/CommunityCommentMapper.xml
 *
 * 참고 테이블
 * - TB_POST_COMMENT
 */

package com.petcare.petcare.community.comment.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.community.comment.vo.CommunityCommentVO;

@Mapper
public interface CommunityCommentMapper {

    // 게시글 일반댓글만 (PARENT_ID IS NULL)
    List<CommunityCommentVO> selectCommentList(long postId);

    // 게시글 대댓글만 (PARENT_ID IS NOT NULL)
    List<CommunityCommentVO> selectRepliesByPostId(long postId);

    // 게시글 전체 댓글 (일반 + 대댓글) — Service 에서 parentId 로 묶음
    List<CommunityCommentVO> selectAllCommentsByPostId(long postId);

    // 대댓글 등록 시 부모 댓글 검증용
    CommunityCommentVO selectCommentById(long commentId);

    int selectCommentCountByPostId(long postId);

    int insertComment(CommunityCommentVO vo);
    int updateMemberCommentCount(String memberId);

    Long selectMemberNoByMemberId(String memberId);

    Long selectMemberNoByEmail(String email);

    int softDeleteComment(long commentId);

    //HYJ 26.07.28 댓글삭제
    int hardDeleteComment(long commentId);

    // 2026-07-23 HYJ — 게시글 삭제 시 댓글 일괄 소프트 삭제 (LIFE)
    int softDeleteCommentsByPostId(long postId);

    // 2026-07-23 HYJ — 게시글 삭제 시 댓글 일괄 물리 삭제 (TOWN/SHARE)
    int hardDeleteCommentsByPostId(long postId);

    int updateCommentBody(@Param("commentId") long commentId, @Param("body") String body);
}
