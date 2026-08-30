/**
 * 역할: CommunityPostService 구현체 (@Service)
 *
 * - 박유정 / 2026-07-08~10
 * - 2026/07/22 장우철 — 사진 저장/삭제 gcs.enabled 분기 (로컬 ↔ GCS)
 *
 * [getPostList — 목록]
 * 1. boardType·keyword·page 로 TB_POST 조회 (5건/페이지)
 * 2. 각 글의 첫 사진 URL → thumbUrl
 * 3. LIFE + ANSWERED → 첫 일반댓글 답변 미리보기 (2026-07-10 STEP 4)
 *
 * [getPostDetail — 상세]
 * 1. increaseViewCount() → VIEW_COUNT +1
 * 2. TB_POST 1건 + photoUrls 목록
 *
 * [insertPost — 등록]
 * 1. 로그인 회원 → MEMBER_NO
 * 2. TB_POST INSERT (SEQ_TB_POST)
 * 3. 사진 저장(로컬 또는 GCS) + TB_FILE INSERT (최대 5장)
 * 4. LIFE 등록 시 TAGS = WAITING (2026-07-10)
 *
 * [deletePhotosByPostId — 글 사진 삭제] 2026/07/22 장우철
 * - 관리자 글 삭제 시 버킷/로컬 + TB_FILE 정리
 *
 * [markLifeAnswered — LIFE 답변완료] 2026-07-10 STEP 4
 * 1. BOARD_TYPE = LIFE 인지 확인
 * 2. updatePostTags(postId, "ANSWERED")
 *
 * 참고 테이블
 * - TB_POST, TB_FILE (REF_TYPE = 'POST')
 */

package com.petcare.petcare.community.post.service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.UUID;

import com.petcare.petcare.give.report.vo.GiveReportFileVO;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.google.cloud.storage.BlobId;
import com.google.cloud.storage.BlobInfo;
import com.google.cloud.storage.Storage;
import com.petcare.petcare.admin.community.mapper.AdminCommunityMapper;
import com.petcare.petcare.community.comment.service.CommunityCommentService;
import com.petcare.petcare.community.comment.vo.CommunityCommentVO;
import com.petcare.petcare.community.post.mapper.CommunityPostMapper;
import com.petcare.petcare.community.post.vo.CommunityPostVO;
import com.petcare.petcare.file.mapper.FileMapper;
import com.petcare.petcare.file.vo.FileVO;
import com.petcare.petcare.member.vo.MemberVO;

@Service
public class CommunityPostServiceImpl implements CommunityPostService {

    private final CommunityPostMapper communityPostMapper;
    private final CommunityCommentService communityCommentService;

    @Value("${file.upload-dir}")
    private String uploadDir;

    @Value("${gcs.enabled:false}")
    private boolean gcsEnabled;

    @Value("${gcs.bucket-name:}")
    private String gcsBucket;

    @Autowired(required = false)
    private Storage storage;

    @Autowired
    private FileMapper fileMapper;
    @Autowired
    private AdminCommunityMapper adminCommunityMapper;

    private static final int MAX_PHOTOS = 5;
    private static final int PAGE_SIZE = 5;

    public CommunityPostServiceImpl(
            CommunityPostMapper communityPostMapper,
            CommunityCommentService communityCommentService) {
        this.communityPostMapper = communityPostMapper;
        this.communityCommentService = communityCommentService;
    }

    @Override
    public List<CommunityPostVO> getPostList(
            String boardType, String keyword, int page, String petSpecies, String vetStatus) {
        String searchKeyword = normalizeKeyword(keyword);
        String species = normalizeLifeFilter(petSpecies);
        String status = normalizeVetStatus(vetStatus);
        int pageNo = Math.max(page, 1);
        int offset = (pageNo - 1) * PAGE_SIZE;
        List<CommunityPostVO> list = communityPostMapper.selectPostList(
                boardType, searchKeyword, species, status, offset, PAGE_SIZE);

        for (CommunityPostVO item : list) {
            List<String> urls = communityPostMapper.selectFileUrlsByPostId(item.getPostId());
            if (urls != null && !urls.isEmpty()) {
                item.setThumbUrl(urls.get(0));
            }
            attachLifeAnswerPreview(item);
        }
        return list;
    }

    @Override
    public int getPostCount(String boardType, String keyword, String petSpecies, String vetStatus) {
        return communityPostMapper.selectPostCount(
                boardType, normalizeKeyword(keyword), normalizeLifeFilter(petSpecies), normalizeVetStatus(vetStatus));
    }

    @Override
    public int getTotalPages(String boardType, String keyword, String petSpecies, String vetStatus) {
        int totalCount = getPostCount(boardType, keyword, petSpecies, vetStatus);
        if (totalCount == 0) {
            return 1;
        }
        return (int) Math.ceil(totalCount / (double) PAGE_SIZE);
    }

    private String normalizeLifeFilter(String value) {
        if (value == null || value.isBlank()) {
            return "";
        }
        return switch (value.trim().toUpperCase()) {
            case "DOG", "CAT", "ETC" -> value.trim().toUpperCase();
            default -> "";
        };
    }

    private String normalizeVetStatus(String value) {
        if (value == null || value.isBlank()) {
            return "";
        }
        return switch (value.trim().toUpperCase()) {
            case "WAITING", "ANSWERED" -> value.trim().toUpperCase();
            default -> "";
        };
    }

    private String normalizeKeyword(String keyword) {
        if (keyword == null) {
            return "";
        }
        return keyword.trim();
    }

    private void attachLifeAnswerPreview(CommunityPostVO item) {
        // LIFE 목록 — ANSWERED 글에 vet-answer 미리보기 데이터 첨부 / 2026-07-10 STEP 4
        if (item == null || item.getPostId() == null) {
            return;
        }
        if (!"LIFE".equalsIgnoreCase(item.getBoardType())) {
            return;
        }
        String tags = item.getTags();
        if (tags == null || !tags.contains("ANSWERED")) {
            return;
        }
        CommunityCommentVO answer = communityCommentService.getFirstTopComment(item.getPostId());
        if (answer == null) {
            return;
        }
        item.setAnswerBody(answer.getBody());
        item.setAnswerAuthor(answer.getNickname());
        item.setAnswerDate(answer.getRegDate());
    }

    @Override
    public CommunityPostVO getPostDetail(long postId) {
        CommunityPostVO post = communityPostMapper.selectPostDetail(postId);
        if (post == null) {
            return null;
        }
        communityPostMapper.increaseViewCount(postId);
        post.setPhotoUrls(communityPostMapper.selectFileUrlsByPostId(postId));
        return post;
    }

    //HYJ 26.08.04 게시물 수정용(조회수X)
    public CommunityPostVO getPostDetailForEdit(long postId) {
        CommunityPostVO post = communityPostMapper.selectPostDetail(postId);
        if (post == null) {
            return null;
        }
        post.setPhotoUrls(communityPostMapper.selectFileUrlsByPostId(postId));
        return post;
    }

    @Override
    @Transactional
    public void insertPost(CommunityPostVO vo, MemberVO loginMember, MultipartFile[] photos) {
        resolveMemberNo(vo, loginMember);

        vo.setStatusCd("ACTIVE");
        if (vo.getRegion() == null) {
            vo.setRegion("");
        }
        if (vo.getTags() == null) {
            vo.setTags("");
        }
        if (vo.getLostSpecies() == null) {
            vo.setLostSpecies("");
        }
        if (vo.getLostFeature() == null) {
            vo.setLostFeature("");
        }

        if ("LIFE".equalsIgnoreCase(vo.getBoardType())) {
            vo.setLostSpecies(normalizePetType(vo.getPetType()));
            vo.setLostFeature(buildPetFeature(vo.getBreed(), vo.getPetAge()));
            vo.setTags("WAITING");  // LIFE 상담 등록 시 답변대기 / 2026-07-10
        }

        int result = communityPostMapper.insertPost(vo);
        if (result > 0) {
            //HYJ 26.07.28 작성횟수 + 1
            communityPostMapper.updateMemberPostCount(loginMember.getMemberId());

            savePhotos(vo.getPostId(), photos);
        }
    }

    private String normalizePetType(String petType) {
        if (petType == null || petType.isBlank()) {
            return "";
        }
        return switch (petType.trim().toUpperCase()) {
            case "DOG", "CAT", "ETC" -> petType.trim().toUpperCase();
            default -> "";
        };
    }

    private String buildPetFeature(String breed, String petAge) {
        String b = breed == null ? "" : breed.trim();
        String a = petAge == null ? "" : petAge.trim();
        return b + "|" + a;
    }

    private void resolveMemberNo(CommunityPostVO vo, MemberVO loginMember) {
        if (loginMember == null) {
            throw new IllegalStateException("LOGIN_REQUIRED");
        }
        if (loginMember.getMemberNo() != null) {
            vo.setMemberNo(loginMember.getMemberNo());
            return;
        }
        Long memberNo = lookupMemberNo(loginMember);
        if (memberNo == null) {
            throw new IllegalStateException("MEMBER_NOT_FOUND");
        }
        vo.setMemberNo(memberNo);
    }

    private Long lookupMemberNo(MemberVO loginMember) {
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

    private void savePhotos(Long postId, MultipartFile[] photos) {
        savePhotos(postId, photos, MAX_PHOTOS);
    }

    // 2026-08-13 박유정 — 수정 시 남은 슬롯만큼만 저장
    private void savePhotos(Long postId, MultipartFile[] photos, int maxCount) {
        if (postId == null || photos == null || maxCount <= 0) {
            return;
        }

        int saved = 0;
        for (MultipartFile file : photos) {
            if (file == null || file.isEmpty()) {
                continue;
            }
            if (saved >= maxCount) {
                break;
            }

            String savedName = UUID.randomUUID() + resolveExtension(file.getOriginalFilename());
            // DB·JSP용 URL (앞에 /upload 유지) / GCS·로컬 실제 경로는 objectPath
            String objectPath = "community/post/" + postId + "/" + savedName;
            String fileUrl = "/upload/" + objectPath;

            if (gcsEnabled) {
                // [GCS 업로드 — gcs.enabled=true] 2026/07/22 장우철
                //#region구글 스토리지 GCS 전환코드 START
                if (storage == null) {
                    throw new IllegalStateException("GCS enabled but Storage bean is missing");
                }
                try {
                    String contentType = file.getContentType();
                    if (contentType == null || contentType.isBlank()) {
                        contentType = "application/octet-stream";
                    }
                    BlobInfo blobInfo = BlobInfo.newBuilder(BlobId.of(gcsBucket, objectPath))
                            .setContentType(contentType)
                            .build();
                    storage.create(blobInfo, file.getBytes());
                } catch (IOException e) {
                    throw new IllegalStateException("FILE_SAVE_FAILED", e);
                }
                //#endregion GCS 전환코드 END
            } else {
                // [로컬 저장 — gcs.enabled=false] 2026/07/22 장우철
                //#region로컬 파일관리
                Path dir = Paths.get(uploadDir, "community", "post", String.valueOf(postId));
                try {
                    Files.createDirectories(dir);
                    file.transferTo(dir.resolve(savedName));
                } catch (IOException e) {
                    throw new IllegalStateException("FILE_SAVE_FAILED", e);
                }
                //#endregion
            }

            GiveReportFileVO fileVo = new GiveReportFileVO();
            fileVo.setRefType("POST");
            fileVo.setRefId(postId);
            fileVo.setDriveFileId(gcsEnabled ? "GCS" : "LOCAL");
            fileVo.setFileUrl(fileUrl);
            fileVo.setOriginName(file.getOriginalFilename());
            communityPostMapper.insertFile(fileVo);
            saved++;
        }
    }

    /**
     * 게시글 사진 물리 삭제 + TB_FILE 삭제
     * 관리자 글 삭제 시 호출 — 2026/07/22 장우철
     */
    @Override
    public void deletePhotosByPostId(long postId) {
        List<String> urls = communityPostMapper.selectFileUrlsByPostId(postId);
        if (urls != null) {
            for (String fileUrl : urls) {
                deleteStoredFile(fileUrl);
            }
        }
        try {
            FileVO del = new FileVO();
            del.setRefType("POST");
            del.setRefId(postId);
            fileMapper.deleteFilesByRefId(del);
        } catch (Exception e) {
            throw new IllegalStateException("FILE_DB_DELETE_FAILED", e);
        }
    }

    private void deleteStoredFile(String fileUrl) {
        if (fileUrl == null || fileUrl.isBlank()) {
            return;
        }
        String objectPath = toObjectPath(fileUrl);
        if (gcsEnabled) {
            // [GCS 삭제 — gcs.enabled=true] 2026/07/22 장우철
            //#region구글 스토리지 GCS 전환코드 START
            if (storage != null) {
                storage.delete(BlobId.of(gcsBucket, objectPath));
            }
            //#endregion GCS 전환코드 END
        } else {
            // [로컬 삭제 — gcs.enabled=false] 2026/07/22 장우철
            //#region로컬 파일관리
            try {
                Files.deleteIfExists(Paths.get(uploadDir, objectPath));
            } catch (IOException ignored) {
                // 로컬 파일 없으면 무시
            }
            //#endregion
        }
    }

    /** DB FILE_URL (/upload/...) → 버킷·로컬 상대경로 */
    private String toObjectPath(String fileUrl) {
        String path = fileUrl.trim();
        if (path.startsWith("/upload/")) {
            return path.substring("/upload/".length());
        }
        if (path.startsWith("upload/")) {
            return path.substring("upload/".length());
        }
        return path.startsWith("/") ? path.substring(1) : path;
    }

    private String resolveExtension(String originalName) {
        if (originalName == null) {
            return ".jpg";
        }
        int dot = originalName.lastIndexOf('.');
        if (dot < 0) {
            return ".jpg";
        }
        String ext = originalName.substring(dot).toLowerCase();
        if (ext.matches("\\.(jpg|jpeg|png|gif|webp)")) {
            return ext;
        }
        return ".jpg";
    }

    @Override
    public void markLifeAnswered(long postId) {
        // LIFE + 일반댓글 등록 후 TAGS → ANSWERED / 2026-07-10 STEP 4
        CommunityPostVO post = communityPostMapper.selectPostDetail(postId);
        if (post == null || !"LIFE".equalsIgnoreCase(post.getBoardType())) {
            return;
        }
        communityPostMapper.updatePostTags(postId, "ANSWERED");
    }

    /**
     * 2026-07-23 HYJ — 게시글 수정 (본인 글만)
     * 1. 로그인 확인 → MEMBER_NO 매칭
     * 2. UPDATE TB_POST SET TITLE, BODY WHERE POST_ID AND MEMBER_NO
     * 2026-08-13 박유정 — 3. 기존 사진 선택 삭제 + 새 사진 추가 (전체 5장上限)
     */
    @Override
    @Transactional
    public void updatePost(CommunityPostVO vo, MemberVO loginMember,
                           MultipartFile[] photos, List<String> removePhotoUrls) {
        if (loginMember == null) {
            throw new IllegalStateException("LOGIN_REQUIRED");
        }
        Long loginMemberNo = resolveMemberNoForUpdate(loginMember);
        if (loginMemberNo == null) {
            throw new IllegalStateException("MEMBER_NOT_FOUND");
        }

        CommunityPostVO existing = communityPostMapper.selectPostDetail(vo.getPostId());
        if (existing == null) {
            throw new IllegalArgumentException("POST_NOT_FOUND");
        }
        if (!loginMemberNo.equals(existing.getMemberNo())) {
            throw new IllegalStateException("FORBIDDEN");
        }

        vo.setMemberNo(loginMemberNo);
        int updated = communityPostMapper.updatePost(vo);
        if (updated == 0) {
            throw new IllegalStateException("UPDATE_FAILED");
        }

        // 2026-08-13 박유정 — 체크한 기존 사진 삭제
        if (removePhotoUrls != null) {
            List<String> currentUrls = communityPostMapper.selectFileUrlsByPostId(vo.getPostId());
            for (String url : removePhotoUrls) {
                if (url == null || url.isBlank()) {
                    continue;
                }
                String trimmed = url.trim();
                if (currentUrls != null && currentUrls.contains(trimmed)) {
                    deleteStoredFile(trimmed);
                    communityPostMapper.deleteFileByPostIdAndUrl(vo.getPostId(), trimmed);
                }
            }
        }

        // 2026-08-13 박유정 — 새 사진 추가 (전체 5장上限)
        List<String> remainUrls = communityPostMapper.selectFileUrlsByPostId(vo.getPostId());
        int remain = MAX_PHOTOS - (remainUrls == null ? 0 : remainUrls.size());
        savePhotos(vo.getPostId(), photos, remain);
    }

    /**
     * 2026-07-23 HYJ — 게시글 삭제 (본인 글만)
     * - LIFE(수의사 상담): STATUS_CD='DELETED' + DELETE_DATE (유저/관리자 동일, 7일 보관 후 purge)
     * 2026/08/03 장우철 — LIFE soft 삭제 시 댓글·사진은 유지, purge 시 일괄 정리
     * - TOWN/SHARE: 즉시 물리 삭제 (댓글 → 파일 → 게시글 DELETE)
     */
    @Override
    @Transactional
    public void deletePost(long postId, MemberVO loginMember) {
        if (loginMember == null) {
            throw new IllegalStateException("LOGIN_REQUIRED");
        }
        Long loginMemberNo = resolveMemberNoForUpdate(loginMember);
        if (loginMemberNo == null) {
            //HYJ 26.07.28 관리자계정 통과
            if (!"ADMIN".equals(loginMember.getRole())){
                throw new IllegalStateException("MEMBER_NOT_FOUND");
            }
        }

        CommunityPostVO existing = communityPostMapper.selectPostDetail(postId);
        if (existing == null) {
            throw new IllegalArgumentException("POST_NOT_FOUND");
        }
        if (loginMemberNo == null || !loginMemberNo.equals(existing.getMemberNo())) {
            //HYJ 26.07.28 관리자계정 통과
            if (!"ADMIN".equals(loginMember.getRole())){
                throw new IllegalStateException("MEMBER_NOT_FOUND");
            }
        }

        boolean isLife = "LIFE".equalsIgnoreCase(existing.getBoardType());
        int result;

        if (isLife) {
            // LIFE — STATUS_CD='DELETED' (관리자와 동일, 7일 후 스케줄러가 물리 삭제)
            result = communityPostMapper.softDeletePostByUser(postId, existing.getMemberNo());
        } else {
            // TOWN, SHARE — 즉시 물리 삭제
            // 2026/08/03 장우철 — 신고·좋아요 → 댓글 → 파일 → 게시글 (ORA-02292 FK_PTN65_0058 방지)
            clearPostChildRecords(postId);
            communityCommentService.hardDeleteCommentsByPostId(postId);
            deletePhotosByPostId(postId);
            result = communityPostMapper.hardDeletePostByUser(postId, existing.getMemberNo());
        }

        if (result == 0) {
            throw new IllegalStateException("DELETE_FAILED");
        }

        if ("ADMIN".equals(loginMember.getRole())) {
            //HYJ 26.07.28 관리자 게시글삭제 회수반영
            adminCommunityMapper.updateMemberAdminPostDelCount(existing.getMemberNo());
        }
    }

    private Long resolveMemberNoForUpdate(MemberVO loginMember) {
        if (loginMember.getMemberNo() != null) {
            return loginMember.getMemberNo();
        }
        return lookupMemberNo(loginMember);
    }

    /**
     * 2026-07-23 HYJ — LIFE 7일 경과 DELETED 게시글 물리 삭제 (스케줄러)
     * STATUS_CD='DELETED' + DELETE_DATE 기준
     * 삭제 순서: 댓글 → 파일 → 게시글
     */
    @Override
    public int purgeExpiredDeletedPosts(int days) {
        List<Long> expiredPostIds = communityPostMapper.selectExpiredDeletedPostIds(days);
        if (expiredPostIds == null || expiredPostIds.isEmpty()) {
            return 0;
        }

        int purged = 0;
        for (Long postId : expiredPostIds) {
            // 2026/08/03 장우철 — 물리 삭제 전 신고·좋아요 정리
            clearPostChildRecords(postId);
            communityCommentService.hardDeleteCommentsByPostId(postId);
            deletePhotosByPostId(postId);
            int result = communityPostMapper.hardDeleteExpiredPost(postId);
            if (result > 0) {
                purged++;
            }
        }
        return purged;
    }

    /** 2026/08/03 장우철 — TB_POST 자식(신고·좋아요) 선삭제 */
    private void clearPostChildRecords(long postId) {
        communityPostMapper.deleteReportsByPostId(postId);
        communityPostMapper.deleteLikesByPostId(postId);
    }
}
