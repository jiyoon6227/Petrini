package com.petcare.petcare.biz.stay.service;



import java.util.List;



import org.springframework.web.multipart.MultipartFile;



import com.petcare.petcare.biz.vo.BizCouponVO;
import com.petcare.petcare.biz.vo.BizDashboardVO;
import com.petcare.petcare.hospital.vo.ReviewDeleteRequestVO;

import com.petcare.petcare.main.banner.vo.MainBannerVO;

import com.petcare.petcare.stay.vo.ReservationVO;

import com.petcare.petcare.stay.vo.StayReviewVO;

import com.petcare.petcare.stay.vo.StayRoomVO;

import com.petcare.petcare.stay.vo.StayVO;



public interface BizStayService {

    StayVO getStayByBizId(String bizId);



    // 승인됐는데 TB_HOSPITAL 없으면 껍데기 생성 후 반환

    StayVO resolveStayByBizId(String bizId);



    void updateStayInfo(StayVO vo);



    void updateStayProfile(StayVO vo);



    // 객실 관리

    List<StayRoomVO> getRoomList(Long stayId);



    void insertRoom(StayRoomVO vo);



    void updateRoom(StayRoomVO vo);



    // APPROVE / HOLD / CLOSED
    void changeRoomStatus(Long roomId, Long stayId, String statusCd);



    // 예약 관리

    List<ReservationVO> getReservationList(Long stayId, String tab) throws Exception;



    ReservationVO getReservationDetail(Long stayId, Long resvId) throws Exception;



    void updateReservationStatus(Long stayId, Long resvId, String statusCd, String cancelReason) throws Exception;



    List<ReservationVO> getCalendarReservations(Long stayId, String fromDate, String toDate) throws Exception;



    // 사이드바 예약관리 배지 (PENDING + CONFIRMED)

    int countPendingReservations(Long stayId) throws Exception;



    int countTodayConfirmedReservations(Long stayId) throws Exception;



    // 쿠폰관리

    // BIZ_MEMBER_NO = TB_BUSINESS.BIZ_NO (NUMBER)

    // 사업자 본인 쿠폰 목록

    List<BizCouponVO> getCouponList(Long bizNo);



    // 쿠폰 상세

    BizCouponVO getCouponDetail(Long couponId);



    // 쿠폰 신청 (PENDING 상태로 INSERT)

    void applyCoupon(Long bizNo, BizCouponVO vo);



    // 쿠폰 수정 (PENDING 상태일 때만)

    void updateCoupon(Long bizNo, BizCouponVO vo);



    // 쿠폰 삭제 (PENDING 상태일 때만)
    void deleteCoupon(Long bizNo, Long couponId);

    // 쿠폰 조기 마감 (병원/숙소 공용)
    void closeCoupon(Long bizNo, Long couponId);



    // 배너관리

    Long getBizNo(String bizId);

    List<MainBannerVO> getBannerList(Long bizNo);

    void applyBanner(MainBannerVO banner, MultipartFile image) throws Exception;



    // 사업자 숙소 리뷰 관리

    List<StayReviewVO> getBizStayReviews(Long stayId) throws Exception;



    void saveReviewBizReply(Long stayId, Long reviewId, String bizReply) throws Exception;



    void requestReviewDelete(Long stayId, Long bizNo, Long reviewId, String requestReason) throws Exception;



    List<ReviewDeleteRequestVO> getBizReviewDeleteRequests(Long stayId, Long bizNo) throws Exception;

    // 대시보드
    BizDashboardVO getDashboardData(Long stayId, int chartDays) throws Exception;
    List<ReservationVO> getTodayCheckinList(Long stayId);
    List<StayReviewVO> getRecentReviews(Long stayId);

    // 사업자 숙소 환불신청
    int countPendingStayRefundRequests(Long stayId);
    List<com.petcare.petcare.member.inquiry.vo.MemberInquiryVO> getStayRefundList(Long stayId, String statusCd);
    java.util.Map<String, Integer> getStayRefundStatusCounts(Long stayId);

}


