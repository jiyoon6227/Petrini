package com.petcare.petcare.admin.community.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import com.petcare.petcare.community.post.vo.CommunityPostVO;


@Mapper
public interface AdminCommunityMapper {

    // 관리자 게시글 목록 (전체 상태 + 신고 건수)
    List<CommunityPostVO> selectAdminPostList(
            @Param("keyword") String keyword,
            @Param("boardType") String boardType,
            @Param("statusCd") String statusCd,
            @Param("offset") int offset,
            @Param("limit") int limit);

    // 목록 총 건수 (검색·필터 동일 조건)
    int selectAdminPostCount(
            @Param("keyword") String keyword,
            @Param("boardType") String boardType,
            @Param("statusCd") String statusCd);

    // 관리자 게시글 상세
    CommunityPostVO selectAdminPostDetail(@Param("postId") long postId);

    // 관리자 신고 목록/기각
    java.util.List<com.petcare.petcare.community.report.vo.CommunityReportVO> selectReportsByPostId(
            @Param("postId") long postId);
    int dismissPendingReports(@Param("postId") long postId, @Param("adminNo") Long adminNo);

    // 상태 변경 (숨김/삭제/복구)
    int updatePostStatus(@Param("postId") long postId,
    @Param("statusCd") String statusCd);

    // 관리자 게시글 삭제회수 반영
    int updateMemberAdminPostDelCount(@Param("memberNo") long memberNo);
    // 관리자 댓글 삭제회수 반영
    int updateMemberAdminCommentDelCount(@Param("memberNo") long memberNo);
}
