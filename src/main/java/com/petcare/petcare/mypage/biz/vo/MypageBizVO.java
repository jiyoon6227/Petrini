/**
 * 역할: 마이페이지 사업자 신청 데이터 객체
 *
 * 필드 예시
 * - businessId, memberId, bizType, bizName, status
 *
 * 참고 테이블
 * - TB_BUSINESS
 *
 * DB 컬럼명은 팀 VO 규칙(camelCase)에 맞게 작성
 */

package com.petcare.petcare.mypage.biz.vo;

import lombok.Getter;
import lombok.Setter;

@Getter @Setter
public class MypageBizVO {
    // TB_BUSINESS
    private Long bizNo;          // PK (자동증가)
    private String bizId;        // 로그인 ID (세션에서 세팅)
    private String bizType;      // 사업자 유형 (HOSPITAL/STAY/GROOMING 등)
    private String bizRegNo;     // 사업자등록번호
    private String bizName;      // 상호명
    private String ceoName;      // 대표자
    private String phone;        // 연락처
    private String statusCd;     // 상태코드 (PENDING/APPROVED/REJECTED)

    // 2026-07-09 장우철 — TB_BUSINESS_AUTH 최신 건 반려 사유 (반려 화면·재신청 안내)
    private String rejectReason;

    // 폼에서만 사용 (DB 컬럼 아님)
    private String zipcode;
    private String addr1;
    private String addr2;
}
