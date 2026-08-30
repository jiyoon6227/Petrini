/**
 * 역할: 관리자 커뮤니티 DB 접근 (MyBatis interface)
 *
 * XML: resources/mybatis/mapper/admin/community/AdminCommunityMapper.xml
 * namespace: com.petcare.petcare.admin.community.mapper.AdminCommunityMapper
 *
 * 쿼리 예시
 * - selectPostList
 * - selectPostDetail
 * - updatePostStatus
 * - deletePost
 *
 * 참고 테이블
 * - TB_POST
 * - TB_POST_REPORT
 *
 * SQL은 XML에만 작성 (@Select 등 어노테이션 사용 X)
 * 메서드명은 Service에서 호출하는 이름과 동일하게
 */

package com.petcare.petcare.admin.community.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import com.petcare.petcare.community.post.vo.CommunityPostVO;


@Mapper
public interface AdminCommunityMapper {

    // 2026-07-15 박유정 — 관리자 게시글 목록 (전체 상태 + 신고 건수)
    List<CommunityPostVO> selectAdminPostList(
            @Param("keyword") String keyword,
            @Param("boardType") String boardType,
            @Param("statusCd") String statusCd,
            @Param("offset") int offset,
            @Param("limit") int limit);

    // 2026-07-15 박유정 — 목록 총 건수 (검색·필터 동일 조건)
    int selectAdminPostCount(
            @Param("keyword") String keyword,
            @Param("boardType") String boardType,
            @Param("statusCd") String statusCd);

    // 2026-07-15 박유정 — 관리자 게시글 상세
    CommunityPostVO selectAdminPostDetail(@Param("postId") long postId);

    //2026/08/06 장우철 — 관리자 신고 목록/기각
    java.util.List<com.petcare.petcare.community.report.vo.CommunityReportVO> selectReportsByPostId(
            @Param("postId") long postId);
    int dismissPendingReports(@Param("postId") long postId, @Param("adminNo") Long adminNo);

    // 2026-07-15 박유정 STEP 7 — 상태 변경 (숨김/삭제/복구)
    int updatePostStatus(@Param("postId") long postId,
    @Param("statusCd") String statusCd);

    //HYJ 26.07.28 관리자 게시글 삭제회수 반영
    int updateMemberAdminPostDelCount(@Param("memberNo") long memberNo);
    //HYJ 26.07.28 관리자 댓글 삭제회수 반영
    int updateMemberAdminCommentDelCount(@Param("memberNo") long memberNo);
}
