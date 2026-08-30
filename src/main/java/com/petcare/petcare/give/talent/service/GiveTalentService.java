/**
 * 역할: 재능나눔 비즈니스 로직 (interface)
 *
 * - 박유정 / 2026-07-13~14
 * - 박유정 / 2026-08-10 — 참여 신청·확인·마감·알림·이미지·예약내역 연동
 *
 * 담당 화면
 * - give/talent/list.jsp        사용자 재능나눔 목록 (APPROVED)
 * - give/talent/detail.jsp      사용자 재능나눔 상세
 * - admin/biz/talent.jsp        관리자 승인·반려
 * - biz/hospital/talent.jsp     사업자 재능나눔 신청 (병원만 DB 연동)
 *
 * 연결
 * - 구현: GiveTalentServiceImpl
 * - DB: GiveTalentMapper
 *
 * 참고 테이블
 * - TB_TALENT (STATUS: PENDING / APPROVED / REJECTED / DONE)
 */

package com.petcare.petcare.give.talent.service;

import java.util.List;
import java.util.Map;

import org.springframework.web.multipart.MultipartFile;

import com.petcare.petcare.give.talent.vo.GiveTalentApplyVO;
import com.petcare.petcare.give.talent.vo.GiveTalentVO;

public interface GiveTalentService {

    // ── 사용자 목록·상세 (2026-07-13) ─────────────────────────────

    List<GiveTalentVO> getApprovedTalentList(String talentType);

    GiveTalentVO getTalentDetail(long talentId);

    // ── 관리자 승인 화면 (2026-07-13) ─────────────────────────────

    List<GiveTalentVO> getTalentListByStatus(String statusCd);

    Map<String, Integer> getTalentStatusCounts();

    void approveTalent(long talentId, long adminNo);

    void rejectTalent(long talentId, String rejectReason, long adminNo);

    void completeTalent(long talentId, long adminNo);

    // ── 사업자 신청 (2026-07-14 STEP 4 — 병원) ───────────────────

    /** 사업자 재능나눔 신청 — TB_TALENT INSERT + 대표 이미지(선택) — 2026-08-10 박유정 */
    void applyTalent(String bizId, GiveTalentVO vo, MultipartFile thumbImage);

    /** 사업자 본인 재능나눔 이력 — biz/hospital/talent.jsp 하단 테이블 */
    List<GiveTalentVO> getTalentListByBizId(String bizId);

    // ── 일반 회원 참여 신청 (2026-08-10 STEP 3) ───────────────────

    /** 모집 중인지 (APPROVED + 인원 여유 + DONE 아님) */
    boolean isRecruitmentOpen(GiveTalentVO talent);

    /** 화면용 라벨 — 모집중 / 모집마감 */
    String getRecruitmentStatusLabel(GiveTalentVO talent);

    /** 일반 회원 참여 신청 */
    void applyForTalent(long memberNo, long talentId, String message);

    /** 상세 화면 — 내 신청 1건 (없으면 null) */
    GiveTalentApplyVO getMyApply(long talentId, long memberNo);

    // ── 병원 사업자 신청자 확인 (2026-08-10 STEP 3) ─────────────

    /** 병원 — 내 글에 달린 신청 전체 */
    List<GiveTalentApplyVO> getAppliesByBizId(String bizId);

    /** 병원 — 특정 글의 신청자 목록 */
    List<GiveTalentApplyVO> getAppliesByTalentId(long talentId);

    /** 병원 [확인] — PENDING → CONFIRMED (승인/반려 아님) */
    void confirmApply(long applyId, String bizId);

    /** 병원 [모집 마감] — APPROVED → DONE */
    void closeRecruitment(long talentId, String bizId);

    /** 병원 사이드바 뱃지 — 확인 대기(PENDING) 신청 건수 — 2026-08-10 박유정 */
    int countPendingAppliesByBizId(String bizId);

    /** 회원 — 참여 신청 취소 (PENDING만) — 2026-08-10 박유정 */
    void cancelMyApply(long applyId, long memberNo);
}
