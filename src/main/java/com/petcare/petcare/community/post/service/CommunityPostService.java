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

    // 게시물 수정용
    CommunityPostVO getPostDetailForEdit(long postId);

    // 게시글 등록 (TB_POST + 사진 TB_FILE)
    void insertPost(CommunityPostVO vo, MemberVO loginMember, MultipartFile[] photos);

    // LIFE 상담 — 답변 완료 (TAGS = ANSWERED)
    void markLifeAnswered(long postId);

    // 게시글 수정 (본인 글만)
    // 수정 시 사진 삭제·추가
    void updatePost(CommunityPostVO vo, MemberVO loginMember,
                    MultipartFile[] photos, List<String> removePhotoUrls);

    // 게시글 삭제 (LIFE: STATUS_CD='DELETED' / TOWN·SHARE: 즉시 물리 삭제)
    void deletePost(long postId, MemberVO loginMember);

    // LIFE 7일 경과 DELETED 게시글 물리 삭제 (스케줄러)
    int purgeExpiredDeletedPosts(int days);

    // 글 사진 물리 삭제(로컬/GCS) + TB_FILE 삭제 (관리자 글 삭제 시)
    void deletePhotosByPostId(long postId);
}
