package com.petcare.petcare.stay.service;

import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.petcare.petcare.common.external.service.KakaoMessageService;
import com.petcare.petcare.common.external.service.TossPaymentService;
import com.petcare.petcare.mypage.notify.service.MypageNotifyService;
import com.petcare.petcare.stay.vo.ReservationVO;
import com.petcare.petcare.stay.vo.StayPetVO;
import com.petcare.petcare.stay.mapper.StayMapper;
import com.petcare.petcare.stay.vo.StayReviewVO;
import com.petcare.petcare.stay.vo.StayRoomVO;
import com.petcare.petcare.stay.vo.StayVO;
import com.petcare.petcare.store.vo.CouponVO;
import com.petcare.petcare.coupon.mapper.CouponMapper;
import com.petcare.petcare.coupon.service.CouponDiscountCalculator;

@Service
public class StayServiceImpl implements StayService {

    private static final Logger log = LoggerFactory.getLogger(StayServiceImpl.class);

    @Autowired
    private StayMapper stayMapper;

    // 숙소 예약 쿠폰 적용용
    @Autowired
    private CouponMapper couponMapper;

    @Autowired
    private KakaoMessageService kakaoMessageService;

    @Autowired
    private TossPaymentService tossPaymentService;

    @Autowired
    private MypageNotifyService mypageNotifyService;

    @Override
    public List<StayVO> getStayList() {
        return stayMapper.selectStayList();
    }

    @Override
    public List<StayVO> getStayListBySearch(StayVO searchVO) {
        return stayMapper.selectStayListBySearch(searchVO);
    }
    
    @Override
    public StayVO getStayById(Long stayId) {
        StayVO stay = stayMapper.selectStayById(stayId);
        if (stay != null) {
            List<StayRoomVO> rooms = stayMapper.selectRoomsByStayId(stayId);
            stay.setRooms(rooms);
            // 고객 노출 환불정책은 플랫폼 고정 문구
            stay.setRefundPolicy(StayCancelFeeCalculator.FIXED_POLICY_TEXT);
        }
        return stay;
    }

    @Override
    public List<StayPetVO> getPetList(Long memberNo) {
        return stayMapper.selectPetListByMemberNo(memberNo);
    }

    @Override
    @Transactional(readOnly = true)
    public List<StayReviewVO> getStayReviews(Long stayId) throws Exception {
        if (stayId == null) {
            return List.of();
        }
        return stayMapper.selectStayReviews(stayId);
    }

    // 가용성 체크 (단순 조회 — 락 없음)
    @Override
    public boolean checkRoomAvailability(Long roomId, Date checkinDate, Date checkoutDate) {
        StayRoomVO room = stayMapper.selectRoomById(roomId);
        if (room == null) {
            return false;
        }
        String status = room.getStatusCd() == null || room.getStatusCd().isBlank() ? "APPROVE" : room.getStatusCd();
        if (!"APPROVE".equals(status)) {
            return false;
        }
        Map<String, Object> param = new HashMap<>();
        param.put("roomId", roomId);
        param.put("checkinDate", checkinDate);
        param.put("checkoutDate", checkoutDate);
        int count = stayMapper.countOverlappingReservation(param);
        return count == 0;
    }

    // 예약 생성 (비관적 락 + 가용성 검증)
    // PET_CNT·PET_FEE(추가 마리×박) 반영
    @Override
    @Transactional
    public Long createStayReservation(ReservationVO vo) {
        // PET_ID NOT NULL 제약 (반려동물 미선택 시 INSERT 방지)
        if (vo.getPetId() == null) {
            throw new RuntimeException("반려동물을 선택해 주세요. 등록된 반려동물이 없으면 마이페이지에서 등록 후 이용해 주세요.");
        }

        StayRoomVO room = stayMapper.selectRoomForUpdate(vo.getRoomId());
        if (room == null) {
            throw new RuntimeException("존재하지 않는 객실입니다.");
        }
        String roomStatus = room.getStatusCd() == null || room.getStatusCd().isBlank() ? "APPROVE" : room.getStatusCd();
        if (!"APPROVE".equals(roomStatus)) {
            throw new RuntimeException("현재 예약할 수 없는 객실입니다.");
        }

        int petLimit = room.getPetLimit() > 0 ? room.getPetLimit() : 1;
        int petCnt = vo.getPetCnt() != null ? vo.getPetCnt() : 1;
        if (petCnt < 1) {
            throw new RuntimeException("반려동물을 1마리 이상 선택해 주세요.");
        }
        if (petCnt > petLimit) {
            throw new RuntimeException("이 객실은 반려동물 최대 " + petLimit + "마리까지 가능합니다.");
        }
        vo.setPetCnt(petCnt);

        Map<String, Object> param = new HashMap<>();
        param.put("roomId", vo.getRoomId());
        param.put("checkinDate", vo.getCheckinDate());
        param.put("checkoutDate", vo.getCheckoutDate());
        int overlap = stayMapper.countOverlappingReservation(param);
        if (overlap > 0) {
            throw new RuntimeException("해당 날짜에 이미 예약이 있습니다.");
        }

        // 금액은 서버에서 재계산: 객실가×박 + max(0,펫수-1)×PET_FEE×박
        int nightCnt = vo.getNightCnt();
        if (nightCnt <= 0) {
            throw new RuntimeException("숙박 일수가 올바르지 않습니다.");
        }
        StayVO stay = stayMapper.selectStayById(room.getStayId());
        long petFeeAmt = (stay != null && stay.getPetFee() != null) ? stay.getPetFee() : 0L;
        long roomAmount = (long) room.getPricePerNight() * nightCnt;
        long extraPetAmount = Math.max(0, petCnt - 1) * petFeeAmt * nightCnt;
        vo.setTotalAmount(roomAmount + extraPetAmount);

        vo.setResvType("STAY");
        vo.setStatusCd("PENDING");
        vo.setResvNo("S" + new SimpleDateFormat("yyyyMMddHHmmss").format(new Date()));
        stayMapper.insertReservation(vo);
        return vo.getResvId();
    }

    // 결제 확정 (PENDING → CONFIRMED + TB_PAYMENT INSERT + 포인트 차감)
    // 위젯 결제는 토스 confirm API 필수 (미호출 시 취소 불가)
    @Override
    @Transactional
    public void confirmPayment(Long resvId, String tossPaymentKey, String tossOrderId, String payMethod,
                               String kakaoAccessToken, Long memberNo, long usedPoint, Long tossPaidAmount,
                               Long memberCouponId) {
        // 예약 조회
        ReservationVO resv = stayMapper.selectReservationById(resvId);
        if (resv == null) {
            throw new RuntimeException("예약 정보를 찾을 수 없습니다.");
        }
        if (!"PENDING".equals(resv.getStatusCd())) {
            throw new RuntimeException("결제할 수 없는 예약 상태입니다.");
        }

        long total = resv.getTotalAmount() != null ? resv.getTotalAmount() : 0L;

        // 쿠폰 서버 재검증 (클라이언트가 보낸 memberCouponId를 그대로 믿지 않음)
        long couponDiscount = 0L;
        if (memberCouponId != null && memberCouponId > 0) {
            couponDiscount = calcStayCouponDiscount(resv, memberCouponId, memberNo);
        }

        long payableAfterCoupon = total - couponDiscount;
        if (usedPoint < 0) {
            usedPoint = 0;
        }
        if (usedPoint > payableAfterCoupon) {
            usedPoint = payableAfterCoupon;
        }
        long cardAmount = payableAfterCoupon - usedPoint;
        // 클라이언트 결제금액이 서버 계산(예약금 − 쿠폰 − 포인트)과 다르면 승인 전 거절
        if (tossPaidAmount != null && tossPaidAmount != cardAmount) {
            throw new RuntimeException("결제 금액이 일치하지 않습니다. 다시 시도해 주세요.");
        }

        String key = tossPaymentKey != null ? tossPaymentKey.trim() : "";
        boolean pointOnly = "POINT_ONLY".equalsIgnoreCase(key) || "POINT".equalsIgnoreCase(payMethod);
        boolean billingAlreadyPaid = "BILLING".equalsIgnoreCase(payMethod);

        // 위젯 결제: 토스 승인 완료 후에만 DB 확정 (쇼핑과 동일)
        if (!pointOnly && !billingAlreadyPaid && cardAmount > 0) {
            if (key.isEmpty()) {
                throw new RuntimeException("결제 키가 없습니다.");
            }
            String tossError = tossPaymentService.confirmPayment(key, tossOrderId, (int) cardAmount);
            if (tossError != null) {
                throw new RuntimeException(tossError);
            }
            if (payMethod == null || payMethod.isBlank()) {
                payMethod = "CARD";
            }
        }

        // 포인트 사용 처리
        if (usedPoint > 0) {
            if (memberNo == null) {
                throw new RuntimeException("회원 정보가 없습니다.");
            }
            // 보유 포인트 확인
            Long currentBalance = stayMapper.selectMemberPointBalance(memberNo);
            if (currentBalance == null || currentBalance < usedPoint) {
                throw new RuntimeException("보유 포인트가 부족합니다.");
            }

            // 포인트 잔액 차감
            Map<String, Object> deductParam = new HashMap<>();
            deductParam.put("memberNo", memberNo);
            deductParam.put("pointAmount", usedPoint);
            // SQL 가드 실패 시 롤백
            int updated = stayMapper.deductMemberPointBalance(deductParam);
            if (updated != 1) {
                throw new RuntimeException("보유 포인트가 부족합니다.");
            }

            // 차감 후 잔액 조회
            Long balanceAfter = stayMapper.selectMemberPointBalance(memberNo);

            // 포인트 이력 INSERT
            Map<String, Object> pointParam = new HashMap<>();
            pointParam.put("memberNo", memberNo);
            pointParam.put("pointAmount", String.valueOf(usedPoint));
            pointParam.put("balanceAfter", String.valueOf(balanceAfter));
            pointParam.put("refType", "STAY_PAYMENT");
            pointParam.put("refId", String.valueOf(resvId));
            stayMapper.insertPointHistory(pointParam);
        }

        // 예약 상태 → CONFIRMED
        Map<String, Object> statusParam = new HashMap<>();
        statusParam.put("resvId", resvId);
        statusParam.put("statusCd", "CONFIRMED");
        stayMapper.updateReservationStatus(statusParam);

        // 쿠폰·포인트 사용 확정 — 예약에 기록 (완료화면에 정확한 결제금액 표시용)
        // 쿠폰을 안 썼어도 포인트만 썼으면 그 내역도 남겨야 완료화면이 정확해짐
        Map<String, Object> paymentInfoParam = new HashMap<>();
        paymentInfoParam.put("resvId", resvId);
        paymentInfoParam.put("memberCouponId", (memberCouponId != null && memberCouponId > 0) ? memberCouponId : null);
        paymentInfoParam.put("couponDiscount", couponDiscount);
        paymentInfoParam.put("pointUsed", usedPoint);
        stayMapper.updateReservationPaymentInfo(paymentInfoParam);

        if (memberCouponId != null && memberCouponId > 0 && couponDiscount > 0) {
            int couponUpdated = couponMapper.markMemberCouponUsed(memberCouponId);
            if (couponUpdated != 1) {
                throw new RuntimeException("쿠폰 사용 처리에 실패했습니다.");
            }
        }

        // 결제 정보 INSERT — PAY_AMOUNT 는 카드(토스) 실결제액
        long payAmountToStore = pointOnly ? 0L : cardAmount;
        if (pointOnly) {
            payAmountToStore = 0L;
        } else if (billingAlreadyPaid || cardAmount > 0) {
            payAmountToStore = cardAmount;
        } else {
            payAmountToStore = total;
        }
        Map<String, Object> payParam = new HashMap<>();
        payParam.put("resvId", resvId);
        payParam.put("payMethod", payMethod);
        payParam.put("payAmount", payAmountToStore);
        payParam.put("tossPaymentKey", tossPaymentKey);
        payParam.put("tossOrderId", tossOrderId);
        payParam.put("payStatus", "DONE");
        stayMapper.insertPayment(payParam);

        // 결제 완료 시 사업자에게 예약 접수 알림
        try {
            Long stayId = resv.getTargetId() != null ? Long.parseLong(resv.getTargetId()) : null;
            Long bizMemberNo = stayId != null ? stayMapper.selectStayMemberNo(stayId) : null;
            String stayName = resv.getStayName() != null ? resv.getStayName() : "숙소";
            mypageNotifyService.sendStayReserveToBizNotification(
                    bizMemberNo, stayName, resv.getCheckinDate(), resv.getCheckoutDate(), resvId);
        } catch (Exception e) {
            log.warn("[Stay] 사업자 예약 알림 발송 실패 — resvId={}, 예약은 정상 처리됨", resvId, e);
        }

        // 카카오톡 "나에게 보내기" 알림 발송
        // 카카오 로그인 사용자만 (accessToken 있을 때) + 실패해도 결제는 정상 유지
        if (kakaoAccessToken != null && !kakaoAccessToken.isBlank()) {
            try {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy.MM.dd");
                String ciStr = sdf.format(resv.getCheckinDate());
                String coStr = sdf.format(resv.getCheckoutDate());

                // 숙소명·객실명·반려동물명 조회 (JOIN 포함)
                ReservationVO fullResv = stayMapper.selectReservationById(resvId);
                String stayName = fullResv.getStayName()    != null ? fullResv.getStayName()    : "숙소";
                String roomName = fullResv.getServiceName() != null ? fullResv.getServiceName() : "객실";
                String petName  = fullResv.getPetName()      != null ? fullResv.getPetName()      : "";

                kakaoMessageService.sendStayReservationMessage(
                    kakaoAccessToken,
                    resv.getResvNo(),
                    stayName,
                    roomName,
                    ciStr,
                    coStr,
                    resv.getNightCnt(),
                    resv.getTotalAmount(),
                    petName
                );
            } catch (Exception e) {
                log.warn("[Stay] 카카오톡 알림 발송 실패 — resvId={}, 예약은 정상 처리됨", resvId, e);
            }
        }
    }
        
    @Override
    public ReservationVO getReservationById(Long resvId) {
        return stayMapper.selectReservationById(resvId);
    }

    // DB 실제 보유 포인트
    @Override
    public Long getMemberPointBalance(Long memberNo) {
        Long bal = stayMapper.selectMemberPointBalance(memberNo);
        return bal != null ? bal : 0L;
    }

    // 이 숙소(사업자)가 발급한, 회원이 사용 가능한 쿠폰 목록
    @Override
    public List<CouponVO> getUsableCoupons(Long memberNo, Long bizNo) {
        if (memberNo == null || bizNo == null) {
            return java.util.Collections.emptyList();
        }
        return couponMapper.selectMemberCouponsByBiz(memberNo, bizNo);
    }

    // 쿠폰 재검증 + 할인액 (본인·미사용·승인·사용기간·숙소 사업자·최소금액)
    @Override
    public long calcStayCouponDiscount(ReservationVO resv, Long memberCouponId, Long memberNo) {
        if (resv == null || memberCouponId == null || memberCouponId <= 0) {
            return 0L;
        }
        long total = resv.getTotalAmount() != null ? resv.getTotalAmount() : 0L;
        CouponVO coupon = couponMapper.selectMemberCouponForUse(memberCouponId, memberNo);
        StayVO stay = getStayById(Long.valueOf(resv.getTargetId()));
        Long stayBizNo = stay != null ? stay.getBizNo() : null;
        String todayYmd = LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE);
        return CouponDiscountCalculator.stayDiscount(coupon, stayBizNo, total, todayYmd);
    }
}
