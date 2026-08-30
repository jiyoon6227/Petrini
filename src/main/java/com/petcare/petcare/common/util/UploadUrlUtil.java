package com.petcare.petcare.common.util;

/**
 * TB_FILE.FILE_URL → 브라우저에서 열 수 있는 공개 URL로 변환
 *
 * 저장 형식 예:
 * - banner/12/uuid.jpg           (FileService)
 * - /upload/give/report/...      (분실신고·커뮤니티 등)
 *
 * 2026-08-07 박유정 — 배너 API·목록 이미지 URL 통일
 */
public final class UploadUrlUtil {

    private UploadUrlUtil() {
    }

    /** 2026-08-07 박유정 — FILE_URL → contextPath 포함 브라우저 접근 URL */
    public static String toPublicUrl(String fileUrl, String contextPath) {
        if (fileUrl == null || fileUrl.isBlank()) {
            return "";
        }

        String path = fileUrl.trim().replace('\\', '/');
        String ctx = contextPath == null ? "" : contextPath;

        if (path.startsWith("http://") || path.startsWith("https://")) {
            return path;
        }
        if (!ctx.isEmpty() && path.startsWith(ctx + "/")) {
            return path;
        }
        if (path.startsWith("/upload/")) {
            return ctx + path;
        }
        if (path.startsWith("upload/")) {
            return ctx + "/" + path;
        }

        int uploadIdx = path.indexOf("/upload/");
        if (uploadIdx >= 0) {
            return ctx + path.substring(uploadIdx);
        }

        // Windows 절대경로가 DB에 들어간 경우 (C:/upload/banner/...) — 2026-08-07 박유정
        int bannerIdx = path.indexOf("banner/");
        if (bannerIdx > 0 && path.contains(":")) {
            return ctx + "/upload/" + path.substring(bannerIdx);
        }

        return ctx + "/upload/" + path;
    }
}
