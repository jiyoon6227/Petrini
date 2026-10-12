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
