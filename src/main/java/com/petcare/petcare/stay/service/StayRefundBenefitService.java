/**
 * 역할: 숙소 취소/환불 시 실결제액 산정 + 포인트·쿠폰 복구
 * 2026/08/07 장우철 — TOTAL_AMOUNT 대신 PAY_AMOUNT 기준 환불, 혜택 복구
 */
package com.petcare.petcare.stay.service;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.petcare.petcare.coupon.mapper.CouponMapper;
import com.petcare.petcare.stay.mapper.StayCancelMapper;
import com.petcare.petcare.stay.vo.ReservationVO;

@Service
public class StayRefundBenefitService {

    @Autowired
    private StayCancelMapper stayCancelMapper;
    @Autowired
    private CouponMapper couponMapper;

    /** TB_PAYMENT.PAY_AMOUNT (DONE) 우선, 없으면 TOTAL - 쿠폰 - 포인트 */
    public long resolveCardPayAmount(Long resvId, Long totalAmount, Long couponDiscount, Long pointUsed) {
        Map<String, Object> payment = stayCancelMapper.selectDonePaymentByResvId(resvId);
        if (payment != null && payment.get("payAmount") instanceof Number) {
            long pay = ((Number) payment.get("payAmount")).longValue();
            return Math.max(0L, pay);
        }
        long total = totalAmount != null ? totalAmount : 0L;
        long coupon = couponDiscount != null ? couponDiscount : 0L;
        long point = pointUsed != null ? pointUsed : 0L;
        return Math.max(0L, total - coupon - point);
    }

    public long resolveCardPayAmount(ReservationVO resv) {
        if (resv == null) {
            return 0L;
        }
        return resolveCardPayAmount(
                resv.getResvId(),
                resv.getTotalAmount(),
                resv.getCouponDiscount(),
                resv.getPointUsed());
    }

    public long readPayAmount(Map<String, Object> payment) {
        if (payment == null || !(payment.get("payAmount") instanceof Number)) {
            return 0L;
        }
        return Math.max(0L, ((Number) payment.get("payAmount")).longValue());
    }

    /**
     * 포인트 잔액 복구 + 이력, 사용 쿠폰 UNUSED 복구.
     * PAY_STATUS=DONE 건을 환불 처리할 때 1회 호출 (이미 REFUND면 selectDonePayment가 비어 이중복구 방지).
     */
    public void restorePointAndCoupon(Long memberNo, Long pointUsed, Long memberCouponId,
                                      Long resvId, String reasonCd) {
        if (memberNo == null) {
            return;
        }

        long point = pointUsed != null ? pointUsed : 0L;
        if (point > 0) {
            Long current = stayCancelMapper.selectMemberPointBalance(memberNo);
            long balanceAfter = (current != null ? current : 0L) + point;

            Map<String, Object> bal = new HashMap<>();
            bal.put("memberNo", memberNo);
            bal.put("pointAmount", point);
            stayCancelMapper.addMemberPointBalance(bal);

            Map<String, Object> hist = new HashMap<>();
            hist.put("memberNo", memberNo);
            hist.put("pointAmount", point);
            hist.put("balanceAfter", balanceAfter);
            hist.put("reasonCd", reasonCd != null ? reasonCd : "STAY_CANCEL");
            hist.put("refType", "RESERVATION");
            hist.put("refId", resvId != null ? String.valueOf(resvId) : null);
            stayCancelMapper.insertPointRefundHistory(hist);
        }

        if (memberCouponId != null && memberCouponId > 0) {
            couponMapper.restoreMemberCouponUsed(memberCouponId);
        }
    }

    public void restorePointAndCoupon(ReservationVO resv, String reasonCd) {
        if (resv == null) {
            return;
        }
        restorePointAndCoupon(
                resv.getMemberNo(),
                resv.getPointUsed(),
                resv.getMemberCouponId(),
                resv.getResvId(),
                reasonCd);
    }
}
