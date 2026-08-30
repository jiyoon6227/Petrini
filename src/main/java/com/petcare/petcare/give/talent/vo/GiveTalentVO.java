/**
 * 역할: 재능나눔 데이터 객체
 *
 * - 박유정 / 2026-07-13
 * - 팀 DDL 기준 (TB_TALENT — TB_POST SHARE 와 별도)
 *
 * 참고 테이블
 * - TB_TALENT
 * - TB_BUSINESS (JOIN — bizId, bizName, bizType)
 *
 * [TALENT_TYPE]
 * - GROOMING / HOSPITAL / PHOTO / TRANSPORT / ETC
 *
 * [STATUS_CD]
 * - PENDING   승인 대기
 * - APPROVED  게시 중 (가족찾기 노출)
 * - REJECTED  반려
 * - DONE      진행 종료
 */

package com.petcare.petcare.give.talent.vo;

import java.time.LocalDateTime;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class GiveTalentVO {

    // ── TB_TALENT 컬럼 ───────────────────────────────────────

    private Long talentId;         // TALENT_ID — 재능나눔 ID
    private Long bizNo;            // BIZ_NO — 사업자 번호
    private String title;          // TITLE — 제목
    private String talentType;     // TALENT_TYPE — 재능 유형 (GROOMING/HOSPITAL 등)
    private Integer capacity;      // CAPACITY — 모집 인원
    private Integer currentCnt;    // CURRENT_CNT — 현재 신청 인원
    private String schedule;       // SCHEDULE — 일정
    private String duration;       // DURATION — 소요 시간
    private String location;       // LOCATION — 장소
    private String contact;        // CONTACT — 연락처
    private String body;           // BODY — 상세 설명
    private String thumbUrl;       // THUMB_URL — 썸네일 URL
    private String statusCd;       // STATUS_CD — 승인 상태 (PENDING/APPROVED 등)
    private String rejectReason;   // REJECT_REASON — 반려 사유
    private Long adminNo;          // ADMIN_NO — 처리 관리자 번호
    private LocalDateTime regDate; // REG_DATE — 등록일
    private LocalDateTime approveDate; // APPROVE_DATE — 승인일

    // ── 조회 전용 (TB_BUSINESS JOIN) ─────────────────────────

    private String bizId;          // BIZ_ID — 사업자 ID (이메일)
    private String bizName;        // BIZ_NAME — 업체명
    private String bizType;        // BIZ_TYPE — 업종
}
