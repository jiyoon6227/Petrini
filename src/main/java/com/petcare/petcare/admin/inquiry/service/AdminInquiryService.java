/**
 * 역할: 관리자 숙소 환불(1:1) 승인/거절
 * 2026/07/31 장우철 — R2 2-7 / R3 정산 연결
 * 2026/08/06 장우철 — B: STATUS APPROVED/REJECTED + 승인 시 보상숙박(예약 유지)
 */
package com.petcare.petcare.admin.inquiry.service;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.member.inquiry.mapper.MemberInquiryMapper;
import com.petcare.petcare.member.inquiry.vo.MemberInquiryVO;
import com.petcare.petcare.mypage.notify.service.MypageNotifyService;
import com.petcare.petcare.settlement.mapper.StaySettlementMapper;
import com.petcare.petcare.stay.service.StayFullCancelService;

@Service
public class AdminInquiryService {

    @Autowired
    private MemberInquiryMapper memberInquiryMapper;
    @Autowired
    private StayFullCancelService stayFullCancelService;
    @Autowired
    private StaySettlementMapper staySettlementMapper;
    @Autowired
    private MypageNotifyService mypageNotifyService;

    @Transactional(readOnly = true)
    public List<MemberInquiryVO> getStayRefundList(String statusCd, String keyword) {
        String status = normalizeStatus(statusCd);
        List<MemberInquiryVO> list = memberInquiryMapper.selectStayRefundList(status);
        return filterStayRefundList(list, keyword);
    }

    @Transactional(readOnly = true)
    public Map<String, Integer> getStayRefundStatusCounts() {
        List<MemberInquiryVO> all = memberInquiryMapper.selectStayRefundList(null);
        return buildStatusCounts(all);
    }

    // 2026-08-11 박유정 — 관리자 사이드바 숙소 환불신청 대기 배지
    @Transactional(readOnly = true)
    public int countPendingStayRefund() {
        Map<String, Integer> counts = getStayRefundStatusCounts();
        Integer wait = counts.get("WAIT");
        return wait != null ? wait : 0;
    }

    @Transactional(readOnly = true)
    public MemberInquiryVO getStayRefundDetail(Long inquiryId) {
        if (inquiryId == null) {
            return null;
        }
        return memberInquiryMapper.selectStayRefundDetail(inquiryId);
    }

    /**
     * 승인: 전액 환불 + 예약 이용 유지(보상 숙박) + 정산 REFUNDED + 문의 APPROVED
     * 2026/08/06 장우철 — CANCEL 하지 않음
     */
    @Transactional
    public void approveStayRefund(Long inquiryId, Long adminNo, String answer) throws Exception {
        MemberInquiryVO detail = memberInquiryMapper.selectStayRefundDetail(inquiryId);
        if (detail == null) {
            throw new IllegalStateException("환불 신청을 찾을 수 없습니다.");
        }
        if (!"WAIT".equalsIgnoreCase(detail.getStatusCd())) {
            throw new IllegalStateException("이미 처리된 신청입니다.");
        }
        if (detail.getRefId() == null) {
            throw new IllegalStateException("연결된 예약이 없습니다.");
        }

        String msg = (answer == null || answer.isBlank())
                ? "환불이 승인되었습니다. 결제금은 전액 환불되며, 예약 기간 동안 숙소 이용은 가능합니다(보상 숙박)."
                : answer.trim();

        Long resvId = detail.getRefId();

        staySettlementMapper.updateSettlementItemRefundedByResvId(
                resvId, "관리자 환불승인(이용유지)");
        staySettlementMapper.recalcUnpaidSettlementTotalsByResvId(resvId);

        // 2026/08/11 장우철 — 보상숙박: 결제 환불만 하고 예약 STATUS 유지 (cancelWithFullRefund 사용 안 함)
        stayFullCancelService.refundPaymentKeepReservation(resvId, "관리자");

        int updated = memberInquiryMapper.updateInquiryAnswer(inquiryId, "APPROVED", msg, adminNo);
        if (updated == 0) {
            throw new IllegalStateException("문의 상태 갱신에 실패했습니다.");
        }

        // 2026-08-11 박유정 — 환불 승인 알림 (예약 취소 문구 없음)
        String stayName = detail.getStayName() != null ? detail.getStayName() : "숙소";
        Long refundAmt = detail.getTotalAmount() != null ? detail.getTotalAmount() : 0L;
        mypageNotifyService.sendStayRefundApprovedToMemberNotification(
                detail.getMemberNo(), stayName, detail.getApplyDate(), refundAmt, resvId);
    }

    /**
     * 거절: 예약 유지 + 문의 REJECTED → 다음 정산 기간에 이월 합산(R3-3)
     * 2026/08/06 장우철 — STATUS_CD = REJECTED (B방식)
     */
    @Transactional
    public void rejectStayRefund(Long inquiryId, Long adminNo, String answer) {
        MemberInquiryVO detail = memberInquiryMapper.selectStayRefundDetail(inquiryId);
        if (detail == null) {
            throw new IllegalStateException("환불 신청을 찾을 수 없습니다.");
        }
        if (!"WAIT".equalsIgnoreCase(detail.getStatusCd())) {
            throw new IllegalStateException("이미 처리된 신청입니다.");
        }
        if (answer == null || answer.isBlank()) {
            throw new IllegalArgumentException("거절 사유를 입력해 주세요.");
        }
        int updated = memberInquiryMapper.updateInquiryAnswer(
                inquiryId, "REJECTED", answer.trim(), adminNo);
        if (updated == 0) {
            throw new IllegalStateException("문의 상태 갱신에 실패했습니다.");
        }

        // 2026-08-11 박유정 — 환불 거절 알림
        String stayName = detail.getStayName() != null ? detail.getStayName() : "숙소";
        mypageNotifyService.sendStayRefundRejectedToMemberNotification(
                detail.getMemberNo(), stayName, detail.getApplyDate(), answer.trim(), detail.getRefId());
    }

    // 2026-08-11 박유정 — 관리자 일반 1:1 문의 (숙소 환불 제외)

  /** 목록 조회 */
    @Transactional(readOnly = true)
    public List<MemberInquiryVO> getGeneralInquiryList(String statusCd, String keyword) {
        String status = normalizeStatus(statusCd);
        List<MemberInquiryVO> list = memberInquiryMapper.selectGeneralInquiryList(status);
        return filterGeneralInquiryList(list, keyword);
    }

    @Transactional(readOnly = true)
    public Map<String, Integer> getGeneralInquiryStatusCounts() {
        List<MemberInquiryVO> all = memberInquiryMapper.selectGeneralInquiryList(null);
        return buildStatusCounts(all);
    }

    // 2026-08-11 박유정 — 관리자 사이드바 1:1 문의 대기 배지
    @Transactional(readOnly = true)
    public int countPendingGeneralInquiry() {
        Map<String, Integer> counts = getGeneralInquiryStatusCounts();
        Integer wait = counts.get("WAIT");
        return wait != null ? wait : 0;
    }

    /** 상세 조회 */
    @Transactional(readOnly = true)
    public MemberInquiryVO getGeneralInquiryDetail(Long inquiryId) {
        if (inquiryId == null) {
            return null;
        }
        return memberInquiryMapper.selectGeneralInquiryDetail(inquiryId);
    }

    /** 답변 등록 */
    @Transactional
    public void answerGeneralInquiry(Long inquiryId, Long adminNo, String answer) {
        MemberInquiryVO detail = memberInquiryMapper.selectGeneralInquiryDetail(inquiryId);
        if (detail == null) {
            throw new IllegalArgumentException("문의를 찾을 수 없습니다.");
        }
        if (!"WAIT".equalsIgnoreCase(detail.getStatusCd())) {
            throw new IllegalStateException("이미 답변 완료된 문의입니다.");
        }
        if (answer == null || answer.isBlank()) {
            throw new IllegalArgumentException("답변 내용을 입력해 주세요.");
        }

        int updated = memberInquiryMapper.updateInquiryAnswer(
                inquiryId, "DONE", answer.trim(), adminNo);
        if (updated == 0) {
            throw new IllegalStateException("답변 저장에 실패했습니다.");
        }
    }

    // 2026-08-11 박유정 — 목록 탭 건수·검색 공통
    private String normalizeStatus(String statusCd) {
        if (statusCd == null || statusCd.isBlank() || "ALL".equalsIgnoreCase(statusCd)) {
            return null;
        }
        return statusCd.trim().toUpperCase();
    }

    private Map<String, Integer> buildStatusCounts(List<MemberInquiryVO> all) {
        List<MemberInquiryVO> list = all != null ? all : Collections.emptyList();
        int wait = 0;
        int done = 0;
        for (MemberInquiryVO item : list) {
            if (isWaitStatus(item.getStatusCd())) {
                wait++;
            } else {
                done++;
            }
        }
        Map<String, Integer> counts = new HashMap<>();
        counts.put("ALL", list.size());
        counts.put("WAIT", wait);
        counts.put("DONE", done);
        return counts;
    }

    private boolean isWaitStatus(String statusCd) {
        return statusCd != null && "WAIT".equalsIgnoreCase(statusCd.trim());
    }

    private List<MemberInquiryVO> filterGeneralInquiryList(List<MemberInquiryVO> list, String keyword) {
        List<MemberInquiryVO> rows = list != null ? list : Collections.emptyList();
        if (keyword == null || keyword.isBlank()) {
            return rows;
        }
        String kw = keyword.trim().toLowerCase();
        return rows.stream()
                .filter(item -> containsIgnoreCase(item.getTitle(), kw)
                        || containsIgnoreCase(item.getMemberName(), kw)
                        || containsIgnoreCase(item.getMemberEmail(), kw)
                        || String.valueOf(item.getInquiryId()).contains(kw))
                .toList();
    }

    private List<MemberInquiryVO> filterStayRefundList(List<MemberInquiryVO> list, String keyword) {
        List<MemberInquiryVO> rows = list != null ? list : Collections.emptyList();
        if (keyword == null || keyword.isBlank()) {
            return rows;
        }
        String kw = keyword.trim().toLowerCase();
        return rows.stream()
                .filter(item -> containsIgnoreCase(item.getResvNo(), kw)
                        || containsIgnoreCase(item.getStayName(), kw)
                        || containsIgnoreCase(item.getMemberName(), kw)
                        || String.valueOf(item.getInquiryId()).contains(kw))
                .toList();
    }

    private boolean containsIgnoreCase(String value, String keyword) {
        return value != null && value.toLowerCase().contains(keyword);
    }
}
