/**
 * 역할: 분실/보호 제보 데이터 객체
 *
 * - 박유정 / 2026-07-06~07
 *
 * 참고 테이블
 * - TB_POST (BOARD_TYPE = 'LOST')
 * - TB_FILE (REF_TYPE = 'POST', 사진 메타)
 *
 * DB 컬럼명은 팀 VO 규칙(camelCase)에 맞게 작성
 */

package com.petcare.petcare.give.report.vo;

import java.time.LocalDateTime;

import org.springframework.stereotype.Component;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Component("giveReportVO")
public class GiveReportVO {

    // ── TB_POST 컬럼 ──────────────────────────────────────────
                   
    private Long postId;           // POST_ID — 게시글 ID
    private Long memberNo;         // MEMBER_NO — 작성자 회원번호
    private String boardType;      // BOARD_TYPE — 게시판 유형 (LOST 고정)
    private String title;          // TITLE — 제목
    private String body;           // BODY — 본문
    private Integer viewCount;     // VIEW_COUNT — 조회수
    private Integer likeCnt;       // LIKE_CNT — 좋아요 수
    private String lostSpecies;    // LOST_SPECIES — 분실·발견 동물 종류 (DOG/CAT/ETC)
    private String lostFeature;    // LOST_FEATURE — 분실·발견 동물 특징 (크기·색상·성별·태그 등)
    private Double lostLat;        // LOST_LAT — 분실·발견 위도
    private Double lostLng;        // LOST_LNG — 분실·발견 경도
    private String lostContact;    // LOST_CONTACT — 분실·발견 연락처
    private String region;         // REGION — 지역 (시·구 등)
    private String statusCd;       // STATUS_CD — 게시 상태 (ACTIVE/HIDDEN/DELETED)
    private LocalDateTime regDate; // REG_DATE — 등록일
    private String tags;           // TAGS — 해시태그·분류 (FOUND/LOST/TEMP_CARE/FINDING 등)

    

    // ── write.jsp 폼 전용 (DB 컬럼 없음 → Service에서 조합) ──

    private String reportKind;     // (폼) — 신고 유형, TAGS 조합용 (LOST/FOUND)
    private String animalSize;     // (폼) — 추정 크기, LOST_FEATURE 조합용
    private String furColor;       // (폼) — 털 색상, LOST_FEATURE 조합용
    private String gender;         // (폼) — 성별 추정 (M/F/UNKNOWN)
    private String featureTags;    // (폼) — 외형 특징 태그, LOST_FEATURE 조합용
    private String foundAt;        // (폼) — 발견·분실 일시 (datetime-local)
    private String address;        // (폼) — 발견·분실 주소, LOST_LAT/LNG 변환용
    private String description;    // (폼) — 상황 설명, BODY 보조
    private String tempCare;       // (폼) — 임시보호 여부 (Y/N), TAGS 조합용

    // ── 조회 전용 (TB_FILE) ──

    private String thumbUrl;           // FILE_URL — 목록 썸네일 (TB_FILE 첫 사진)
    private java.util.List<String> photoUrls; // FILE_URL — 상세 사진 URL 목록 (TB_FILE)
}
