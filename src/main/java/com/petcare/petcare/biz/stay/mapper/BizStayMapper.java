package com.petcare.petcare.biz.stay.mapper;



import java.util.List;



import org.apache.ibatis.annotations.Mapper;

import org.apache.ibatis.annotations.Param;



import com.petcare.petcare.biz.vo.BizCouponVO;

import com.petcare.petcare.hospital.vo.ReviewDeleteRequestVO;

import com.petcare.petcare.main.banner.vo.MainBannerVO;

import com.petcare.petcare.stay.vo.ReservationVO;

import com.petcare.petcare.stay.vo.StayReviewVO;

import com.petcare.petcare.stay.vo.StayRoomVO;

import com.petcare.petcare.stay.vo.StayVO;





@Mapper

public interface BizStayMapper {

    StayVO selectStayByBizId(String bizId);



    int insertStay(String bizId);



    int updateStayInfo(StayVO vo);



    // 객실 CRUD

    List<StayRoomVO> selectRoomList(Long stayId);

    StayRoomVO selectRoomById(@Param("roomId") Long roomId, @Param("stayId") Long stayId);



    int insertRoom(StayRoomVO vo);



    int updateRoom(StayRoomVO vo);



    int updateRoomStatus(@Param("roomId") Long roomId,
                         @Param("stayId") Long stayId,
                         @Param("statusCd") String statusCd);

    // 진행 중 예약 건수 (객실 삭제 가능 여부)
    int countActiveReservationsForRoom(@Param("roomId") Long roomId);



    // 병원 예약 사업자 측 Mapper

    List<ReservationVO> selectReservationList(@Param("stayId") Long stayId,

                                               @Param("tab") String tab) throws Exception;



    ReservationVO selectReservationDetail(@Param("resvId") Long resvId,

                                          @Param("stayId") Long stayId) throws Exception;



    int updateReservationStatus(@Param("resvId") Long resvId,

                                @Param("stayId") Long stayId,

                                @Param("statusCd") String statusCd,

                                @Param("rejectReason") String rejectReason) throws Exception;



    List<ReservationVO> selectReservationCalendarList(@Param("stayId") Long stayId,

                                                        @Param("fromDate") String fromDate,

                                                        @Param("toDate") String toDate) throws Exception;



    // 사이드바 예약관리 배지 (PENDING + CONFIRMED)

    int countPendingReservations(@Param("stayId") Long stayId) throws Exception;



    int countTodayConfirmedReservations(@Param("stayId") Long stayId) throws Exception;



    String selectStayNameById(@Param("stayId") Long stayId) throws Exception;



    void updateStayProfile(StayVO vo);



    // 쿠폰관리

    // BIZ_MEMBER_NO = TB_BUSINESS.BIZ_NO (NUMBER)

    // 사업자 본인 쿠폰 목록

    List<BizCouponVO> selectCouponListByBizNo(@Param("bizMemberNo") Long bizMemberNo);



    // 쿠폰 상세 1건

    BizCouponVO selectCouponById(@Param("couponId") Long couponId);



    // 쿠폰 신청 INSERT

    int insertCoupon(BizCouponVO vo);



    // 쿠폰 수정 (PENDING 상태일 때만)

    int updateCoupon(BizCouponVO vo);



    // 쿠폰 삭제 (PENDING 상태일 때만)
    int deleteCoupon(@Param("couponId") Long couponId,
                     @Param("bizMemberNo") Long bizMemberNo);

    // 쿠폰 조기 마감 (병원/숙소 공용)
    int closeCoupon(@Param("couponId") Long couponId,
                    @Param("bizMemberNo") Long bizMemberNo);



    // 배너관리

    Long selectBizNoByBizId(@Param("bizId") String bizId);

    // 사업자: 내 배너 목록

    List<MainBannerVO> selectBannerList(Long bizNo);



    // 사업자: 배너 신청 INSERT

    void insertBanner(MainBannerVO banner);



    // 사업자 숙소 리뷰 관리

    // 목록

    List<StayReviewVO> selectBizStayReviews(@Param("stayId") Long stayId);



    // 단건 검증 (답글/삭제요청 전 "내 숙소 리뷰인지" 확인)

    StayReviewVO selectBizStayReview(@Param("stayId") Long stayId, @Param("reviewId") Long reviewId);



    // 답글 저장

    int updateReviewBizReply(@Param("stayId") Long stayId, @Param("reviewId") Long reviewId, @Param("bizReply") String bizReply);



    // 삭제 요청 INSERT

    int insertReviewDeleteRequest(ReviewDeleteRequestVO vo);



    // PENDING 중복 체크

    int countPendingReviewDeleteRequest(@Param("reviewId") Long reviewId, @Param("bizNo") Long bizNo);



    // 삭제요청 탭 목록

    List<ReviewDeleteRequestVO> selectBizReviewDeleteRequests(@Param("stayId") Long stayId, @Param("bizNo") Long bizNo);

    // 대시보드 집계
    int countResvByDate(@Param("targetId") Long targetId, @Param("dt") String dt);
    int countCheckoutByDate(@Param("targetId") Long targetId, @Param("dt") String dt);
    long sumMonthRevenue(@Param("targetId") Long targetId, @Param("dt") String dt);
    List<java.util.Map<String, Object>> countByStatus(@Param("targetId") Long targetId);
    List<com.petcare.petcare.biz.vo.DailyStatVO> selectDailyStats(@Param("targetId") Long targetId, @Param("days") int days);
    List<ReservationVO> selectTodayCheckinList(@Param("stayId") Long stayId);
    List<StayReviewVO> selectRecentReviews(@Param("stayId") Long stayId);
}


