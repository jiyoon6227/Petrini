/**
 * 역할: CommunityReactionService 구현체 (@Service)
 *
 * - 박유정 / 2026-07-09
 *
 * [isLiked — 좋아요 여부 조회]
 * 1. TB_POST_LIKE 에 해당 postId + memberNo 존재 여부 확인
 * 2. DB 실패 시 세션 폴백 (communityLikedPosts:{memberNo})
 *
 * [toggleLike — 좋아요 토글]
 * 1. 로그인 + MEMBER_NO 확인
 * 2. 이미 좋아요 → DELETE + LIKE_CNT -1
 * 3. 미좋아요 → INSERT + LIKE_CNT +1
 * 4. DB 실패 시 세션 Set 으로 폴백 (LIKE_CNT 는 DB 갱신)
 *
 * 참고 테이블
 * - TB_POST_LIKE (SEQ_TB_POST_LIKE)
 * - TB_POST.LIKE_CNT
 */

package com.petcare.petcare.community.reaction.service;

import java.util.HashSet;
import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.community.post.mapper.CommunityPostMapper;
import com.petcare.petcare.community.post.vo.CommunityPostVO;
import com.petcare.petcare.community.reaction.mapper.CommunityReactionMapper;
import com.petcare.petcare.community.reaction.vo.CommunityLikeToggleResult;
import com.petcare.petcare.community.reaction.vo.CommunityReactionVO;
import com.petcare.petcare.member.vo.MemberVO;

import jakarta.servlet.http.HttpSession;

@Service
public class CommunityReactionServiceImpl implements CommunityReactionService {

    private static final Logger log = LoggerFactory.getLogger(CommunityReactionServiceImpl.class);

    private final CommunityReactionMapper communityReactionMapper;
    private final CommunityPostMapper communityPostMapper;

    public CommunityReactionServiceImpl(
            CommunityReactionMapper communityReactionMapper,
            CommunityPostMapper communityPostMapper) {
        this.communityReactionMapper = communityReactionMapper;
        this.communityPostMapper = communityPostMapper;
    }

    @Override
    public boolean isLiked(long postId, MemberVO loginMember, HttpSession session) {
        Long memberNo = resolveMemberNo(loginMember);
        if (memberNo == null) {
            return false;
        }
        try {
            return communityReactionMapper.countLikeByPostAndMember(postId, memberNo) > 0;
        } catch (Exception e) {
            log.warn("like check fallback(session): postId={}, memberNo={}", postId, memberNo);
            return getSessionLikedPosts(session, memberNo).contains(postId);
        }
    }

    @Override
    @Transactional
    public CommunityLikeToggleResult toggleLike(long postId, MemberVO loginMember, HttpSession session) {
        if (loginMember == null) {
            throw new IllegalStateException("LOGIN_REQUIRED");
        }
        Long memberNo = resolveMemberNo(loginMember);
        if (memberNo == null) {
            throw new IllegalStateException("MEMBER_NOT_FOUND");
        }

        try {
            return toggleLikeInDb(postId, memberNo);
        } catch (Exception e) {
            log.warn("DB like toggle failed, using session fallback: {}", e.getMessage());
            return toggleLikeInSession(postId, memberNo, session);
        }
    }

    private CommunityLikeToggleResult toggleLikeInDb(long postId, long memberNo) {
        boolean liked;
        if (communityReactionMapper.countLikeByPostAndMember(postId, memberNo) > 0) {
            communityReactionMapper.deleteLikeByPostAndMember(postId, memberNo);
            communityPostMapper.decreaseLikeCnt(postId);
            liked = false;
        } else {
            CommunityReactionVO likeVo = new CommunityReactionVO();
            likeVo.setPostId(postId);
            likeVo.setMemberNo(memberNo);
            communityReactionMapper.insertLike(likeVo);
            communityPostMapper.increaseLikeCnt(postId);
            liked = true;
        }
        return new CommunityLikeToggleResult(liked, readLikeCnt(postId));
    }

    private CommunityLikeToggleResult toggleLikeInSession(long postId, long memberNo, HttpSession session) {
        Set<Long> likedPosts = getSessionLikedPosts(session, memberNo);
        boolean liked;
        if (likedPosts.contains(postId)) {
            likedPosts.remove(postId);
            communityPostMapper.decreaseLikeCnt(postId);
            liked = false;
        } else {
            likedPosts.add(postId);
            communityPostMapper.increaseLikeCnt(postId);
            liked = true;
        }
        session.setAttribute(sessionKey(memberNo), likedPosts);
        return new CommunityLikeToggleResult(liked, readLikeCnt(postId));
    }

    private int readLikeCnt(long postId) {
        CommunityPostVO post = communityPostMapper.selectPostDetail(postId);
        return post != null && post.getLikeCnt() != null ? post.getLikeCnt() : 0;
    }

    private String sessionKey(long memberNo) {
        return "communityLikedPosts:" + memberNo;
    }

    @SuppressWarnings("unchecked")
    private Set<Long> getSessionLikedPosts(HttpSession session, long memberNo) {
        if (session == null) {
            return new HashSet<>();
        }
        Object raw = session.getAttribute(sessionKey(memberNo));
        if (raw instanceof Set<?> set) {
            return (Set<Long>) set;
        }
        Set<Long> likedPosts = new HashSet<>();
        session.setAttribute(sessionKey(memberNo), likedPosts);
        return likedPosts;
    }

    private Long resolveMemberNo(MemberVO loginMember) {
        if (loginMember == null) {
            return null;
        }
        if (loginMember.getMemberNo() != null) {
            return loginMember.getMemberNo();
        }
        if (loginMember.getMemberId() != null && !loginMember.getMemberId().isBlank()) {
            Long no = communityPostMapper.selectMemberNoByMemberId(loginMember.getMemberId().trim());
            if (no != null) {
                return no;
            }
        }
        if (loginMember.getEmail() != null && !loginMember.getEmail().isBlank()) {
            return communityPostMapper.selectMemberNoByEmail(loginMember.getEmail().trim());
        }
        return null;
    }
}
