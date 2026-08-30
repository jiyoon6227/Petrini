/**
 * 역할: 마이페이지 예약·재능나눔 신청 통합 표시용 VO
 *
 * - 박유정 / 2026-08-10 — 재능나눔 참여 신청 필드 (예약내역 통합)
 * - 장우철 — TB_RESERVATION 병원·숙소 예약 필드
 *
 * 참고 테이블
 * - TB_RESERVATION
 * - TB_HOSPITAL, TB_STAY, TB_PET
 * - TB_TALENT_APPLY, TB_TALENT, TB_BUSINESS (재능나눔)
 */

package com.petcare.petcare.mypage.reserve.vo;

import java.util.Date;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MypageReserveVO {

    // ── TB_RESERVATION 컬럼 ────────────────────────────────────

    private Long resvId;            // RESV_ID — 예약 번호 (PK)
    private String resvNo;          // RESV_NO — 예약번호 (화면 표시용)
    private String resvType;        // RESV_TYPE — 예약 유형 (HOSPITAL/STAY)
    private Long memberNo;          // MEMBER_NO — 회원 번호
    private Long petId;             // PET_ID — 반려동물 FK
    // 2026/08/11 장우철 — 숙소 다펫 마리수
    private Integer petCnt;         // PET_CNT
    private String targetId;        // TARGET_ID — 병원·숙소 ID
    private Date resvDate;          // RESV_DATE — 예약일
    private String resvTime;        // RESV_TIME — 예약 시간
    private String symptoms;        // SYMPTOMS — 증상 (병원)
    private String requestMemo;     // REQUEST_MEMO — 요청 메모
    private String statusCd;        // STATUS_CD — 예약 상태
    private String rejectReason;    // REJECT_REASON — 취소·거절 사유
    private Date regDate;           // REG_DATE — 등록일

    // ── 조회 전용 (TB_PET JOIN) ─────────────────────────────────

    private String petName;         // PET_NAME — 반려동물 이름
    private String petSpecies;      // SPECIES — 종 (DOG/CAT 등)
    private String petBreed;        // BREED — 품종

    // ── 조회 전용 (TB_HOSPITAL JOIN) ────────────────────────────

    private String hospitalName;    // NAME — 병원명
    private String hospitalAddr;    // ADDR — 병원 주소

    // ── 조회 전용 (병원 예약 고도화) / 2026/07/20 장우철 ───────

    private Long doctorId;          // DOCTOR_ID — 담당 수의사 FK
    private Long treatTypeId;       // TREAT_TYPE_ID — 진료 유형 FK
    private Integer durationMin;    // DURATION_MIN — 진료 소요 시간(분)
    private String endTime;         // END_TIME — 종료 시간
    private String doctorName;      // DOCTOR_NAME — 수의사명 (JOIN)
    private String treatTypeName;   // TYPE_NAME — 진료 유형명 (JOIN)
    private String reviewedYn;      // (계산) — 리뷰 작성 여부 (Y/N)

    // ── 조회 전용 (TB_STAY JOIN) ────────────────────────────────

    private Date checkinDate;       // CHECKIN_DATE — 체크인일
    private Date checkoutDate;      // CHECKOUT_DATE — 체크아웃일
    private Integer nightCnt;       // NIGHT_CNT — 숙박 박수
    private Long totalAmount;       // TOTAL_AMOUNT — 결제 금액
    private String stayName;        // NAME — 숙소명
    private String stayAddr;        // ADDR — 숙소 주소
    private Long roomId;            // ROOM_ID — 객실 FK
    private String roomName;        // ROOM_NAME — 객실명

    // ── 유저 취소 위약금/환불 / 2026/07/31 장우철 ───────────────

    private Long cancelFeeAmt;      // CANCEL_FEE_AMT — 취소 위약금
    private Long refundAmt;         // REFUND_AMT — 환불 금액
    private Date cancelAt;          // CANCEL_AT — 취소 일시

    // 2026/08/07 장우철 — 쿠폰·포인트·실결제 (취소 환불 기준)
    private Long memberCouponId;
    private Long couponDiscount;
    private Long pointUsed;
    /** 취소 미리보기/환불 기준 실결제액 (PAY_AMOUNT) */
    private Long payAmount;

    // 2026/08/06 장우철 — 숙소 환불신청 UI (PENDING/APPROVED/REJECTED, 예약 운영상태 유지)
    private String stayRefundStatus;
    // 2026/08/06 장우철 — 환불 승인/거절 시 관리자 답변
    private String stayRefundAnswer;

    // ── 상세 화면 미리보기용 (DB 미저장) / 2026/07/31 장우철 ───

    private Long daysUntilCheckin;       // (계산) — 체크인까지 남은 일수
    private Integer cancelFeeRatePercent; // (계산) — 취소 수수료율 (%)
    private String cancelFeeTierLabel;   // (계산) — 취소 정책 구간 라벨
    private Boolean cancelable;          // (계산) — 취소 가능 여부

    // ── 재능나눔 참여 신청 / 2026-08-10 박유정 ─────────────────

    private String talentTitle;     // TB_TALENT.TITLE — 재능나눔 제목
    private String bizName;         // TB_BUSINESS.BIZ_NAME — 제공 업체명
    private String thumbUrl;        // 재능: TB_TALENT.THUMB_URL / 숙소·병원: TB_FILE.FILE_URL
    private String talentSchedule;    // TB_TALENT.SCHEDULE — 일정
}
