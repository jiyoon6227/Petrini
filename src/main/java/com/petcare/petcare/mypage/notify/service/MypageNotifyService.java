/**
 * 역할: 마이페이지 알림 비즈니스 로직 (interface)
 *
 * 담당 화면
 * - mypage/notifications.jsp  알림 목록
 * - mypage/notification-detail.jsp 알림 상세
 *
 * 구현할 기능 예시
 * - 알림 목록·상세 조회
 * - 읽음 처리
 *
 * 연결
 * - 구현: MypageNotifyServiceImpl
 * - 호출: MypageNotifyController
 * - DB: MypageNotifyMapper
 *
 * 참고 테이블
 * - TB_NOTIFICATION
 */

package com.petcare.petcare.mypage.notify.service;

import java.util.List;

import com.petcare.petcare.mypage.notify.vo.MypageNotifyVO;

public interface MypageNotifyService {

    // =====================================================================
    // 2026/08/11 장우철 — 알림 메서드 도메인별 정리
    // 병원 → 쇼핑 → 숙소 → 커뮤니티 → 기타(공통/관리자)
    // =====================================================================

    // ========== 1. 병원 (HOSPITAL) ==========

    // ----- 1-1. 유저 → 사업자 -----

    // 2026/08/07 장우철 — 미구현 알림 보강 (쿠폰·공지/FAQ·이메일/FCM·커뮤니티 댓글 제외)

    /** 병원 신규 예약(PENDING) → 사업자 */
    void sendHospitalReserveToBizNotification(Long bizMemberNo, String hospitalName,
                                              java.util.Date resvDate, String resvTime, Long resvId);

    // 2026/07/13 장우철 — 유저 리뷰 등록 → 사업자(병원 회원) 알림
    void sendHospitalReviewToBizNotification(Long bizMemberNo, String hospitalName,
                                             String reviewerNickname, Double rating, Long resvId);

    // ----- 1-2. 사업자 → 유저 -----

    // 2026/07/11 장우철 — 병원 예약 확정/취소 알림 (NOTI_TYPE=RESERVE)
    // resvId: 3차에서 상세 이동용 linkUrl 에 사용 (2차 상세 URL 미리 연결)
    void sendReserveConfirmNotification(Long memberNo, String hospitalName, java.util.Date resvDate,
                                        String resvTime, Long resvId);

    void sendReserveCancelNotification(Long memberNo, String hospitalName, java.util.Date resvDate,
                                       String resvTime, String cancelReason, Long resvId);

    // 2026-08-11 박유정 — 숙소 예약 취소 알림 (병원 문구와 분리)
    void sendStayReserveCancelNotification(Long memberNo, String stayName,
                                           java.util.Date checkinDate, java.util.Date checkoutDate,
                                           String cancelReason, Long resvId);

    // 2026-08-11 박유정 — 숙소 환불 신청·처리 알림
    void sendStayRefundRequestToBizNotification(Long bizMemberNo, String stayName,
                                                String resvNo, java.util.Date applyDate, Long resvId);
    void sendStayRefundRequestToMemberNotification(Long memberNo, String stayName,
                                                   java.util.Date applyDate, Long resvId);
    void sendStayRefundApprovedToMemberNotification(Long memberNo, String stayName,
                                                    java.util.Date applyDate, Long refundAmount, Long resvId);
    void sendStayRefundRejectedToMemberNotification(Long memberNo, String stayName,
                                                    java.util.Date applyDate, String rejectReason, Long resvId);

    // 2026/07/13 장우철 — 진료완료 알림 → 예약 상세(리뷰 작성)
    void sendReserveDoneNotification(Long memberNo, String hospitalName, java.util.Date resvDate,
                                     String resvTime, Long resvId);

    // 2026/07/14 장우철 — 병원 답글 → 리뷰 작성 회원 알림
    void sendHospitalReviewReplyNotification(Long memberNo, String hospitalName,
                                             Long resvId, Long hospitalId);

    // ========== 2. 쇼핑 (STORE) ==========

    // ----- 2-1. 유저/시스템 → 사업자 -----

    // 2026-07-21 지윤 추가 — 신규 주문 알림 → 사업자 회원 알림함 "주문" 탭
    void sendNewOrderNotification(Long bizMemberNo, String orderNo, String productName, int itemCount);

    // 2026-07-16 지윤 — 상품 품절 알림 → 사업자 회원 알림함 "재고" 탭
    void sendProductSoldoutNotification(Long bizMemberNo, String productName, Long productId);

    // 2026-07-23 지윤 추가 — 주문취소 신청 알림 → 사업자 회원 알림함 "주문" 탭
    void sendCancelRequestNotification(Long bizMemberNo, String orderNo, String reason);

    // 2026/08/04 장우철 — 상품 환불 신청 알림 → 사업자 (환불신청 페이지)
    void sendRefundRequestNotification(Long bizMemberNo, String orderNo, String productName, String reasonCd);

    // ----- 2-2. 사업자 → 유저 -----

    /** 주문취소 승인/거절 → 구매자 */
    void sendCancelApproveToBuyerNotification(Long memberNo, String orderNo);

    void sendCancelRejectToBuyerNotification(Long memberNo, String orderNo);

    /** 배송중 / 배송완료 → 구매자 */
    void sendOrderShippingToBuyerNotification(Long memberNo, String orderNo);

    void sendOrderDeliveredToBuyerNotification(Long memberNo, String orderNo);

    // 2026/08/04 장우철 — 환불 승인/거절/완료 → 구매자 알림
    void sendRefundApproveToBuyerNotification(Long memberNo, String orderNo, String productName, String returnReasonCd);

    void sendRefundRejectToBuyerNotification(Long memberNo, String orderNo, String productName, String rejectReason);

    void sendRefundDoneToBuyerNotification(Long memberNo, String orderNo, String productName, int refundAmount);

    // ----- 2-3. 관리자 → 사업자 (정산) -----

    /**
     * 2026/08/05 장우철 — 쇼핑 중간정산 승인/거절 · 더미 지급 알림
     */
    void sendStoreMidSettleApproveNotification(Long memberNo, String bizName,
                                               String periodStart, String periodEnd,
                                               String requestScope, Long settleAmount);

    void sendStoreMidSettleRejectNotification(Long memberNo, String bizName,
                                              String periodStart, String periodEnd,
                                              String rejectReason);

    void sendStoreSettlementPaidNotification(Long memberNo, String bizName,
                                             String periodStart, String periodEnd,
                                             String requestType, Long settleAmount);

    // ========== 3. 숙소 (STAY) ==========

    // ----- 3-1. 유저/시스템 → 사업자 -----

    // 2026-07-28 박유정 — 숙소 예약 결제 완료 → 사업자 알림
    void sendStayReserveToBizNotification(Long bizMemberNo, String stayName,
                                          java.util.Date checkinDate, java.util.Date checkoutDate,
                                          Long resvId);

    // 2026-07-28 박유정 — 유저 리뷰 등록 → 사업자(숙소 회원) 알림
    void sendStayReviewToBizNotification(Long bizMemberNo, String stayName,
                                         String reviewerNickname, Double rating, Long resvId);

    // ----- 3-2. 사업자/스케줄/취소 → 유저 -----

    // 2026/08/11 장우철 — 숙소 예약 확정/취소 알림 (병원 메서드와 문구 분리)
    void sendStayReserveConfirmNotification(Long memberNo, String stayName, java.util.Date resvDate,
                                            String resvTime, Long resvId);

    void sendStayReserveCancelNotification(Long memberNo, String stayName, java.util.Date resvDate,
                                           String resvTime, String cancelReason, Long resvId);

    /** 숙소 체크인 / 체크아웃 / 이용완료 → 회원 */
    void sendStayCheckinNotification(Long memberNo, String stayName, Long resvId);

    void sendStayCheckoutNotification(Long memberNo, String stayName, Long resvId);

    void sendStayDoneNotification(Long memberNo, String stayName, Long resvId);

    /** 숙소 보상환불(이용 유지) → 회원 */
    void sendStayCompensationRefundNotification(Long memberNo, String stayName, long refundAmount, Long resvId);

    // 2026-07-28 박유정 — 숙소 답글 → 리뷰 작성 회원 알림
    void sendStayReviewReplyNotification(Long memberNo, String stayName,
                                     Long resvId, Long stayId);

    // ----- 3-3. 관리자 → 사업자 (정산) -----

    /**
     * 2026/07/30 장우철 — 숙소 중간정산 승인/거절 사이트 알림 (5-4 B/C)
     * NOTI_TYPE=SYSTEM, 이메일 아님 · TB_NOTIFICATION 만
     */
    void sendStayMidSettleApproveNotification(Long memberNo, String bizName,
                                              String periodStart, String periodEnd,
                                              String requestScope, Long settleAmount);

    void sendStayMidSettleRejectNotification(Long memberNo, String bizName,
                                             String periodStart, String periodEnd,
                                             String rejectReason);

    /**
     * 2026/07/30 장우철 — 숙소 정산 더미 지급 완료 알림 (5-4 D)
     */
    void sendStaySettlementPaidNotification(Long memberNo, String bizName,
                                            String periodStart, String periodEnd,
                                            String requestType, Long settleAmount);

    // ========== 4. 커뮤니티 ==========

    // ----- 관리자 → 유저 -----

    /** 커뮤니티 신고 조치(숨김/삭제) → 작성자 */
    void sendCommunityPostHiddenNotification(Long memberNo, String postTitle, Long postId);

    void sendCommunityPostDeletedNotification(Long memberNo, String postTitle);

    // ========== 5. 기타 (병원/쇼핑/숙소/커뮤니티 외) ==========

    // ----- 관리자 → 신청자(유저) : 사업자 등록 -----

    // 2026-07-10 장우철 — 사업자 승인 알림 INSERT (문구는 ServiceImpl 에서 수정 가능)
    void sendBizApproveNotification(Long memberNo, String bizName, String bizType);

    void sendBizRejectNotification(Long memberNo, String bizName, String rejectReason);

    // ----- 관리자 → 사업자 : 리뷰삭제 -----

    // 2026-07-24 박유정 — 리뷰 삭제 요청 승인 알림 (사업자)
    void sendReviewDeleteApproveNotification(Long bizMemberNo, String targetName,
                                             Long reviewId, String linkUrl);

    // 2026-07-24 박유정 — 리뷰 삭제 요청 반려 알림 (사업자)
    void sendReviewDeleteRejectNotification(Long bizMemberNo, String targetName,
                                            String rejectReason, String linkUrl);

    // ----- 관리자 → 사업자 : 배너 -----

    // 2026-08-06 박유정 — 배너 신청 승인 알림 (사업자)
    void sendBannerApproveNotification(Long memberNo, String bannerTitle, String positionLabel, String linkUrl);

    // 2026-08-06 박유정 — 배너 신청 대기(노출예정) 알림 (사업자)
    void sendBannerHoldNotification(Long memberNo, String bannerTitle, String positionLabel, String holdReason, String linkUrl);

    // 2026-08-06 박유정 — 배너 신청 반려 알림 (사업자)
    void sendBannerRejectNotification(Long memberNo, String bannerTitle, String positionLabel, String rejectReason, String linkUrl);

    /** 재능나눔 참여 신청 → 병원 사업자 알림 — 2026-08-10 박유정 */
    void sendTalentApplyToBizNotification(Long bizMemberNo, String talentTitle,
                                          String applicantNickname, String linkUrl);

    /** 재능나눔 신청 확인 → 신청 회원 알림 — 2026-08-10 박유정 */
    void sendTalentApplyConfirmNotification(Long memberNo, String talentTitle,
                                            String bizName, String linkUrl);

    // ========== 6. 알림함 조회/읽음/삭제 (CRUD) ==========

    // 2026-07-09 장우철 — 알림함 목록·상세 (DB only, 이메일/FCM 은 후속 API)
    List<MypageNotifyVO> getNotificationList(Long memberNo);

    MypageNotifyVO getNotificationDetail(Long notiId, Long memberNo);

    // 2026-07-10 장우철 — 알림함 전체 읽음 / 전체 삭제
    int markAllNotificationsRead(Long memberNo);

    int deleteAllNotifications(Long memberNo);

    // 2026/07/11 장우철 — 헤더 미읽음 알림 배지
    int countUnreadNotifications(Long memberNo);
}
