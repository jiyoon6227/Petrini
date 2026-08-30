/**
 * 역할: BizStayService 구현체 (@Service)
 *
 * 구현 내용
 * - Controller에서 넘어온 요청 처리
 * - Mapper 호출하여 DB 조회·수정
 * - 비즈니스 규칙 검증 및 결과 반환
 *
 * 연결
 * - implements: BizStayService
 * - 사용: BizStayMapper
 *
 * 비즈니스 로직은 여기에 작성 (Controller, Mapper에 직접 작성 X)
 */

package com.petcare.petcare.biz.stay.service;

import java.util.ArrayList;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.petcare.petcare.biz.stay.mapper.BizStayMapper;
import com.petcare.petcare.biz.vo.BizCouponVO;
import com.petcare.petcare.biz.vo.BizDashboardVO;
import com.petcare.petcare.common.external.service.KakaoMapService;
import com.petcare.petcare.file.service.FileService;
import com.petcare.petcare.file.vo.FileVO;
import com.petcare.petcare.hospital.vo.ReviewDeleteRequestVO;
import com.petcare.petcare.main.banner.BannerConstants;
import com.petcare.petcare.main.banner.mapper.MainBannerMapper;
import com.petcare.petcare.main.banner.service.BannerExpiryService;
import com.petcare.petcare.main.banner.vo.MainBannerVO;
import com.petcare.petcare.member.inquiry.mapper.MemberInquiryMapper;
import com.petcare.petcare.member.inquiry.vo.MemberInquiryVO;
import com.petcare.petcare.mypage.notify.service.MypageNotifyService;
import com.petcare.petcare.stay.service.StayFullCancelService;
import com.petcare.petcare.stay.vo.ReservationVO;
import com.petcare.petcare.stay.vo.StayReviewVO;
import com.petcare.petcare.stay.vo.StayRoomVO;
import com.petcare.petcare.stay.vo.StayVO;

@Service
public class BizStayServiceImpl implements BizStayService {
    @Autowired
    private BizStayMapper bizStayMapper;
    @Autowired
    private KakaoMapService kakaoMapService;
    @Autowired
    private FileService fileService;
    @Autowired
    private MypageNotifyService mypageNotifyService;
    @Autowired
    private MemberInquiryMapper memberInquiryMapper;
    @Autowired
    private StayFullCancelService stayFullCancelService;
    @Autowired
    private MainBannerMapper mainBannerMapper;
    @Autowired
    private BannerExpiryService bannerExpiryService; // 2026-08-06 박유정 — 배너 자동 만료

    @Override
    public StayVO getStayByBizId(String bizId) {
        return bizStayMapper.selectStayByBizId(bizId);
    }
    @Override
    public StayVO resolveStayByBizId(String bizId) {
        if (bizId == null || bizId.isBlank()) {
            return null;
        }
        StayVO stay = bizStayMapper.selectStayByBizId(bizId);
        if (stay == null) {
            bizStayMapper.insertStay(bizId);
            stay = bizStayMapper.selectStayByBizId(bizId);
        }
        if (stay != null) {
            // 2026/08/11 장우철 — 프로필 화면에도 고정 환불정책 표시
            stay.setRefundPolicy(com.petcare.petcare.stay.service.StayCancelFeeCalculator.FIXED_POLICY_TEXT);
        }
        return stay;
    }
    @Override
    public void updateStayInfo(StayVO vo) {
        // 2026-07-10 장우철 — 주소 있으면 좌표 변환 (유저 목록 '상세보기'는 LAT 필수)
        if (vo.getAddr() != null && !vo.getAddr().isBlank()) {
            Map<String, Double> coords = kakaoMapService.geocodeAddress(vo.getAddr());
            if (coords != null) {
                vo.setLat(coords.get("lat"));
                vo.setLng(coords.get("lng"));
            }
        }

        bizStayMapper.updateStayInfo(vo);
    }

    @Override
    public void updateStayProfile(StayVO vo) {
        if (vo.getAddr() != null && !vo.getAddr().isBlank()) {
            Map<String, Double> coords = kakaoMapService.geocodeAddress(vo.getAddr());
            if (coords != null) {
                vo.setLat(coords.get("lat"));
                vo.setLng(coords.get("lng"));
            }
        }
        // 2026/08/11 장우철 — 환불정책 플랫폼 고정 / PET_FEE null → 0
        vo.setRefundPolicy(com.petcare.petcare.stay.service.StayCancelFeeCalculator.FIXED_POLICY_TEXT);
        if (vo.getPetFee() == null || vo.getPetFee() < 0) {
            vo.setPetFee(0L);
        }
        
        bizStayMapper.updateStayProfile(vo);
    }

    // ── 객실 관리 ──
    @Override
    public List<StayRoomVO> getRoomList(Long stayId) {
        return bizStayMapper.selectRoomList(stayId);
    }

    @Override
    public void insertRoom(StayRoomVO vo) {
        bizStayMapper.insertRoom(vo);
    }

    @Override
    public void updateRoom(StayRoomVO vo) {
        StayRoomVO current = bizStayMapper.selectRoomById(vo.getRoomId(), vo.getStayId());
        if (current == null) {
            throw new IllegalStateException("객실을 찾을 수 없습니다.");
        }
        String status = current.getStatusCd() == null ? "APPROVE" : current.getStatusCd();
        if ("CLOSED".equals(status) || "DELETED".equals(status)) {
            throw new IllegalStateException("운영종료된 객실은 수정할 수 없습니다.");
        }
        bizStayMapper.updateRoom(vo);
    }

    @Override
    @Transactional
    public void changeRoomStatus(Long roomId, Long stayId, String statusCd) {
        // 2026/08/13 장우철 — 운영중(APPROVE) / 운영중지(HOLD) / 운영종료(CLOSED)
        StayRoomVO room = bizStayMapper.selectRoomById(roomId, stayId);
        if (room == null) {
            throw new IllegalStateException("객실을 찾을 수 없습니다.");
        }
        String current = room.getStatusCd() == null ? "APPROVE" : room.getStatusCd();
        if ("DELETED".equals(current)) {
            current = "CLOSED";
        }

        if ("HOLD".equals(statusCd)) {
            if (!"APPROVE".equals(current)) {
                throw new IllegalStateException("운영중인 객실만 운영중지할 수 있습니다.");
            }
            if (bizStayMapper.countActiveReservationsForRoom(roomId) > 0) {
                throw new IllegalStateException("진행 중인 예약이 있어 운영중지할 수 없습니다.");
            }
        } else if ("CLOSED".equals(statusCd)) {
            if ("CLOSED".equals(current)) {
                throw new IllegalStateException("이미 운영종료된 객실입니다.");
            }
            if (bizStayMapper.countActiveReservationsForRoom(roomId) > 0) {
                throw new IllegalStateException("진행 중인 예약이 있어 운영종료할 수 없습니다.");
            }
        } else if ("APPROVE".equals(statusCd)) {
            if (!"HOLD".equals(current)) {
                throw new IllegalStateException("운영중지 상태만 다시 운영중으로 바꿀 수 있습니다.");
            }
        } else {
            throw new IllegalStateException("올바르지 않은 객실 상태입니다.");
        }

        int updated = bizStayMapper.updateRoomStatus(roomId, stayId, statusCd);
        if (updated == 0) {
            throw new IllegalStateException("객실 상태 변경에 실패했습니다.");
        }
    }

    // ── 2026-07-14 예약 관리 ──

    @Override
    @Transactional(readOnly = true)
    public List<ReservationVO> getReservationList(Long stayId, String tab) throws Exception {
        if (stayId == null) {
            return List.of();
        }
        String safeTab = (tab == null || "all".equals(tab)) ? null : tab;
        return bizStayMapper.selectReservationList(stayId, safeTab);
    }

    @Override
    @Transactional(readOnly = true)
    public ReservationVO getReservationDetail(Long stayId, Long resvId) throws Exception {
        return bizStayMapper.selectReservationDetail(resvId, stayId);
    }

    @Override
    @Transactional
    public void updateReservationStatus(Long stayId, Long resvId, String statusCd, String cancelReason)
            throws Exception {
        if (stayId == null || resvId == null || statusCd == null || statusCd.isBlank()) {
            throw new IllegalArgumentException("예약 상태 변경 정보가 올바르지 않습니다.");
        }

        String next = statusCd.trim().toUpperCase();
        if (!next.equals("PENDING") && !next.equals("CONFIRMED")
                && !next.equals("CHECKIN") && !next.equals("CHECKOUT")
                && !next.equals("DONE") && !next.equals("CANCEL")) {
            throw new IllegalArgumentException("허용되지 않은 예약 상태입니다.");
        }

        ReservationVO current = bizStayMapper.selectReservationDetail(resvId, stayId);
        if (current == null) {
            throw new IllegalStateException("예약을 찾을 수 없거나 변경할 수 없습니다.");
        }

        String prev = current.getStatusCd() != null ? current.getStatusCd().trim().toUpperCase() : "";
        if (!isAllowedStatusTransition(prev, next)) {
            throw new IllegalStateException("현재 상태에서는 해당 처리가 불가합니다. (현재: " + prev + ")");
        }

        // 2026/07/31 장우철 — 사업자 취소 = 수수료 0 · 전액 환불
        if ("CANCEL".equals(next)) {
            stayFullCancelService.cancelWithFullRefund(resvId, stayId, cancelReason, "사업자");
            return;
        }

        int updated = bizStayMapper.updateReservationStatus(resvId, stayId, next, null);
        if (updated == 0) {
            throw new IllegalStateException("예약을 찾을 수 없거나 변경할 수 없습니다.");
        }

        String stayName = bizStayMapper.selectStayNameById(stayId);
        if (stayName == null || stayName.isBlank()) {
            stayName = "숙소";
        }
        if ("CONFIRMED".equals(next)) {
            // 2026/08/11 장우철 — 숙소 전용 확정 알림 (병원 문구 혼용 방지)
            mypageNotifyService.sendStayReserveConfirmNotification(
                    current.getMemberNo(), stayName, current.getCheckinDate(), null, resvId);
        } else if ("CHECKIN".equals(next)) {
            // 2026/08/07 장우철 — 체크인 알림
            try {
                mypageNotifyService.sendStayCheckinNotification(current.getMemberNo(), stayName, resvId);
            } catch (Exception ignored) {
            }
        } else if ("CHECKOUT".equals(next)) {
            // 2026/08/07 장우철 — 체크아웃 알림
            try {
                mypageNotifyService.sendStayCheckoutNotification(current.getMemberNo(), stayName, resvId);
            } catch (Exception ignored) {
            }
        }
    }

    /**
     * 2026/07/31 장우철 — R2 상태 전이
     * PENDING→CONFIRMED/CANCEL
     * CONFIRMED→CHECKIN/CANCEL
     * CHECKIN→CHECKOUT/CANCEL
     * CHECKOUT→ (DONE은 스케줄러만, 수동 DONE 불가)
     */
    private boolean isAllowedStatusTransition(String prev, String next) {
        if ("PENDING".equals(prev)) {
            return "CONFIRMED".equals(next) || "CANCEL".equals(next);
        }
        if ("CONFIRMED".equals(prev)) {
            return "CHECKIN".equals(next) || "CANCEL".equals(next);
        }
        if ("CHECKIN".equals(prev)) {
            return "CHECKOUT".equals(next) || "CANCEL".equals(next);
        }
        return false;
    }

    @Override
    @Transactional(readOnly = true)
    public List<ReservationVO> getCalendarReservations(Long stayId, String fromDate, String toDate) throws Exception {
        if (stayId == null) {
            return List.of();
        }
        return bizStayMapper.selectReservationCalendarList(stayId, fromDate, toDate);
    }

    @Override
    @Transactional(readOnly = true)
    // 2026-07-28 박유정 — 사이드바 예약관리 배지 (PENDING + CONFIRMED)
    public int countPendingReservations(Long stayId) throws Exception {
        if (stayId == null) {
            return 0;
        }
        return bizStayMapper.countPendingReservations(stayId);
    }

    @Override
    @Transactional(readOnly = true)
    public int countTodayConfirmedReservations(Long stayId) throws Exception {
        if (stayId == null) {
            return 0;
        }
        return bizStayMapper.countTodayConfirmedReservations(stayId);
    }

    //HYJ 26.07.29 쿠폰관리
    // 2026/08/01 장우철 — BIZ_MEMBER_NO = TB_BUSINESS.BIZ_NO (NUMBER)
    @Override
    public List<BizCouponVO> getCouponList(Long bizNo) {
        return bizStayMapper.selectCouponListByBizNo(bizNo);
    }

    @Override
    public BizCouponVO getCouponDetail(Long couponId) {
        return bizStayMapper.selectCouponById(couponId);
    }

    @Override
    public void applyCoupon(Long bizNo, BizCouponVO vo) {

         // 2026-08-13 박유정 — 빈 숫자칸 null 처리
         if (vo.getMinOrderAmt() == null) {
             vo.setMinOrderAmt(0);
           }
          if ("FIXED".equals(vo.getCouponType())) {
              vo.setMaxDiscountAmt(null);
          }
        // 쿠폰 코드 자동 생성 (CPN- + UUID 앞 8자리)
        String code = "CPN-" + UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase();
        vo.setCouponCode(code);
        vo.setBizMemberNo(bizNo);
        vo.setApprovalStatus("PENDING");
        vo.setStatusCd("INACTIVE");
        vo.setIssuedBudget(0);
        vo.setIssuedQty(0);

        bizStayMapper.insertCoupon(vo);
    }

    @Override
    public void updateCoupon(Long bizNo, BizCouponVO vo) {
        BizCouponVO existing = bizStayMapper.selectCouponById(vo.getCouponId());
        if (existing == null) {
            throw new IllegalArgumentException("COUPON_NOT_FOUND");
        }
        if (bizNo == null || !bizNo.equals(existing.getBizMemberNo())) {
            throw new IllegalStateException("NOT_OWNER");
        }
        if (!"PENDING".equals(existing.getApprovalStatus())) {
            throw new IllegalStateException("NOT_PENDING");
        }
        vo.setBizMemberNo(bizNo);
        bizStayMapper.updateCoupon(vo);
    }

    @Override
    public void deleteCoupon(Long bizNo, Long couponId) {
        BizCouponVO existing = bizStayMapper.selectCouponById(couponId);
        if (existing == null) {
            throw new IllegalArgumentException("COUPON_NOT_FOUND");
        }
        if (bizNo == null || !bizNo.equals(existing.getBizMemberNo())) {
            throw new IllegalStateException("NOT_OWNER");
        }
        if (!"PENDING".equals(existing.getApprovalStatus())) {
            throw new IllegalStateException("NOT_PENDING");
        }
        bizStayMapper.deleteCoupon(couponId, bizNo);
    }

    /**
     * 지윤 26.08.07
     * 병원/숙소 쿠폰 조기 마감 (BizStoreServiceImpl.closeCoupon과 동일 패턴)
     * 관리자 재승인 없이 사업자가 직접 마감한다.
     * 기존에 발급된 회원 쿠폰은 변경하지 않는다.
     */
    @Override
    public void closeCoupon(Long bizNo, Long couponId) {
        BizCouponVO existing = bizStayMapper.selectCouponById(couponId);

        if (existing == null) {
            throw new IllegalArgumentException("COUPON_NOT_FOUND");
        }

        // 로그인 사업자가 발급한 쿠폰인지 확인
        if (bizNo == null || !bizNo.equals(existing.getBizMemberNo())) {
            throw new IllegalStateException("NOT_OWNER");
        }

        // 관리자 승인을 받은 쿠폰만 조기 마감 가능
        if (!"APPROVED".equals(existing.getApprovalStatus())) {
            throw new IllegalStateException("NOT_APPROVED");
        }

        // 현재 게시 중인 쿠폰만 조기 마감 가능
        if (!"ACTIVE".equals(existing.getStatusCd())) {
            throw new IllegalStateException("NOT_ACTIVE");
        }

        int result = bizStayMapper.closeCoupon(couponId, bizNo);

        if (result == 0) {
            throw new IllegalStateException("CLOSE_FAILED");
        }
    }

    //
    //HYJ 26.07.31 배너관리
    //
    @Override
    public Long getBizNo(String bizId) {
        return bizStayMapper.selectBizNoByBizId(bizId);
    }

    // 2026-08-06 박유정 — 사업자 배너 목록 (조회 전 만료 처리)
    @Override
    public List<MainBannerVO> getBannerList(Long bizNo) {
        bannerExpiryService.expirePastEndDateBanners();
        List<MainBannerVO> result = bizStayMapper.selectBannerList(bizNo);
        return result;
    }

    // ── 사업자: 배너 신청 (INSERT + 이미지 업로드) ──
    @Override
    @Transactional
    public void applyBanner(MainBannerVO banner, MultipartFile image) throws Exception {
        if (image == null || image.isEmpty()) {
            throw new IllegalArgumentException("배너 이미지를 선택해 주세요.");
        }
        // 2026-08-07 박유정 — JPG/PNG/WebP만 허용 (PDF 등은 <img>에서 표시 불가)
        validateBannerImageFile(image);

        // 2026-08-06 박유정 — 종료일 과거 신청 차단 + 위치별 슬롯 제한
        validateBannerApplyPeriod(banner.getStartDate(), banner.getEndDate());

        // 2026-08-07 박유정 — 위치별 슬롯 상한 (MAIN_MID 1개)
        int maxSlots = BannerConstants.getMaxPerPosition(banner.getPositionCd());
        int occupied = mainBannerMapper.countReservedSlotsByPosition(banner.getPositionCd());
        if (occupied >= maxSlots) {
            throw new IllegalArgumentException(
                    "해당 노출 위치의 배너는 최대 " + maxSlots + "개까지 신청할 수 있습니다.");
        }

        FileVO file = fileService.uploadFile(image, "BANNER", banner.getBizNo());
        banner.setFileId(file.getFileId());

        try {
            bizStayMapper.insertBanner(banner);
        } catch (Exception e) {
            fileService.deleteFile(file.getFileId());
            throw e;
        }
    }

    // 2026-08-06 박유정 — 사업자 배너 신청 기간 검증 (종료일 < 오늘 차단)
    private void validateBannerApplyPeriod(String startDate, String endDate) {
        if (startDate == null || endDate == null || startDate.isBlank() || endDate.isBlank()) {
            throw new IllegalArgumentException("시작일과 종료일을 모두 입력해 주세요.");
        }
        if (endDate.compareTo(startDate) < 0) {
            throw new IllegalArgumentException("종료일은 시작일 이후여야 합니다.");
        }
        String today = LocalDate.now().format(DateTimeFormatter.ISO_LOCAL_DATE);
        if (endDate.compareTo(today) < 0) {
            throw new IllegalArgumentException("종료일이 지났습니다. 기간을 수정한 후 신청해 주세요.");
        }
    }

    // 2026-08-07 박유정 — 배너 이미지 형식 검증 (PDF 등 차단)
    private void validateBannerImageFile(MultipartFile image) {
        String originalName = image.getOriginalFilename();
        if (originalName != null) {
            String lower = originalName.toLowerCase();
            if (lower.endsWith(".pdf") || lower.endsWith(".doc") || lower.endsWith(".docx")
                    || lower.endsWith(".hwp") || lower.endsWith(".ppt") || lower.endsWith(".pptx")) {
                throw new IllegalArgumentException("배너는 JPG, PNG, WebP 이미지 파일만 등록할 수 있습니다.");
            }
        }
        String contentType = image.getContentType();
        if (contentType != null && !contentType.isBlank() && !contentType.startsWith("image/")) {
            throw new IllegalArgumentException("배너는 JPG, PNG, WebP 이미지 파일만 등록할 수 있습니다.");
        }
    }

    // 2026-07-27 박유정  — 사업자 숙소 리뷰 목록
    @Override
    @Transactional(readOnly = true)
    public List<StayReviewVO> getBizStayReviews(Long stayId) throws Exception {
        if (stayId == null) {
            return List.of();
        }
        return bizStayMapper.selectBizStayReviews(stayId);
    }

    // 2026-07-27 박유정  — 숙소 답글 저장
    @Override
    @Transactional
    public void saveReviewBizReply(Long stayId, Long reviewId, String bizReply) throws Exception {
        if (stayId == null || reviewId == null) {
            throw new IllegalArgumentException("리뷰 정보가 올바르지 않습니다.");
        }
        if (bizReply == null || bizReply.isBlank()) {
            throw new IllegalArgumentException("답글 내용을 입력해 주세요.");
        }
        String reply = bizReply.trim();
        if (reply.length() > 2000) {
            reply = reply.substring(0, 2000);
        }

        StayReviewVO current = bizStayMapper.selectBizStayReview(stayId, reviewId);
        if (current == null) {
            throw new IllegalStateException("리뷰를 찾을 수 없거나 권한이 없습니다.");
        }

        int updated = bizStayMapper.updateReviewBizReply(stayId, reviewId, reply);
        if (updated == 0) {
            throw new IllegalStateException("답글 저장에 실패했습니다.");
        }

        String stayName = bizStayMapper.selectStayNameById(stayId);
        mypageNotifyService.sendStayReviewReplyNotification(
        current.getMemberNo(), stayName, current.getResvId(), stayId);
    }

    // 2026-07-27 박유정  — 리뷰 삭제 요청
    @Override
    @Transactional
    public void requestReviewDelete(Long stayId, Long bizNo, Long reviewId, String requestReason) throws Exception {
        if (stayId == null || bizNo == null || reviewId == null) {
            throw new IllegalArgumentException("요청 정보가 올바르지 않습니다.");
        }
        if (requestReason == null || requestReason.isBlank()) {
            throw new IllegalArgumentException("삭제 요청 사유를 입력해 주세요.");
        }
        String reason = requestReason.trim();
        if (reason.length() > 500) {
            reason = reason.substring(0, 500);
        }

        StayReviewVO current = bizStayMapper.selectBizStayReview(stayId, reviewId);
        if (current == null) {
            throw new IllegalStateException("리뷰를 찾을 수 없거나 권한이 없습니다.");
        }

        if (bizStayMapper.countPendingReviewDeleteRequest(reviewId, bizNo) > 0) {
            throw new IllegalStateException("이미 삭제 요청이 접수된 리뷰입니다.");
        }

        ReviewDeleteRequestVO vo = new ReviewDeleteRequestVO();
        vo.setReviewId(reviewId);
        vo.setReviewType("STAY");
        vo.setTargetId(stayId);
        vo.setBizNo(bizNo);
        vo.setRequestReason(reason);
        vo.setStatusCd("PENDING");
        int inserted = bizStayMapper.insertReviewDeleteRequest(vo);
        if (inserted == 0) {
            throw new IllegalStateException("삭제 요청 접수에 실패했습니다.");
        }
    }

    // 2026-07-27 박유정 — 삭제요청 탭 목록
    @Override
    @Transactional(readOnly = true)
    public List<ReviewDeleteRequestVO> getBizReviewDeleteRequests(Long stayId, Long bizNo) throws Exception {
        if (stayId == null || bizNo == null) {
            return List.of();
        }
        return bizStayMapper.selectBizReviewDeleteRequests(stayId, bizNo);
    }

    // ── HYJ 26.08.06 대시보드 ──

    @Override
    public BizDashboardVO getDashboardData(Long stayId, int chartDays) throws Exception {
        BizDashboardVO dash = new BizDashboardVO();
        String today = java.time.LocalDate.now().toString();
        String yesterday = java.time.LocalDate.now().minusDays(1).toString();

        // 요약 카드
        dash.setTodayResvCount(bizStayMapper.countResvByDate(stayId, today));
        dash.setTodayResvYesterday(bizStayMapper.countResvByDate(stayId, yesterday));
        dash.setDoneCount(bizStayMapper.countCheckoutByDate(stayId, today));
        dash.setDoneYesterday(bizStayMapper.countCheckoutByDate(stayId, yesterday));
        dash.setPendingCount(bizStayMapper.countPendingReservations(stayId));
        dash.setPendingYesterday(0); // 대기는 누적이므로 비교 생략
        dash.setMonthRevenue(bizStayMapper.sumMonthRevenue(stayId, today));
        dash.setMonthRevenueYesterday(bizStayMapper.sumMonthRevenue(stayId, yesterday));

        // 상태 현황 (도넛)
        List<Map<String, Object>> statusList = bizStayMapper.countByStatus(stayId);
        int total = 0;
        for (Map<String, Object> row : statusList) {
            String st = (String) row.get("STATUS_CD");
            int cnt = ((Number) row.get("CNT")).intValue();
            total += cnt;
            if ("CONFIRMED".equals(st)) dash.setStatusConfirmed(cnt);
            else if ("PENDING".equals(st)) dash.setStatusPending(cnt);
            else if ("CHECKIN".equals(st)) dash.setStatusCheckin(cnt);
            else if ("CHECKOUT".equals(st)) dash.setStatusCheckout(cnt);
            else if ("DONE".equals(st)) dash.setStatusDone(cnt);
            else if ("CANCEL".equals(st) || "REJECTED".equals(st))
                dash.setStatusCancel(dash.getStatusCancel() + cnt);
        }
        dash.setTotalStatusCount(total);

        // 차트 (일별)
        List<com.petcare.petcare.biz.vo.DailyStatVO> dailyList = bizStayMapper.selectDailyStats(stayId, chartDays);
        List<String> labels = new ArrayList<>();
        List<Integer> counts = new ArrayList<>();
        List<Long> revenues = new ArrayList<>();
        for (com.petcare.petcare.biz.vo.DailyStatVO d : dailyList) {
            labels.add(d.getDt());
            counts.add(d.getResvCount());
            revenues.add(d.getRevenue());
        }
        dash.setChartLabels(labels);
        dash.setChartResvCounts(counts);
        dash.setChartRevenues(revenues);

        return dash;
    }

    @Override
    public List<com.petcare.petcare.stay.vo.ReservationVO> getTodayCheckinList(Long stayId) {
        return bizStayMapper.selectTodayCheckinList(stayId);
    }

    @Override
    public List<com.petcare.petcare.stay.vo.StayReviewVO> getRecentReviews(Long stayId) {
        return bizStayMapper.selectRecentReviews(stayId);
    }

    // 2026-08-11 박유정 — 사업자 숙소 환불신청 대기 건수
    @Override
    @Transactional(readOnly = true)
    public int countPendingStayRefundRequests(Long stayId) {
        if (stayId == null) {
            return 0;
        }
        return memberInquiryMapper.countPendingStayRefundByStayId(stayId);
    }

    // 2026-08-11 박유정 — 사업자 숙소 환불신청 목록
    @Override
    @Transactional(readOnly = true)
    public List<MemberInquiryVO> getStayRefundList(Long stayId, String statusCd) {
        if (stayId == null) {
            return List.of();
        }
        String status = (statusCd == null || statusCd.isBlank() || "ALL".equalsIgnoreCase(statusCd))
                ? null : statusCd.trim().toUpperCase();
        return memberInquiryMapper.selectStayRefundListByStayId(stayId, status);
    }

    // 2026/08/18 장우철 — 사업자 숙소 환불 탭별 건수 (전체·대기·처리완료·거절)
    @Override
    @Transactional(readOnly = true)
    public Map<String, Integer> getStayRefundStatusCounts(Long stayId) {
        Map<String, Integer> counts = new HashMap<>();
        if (stayId == null) {
            counts.put("ALL", 0);
            counts.put("WAIT", 0);
            counts.put("DONE", 0);
            counts.put("REJECTED", 0);
            return counts;
        }
        int wait = memberInquiryMapper.countStayRefundByStayId(stayId, "WAIT");
        int done = memberInquiryMapper.countStayRefundByStayId(stayId, "DONE");
        int rejected = memberInquiryMapper.countStayRefundByStayId(stayId, "REJECTED");
        counts.put("WAIT", wait);
        counts.put("DONE", done);
        counts.put("REJECTED", rejected);
        counts.put("ALL", wait + done + rejected);
        return counts;
    }
}
