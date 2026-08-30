/**
 * 역할: 커뮤니티 좋아요 비즈니스 로직 (interface)
 *
 * - 박유정 / 2026-07-09
 *
 * 담당 화면
 * - community/detail.jsp   좋아요 버튼 Ajax 토글
 *
 * 연결
 * - 구현: CommunityReactionServiceImpl
 * - 호출: CommunityReactionController, CommunityPostController (isLiked)
 * - DB: CommunityReactionMapper, CommunityPostMapper (LIKE_CNT)
 *
 * 참고 테이블
 * - TB_POST_LIKE
 * - TB_POST.LIKE_CNT
 */

package com.petcare.petcare.community.reaction.service;

import com.petcare.petcare.community.reaction.vo.CommunityLikeToggleResult;
import com.petcare.petcare.member.vo.MemberVO;

import jakarta.servlet.http.HttpSession;

public interface CommunityReactionService {

    // 상세 진입 시 — 현재 회원이 이 글에 좋아요 눌렀는지
    boolean isLiked(long postId, MemberVO loginMember, HttpSession session);

    // Ajax 토글 — TB_POST_LIKE INSERT/DELETE + LIKE_CNT 증감
    CommunityLikeToggleResult toggleLike(long postId, MemberVO loginMember, HttpSession session);
}
