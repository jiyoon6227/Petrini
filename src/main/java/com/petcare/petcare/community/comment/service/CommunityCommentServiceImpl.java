/**
 * 역할: CommunityCommentService 구현체 (@Service)
 *
 * - 박유정 / 2026-07-09~10
 *
 * [getCommentList — 댓글 목록]
 * 1. TB_POST_COMMENT 전체 조회 (일반 + 대댓글)
 * 2. PARENT_ID 가 null → 최상위 댓글, 나머지는 replies 에 묶음
 *
 * [insertComment — 댓글·대댓글 등록]
 * 1. 로그인 확인 + 본문 검증
 * 2. parentId 있으면 → 같은 글의 일반댓글인지 검증
 * 3. LIFE(수의사 상담) 권한 검증 — 병원 사업자 / 질문자 대댓글
 * 4. TB_POST_COMMENT INSERT (PARENT_ID)
 *
 * [deleteComment — 댓글 삭제]
 * 1. 작성자 본인 확인 (memberNo)
 * 2. softDeleteComment → IS_DELETED='Y' (대댓글은 유지, 화면은 '삭제된 댓글입니다')
 *
 * [updateComment — 댓글 수정] 2026-07-14
 * 1. 작성자 본인 확인 (memberNo)
 * 2. updateCommentBody → BODY 갱신
 *
 * [getFirstTopComment — LIFE 답변 미리보기] 2026-07-10 STEP 4
 * 1. selectCommentList → PARENT_ID IS NULL 첫 1건 반환
 */

package com.petcare.petcare.community.comment.service;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.admin.community.mapper.AdminCommunityMapper;
import com.petcare.petcare.community.comment.mapper.CommunityCommentMapper;
import com.petcare.petcare.community.comment.vo.CommunityCommentVO;
import com.petcare.petcare.community.post.mapper.CommunityPostMapper;
import com.petcare.petcare.community.post.vo.CommunityPostVO;
import com.petcare.petcare.member.vo.MemberVO;

@Service
public class CommunityCommentServiceImpl implements CommunityCommentService {

    private final CommunityCommentMapper communityCommentMapper;
    private final CommunityPostMapper communityPostMapper;
    private final AdminCommunityMapper adminCommunityMapper;

    public CommunityCommentServiceImpl(
            CommunityCommentMapper communityCommentMapper,
            CommunityPostMapper communityPostMapper,
            AdminCommunityMapper adminCommunityMapper) {
        this.communityCommentMapper = communityCommentMapper;
        this.communityPostMapper = communityPostMapper;
        this.adminCommunityMapper = adminCommunityMapper;
    }

    @Override
    public List<CommunityCommentVO> getCommentList(long postId) {
        List<CommunityCommentVO> parents = communityCommentMapper.selectCommentList(postId);
        List<CommunityCommentVO> replies = communityCommentMapper.selectRepliesByPostId(postId);

        Map<Long, CommunityCommentVO> parentMap = new LinkedHashMap<>();
        for (CommunityCommentVO comment : parents) {
            comment.setReplies(new ArrayList<>());
            if (comment.getCommentId() != null) {
                parentMap.put(comment.getCommentId(), comment);
            }
        }
        for (CommunityCommentVO reply : replies) {
            if (reply.getParentId() == null) {
                continue;
            }
            CommunityCommentVO parent = parentMap.get(reply.getParentId());
            if (parent != null) {
                parent.getReplies().add(reply);
            }
        }

        // 2026/08/03 장우철 — 삭제된 부모는 살아 있는 대댓글이 있을 때만 노출
        List<CommunityCommentVO> visible = new ArrayList<>();
        for (CommunityCommentVO parent : parents) {
            boolean parentDeleted = isDeleted(parent);
            boolean hasActiveReply = false;
            if (parent.getReplies() != null) {
                for (CommunityCommentVO reply : parent.getReplies()) {
                    if (!isDeleted(reply)) {
                        hasActiveReply = true;
                        break;
                    }
                }
            }
            if (!parentDeleted || hasActiveReply) {
                visible.add(parent);
            }
        }
        return visible;
    }

    @Override
    public int getCommentCount(long postId) {
        return communityCommentMapper.selectCommentCountByPostId(postId);
    }

    private boolean isDeleted(CommunityCommentVO comment) {
        return comment != null
                && comment.getIsDeleted() != null
                && "Y".equalsIgnoreCase(comment.getIsDeleted().trim());
    }

    @Override
    @Transactional
    public void insertComment(long postId, String body, MemberVO loginMember) {
        insertComment(postId, body, loginMember, null);
    }

    @Override
    @Transactional
    public void insertComment(long postId, String body, MemberVO loginMember, Long parentId) {
        if (loginMember == null) {
            throw new IllegalStateException("LOGIN_REQUIRED");
        }
        if (body == null || body.isBlank()) {
            throw new IllegalArgumentException("EMPTY_BODY");
        }

        Long memberNo = lookupMemberNo(loginMember);
        if (memberNo == null) {
            throw new IllegalStateException("MEMBER_NOT_FOUND");
        }

        if (parentId != null) {
            validateParentComment(postId, parentId);
        }

        // 2026/07/11 장우철 — 수의사 상담(LIFE) 댓글 권한
        // 병원 사업자: 댓글·대댓글 가능 / 질문자: 대댓글만 / 그 외: 불가
        validateLifeCommentPermission(postId, loginMember, memberNo, parentId);

        CommunityCommentVO vo = new CommunityCommentVO();
        vo.setPostId(postId);
        vo.setParentId(parentId);
        vo.setMemberNo(memberNo);
        vo.setBody(body.trim());

        int result = communityCommentMapper.insertComment(vo);
        
        //HYJ 26.07.28 댓글작성회수 반영
        if (result > 0) {
            communityCommentMapper.updateMemberCommentCount(loginMember.getMemberId());
        }
    }

    /**
     * 2026/07/11 장우철 — LIFE(수의사 상담) 댓글 권한 검증
     * - TOWN/SHARE 등: 제한 없음 (기존과 동일)
     * - LIFE + 병원 사업자(BIZ/HOSPITAL): 최상위 댓글·대댓글 모두 허용
     * - LIFE + 질문자(글 작성자): parentId 있는 대댓글만 허용 (추가 질문)
     * - LIFE + 그 외: LIFE_COMMENT_FORBIDDEN
     * 2026-08-13 박유정 — LOST(분실·보호) 등 selectPostDetail null이면 LIFE 규칙 스킵
     */
    private void validateLifeCommentPermission(
            long postId, MemberVO loginMember, Long memberNo, Long parentId) {
        CommunityPostVO post = communityPostMapper.selectPostDetail(postId);
        if (post == null) {
         // 2026-08-13 박유정 — LOST(분실·보호) 등 커뮤니티 외 게시글은 LIFE 규칙 미적용
            return;
        }
        if (post.getBoardType() == null || !"LIFE".equalsIgnoreCase(post.getBoardType().trim())) {
            return;
        }
        if (isHospitalBiz(loginMember)) {
            return;
        }
        boolean isAuthor = post.getMemberNo() != null && post.getMemberNo().equals(memberNo);
        if (parentId != null && isAuthor) {
            return;
        }
        throw new IllegalStateException("LIFE_COMMENT_FORBIDDEN");
    }

    /** 2026/07/11 장우철 — 승인된 병원 사업자 여부 (세션 role/bizType) */
    private boolean isHospitalBiz(MemberVO loginMember) {
        if (loginMember == null || loginMember.getRole() == null || loginMember.getBizType() == null) {
            return false;
        }
        return "BIZ".equalsIgnoreCase(loginMember.getRole().trim())
                && "HOSPITAL".equalsIgnoreCase(loginMember.getBizType().trim());
    }

    private void validateParentComment(long postId, long parentId) {
        CommunityCommentVO parent = communityCommentMapper.selectCommentById(parentId);
        if (parent == null || !Long.valueOf(postId).equals(parent.getPostId())) {
            throw new IllegalArgumentException("INVALID_PARENT");
        }
        if (parent.getParentId() != null) {
            throw new IllegalArgumentException("INVALID_PARENT");
        }
    }

    private Long lookupMemberNo(MemberVO loginMember) {
        // memberId / email 로 DB 조회 우선 (testUser 등 세션만 있는 경우 대비)
        if (loginMember.getMemberId() != null && !loginMember.getMemberId().isBlank()) {
            Long no = communityCommentMapper.selectMemberNoByMemberId(loginMember.getMemberId().trim());
            if (no != null) {
                return no;
            }
        }
        if (loginMember.getEmail() != null && !loginMember.getEmail().isBlank()) {
            Long no = communityCommentMapper.selectMemberNoByEmail(loginMember.getEmail().trim());
            if (no != null) {
                return no;
            }
        }
        if (loginMember.getMemberNo() != null) {
            return loginMember.getMemberNo();
        }
        return null;
    }

    @Override
    @Transactional
    public void deleteComment(long commentId, long postId, MemberVO loginMember) {
        if (loginMember == null) {
            throw new IllegalStateException("LOGIN_REQUIRED");
        }

        CommunityCommentVO comment = communityCommentMapper.selectCommentById(commentId);
        if (comment == null || !Long.valueOf(postId).equals(comment.getPostId())) {
            throw new IllegalArgumentException("COMMENT_NOT_FOUND");
        }
        if (isDeleted(comment)) {
            throw new IllegalArgumentException("COMMENT_ALREADY_DELETED");
        }

        Long loginMemberNo = lookupMemberNo(loginMember);
        if (loginMemberNo == null || !loginMemberNo.equals(comment.getMemberNo())) {
            //HYJ 26.07.28 관리자권한 통과
            if (!"ADMIN".equals(loginMember.getRole())){
                throw new IllegalStateException("FORBIDDEN");
            }
        }

        // 2026/08/03 장우철 — 게시판 공통 soft 삭제 (대댓글 유지, '삭제된 댓글입니다' 표시)
        int result = communityCommentMapper.softDeleteComment(commentId);
        if (result == 0) {
            throw new IllegalStateException("DELETE_FAILED");
        }

        if ("ADMIN".equals(loginMember.getRole())) {
            CommunityPostVO existing = communityPostMapper.selectPostDetail(postId);
            if (existing != null) {
                adminCommunityMapper.updateMemberAdminCommentDelCount(existing.getMemberNo());
            }
        }
    }

    // 2026-07-14 박유정 — 댓글 수정 (community/detail.jsp, give/report/detail.jsp)
    @Override
    public void updateComment(long commentId, long postId, String body, MemberVO loginMember) {
        if (loginMember == null) {
            throw new IllegalStateException("LOGIN_REQUIRED");
        }
        if (body == null || body.isBlank()) {
            throw new IllegalArgumentException("EMPTY_BODY");
        }

        CommunityCommentVO comment = communityCommentMapper.selectCommentById(commentId);
        if (comment == null || !Long.valueOf(postId).equals(comment.getPostId())) {
            throw new IllegalArgumentException("COMMENT_NOT_FOUND");
        }
        if (isDeleted(comment)) {
            throw new IllegalStateException("COMMENT_ALREADY_DELETED");
        }

        Long loginMemberNo = lookupMemberNo(loginMember);
        if (loginMemberNo == null || !loginMemberNo.equals(comment.getMemberNo())) {
            throw new IllegalStateException("FORBIDDEN");
        }

        communityCommentMapper.updateCommentBody(commentId, body.trim());
    }

    @Override
    public Long resolveLoginMemberNo(MemberVO loginMember) {
        if (loginMember == null) {
            return null;
        }
        return lookupMemberNo(loginMember);
    }

    @Override
    public CommunityCommentVO getFirstTopComment(long postId) {
        // LIFE + ANSWERED 목록 카드 vet-answer 용 / 2026-07-10 STEP 4
        List<CommunityCommentVO> parents = communityCommentMapper.selectCommentList(postId);
        if (parents == null || parents.isEmpty()) {
            return null;
        }
        return parents.get(0);
    }

    /**
     * 2026-07-23 HYJ — LIFE 게시글 삭제 시 댓글·대댓글 일괄 소프트 삭제
     * IS_DELETED='Y', DELETE_DATE=SYSDATE
     */
    @Override
    public void softDeleteCommentsByPostId(long postId) {
        communityCommentMapper.softDeleteCommentsByPostId(postId);
    }

    /**
     * 2026-07-23 HYJ — TOWN/SHARE 게시글 삭제 시 댓글·대댓글 일괄 물리 삭제
     */
    @Override
    public void hardDeleteCommentsByPostId(long postId) {
        communityCommentMapper.hardDeleteCommentsByPostId(postId);
    }
}

