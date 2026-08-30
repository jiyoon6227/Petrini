/**
 * 역할: 사업자 펫호텔 URL 처리 → Service 호출 → JSP 반환
 *
 * 연결
 * - Service: BizStayService
 * - 상속: BizBaseController (사업자 로그인 체크)
 *
 * SQL·비즈니스 로직은 넣지 말 것 → Service로 위임
 * return 경로는 담당 JSP와 동일하게 맞출 것
 */

package com.petcare.petcare.biz.stay.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.petcare.petcare.biz.controller.BizBaseController;
import com.petcare.petcare.biz.stay.service.BizStayService;
import com.petcare.petcare.biz.store.service.BizStoreService;
import com.petcare.petcare.biz.store.vo.BizInfoVO;
import com.petcare.petcare.biz.vo.BizCouponVO;
import com.petcare.petcare.file.service.FileService;
import com.petcare.petcare.file.vo.FileVO;
import com.petcare.petcare.main.banner.vo.MainBannerVO;
import com.petcare.petcare.stay.vo.ReservationVO;
import com.petcare.petcare.member.vo.MemberVO;
import com.petcare.petcare.settlement.service.StaySettlementService;
import com.petcare.petcare.settlement.vo.StaySettlementItemVO;
import com.petcare.petcare.settlement.vo.StaySettlementRequestVO;
import com.petcare.petcare.settlement.vo.StaySettlementSummaryVO;
import com.petcare.petcare.settlement.vo.StaySettlementVO;
import com.petcare.petcare.stay.vo.StayRoomVO;
import com.petcare.petcare.stay.vo.StayVO;

import jakarta.servlet.http.HttpSession;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.Set;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.petcare.petcare.hospital.vo.ReviewDeleteRequestVO;
import com.petcare.petcare.member.inquiry.vo.MemberInquiryVO;
import com.petcare.petcare.stay.vo.StayReviewVO;

import org.springframework.beans.propertyeditors.CustomNumberEditor;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.InitBinder;

@Controller("bizStayController")
@RequestMapping("/biz/stay")
public class BizStayController extends BizBaseController {
    @Autowired
    private BizStayService bizStayService;
    @Autowired
    private ObjectMapper objectMapper;
    @Autowired
    private FileService fileService;
    // 2026/07/30 장우철 — 숙소 정산 요약/목록
    @Autowired
    private StaySettlementService staySettlementService;
    // 2026/08/06 장우철 — 정산계좌(TB_BUSINESS.SETTLE_*)는 쇼핑과 동일 테이블·서비스 재사용
    @Autowired
    private BizStoreService bizStoreService;

    // 2026-07-14 — 사이드바 예약관리 배지: PENDING 건수
    // 2026-07-28 박유정 — PENDING + CONFIRMED 합산 (BizStayMapper.countPendingReservations)
    @ModelAttribute("pendingReserveCount")
    public int pendingReserveCount(HttpSession session) {
        try {
            MemberVO member = getBizMember(session);
            if (member == null || member.getMemberId() == null) return 0;
            StayVO stay = bizStayService.resolveStayByBizId(member.getMemberId());
            if (stay == null || stay.getStayId() == null) return 0;
            return bizStayService.countPendingReservations(stay.getStayId());
        } catch (Exception e) {
            return 0;
        }
    }

    // 2026-07-14 — 사이드바 캘린더 배지: 오늘 체크인 CONFIRMED 건수
    @ModelAttribute("todayConfirmedCount")
    public int todayConfirmedCount(HttpSession session) {
        try {
            MemberVO member = getBizMember(session);
            if (member == null || member.getMemberId() == null) return 0;
            StayVO stay = bizStayService.resolveStayByBizId(member.getMemberId());
            if (stay == null || stay.getStayId() == null) return 0;
            return bizStayService.countTodayConfirmedReservations(stay.getStayId());
        } catch (Exception e) {
            return 0;
        }
    }

    // 2026-08-11 박유정 — 사이드바 환불신청 배지: 대기 건수
    @ModelAttribute("stayRefundRequestCount")
    public int stayRefundRequestCount(HttpSession session) {
        try {
            MemberVO member = getBizMember(session);
            if (member == null || member.getMemberId() == null) return 0;
            StayVO stay = bizStayService.resolveStayByBizId(member.getMemberId());
            if (stay == null || stay.getStayId() == null) return 0;
            return bizStayService.countPendingStayRefundRequests(stay.getStayId());
        } catch (Exception e) {
            return 0;
        }
    }
    
    @GetMapping({"", "/"})
    public String stayDashboard(HttpSession session, Model model) throws Exception {
        MemberVO member = getBizMember(session);
        if (member == null) 
            return "redirect:/login";

        //HYJ 26.08.06 대시보드
        StayVO stay = bizStayService.resolveStayByBizId(member.getMemberId());
        if (stay == null || stay.getStayId() == null) {
            return "redirect:/mypage/biz";
        }

        model.addAttribute("stay", stay);
        model.addAttribute("dash", bizStayService.getDashboardData(stay.getStayId(), 7));
        model.addAttribute("todayList", bizStayService.getTodayCheckinList(stay.getStayId()));
        model.addAttribute("recentReviews", bizStayService.getRecentReviews(stay.getStayId()));

        return "biz/stay/dashboard";
    }

    // 2026-07-14 — 사업자 숙소 예약 관리 (DB 연동)
    @GetMapping("/reserve")
    public String stayReserve(HttpSession session, Model model) throws Exception {
        MemberVO member = getBizMember(session);
        if (member == null) return "redirect:/login";

        StayVO stay = bizStayService.resolveStayByBizId(member.getMemberId());
        if (stay == null || stay.getStayId() == null) {
            return "redirect:/mypage/biz";
        }

        List<ReservationVO> reservationList = bizStayService.getReservationList(stay.getStayId(), "all");
        model.addAttribute("stay", stay);
        model.addAttribute("reservationList", reservationList);
        return "biz/stay/reserve";
    }

    // 2026-07-14 — 사업자 숙소 예약 상태 변경
    @PostMapping("/reserve/status")
    public String updateReservationStatus(@RequestParam("resvId") Long resvId,
                                          @RequestParam("statusCd") String statusCd,
                                          @RequestParam(value = "cancelReason", required = false) String cancelReason,
                                          HttpSession session,
                                          RedirectAttributes rttr) throws Exception {
        MemberVO member = getBizMember(session);
        if (member == null) return "redirect:/login";

        StayVO stay = bizStayService.resolveStayByBizId(member.getMemberId());
        if (stay == null || stay.getStayId() == null) {
            return "redirect:/mypage/biz";
        }

        try {
            bizStayService.updateReservationStatus(
                    stay.getStayId(), resvId, statusCd, cancelReason);
            rttr.addFlashAttribute("msg", "예약 상태가 변경되었습니다.");
        } catch (IllegalStateException | IllegalArgumentException e) {
            rttr.addFlashAttribute("errorMsg", e.getMessage());
        }
        catch (Exception e) {
            rttr.addFlashAttribute("errorMsg", e.getMessage());
        }
        
        return "redirect:/biz/stay/reserve";
    }

    // 2026-07-14 — 사업자 숙소 예약 상세 모달 API
    @GetMapping("/reserve/detail")
    @ResponseBody
    public ReservationVO reservationDetail(@RequestParam("resvId") Long resvId,
                                           HttpSession session) throws Exception {
        MemberVO member = getBizMember(session);
        if (member == null) return null;

        StayVO stay = bizStayService.resolveStayByBizId(member.getMemberId());
        if (stay == null || stay.getStayId() == null) return null;

        return bizStayService.getReservationDetail(stay.getStayId(), resvId);
    }

    // 2026-07-14 — 사업자 숙소 예약 캘린더 (DB 연동)
    @GetMapping("/calendar")
    public String stayCalendar(@RequestParam(value = "from", required = false) String fromDate,
                               @RequestParam(value = "to", required = false) String toDate,
                               HttpSession session,
                               Model model) throws Exception {
        MemberVO member = getBizMember(session);
        if (member == null) return "redirect:/login";

        StayVO stay = bizStayService.resolveStayByBizId(member.getMemberId());
        if (stay == null || stay.getStayId() == null) {
            return "redirect:/mypage/biz";
        }

        if (fromDate == null || fromDate.isBlank()) {
            fromDate = java.time.LocalDate.now().minusMonths(3).toString();
        }
        if (toDate == null || toDate.isBlank()) {
            toDate = java.time.LocalDate.now().plusMonths(6).toString();
        }

        List<ReservationVO> calendarReservations = bizStayService.getCalendarReservations(stay.getStayId(), fromDate, toDate);
        model.addAttribute("stay", stay);
        model.addAttribute("calendarReservations", calendarReservations);
        return "biz/stay/calendar";
    }

    // 2026-08-11 박유정 — 사업자 숙소 환불신청 목록 (조회 전용, 승인은 관리자)
    @GetMapping("/refunds")
    public String stayRefunds(HttpSession session, Model model,
                              @RequestParam(value = "status", defaultValue = "WAIT") String status) {
        MemberVO member = getBizMember(session);
        if (member == null) {
            return "redirect:/login";
        }
        StayVO stay = bizStayService.resolveStayByBizId(member.getMemberId());
        if (stay == null || stay.getStayId() == null) {
            return "redirect:/mypage/biz";
        }
        List<MemberInquiryVO> refundList = bizStayService.getStayRefundList(stay.getStayId(), status);
        Map<String, Integer> statusCounts = bizStayService.getStayRefundStatusCounts(stay.getStayId());
        model.addAttribute("stay", stay);
        model.addAttribute("refundList", refundList);
        model.addAttribute("status", status);
        model.addAttribute("waitCount", statusCounts.get("WAIT"));
        model.addAttribute("doneCount", statusCounts.get("DONE"));
        model.addAttribute("rejectedCount", statusCounts.get("REJECTED"));
        model.addAttribute("allCount", statusCounts.get("ALL"));
        return "biz/stay/refunds";
    }

    // 2026-07-28 박유정 — 사업자 숙소 리뷰관리 (DB 목록 → JSP JSON)
    @GetMapping("/reviews")
    public String stayReviews(HttpSession session, Model model) throws Exception {

    // ═══════════════════════════════════════
    // ① 로그인 확인
    // ═══════════════════════════════════════
    MemberVO member = getBizMember(session);
    if (member == null) {
        return "redirect:/login";
    }

    // ═══════════════════════════════════════
    // ② 이 사업자의 숙소 정보 가져오기
    // ═══════════════════════════════════════
    StayVO stay = bizStayService.resolveStayByBizId(member.getMemberId());
    if (stay == null || stay.getStayId() == null) {
        return "redirect:/mypage/biz";
    }

    // ═══════════════════════════════════════
    // ③ DB에서 리뷰 목록 조회
    // 2026-07-27 박유정 — TB_REVIEW(STAY) 사업자 숙소 리뷰
    // ═══════════════════════════════════════
    List<StayReviewVO> reviewList =
            bizStayService.getBizStayReviews(stay.getStayId());

    // ═══════════════════════════════════════
    // ④ DB에서 삭제 요청 목록 조회
    // 2026-07-27 박유정 — TB_REVIEW_DELETE_REQUEST (bizNo 기준)
    // ═══════════════════════════════════════
    List<ReviewDeleteRequestVO> deleteRequests = List.of();
    if (stay.getBizNo() != null) {
        deleteRequests = bizStayService.getBizReviewDeleteRequests(
                stay.getStayId(), stay.getBizNo());
    }

    // ═══════════════════════════════════════
    // ⑤ "삭제 요청 대기 중"인 리뷰 ID 모으기
    // 2026-07-27 박유정 — PENDING 건은 답글·삭제요청 버튼 숨김용
    // ═══════════════════════════════════════
    Set<Long> pendingReviewIds = new HashSet<>();
    for (ReviewDeleteRequestVO dr : deleteRequests) {
        if ("PENDING".equals(dr.getStatusCd()) && dr.getReviewId() != null) {
            pendingReviewIds.add(dr.getReviewId());
        }
    }

    // ═══════════════════════════════════════
    // ⑥ 리뷰 목록 → JSP용 Map 리스트로 변환
    // 2026-07-27 박유정 — reviews.jsp var reviews (id/author/date/rating/content/reply/deleteRequestPending)
    // ═══════════════════════════════════════
    SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");
    List<Map<String, Object>> rows = new ArrayList<>();

    for (StayReviewVO r : reviewList) {
        Map<String, Object> row = new LinkedHashMap<>();
        row.put("id", r.getReviewId());
        row.put("author", (r.getNickname() != null && !r.getNickname().isBlank())
                ? r.getNickname() : "회원");
        row.put("date", r.getRegDate() != null ? df.format(r.getRegDate()) : "");
        row.put("rating", r.getRating() != null ? r.getRating() : 0);
        row.put("content", r.getContent() != null ? r.getContent() : "");
        row.put("reply", r.getBizReply());
        row.put("deleteRequestPending", pendingReviewIds.contains(r.getReviewId()));
        rows.add(row);
    }

    // ═══════════════════════════════════════
    // ⑦ 삭제 요청 목록 → JSP용 Map 리스트로 변환
    // 2026-07-27 박유정 — reviews.jsp var deleteRequests (statusCd·reqDate·processDate 등)
    // ═══════════════════════════════════════
    List<Map<String, Object>> deleteRows = new ArrayList<>();

    for (ReviewDeleteRequestVO dr : deleteRequests) {
        Map<String, Object> row = new LinkedHashMap<>();
        row.put("requestId", dr.getRequestId());
        row.put("reviewId", dr.getReviewId());
        row.put("author", (dr.getReviewerNickname() != null && !dr.getReviewerNickname().isBlank())
                ? dr.getReviewerNickname() : "회원");
        row.put("rating", dr.getReviewRating() != null ? dr.getReviewRating() : 0);
        row.put("content", dr.getReviewContent() != null ? dr.getReviewContent() : "(삭제된 리뷰)");
        row.put("requestReason", dr.getRequestReason() != null ? dr.getRequestReason() : "");
        row.put("rejectReason", dr.getRejectReason());
        row.put("statusCd", dr.getStatusCd());
        row.put("reqDate", dr.getReqDate() != null ? df.format(dr.getReqDate()) : "");
        row.put("processDate", dr.getProcessDate() != null ? df.format(dr.getProcessDate()) : "");
        deleteRows.add(row);
    }

    // ═══════════════════════════════════════
    // ⑧ JSP에 데이터 넘기고 화면 반환
    // 2026-07-27 박유정 — reviewListJson / deleteRequestListJson (ObjectMapper)
    // ═══════════════════════════════════════
    model.addAttribute("stay", stay);
    model.addAttribute("reviewListJson", objectMapper.writeValueAsString(rows));
    model.addAttribute("deleteRequestListJson", objectMapper.writeValueAsString(deleteRows));
    return "biz/stay/reviews";
}

// 2026-07-28 박유정 - 리뷰 답글 작성/수정
    @PostMapping("/reviews/reply")
    public String saveReviewReply(@RequestParam("reviewId") Long reviewId,
                                  @RequestParam("bizReply") String bizReply,
                                  HttpSession session,
                                  RedirectAttributes rttr) throws Exception {
        MemberVO member = getBizMember(session);
        if (member == null) {
            return "redirect:/login";
        }
        StayVO stay = bizStayService.resolveStayByBizId(member.getMemberId());
        if (stay == null || stay.getStayId() == null) {
            return "redirect:/mypage/biz";
        }
        try {
            bizStayService.saveReviewBizReply(stay.getStayId(), reviewId, bizReply);
            rttr.addFlashAttribute("msg", "답글이 저장되었습니다.");
        } catch (IllegalArgumentException | IllegalStateException e) {
            rttr.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/biz/stay/reviews";
    }

// 2026-07-28 박유정 - 리뷰 삭제 요청
    @PostMapping("/reviews/delete-request")
    public String requestReviewDelete(@RequestParam("reviewId") Long reviewId,
                                      @RequestParam("requestReason") String requestReason,
                                      HttpSession session,
                                      RedirectAttributes rttr) throws Exception {
        MemberVO member = getBizMember(session);
        if (member == null) {
            return "redirect:/login";
        }
        StayVO stay = bizStayService.resolveStayByBizId(member.getMemberId());
        if (stay == null || stay.getStayId() == null || stay.getBizNo() == null) {
            return "redirect:/mypage/biz";
        }
        try {
            bizStayService.requestReviewDelete(
                stay.getStayId(),
                stay.getBizNo(),
                reviewId,
                requestReason);
            rttr.addFlashAttribute("msg", "삭제 요청이 접수되었습니다. 관리자 검토 후 처리됩니다.");
        } catch (IllegalArgumentException | IllegalStateException e) {
            rttr.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/biz/stay/reviews";
       }
    @GetMapping("/contract")
    public String stayContract(HttpSession session) {
        if (getBizMember(session) == null)
            return "redirect:/login";
        return "biz/stay/contract";
    }
/* 사업자(숙소) 정산관리 — 2026/07/30 장우철 2-1 요약 / 2-2 목록 */
    @GetMapping("/settlement")
    public String staySettlement(HttpSession session, Model model,
                                 @RequestParam(value = "month", required = false, defaultValue = "all") String month,
                                 @RequestParam(value = "status", required = false, defaultValue = "all") String status) {
        MemberVO member = getBizMember(session);
        if (member == null) {
            return "redirect:/login";
        }

        StayVO stay = bizStayService.resolveStayByBizId(member.getMemberId());
        if (stay == null || stay.getBizNo() == null) {
            return "redirect:/mypage/biz";
        }

        Long bizNo = stay.getBizNo();
        StaySettlementSummaryVO summary = staySettlementService.getStaySettlementSummary(bizNo);
        List<StaySettlementVO> settlements = staySettlementService.getStaySettlementList(bizNo, month, status);
        List<String> settleMonths = staySettlementService.getStaySettlementMonths(bizNo);
        // 2026/07/30 장우철 — 4-1 중간정산 요청 폼용 객실 목록 (저장은 4-2)
        List<StayRoomVO> roomList = (stay.getStayId() != null)
                ? bizStayService.getRoomList(stay.getStayId())
                : java.util.Collections.emptyList();

        model.addAttribute("stay", stay);
        model.addAttribute("summary", summary);
        model.addAttribute("settlements", settlements);
        model.addAttribute("settleMonths", settleMonths);
        model.addAttribute("filterMonth", month);
        model.addAttribute("filterStatus", status);
        model.addAttribute("roomList", roomList);
        //2026/08/06 장우철 — 정산계좌 모달용 (숙소·쇼핑 공통 SETTLE_*)
        BizInfoVO settleAcc = bizStoreService.getSettleAccount(bizNo);
        model.addAttribute("settleAccountInfo",
                settleAcc != null ? settleAcc : new BizInfoVO());
        return "biz/stay/settlement";
    }

    /**
     * 2026/08/06 장우철 — 숙소 정산 계좌 변경
     * POST /biz/stay/settlement/account
     */
    @PostMapping("/settlement/account")
    @ResponseBody
    public Map<String, Object> updateStaySettleAccount(HttpSession session,
                                                       @RequestParam String settleBank,
                                                       @RequestParam String settleBankCode,
                                                       @RequestParam String settleAccount,
                                                       @RequestParam String settleHolder,
                                                       @RequestParam(required = false) String settleVerifyYn) {
        Map<String, Object> result = new HashMap<>();
        MemberVO member = getBizMember(session);
        if (member == null) {
            result.put("ok", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }
        StayVO stay = bizStayService.resolveStayByBizId(member.getMemberId());
        if (stay == null || stay.getBizNo() == null) {
            result.put("ok", false);
            result.put("message", "숙소 사업자 정보가 없습니다.");
            return result;
        }
        if (!"Y".equals(settleVerifyYn)) {
            result.put("ok", false);
            result.put("message", "계좌 인증을 완료한 뒤 저장해 주세요.");
            return result;
        }
        boolean ok = bizStoreService.updateSettleAccount(
                stay.getBizNo(), settleBank, settleBankCode, settleAccount, settleHolder);
        result.put("ok", ok);
        result.put("message", ok ? "정산 계좌가 저장되었습니다." : "정산 계좌 저장에 실패했습니다.");
        return result;
    }

    /**
     * 2026/07/30 장우철 — 2-4 정산 상세 ITEM JSON
     * GET /biz/stay/settlement/items?settleId=
     */
    @GetMapping("/settlement/items")
    @ResponseBody
    public Map<String, Object> staySettlementItems(HttpSession session,
                                                   @RequestParam("settleId") Long settleId) {
        Map<String, Object> result = new HashMap<>();
        MemberVO member = getBizMember(session);
        if (member == null) {
            result.put("ok", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }

        StayVO stay = bizStayService.resolveStayByBizId(member.getMemberId());
        if (stay == null || stay.getBizNo() == null) {
            result.put("ok", false);
            result.put("message", "숙소 사업자 정보가 없습니다.");
            return result;
        }

        List<StaySettlementItemVO> items =
                staySettlementService.getStaySettlementItems(stay.getBizNo(), settleId);
        result.put("ok", true);
        result.put("items", items);
        return result;
    }

    /**
     * 2026/07/30 장우철 — 4-2 중간정산 요청 저장
     * POST /biz/stay/settlement/request
     * body: { requestScope, roomId?, targetEnd, requestMemo? }
     * TARGET_START 는 서버에서 해당 월 1일로 고정
     */
    @PostMapping("/settlement/request")
    @ResponseBody
    public Map<String, Object> staySettlementRequest(HttpSession session,
                                                     @RequestBody Map<String, Object> body) {
        Map<String, Object> result = new HashMap<>();
        MemberVO member = getBizMember(session);
        if (member == null) {
            result.put("ok", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }

        StayVO stay = bizStayService.resolveStayByBizId(member.getMemberId());
        if (stay == null || stay.getBizNo() == null) {
            result.put("ok", false);
            result.put("message", "숙소 사업자 정보가 없습니다.");
            return result;
        }

        try {
            String scope = body.get("requestScope") == null
                    ? null : String.valueOf(body.get("requestScope"));
            Long roomId = null;
            if (body.get("roomId") != null && !String.valueOf(body.get("roomId")).isBlank()) {
                roomId = Long.parseLong(String.valueOf(body.get("roomId")));
            }
            String endStr = body.get("targetEnd") == null
                    ? null : String.valueOf(body.get("targetEnd"));
            if (endStr == null || endStr.isBlank()) {
                throw new IllegalArgumentException("대상 종료일(컷오프)을 입력하세요.");
            }
            java.util.Date targetEnd = java.sql.Date.valueOf(endStr.substring(0, 10));
            String memo = body.get("requestMemo") == null
                    ? null : String.valueOf(body.get("requestMemo"));

            StaySettlementRequestVO saved = staySettlementService.createMidSettlementRequest(
                    stay.getBizNo(), scope, roomId, targetEnd, memo);

            result.put("ok", true);
            result.put("requestId", saved.getRequestId());
            result.put("targetStart", saved.getTargetStart());
            result.put("targetEnd", saved.getTargetEnd());
            // 5-4 A: 화면 문구만 (사이트 알림/이메일 없음)
            result.put("message", "중간정산 요청이 접수되었습니다. 관리자 승인 후 지급 예정입니다.");
        } catch (IllegalArgumentException | IllegalStateException e) {
            result.put("ok", false);
            result.put("message", e.getMessage());
        } catch (Exception e) {
            result.put("ok", false);
            result.put("message", "요청 처리 중 오류가 발생했습니다.");
        }
        return result;
    }

    @GetMapping("/info")
    public String stayInfo(HttpSession session, Model model) {
        MemberVO member = getBizMember(session);
        if (member == null) return "redirect:/login";

        StayVO stay = bizStayService.resolveStayByBizId(member.getMemberId());
        if (stay == null) {
            return "redirect:/mypage/biz";
        }
        model.addAttribute("stay", stay);   
        return "biz/stay/info";

    }

    /*사업자 숙소관리 메뉴 0702지윤*/
    @GetMapping("/profile")
    public String stayLodge(HttpSession session, Model model) throws Exception {
        MemberVO member = getBizMember(session);
        if (member == null) return "redirect:/login";

        StayVO stay = bizStayService.resolveStayByBizId(member.getMemberId());
        if (stay == null) return "redirect:/mypage/biz";

        model.addAttribute("stay", stay);

        List<FileVO> imgList = fileService.getFileList("STAY", stay.getStayId());
        model.addAttribute("imgList", imgList);

        return "biz/stay/profile";
    }

    @PostMapping("/profile")
    public String saveProfile(StayVO vo,
                              @RequestParam(value = "facilities", required = false) String[] facilities,
                              @RequestParam(value = "imgList", required = false) MultipartFile[] imgList,
                              @RequestParam(value = "deleteFileIds", required = false) Long[] deleteFileIds,
                              HttpSession session,
                              RedirectAttributes rttr) throws Exception {

        MemberVO member = getBizMember(session);
        if (member == null) return "redirect:/login";
        
        StayVO stay = bizStayService.resolveStayByBizId(member.getMemberId());
        if (stay == null || stay.getStayId() == null) {
            rttr.addFlashAttribute("errorMsg", "숙소 정보를 불러올 수 없습니다.");
            return "redirect:/biz/stay/profile";
        }
        vo.setStayId(stay.getStayId());        
        
        // DB에서 stayId 확보 (폼 조작 방지)
        if (vo.getName() == null || vo.getName().isBlank()) {
            vo.setName(vo.getName());
        }
        if (vo.getPhone() == null || vo.getPhone().isBlank()) {
            vo.setPhone(vo.getPhone());
        }
        if (vo.getAddr() == null || stay.getAddr().isBlank()) {
            vo.setAddr(stay.getAddr());
            if (vo.getLat() == null) {
                vo.setLat(stay.getLat());
            }
            if (vo.getLng() == null) {
                vo.setLng(vo.getLng());
            }
        }
        if (vo.getAddrDetail() == null) {
            vo.setAddrDetail(vo.getAddrDetail());
        }

        // 편의시설 체크박스 배열 → 콤마 구분 문자열
        vo.setFacilities(facilities != null ? String.join(",", facilities) : "");

        // 기존 이미지 삭제
        if (deleteFileIds != null) {
            for (Long fileId : deleteFileIds) {
                fileService.deleteFile(fileId);
            }
        }

        // 새 이미지 업로드
        if (imgList != null) {
            for (MultipartFile img : imgList) {
                if (img == null || img.isEmpty()) continue;
                fileService.uploadFile(img, "STAY", stay.getStayId());
            }
        }

        // TB_STAY 운영정보 업데이트
        bizStayService.updateStayProfile(vo);

        rttr.addFlashAttribute("msg", "저장되었습니다.");
        return "redirect:/biz/stay/profile";
    }

    // ── GET: 객실 목록 ──
    @GetMapping("/rooms")
    public String stayRooms(HttpSession session, Model model) {
        MemberVO member = getBizMember(session);
        if (member == null) return "redirect:/login";

        StayVO stay = bizStayService.resolveStayByBizId(member.getMemberId());
        if (stay == null) return "redirect:/mypage/biz";

        List<StayRoomVO> roomList = bizStayService.getRoomList(stay.getStayId());
        model.addAttribute("roomList", roomList);

        return "biz/stay/rooms";
    }

    // ── POST: 객실 등록/수정 ──
    @PostMapping("/rooms")
    public String saveRoom(StayRoomVO room,
                           HttpSession session,
                           RedirectAttributes rttr) {

        MemberVO member = getBizMember(session);
        if (member == null) return "redirect:/login";

        StayVO stay = bizStayService.resolveStayByBizId(member.getMemberId());
        room.setStayId(stay.getStayId());

        if (room.getRoomId() == null) {
            // 신규 등록 (승인 없이 바로 등록)
            room.setStatusCd("APPROVE");
            bizStayService.insertRoom(room);
            rttr.addFlashAttribute("msg", "객실이 등록되었습니다.");
        } else {
            try {
                bizStayService.updateRoom(room);
                rttr.addFlashAttribute("msg", "객실 정보가 수정되었습니다.");
            } catch (IllegalStateException e) {
                rttr.addFlashAttribute("errorMsg", e.getMessage());
            }
        }
        return "redirect:/biz/stay/rooms";
    }

    // ── POST: 객실 상태 (운영중/운영중지/운영종료) ──
    @PostMapping("/rooms/status")
    public String changeRoomStatus(@RequestParam Long roomId,
                                   @RequestParam String statusCd,
                                   HttpSession session,
                                   RedirectAttributes rttr) {

        MemberVO member = getBizMember(session);
        if (member == null) return "redirect:/login";

        StayVO stay = bizStayService.resolveStayByBizId(member.getMemberId());
        if (stay == null) return "redirect:/mypage/biz";

        try {
            bizStayService.changeRoomStatus(roomId, stay.getStayId(), statusCd);
            if ("HOLD".equals(statusCd)) {
                rttr.addFlashAttribute("msg", "객실을 운영중지했습니다. 다시 운영할 때까지 예약이 불가합니다.");
            } else if ("CLOSED".equals(statusCd)) {
                rttr.addFlashAttribute("msg", "객실을 운영종료했습니다. 유저에게는 더 이상 보이지 않습니다.");
            } else {
                rttr.addFlashAttribute("msg", "객실을 다시 운영중으로 변경했습니다.");
            }
        } catch (IllegalStateException e) {
            rttr.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/biz/stay/rooms";
    }
    //
    // HYJ 26.07.29 ── 쿠폰 신청 목록 ──
    // 2026/08/01 장우철 — BIZ_MEMBER_NO = BIZ_NO
    //
    @GetMapping({"/coupon", "/coupon/"})
    public String couponList(HttpSession session, Model model) {
        MemberVO member = getBizMember(session);
        if (member == null) return "redirect:/login";

        Long bizNo = bizStayService.getBizNo(member.getMemberId());
        if (bizNo == null) {
            model.addAttribute("errorMsg", "사업자 정보를 찾을 수 없습니다.");
            model.addAttribute("couponList", java.util.Collections.emptyList());
            return "biz/stay/coupon";
        }

        model.addAttribute("couponList", bizStayService.getCouponList(bizNo));
        return "biz/stay/coupon";
    }

    // ── 쿠폰 신청 POST ──
    @PostMapping("/coupon/apply")
    public String applyCoupon(BizCouponVO vo,
                              HttpSession session,
                              RedirectAttributes rttr) {
        MemberVO member = getBizMember(session);
        if (member == null) return "redirect:/login";

        try {
            Long bizNo = bizStayService.getBizNo(member.getMemberId());
            if (bizNo == null) {
                rttr.addFlashAttribute("errorMsg", "사업자 정보를 찾을 수 없습니다.");
                return "redirect:/biz/stay/coupon";
            }
            bizStayService.applyCoupon(bizNo, vo);
            rttr.addFlashAttribute("msg", "쿠폰 승인 신청이 완료되었습니다.");
        } catch (Exception e) {
            rttr.addFlashAttribute("errorMsg", "쿠폰 신청 중 오류가 발생했습니다.");
        }
        return "redirect:/biz/stay/coupon";
    }

    // ── 쿠폰 수정 POST (PENDING 상태일 때만) ──
    @PostMapping("/coupon/update")
    public String updateCoupon(BizCouponVO vo,
                               HttpSession session,
                               RedirectAttributes rttr) {
        MemberVO member = getBizMember(session);
        if (member == null) return "redirect:/login";

        try {
            Long bizNo = bizStayService.getBizNo(member.getMemberId());
            if (bizNo == null) {
                rttr.addFlashAttribute("errorMsg", "사업자 정보를 찾을 수 없습니다.");
                return "redirect:/biz/stay/coupon";
            }
            bizStayService.updateCoupon(bizNo, vo);
            rttr.addFlashAttribute("msg", "쿠폰 정보가 수정되었습니다.");
        } catch (IllegalStateException e) {
            if ("NOT_PENDING".equals(e.getMessage())) {
                rttr.addFlashAttribute("errorMsg", "승인 대기 상태의 쿠폰만 수정할 수 있습니다.");
            } else {
                rttr.addFlashAttribute("errorMsg", "수정 권한이 없습니다.");
            }
        } catch (Exception e) {
            rttr.addFlashAttribute("errorMsg", "수정 중 오류가 발생했습니다.");
        }
        return "redirect:/biz/stay/coupon";
    }

    // ── 쿠폰 삭제 POST (PENDING 상태일 때만) ──
    @PostMapping("/coupon/delete")
    public String deleteCoupon(@RequestParam Long couponId,
                               HttpSession session,
                               RedirectAttributes rttr) {
        MemberVO member = getBizMember(session);
        if (member == null) return "redirect:/login";

        try {
            Long bizNo = bizStayService.getBizNo(member.getMemberId());
            if (bizNo == null) {
                rttr.addFlashAttribute("errorMsg", "사업자 정보를 찾을 수 없습니다.");
                return "redirect:/biz/stay/coupon";
            }
            bizStayService.deleteCoupon(bizNo, couponId);
            rttr.addFlashAttribute("msg", "쿠폰 신청이 삭제되었습니다.");
        } catch (IllegalStateException e) {
            if ("NOT_PENDING".equals(e.getMessage())) {
                rttr.addFlashAttribute("errorMsg", "승인 대기 상태의 쿠폰만 삭제할 수 있습니다.");
            } else {
                rttr.addFlashAttribute("errorMsg", "삭제 권한이 없습니다.");
            }
        } catch (Exception e) {
            rttr.addFlashAttribute("errorMsg", "삭제 중 오류가 발생했습니다.");
        }
        return "redirect:/biz/stay/coupon";
    }

    // ── 쿠폰 조기 마감 POST (지윤 26.08.07, store closeCoupon과 동일 패턴) ──
    @PostMapping("/coupon/close")
    public String closeCoupon(@RequestParam Long couponId,
                              HttpSession session,
                              RedirectAttributes rttr) {
        MemberVO member = getBizMember(session);
        if (member == null) return "redirect:/login";

        try {
            Long bizNo = bizStayService.getBizNo(member.getMemberId());
            if (bizNo == null) {
                rttr.addFlashAttribute("errorMsg", "사업자 정보를 찾을 수 없습니다.");
                return "redirect:/biz/stay/coupon";
            }
            bizStayService.closeCoupon(bizNo, couponId);
            rttr.addFlashAttribute("msg", "쿠폰이 조기 마감되었습니다.");
        } catch (IllegalStateException e) {
            if ("NOT_OWNER".equals(e.getMessage())) {
                rttr.addFlashAttribute("errorMsg", "본인이 등록한 쿠폰만 마감할 수 있습니다.");
            } else if ("NOT_APPROVED".equals(e.getMessage())) {
                rttr.addFlashAttribute("errorMsg", "승인된 쿠폰만 조기 마감할 수 있습니다.");
            } else if ("NOT_ACTIVE".equals(e.getMessage())) {
                rttr.addFlashAttribute("errorMsg", "현재 게시 중인 쿠폰만 조기 마감할 수 있습니다.");
            } else {
                rttr.addFlashAttribute("errorMsg", "쿠폰 조기 마감에 실패했습니다.");
            }
        } catch (Exception e) {
            rttr.addFlashAttribute("errorMsg", "쿠폰 조기 마감 중 오류가 발생했습니다.");
        }
        return "redirect:/biz/stay/coupon";
    }

    //
    //HYJ 26.07.31 배너신청
    //
    // 배너 신청 목록 페이지
    @GetMapping("/banner")
    public String bannerList(HttpSession session, Model model) {
        MemberVO biz = getBizMember(session);
        if (biz == null) return "redirect:/login";

        Long bizNo = bizStayService.getBizNo(biz.getMemberId());
        List<MainBannerVO> bannerList = bizStayService.getBannerList(bizNo);
        model.addAttribute("bannerList", bannerList);
        model.addAttribute("bizPage", "banner");
        return "biz/stay/banner";
    }

    // 배너 신청 폼 페이지
    @GetMapping("/banner/form")
    public String bannerForm(HttpSession session, Model model) {
        if (getBizMember(session) == null) return "redirect:/login";
        model.addAttribute("bizPage", "banner");
        return "biz/stay/banner-form";
    }

    // 배너 신청 처리
    @PostMapping("/banner")
    public String bannerSubmit(@RequestParam String title,
                                  @RequestParam(required = false) String linkUrl,
                                  @RequestParam String positionCd,
                                  @RequestParam String startDate,
                                  @RequestParam String endDate,
                                  @RequestParam(required = false) MultipartFile bannerImage,
                                  HttpSession session,
                                  RedirectAttributes rttr) {
        MemberVO biz = getBizMember(session);
        if (biz == null) return "redirect:/login";

        try {
            Long bizNo = bizStayService.getBizNo(biz.getMemberId());

            MainBannerVO banner = new MainBannerVO();
            banner.setBizNo(bizNo);
            banner.setTitle(title);
            banner.setLinkUrl(linkUrl);
            banner.setPositionCd(positionCd);
            // 2026/08/01 장우철 — DDL VARCHAR2(YYYY-MM-DD), input type=date 값 그대로 저장
            banner.setStartDate(startDate);
            banner.setEndDate(endDate);
            banner.setStatusCd("PENDING");

            bizStayService.applyBanner(banner, bannerImage);
            rttr.addFlashAttribute("msg", "배너 신청이 완료되었습니다. 관리자 승인 후 노출됩니다.");
        } catch (IllegalArgumentException e) {
            rttr.addFlashAttribute("errorMsg", e.getMessage());
        } catch (Exception e) {
            rttr.addFlashAttribute("errorMsg", "배너 신청 중 오류가 발생했습니다.");
        }
        return "redirect:/biz/stay/banner";
    }
    // 2026-08-13 박유정 — 빈 숫자칸("") → null (Integer 바인딩 오류 방지)
    @InitBinder
    public void initBinder(WebDataBinder binder) {
      binder.registerCustomEditor(Integer.class, new CustomNumberEditor(Integer.class, true));
    }
}
