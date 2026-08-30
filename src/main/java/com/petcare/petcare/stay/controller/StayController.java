/**
 * 역할: 펫호텔 URL 처리 → Service 호출 → JSP 반환
 *
 * 연결
 * - Service: StayStayService
 *
 * SQL·비즈니스 로직은 넣지 말 것 → Service로 위임
 * return 경로는 담당 JSP와 동일하게 맞출 것
 */

package com.petcare.petcare.stay.controller;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.petcare.petcare.common.billing.service.BillingCardService;
import com.petcare.petcare.common.billing.vo.BillingApproveResultVO;
import com.petcare.petcare.common.billing.vo.BillingCardVO;
import com.petcare.petcare.common.external.service.KakaoMapService;
import com.petcare.petcare.common.external.service.TossBillingService;
import com.petcare.petcare.file.service.FileService;
import com.petcare.petcare.file.vo.FileVO;
import com.petcare.petcare.stay.vo.ReservationVO;
import com.petcare.petcare.member.vo.MemberVO;
import com.petcare.petcare.stay.service.StayServiceImpl;
import com.petcare.petcare.stay.vo.StayVO;
import com.petcare.petcare.store.vo.CouponVO;
import com.petcare.petcare.coupon.mapper.CouponMapper;

import jakarta.servlet.http.HttpSession;


@Controller("stayController")
@RequestMapping("/stay")
public class StayController {

    // 2026/08/10 장우철 — 결제 실패 원인 로그용
    private static final Logger log = LoggerFactory.getLogger(StayController.class);

    @Value("${toss.client-key}")
    private String tossApiKey;
    
    @Autowired
    private KakaoMapService kakaoMapService;
    @Autowired
    private StayServiceImpl stayService;
    @Autowired
    private FileService fileService;

    // 2026/07/27 장우철 — 등록카드(빌링) 결제
    @Autowired
    private BillingCardService billingCardService;
    @Autowired
    private TossBillingService tossBillingService;
    // 지윤 26.08.07: 등록카드 결제 시 쿠폰 할인 미리계산용
    @Autowired
    private CouponMapper couponMapper;

    @GetMapping({"", "/"})
    public String list(@ModelAttribute("search") StayVO searchVO, Model model) throws Exception {
        //List<StayVO> stayList = stayService.getStayList();
        List<StayVO> stayList = stayService.getStayListBySearch(searchVO);
        kakaoMapService.addMapAttributes(model, stayList);
        
        model.addAttribute("stayList", stayList);
        model.addAttribute("skipAutoMarkers", "true");
        return "stay/list";
    }

    @GetMapping("/detail")
    public String detail(@RequestParam(defaultValue = "1") Long id, Model model) throws Exception {
        StayVO stay = stayService.getStayById(id);
        List<FileVO> imgList = fileService.getFileList("STAY", id);
        
        // 지도 표시 (단일마커 — 숙소 1곳)
        if (stay != null && stay.getLat() != null) {
            java.util.List<StayVO> singleList = new java.util.ArrayList<>();
            singleList.add(stay);
            kakaoMapService.addMapAttributes(model, singleList);
        }

        model.addAttribute("stay", stay);
        model.addAttribute("imgList", imgList);
        model.addAttribute("reviewList", stayService.getStayReviews(id));
        
        return "stay/detail";
    }

    @GetMapping("/reserve")
    public String reserve(@RequestParam("id") Long id,
                          @RequestParam(value = "roomId", required = false) Long roomId,
                          HttpSession session, 
                          Model model) throws Exception {

        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null) return "redirect:/login";

        StayVO stay = stayService.getStayById(id);
        if (stay == null) return "redirect:/stay";

        model.addAttribute("stay", stay);
        model.addAttribute("roomId", roomId);
        model.addAttribute("petList", stayService.getPetList(member.getMemberNo()));
        return "stay/reserve";
    }

    // ── HYJ 26.07.20 가용성 체크 API (AJAX) ──
    @GetMapping("/checkAvailability")
    @ResponseBody
    public Map<String, Object> checkAvailability(@RequestParam("roomId") Long roomId,
                                                 @RequestParam("checkinDate") String checkinDate,
                                                 @RequestParam("checkoutDate") String checkoutDate) throws Exception {

        Map<String, Object> result = new HashMap<>();

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        Date ciDate = sdf.parse(checkinDate);
        Date coDate = sdf.parse(checkoutDate);

        boolean available = stayService.checkRoomAvailability(roomId, ciDate, coDate);
        result.put("available", available);

        if (!available) {
            result.put("message", "선택한 날짜에 이미 예약이 있습니다.");
        }
        return result;
    }

        
    // ── HYJ 26.07.20 예약 저장 → 결제 페이지로 이동──
    // 2026/08/11 장우철 — 다펫: petIds → 대표 petId + petCnt
    @PostMapping("/reserve")
    public String saveReserve(@ModelAttribute ReservationVO vo,
                              @RequestParam("stayId") Long stayId,
                              @RequestParam(value = "petIds", required = false) java.util.List<Long> petIds,
                              HttpSession session,
                              RedirectAttributes rttr) throws Exception {

        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null) return "redirect:/login";

        vo.setMemberNo(member.getMemberNo());
        vo.setTargetId(String.valueOf(stayId));

        if (petIds != null && !petIds.isEmpty()) {
            vo.setPetId(petIds.get(0));
            vo.setPetCnt(petIds.size());
        } else if (vo.getPetCnt() == null) {
            vo.setPetCnt(1);
        }

        try {
            
            //HYJ 26.07.23 결제 없이 예약버튼만 눌러도 예약처리됨 -> 수정필요
            //HYJ 26.07.28 예약후 15분 이내 결제 없을 경우 취소안내 후, 예약처리
            Long resvId = stayService.createStayReservation(vo);
            // 결제 페이지로 리다이렉트
            return "redirect:/stay/payment?resvId=" + resvId;
        } catch (RuntimeException e) {
            rttr.addFlashAttribute("errorMsg", e.getMessage());
            return "redirect:/stay/reserve?id=" + stayId;
        }
    }

    // ── HYJ 26.07.20 결제 페이지 ──
    @GetMapping("/payment")
    public String payment(@RequestParam("resvId") Long resvId,
                            HttpSession session,
                            Model model) throws Exception {

        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null) return "redirect:/login";

        ReservationVO reservation = stayService.getReservationById(resvId);
        if (reservation == null) return "redirect:/stay";

        // 본인 예약만 결제 가능
        if (!member.getMemberNo().equals(reservation.getMemberNo())) {
            return "redirect:/stay";
        }

        model.addAttribute("reservation", reservation);
        model.addAttribute("tossApiKey", tossApiKey);
        // 2026/07/27 장우철 — 결제 화면 보유포인트 = DB 실잔액 (세션 동기화)
        Long dbPoint = stayService.getMemberPointBalance(member.getMemberNo());
        long held = dbPoint != null ? dbPoint : 0L;
        member.setPointBalance(held);
        session.setAttribute("memberInfo", member);
        model.addAttribute("memberPoint", held);

        // 지윤 26.08.07: 이 숙소가 발급한, 회원이 사용 가능한 쿠폰 목록
        StayVO stay = stayService.getStayById(Long.valueOf(reservation.getTargetId()));
        Long stayBizNo = stay != null ? stay.getBizNo() : null;
        model.addAttribute("usableCoupons", stayService.getUsableCoupons(member.getMemberNo(), stayBizNo));

        return "stay/payment";
    }

    // ── HYJ 26.07.20 결제 성공 콜백 (Toss → 여기로 리다이렉트) ──
    @GetMapping("/payment/success")
    public String paymentSuccess(@RequestParam("orderId") String orderId,
                                    @RequestParam("paymentKey") String paymentKey,
                                    @RequestParam("amount") Long amount,
                                    HttpSession session,
                                    RedirectAttributes rttr) throws Exception {

        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null) return "redirect:/login";

        // orderId 형식: stay-{resvId}-{usedPoint}-{couponMemberCouponId}-{timestamp}
        // 지윤 26.08.07: couponMemberCouponId 추가 (4번째 조각). 기존 형식(4개 조각)도 하위호환 처리
        String[] parts = orderId.split("-");
        Long resvId = Long.parseLong(parts[1]);
        long usedPoint = parts.length >= 4 ? Long.parseLong(parts[2]) : 0;
        Long couponMemberCouponId = parts.length >= 5 ? Long.parseLong(parts[3]) : 0L;

        try {
            String kakaoToken = (String) session.getAttribute("kakaoAccessToken");
            // 2026/07/31 장우철 — amount 는 토스 위젯 실결제액(confirm 필수)
            stayService.confirmPayment(resvId, paymentKey, orderId, "CARD", kakaoToken,
                    member.getMemberNo(), usedPoint, amount, couponMemberCouponId);

            // 2026/07/27 장우철 — 세션 포인트 = DB 실잔액
            syncSessionPointBalance(session, member);

            return "redirect:/stay/complete?resvId=" + resvId;
        } catch (RuntimeException e) {
            // 2026/08/10 장우철 — redirect 시 model 은 유실되므로 flash + 로그로 원인 남김
            // printStackTrace 는 stderr 무단 출력·스택 노출이라 사용하지 않음 (log.error 로 충분)
            log.error("[Stay paymentSuccess] 결제 확정 실패 orderId={}, amount={}, message={}",
                    orderId, amount, e.getMessage(), e);
            rttr.addFlashAttribute("errorMsg", e.getMessage() != null ? e.getMessage() : "결제 확정에 실패했습니다.");
            return "redirect:/stay";
        }
    }

    /**
     * 2026/07/27 장우철 — 등록카드(빌링키) Ajax 결제
     * POST /stay/payment/billing-card
     */
    @PostMapping("/payment/billing-card")
    @ResponseBody
    public Map<String, Object> payWithBillingCard(
            @RequestParam Long billingCardId,
            @RequestParam Long resvId,
            @RequestParam(defaultValue = "0") long usedPoint,
            @RequestParam(defaultValue = "0") Long couponMemberCouponId,
            HttpSession session) {

        Map<String, Object> res = new HashMap<>();
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null || member.getMemberNo() == null) {
            res.put("ok", false);
            res.put("message", "로그인이 필요합니다.");
            return res;
        }

        ReservationVO reservation;
        try {
            reservation = stayService.getReservationById(resvId);
        } catch (Exception e) {
            res.put("ok", false);
            res.put("message", "예약 정보를 불러오지 못했습니다.");
            return res;
        }
        if (reservation == null || !member.getMemberNo().equals(reservation.getMemberNo())) {
            res.put("ok", false);
            res.put("message", "예약 정보를 확인할 수 없습니다.");
            return res;
        }

        BillingCardVO card = billingCardService.getCard(billingCardId);
        if (card == null || !"ACTIVE".equals(card.getStatusCd())
                || !"MEMBER".equals(card.getOwnerType())
                || !member.getMemberNo().equals(card.getOwnerNo())) {
            res.put("ok", false);
            res.put("message", "등록된 카드를 확인할 수 없습니다.");
            return res;
        }

        long total = reservation.getTotalAmount() != null ? reservation.getTotalAmount() : 0L;

        // 지윤 26.08.07: 등록카드 결제도 쿠폰 할인 반영 (실제 확정 검증은 confirmPayment에서 다시 함)
        // 여기선 청구 금액 산정용으로만 미리 계산
        long couponDiscountPreview = 0L;
        if (couponMemberCouponId != null && couponMemberCouponId > 0) {
            CouponVO couponPreview = couponMapper.selectMemberCouponForUse(couponMemberCouponId, member.getMemberNo());
            if (couponPreview != null) {
                if ("RATE".equals(couponPreview.getCouponType())) {
                    long rawDiscount = total * couponPreview.getDiscountValue() / 100;
                    // 지윤 26.08.11 수정: 최대할인금액 캡 적용 (실제 확정은 confirmPayment/StayServiceImpl에서 재검증)
                    Integer maxAmt = couponPreview.getMaxDiscountAmt();
                    couponDiscountPreview = (maxAmt != null && maxAmt > 0)
                            ? Math.min(rawDiscount, (long) maxAmt)
                            : rawDiscount;
                } else {
                    couponDiscountPreview = couponPreview.getDiscountValue();
                }
                if (couponDiscountPreview > total) couponDiscountPreview = total;
            }
        }
        long payableAfterCoupon = total - couponDiscountPreview;

        if (usedPoint < 0) usedPoint = 0;
        if (usedPoint > payableAfterCoupon) usedPoint = payableAfterCoupon;
        // 2026/07/27 장우철 — 보유 포인트 초과 사용 불가
        Long heldBal = stayService.getMemberPointBalance(member.getMemberNo());
        long held = heldBal != null ? Math.max(0L, heldBal) : 0L;
        if (usedPoint > held) usedPoint = held;
        int chargeAmount = (int) (payableAfterCoupon - usedPoint);
        if (chargeAmount <= 0) {
            res.put("ok", false);
            res.put("message", "결제 금액이 없습니다. 포인트 전액 결제를 이용해 주세요.");
            return res;
        }

        String tossOrderId = "stay-" + resvId + "-" + usedPoint + "-" + couponMemberCouponId + "-" + System.currentTimeMillis();
        String orderName = "펫케어 숙소 예약";
        if (reservation.getStayName() != null) {
            orderName = reservation.getStayName();
            if (reservation.getServiceName() != null) {
                orderName = orderName + " - " + reservation.getServiceName();
            }
            if (orderName.length() > 100) {
                orderName = orderName.substring(0, 100);
            }
        }

        StringBuilder err = new StringBuilder();
        BillingApproveResultVO approved = tossBillingService.approveBilling(
                card.getBillingKey(), card.getCustomerKey(), chargeAmount,
                tossOrderId, orderName, err);

        if (approved == null) {
            res.put("ok", false);
            res.put("message", err.length() > 0 ? err.toString() : "등록카드 결제에 실패했습니다.");
            return res;
        }

        try {
            String paymentKey = approved.getPaymentKey() != null
                    ? approved.getPaymentKey() : ("BILLING-" + tossOrderId);
                    String kakaoToken = (String) session.getAttribute("kakaoAccessToken");
                    stayService.confirmPayment(resvId, paymentKey, tossOrderId, "BILLING",
                            kakaoToken, member.getMemberNo(), usedPoint, (long) chargeAmount, couponMemberCouponId);

            // 2026/07/27 장우철 — 세션 포인트 = DB 실잔액
            syncSessionPointBalance(session, member);

            res.put("ok", true);
            res.put("redirectUrl", "/stay/complete?resvId=" + resvId);
            return res;
        } catch (Exception e) {
            res.put("ok", false);
            res.put("message", "결제는 승인됐으나 예약 확정 중 오류: " + e.getMessage());
            return res;
        }
    }

    // ── HYJ 26.07.21 전액 포인트 결제 (Toss 없이 직접 처리) ──
    @GetMapping("/payment/point-only")
    public String paymentPointOnly(@RequestParam("resvId") Long resvId,
                                    @RequestParam("usedPoint") Long usedPoint,
                                    @RequestParam(defaultValue = "0") Long couponMemberCouponId,
                                    HttpSession session,
                                    RedirectAttributes rttr) throws Exception {

        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null) return "redirect:/login";

        try {
            String kakaoToken = (String) session.getAttribute("kakaoAccessToken");
            stayService.confirmPayment(resvId, "POINT_ONLY", "point-" + resvId + "-" + System.currentTimeMillis(),
                    "POINT", kakaoToken, member.getMemberNo(), usedPoint, 0L, couponMemberCouponId);

            // 2026/07/27 장우철 — 세션 포인트 = DB 실잔액
            syncSessionPointBalance(session, member);

            return "redirect:/stay/complete?resvId=" + resvId;
        } catch (RuntimeException e) {
            rttr.addFlashAttribute("errorMsg", e.getMessage());
            return "redirect:/stay/payment?resvId=" + resvId;
        }
    }

    // ── HYJ 26.07.20 결제 실패 콜백 ──
    @GetMapping("/payment/fail")
    public String paymentFail(@RequestParam(required = false) String code,
                                @RequestParam(required = false) String message,
                                RedirectAttributes rttr) throws Exception {
        rttr.addFlashAttribute("errorMsg", "결제에 실패했습니다: " + message);
        return "redirect:/stay";
    }

    @GetMapping("/complete")
    public String complete(@RequestParam(value = "resvId", required = false) Long resvId,
                           Model model) throws Exception {
        if (resvId != null) {
            ReservationVO reservation = stayService.getReservationById(resvId);
            model.addAttribute("reservation", reservation);
        }
        return "stay/complete";
    }

    /**
     * 2026/07/27 장우철 — 결제 후 세션 포인트를 DB 실잔액과 맞춤
     */
    private void syncSessionPointBalance(HttpSession session, MemberVO member) {
        if (member == null || member.getMemberNo() == null) {
            return;
        }
        Long bal = stayService.getMemberPointBalance(member.getMemberNo());
        member.setPointBalance(bal != null ? bal : 0L);
        session.setAttribute("memberInfo", member);
    }
}
