/**
 * 역할: 재능나눔 DB 접근 (MyBatis interface)
 *
 * - 박유정 / 2026-07-13~14
 * - 팀 DDL: TB_TALENT (BIZ_NO FK, ADMIN_NO, STATUS_CD + DONE)
 *
 * XML: resources/mybatis/mapper/give/talent/GiveTalentMapper.xml
 */

package com.petcare.petcare.give.talent.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.give.talent.vo.GiveTalentVO;

@Mapper
public interface GiveTalentMapper {

    // ── 사업자 신청 (2026-07-14 STEP 4) ───────────────────────────

    int insertTalent(GiveTalentVO vo);

    /** 로그인 bizId → BIZ_NO (INSERT 시 FK) */
    Long selectBizNoByBizId(@Param("bizId") String bizId);

    /** 사업자 승인(APPROVED) 여부 — 신청 전 검사 */
    String selectBusinessStatusByBizId(@Param("bizId") String bizId);

    /** 사업자 본인 이력 — biz/hospital/talent.jsp */
    List<GiveTalentVO> selectTalentListByBizId(@Param("bizId") String bizId);

    // ── 사용자 목록·상세 (2026-07-13) ─────────────────────────────

    List<GiveTalentVO> selectApprovedTalentList(@Param("talentType") String talentType);

    GiveTalentVO selectTalentDetail(@Param("talentId") long talentId);

    // ── 관리자 승인 (2026-07-13) ───────────────────────────────────

    List<GiveTalentVO> selectTalentListByStatus(@Param("statusCd") String statusCd);

    int countTalentByStatus(@Param("statusCd") String statusCd);

    int updateTalentStatus(GiveTalentVO vo);

    /** 병원 수동 마감 — 내 글인지 + APPROVED 인지 (1이면 OK) — 2026-08-10 박유정 */
    int countTalentOwnedByBiz(@Param("talentId") long talentId,
    @Param("bizId") String bizId);

    /** 알림 수신자(사업자) MEMBER_NO — 2026-08-10 박유정 */
    Long selectMemberNoByBizId(@Param("bizId") String bizId);

    /** 대표 이미지 URL 갱신 — 2026-08-10 박유정 */
    int updateTalentThumbUrl(GiveTalentVO vo);
}
