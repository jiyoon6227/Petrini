/**
 * 역할: CommunityReportService 구현체 (@Service)
 *
 * - 박유정 / 2026-07-10
 *
 * [insertPostReport]
 * 1. 로그인·사유 검증
 * 2. 본인 글 신고 불가 / 중복 대기 신고 불가
 * 3. TB_POST_REPORT INSERT (STATUS_CD = PENDING)
 */

package com.petcare.petcare.community.report.service;

import org.springframework.stereotype.Service;

import com.petcare.petcare.community.post.mapper.CommunityPostMapper;
import com.petcare.petcare.community.post.vo.CommunityPostVO;
import com.petcare.petcare.community.report.mapper.CommunityReportMapper;
import com.petcare.petcare.community.report.vo.CommunityReportVO;
import com.petcare.petcare.member.vo.MemberVO;

@Service
public class CommunityReportServiceImpl implements CommunityReportService {

    private final CommunityReportMapper communityReportMapper;
    private final CommunityPostMapper communityPostMapper;

    public CommunityReportServiceImpl(
            CommunityReportMapper communityReportMapper,
            CommunityPostMapper communityPostMapper) {
        this.communityReportMapper = communityReportMapper;
        this.communityPostMapper = communityPostMapper;
    }

    @Override
    public void insertPostReport(long postId, String reasonCd, String reasonDetail, MemberVO loginMember) {
        if (loginMember == null) {
            throw new IllegalStateException("LOGIN_REQUIRED");
        }
        if (reasonCd == null || reasonCd.isBlank()) {
            throw new IllegalArgumentException("EMPTY_REASON");
        }

        String normalizedReason = reasonCd.trim().toUpperCase();
        if (!normalizedReason.equals("SPAM")
                && !normalizedReason.equals("ABUSE")
                && !normalizedReason.equals("ETC")) {
            throw new IllegalArgumentException("INVALID_REASON");
        }

        Long memberNo = lookupMemberNo(loginMember);
        if (memberNo == null) {
            throw new IllegalStateException("MEMBER_NOT_FOUND");
        }

        CommunityPostVO post = communityPostMapper.selectPostDetail(postId);
        if (post == null) {
            throw new IllegalArgumentException("POST_NOT_FOUND");
        }
        if (post.getMemberNo() != null && post.getMemberNo().equals(memberNo)) {
            throw new IllegalStateException("SELF_REPORT");
        }

        if (communityReportMapper.countPendingByPostAndMember(postId, memberNo) > 0) {
            throw new IllegalStateException("DUPLICATE_REPORT");
        }

        CommunityReportVO vo = new CommunityReportVO();
        vo.setPostId(postId);
        vo.setMemberNo(memberNo);
        // 2026/07/11 장우철 — TB_POST_REPORT.REASON(VARCHAR2)에 사유코드(+상세) 저장
        // [변경 전] REASON_CD / REASON_DETAIL 컬럼 가정 → 실제 DB에는 REASON 만 존재
        if (reasonDetail != null && !reasonDetail.isBlank()) {
            String detail = reasonDetail.trim();
            if (detail.length() > 150) {
                detail = detail.substring(0, 150);
            }
            vo.setReasonCd(normalizedReason + ": " + detail);
        } else {
            vo.setReasonCd(normalizedReason);
        }
        vo.setStatusCd("PENDING");

        communityReportMapper.insertReport(vo);
    }

    private Long lookupMemberNo(MemberVO loginMember) {
        if (loginMember.getMemberId() != null && !loginMember.getMemberId().isBlank()) {
            Long no = communityReportMapper.selectMemberNoByMemberId(loginMember.getMemberId().trim());
            if (no != null) {
                return no;
            }
        }
        if (loginMember.getEmail() != null && !loginMember.getEmail().isBlank()) {
            Long no = communityReportMapper.selectMemberNoByEmail(loginMember.getEmail().trim());
            if (no != null) {
                return no;
            }
        }
        if (loginMember.getMemberNo() != null) {
            return loginMember.getMemberNo();
        }
        return null;
    }
}
