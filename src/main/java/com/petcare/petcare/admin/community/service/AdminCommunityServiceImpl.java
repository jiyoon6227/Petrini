/**
 * 역할: AdminCommunityService 구현체 (@Service)
 *
 * 구현 내용
 * - Controller에서 넘어온 요청 처리
 * - Mapper 호출하여 DB 조회·수정
 * - 비즈니스 규칙 검증 및 결과 반환
 *
 * 연결
 * - implements: AdminCommunityService
 * - 사용: AdminCommunityMapper
 *
 * 비즈니스 로직은 여기에 작성 (Controller, Mapper에 직접 작성 X)
 */

package com.petcare.petcare.admin.community.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.admin.community.mapper.AdminCommunityMapper;
import com.petcare.petcare.community.post.vo.CommunityPostVO;

import com.petcare.petcare.community.comment.mapper.CommunityCommentMapper;
import com.petcare.petcare.community.comment.service.CommunityCommentService;
import com.petcare.petcare.community.post.mapper.CommunityPostMapper;
import com.petcare.petcare.community.post.service.CommunityPostService;
import com.petcare.petcare.mypage.notify.service.MypageNotifyService;

@Service
public class AdminCommunityServiceImpl implements AdminCommunityService {

    private final AdminCommunityMapper adminCommunityMapper;
    private final CommunityPostMapper communityPostMapper;
    private final CommunityCommentMapper communityCommentMapper;
    private final CommunityPostService communityPostService;
    private final CommunityCommentService communityCommentService;
    private final MypageNotifyService mypageNotifyService;

    private static final int PAGE_SIZE = 10;

    public AdminCommunityServiceImpl(AdminCommunityMapper adminCommunityMapper,
                                     CommunityPostMapper communityPostMapper,
                                     CommunityCommentMapper communityCommentMapper,
                                     CommunityPostService communityPostService,
                                     CommunityCommentService communityCommentService,
                                     MypageNotifyService mypageNotifyService) {

        this.adminCommunityMapper = adminCommunityMapper;
        this.communityPostMapper = communityPostMapper;
        this.communityCommentMapper = communityCommentMapper;
        this.communityPostService = communityPostService;
        this.communityCommentService = communityCommentService;
        this.mypageNotifyService = mypageNotifyService;
    }

    // 2026-07-15 박유정 — 관리자 게시글 목록 (검색·필터·페이징)
    @Override
    public List<CommunityPostVO> getAdminPostList(String keyword, String boardType, String statusCd, int page) {
        int safePage = page < 1 ? 1 : page;
        int offset = (safePage - 1) * PAGE_SIZE;
        return adminCommunityMapper.selectAdminPostList(keyword, boardType, statusCd, offset, PAGE_SIZE);
    }

    // 2026-07-15 박유정 — 목록 총 건수
    @Override
    public int getAdminPostCount(String keyword, String boardType, String statusCd) {
        return adminCommunityMapper.selectAdminPostCount(keyword, boardType, statusCd);
    }

    // 2026-07-15 박유정 — 관리자 상세 (댓글 수·첨부 이미지 포함)
    @Override
    public CommunityPostVO getAdminPostDetail(long postId) {
        CommunityPostVO post = adminCommunityMapper.selectAdminPostDetail(postId);
        if (post == null) {
            return null;
        }
        post.setCommentCount(communityCommentMapper.selectCommentCountByPostId(postId));
        post.setPhotoUrls(communityPostMapper.selectFileUrlsByPostId(postId));
        return post;
    }

    // 2026/08/07 장우철 — 관리자 상세 댓글 (대댓글 포함, 읽기 전용)
    @Override
    public List<com.petcare.petcare.community.comment.vo.CommunityCommentVO> getPostComments(long postId) {
        return communityCommentService.getCommentList(postId);
    }

    //2026/08/06 장우철 — 게시글 신고 내역
    @Override
    public List<com.petcare.petcare.community.report.vo.CommunityReportVO> getPostReports(long postId) {
        return adminCommunityMapper.selectReportsByPostId(postId);
    }

    //2026/08/06 장우철 — 대기 신고 일괄 기각
    @Override
    @Transactional
    public int dismissPendingReports(long postId, Long adminNo) {
        CommunityPostVO post = adminCommunityMapper.selectAdminPostDetail(postId);
        if (post == null) {
            throw new IllegalArgumentException("POST_NOT_FOUND");
        }
        return adminCommunityMapper.dismissPendingReports(postId, adminNo);
    }

    // 2026-07-15 박유정 STEP 7 — 숨김 (STATUS_CD = HIDDEN)
    @Override
    public void hidePost(long postId) {
        CommunityPostVO existing = communityPostMapper.selectPostDetail(postId);
        int updated = adminCommunityMapper.updatePostStatus(postId, "HIDDEN");
        if (updated == 0) {
            throw new IllegalArgumentException("POST_NOT_FOUND");
        }
        // 2026/08/07 장우철 — 신고 조치(숨김) → 작성자 알림
        if (existing != null && existing.getMemberNo() != null) {
            try {
                mypageNotifyService.sendCommunityPostHiddenNotification(
                        existing.getMemberNo(), existing.getTitle(), postId);
            } catch (Exception ignored) {
            }
        }
    }

    // 2026-07-15 박유정 STEP 7 — 삭제 (STATUS_CD = DELETED)
    // 2026/08/03 장우철 — LIFE: soft 삭제만 (댓글·사진은 7일 후 purge). TOWN/SHARE: 즉시 물리 삭제
    @Override
    @Transactional
    public void deletePost(long postId) {
        CommunityPostVO existing = communityPostMapper.selectPostDetail(postId);
        if (existing == null) {
            throw new IllegalArgumentException("POST_NOT_FOUND");
        }

        boolean isLife = existing.getBoardType() != null
                && "LIFE".equalsIgnoreCase(existing.getBoardType().trim());
        if (isLife) {
            int updated = adminCommunityMapper.updatePostStatus(postId, "DELETED");
            if (updated == 0) {
                throw new IllegalArgumentException("POST_NOT_FOUND");
            }
            notifyAuthorPostDeleted(existing);
            return;
        }

        Long authorNo = existing.getMemberNo();
        if (authorNo == null) {
            throw new IllegalStateException("DELETE_FAILED");
        }
        communityPostMapper.deleteReportsByPostId(postId);
        communityPostMapper.deleteLikesByPostId(postId);
        communityCommentService.hardDeleteCommentsByPostId(postId);
        communityPostService.deletePhotosByPostId(postId);
        int result = communityPostMapper.hardDeletePostByUser(postId, authorNo);
        if (result == 0) {
            throw new IllegalStateException("DELETE_FAILED");
        }
        notifyAuthorPostDeleted(existing);
    }

    @Override
    @Transactional
    public void deletePost(long postId, long memberNo) {
        CommunityPostVO existing = communityPostMapper.selectPostDetail(postId);
        if (existing == null) {
            throw new IllegalArgumentException("POST_NOT_FOUND");
        }

        boolean isLife = existing.getBoardType() != null
                && "LIFE".equalsIgnoreCase(existing.getBoardType().trim());
        int result;
        if (isLife) {
            // LIFE — STATUS_CD='DELETED' + DELETE_DATE, 댓글·사진은 7일 후 스케줄러 정리
            result = communityPostMapper.softDeletePostByUser(postId, memberNo);
        } else {
            // TOWN, SHARE — 즉시 물리 삭제
            communityPostMapper.deleteReportsByPostId(postId);
            communityPostMapper.deleteLikesByPostId(postId);
            communityCommentService.hardDeleteCommentsByPostId(postId);
            communityPostService.deletePhotosByPostId(postId);
            result = communityPostMapper.hardDeletePostByUser(postId, memberNo);
        }

        if (result == 0) {
            throw new IllegalStateException("DELETE_FAILED");
        }

        adminCommunityMapper.updateMemberAdminPostDelCount(memberNo);
        // 2026/08/07 장우철 — 신고 조치(삭제) → 작성자 알림
        notifyAuthorPostDeleted(existing);
    }

    /** 2026/08/07 장우철 — 관리자 삭제 조치 알림 */
    private void notifyAuthorPostDeleted(CommunityPostVO existing) {
        if (existing == null || existing.getMemberNo() == null) {
            return;
        }
        try {
            mypageNotifyService.sendCommunityPostDeletedNotification(
                    existing.getMemberNo(), existing.getTitle());
        } catch (Exception ignored) {
        }
    }

    // 2026-07-15 박유정 — 복구 (STATUS_CD = ACTIVE)
    @Override
    public void restorePost(long postId) {
        int updated = adminCommunityMapper.updatePostStatus(postId, "ACTIVE");
        if (updated == 0) {
            throw new IllegalArgumentException("POST_NOT_FOUND");
        }
    }
}