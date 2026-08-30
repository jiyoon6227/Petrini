/**
 * 역할: 제보 첨부 사진 데이터 객체
 *
 * - 박유정 / 2026-07-07
 * - 로컬 사진 업로드 (구글드라이브는 추후)
 *
 * 참고 테이블: TB_FILE
 * DRIVE_FILE_ID = 'LOCAL' (로컬 저장)
 * FILE_URL 예: /upload/give/report/{postId}/{uuid}.jpg
 */

package com.petcare.petcare.give.report.vo;

import java.time.LocalDateTime;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class GiveReportFileVO {

    private Long fileId;           // FILE_ID — 파일 ID
    private String refType;        // REF_TYPE — 참조 유형 (POST)
    private Long refId;            // REF_ID — 참조 ID (POST_ID)
    private String driveFileId;    // DRIVE_FILE_ID — LOCAL 또는 구글드라이브 ID
    private String fileUrl;        // FILE_URL — 저장 경로 (/upload/...)
    private String originName;     // ORIGIN_NAME — 원본 파일명
    private LocalDateTime regDate; // REG_DATE — 등록일
}
