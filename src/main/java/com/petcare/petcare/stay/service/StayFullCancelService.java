/**
 * 역할: 숙소 예약 전액 환불 취소 (사업자·관리자 공통)
 * 2026/07/31 장우철 — 수수료 0 · 결제액 전액 토스 취소 · 정산 대상 아님(CANCEL)
 * 2026/08/07 장우철 — 실결제(PAY_AMOUNT) 환불 + 포인트·쿠폰 복구
 */
package com.petcare.petcare.stay.service;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.common.external.service.TossPaymentService;
import com.petcare.petcare.mypage.notify.service.MypageNotifyService;
import com.petcare.petcare.stay.mapper.StayCancelMapper;
import com.petcare.petcare.stay.vo.ReservationVO;

@Service
public class StayFullCancelService {

    @Autowired
    private StayCancelMapper stayCancelMapper;
    @Autowired
    private TossPaymentService tossPaymentService;
    @Autowired
    private MypageNotifyService mypageNotifyService;
    @Autowired
    private StayRefundBenefitService stayRefundBenefitService;

    /**
     * 사업자·관리자 취소: CANCEL_FEE=0, 실결제 전액 환불, 포인트·쿠폰 복구
     * @param stayId 사업자 소속 검증용 (관리자면 null)
     */
    @Transactional
    public void cancelWithFullRefund(Long resvId, Long stayId, String cancelReason, String actorLabel)
            throws Exception {
        cancelWithFullRefund(resvId, stayId, cancelReason, actorLabel, false, false);
    }

    /**
     * 2026/07/31 장우철 — R3 관리자 환불승인: DONE 포함 전액 환불 취소
     */
    @Transactional
    public void cancelWithFullRefund(Long resvId, Long stayId, String cancelReason, String actorLabel,
                                     boolean allowDone)
            throws Exception {
        cancelWithFullRefund(resvId, stayId, cancelReason, actorLabel, allowDone, false);
    }

    /**
     * 2026-08-11 박유정 — skipCancelNotification: 관리자 환불승인 시 취소 알림 생략(별도 환불 알림)
     */
    @Transactional
    public void cancelWithFullRefund(Long resvId, Long stayId, String cancelReason, String actorLabel,
                                     boolean allowDone, boolean skipCancelNotification)
            throws Exception {
        if (resvId == null) {
            throw new IllegalArgumentException("예약 정보가 올바르지 않습니다.");
        }
        if (cancelReason == null || cancelReason.isBlank()) {
            throw new IllegalArgumentException("취소 사유를 입력해 주세요.");
        }
        String reason = cancelReason.trim();
        if (reason.length() > 500) {
            reason = reason.substring(0, 500);
        }
        String actor = (actorLabel == null || actorLabel.isBlank()) ? "관리자" : actorLabel.trim();

        ReservationVO resv = stayCancelMapper.selectStayReservation(resvId, stayId);
        if (resv == null) {
            throw new IllegalStateException("예약을 찾을 수 없거나 권한이 없습니다.");
        }
        if (!"STAY".equalsIgnoreCase(resv.getResvType())) {
            throw new IllegalStateException("숙소 예약만 취소할 수 있습니다.");
        }

        String status = resv.getStatusCd() != null ? resv.getStatusCd().trim().toUpperCase() : "";
        if ("CANCEL".equals(status) || "REJECTED".equals(status)) {
            throw new IllegalStateException("이미 취소된 예약입니다.");
        }
        if ("DONE".equals(status) && !allowDone) {
            throw new IllegalStateException("이용완료 예약은 취소할 수 없습니다.");
        }

        long cancelFeeAmt = 0L;
        long refundAmt = 0L;

        // 결제 완료건: 실결제액 환불 + 혜택 복구
        if (!"PENDING".equals(status)) {
            Map<String, Object> payment = stayCancelMapper.selectDonePaymentByResvId(resvId);
            if (payment != null) {
                refundAmt = stayRefundBenefitService.readPayAmount(payment);
                if (refundAmt > 0 && payment.get("tossPaymentKey") != null) {
                    String paymentKey = String.valueOf(payment.get("tossPaymentKey"));
                    if (!paymentKey.startsWith("POINT") && !paymentKey.isBlank()
                            && !paymentKey.startsWith("BILLING-")) {
                        String payMethod = payment.get("payMethod") != null
                                ? String.valueOf(payment.get("payMethod")) : null;
                        boolean billing = TossPaymentService.isBillingPayMethod(payMethod);
                        // 실결제 전액 → cancelAmount null (토스 전액취소)
                        String tossError = tossPaymentService.cancelPayment(
                                paymentKey, actor + " 숙소 예약 취소", null, billing);
                        if (tossError != null) {
                            throw new IllegalStateException(tossError);
                        }
                    }
                }
                stayCancelMapper.updatePaymentRefundByResvId(resvId, refundAmt);
                stayRefundBenefitService.restorePointAndCoupon(resv, "STAY_CANCEL");
            }
        }

        int updated = stayCancelMapper.updateStayFullCancel(
                resvId, stayId, reason, cancelFeeAmt, refundAmt, allowDone);
        if (updated == 0) {
            throw new IllegalStateException("예약을 취소할 수 없습니다. 상태를 확인해 주세요.");
        }

        // 2026/08/11 장우철 — 숙소 전용 취소 알림 + yujeong skipCancelNotification
        if (!skipCancelNotification) {
            String stayName = resv.getStayName() != null && !resv.getStayName().isBlank()
                    ? resv.getStayName() : "숙소";
            mypageNotifyService.sendStayReserveCancelNotification(
                    resv.getMemberNo(), stayName, resv.getCheckinDate(), resv.getCheckoutDate(),
                    reason, resvId);
        }
    }

    /**
     * 2026/08/06 장우철 — 관리자 환불승인(보상 숙박): 실결제 환불 + 포인트·쿠폰 복구, 예약 STATUS 유지
     */
    @Transactional
    public void refundPaymentKeepReservation(Long resvId, String actorLabel) throws Exception {
        if (resvId == null) {
            throw new IllegalArgumentException("예약 정보가 올바르지 않습니다.");
        }
        String actor = (actorLabel == null || actorLabel.isBlank()) ? "관리자" : actorLabel.trim();

        ReservationVO resv = stayCancelMapper.selectStayReservation(resvId, null);
        if (resv == null) {
            throw new IllegalStateException("예약을 찾을 수 없거나 권한이 없습니다.");
        }
        if (!"STAY".equalsIgnoreCase(resv.getResvType())) {
            throw new IllegalStateException("숙소 예약만 환불할 수 있습니다.");
        }

        String status = resv.getStatusCd() != null ? resv.getStatusCd().trim().toUpperCase() : "";
        if ("CANCEL".equals(status) || "REJECTED".equals(status)) {
            throw new IllegalStateException("이미 취소된 예약입니다.");
        }

        long refundAmt = 0L;
        Map<String, Object> payment = stayCancelMapper.selectDonePaymentByResvId(resvId);
        if (payment == null) {
            throw new IllegalStateException("환불할 결제 내역이 없습니다.");
        }

        refundAmt = stayRefundBenefitService.readPayAmount(payment);
        if (refundAmt > 0 && payment.get("tossPaymentKey") != null) {
            String paymentKey = String.valueOf(payment.get("tossPaymentKey"));
            if (!paymentKey.startsWith("POINT") && !paymentKey.isBlank()
                    && !paymentKey.startsWith("BILLING-")) {
                String payMethod = payment.get("payMethod") != null
                        ? String.valueOf(payment.get("payMethod")) : null;
                boolean billing = TossPaymentService.isBillingPayMethod(payMethod);
                String tossError = tossPaymentService.cancelPayment(
                        paymentKey, actor + " 숙소 환불승인(이용유지)", null, billing);
                if (tossError != null) {
                    throw new IllegalStateException(tossError);
                }
            }
        }
        stayCancelMapper.updatePaymentRefundByResvId(resvId, refundAmt);
        stayRefundBenefitService.restorePointAndCoupon(resv, "STAY_REFUND");

        int updated = stayCancelMapper.updateStayRefundAmtKeepStatus(resvId, refundAmt);
        if (updated == 0) {
            throw new IllegalStateException("환불 금액을 기록할 수 없습니다. 예약 상태를 확인해 주세요.");
        }

        // 2026/08/07 장우철 — 보상환불(이용 유지) → 회원 알림
        try {
            String stayName = resv.getStayName() != null && !resv.getStayName().isBlank()
                    ? resv.getStayName() : "숙소";
            mypageNotifyService.sendStayCompensationRefundNotification(
                    resv.getMemberNo(), stayName, refundAmt, resvId);
        } catch (Exception ignored) {
        }
    }
}
