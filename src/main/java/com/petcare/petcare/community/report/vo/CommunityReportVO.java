/**
 * 역할: 커뮤니티 게시글 신고 데이터 객체
 *
 * - 박유정 / 2026-07-10
 *
 * 담당 화면
 * - community/detail.jsp   게시글 신고 팝업
 *
 * 참고 테이블
 * - TB_POST_REPORT
 */

package com.petcare.petcare.community.report.vo;

import java.time.LocalDateTime;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CommunityReportVO {

    private Long reportId;       // REPORT_ID — 신고 ID
    private Long postId;         // POST_ID — 신고 대상 게시글 ID
    private Long memberNo;       // REPORTER_NO — 신고자 회원번호 (VO 필드명 memberNo)
    private String reasonCd;     // REASON — 신고 사유 코드 (SPAM/ABUSE/ETC)
    private String reasonDetail; // (미사용) — 상세 사유, DB 미저장 시 폼용
    private String statusCd;     // STATUS_CD — 처리 상태 (PENDING/DISMISSED 등)
    private LocalDateTime regDate; // REG_DATE — 신고 접수일 (조회 시)

    //2026/08/06 장우철 — 관리자 신고내역 표시용
    private String reporterNickname; // 신고자 닉네임
}
