/**
 * 역할: MypageReserveService 구현체 (@Service)
 *
 * 2026/07/11 장우철 — 마이페이지 예약 목록·상세 (2차)
 * - 박유정 / 2026-07-29 — addStayReview 후 TB_STAY AVG_RATING·REVIEW_CNT 갱신
 * - 박유정 / 2026-08-10 — 재능나눔 참여 신청 예약내역 통합·취소
 */

package com.petcare.petcare.mypage.reserve.service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.common.external.service.TossPaymentService;
import com.petcare.petcare.give.talent.service.GiveTalentService;
import com.petcare.petcare.hospital.vo.HospitalReviewVO;
import com.petcare.petcare.mypage.notify.service.MypageNotifyService;
import com.petcare.petcare.mypage.reserve.mapper.MypageReserveMapper;
import com.petcare.petcare.mypage.reserve.vo.MypageReserveVO;
import com.petcare.petcare.mypage.reserve.vo.StayReviewRegisterResult;
import com.petcare.petcare.stay.service.StayCancelFeeCalculator;
import com.petcare.petcare.stay.service.StayRefundBenefitService;
import com.petcare.petcare.stay.vo.StayReviewVO;

@Service
public class MypageReserveServiceImpl implements MypageReserveService {

    @Autowired
    private MypageReserveMapper mypageReserveMapper;
    @Autowired
    private StayRefundBenefitService stayRefundBenefitService;
    @Autowired
    private MypageNotifyService mypageNotifyService;
    @Autowired
    private TossPaymentService tossPaymentService;
    @Autowired
    private MypageReservePointService mypageReservePointService;
    // 2026-08-10 박유정 — 재능나눔 신청 취소 위임
    @Autowired
    private GiveTalentService giveTalentService;

    // 2026-08-10 박유정 — 예약 + 재능나눔 신청 목록 병합 (type=talent 필터)
    @Override
    @Transactional(readOnly = true)
    public List<MypageReserveVO> getMyReservationList(Long memberNo, String statusFilter, String typeFilter) {
        if (memberNo == null) {
            return Collections.emptyList();
        }
        String status = (statusFilter == null || statusFilter.isBlank() || "all".equalsIgnoreCase(statusFilter))
                ? null : statusFilter.trim().toLowerCase();
        String type = (typeFilter == null || typeFilter.isBlank() || "all".equalsIgnoreCase(typeFilter))
                ? null : typeFilter.trim().toLowerCase();
        if (type != null && !"hospital".equals(type) && !"stay".equals(type) && !"talent".equals(type)) {
            type = null;
        }

        List<MypageReserveVO> list = new ArrayList<>();
        if (type == null || "hospital".equals(type) || "stay".equals(type)) {
            String reservationType = "talent".equals(type) ? null : type;
            list.addAll(mypageReserveMapper.selectMyReservationList(memberNo, status, reservationType));
        }
        if (type == null || "talent".equals(type)) {
            list.addAll(mypageReserveMapper.selectMyTalentApplyList(memberNo, status));
        }

        list.sort(Comparator
                .comparing(MypageReserveVO::getRegDate, Comparator.nullsLast(Comparator.reverseOrder()))
                .thenComparing(MypageReserveVO::getResvId, Comparator.nullsLast(Comparator.reverseOrder())));
        return list;
    }

    // 2026-08-10 박유정 — resvType=TALENT 이면 TB_TALENT_APPLY 상세
    @Override
    @Transactional(readOnly = true)
    public MypageReserveVO getMyReservationDetail(Long memberNo, Long resvId, String resvType) {
        if (memberNo == null || resvId == null) {
            return null;
        }
        if ("TALENT".equalsIgnoreCase(resvType)) {
            MypageReserveVO detail = mypageReserveMapper.selectMyTalentApplyDetail(memberNo, resvId);
            if (detail != null && "PENDING".equalsIgnoreCase(detail.getStatusCd())) {
                detail.setCancelable(true);
            } else if (detail != null) {
                detail.setCancelable(false);
            }
            return detail;
        }
        MypageReserveVO detail = mypageReserveMapper.selectMyReservationDetail(memberNo, resvId);
        if (detail != null) {
            fillStayCancelPreview(detail);
        }
        return detail;
    }

    // 2026-08-10 박유정 — 마이페이지에서 재능나눔 신청 취소
    @Override
    @Transactional
    public void cancelTalentApply(Long memberNo, Long applyId) {
        if (memberNo == null || applyId == null) {
            throw new IllegalArgumentException("신청 정보가 올바르지 않습니다.");
        }
        try {
            giveTalentService.cancelMyApply(applyId, memberNo);
        } catch (IllegalStateException e) {
            switch (e.getMessage()) {
                case "NOT_OWNER" -> throw new IllegalStateException("본인 신청만 취소할 수 있습니다.");
                case "NOT_CANCELABLE" -> throw new IllegalStateException("확인 대기 중인 신청만 취소할 수 있습니다.");
                default -> throw e;
            }
        }
    }

    /** 2026/07/31 장우철 — CONFIRMED 숙소면 취소 수수료 미리보기 채움 */
    /** 2026/08/07 장우철 — 수수료·환불 미리보기는 실결제(PAY_AMOUNT) 기준 */
    private void fillStayCancelPreview(MypageReserveVO detail) {
        if (!"STAY".equalsIgnoreCase(detail.getResvType())
                || !"CONFIRMED".equalsIgnoreCase(detail.getStatusCd())
                || detail.getCheckinDate() == null) {
            detail.setCancelable(false);
            return;
        }
        try {
            long payBase = stayRefundBenefitService.resolveCardPayAmount(
                    detail.getResvId(),
                    detail.getTotalAmount(),
                    detail.getCouponDiscount(),
                    detail.getPointUsed());
            detail.setPayAmount(payBase);
            StayCancelFeeCalculator.Result fee =
                    StayCancelFeeCalculator.calculate(payBase, detail.getCheckinDate());
            detail.setCancelable(true);
            detail.setDaysUntilCheckin(fee.getDaysUntilCheckin());
            detail.setCancelFeeRatePercent(fee.getFeeRatePercent());
            detail.setCancelFeeTierLabel(fee.getTierLabel());
            detail.setCancelFeeAmt(fee.getCancelFeeAmt());
            detail.setRefundAmt(fee.getRefundAmt());
        } catch (IllegalStateException | IllegalArgumentException e) {
            detail.setCancelable(false);
        }
    }

    // 2026/07/31 장우철 — 유저 숙소 취소 (1-4) + 위약금(1-6)
    // 2026/08/07 장우철 — 실결제 기준 수수료/환불 + 포인트·쿠폰 복구
    @Override
    @Transactional
    public void cancelStayReservation(Long memberNo, Long resvId, String cancelReason) {
        if (memberNo == null || resvId == null) {
            throw new IllegalArgumentException("예약 정보가 올바르지 않습니다.");
        }
        if (cancelReason == null || cancelReason.isBlank()) {
            throw new IllegalArgumentException("취소 사유를 입력해 주세요.");
        }
        String reason = cancelReason.trim();
        if (reason.length() > 500) {
            reason = reason.substring(0, 500);
        }

        MypageReserveVO detail = mypageReserveMapper.selectMyReservationDetail(memberNo, resvId);
        if (detail == null) {
            throw new IllegalStateException("예약을 찾을 수 없습니다.");
        }
        if (!"STAY".equalsIgnoreCase(detail.getResvType())) {
            throw new IllegalStateException("숙소 예약만 취소할 수 있습니다.");
        }
        if (!"CONFIRMED".equalsIgnoreCase(detail.getStatusCd())) {
            throw new IllegalStateException("예약확정 상태에서만 취소할 수 있습니다.");
        }

        Map<String, Object> payment = mypageReserveMapper.selectDonePaymentByResvId(resvId);
        long payAmount = stayRefundBenefitService.readPayAmount(payment);
        if (payment == null) {
            payAmount = stayRefundBenefitService.resolveCardPayAmount(
                    resvId, detail.getTotalAmount(), detail.getCouponDiscount(), detail.getPointUsed());
        }

        StayCancelFeeCalculator.Result fee =
                StayCancelFeeCalculator.calculate(payAmount, detail.getCheckinDate());

        // 1) 토스 부분/전액 환불 (환불액 0이면 스킵) + 결제 REFUND
        if (payment != null) {
            if (fee.getRefundAmt() > 0 && payment.get("tossPaymentKey") != null) {
                String paymentKey = String.valueOf(payment.get("tossPaymentKey"));
                if (!paymentKey.startsWith("POINT") && !paymentKey.isBlank()
                        && !paymentKey.startsWith("BILLING-")) {
                    long refundAmt = fee.getRefundAmt();
                    Long cancelAmountParam = (payAmount > 0 && refundAmt >= payAmount)
                            ? null
                            : refundAmt;
                    String payMethod = payment.get("payMethod") != null
                            ? String.valueOf(payment.get("payMethod")) : null;
                    boolean billing = TossPaymentService.isBillingPayMethod(payMethod);
                    String tossError = tossPaymentService.cancelPayment(
                            paymentKey, "숙소 예약 취소", cancelAmountParam, billing);
                    if (tossError != null) {
                        throw new IllegalStateException(tossError);
                    }
                }
            }
            mypageReserveMapper.updatePaymentRefundByResvId(resvId, fee.getRefundAmt());
            // 포인트·쿠폰 복구 (결제 DONE → REFUND 전환 시 1회)
            stayRefundBenefitService.restorePointAndCoupon(
                    memberNo,
                    detail.getPointUsed(),
                    detail.getMemberCouponId(),
                    resvId,
                    "STAY_CANCEL");
        }

        // 2) 예약 CANCEL + 위약금/환불액 저장
        int updated = mypageReserveMapper.updateStayUserCancel(
                resvId, memberNo, reason, fee.getCancelFeeAmt(), fee.getRefundAmt());
        if (updated == 0) {
            throw new IllegalStateException("예약을 취소할 수 없습니다. 상태를 확인해 주세요.");
        }

        // 3) 알림 (본인) — 2026-08-11 박유정 — 숙소 전용 취소 알림 (병원 문구 분리)
        String stayName = detail.getHospitalName() != null ? detail.getHospitalName() : "숙소";
        // 2026/08/11 장우철 — 숙소 전용 취소 알림 (checkin~checkout 기간 표시)
        mypageNotifyService.sendStayReserveCancelNotification(
                memberNo, stayName, detail.getCheckinDate(), detail.getCheckoutDate(), reason, resvId);
    }

    // 2026/07/13 장우철 — DONE + 미작성 예약만 병원 리뷰 INSERT 후 평점 갱신
    @Override
    @Transactional
    public void addHospitalReview(Long memberNo, Long resvId, Double rating, String content) {
        if (memberNo == null || resvId == null) {
            throw new IllegalArgumentException("리뷰 정보가 올바르지 않습니다.");
        }
        if (rating == null || rating < 1.0 || rating > 5.0) {
            throw new IllegalArgumentException("별점은 1~5점이어야 합니다.");
        }
        if (content == null || content.isBlank()) {
            throw new IllegalArgumentException("리뷰 내용을 입력해 주세요.");
        }

        MypageReserveVO detail = mypageReserveMapper.selectMyReservationDetail(memberNo, resvId);
        if (detail == null) {
            throw new IllegalStateException("예약을 찾을 수 없습니다.");
        }
        if (!"DONE".equalsIgnoreCase(detail.getStatusCd())) {
            throw new IllegalStateException("진료완료된 예약만 리뷰를 작성할 수 있습니다.");
        }
        if ("Y".equalsIgnoreCase(detail.getReviewedYn())
                || mypageReserveMapper.countHospitalReviewByResvId(resvId, memberNo) > 0) {
            throw new IllegalStateException("이미 리뷰를 작성한 예약입니다.");
        }
        if (detail.getTargetId() == null || detail.getTargetId().isBlank()) {
            throw new IllegalStateException("병원 정보가 없습니다.");
        }

        Long hospitalId = Long.parseLong(detail.getTargetId());
        HospitalReviewVO review = new HospitalReviewVO();
        review.setTargetId(hospitalId);
        review.setMemberNo(memberNo);
        review.setResvId(resvId);
        review.setRating(rating);
        review.setContent(content.trim());

        mypageReserveMapper.insertHospitalReview(review);
        mypageReserveMapper.updateHospitalRatingSummary(hospitalId);

        // 2026/07/13 장우철 — 사업자에게 리뷰 등록 알림
        Long bizMemberNo = mypageReserveMapper.selectHospitalMemberNo(hospitalId);
        String nickname = mypageReserveMapper.selectMemberNickname(memberNo);
        mypageNotifyService.sendHospitalReviewToBizNotification(
                bizMemberNo, detail.getHospitalName(), nickname, rating, resvId);
    }

    // HYJ 26.07.20 — DONE + 미작성 예약만 숙소 리뷰 INSERT
    // 2026-07-28 박유정 — 사업자 알림·결제금액 3% 포인트 적립·결과 VO 반환 (별도 TX)
    @Override
    @Transactional(timeout = 15)
    public StayReviewRegisterResult addStayReview(Long memberNo, Long resvId, Double rating, String content,
                                                  Long currentPointBalance) {
        if (memberNo == null || resvId == null) {
            throw new IllegalArgumentException("리뷰 정보가 올바르지 않습니다.");
        }
        if (rating == null || rating < 1.0 || rating > 5.0) {
            throw new IllegalArgumentException("별점은 1~5점이어야 합니다.");
        }
        if (content == null || content.isBlank()) {
            throw new IllegalArgumentException("리뷰 내용을 입력해 주세요.");
        }

        MypageReserveVO detail = mypageReserveMapper.selectMyReservationDetail(memberNo, resvId);
        if (detail == null) {
            throw new IllegalStateException("예약을 찾을 수 없습니다.");
        }
        if (!"DONE".equalsIgnoreCase(detail.getStatusCd())) {
            throw new IllegalStateException("숙박 완료된 예약만 리뷰를 작성할 수 있습니다.");
        }
        if (!"STAY".equalsIgnoreCase(detail.getResvType())) {
            throw new IllegalStateException("숙소 예약이 아닙니다.");
        }
        if ("Y".equalsIgnoreCase(detail.getReviewedYn())) {
            throw new IllegalStateException("이미 리뷰를 작성한 예약입니다.");
        }
        if (detail.getTargetId() == null || detail.getTargetId().isBlank()) {
            throw new IllegalStateException("숙소 정보가 없습니다.");
        }

        StayReviewVO review = new StayReviewVO();
        review.setTargetId(Long.parseLong(detail.getTargetId()));
        review.setMemberNo(memberNo);
        review.setResvId(resvId);
        review.setRating(rating);
        review.setContent(content.trim());

        mypageReserveMapper.insertStayReview(review);
        // 2026-07-29 박유정 — TB_STAY AVG_RATING·REVIEW_CNT 갱신 (병원 addHospitalReview와 동일)
        mypageReserveMapper.updateStayRatingSummary(review.getTargetId());

        // 2026-07-28 박유정 — 사업자에게 리뷰 등록 알림
        Long bizMemberNo = mypageReserveMapper.selectStayMemberNo(review.getTargetId());
        String nickname = mypageReserveMapper.selectMemberNickname(memberNo);
        mypageNotifyService.sendStayReviewToBizNotification(
                bizMemberNo, detail.getStayName(), nickname, rating, resvId);

        // 2026-07-28 박유정 — 숙소 리뷰 포인트 적립 (결제금액 3%, MypageReservePointService 별도 TX)
        long earnedPoint = 0;
        if (detail.getTotalAmount() != null && detail.getTotalAmount() > 0) {
            earnedPoint = (long) Math.floor(detail.getTotalAmount() * 0.03);
        }
        boolean pointEarned = earnedPoint > 0
                && mypageReservePointService.earnStayReviewPoint(
                        memberNo, earnedPoint, review.getReviewId(),
                        currentPointBalance != null ? currentPointBalance : 0L);

        return new StayReviewRegisterResult(review.getReviewId(), earnedPoint, pointEarned);
    }
}
