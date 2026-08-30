/**
 * 역할: 사업자 쇼핑몰 URL 처리 → Service 호출 → JSP 반환
 *
 * 연결
 * - Service: BizStoreService
 * - 상속: BizBaseController (사업자 로그인 체크)
 *
 * SQL·비즈니스 로직은 넣지 말 것 → Service로 위임
 * return 경로는 담당 JSP와 동일하게 맞출 것
 */

package com.petcare.petcare.biz.store.controller;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.petcare.petcare.biz.controller.BizBaseController;
import com.petcare.petcare.biz.store.service.BizStoreService;
import com.petcare.petcare.biz.store.vo.BizProductVO;
import com.petcare.petcare.biz.store.vo.BizReviewVO;
import com.petcare.petcare.member.vo.MemberVO;
import com.petcare.petcare.settlement.service.StoreSettlementService;
import com.petcare.petcare.settlement.vo.StoreSettlementItemVO;
import com.petcare.petcare.settlement.vo.StoreSettlementRequestVO;
import com.petcare.petcare.settlement.vo.StoreSettlementSummaryVO;
import com.petcare.petcare.settlement.vo.StoreSettlementVO;
import com.petcare.petcare.store.vo.OptionVO;

import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.servlet.http.HttpSession;

import com.petcare.petcare.biz.stay.service.BizStayService;
import com.petcare.petcare.main.banner.vo.MainBannerVO;

import org.springframework.beans.propertyeditors.CustomNumberEditor;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.InitBinder;

@Controller("bizStoreController")
@RequestMapping("/biz/store")
public class BizStoreController extends BizBaseController {

    //지윤 26.07.14 상품관리(BIZ-04) 서비스 주입
    @Autowired
    private BizStoreService bizStoreService;

    //지윤 26.07.20 추가: 리뷰관리 JSON 응답용
    @Autowired
    private ObjectMapper objectMapper;

    // 2026/08/05 장우철 — 쇼핑 정산 S9
    @Autowired
    private StoreSettlementService storeSettlementService;

    //지윤 26.07.24 추가: 택배사 API 연동용
    @Autowired
    private com.petcare.petcare.common.external.service.SmartTrackerService smartTrackerService;

    // 2026-08-06 박유정 — 쇼핑 배너 (BizStayService 공용)
    @Autowired
    private BizStayService bizStayService;

    //지윤 26.07.21 추가: 사이드바 "주문관리" 뱃지 하드코딩(12) 제거 - 이 컨트롤러가 처리하는 모든 페이지(상품관리/주문관리/배송관리/리뷰관리 등) 렌더링 전에
    //자동으로 실행돼서 model에 paidOrderCount를 채워줌. 로그인 안 됐으면 0으로 조용히 넘어감 (개별 핸들러가 알아서 redirect:/login 처리하므로 여기선 막지 않음)
    @ModelAttribute
    public void addPaidOrderCount(HttpSession session, Model model) {
        MemberVO biz = getBizMember(session);
        if (biz == null) {
            model.addAttribute("paidOrderCount", 0);
            model.addAttribute("returnRequestedCount", 0);
            return;
        }
        Long bizNo = bizStoreService.getBizNo(biz.getMemberId());
        model.addAttribute("paidOrderCount", bizStoreService.getPaidOrderCount(bizNo));
        // 2026/08/04 장우철 — 환불신청 대기 뱃지
        model.addAttribute("returnRequestedCount", bizStoreService.getReturnRequestedCount(bizNo));
    }

   //지윤 26.07.23 수정: 목업 -> 실데이터 연동 (매출 통계 라인차트/이번달매출은 패스, 나머지는 실데이터)
   @GetMapping({"", "/"})
   public String storeDashboard(HttpSession session, Model model) {
       MemberVO biz = getBizMember(session);
       if (biz == null) return "redirect:/login";
       Long bizNo = bizStoreService.getBizNo(biz.getMemberId());

       model.addAttribute("todayNewOrderCount", bizStoreService.getTodayNewOrderCount(bizNo));
       model.addAttribute("statusCounts", bizStoreService.getOrderStatusCounts(bizNo));

       List<com.petcare.petcare.biz.store.vo.BizOrderVO> orders = bizStoreService.getOrderList(bizNo, null);
       model.addAttribute("recentOrders", orders.subList(0, Math.min(3, orders.size())));

       List<BizReviewVO> reviews = bizStoreService.getBizReviewList(bizNo);
       model.addAttribute("recentReviews", reviews.subList(0, Math.min(3, reviews.size())));

       return "biz/store/dashboard";
   }

    //지윤 26.07.14 수정: 상품목록 실데이터 연동 (검색/카테고리/상태 필터 + 페이지네이션, 페이지당 10개)
    //2026/08/06 장우철: 카테고리 필터를 ID → 이름(동일명칭 통합)으로 변경
    @GetMapping("/products")
    public String storeProducts(@RequestParam(required = false) String keyword,
                                 @RequestParam(required = false) String categoryName,
                                 @RequestParam(required = false) String statusCd,
                                 @RequestParam(defaultValue = "1") int page,
                                 HttpSession session, Model model) {
        MemberVO biz = getBizMember(session);
        if (biz == null) return "redirect:/login";

        //로그인 세션엔 bizNo가 없어서, 로그인 ID로 되짚어 조회
        Long bizNo = bizStoreService.getBizNo(biz.getMemberId());

        model.addAttribute("productList", bizStoreService.getProductList(bizNo, keyword, categoryName, statusCd, page));
        model.addAttribute("totalPages", bizStoreService.getTotalPages(bizNo, keyword, categoryName, statusCd));
        model.addAttribute("totalCount", bizStoreService.getTotalCount(bizNo, keyword, categoryName, statusCd));
        model.addAttribute("currentPage", page);
        model.addAttribute("categoryList", bizStoreService.getLeafCategories());
        model.addAttribute("filterCategoryNames", bizStoreService.getFilterCategoryNames());
        model.addAttribute("selectedKeyword", keyword);
        model.addAttribute("selectedCategoryName", categoryName);
        model.addAttribute("selectedStatusCd", statusCd);
        return "biz/store/products";
    }

        //지윤 26.07.20 수정: 목업 -> 실데이터 연동 (상태 탭 필터)
    // 2026/08/13 장우철 — 환불·배송중·배송완료 탭 제거. 환불 완료는 /biz/store/refunds
    @GetMapping("/orders")
    public String storeOrders(@RequestParam(required = false) String statusCd, HttpSession session, Model model) {
        MemberVO biz = getBizMember(session);
        if (biz == null) return "redirect:/login";
        Long bizNo = bizStoreService.getBizNo(biz.getMemberId());

        if ("RETURN_DONE".equals(statusCd)) {
            return "redirect:/biz/store/refunds?statusCd=DONE";
        }

        model.addAttribute("statusCounts", bizStoreService.getOrderStatusCounts(bizNo));
        model.addAttribute("selectedStatusCd", statusCd);
        model.addAttribute("orderList", bizStoreService.getOrderList(bizNo, statusCd));
        return "biz/store/orders";
    }

    // 2026/08/04 장우철 — 환불신청 목록 (처리용: REQUESTED / RETURNING)
    // 2026/08/11 장우철 — P8: DONE/REJECTED 탭 추가 (숙소 예약관리와 유사)
    @GetMapping("/refunds")
    public String storeRefunds(@RequestParam(required = false, defaultValue = "REQUESTED") String statusCd,
                               HttpSession session, Model model) {
        MemberVO biz = getBizMember(session);
        if (biz == null) return "redirect:/login";
        Long bizNo = bizStoreService.getBizNo(biz.getMemberId());
        if (!"REQUESTED".equals(statusCd) && !"RETURNING".equals(statusCd)
                && !"DONE".equals(statusCd) && !"REJECTED".equals(statusCd)) {
            statusCd = "REQUESTED";
        }
        model.addAttribute("returnList", bizStoreService.getReturnList(bizNo, statusCd));
        model.addAttribute("selectedStatusCd", statusCd);
        model.addAttribute("requestedCount", bizStoreService.getReturnRequestedCount(bizNo));
        model.addAttribute("returningCount", bizStoreService.getReturnList(bizNo, "RETURNING").size());
        model.addAttribute("doneCount", bizStoreService.getReturnList(bizNo, "DONE").size());
        model.addAttribute("rejectedCount", bizStoreService.getReturnList(bizNo, "REJECTED").size());
        return "biz/store/refunds";
    }

    @GetMapping("/refunds/detail")
    public String storeRefundDetail(@RequestParam("orderItemId") Long orderItemId,
                                    HttpSession session, Model model, RedirectAttributes rttr) {
        MemberVO biz = getBizMember(session);
        if (biz == null) return "redirect:/login";
        Long bizNo = bizStoreService.getBizNo(biz.getMemberId());
        var detail = bizStoreService.getReturnDetail(orderItemId, bizNo);
        if (detail == null) {
            rttr.addFlashAttribute("errorMsg", "환불 신청을 찾을 수 없습니다.");
            return "redirect:/biz/store/refunds";
        }
        model.addAttribute("refund", detail);
        return "biz/store/refund-detail";
    }

    @PostMapping("/refunds/approve")
    public String approveRefund(@RequestParam("orderItemId") Long orderItemId,
                                HttpSession session, RedirectAttributes rttr) {
        MemberVO biz = getBizMember(session);
        if (biz == null) return "redirect:/login";
        Long bizNo = bizStoreService.getBizNo(biz.getMemberId());
        String err = bizStoreService.approveReturn(orderItemId, bizNo);
        rttr.addFlashAttribute(err == null ? "msg" : "errorMsg",
                err == null ? "승인되었습니다. 회수 확인 후 회수완료를 눌러 주세요." : err);
        return "redirect:/biz/store/refunds/detail?orderItemId=" + orderItemId;
    }

    @PostMapping("/refunds/reject")
    public String rejectRefund(@RequestParam("orderItemId") Long orderItemId,
                               @RequestParam("rejectReason") String rejectReason,
                               HttpSession session, RedirectAttributes rttr) {
        MemberVO biz = getBizMember(session);
        if (biz == null) return "redirect:/login";
        Long bizNo = bizStoreService.getBizNo(biz.getMemberId());
        String err = bizStoreService.rejectReturn(orderItemId, bizNo, rejectReason);
        rttr.addFlashAttribute(err == null ? "msg" : "errorMsg",
                err == null ? "거절 처리되었습니다." : err);
        return err == null
                ? "redirect:/biz/store/refunds?statusCd=REQUESTED"
                : "redirect:/biz/store/refunds/detail?orderItemId=" + orderItemId;
    }

    @PostMapping("/refunds/complete")
    public String completeRefund(@RequestParam("orderItemId") Long orderItemId,
                                 HttpSession session, RedirectAttributes rttr) {
        MemberVO biz = getBizMember(session);
        if (biz == null) return "redirect:/login";
        Long bizNo = bizStoreService.getBizNo(biz.getMemberId());
        String err = bizStoreService.completeReturn(orderItemId, bizNo);
        rttr.addFlashAttribute(err == null ? "msg" : "errorMsg",
                err == null ? "회수완료 및 환불이 처리되었습니다." : err);
        return err == null
                ? "redirect:/biz/store/refunds?statusCd=DONE"
                : "redirect:/biz/store/refunds/detail?orderItemId=" + orderItemId;
    }

    //지윤 26.07.20 추가: 주문 상세 조회 (모달/상세영역 프리필용 AJAX)
    @GetMapping("/orders/{id}")
    @ResponseBody
    public com.petcare.petcare.biz.store.vo.BizOrderVO getOrderDetailJson(@PathVariable Long id, HttpSession session) {
        MemberVO biz = getBizMember(session);
        if (biz == null) return null;
        Long bizNo = bizStoreService.getBizNo(biz.getMemberId());
        return bizStoreService.getOrderDetail(id, bizNo);
    }

    //지윤 26.07.20 추가: 주문 상태 변경 (택배사/송장번호 같이 저장)
    @PostMapping("/orders/{id}/status")
    @ResponseBody
    public String updateOrderStatus(@PathVariable Long id,
                                     @RequestParam String orderStatus,
                                     @RequestParam(required = false) String courierName,
                                     @RequestParam(required = false) String courierCode,
                                     @RequestParam(required = false) String trackingNo,
                                     HttpSession session) {
        MemberVO biz = getBizMember(session);
        if (biz == null) return "LOGIN_REQUIRED";
        Long bizNo = bizStoreService.getBizNo(biz.getMemberId());
        boolean ok = bizStoreService.updateOrderStatus(id, bizNo, orderStatus, courierName, courierCode, trackingNo);
        return ok ? "OK" : "FAILED";
    }

    //지윤 26.07.22 추가: 취소신청 승인
    @PostMapping("/orders/{id}/cancel/approve")
    @ResponseBody
    public String approveOrderCancel(@PathVariable Long id, HttpSession session) {
        MemberVO biz = getBizMember(session);
        if (biz == null) return "LOGIN_REQUIRED";
        Long bizNo = bizStoreService.getBizNo(biz.getMemberId());
        String error = bizStoreService.approveOrderCancel(id, bizNo);
        return error == null ? "OK" : error;
    }

    //지윤 26.07.22 추가: 취소신청 반려
@PostMapping("/orders/{id}/cancel/reject")
@ResponseBody
public String rejectOrderCancel(@PathVariable Long id, HttpSession session) {
    MemberVO biz = getBizMember(session);
    if (biz == null) return "LOGIN_REQUIRED";
    Long bizNo = bizStoreService.getBizNo(biz.getMemberId());
    boolean ok = bizStoreService.rejectOrderCancel(id, bizNo);
    return ok ? "OK" : "FAILED";
}

//지윤 26.07.27 추가: 배송완료 수동 강제처리
//원칙적으로 "배송완료"는 스마트택배 API(level==6) 확인 시에만 자동으로 전환되고, 드롭다운에선 선택 불가하게 뺐음.
//단, 스마트택배 미지원 특수배송(퀵서비스/직접전달 등) 예외 케이스 대비용으로 별도 버튼+확인창을 통해서만 가능하게 함
//autoCompleteDeliveryIfDone 그대로 재사용: 이미 DONE이면 스킵되는 가드도 동일하게 적용됨
@PostMapping("/orders/{id}/force-complete")
@ResponseBody
public String forceCompleteDelivery(@PathVariable Long id, HttpSession session) {
    MemberVO biz = getBizMember(session);
    if (biz == null) return "LOGIN_REQUIRED";
    Long bizNo = bizStoreService.getBizNo(biz.getMemberId());
    boolean ok = bizStoreService.autoCompleteDeliveryIfDone(id, bizNo);
    return ok ? "OK" : "FAILED";
}
    
    @GetMapping("/delivery")
    public String storeDelivery(@RequestParam(required = false) String carrier,
                                 @RequestParam(required = false) String statusCd,
                                 @RequestParam(required = false) String keyword,
                                 HttpSession session, Model model) {
        MemberVO biz = getBizMember(session);
        if (biz == null) return "redirect:/login";
        Long bizNo = bizStoreService.getBizNo(biz.getMemberId());

        model.addAttribute("deliveryList", bizStoreService.getDeliveryList(bizNo, carrier, statusCd, keyword));
        model.addAttribute("summary", bizStoreService.getDeliverySummary(bizNo));
        model.addAttribute("selectedCarrier", carrier);
        model.addAttribute("selectedStatusCd", statusCd);
        model.addAttribute("selectedKeyword", keyword);
        return "biz/store/delivery";
    }

    //지윤 26.07.24 추가: 택배사 전체목록 조회 (드롭다운 채우기용, AJAX)
//지윤 26.07.27 수정: BIZ 세션 체크 제거 - 택배사 목록은 민감정보 아니고 admin 화면(order-detail.jsp)에서도 같이 씀
@GetMapping("/delivery/companies")
@ResponseBody
public java.util.List<java.util.Map<String, String>> getCompanyList(HttpSession session) {
    return smartTrackerService.getCompanyList();
}

    //지윤 26.07.24 추가: 실시간 배송조회 (AJAX, 원본 JSON 그대로 화면에 넘김)
//지윤 26.07.27 수정: orderId 추가 - 조회 결과 level==6(배송완료)이면 그 시점에 주문상태 자동 DONE 처리
//(스마트택배 무료플랜 월 100건 제한이라 별도 스케줄러 폴링은 안 함, 사람이 조회 버튼 누르는 시점에만 동기화)
@GetMapping("/delivery/track")
@ResponseBody
public String trackDelivery(@RequestParam Long orderId, @RequestParam String courierCode,
                             @RequestParam String trackingNo, HttpSession session) {
    MemberVO biz = getBizMember(session);
    if (biz == null) return "{\"status\":false,\"msg\":\"로그인이 필요합니다.\"}";

    String json = smartTrackerService.getTrackingInfo(courierCode, trackingNo);
try {
    Long bizNo = bizStoreService.getBizNo(biz.getMemberId());
    com.fasterxml.jackson.databind.JsonNode node = new ObjectMapper().readTree(json);
    int level = node.path("level").asInt(-1);
    //지윤 26.07.28 수정: level==6(완료)일 때만 반응하던 것 -> level 2~5(이미 이동중)일 때도 반응하도록 확장
    //PAID/READY에 머물러있는 주문이면 SHIPPING으로 자동승격 (이미 SHIPPING 이상이면 내부에서 자동 스킵)
    if (level == 6) {
        bizStoreService.autoCompleteDeliveryIfDone(orderId, bizNo);
    } else if (level >= 2) {
        bizStoreService.autoElevateToShippingIfNeeded(orderId, bizNo);
    }
} catch (Exception e) {
    //파싱 실패해도 배송조회 결과 자체는 그대로 반환하고, 자동 상태갱신만 스킵
}
return json;
}
    

    //지윤 26.07.20 추가: 송장 일괄등록 (텍스트 여러 줄 파싱)
    @PostMapping("/delivery/bulk")
    @ResponseBody
    public java.util.Map<String, Object> bulkDelivery(@RequestParam String bulkText, HttpSession session) {
        MemberVO biz = getBizMember(session);
        if (biz == null) return java.util.Map.of("error", "LOGIN_REQUIRED");
        Long bizNo = bizStoreService.getBizNo(biz.getMemberId());
        return bizStoreService.bulkRegisterDelivery(bizNo, bulkText);
    }

    //지윤 26.07.20 수정: 목업 -> 실데이터 연동. 리뷰 목록 조회해서 JS에서 쓸 JSON으로 변환
    @GetMapping("/reviews")
    public String storeReviews(HttpSession session, Model model) throws Exception {
        MemberVO biz = getBizMember(session);
        if (biz == null) return "redirect:/login";
        Long bizNo = bizStoreService.getBizNo(biz.getMemberId());

        List<BizReviewVO> reviewList = bizStoreService.getBizReviewList(bizNo);
        java.text.SimpleDateFormat df = new java.text.SimpleDateFormat("yyyy-MM-dd");
        List<java.util.Map<String, Object>> rows = new ArrayList<>();
        for (BizReviewVO r : reviewList) {
            java.util.Map<String, Object> row = new java.util.LinkedHashMap<>();
            row.put("id", r.getReviewId());
            row.put("author", (r.getNickname() != null && !r.getNickname().isBlank()) ? r.getNickname() : "회원");
            row.put("date", r.getRegDate() != null ? df.format(r.getRegDate()) : "");
            row.put("rating", r.getRating() != null ? r.getRating() : 0);
            row.put("product", r.getProductName());
            row.put("thumbnail", r.getThumbnailUrl()); //지윤 26.07.22 추가: 상품 썸네일
            //지윤 26.07.22 복원: 실제 구매 옵션 (색상/사이즈)
            String optText = "";
            if (r.getOptionSize() != null && !r.getOptionSize().isBlank()) {
                optText = (r.getOptionColor() != null && !r.getOptionColor().isBlank() && !"기본".equals(r.getOptionColor()))
                        ? r.getOptionColor() + " / " + r.getOptionSize() : r.getOptionSize();
            }
            row.put("option", optText);
            row.put("content", r.getContent() != null ? r.getContent() : "");
            row.put("reply", r.getBizReply());
            row.put("deleteRequested", "PENDING".equals(r.getReportStatus())); //지윤 26.07.20 추가: 삭제요청 대기중이면 true
            //지윤 26.07.22 추가: 리뷰가 남아있는데 요청상태가 DONE이면 = 반려된 것 (승인됐으면 리뷰 자체가 삭제돼서 여기 조회조차 안 됨)
            row.put("deleteRejected", "DONE".equals(r.getReportStatus()));
            row.put("reportCount", r.getReportCount() != null ? r.getReportCount() : 0); //지윤 26.07.21 추가: 유저 신고 건수
            row.put("reporterNames", r.getReporterNames());                              //지윤 26.07.21 추가: 신고자 닉네임 목록
            rows.add(row);
        }
        model.addAttribute("reviewListJson", objectMapper.writeValueAsString(rows));
        return "biz/store/reviews";
    }

    //지윤 26.07.20 추가: 리뷰 답글 작성/수정 (TB_REVIEW.BIZ_REPLY)
    @PostMapping("/reviews/reply")
    public String saveReviewReply(@RequestParam("reviewId") Long reviewId,
                                   @RequestParam("bizReply") String bizReply,
                                   HttpSession session, RedirectAttributes rttr) {
        MemberVO biz = getBizMember(session);
        if (biz == null) return "redirect:/login";
        Long bizNo = bizStoreService.getBizNo(biz.getMemberId());
        boolean ok = bizStoreService.saveReviewBizReply(bizNo, reviewId, bizReply);
        rttr.addFlashAttribute(ok ? "msg" : "errorMsg", ok ? "답글이 저장되었습니다." : "본인 상품의 리뷰가 아닙니다.");
        return "redirect:/biz/store/reviews";
    }

    //지윤 26.07.20 추가: 리뷰 삭제요청 - 즉시 삭제 X, TB_REVIEW_REPORT에 PENDING 등록만 (관리자 승인 후 실제 삭제됨)
    @PostMapping("/reviews/delete-request")
    public String requestReviewDelete(@RequestParam("reviewId") Long reviewId,
                                       @RequestParam(value = "reason", required = false) String reason,
                                       HttpSession session, RedirectAttributes rttr) {
        MemberVO biz = getBizMember(session);
        if (biz == null) return "redirect:/login";
        Long bizNo = bizStoreService.getBizNo(biz.getMemberId());
        try {
            bizStoreService.requestReviewDelete(bizNo, reviewId, reason);
            rttr.addFlashAttribute("msg", "삭제 요청이 접수되었습니다. 관리자 승인 후 삭제됩니다.");
        } catch (IllegalArgumentException | IllegalStateException e) {
            rttr.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/biz/store/reviews";
    }

    //지윤 26.07.21 추가: Q&A관리 목록 (미답변 우선 정렬)
    @GetMapping("/qna")
    public String storeQna(HttpSession session, Model model) {
        MemberVO biz = getBizMember(session);
        if (biz == null) return "redirect:/login";
        Long bizNo = bizStoreService.getBizNo(biz.getMemberId());

        model.addAttribute("qnaList", bizStoreService.getBizQnaList(bizNo));
        return "biz/store/qna";
    }

    //지윤 26.07.21 추가: Q&A 답변 작성/수정
    @PostMapping("/qna/answer")
    public String saveQnaAnswer(@RequestParam("qnaId") Long qnaId,
                                 @RequestParam("answer") String answer,
                                 HttpSession session, RedirectAttributes rttr) {
        MemberVO biz = getBizMember(session);
        if (biz == null) return "redirect:/login";
        Long bizNo = bizStoreService.getBizNo(biz.getMemberId());
        boolean ok = bizStoreService.saveQnaAnswer(bizNo, qnaId, answer);
        rttr.addFlashAttribute(ok ? "msg" : "errorMsg", ok ? "답변이 등록되었습니다." : "본인 상품의 문의가 아닙니다.");
        return "redirect:/biz/store/qna";
    }

    /* 사업자(쇼핑) 정산관리 — 2026/08/05 장우철 S9 2-1 요약 / 2-2 목록 / 2-3·2-4 상세 */
    @GetMapping("/settlement")
    public String storeSettlement(HttpSession session, Model model,
                                  @RequestParam(value = "month", required = false, defaultValue = "all") String month,
                                  @RequestParam(value = "status", required = false, defaultValue = "all") String status) {
        MemberVO biz = getBizMember(session);
        if (biz == null) {
            return "redirect:/login";
        }

        Long bizNo = bizStoreService.getBizNo(biz.getMemberId());
        if (bizNo == null) {
            return "redirect:/mypage/biz";
        }

        StoreSettlementSummaryVO summary = storeSettlementService.getStoreSettlementSummary(bizNo);
        List<StoreSettlementVO> settlements = storeSettlementService.getStoreSettlementList(bizNo, month, status);
        List<String> settleMonths = storeSettlementService.getStoreSettlementMonths(bizNo);
        List<BizProductVO> productList = storeSettlementService.getProductsForSettlement(bizNo);

        model.addAttribute("summary", summary);
        model.addAttribute("settlements", settlements);
        model.addAttribute("settleMonths", settleMonths);
        model.addAttribute("filterMonth", month);
        model.addAttribute("filterStatus", status);
        model.addAttribute("productList", productList);
        //2026/08/06 장우철 — 정산계좌 모달용
        com.petcare.petcare.biz.store.vo.BizInfoVO settleAcc = bizStoreService.getSettleAccount(bizNo);
        model.addAttribute("settleAccountInfo",
                settleAcc != null ? settleAcc : new com.petcare.petcare.biz.store.vo.BizInfoVO());
        return "biz/store/settlement";
    }

    /**
     * 2026/08/05 장우철 — S9 2-3 정산 상세 ITEM JSON
     * GET /biz/store/settlement/items?settleId=
     */
    @GetMapping("/settlement/items")
    @ResponseBody
    public Map<String, Object> storeSettlementItems(HttpSession session,
                                                    @RequestParam("settleId") Long settleId) {
        Map<String, Object> result = new HashMap<>();
        MemberVO biz = getBizMember(session);
        if (biz == null) {
            result.put("ok", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }

        Long bizNo = bizStoreService.getBizNo(biz.getMemberId());
        if (bizNo == null) {
            result.put("ok", false);
            result.put("message", "쇼핑 사업자 정보가 없습니다.");
            return result;
        }

        List<StoreSettlementItemVO> items =
                storeSettlementService.getStoreSettlementItems(bizNo, settleId);
        result.put("ok", true);
        result.put("items", items);
        return result;
    }

    /**
     * 2026/08/06 장우철 — 정산 계좌 변경
     * POST /biz/store/settlement/account
     * (계좌인증은 /mypage/biz/account/verify 재사용 후 여기로 저장)
     */
    @PostMapping("/settlement/account")
    @ResponseBody
    public Map<String, Object> updateSettleAccount(HttpSession session,
                                                   @RequestParam String settleBank,
                                                   @RequestParam String settleBankCode,
                                                   @RequestParam String settleAccount,
                                                   @RequestParam String settleHolder,
                                                   @RequestParam(required = false) String settleVerifyYn) {
        Map<String, Object> result = new HashMap<>();
        MemberVO biz = getBizMember(session);
        if (biz == null) {
            result.put("ok", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }
        Long bizNo = bizStoreService.getBizNo(biz.getMemberId());
        if (bizNo == null) {
            result.put("ok", false);
            result.put("message", "쇼핑 사업자 정보가 없습니다.");
            return result;
        }
        if (!"Y".equals(settleVerifyYn)) {
            result.put("ok", false);
            result.put("message", "계좌 인증을 완료한 뒤 저장해 주세요.");
            return result;
        }
        boolean ok = bizStoreService.updateSettleAccount(bizNo, settleBank, settleBankCode, settleAccount, settleHolder);
        result.put("ok", ok);
        result.put("message", ok ? "정산 계좌가 저장되었습니다." : "정산 계좌 저장에 실패했습니다.");
        return result;
    }

    /**
     * 2026/08/05 장우철 — S10 중간정산 요청
     * POST /biz/store/settlement/request
     */
    @PostMapping("/settlement/request")
    @ResponseBody
    public Map<String, Object> storeSettlementRequest(HttpSession session,
                                                      @RequestBody Map<String, Object> body) {
        Map<String, Object> result = new HashMap<>();
        MemberVO biz = getBizMember(session);
        if (biz == null) {
            result.put("ok", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }

        Long bizNo = bizStoreService.getBizNo(biz.getMemberId());
        if (bizNo == null) {
            result.put("ok", false);
            result.put("message", "쇼핑 사업자 정보가 없습니다.");
            return result;
        }

        try {
            String scope = body.get("requestScope") == null
                    ? null : String.valueOf(body.get("requestScope"));
            Long productId = null;
            if (body.get("productId") != null && !String.valueOf(body.get("productId")).isBlank()) {
                productId = Long.parseLong(String.valueOf(body.get("productId")));
            }
            String endStr = body.get("targetEnd") == null
                    ? null : String.valueOf(body.get("targetEnd"));
            if (endStr == null || endStr.isBlank()) {
                throw new IllegalArgumentException("대상 종료일(컷오프)을 입력하세요.");
            }
            java.util.Date targetEnd = java.sql.Date.valueOf(endStr.substring(0, 10));
            String memo = body.get("requestMemo") == null
                    ? null : String.valueOf(body.get("requestMemo"));

            StoreSettlementRequestVO saved = storeSettlementService.createMidSettlementRequest(
                    bizNo, scope, productId, targetEnd, memo);

            result.put("ok", true);
            result.put("requestId", saved.getRequestId());
            result.put("targetStart", saved.getTargetStart());
            result.put("targetEnd", saved.getTargetEnd());
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

    //지윤 26.07.23 수정: 목업 -> 실데이터 연동
    @GetMapping("/info")
    public String storeInfo(HttpSession session, Model model) {
        MemberVO biz = getBizMember(session);
        if (biz == null) return "redirect:/login";
        Long bizNo = bizStoreService.getBizNo(biz.getMemberId());

        model.addAttribute("info", bizStoreService.getBusinessInfo(bizNo));
        return "biz/store/info";
    }

    //지윤 26.07.23 추가: 사업자 정보 저장
    @PostMapping("/info")
    public String saveInfo(@RequestParam String shopName, @RequestParam String ceoName, @RequestParam String bizRegNo,
                            @RequestParam String addr,
                            @RequestParam(required = false) String addrDetail, @RequestParam String phone,
                            @RequestParam(required = false) MultipartFile certFile,
                            HttpSession session, RedirectAttributes rttr) throws Exception {
        MemberVO biz = getBizMember(session);
        if (biz == null) return "redirect:/login";
        Long bizNo = bizStoreService.getBizNo(biz.getMemberId());

        com.petcare.petcare.biz.store.vo.BizInfoVO existing = bizStoreService.getBusinessInfo(bizNo);

        com.petcare.petcare.biz.store.vo.BizInfoVO info = new com.petcare.petcare.biz.store.vo.BizInfoVO();
        info.setShopName(shopName);
        info.setCeoName(ceoName);
        info.setBizRegNo(bizRegNo);
        info.setBizType(existing.getBizType());
        info.setAddr(addr);
        info.setAddrDetail(addrDetail);
        info.setPhone(phone);

        bizStoreService.updateBusinessInfo(bizNo, info, certFile);
        rttr.addFlashAttribute("msg", "사업자 정보가 저장되었습니다.");
        return "redirect:/biz/store/info";
    }
    
    //지윤 26.07.15 상품 등록 모달 제출 처리 (옵션 여러 개 + 이미지 1장)
    @PostMapping("/products")
    public String registerProduct(@RequestParam String productName,
                                   @RequestParam Long categoryId,
                                   @RequestParam Integer price,
                                   @RequestParam Integer salePrice,
                                   @RequestParam(required = false) String brandName,
                                   @RequestParam(required = false) String description,
                                   @RequestParam String statusCd,
                                   @RequestParam(required = false) String tags,
                                   @RequestParam(required = false) String[] optionColor,
                                   @RequestParam String[] optionSize,
                                   @RequestParam Integer[] addPrice,
                                   @RequestParam Integer[] stockQty,
                                   @RequestParam(required = false) MultipartFile image,
                                   HttpSession session) throws Exception {
        MemberVO biz = getBizMember(session);
        if (biz == null) return "redirect:/login";
        Long bizNo = bizStoreService.getBizNo(biz.getMemberId());

        BizProductVO product = new BizProductVO();
        product.setProductName(productName);
        product.setBizNo(bizNo);
        product.setCategoryId(categoryId);
        product.setPrice(price);
        product.setSalePrice(salePrice);
        product.setBrandName(brandName);
        product.setDescription(description);
        product.setStatusCd(statusCd);
        product.setTags(tags);

        bizStoreService.addProduct(product, buildOptions(optionColor, optionSize, addPrice, stockQty), image);
        return "redirect:/biz/store/products";
    }

    //지윤 26.07.15 수정 모달 프리필용 - 상품 1건 + 옵션 리스트 JSON 반환
    @GetMapping("/products/{id}")
    @ResponseBody
    public BizProductVO getProductJson(@PathVariable Long id, HttpSession session) {
        MemberVO biz = getBizMember(session);
        if (biz == null) return null;
        Long bizNo = bizStoreService.getBizNo(biz.getMemberId());
        return bizStoreService.getProductDetail(id, bizNo);
    }

    //지윤 26.07.15 상품 수정 모달 제출 처리
    @PostMapping("/products/{id}")
    public String updateProductSubmit(@PathVariable Long id,
                                       @RequestParam String productName,
                                       @RequestParam Long categoryId,
                                       @RequestParam Integer price,
                                       @RequestParam Integer salePrice,
                                       @RequestParam(required = false) String brandName,
                                       @RequestParam(required = false) String description,
                                       @RequestParam String statusCd,
                                       @RequestParam(required = false) String tags,
                                       @RequestParam(required = false) String[] optionId,
                                       @RequestParam(required = false) String[] optionColor,
                                       @RequestParam String[] optionSize,
                                       @RequestParam Integer[] addPrice,
                                       @RequestParam Integer[] stockQty,
                                       @RequestParam(required = false) MultipartFile image,
                                       HttpSession session) throws Exception {
        MemberVO biz = getBizMember(session);
        if (biz == null) return "redirect:/login";
        Long bizNo = bizStoreService.getBizNo(biz.getMemberId());

        BizProductVO product = new BizProductVO();
        product.setProductId(id);
        product.setBizNo(bizNo);
        product.setProductName(productName);
        product.setCategoryId(categoryId);
        product.setPrice(price);
        product.setSalePrice(salePrice);
        product.setBrandName(brandName);
        product.setDescription(description);
        product.setStatusCd(statusCd);
        product.setTags(tags);

        bizStoreService.updateProduct(product, buildOptions(optionId, optionColor, optionSize, addPrice, stockQty), image);
        return "redirect:/biz/store/products";
    }

    //지윤 26.07.15 폼 배열(옵션당 1줄씩)을 OptionVO 리스트로 변환
    //지윤 26.07.15 수정: 배열 길이가 서로 안 맞아도(브라우저 재전송 등) 에러 안 나게 방어 코드 추가
    //지윤 26.07.24 수정: optionId 오버로드 추가 (수정화면에서 어느 옵션인지 정확히 구분하기 위함)
    private List<OptionVO> buildOptions(String[] optionColor, String[] optionSize, Integer[] addPrice, Integer[] stockQty) {
        return buildOptions(null, optionColor, optionSize, addPrice, stockQty);
    }

    private List<OptionVO> buildOptions(String[] optionId, String[] optionColor, String[] optionSize, Integer[] addPrice, Integer[] stockQty) {
        List<OptionVO> options = new ArrayList<>();
        if (optionSize == null) return options;
        for (int i = 0; i < optionSize.length; i++) {
            OptionVO opt = new OptionVO();
            // 2026/08/13 장우철 — 수정 시 신규 옵션 hidden optionId="" 가 Long[] 바인딩에서 400 나던 것 방지
            opt.setOptionId(parseLongOrNull(optionId, i));
            opt.setOptionColor(optionColor != null && optionColor.length > i ? optionColor[i] : null);
            opt.setOptionSize(optionSize[i]);

            //HYJ 26.08.13 null 체크 추가
            opt.setAddPrice(addPrice != null && addPrice.length > i && addPrice[i] != null ? addPrice[i] : 0);
            opt.setStockQty(stockQty != null && stockQty.length > i && stockQty[i] != null ? stockQty[i] : 0);
            options.add(opt);
        }
        return options;
    }

    private Long parseLongOrNull(String[] arr, int i) {
        if (arr == null || arr.length <= i || arr[i] == null || arr[i].isBlank()) return null;
        try {
            return Long.valueOf(arr[i].trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    // ─────────────────────────────────────────────
// 2026-08-06 박유정 — 쇼핑 배너 (stay/hospital 공용 BizStayService)
// ─────────────────────────────────────────────
@GetMapping({"/banner", "/banner/"})
public String bannerList(HttpSession session, Model model) {
    MemberVO member = getBizMember(session);
    if (member == null) return "redirect:/login";

    Long bizNo = bizStoreService.getBizNo(member.getMemberId());
    if (bizNo == null) {
        model.addAttribute("errorMsg", "사업자 정보를 찾을 수 없습니다.");
        model.addAttribute("bannerList", java.util.Collections.emptyList());
        model.addAttribute("bizPage", "banner");
        return "biz/store/banner";
    }
    model.addAttribute("bannerList", bizStayService.getBannerList(bizNo));
    model.addAttribute("bizPage", "banner");
    return "biz/store/banner";
}

@GetMapping("/banner/form")
public String bannerForm(HttpSession session, Model model) {
    if (getBizMember(session) == null) return "redirect:/login";
    model.addAttribute("bizPage", "banner");
    return "biz/store/banner-form";
}

@PostMapping("/banner")
public String bannerSubmit(@RequestParam String title,
                           @RequestParam(required = false) String linkUrl,
                           @RequestParam String positionCd,
                           @RequestParam String startDate,
                           @RequestParam String endDate,
                           @RequestParam(required = false) MultipartFile bannerImage,
                           HttpSession session,
                           RedirectAttributes rttr) {
    MemberVO member = getBizMember(session);
    if (member == null) return "redirect:/login";
    try {
        Long bizNo = bizStoreService.getBizNo(member.getMemberId());
        if (bizNo == null) {
            rttr.addFlashAttribute("errorMsg", "사업자 정보를 찾을 수 없습니다.");
            return "redirect:/biz/store/banner";
        }
        MainBannerVO banner = new MainBannerVO();
        banner.setBizNo(bizNo);
        banner.setTitle(title);
        banner.setLinkUrl(linkUrl);
        banner.setPositionCd(positionCd);
        banner.setStartDate(startDate);
        banner.setEndDate(endDate);
        banner.setStatusCd("PENDING");

        bizStayService.applyBanner(banner, bannerImage);
        rttr.addFlashAttribute("msg", "배너 신청이 완료되었습니다. 관리자 승인 후 노출됩니다.");
    } catch (IllegalArgumentException e) {
        rttr.addFlashAttribute("errorMsg", e.getMessage());
    } catch (Exception e) {
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage() : "";
        if (msg.contains("ORA-00001")) {
            rttr.addFlashAttribute("errorMsg",
                    "배너 ID가 중복되었습니다. DB에서 SEQ_TB_BANNER 시퀀스를 MAX(BANNER_ID)+1 로 맞춘 뒤 다시 시도하세요.");
        } else if (msg.contains("ORA-02289")) {
            rttr.addFlashAttribute("errorMsg",
                    "SEQ_TB_BANNER 시퀀스가 없습니다. DB에 시퀀스를 생성한 뒤 다시 시도하세요.");
        } else {
            rttr.addFlashAttribute("errorMsg", "배너 신청 중 오류가 발생했습니다. (서버 콘솔 ORA- 메시지 확인)");
        }
    }
    return "redirect:/biz/store/banner";
}

    /*사업자(샵) 계약관리*/
    @GetMapping("/contract")
    public String storeContract(HttpSession session) {
        if (getBizMember(session) == null)
            return "redirect:/login";
        return "biz/store/contract";
    }

    // ─────────────────────────────────────────────
// 지윤 26.08.06: 쇼핑몰 사업자 쿠폰 관리
// ─────────────────────────────────────────────

/**
 * 쇼핑몰 사업자 쿠폰 목록
 */
@GetMapping({"/coupon", "/coupon/"})
public String couponList(
        HttpSession session,
        Model model
) {
    MemberVO biz = getBizMember(session);

    if (biz == null) {
        return "redirect:/login";
    }

    Long bizNo = bizStoreService.getBizNo(biz.getMemberId());

    if (bizNo == null) {
        model.addAttribute(
                "errorMsg",
                "사업자 정보를 찾을 수 없습니다."
        );

        model.addAttribute(
                "couponList",
                java.util.Collections.emptyList()
        );

        return "biz/store/coupon";
    }

    model.addAttribute(
            "couponList",
            bizStoreService.getCouponList(bizNo)
    );

    // 지윤 26.08.10 추가: 기간만료 배지 판단용
    model.addAttribute(
            "today",
            LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"))
    );

    return "biz/store/coupon";
}

/**
 * 쿠폰 승인 신청
 */
@PostMapping("/coupon/apply")
public String applyCoupon(
        com.petcare.petcare.biz.vo.BizCouponVO vo,
        HttpSession session,
        RedirectAttributes rttr
) {
    MemberVO biz = getBizMember(session);

    if (biz == null) {
        return "redirect:/login";
    }

    try {
        Long bizNo = bizStoreService.getBizNo(biz.getMemberId());

        if (bizNo == null) {
            rttr.addFlashAttribute(
                    "errorMsg",
                    "사업자 정보를 찾을 수 없습니다."
            );

            return "redirect:/biz/store/coupon";
        }

        bizStoreService.applyCoupon(bizNo, vo);

        rttr.addFlashAttribute(
                "msg",
                "쿠폰 승인 신청이 완료되었습니다."
        );

    } catch (Exception e) {
        e.printStackTrace();

        rttr.addFlashAttribute(
                "errorMsg",
                "쿠폰 신청 중 오류가 발생했습니다."
        );
    }

    return "redirect:/biz/store/coupon";
}

/**
 * 승인 대기 쿠폰 수정
 */
@PostMapping("/coupon/update")
public String updateCoupon(
        com.petcare.petcare.biz.vo.BizCouponVO vo,
        HttpSession session,
        RedirectAttributes rttr
) {
    MemberVO biz = getBizMember(session);

    if (biz == null) {
        return "redirect:/login";
    }

    try {
        Long bizNo = bizStoreService.getBizNo(biz.getMemberId());

        if (bizNo == null) {
            rttr.addFlashAttribute(
                    "errorMsg",
                    "사업자 정보를 찾을 수 없습니다."
            );

            return "redirect:/biz/store/coupon";
        }

        bizStoreService.updateCoupon(bizNo, vo);

        rttr.addFlashAttribute(
                "msg",
                "쿠폰 정보가 수정되었습니다."
        );

    } catch (IllegalStateException e) {

        if ("NOT_PENDING".equals(e.getMessage())) {
            rttr.addFlashAttribute(
                    "errorMsg",
                    "승인 대기 상태의 쿠폰만 수정할 수 있습니다."
            );

        } else {
            rttr.addFlashAttribute(
                    "errorMsg",
                    "수정 권한이 없습니다."
            );
        }

    } catch (Exception e) {
        rttr.addFlashAttribute(
                "errorMsg",
                "수정 중 오류가 발생했습니다."
        );
    }

    return "redirect:/biz/store/coupon";
}

/**
 * 승인 대기 쿠폰 삭제
 */
@PostMapping("/coupon/delete")
public String deleteCoupon(
        @RequestParam Long couponId,
        HttpSession session,
        RedirectAttributes rttr
) {
    MemberVO biz = getBizMember(session);

    if (biz == null) {
        return "redirect:/login";
    }

    try {
        Long bizNo = bizStoreService.getBizNo(biz.getMemberId());

        if (bizNo == null) {
            rttr.addFlashAttribute(
                    "errorMsg",
                    "사업자 정보를 찾을 수 없습니다."
            );

            return "redirect:/biz/store/coupon";
        }

        bizStoreService.deleteCoupon(bizNo, couponId);

        rttr.addFlashAttribute(
                "msg",
                "쿠폰 신청이 삭제되었습니다."
        );

    } catch (IllegalStateException e) {

        if ("NOT_PENDING".equals(e.getMessage())) {
            rttr.addFlashAttribute(
                    "errorMsg",
                    "승인 대기 상태의 쿠폰만 삭제할 수 있습니다."
            );

        } else {
            rttr.addFlashAttribute(
                    "errorMsg",
                    "삭제 권한이 없습니다."
            );
        }

    } catch (Exception e) {
        rttr.addFlashAttribute(
                "errorMsg",
                "삭제 중 오류가 발생했습니다."
        );
    }

    return "redirect:/biz/store/coupon";
}

/**
 * 지윤 26.08.06
 * 쇼핑몰 사업자 쿠폰 조기 마감
 *
 * 관리자 재승인 없이 사업자가 직접 마감한다.
 * 기존에 발급된 회원 쿠폰은 변경하지 않는다.
 */
@PostMapping("/coupon/close")
public String closeCoupon(
        @RequestParam Long couponId,
        HttpSession session,
        RedirectAttributes rttr
) {
    MemberVO biz = getBizMember(session);

    if (biz == null) {
        return "redirect:/login";
    }

    try {
        Long bizNo = bizStoreService.getBizNo(biz.getMemberId());

        if (bizNo == null) {
            rttr.addFlashAttribute(
                    "errorMsg",
                    "사업자 정보를 찾을 수 없습니다."
            );

            return "redirect:/biz/store/coupon";
        }

        bizStoreService.closeCoupon(bizNo, couponId);

        rttr.addFlashAttribute(
                "msg",
                "쿠폰이 조기 마감되었습니다."
        );

    } catch (IllegalStateException e) {

        if ("NOT_OWNER".equals(e.getMessage())) {
            rttr.addFlashAttribute(
                    "errorMsg",
                    "본인이 등록한 쿠폰만 마감할 수 있습니다."
            );

        } else if ("NOT_APPROVED".equals(e.getMessage())) {
            rttr.addFlashAttribute(
                    "errorMsg",
                    "승인된 쿠폰만 조기 마감할 수 있습니다."
            );

        } else if ("NOT_ACTIVE".equals(e.getMessage())) {
            rttr.addFlashAttribute(
                    "errorMsg",
                    "현재 게시 중인 쿠폰만 조기 마감할 수 있습니다."
            );

        } else {
            rttr.addFlashAttribute(
                    "errorMsg",
                    "쿠폰 조기 마감에 실패했습니다."
            );
        }

    } catch (Exception e) {
        rttr.addFlashAttribute(
                "errorMsg",
                "쿠폰 조기 마감 중 오류가 발생했습니다."
        );
    }

    return "redirect:/biz/store/coupon";
}

// 2026-08-13 박유정 — 빈 숫자칸("") → null (Integer 바인딩 오류 방지)
@InitBinder
public void initBinder(WebDataBinder binder) {
    binder.registerCustomEditor(Integer.class, new CustomNumberEditor(Integer.class, true));
}

}