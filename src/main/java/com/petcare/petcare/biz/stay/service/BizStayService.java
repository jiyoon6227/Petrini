/**

 * 역할: 사업자 펫호텔(숙박) 비즈니스 로직 (interface)

 *

 * 담당 화면

 * - biz/stay/dashboard.jsp    대시보드

 * - biz/stay/reserve.jsp      예약 관리

 * - biz/stay/rooms.jsp        객실 관리

 * - biz/stay/calendar.jsp     예약 캘린더

 * - biz/stay/reviews.jsp      리뷰 관리

 * - biz/stay/settlement.jsp   정산

 * - biz/stay/info.jsp         매장 정보

 *

 * 구현할 기능 예시

 * - 예약 목록·상태 변경

 * - 객실 등록·수정

 * - 캘린더 예약 현황 조회

 * - 리뷰·정산 조회

 *

 * 연결

 * - 구현: BizStayServiceImpl

 * - 호출: BizStayController

 * - DB: BizStayMapper

 *

 * 참고 테이블

 * - TB_STAY_ROOM

 * - TB_RESERVATION

 * - TB_REVIEW

 */



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



    // 2026-07-10 장우철 — 승인됐는데 TB_HOSPITAL 없으면 껍데기 생성 후 반환

    StayVO resolveStayByBizId(String bizId);



    void updateStayInfo(StayVO vo);



    void updateStayProfile(StayVO vo);



    // ── 객실 관리 ──

    List<StayRoomVO> getRoomList(Long stayId);



    void insertRoom(StayRoomVO vo);



    void updateRoom(StayRoomVO vo);



    // 2026/08/13 장우철 — APPROVE / HOLD / CLOSED
    void changeRoomStatus(Long roomId, Long stayId, String statusCd);



    // ── 2026-07-14 예약 관리 ──

    List<ReservationVO> getReservationList(Long stayId, String tab) throws Exception;



    ReservationVO getReservationDetail(Long stayId, Long resvId) throws Exception;



    void updateReservationStatus(Long stayId, Long resvId, String statusCd, String cancelReason) throws Exception;



    List<ReservationVO> getCalendarReservations(Long stayId, String fromDate, String toDate) throws Exception;



    // 2026-07-28 박유정 — 사이드바 예약관리 배지 (PENDING + CONFIRMED)

    int countPendingReservations(Long stayId) throws Exception;



    int countTodayConfirmedReservations(Long stayId) throws Exception;



    //HYJ 26.07.29 쿠폰관리

    // 2026/08/01 장우철 — BIZ_MEMBER_NO = TB_BUSINESS.BIZ_NO (NUMBER)

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

    // 지윤 26.08.07: 쿠폰 조기 마감 (병원/숙소 공용)
    void closeCoupon(Long bizNo, Long couponId);



    //HYJ 26.07.31 배너관리

    Long getBizNo(String bizId);

    List<MainBannerVO> getBannerList(Long bizNo);

    void applyBanner(MainBannerVO banner, MultipartFile image) throws Exception;



    // 2026-07-27 박유정 STEP 2 — 사업자 숙소 리뷰 관리

    List<StayReviewVO> getBizStayReviews(Long stayId) throws Exception;



    void saveReviewBizReply(Long stayId, Long reviewId, String bizReply) throws Exception;



    void requestReviewDelete(Long stayId, Long bizNo, Long reviewId, String requestReason) throws Exception;



    List<ReviewDeleteRequestVO> getBizReviewDeleteRequests(Long stayId, Long bizNo) throws Exception;

    // ── 대시보드 ──
    BizDashboardVO getDashboardData(Long stayId, int chartDays) throws Exception;
    List<ReservationVO> getTodayCheckinList(Long stayId);
    List<StayReviewVO> getRecentReviews(Long stayId);

    // 2026-08-11 박유정 — 사업자 숙소 환불신청
    int countPendingStayRefundRequests(Long stayId);
    List<com.petcare.petcare.member.inquiry.vo.MemberInquiryVO> getStayRefundList(Long stayId, String statusCd);
    java.util.Map<String, Integer> getStayRefundStatusCounts(Long stayId);

}


