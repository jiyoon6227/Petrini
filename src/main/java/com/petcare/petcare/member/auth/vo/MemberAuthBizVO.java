/**
 * 역할: 로그인 시 TB_BUSINESS 승인 여부 조회용 VO
 *
 * 연결
 * - MemberAuthMapper.selectApprovedBusinessByBizId
 * - MemberAuthServiceImpl.enrichSessionWithApprovedBiz
 */

package com.petcare.petcare.member.auth.vo;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MemberAuthBizVO {

    // 2026-07-09 장우철 — 승인된 사업자 세션(role=BIZ) 세팅용 필드
    // 이유: BIZ_ID(=회원 이메일)로 TB_BUSINESS 조회 후 bizType 으로 /biz/* 화면 분기
    private Long   bizNo;
    private String bizType;   // HOSPITAL / STAY / STORE / GROOMING / STUDIO / RESTAURANT
    private String statusCd;  // APPROVED
}
