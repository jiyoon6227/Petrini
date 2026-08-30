/**
 * 역할: MypageNotifyService 구현체 (@Service)
 *
 * 연결
 * - implements: MypageNotifyService
 * - 사용: MypageNotifyMapper
 */

package com.petcare.petcare.mypage.notify.service;

import java.util.Collections;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.mypage.notify.mapper.MypageNotifyMapper;
import com.petcare.petcare.mypage.notify.vo.MypageNotifyVO;

@Service
public class MypageNotifyServiceImpl implements MypageNotifyService {

    @Autowired
    private MypageNotifyMapper mypageNotifyMapper;

    // =====================================================================
    // 2026/08/11 장우철 — 알림 메서드 도메인별 정리
    // 병원 → 쇼핑 → 숙소 → 커뮤니티 → 기타(공통/관리자)
    // =====================================================================

    // ========== 1. 병원 (HOSPITAL) ==========

    // ----- 1-1. 유저 → 사업자 -----

    // ── 2026/08/07 장우철 — 미구현 알림 보강 ──

    @Override
    @Transactional
    public void sendHospitalReserveToBizNotification(Long bizMemberNo, String hospitalName,
                                                     java.util.Date resvDate, String resvTime, Long resvId) {
        if (bizMemberNo == null) {
            return;
        }
        String name = (hospitalName != null && !hospitalName.isBlank()) ? hospitalName.trim() : "병원";
        String when = formatResvWhen(resvDate, resvTime);
        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(bizMemberNo);
        vo.setNotiType("RESERVE");
        vo.setTitle("새 병원 예약이 접수되었습니다");
        vo.setContent("[" + name + "] " + when + " 예약이 접수되었습니다. 확정 여부를 확인해 주세요.");
        vo.setLinkUrl("/biz/hospital/reserve");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    // 2026/07/13 장우철 — 리뷰 등록 → 사업자 알림
    @Override
    @Transactional
    public void sendHospitalReviewToBizNotification(Long bizMemberNo, String hospitalName,
                                                    String reviewerNickname, Double rating, Long resvId) {
        if (bizMemberNo == null) {
            return;
        }
        String safeName = hospitalName != null ? hospitalName : "병원";
        String who = (reviewerNickname != null && !reviewerNickname.isBlank()) ? reviewerNickname : "회원";
        String star = rating != null ? String.valueOf(rating) : "-";
        String content = "[" + safeName + "] 새 진료 리뷰가 등록되었습니다.\n\n작성자: " + who
                + "\n별점: " + star;

        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(bizMemberNo);
        vo.setNotiType("RESERVE");
        vo.setTitle("병원 리뷰가 등록되었습니다");
        vo.setContent(content.length() > 500 ? content.substring(0, 497) + "..." : content);
        vo.setLinkUrl("/biz/hospital/reviews");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    // ----- 1-2. 사업자 → 유저 -----

    // 2026/07/11 장우철 — 병원 예약 확정 알림
    @Override
    @Transactional
    public void sendReserveConfirmNotification(Long memberNo, String hospitalName,
                                               java.util.Date resvDate, String resvTime, Long resvId) {
        if (memberNo == null) {
            return;
        }
        String when = formatResvWhen(resvDate, resvTime);
        String safeName = hospitalName != null ? hospitalName : "병원";
        String content = "[" + safeName + "] 예약이 확정되었습니다.\n\n예약 일시: " + when;

        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("RESERVE");
        vo.setTitle("병원 예약이 확정되었습니다");
        vo.setContent(content.length() > 500 ? content.substring(0, 497) + "..." : content);
        vo.setLinkUrl(resvId != null ? "/mypage/reserve/detail?resvId=" + resvId : "/mypage/reserve");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    // 2026/07/11 장우철 — 병원 예약 취소 알림 (취소 사유 포함)
    @Override
    @Transactional
    public void sendReserveCancelNotification(Long memberNo, String hospitalName,
                                              java.util.Date resvDate, String resvTime,
                                              String cancelReason, Long resvId) {
        if (memberNo == null) {
            return;
        }
        String when = formatResvWhen(resvDate, resvTime);
        String safeName = hospitalName != null ? hospitalName : "병원";
        String reason = (cancelReason != null && !cancelReason.isBlank()) ? cancelReason.trim() : "-";
        String content = "[" + safeName + "] 예약이 취소되었습니다.\n\n예약 일시: " + when
                + "\n취소 사유: " + reason;
        if (content.length() > 500) {
            content = content.substring(0, 497) + "...";
        }

        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("RESERVE");
        vo.setTitle("병원 예약이 취소되었습니다");
        vo.setContent(content);
        vo.setLinkUrl(resvId != null ? "/mypage/reserve/detail?resvId=" + resvId : "/mypage/reserve");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    // 2026-08-11 박유정 — 숙소 예약 취소 알림
    @Override
    @Transactional
    public void sendStayReserveCancelNotification(Long memberNo, String stayName,
                                                  java.util.Date checkinDate, java.util.Date checkoutDate,
                                                  String cancelReason, Long resvId) {
        if (memberNo == null) {
            return;
        }
        String period = formatStayPeriod(checkinDate, checkoutDate);
        String safeName = stayName != null ? stayName : "숙소";
        String reason = (cancelReason != null && !cancelReason.isBlank()) ? cancelReason.trim() : "-";
        String content = "[" + safeName + "] 예약이 취소되었습니다.\n\n숙박 기간: " + period
                + "\n취소 사유: " + reason;
        if (content.length() > 500) {
            content = content.substring(0, 497) + "...";
        }

        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("RESERVE");
        vo.setTitle("숙소 예약이 취소되었습니다");
        vo.setContent(content);
        vo.setLinkUrl(resvId != null ? "/mypage/reserve/detail?resvId=" + resvId : "/mypage/reserve");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    // 2026-08-11 박유정 — 숙소 환불 신청 → 사업자 알림
    @Override
    @Transactional
    public void sendStayRefundRequestToBizNotification(Long bizMemberNo, String stayName,
                                                       String resvNo, java.util.Date applyDate, Long resvId) {
        if (bizMemberNo == null) {
            return;
        }
        String safeName = stayName != null ? stayName : "숙소";
        String safeResvNo = (resvNo != null && !resvNo.isBlank()) ? resvNo : String.valueOf(resvId);
        String content = "[" + safeName + "] 환불 신청이 접수되었습니다.\n\n"
                + "예약번호: " + safeResvNo + "\n"
                + "환불 신청일시: " + formatDateTime(applyDate) + "\n"
                + "처리 상태: 대기\n\n"
                + "환불 신청 메뉴에서 확인해 주세요. (관리자 승인 후 환불됩니다)";

        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(bizMemberNo);
        vo.setNotiType("RESERVE");
        vo.setTitle("숙소 환불 신청이 접수되었습니다");
        vo.setContent(content.length() > 500 ? content.substring(0, 497) + "..." : content);
        vo.setLinkUrl("/biz/stay/refunds?status=WAIT");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    // 2026-08-11 박유정 — 숙소 환불 신청 접수 → 회원 알림
    @Override
    @Transactional
    public void sendStayRefundRequestToMemberNotification(Long memberNo, String stayName,
                                                          java.util.Date applyDate, Long resvId) {
        if (memberNo == null) {
            return;
        }
        String safeName = stayName != null ? stayName : "숙소";
        String content = "[" + safeName + "] 환불 신청이 접수되었습니다.\n\n"
                + "환불 신청일시: " + formatDateTime(applyDate) + "\n"
                + "환불 승인: 대기\n"
                + "환불: 미처리";

        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("RESERVE");
        vo.setTitle("숙소 환불 신청이 접수되었습니다");
        vo.setContent(content);
        vo.setLinkUrl(resvId != null ? "/mypage/reserve/detail?resvId=" + resvId : "/mypage/reserve");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    // 2026-08-11 박유정 — 숙소 환불 승인 → 회원 알림 (예약 취소 문구 없음)
    @Override
    @Transactional
    public void sendStayRefundApprovedToMemberNotification(Long memberNo, String stayName,
                                                           java.util.Date applyDate, Long refundAmount,
                                                           Long resvId) {
        if (memberNo == null) {
            return;
        }
        String safeName = stayName != null ? stayName : "숙소";
        String amountText = refundAmount != null ? String.format("%,d원 환불 완료", refundAmount) : "환불 완료";
        String content = "[" + safeName + "] 환불이 승인되었습니다.\n\n"
                + "환불 신청일시: " + formatDateTime(applyDate) + "\n"
                + "환불 승인: 승인\n"
                + "환불: " + amountText;

        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("RESERVE");
        vo.setTitle("숙소 환불이 승인되었습니다");
        vo.setContent(content.length() > 500 ? content.substring(0, 497) + "..." : content);
        vo.setLinkUrl(resvId != null ? "/mypage/reserve/detail?resvId=" + resvId : "/mypage/reserve");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    // 2026-08-11 박유정 — 숙소 환불 거절 → 회원 알림
    @Override
    @Transactional
    public void sendStayRefundRejectedToMemberNotification(Long memberNo, String stayName,
                                                           java.util.Date applyDate, String rejectReason,
                                                           Long resvId) {
        if (memberNo == null) {
            return;
        }
        String safeName = stayName != null ? stayName : "숙소";
        String reason = (rejectReason != null && !rejectReason.isBlank()) ? rejectReason.trim() : "-";
        String content = "[" + safeName + "] 환불 신청이 거절되었습니다.\n\n"
                + "환불 신청일시: " + formatDateTime(applyDate) + "\n"
                + "환불 승인: 거절\n"
                + "환불: 없음\n"
                + "거절 사유: " + reason;

        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("RESERVE");
        vo.setTitle("숙소 환불 신청이 거절되었습니다");
        vo.setContent(content.length() > 500 ? content.substring(0, 497) + "..." : content);
        vo.setLinkUrl(resvId != null ? "/mypage/reserve/detail?resvId=" + resvId : "/mypage/reserve");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    // 2026/07/13 장우철 — 진료완료 알림 (상세에서 리뷰 작성)
    @Override
    @Transactional
    public void sendReserveDoneNotification(Long memberNo, String hospitalName,
                                            java.util.Date resvDate, String resvTime, Long resvId) {
        if (memberNo == null) {
            return;
        }
        String when = formatResvWhen(resvDate, resvTime);
        String safeName = hospitalName != null ? hospitalName : "병원";
        String content = "[" + safeName + "] 진료가 완료되었습니다.\n\n예약 일시: " + when
                + "\n예약 상세에서 진료 내용을 확인하고 리뷰를 작성해 주세요.";

        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("RESERVE");
        vo.setTitle("병원 진료가 완료되었습니다");
        vo.setContent(content.length() > 500 ? content.substring(0, 497) + "..." : content);
        vo.setLinkUrl(resvId != null ? "/mypage/reserve/detail?resvId=" + resvId : "/mypage/reserve");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    // 2026/07/14 장우철 — 병원 답글 → 회원 알림
    @Override
    @Transactional
    public void sendHospitalReviewReplyNotification(Long memberNo, String hospitalName,
                                                    Long resvId, Long hospitalId) {
        if (memberNo == null) {
            return;
        }
        String safeName = hospitalName != null ? hospitalName : "병원";
        String content = "[" + safeName + "] 회원님의 리뷰에 병원 답글이 등록되었습니다.";

        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("RESERVE");
        vo.setTitle("병원 리뷰 답글이 등록되었습니다");
        vo.setContent(content.length() > 500 ? content.substring(0, 497) + "..." : content);
        if (hospitalId != null) {
            vo.setLinkUrl("/hospital/detail?id=" + hospitalId);
        } else if (resvId != null) {
            vo.setLinkUrl("/mypage/reserve/detail?resvId=" + resvId);
        } else {
            vo.setLinkUrl("/mypage/reserve");
        }
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    // ========== 2. 쇼핑 (STORE) ==========

    // ----- 2-1. 유저/시스템 → 사업자 -----

     // 2026-07-21 지윤 추가 — 신규 주문 알림 (알림함 "주문" 탭은 NOTI_TYPE='ORDER' 기준으로 필터링됨)
    @Override
    @Transactional
    public void sendNewOrderNotification(Long bizMemberNo, String orderNo, String productName, int itemCount) {
        if (bizMemberNo == null) {
            return;
        }
        String safeName = productName != null ? productName : "상품";
        String extra = itemCount > 1 ? " 외 " + (itemCount - 1) + "건" : "";
        String content = "[" + safeName + extra + "] 주문이 새로 접수되었습니다.\n\n주문번호: " + orderNo + "\n주문 관리에서 확인해 주세요.";

        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(bizMemberNo);
        vo.setNotiType("ORDER");
        vo.setTitle("새 주문이 들어왔습니다");
        vo.setContent(content.length() > 500 ? content.substring(0, 497) + "..." : content);

        vo.setLinkUrl("/biz/store/orders");
        vo.setIsRead("N");

        mypageNotifyMapper.insertNotification(vo);
    }

    // 2026-07-16 지윤 — 상품 품절 시 사업자에게 알림 (NOTI_TYPE=STOCK)
    @Override
    @Transactional
    public void sendProductSoldoutNotification(Long bizMemberNo, String productName, Long productId) {
        if (bizMemberNo == null) {
            return;
        }
        String safeName = productName != null ? productName : "상품";
        String content = "[" + safeName + "] 상품의 재고가 모두 소진되어 품절 처리되었습니다.\n\n상품 관리에서 재고를 추가하거나 상태를 변경해 주세요.";

        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(bizMemberNo);
        vo.setNotiType("STOCK");
        vo.setTitle("상품이 품절되었습니다");
        vo.setContent(content.length() > 500 ? content.substring(0, 497) + "..." : content);
        vo.setLinkUrl("/biz/store/products");
        vo.setIsRead("N");

        mypageNotifyMapper.insertNotification(vo);
    }

    // 2026-07-23 지윤 추가 — 주문취소 신청 알림 (알림함 "주문" 탭은 NOTI_TYPE='ORDER' 기준으로 필터링됨)
    @Override
    @Transactional
    public void sendCancelRequestNotification(Long bizMemberNo, String orderNo, String reason) {
        if (bizMemberNo == null) {
            return;
        }
        String safeReason = (reason != null && !reason.isBlank()) ? reason : "사유 없음";
        String content = "주문번호 " + orderNo + " 건에 대해 구매자가 취소를 신청했습니다.\n\n신청사유: " + safeReason
                + "\n\n주문 관리 > 배송전취소 탭에서 확인해 주세요.";

        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(bizMemberNo);
        vo.setNotiType("ORDER");
        vo.setTitle("주문취소 신청이 접수되었습니다");
        vo.setContent(content.length() > 500 ? content.substring(0, 497) + "..." : content);
        vo.setLinkUrl("/biz/store/orders?statusCd=CLAIM_PENDING");
        vo.setIsRead("N");

        mypageNotifyMapper.insertNotification(vo);
    }

    // 2026/08/04 장우철 — 상품 환불 신청 → 사업자
    @Override
    @Transactional
    public void sendRefundRequestNotification(Long bizMemberNo, String orderNo, String productName, String reasonCd) {
        if (bizMemberNo == null) {
            return;
        }
        String reasonLabel = "DEFECT".equals(reasonCd) ? "상품이상" : "단순변심";
        String safeProduct = productName != null ? productName : "상품";
        String content = "주문번호 " + orderNo + " / " + safeProduct
                + "\n환불 유형: " + reasonLabel
                + "\n\n주문 관리 > 환불신청에서 승인·거절해 주세요.";

        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(bizMemberNo);
        vo.setNotiType("ORDER");
        vo.setTitle("환불 신청이 접수되었습니다");
        vo.setContent(content.length() > 500 ? content.substring(0, 497) + "..." : content);
        vo.setLinkUrl("/biz/store/refunds?statusCd=REQUESTED");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    // ----- 2-2. 사업자 → 유저 -----

    @Override
    @Transactional
    public void sendCancelApproveToBuyerNotification(Long memberNo, String orderNo) {
        if (memberNo == null) {
            return;
        }
        String no = (orderNo != null && !orderNo.isBlank()) ? orderNo.trim() : "-";
        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("ORDER");
        vo.setTitle("주문 취소가 승인되었습니다");
        vo.setContent("주문번호 " + no + " 취소가 승인되어 환불이 진행됩니다.");
        vo.setLinkUrl("/mypage/orders");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    @Override
    @Transactional
    public void sendCancelRejectToBuyerNotification(Long memberNo, String orderNo) {
        if (memberNo == null) {
            return;
        }
        String no = (orderNo != null && !orderNo.isBlank()) ? orderNo.trim() : "-";
        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("ORDER");
        vo.setTitle("주문 취소가 거절되었습니다");
        vo.setContent("주문번호 " + no + " 취소 신청이 거절되었습니다.");
        vo.setLinkUrl("/mypage/orders");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    @Override
    @Transactional
    public void sendOrderShippingToBuyerNotification(Long memberNo, String orderNo) {
        if (memberNo == null) {
            return;
        }
        String no = (orderNo != null && !orderNo.isBlank()) ? orderNo.trim() : "-";
        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("ORDER");
        vo.setTitle("상품이 배송중입니다");
        vo.setContent("주문번호 " + no + " 상품이 배송을 시작했습니다.");
        vo.setLinkUrl("/mypage/orders");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    @Override
    @Transactional
    public void sendOrderDeliveredToBuyerNotification(Long memberNo, String orderNo) {
        if (memberNo == null) {
            return;
        }
        String no = (orderNo != null && !orderNo.isBlank()) ? orderNo.trim() : "-";
        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("ORDER");
        vo.setTitle("상품이 배송완료되었습니다");
        vo.setContent("주문번호 " + no + " 배송이 완료되었습니다. 구매확정·리뷰를 남겨 주세요.");
        vo.setLinkUrl("/mypage/orders?statusCd=DONE");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    @Override
    @Transactional
    public void sendRefundApproveToBuyerNotification(Long memberNo, String orderNo, String productName, String returnReasonCd) {
        if (memberNo == null) return;
        String safeProduct = productName != null ? productName : "상품";
        String feeGuide = "DEFECT".equalsIgnoreCase(returnReasonCd)
                ? "(반송비 3,000원 환급, 카드 잔액 한도)"
                : "(반송비는 직접 선불, 환불금 미차감)";
        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("ORDER");
        vo.setTitle("환불이 승인되었습니다");
        vo.setContent("주문 " + orderNo + " / " + safeProduct
                + "\n상품을 반송해 주세요. 사업자가 회수 확인 후 환불됩니다. " + feeGuide);
        vo.setLinkUrl("/mypage/orders");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    @Override
    @Transactional
    public void sendRefundRejectToBuyerNotification(Long memberNo, String orderNo, String productName, String rejectReason) {
        if (memberNo == null) return;
        String safeProduct = productName != null ? productName : "상품";
        String reason = (rejectReason != null && !rejectReason.isBlank()) ? rejectReason : "사유 없음";
        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("ORDER");
        vo.setTitle("환불 신청이 거절되었습니다");
        vo.setContent("주문 " + orderNo + " / " + safeProduct + "\n거절 사유: " + reason);
        vo.setLinkUrl("/mypage/orders");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    @Override
    @Transactional
    public void sendRefundDoneToBuyerNotification(Long memberNo, String orderNo, String productName, int refundAmount) {
        if (memberNo == null) return;
        String safeProduct = productName != null ? productName : "상품";
        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("ORDER");
        vo.setTitle("환불이 완료되었습니다");
        vo.setContent("주문 " + orderNo + " / " + safeProduct
                + "\n환불금액: " + String.format("%,d", refundAmount) + "원");
        vo.setLinkUrl("/mypage/orders");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    // ----- 2-3. 관리자 → 사업자 (정산) -----

    // 2026/08/05 장우철 — 쇼핑 중간정산 승인 알림
    @Override
    @Transactional
    public void sendStoreMidSettleApproveNotification(Long memberNo, String bizName,
                                                      String periodStart, String periodEnd,
                                                      String requestScope, Long settleAmount) {
        if (memberNo == null) {
            return;
        }
        String safeBiz = bizName != null ? bizName : "쇼핑몰";
        String scopeLabel = "PRODUCT".equalsIgnoreCase(requestScope) ? "특정 상품" : "상품 전체";
        String amountText = settleAmount == null ? "-" : String.format("%,d원", settleAmount);
        String content = "[" + safeBiz + "] 중간정산 요청이 승인되었습니다.\n\n"
                + "기간: " + nullToDash(periodStart) + " ~ " + nullToDash(periodEnd) + "\n"
                + "범위: " + scopeLabel + "\n"
                + "정산금: " + amountText + "\n"
                + "지급은 관리자 처리 후 정산 내역에서 확인할 수 있습니다.";

        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("SYSTEM");
        vo.setTitle("중간정산 요청이 승인되었습니다");
        vo.setContent(content.length() > 500 ? content.substring(0, 497) + "..." : content);
        vo.setLinkUrl("/biz/store/settlement");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    // 2026/08/05 장우철 — 쇼핑 중간정산 거절 알림
    @Override
    @Transactional
    public void sendStoreMidSettleRejectNotification(Long memberNo, String bizName,
                                                     String periodStart, String periodEnd,
                                                     String rejectReason) {
        if (memberNo == null) {
            return;
        }
        String safeBiz = bizName != null ? bizName : "쇼핑몰";
        String safeReason = rejectReason != null ? rejectReason.trim() : "";
        if (safeReason.length() > 400) {
            safeReason = safeReason.substring(0, 400) + "...";
        }
        String content = "[" + safeBiz + "] 중간정산 요청이 거절되었습니다.\n\n"
                + "기간: " + nullToDash(periodStart) + " ~ " + nullToDash(periodEnd) + "\n"
                + "거절 사유:\n" + safeReason;

        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("SYSTEM");
        vo.setTitle("중간정산 요청이 거절되었습니다");
        vo.setContent(content.length() > 500 ? content.substring(0, 497) + "..." : content);
        vo.setLinkUrl("/biz/store/settlement");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    // 2026/08/05 장우철 — 쇼핑 정산 더미 지급 완료 알림
    @Override
    @Transactional
    public void sendStoreSettlementPaidNotification(Long memberNo, String bizName,
                                                    String periodStart, String periodEnd,
                                                    String requestType, Long settleAmount) {
        if (memberNo == null) {
            return;
        }
        String safeBiz = bizName != null ? bizName : "쇼핑몰";
        String typeLabel = "ADHOC".equalsIgnoreCase(requestType) ? "중간정산" : "월정산";
        String amountText = settleAmount == null ? "-" : String.format("%,d원", settleAmount);
        String content = "[" + safeBiz + "] " + typeLabel + " 지급이 완료 처리되었습니다.\n\n"
                + "기간: " + nullToDash(periodStart) + " ~ " + nullToDash(periodEnd) + "\n"
                + "지급액: " + amountText + "\n"
                + "정산 내역에서 확인해 주세요.";

        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("SYSTEM");
        vo.setTitle(typeLabel + " 지급이 완료되었습니다");
        vo.setContent(content.length() > 500 ? content.substring(0, 497) + "..." : content);
        vo.setLinkUrl("/biz/store/settlement");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    // ========== 3. 숙소 (STAY) ==========

    // ----- 3-1. 유저/시스템 → 사업자 -----

    // 2026-07-28 박유정 — 숙소 예약 결제 완료 → 사업자 알림
    @Override
    @Transactional
    public void sendStayReserveToBizNotification(Long bizMemberNo, String stayName,
                                                 java.util.Date checkinDate, java.util.Date checkoutDate,
                                                 Long resvId) {
        if (bizMemberNo == null) {
            return;
        }
        String safeName = stayName != null ? stayName : "숙소";
        String period = formatStayPeriod(checkinDate, checkoutDate);
        String content = "[" + safeName + "] 새 숙소 예약이 접수되었습니다.\n\n숙박 기간: " + period;

        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(bizMemberNo);
        vo.setNotiType("RESERVE");
        vo.setTitle("새 숙소 예약이 접수되었습니다");
        vo.setContent(content.length() > 500 ? content.substring(0, 497) + "..." : content);
        vo.setLinkUrl("/biz/stay/reserve");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    // 2026-07-28 박유정 — 리뷰 등록 → 사업자(숙소) 알림
    @Override
    @Transactional
    public void sendStayReviewToBizNotification(Long bizMemberNo, String stayName,
                                                String reviewerNickname, Double rating, Long resvId) {
        if (bizMemberNo == null) {
            return;
        }
        String safeName = stayName != null ? stayName : "숙소";
        String who = (reviewerNickname != null && !reviewerNickname.isBlank()) ? reviewerNickname : "회원";
        String star = rating != null ? String.valueOf(rating) : "-";
        String content = "[" + safeName + "] 새 숙소 리뷰가 등록되었습니다.\n\n작성자: " + who
                + "\n별점: " + star;

        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(bizMemberNo);
        vo.setNotiType("RESERVE");
        vo.setTitle("숙소 리뷰가 등록되었습니다");
        vo.setContent(content.length() > 500 ? content.substring(0, 497) + "..." : content);
        vo.setLinkUrl("/biz/stay/reviews");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    // ----- 3-2. 사업자/스케줄/취소 → 유저 -----

    // 2026/08/11 장우철 — 숙소 예약 확정 알림 (병원 알림과 문구 분리)
    @Override
    @Transactional
    public void sendStayReserveConfirmNotification(Long memberNo, String stayName,
                                                   java.util.Date resvDate, String resvTime, Long resvId) {
        if (memberNo == null) {
            return;
        }
        String when = formatResvWhen(resvDate, resvTime);
        String safeName = stayName != null ? stayName : "숙소";
        String content = "[" + safeName + "] 예약이 확정되었습니다.\n\n예약 일시: " + when;

        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("RESERVE");
        vo.setTitle("숙소 예약이 확정되었습니다");
        vo.setContent(content.length() > 500 ? content.substring(0, 497) + "..." : content);
        vo.setLinkUrl(resvId != null ? "/mypage/reserve/detail?resvId=" + resvId : "/mypage/reserve");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    // 2026/08/11 장우철 — 숙소 예약 취소 알림
    @Override
    @Transactional
    public void sendStayReserveCancelNotification(Long memberNo, String stayName,
                                                  java.util.Date resvDate, String resvTime,
                                                  String cancelReason, Long resvId) {
        if (memberNo == null) {
            return;
        }
        String when = formatResvWhen(resvDate, resvTime);
        String safeName = stayName != null ? stayName : "숙소";
        String reason = (cancelReason != null && !cancelReason.isBlank()) ? cancelReason.trim() : "-";
        String content = "[" + safeName + "] 예약이 취소되었습니다.\n\n예약 일시: " + when
                + "\n취소 사유: " + reason;
        if (content.length() > 500) {
            content = content.substring(0, 497) + "...";
        }

        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("RESERVE");
        vo.setTitle("숙소 예약이 취소되었습니다");
        vo.setContent(content);
        vo.setLinkUrl(resvId != null ? "/mypage/reserve/detail?resvId=" + resvId : "/mypage/reserve");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    @Override
    @Transactional
    public void sendStayCheckinNotification(Long memberNo, String stayName, Long resvId) {
        if (memberNo == null) {
            return;
        }
        String name = (stayName != null && !stayName.isBlank()) ? stayName.trim() : "숙소";
        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("RESERVE");
        vo.setTitle("숙소 체크인이 완료되었습니다");
        vo.setContent("[" + name + "] 체크인이 확인되었습니다. 편안한 숙박 되세요.");
        vo.setLinkUrl(resvId != null ? "/mypage/reserve/detail?resvId=" + resvId : "/mypage/reserve");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    @Override
    @Transactional
    public void sendStayCheckoutNotification(Long memberNo, String stayName, Long resvId) {
        if (memberNo == null) {
            return;
        }
        String name = (stayName != null && !stayName.isBlank()) ? stayName.trim() : "숙소";
        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("RESERVE");
        vo.setTitle("숙소 체크아웃이 완료되었습니다");
        vo.setContent("[" + name + "] 체크아웃이 확인되었습니다.");
        vo.setLinkUrl(resvId != null ? "/mypage/reserve/detail?resvId=" + resvId : "/mypage/reserve");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    @Override
    @Transactional
    public void sendStayDoneNotification(Long memberNo, String stayName, Long resvId) {
        if (memberNo == null) {
            return;
        }
        String name = (stayName != null && !stayName.isBlank()) ? stayName.trim() : "숙소";
        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("RESERVE");
        vo.setTitle("숙소 이용이 완료되었습니다");
        vo.setContent("[" + name + "] 숙박이 완료되었습니다. 리뷰를 남겨 주세요.");
        vo.setLinkUrl(resvId != null ? "/mypage/reserve/detail?resvId=" + resvId : "/mypage/reserve");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    @Override
    @Transactional
    public void sendStayCompensationRefundNotification(Long memberNo, String stayName,
                                                       long refundAmount, Long resvId) {
        if (memberNo == null) {
            return;
        }
        String name = (stayName != null && !stayName.isBlank()) ? stayName.trim() : "숙소";
        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("RESERVE");
        vo.setTitle("숙소 환불이 승인되었습니다");
        vo.setContent("[" + name + "] 예약은 유지되며 "
                + String.format("%,d", Math.max(0L, refundAmount))
                + "원(및 포인트·쿠폰)이 환불·복구 처리되었습니다.");
        vo.setLinkUrl(resvId != null ? "/mypage/reserve/detail?resvId=" + resvId : "/mypage/reserve");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    // 2026-07-28 박유정 — 숙소 답글 → 회원 알림
    @Override
    @Transactional
    public void sendStayReviewReplyNotification(Long memberNo, String stayName,
                                                Long resvId, Long stayId) {
        if (memberNo == null) {
            return;
        }
        String safeName = stayName != null ? stayName : "숙소";
        String content = "[" + safeName + "] 회원님의 리뷰에 숙소 답글이 등록되었습니다.";

        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("RESERVE");
        vo.setTitle("숙소 리뷰 답글이 등록되었습니다");
        vo.setContent(content.length() > 500 ? content.substring(0, 497) + "..." : content);
        if (stayId != null) {
            vo.setLinkUrl("/stay/detail?id=" + stayId);
        } else if (resvId != null) {
            vo.setLinkUrl("/mypage/reserve/detail?resvId=" + resvId);
        } else {
            vo.setLinkUrl("/mypage/reserve");
        }
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    // ----- 3-3. 관리자 → 사업자 (정산) -----

    // 2026/07/30 장우철 — 숙소 중간정산 승인 알림 (사이트 내, 이메일 아님)
    @Override
    @Transactional
    public void sendStayMidSettleApproveNotification(Long memberNo, String bizName,
                                                     String periodStart, String periodEnd,
                                                     String requestScope, Long settleAmount) {
        if (memberNo == null) {
            return;
        }
        String safeBiz = bizName != null ? bizName : "숙소";
        String scopeLabel = "ROOM".equalsIgnoreCase(requestScope) ? "특정 객실" : "숙소 전체";
        String amountText = settleAmount == null ? "-" : String.format("%,d원", settleAmount);
        String content = "[" + safeBiz + "] 중간정산 요청이 승인되었습니다.\n\n"
                + "기간: " + nullToDash(periodStart) + " ~ " + nullToDash(periodEnd) + "\n"
                + "범위: " + scopeLabel + "\n"
                + "정산금: " + amountText + "\n"
                + "지급은 관리자 처리 후 정산 내역에서 확인할 수 있습니다.";

        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("SYSTEM");
        vo.setTitle("중간정산 요청이 승인되었습니다");
        vo.setContent(content.length() > 500 ? content.substring(0, 497) + "..." : content);
        vo.setLinkUrl("/biz/stay/settlement");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    // 2026/07/30 장우철 — 숙소 중간정산 거절 알림 (사유 포함)
    @Override
    @Transactional
    public void sendStayMidSettleRejectNotification(Long memberNo, String bizName,
                                                    String periodStart, String periodEnd,
                                                    String rejectReason) {
        if (memberNo == null) {
            return;
        }
        String safeBiz = bizName != null ? bizName : "숙소";
        String safeReason = rejectReason != null ? rejectReason.trim() : "";
        if (safeReason.length() > 400) {
            safeReason = safeReason.substring(0, 400) + "...";
        }
        String content = "[" + safeBiz + "] 중간정산 요청이 거절되었습니다.\n\n"
                + "기간: " + nullToDash(periodStart) + " ~ " + nullToDash(periodEnd) + "\n"
                + "거절 사유:\n" + safeReason;

        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("SYSTEM");
        vo.setTitle("중간정산 요청이 거절되었습니다");
        vo.setContent(content.length() > 500 ? content.substring(0, 497) + "..." : content);
        vo.setLinkUrl("/biz/stay/settlement");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    // 2026/07/30 장우철 — 숙소 정산 더미 지급 완료 알림 (사이트 내)
    @Override
    @Transactional
    public void sendStaySettlementPaidNotification(Long memberNo, String bizName,
                                                   String periodStart, String periodEnd,
                                                   String requestType, Long settleAmount) {
        if (memberNo == null) {
            return;
        }
        String safeBiz = bizName != null ? bizName : "숙소";
        String typeLabel = "ADHOC".equalsIgnoreCase(requestType) ? "중간정산" : "월정산";
        String amountText = settleAmount == null ? "-" : String.format("%,d원", settleAmount);
        String content = "[" + safeBiz + "] " + typeLabel + " 지급이 완료 처리되었습니다.\n\n"
                + "기간: " + nullToDash(periodStart) + " ~ " + nullToDash(periodEnd) + "\n"
                + "지급액: " + amountText + "\n"
                + "정산 내역에서 확인해 주세요.";

        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("SYSTEM");
        vo.setTitle(typeLabel + " 지급이 완료되었습니다");
        vo.setContent(content.length() > 500 ? content.substring(0, 497) + "..." : content);
        vo.setLinkUrl("/biz/stay/settlement");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    // ========== 4. 커뮤니티 ==========

    // ----- 관리자 → 유저 -----

    @Override
    @Transactional
    public void sendCommunityPostHiddenNotification(Long memberNo, String postTitle, Long postId) {
        if (memberNo == null) {
            return;
        }
        String title = (postTitle != null && !postTitle.isBlank()) ? postTitle.trim() : "게시글";
        if (title.length() > 40) {
            title = title.substring(0, 37) + "...";
        }
        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("SYSTEM");
        vo.setTitle("게시글이 숨김 처리되었습니다");
        vo.setContent("신고 검토 결과 [" + title + "] 게시글이 숨김 처리되었습니다.");
        vo.setLinkUrl(postId != null ? "/community/detail?id=" + postId : "/community");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    @Override
    @Transactional
    public void sendCommunityPostDeletedNotification(Long memberNo, String postTitle) {
        if (memberNo == null) {
            return;
        }
        String title = (postTitle != null && !postTitle.isBlank()) ? postTitle.trim() : "게시글";
        if (title.length() > 40) {
            title = title.substring(0, 37) + "...";
        }
        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("SYSTEM");
        vo.setTitle("게시글이 삭제 처리되었습니다");
        vo.setContent("신고 검토 결과 [" + title + "] 게시글이 삭제 처리되었습니다.");
        vo.setLinkUrl("/community");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    // ========== 5. 기타 (병원/쇼핑/숙소/커뮤니티 외) ==========

    // ----- 관리자 → 신청자(유저) : 사업자 등록 -----

    // 2026-07-10 장우철 — 사업자 승인 알림 TB_NOTIFICATION INSERT
    // 이유: approveBiz 트랜잭션 안에서 해당 MEMBER_NO 에만 등록 (이메일/푸시는 후속)
    @Override
    @Transactional
    public void sendBizApproveNotification(Long memberNo, String bizName, String bizType) {
        if (memberNo == null) {
            return;
        }

        String safeBizName = bizName != null ? bizName : "사업자";
        String typeLabel = resolveBizTypeLabel(bizType);

        String content = "[" + safeBizName + "] 사업자 등록이 승인되었습니다.\n\n"
                + "승인 유형: " + typeLabel + "\n"
                + "사업자센터에서 업체 정보를 등록해 주세요.";

        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("SYSTEM");
        vo.setTitle("사업자 등록 신청이 승인되었습니다");
        vo.setContent(content.length() > 500 ? content.substring(0, 497) + "..." : content);
        vo.setLinkUrl("/mypage/biz");
        vo.setIsRead("N");

        mypageNotifyMapper.insertNotification(vo);
    }

    // 2026-07-09 장우철 — 사업자 반려 알림 TB_NOTIFICATION INSERT
    // 이유: CONTENT 컬럼 VARCHAR2(500) 이므로 반려사유 길이 제한, LINK 는 재신청 화면(2번) 경로
    @Override
    @Transactional
    public void sendBizRejectNotification(Long memberNo, String bizName, String rejectReason) {
        if (memberNo == null) {
            return;
        }

        String safeBizName = bizName != null ? bizName : "사업자";
        String safeReason = rejectReason != null ? rejectReason.trim() : "";
        if (safeReason.length() > 450) {
            safeReason = safeReason.substring(0, 450) + "...";
        }

        String content = "[" + safeBizName + "] 신청이 반려되었습니다.\n\n반려 사유:\n" + safeReason;

        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("SYSTEM");
        vo.setTitle("사업자 등록 신청이 반려되었습니다");
        vo.setContent(content.length() > 500 ? content.substring(0, 497) + "..." : content);
        vo.setLinkUrl("/mypage/biz/rejected");
        vo.setIsRead("N");

        mypageNotifyMapper.insertNotification(vo);
    }

    // ----- 관리자 → 사업자 : 리뷰삭제 -----

    // 2026-07-24 박유정 — 리뷰 삭제 요청 승인 알림 (사업자)
    @Override
    @Transactional
    public void sendReviewDeleteApproveNotification(Long bizMemberNo, String targetName,
                                                    Long reviewId, String linkUrl) {
        if (bizMemberNo == null) {
            return;
        }
        String safeName = targetName != null ? targetName : "사업장";
        String content = "[" + safeName + "] 리뷰 삭제 요청이 승인되어 리뷰가 삭제되었습니다.";

        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(bizMemberNo);
        vo.setNotiType("BIZ");
        vo.setTitle("리뷰 삭제 요청이 승인되었습니다");
        vo.setContent(content.length() > 500 ? content.substring(0, 497) + "..." : content);
        vo.setLinkUrl(linkUrl != null && !linkUrl.isBlank() ? linkUrl : "/biz/hospital/reviews");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    // 2026-07-24 박유정 — 리뷰 삭제 요청 반려 알림 (사업자)
    @Override
    @Transactional
    public void sendReviewDeleteRejectNotification(Long bizMemberNo, String targetName,
                                                   String rejectReason, String linkUrl) {
        if (bizMemberNo == null) {
            return;
        }
        String safeName = targetName != null ? targetName : "사업장";
        String safeReason = (rejectReason != null && !rejectReason.isBlank()) ? rejectReason.trim() : "사유 없음";
        String content = "[" + safeName + "] 리뷰 삭제 요청이 반려되었습니다. 반려 사유: " + safeReason;

        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(bizMemberNo);
        vo.setNotiType("BIZ");
        vo.setTitle("리뷰 삭제 요청이 반려되었습니다");
        vo.setContent(content.length() > 500 ? content.substring(0, 497) + "..." : content);
        vo.setLinkUrl(linkUrl != null && !linkUrl.isBlank() ? linkUrl : "/biz/hospital/reviews");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    // ----- 관리자 → 사업자 : 배너 -----

    // 2026-08-06 박유정 — 배너 신청 승인 알림 (사업자)
    @Override
    @Transactional
    public void sendBannerApproveNotification(Long memberNo, String bannerTitle,
                                              String positionLabel, String linkUrl) {
        if (memberNo == null) {
            return;
        }
        String safeTitle = (bannerTitle != null && !bannerTitle.isBlank()) ? bannerTitle.trim() : "배너";
        String safePosition = (positionLabel != null && !positionLabel.isBlank()) ? positionLabel.trim() : "지정 위치";
        String content = "[" + safeTitle + "] 배너 신청이 승인되었습니다.\n\n"
                + "노출 위치: " + safePosition + "\n"
                + "설정한 기간 동안 해당 페이지에 노출됩니다.";

        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("BIZ");
        vo.setTitle("배너 신청이 승인되었습니다");
        vo.setContent(content.length() > 500 ? content.substring(0, 497) + "..." : content);
        vo.setLinkUrl(linkUrl != null && !linkUrl.isBlank() ? linkUrl : "/mypage/biz");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    // 2026-08-06 박유정 — 배너 신청 대기(노출예정) 알림 (사업자)
    @Override
    @Transactional
    public void sendBannerHoldNotification(Long memberNo, String bannerTitle,
                                           String positionLabel, String holdReason, String linkUrl) {
        if (memberNo == null) {
            return;
        }
        String safeTitle = (bannerTitle != null && !bannerTitle.isBlank()) ? bannerTitle.trim() : "배너";
        String safePosition = (positionLabel != null && !positionLabel.isBlank()) ? positionLabel.trim() : "지정 위치";
        String safeReason = holdReason != null ? holdReason.trim() : "";
        if (safeReason.length() > 400) {
            safeReason = safeReason.substring(0, 397) + "...";
        }
        String content = "[" + safeTitle + "] 배너 신청이 노출 예정 상태로 변경되었습니다.\n\n"
                + "노출 위치: " + safePosition + "\n"
                + "대기 사유:\n" + safeReason;

        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("BIZ");
        vo.setTitle("배너 신청이 노출 예정으로 변경되었습니다");
        vo.setContent(content.length() > 500 ? content.substring(0, 497) + "..." : content);
        vo.setLinkUrl(linkUrl != null && !linkUrl.isBlank() ? linkUrl : "/mypage/biz");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    // 2026-08-06 박유정 — 배너 신청 반려 알림 (사업자)
    @Override
    @Transactional
    public void sendBannerRejectNotification(Long memberNo, String bannerTitle,
                                             String positionLabel, String rejectReason, String linkUrl) {
        if (memberNo == null) {
            return;
        }
        String safeTitle = (bannerTitle != null && !bannerTitle.isBlank()) ? bannerTitle.trim() : "배너";
        String safePosition = (positionLabel != null && !positionLabel.isBlank()) ? positionLabel.trim() : "지정 위치";
        String safeReason = rejectReason != null ? rejectReason.trim() : "";
        if (safeReason.length() > 400) {
            safeReason = safeReason.substring(0, 397) + "...";
        }
        String content = "[" + safeTitle + "] 배너 신청이 반려되었습니다.\n\n"
                + "노출 위치: " + safePosition + "\n"
                + "반려 사유:\n" + safeReason;

        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("BIZ");
        vo.setTitle("배너 신청이 반려되었습니다");
        vo.setContent(content.length() > 500 ? content.substring(0, 497) + "..." : content);
        vo.setLinkUrl(linkUrl != null && !linkUrl.isBlank() ? linkUrl : "/mypage/biz");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    // ========== 6. 알림함 조회/읽음/삭제 (CRUD) ==========

    // 2026-07-09 장우철 — 알림함 목록 (TB_NOTIFICATION)
    @Override
    @Transactional(readOnly = true)
    public List<MypageNotifyVO> getNotificationList(Long memberNo) {
        if (memberNo == null) {
            return Collections.emptyList();
        }
        return mypageNotifyMapper.selectNotificationList(memberNo);
    }

    // 2026-07-09 장우철 — 알림 상세 + 읽음 처리
    @Override
    @Transactional
    public MypageNotifyVO getNotificationDetail(Long notiId, Long memberNo) {
        if (notiId == null || memberNo == null) {
            return null;
        }
        MypageNotifyVO noti = mypageNotifyMapper.selectNotificationDetail(notiId, memberNo);
        if (noti != null && !"Y".equalsIgnoreCase(noti.getIsRead())) {
            mypageNotifyMapper.updateNotificationRead(notiId, memberNo);
            noti.setIsRead("Y");
        }
        return noti;
    }

    // 2026-07-10 장우철 — 알림함 전체 읽음
    @Override
    @Transactional
    public int markAllNotificationsRead(Long memberNo) {
        if (memberNo == null) {
            return 0;
        }
        return mypageNotifyMapper.updateAllNotificationRead(memberNo);
    }

    // 2026-07-10 장우철 — 알림함 전체 삭제
    @Override
    @Transactional
    public int deleteAllNotifications(Long memberNo) {
        if (memberNo == null) {
            return 0;
        }
        return mypageNotifyMapper.deleteAllNotificationsByMemberNo(memberNo);
    }

    // 2026/07/11 장우철 — 헤더 미읽음 알림 배지
    @Override
    @Transactional(readOnly = true)
    public int countUnreadNotifications(Long memberNo) {
        if (memberNo == null) {
            return 0;
        }
        return mypageNotifyMapper.countUnreadNotifications(memberNo);
    }

    // ========== private helpers ==========

    private String formatResvWhen(java.util.Date resvDate, String resvTime) {
        String datePart = "-";
        if (resvDate != null) {
            datePart = new java.text.SimpleDateFormat("yyyy-MM-dd").format(resvDate);
        }
        String timePart = (resvTime != null && !resvTime.isBlank()) ? resvTime : "";
        return (datePart + " " + timePart).trim();
    }

    private String formatStayPeriod(java.util.Date checkinDate, java.util.Date checkoutDate) {
        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
        String checkin = checkinDate != null ? sdf.format(checkinDate) : "-";
        String checkout = checkoutDate != null ? sdf.format(checkoutDate) : "-";
        return checkin + " ~ " + checkout;
    }

    // 2026-08-11 박유정 — 숙소 환불 알림 일시 포맷
    private String formatDateTime(java.util.Date date) {
        if (date == null) {
            return "-";
        }
        return new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(date);
    }

    private String resolveBizTypeLabel(String bizType) {
        if (bizType == null) {
            return "사업자";
        }
        return switch (bizType) {
            case "HOSPITAL" -> "병원";
            case "STAY" -> "숙소";
            case "STORE" -> "펫샵";
            case "GROOMING" -> "미용";
            case "STUDIO" -> "스튜디오";
            case "RESTAURANT" -> "식당";
            default -> bizType;
        };
    }

    private String nullToDash(String s) {
        return (s == null || s.isBlank()) ? "-" : s;
    }

    // 2026-08-10 박유정 — 재능나눔 참여 신청 → 병원 알림
    @Override
    @Transactional
    public void sendTalentApplyToBizNotification(Long bizMemberNo, String talentTitle,
                                                 String applicantNickname, String linkUrl) {
        if (bizMemberNo == null) {
            return;
        }
        String title = (talentTitle != null && !talentTitle.isBlank()) ? talentTitle.trim() : "재능나눔";
        String nick = (applicantNickname != null && !applicantNickname.isBlank()) ? applicantNickname.trim() : "회원";
        String content = "[" + title + "] 에 새 참여 신청이 있습니다.\n\n신청자: " + nick;

        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(bizMemberNo);
        vo.setNotiType("BIZ");
        vo.setTitle("재능나눔 참여 신청이 도착했습니다");
        vo.setContent(content.length() > 500 ? content.substring(0, 497) + "..." : content);
        vo.setLinkUrl(linkUrl != null && !linkUrl.isBlank() ? linkUrl : "/biz/hospital/talent");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }

    // 2026-08-10 박유정 — 재능나눔 확인 → 회원 알림
    @Override
    @Transactional
    public void sendTalentApplyConfirmNotification(Long memberNo, String talentTitle,
                                                   String bizName, String linkUrl) {
        if (memberNo == null) {
            return;
        }
        String title = (talentTitle != null && !talentTitle.isBlank()) ? talentTitle.trim() : "재능나눔";
        String biz = (bizName != null && !bizName.isBlank()) ? bizName.trim() : "제공 사업자";
        String content = "[" + title + "] 참여 신청이 " + biz + " 에서 확인되었습니다.";

        MypageNotifyVO vo = new MypageNotifyVO();
        vo.setMemberNo(memberNo);
        vo.setNotiType("USER");
        vo.setTitle("재능나눔 신청이 확인되었습니다");
        vo.setContent(content.length() > 500 ? content.substring(0, 497) + "..." : content);
        vo.setLinkUrl(linkUrl != null && !linkUrl.isBlank() ? linkUrl : "/give/talent/list");
        vo.setIsRead("N");
        mypageNotifyMapper.insertNotification(vo);
    }
}
