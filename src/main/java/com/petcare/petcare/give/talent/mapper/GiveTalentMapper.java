package com.petcare.petcare.give.talent.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.give.talent.vo.GiveTalentVO;

@Mapper
public interface GiveTalentMapper {

    // 사업자 신청

    int insertTalent(GiveTalentVO vo);

    /** 로그인 bizId → BIZ_NO (INSERT 시 FK) */
    Long selectBizNoByBizId(@Param("bizId") String bizId);

    /** 사업자 승인(APPROVED) 여부 — 신청 전 검사 */
    String selectBusinessStatusByBizId(@Param("bizId") String bizId);

    /** 사업자 본인 이력 — biz/hospital/talent.jsp */
    List<GiveTalentVO> selectTalentListByBizId(@Param("bizId") String bizId);

    // 사용자 목록·상세

    List<GiveTalentVO> selectApprovedTalentList(@Param("talentType") String talentType);

    int selectApprovedTalentCount();

    GiveTalentVO selectTalentDetail(@Param("talentId") long talentId);

    // 관리자 승인

    List<GiveTalentVO> selectTalentListByStatus(@Param("statusCd") String statusCd);

    int countTalentByStatus(@Param("statusCd") String statusCd);

    int updateTalentStatus(GiveTalentVO vo);

    /** 병원 수동 마감 — 내 글인지 + APPROVED 인지 (1이면 OK) */
    int countTalentOwnedByBiz(@Param("talentId") long talentId,
    @Param("bizId") String bizId);

    /** 알림 수신자(사업자) MEMBER_NO */
    Long selectMemberNoByBizId(@Param("bizId") String bizId);

    /** 대표 이미지 URL 갱신 */
    int updateTalentThumbUrl(GiveTalentVO vo);
}
