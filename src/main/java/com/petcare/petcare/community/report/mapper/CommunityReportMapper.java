/**
 * 역할: 커뮤니티 게시글 신고 DB 접근 (MyBatis interface)
 *
 * - 박유정 / 2026-07-10
 *
 * XML: resources/mybatis/mapper/community/report/CommunityReportMapper.xml
 *
 * 참고 테이블
 * - TB_POST_REPORT (SEQ_TB_POST_REPORT)
 */

package com.petcare.petcare.community.report.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.community.report.vo.CommunityReportVO;

@Mapper
public interface CommunityReportMapper {

    int insertReport(CommunityReportVO vo);

    int countPendingByPostAndMember(@Param("postId") long postId, @Param("memberNo") long memberNo);

    Long selectMemberNoByMemberId(String memberId);

    Long selectMemberNoByEmail(String email);
}
