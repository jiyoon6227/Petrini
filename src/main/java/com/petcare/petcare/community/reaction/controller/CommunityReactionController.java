/**
 * 역할: 커뮤니티 좋아요 Ajax API 처리
 *
 * - 박유정 / 2026-07-09
 *
 * [좋아요 토글 화면 흐름]
 * 1. detail.jsp 에서 fetch POST /community/like/toggle (postId)
 * 2. communityReactionService.toggleLike() 호출
 * 3. JSON { liked, likeCnt } 반환 → 버튼·숫자 갱신
 *
 * 연결
 * - Service: CommunityReactionService
 * - 화면: community/detail.jsp
 *
 * 참고 테이블
 * - TB_POST_LIKE, TB_POST.LIKE_CNT
 */

package com.petcare.petcare.community.reaction.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.petcare.petcare.community.reaction.service.CommunityReactionService;
import com.petcare.petcare.community.reaction.vo.CommunityLikeToggleResult;
import com.petcare.petcare.member.vo.MemberVO;

import jakarta.servlet.http.HttpSession;

@RestController
@RequestMapping("/community")
public class CommunityReactionController {

    private static final Logger log = LoggerFactory.getLogger(CommunityReactionController.class);

    private final CommunityReactionService communityReactionService;

    public CommunityReactionController(CommunityReactionService communityReactionService) {
        this.communityReactionService = communityReactionService;
    }

    /** 좋아요 토글 — Ajax POST, JSON 응답 */
    @PostMapping("/like/toggle")
    public ResponseEntity<?> toggleLike(
            @RequestParam long postId,
            HttpSession session) {
        MemberVO member = getMemberOrNull(session);
        try {
            CommunityLikeToggleResult result =
                    communityReactionService.toggleLike(postId, member, session);
            return ResponseEntity.ok(result);
        } catch (IllegalStateException e) {
            if ("LOGIN_REQUIRED".equals(e.getMessage())) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("LOGIN_REQUIRED");
            }
            if ("MEMBER_NOT_FOUND".equals(e.getMessage())) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("MEMBER_NOT_FOUND");
            }
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        } catch (Exception e) {
            log.error("like toggle failed: postId={}", postId, e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("LIKE_FAILED");
        }
    }

    private MemberVO getMemberOrNull(HttpSession session) {
        Object member = session.getAttribute("memberInfo");
        if (member instanceof MemberVO memberVO) {
            return memberVO;
        }
        return null;
    }
}
