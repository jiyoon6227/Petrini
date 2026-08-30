package com.petcare.petcare.coupon.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.store.vo.CouponVO;
import com.petcare.petcare.store.vo.StoreShopVO;

/**
 * 사용자 이벤트/쿠폰 페이지 DB 접근
 *
 * XML: resources/mybatis/mapper/coupon/CouponMapper.xml
 */
@Mapper
public interface CouponMapper {

    // 받을 수 있는 쿠폰 목록 (APPROVED + ACTIVE + 기간 내 + 잔여 수량)
    // 로그인 상태면 이미 받았는지 체크 (alreadyClaimed)
    // 지윤 26.08.10 수정: 기간만료 쿠폰 제외용 today 파라미터 추가
    List<CouponVO> selectAvailableCoupons(@Param("memberNo") Long memberNo,
                                          @Param("today") String today);

    // 보유 쿠폰 목록 (TB_MEMBER_COUPON JOIN TB_COUPON)
    List<CouponVO> selectMyCoupons(@Param("memberNo") Long memberNo);

    // 보유 쿠폰 개수 (사용 가능 상태)
    int countUsableCoupons(@Param("memberNo") Long memberNo);

    // 이미 받았는지 체크
    int countMemberCoupon(@Param("memberNo") Long memberNo,
                          @Param("couponId") Long couponId);

    // 쿠폰 받기 (TB_MEMBER_COUPON INSERT)
    //HYJ 26.08.13 만료일자 추가
    int insertMemberCoupon(@Param("memberNo") Long memberNo,
                           @Param("couponId") Long couponId,
                           @Param("useEndDate") String useEndDate);

    // TB_COUPON 발급수량·예산 갱신
    int updateCouponIssued(@Param("couponId") Long couponId,
                           @Param("discountValue") int discountValue);

    // TB_COUPON 상세 1건 (발급 가능 여부 검증용)
    CouponVO selectCouponById(@Param("couponId") Long couponId);

    // 지윤 26.08.06: 쿠폰과 발급 사업자 정보 조회
    CouponVO selectCouponTarget(
        @Param("couponId") Long couponId
        );

    // 지윤 26.08.06: 쿠폰 발급 쇼핑몰의 적용 상품 조회
    // 지윤 26.08.06: 쿠폰 적용 상품 검색 및 정렬
    List<StoreShopVO> selectCouponProducts(
    @Param("bizNo") String bizNo,
    @Param("sort") String sort,
    @Param("keyword") String keyword
);

// 지윤 26.08.07: 특정 사업자(병원/숙소)가 발급한, 회원이 보유한 사용가능 쿠폰 목록
List<CouponVO> selectMemberCouponsByBiz(@Param("memberNo") Long memberNo,
                                        @Param("bizNo") Long bizNo);

// 2026-08-13 박유정 — 쇼핑 주문서: 장바구니 사업자(BIZ_NO)에 해당하는 보유 쿠폰만
List<CouponVO> selectMemberCouponsByBizNos(@Param("memberNo") Long memberNo,
                                           @Param("bizNos") List<Long> bizNos);

// 지윤 26.08.07: 결제 확정 시 서버 재검증용 — 본인 소유 + UNUSED 쿠폰 1건 조회
CouponVO selectMemberCouponForUse(@Param("memberCouponId") Long memberCouponId,
                                  @Param("memberNo") Long memberNo);

// 지윤 26.08.07: 쿠폰 사용 확정 (STATUS_CD -> USED)
int markMemberCouponUsed(@Param("memberCouponId") Long memberCouponId);

    // 2026/08/07 장우철 — 숙소 취소/환불 시 쿠폰 복구 (USED -> UNUSED)
    int restoreMemberCouponUsed(@Param("memberCouponId") Long memberCouponId);

    // HYJ 26.08.13 기간 만료 쿠폰 일괄 EXPIRED 처리 (스케줄러용)
    int expireOverdueCoupons();
}
