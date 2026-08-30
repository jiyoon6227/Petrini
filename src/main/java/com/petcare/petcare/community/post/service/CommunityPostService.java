/**
 * 역할: 커뮤니티 게시글 비즈니스 로직 (interface)
 *
 * - 박유정 / 2026-07-08~10
 *
 * [markLifeAnswered — LIFE 답변완료] 2026-07-10 STEP 4
 * - 일반 댓글 등록 시 TAGS = ANSWERED (Controller 에서 호출)
 *
 * 담당 화면
 * - community/list.jsp        게시글 목록 (탭·검색·페이징)
 * - community/detail.jsp      게시글 상세 (조회수·좋아요·댓글)
 * - community/write.jsp       게시글 작성
 *
 * 연결
 * - 구현: CommunityPostServiceImpl
 * - 호출: CommunityPostController
 * - DB: CommunityPostMapper
 *
 * 참고 테이블
 * - TB_POST (BOARD_TYPE = TOWN / SHARE / LIFE)
 * - TB_FILE (사진, REF_TYPE = 'POST')
 */

package com.petcare.petcare.community.post.service;

import java.util.List;
import com.petcare.petcare.community.post.vo.CommunityPostVO;
import org.springframework.web.multipart.MultipartFile;
import com.petcare.petcare.member.vo.MemberVO;

import java.util.List;
import org.springframework.web.multipart.MultipartFile;

public interface CommunityPostService {

    // 게시글 목록 (boardType, keyword, page, LIFE 필터: petSpecies, vetStatus)
    List<CommunityPostVO> getPostList(
            String boardType, String keyword, int page, String petSpecies, String vetStatus);

    int getPostCount(String boardType, String keyword, String petSpecies, String vetStatus);

    int getTotalPages(String boardType, String keyword, String petSpecies, String vetStatus);

    // 게시글 상세 1건 (TB_POST + 사진 URL 목록)
    CommunityPostVO getPostDetail(long postId);

    //HYJ 26.08.04 게시물 수정용
    CommunityPostVO getPostDetailForEdit(long postId);

    // 게시글 등록 (TB_POST + 사진 TB_FILE)
    void insertPost(CommunityPostVO vo, MemberVO loginMember, MultipartFile[] photos);

    // LIFE 상담 — 답변 완료 (TAGS = ANSWERED) / 2026-07-10 STEP 4
    void markLifeAnswered(long postId);

    // 2026-07-23 HYJ — 게시글 수정 (본인 글만)
    // 2026-08-13 박유정 — 수정 시 사진 삭제·추가
    void updatePost(CommunityPostVO vo, MemberVO loginMember,
                    MultipartFile[] photos, List<String> removePhotoUrls);

    // 2026-07-23 HYJ — 게시글 삭제 (LIFE: STATUS_CD='DELETED' / TOWN·SHARE: 즉시 물리 삭제)
    void deletePost(long postId, MemberVO loginMember);

    // 2026-07-23 HYJ — LIFE 7일 경과 DELETED 게시글 물리 삭제 (스케줄러)
    int purgeExpiredDeletedPosts(int days);

    // 2026/07/22 장우철 — 글 사진 물리 삭제(로컬/GCS) + TB_FILE 삭제 (관리자 글 삭제 시)
    void deletePhotosByPostId(long postId);
}
