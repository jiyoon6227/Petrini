/**
 * 역할: 재능나눔 참여 신청 DB 접근 (MyBatis interface)
 *
 * - 박유정 / 2026-08-10 — STEP 2
 *
 * XML: resources/mybatis/mapper/give/talent/GiveTalentApplyMapper.xml
 *
 * 테이블: TB_TALENT_APPLY
 * 시퀀스: SEQ_TB_TALENT_APPLY
 */

package com.petcare.petcare.give.talent.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.give.talent.vo.GiveTalentApplyVO;

@Mapper
public interface GiveTalentApplyMapper {

    /** 신청 INSERT — STATUS_CD=PENDING */
    int insertApply(GiveTalentApplyVO vo);

    /** 같은 글·같은 회원 중복 신청 여부 (0이면 신청 가능) */
    int countByTalentAndMember(@Param("talentId") long talentId,
                               @Param("memberNo") long memberNo);

    /** 상세 화면 — 내가 이미 신청했는지 1건 조회 */
    GiveTalentApplyVO selectByTalentAndMember(@Param("talentId") long talentId,
                                              @Param("memberNo") long memberNo);

    /** 병원 사업자 — 특정 글의 신청자 목록 */
    List<GiveTalentApplyVO> selectAppliesByTalentId(@Param("talentId") long talentId);

    /** 병원 사업자 — 내 글 전체 신청 목록 (bizId 기준) */
    List<GiveTalentApplyVO> selectAppliesByBizId(@Param("bizId") String bizId);

    /** 병원 [확인] — PENDING → CONFIRMED */
    int updateApplyConfirmed(@Param("applyId") long applyId);

    /** 신청 성공 시 TB_TALENT.CURRENT_CNT +1 */
    int incrementTalentCurrentCnt(@Param("talentId") long talentId);

    /** 병원 [확인] 전 — 이 신청이 내 사업자 글인지 검사 (1이면 OK) */
    int countApplyOwnedByBiz(@Param("applyId") long applyId,
                             @Param("bizId") String bizId);

    /** 확인 알림용 — APPLY_ID로 1건 (회원번호·제목 포함) */
    GiveTalentApplyVO selectApplyById(@Param("applyId") long applyId);

    /** 사업자 사이드바 — 확인 대기(PENDING) 신청 건수 — 2026-08-10 박유정 */
    int countPendingAppliesByBizId(@Param("bizId") String bizId);

    /** 회원 취소 — PENDING → CANCELLED — 2026-08-10 박유정 */
    int updateApplyCancelled(@Param("applyId") long applyId, @Param("memberNo") long memberNo);

    /** 취소 시 모집 인원 카운트 감소 — 2026-08-10 박유정 */
    int decrementTalentCurrentCnt(@Param("talentId") long talentId);
}
