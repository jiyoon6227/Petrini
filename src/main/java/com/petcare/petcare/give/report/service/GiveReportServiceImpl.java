/**
 * 역할: GiveReportService 구현체 (@Service)
 *
 * - 박유정 / 2026-07-06~07
 * - 박유정 / 2026-07-29 — insertReport 주소 geocode → LOST_LAT/LNG (Kakao REST)
 * - 2026/07/22 장우철 — 사진 저장/삭제 gcs.enabled 분기 (로컬 ↔ GCS)
 *
 * [insertReport — 등록]
 * 1. 세션 회원 → TB_MEMBER 조회 후 MEMBER_NO 세팅
 * 2. 폼 값 조합(제목·본문·특징·태그) → TB_POST INSERT
 * 3. savePhotos() → 로컬 또는 GCS 저장 + TB_FILE INSERT
 *
 * [getReportList — 목록]
 * 1. TB_POST 목록 조회 (BOARD_TYPE='LOST', STATUS_CD='ACTIVE')
 * 2. 각 글마다 TB_FILE 첫 사진 → thumbUrl
 *
 * [getReportDetail — 상세]
 * 1. TB_POST 1건 조회
 * 2. TB_FILE 사진 URL 목록 → photoUrls
 *
 * [deletePhotosByPostId] 2026/07/22 장우철
 * - 글/관리자 삭제 시 물리 파일 + TB_FILE 정리 (호출부 연결용)
 *
 * 연결
 * - implements: GiveReportService
 * - 사용: GiveReportMapper
 *
 * 비즈니스 로직은 여기에 작성 (Controller, Mapper에 직접 작성 X)
 */

package com.petcare.petcare.give.report.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.google.cloud.storage.BlobId;
import com.google.cloud.storage.BlobInfo;
import com.google.cloud.storage.Storage;
import com.petcare.petcare.common.external.service.KakaoMapService;
import com.petcare.petcare.file.mapper.FileMapper;
import com.petcare.petcare.file.vo.FileVO;
import com.petcare.petcare.give.report.mapper.GiveReportMapper;
import com.petcare.petcare.give.report.vo.GiveReportFileVO;
import com.petcare.petcare.give.report.vo.GiveReportVO;
import com.petcare.petcare.member.vo.MemberVO;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class GiveReportServiceImpl implements GiveReportService {

    // 디비에 접근할 우체부(Mapper) 필드 선언 (final로 안전하게 박제)
    private final GiveReportMapper giveReportMapper;

    @Value("${file.upload-dir}")
    private String uploadDir; // application.properties → C:/upload/

    @Value("${gcs.enabled:false}")
    private boolean gcsEnabled;

    @Value("${gcs.bucket-name:}")
    private String gcsBucket;

    @Autowired(required = false)
    private Storage storage;

    @Autowired
    private FileMapper fileMapper;

    // 2026-07-29 박유정 — 주소 → 위·경도 변환 (insertReport, 병원 BizHospital 저장과 동일 패턴)
    @Autowired
    private KakaoMapService kakaoMapService;

    private static final int MAX_PHOTOS = 5; // write.jsp 최대 5장과 동일

    // 2. 생성자 주입 
    public GiveReportServiceImpl(GiveReportMapper giveReportMapper) {
        this.giveReportMapper = giveReportMapper;
    }

    @Override
    public void insertReport(GiveReportVO vo, MemberVO loginMember, MultipartFile[] photos) {
        resolveMemberNo(vo, loginMember);
        // 1) DB에 꼭 필요한 고정값
        vo.setBoardType("LOST");
        vo.setStatusCd("ACTIVE");
        // 2) 제목·본문·특징 등 조합 
        vo.setTitle(buildTitle(vo));
        vo.setBody(buildBody(vo));
        vo.setLostFeature(truncate(buildLostFeature(vo), 500));
        vo.setTags(truncate(buildTags(vo), 500));
        vo.setRegion(truncate(extractRegion(vo.getAddress()), 50));
        // 2026-07-29 박유정 — 주소 → LOST_LAT/LNG (Kakao REST geocode, 병원 저장과 동일)
        if (vo.getAddress() != null && !vo.getAddress().isBlank()) {
            Map<String, Double> coords = kakaoMapService.geocodeAddress(vo.getAddress());
            if (coords != null) {
                vo.setLostLat(coords.get("lat"));
                vo.setLostLng(coords.get("lng"));
            }
        }
        // 2026-07-29 박유정 — geocode·폼 hidden 모두 실패 시 서울시청 기본 좌표 (write.jsp 기본값과 동일)
        if (vo.getLostLat() == null) {
            vo.setLostLat(37.5665);
        }
        if (vo.getLostLng() == null) {
            vo.setLostLng(126.9780);
        }
        // 4) DB INSERT
        giveReportMapper.insertReport(vo);
        // 5) 사진 로컬 저장 + TB_FILE
        savePhotos(vo.getPostId(), photos);
    }
    // ── 아래는 private 헬퍼 메서드 (같은 클래스 안에 추가) ──
    private String buildTitle(GiveReportVO vo) {
        String kind = "FOUND".equals(vo.getReportKind()) ? "발견" : "분실";
        String species = toSpeciesLabel(vo.getLostSpecies());
        String region = extractRegion(vo.getAddress());
        if (region.isEmpty()) {
            region = "위치 미입력";
        }
        return "[" + kind + "] " + region + " " + species;
    }
    private String buildBody(GiveReportVO vo) {
        StringBuilder sb = new StringBuilder();
        if (vo.getFoundAt() != null && !vo.getFoundAt().isBlank()) {
            sb.append("[발견·분실 일시] ").append(vo.getFoundAt()).append("\n");
        }
        if (vo.getAddress() != null && !vo.getAddress().isBlank()) {
            sb.append("[주소] ").append(vo.getAddress()).append("\n");
        }
        sb.append("[임시보호] ")
          .append("Y".equalsIgnoreCase(vo.getTempCare()) ? "예" : "아니요")
          .append("\n\n");
        if (vo.getDescription() != null) {
            sb.append(vo.getDescription());
        }
        return sb.toString().trim();
    }
    private String buildLostFeature(GiveReportVO vo) {
        return safe(vo.getAnimalSize()) + "|"
             + safe(vo.getFurColor()) + "|"
             + safe(vo.getGender()) + "|"
             + safe(vo.getFeatureTags());
    }
    private String buildTags(GiveReportVO vo) {
        String kind = (vo.getReportKind() == null || vo.getReportKind().isBlank())
                ? "FOUND" : vo.getReportKind();
        String tags = kind + ",FINDING";
        if ("Y".equalsIgnoreCase(vo.getTempCare())) {
            tags += ",TEMP_CARE";
        }
        return tags;
    }
    private String extractRegion(String address) {
        if (address == null || address.isBlank()) {
            return "";
        }
        String trimmed = address.trim();
        return trimmed.length() > 50 ? trimmed.substring(0, 50) : trimmed;
    }
    private String toSpeciesLabel(String species) {
        if (species == null) return "동물";
        return switch (species) {
            case "DOG" -> "강아지";
            case "CAT" -> "고양이";
            case "ETC" -> "기타";
            default -> species;
        };
    }
    private String safe(String value) {
        return value == null ? "" : value.trim();
    }

    private void resolveMemberNo(GiveReportVO vo, MemberVO loginMember) {
        if (loginMember == null) {
            throw new IllegalStateException("LOGIN_REQUIRED");
        }
        Long memberNo = lookupMemberNo(loginMember);
        if (memberNo == null) {
            throw new IllegalStateException("MEMBER_NOT_FOUND");
        }
        vo.setMemberNo(memberNo);
    }

    private Long lookupMemberNo(MemberVO loginMember) {
        if (loginMember.getMemberId() != null && !loginMember.getMemberId().isBlank()) {
            Long no = giveReportMapper.selectMemberNoByMemberId(loginMember.getMemberId().trim());
            if (no != null) {
                return no;
            }
        }
        if (loginMember.getEmail() != null && !loginMember.getEmail().isBlank()) {
            return giveReportMapper.selectMemberNoByEmail(loginMember.getEmail().trim());
        }
        return null;
    }

    private String truncate(String value, int maxLen) {
        if (value == null || value.length() <= maxLen) {
            return value;
        }
        return value.substring(0, maxLen);
    }

    @Override
    public GiveReportVO getReportDetail(long postId) {
        GiveReportVO report = giveReportMapper.selectReportDetail(postId);
        if (report != null) {
            parseLostFeature(report);
            // TB_FILE에서 사진 URL 목록 조회 → detail.jsp photoUrls
            report.setPhotoUrls(giveReportMapper.selectFileUrlsByPostId(postId));
        }
        return report;
    }

    /** LOST_FEATURE(크기|색|성별|특징) → VO 폼 필드. 빈 구간도 인덱스 유지 */
    private void parseLostFeature(GiveReportVO vo) {
        String raw = vo.getLostFeature();
        if (raw == null || raw.isBlank()) {
            return;
        }
        String[] parts = raw.split("\\|", -1);
        if (parts.length > 0 && !parts[0].isBlank()) {
            vo.setAnimalSize(parts[0].trim());
        }
        if (parts.length > 1 && !parts[1].isBlank()) {
            vo.setFurColor(parts[1].trim());
        }
        if (parts.length > 2 && !parts[2].isBlank()) {
            vo.setGender(parts[2].trim());
        }
        if (parts.length > 3 && !parts[3].isBlank()) {
            String tags = parts[3].trim();
            if (parts.length > 4) {
                StringBuilder sb = new StringBuilder(tags);
                for (int i = 4; i < parts.length; i++) {
                    sb.append('|').append(parts[i]);
                }
                tags = sb.toString();
            }
            vo.setFeatureTags(tags);
        }
    }

    @Override
    public List<GiveReportVO> getReportList(String status) {
        String normalized = normalizeListStatus(status);
        List<GiveReportVO> list = giveReportMapper.selectReportList(normalized);
        for (GiveReportVO item : list) {
            // 첫 번째 사진을 목록 썸네일로 사용 → list.jsp thumbUrl
            List<String> urls = giveReportMapper.selectFileUrlsByPostId(item.getPostId());
            if (urls != null && !urls.isEmpty()) {
                item.setThumbUrl(urls.get(0));
            }
        }
        return list;
    }

    private String normalizeListStatus(String status) {
        if (status == null || status.isBlank()) {
            return "";
        }
        return switch (status.trim().toUpperCase()) {
            case "FINDING", "OWNER_FOUND", "RESCUED" -> status.trim().toUpperCase();
            default -> "";
        };
    }

    @Override
    public int getReportCount() {
        return giveReportMapper.selectReportCount();
    }

    /**
     * 사진을 로컬 또는 GCS에 저장하고 TB_FILE에 메타데이터 INSERT
     * 저장 경로: community와 동일하게 objectPath = give/report/{postId}/{uuid}.ext
     * 접근 URL:  /upload/give/report/{postId}/{uuid}.ext
     * 2026/07/22 장우철 — gcs.enabled 분기
     */
    private void savePhotos(Long postId, MultipartFile[] photos) {
        if (postId == null || photos == null) {
            return;
        }

        int saved = 0;
        for (MultipartFile file : photos) {
            if (file == null || file.isEmpty()) {
                continue;
            }
            if (saved >= MAX_PHOTOS) {
                break;
            }
            String savedName = UUID.randomUUID() + resolveExtension(file.getOriginalFilename());
            String objectPath = "give/report/" + postId + "/" + savedName;
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
                Path dir = Paths.get(uploadDir, "give", "report", String.valueOf(postId));
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
            giveReportMapper.insertFile(fileVo);
            saved++;
        }
    }

    /**
     * 제보 사진 물리 삭제 + TB_FILE 삭제
     * 유저/관리자 글 삭제 연동용 — 2026/07/22 장우철
     */
    @Override
    public void deletePhotosByPostId(long postId) {
        List<String> urls = giveReportMapper.selectFileUrlsByPostId(postId);
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

    /** 원본 파일명에서 확장자 추출 (jpg/png/gif/webp만 허용, 없으면 .jpg) */
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

    private static final java.util.Set<String> FINDING_STATUS_CODES =
        java.util.Set.of("FINDING", "RESCUED", "OWNER_FOUND");

    @Override
    public void updateFindingStatus(long postId, String findingStatus, MemberVO loginMember) {
    // 1) 로그인 확인
    if (loginMember == null) {
        throw new IllegalStateException("LOGIN_REQUIRED");
    }

    // 2) 허용된 상태값인지 확인
    if (findingStatus == null || !FINDING_STATUS_CODES.contains(findingStatus)) {
        throw new IllegalArgumentException("INVALID_STATUS");
    }

    // 3) 글 조회
    GiveReportVO report = giveReportMapper.selectReportDetail(postId);
    if (report == null) {
        throw new IllegalStateException("REPORT_NOT_FOUND");
    }

    // 4) 작성자 본인만 변경 가능
    Long loginMemberNo = lookupMemberNo(loginMember);
    if (loginMemberNo == null || !loginMemberNo.equals(report.getMemberNo())) {
        throw new IllegalStateException("FORBIDDEN");
    }

    // 5) 기존 tags에서 진행상태만 교체 (FOUND/LOST/TEMP_CARE 는 유지)
    String newTags = replaceFindingStatus(report.getTags(), findingStatus);

    GiveReportVO updateVo = new GiveReportVO();
    updateVo.setPostId(postId);
    updateVo.setTags(truncate(newTags, 500));

    giveReportMapper.updateReportTags(updateVo);  
    }

    /**
 * TAGS 예: FOUND,FINDING,TEMP_CARE
 * → FOUND,RESCUED,TEMP_CARE (진행상태 토큰만 교체)
 */
private String replaceFindingStatus(String oldTags, String newStatus) {
    java.util.List<String> parts = new java.util.ArrayList<>();
    if (oldTags != null && !oldTags.isBlank()) {
        for (String part : oldTags.split(",")) {
            String trimmed = part.trim();
            if (trimmed.isEmpty()) {
                continue;
            }
            // 진행상태 코드는 제외하고 나머지만 유지
            if (!FINDING_STATUS_CODES.contains(trimmed)) {
                parts.add(trimmed);
            }
        }
    }
    parts.add(newStatus);
    return String.join(",", parts);
}



}
