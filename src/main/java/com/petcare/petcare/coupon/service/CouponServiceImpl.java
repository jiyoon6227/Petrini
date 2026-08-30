package com.petcare.petcare.coupon.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.coupon.mapper.CouponMapper;
import com.petcare.petcare.store.vo.CouponVO;
import com.petcare.petcare.store.vo.StoreShopVO;

@Service
public class CouponServiceImpl implements CouponService {

    @Autowired
    private CouponMapper eventCouponMapper;

    @Override
    public List<CouponVO> getAvailableCoupons(Long memberNo, String today) {
        return eventCouponMapper.selectAvailableCoupons(memberNo, today);
    }

    @Override
    public List<CouponVO> getMyCoupons(Long memberNo) {
        return eventCouponMapper.selectMyCoupons(memberNo);
    }

    @Override
    public int countUsableCoupons(Long memberNo) {
    return eventCouponMapper.countUsableCoupons(memberNo);
    }

    // 지윤 26.08.06: 쿠폰과 발급 사업자 정보 조회
    @Override
    public CouponVO getCouponTarget(Long couponId) {
    return eventCouponMapper.selectCouponTarget(couponId);
    }

    // 지윤 26.08.06: 쿠폰 발급 쇼핑몰의 적용 상품 조회
    // 지윤 26.08.06: 쿠폰 적용 상품 검색 및 정렬
@Override
public List<StoreShopVO> getCouponProducts(
        String bizNo,
        String sort,
        String keyword
) {
    return eventCouponMapper.selectCouponProducts(
            bizNo,
            sort,
            keyword
    );
}
@Override
@Transactional
public void claimCoupon(Long memberNo, Long couponId) {
        // 1) 이미 받았는지 체크 (중복발급 방지)
        int already = eventCouponMapper.countMemberCoupon(memberNo, couponId);
        if (already > 0) {
            throw new IllegalStateException("ALREADY_CLAIMED");
        }

        // 2) 쿠폰 존재 및 발급 가능 상태 확인
        CouponVO coupon = eventCouponMapper.selectCouponById(couponId);
        if (coupon == null) {
            throw new IllegalArgumentException("COUPON_NOT_FOUND");
        }

        // 지윤 26.08.07: 사업자가 조기마감(INACTIVE)한 쿠폰은 발급 불가
        if ("INACTIVE".equals(coupon.getStatusCd())) {
            throw new IllegalStateException("COUPON_CLOSED");
        }

        // 지윤 26.08.07: 수량 소진된 쿠폰은 발급 불가 (사전 체크, 최종 확정은 UPDATE에서)
        // 2026-08-13 박유정 — issuedQty NULL을 0으로 간주
        if ("EXHAUSTED".equals(coupon.getStatusCd())) {
            throw new IllegalStateException("COUPON_EXHAUSTED");
        }
        int issuedQty = coupon.getIssuedQty() != null ? coupon.getIssuedQty() : 0;
        if (coupon.getTotalQty() != null && issuedQty >= coupon.getTotalQty()) {
            throw new IllegalStateException("COUPON_EXHAUSTED");
        }

        // 지윤 26.08.07: 사용기간 종료된 쿠폰은 발급 불가
        String today = java.time.LocalDate.now()
                .format(java.time.format.DateTimeFormatter.ofPattern("yyyyMMdd"));
        if (coupon.getUseEndDate() != null && coupon.getUseEndDate().compareTo(today) < 0) {
            throw new IllegalStateException("COUPON_EXPIRED");
        }

        // 2026-08-13 박유정 — INSERT 전 예산·RATE 설정 사전 검증
        int budgetUnit = "RATE".equals(coupon.getCouponType())
                ? (coupon.getMaxDiscountAmt() != null ? coupon.getMaxDiscountAmt() : 0)
                : (coupon.getDiscountValue() != null ? coupon.getDiscountValue() : 0);

        if ("RATE".equals(coupon.getCouponType()) && budgetUnit <= 0) {
            throw new IllegalStateException("INVALID_COUPON_CONFIG");
        }

        if (coupon.getTotalBudget() != null && coupon.getTotalBudget() > 0) {
            int issuedBudget = coupon.getIssuedBudget() != null ? coupon.getIssuedBudget() : 0;
            if (issuedBudget + budgetUnit > coupon.getTotalBudget()) {
                throw new IllegalStateException("BUDGET_EXHAUSTED");
            }
        }
        
        // 3) TB_MEMBER_COUPON INSERT
        // 2026/08/13 장우철 — 예주 만료일(useEndDate) + 우철 조건부 INSERT(중복발급 방지)
        int inserted = eventCouponMapper.insertMemberCoupon(memberNo, couponId, coupon.getUseEndDate());
        if (inserted == 0) {
            throw new IllegalStateException("ALREADY_CLAIMED");
        }

        // 4) TB_COUPON 발급수량·예산 갱신
        // 지윤 26.08.07: 동시요청으로 그 사이 소진됐으면 0건 갱신 → 트랜잭션 롤백(2번 INSERT도 취소)
        int updated = eventCouponMapper.updateCouponIssued(couponId, budgetUnit);
        if (updated == 0) {
            throw new IllegalStateException("COUPON_EXHAUSTED");
        }
    }
}
