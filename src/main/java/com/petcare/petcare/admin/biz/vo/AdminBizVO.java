/**
 * 역할: 관리자 사업자 목록·상세·승인 처리용 데이터 객체
 *
 * 참고 테이블
 * - TB_BUSINESS
 * - TB_BUSINESS_AUTH
 *
 * DB 컬럼명은 팀 VO 규칙(camelCase)에 맞게 작성
 */

package com.petcare.petcare.admin.biz.vo;

import java.time.LocalDateTime;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AdminBizVO {

    // 2026-07-09 장우철 — 관리자 사업자 승인 목록·상세 필드
    // 이유: MypageBizVO(신청)와 동일 테이블이지만 관리자 화면에서 필요한 컬럼만 분리해 둠

    private Long bizNo;
    private String bizId;        // TB_BUSINESS.BIZ_ID (회원 로그인 이메일)
    private String bizType;      // HOSPITAL / STAY / STORE ...
    private String bizRegNo;
    private String bizName;
    private String ceoName;
    private String phone;
    private String statusCd;     // PENDING / APPROVED / REJECTED
    private LocalDateTime joinDate;

    private Long authId;         // TB_BUSINESS_AUTH 최신 건 PK
    private LocalDateTime applyDate;

    // 2026/07/28 장우철 — 정산 계좌 (숙소·쇼핑, TB_BUSINESS.SETTLE_*)
    private String settleBank;
    private String settleBankCode;
    private String settleAccount;
    private String settleHolder;
    private String settleVerifyYn;
    private LocalDateTime settleVerifyDate;
}
