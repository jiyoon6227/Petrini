package com.petcare.petcare.community.report.service;

import com.petcare.petcare.member.vo.MemberVO;

public interface CommunityReportService {

    void insertPostReport(long postId, String reasonCd, String reasonDetail, MemberVO loginMember);
}
