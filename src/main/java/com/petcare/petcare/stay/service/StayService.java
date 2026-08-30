/**
 * 역할: 펫호텔(사용자) 비즈니스 로직 (interface)
 *
 * 담당 화면
 * - stay/list.jsp             숙소 목록
 * - stay/detail.jsp           숙소 상세
 * - stay/reserve.jsp          예약
 * - stay/complete.jsp         예약 완료
 *
 * 구현할 기능 예시
 * - 펫호텔 목록 조회
 * - 호텔 상세·예약 등록
 *
 * 연결
 * - 구현: StayStayServiceImpl
 * - 호출: StayStayController
 * - DB: StayStayMapper
 *
 * 참고 테이블
 * - TB_STAY
 * - TB_RESERVATION
 */

package com.petcare.petcare.stay.service;

import java.util.Date;
import java.util.List;

import com.petcare.petcare.stay.vo.ReservationVO;
import com.petcare.petcare.stay.vo.StayPetVO;
import com.petcare.petcare.stay.vo.StayReviewVO;
import com.petcare.petcare.stay.vo.StayVO;
import com.petcare.petcare.store.vo.CouponVO;

public interface StayService {
    public List<StayVO> getStayList();
    public List<StayVO> getStayListBySearch(StayVO searchVO);
    public StayVO getStayById(Long stayId);
    
    // 예약
    public List<StayPetVO> getPetList(Long memberNo);
    public Long createStayReservation(ReservationVO vo);
    public ReservationVO getReservationById(Long resvId);

    List<StayReviewVO> getStayReviews(Long stayId) throws Exception;

    // HYJ 26.07.20 가용성 체크
    public boolean checkRoomAvailability(Long roomId, Date checkinDate, Date checkoutDate);

    // HYJ 26.07.20 결제 확정 (+ 포인트 사용)
    // 2026/07/31 장우철 — tossPaidAmount: 위젯/빌링 실결제액(포인트 차감 후). null이면 total-usedPoint
    // 지윤 26.08.07 — memberCouponId 추가: 사용할 회원쿠폰 (없으면 null/0)
    public void confirmPayment(Long resvId, String tossPaymentKey, String tossOrderId, String payMethod,
                               String kakaoAccessToken, Long memberNo, long usedPoint, Long tossPaidAmount,
                               Long memberCouponId);

    // 2026/07/27 장우철 — DB 실제 보유 포인트
    Long getMemberPointBalance(Long memberNo);

    // 지윤 26.08.07: 이 숙소(사업자)가 발급한, 회원이 사용 가능한 쿠폰 목록
    List<CouponVO> getUsableCoupons(Long memberNo, Long bizNo);
}