/**
 * 역할: 커뮤니티 게시글 신고 비즈니스 로직 (interface)
 *
 * - 박유정 / 2026-07-10
 *
 * [insertPostReport]
 * - 로그인 회원이 게시글 신고 → TB_POST_REPORT INSERT (PENDING)
 *
 * 담당 화면
 * - community/detail.jsp
 *
 * 참고 테이블
 * - TB_POST_REPORT
 */

package com.petcare.petcare.community.report.service;

import com.petcare.petcare.member.vo.MemberVO;

public interface CommunityReportService {

    void insertPostReport(long postId, String reasonCd, String reasonDetail, MemberVO loginMember);
}
