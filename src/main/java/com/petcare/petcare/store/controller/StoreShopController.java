/**
 * 역할: 쇼핑몰 URL 처리 → Service 호출 → JSP 반환
 *
 * 연결
 * - Service: StoreShopService
 *
 * SQL·비즈니스 로직은 넣지 말 것 → Service로 위임
 * return 경로는 담당 JSP와 동일하게 맞출 것
 */

package com.petcare.petcare.store.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.petcare.petcare.member.vo.MemberVO;
import com.petcare.petcare.store.service.StoreShopService;
import com.petcare.petcare.store.vo.CartItemVO;
import com.petcare.petcare.store.vo.CouponVO;
import com.petcare.petcare.store.vo.OrderTempVO;
import com.petcare.petcare.common.billing.service.BillingCardService;
import com.petcare.petcare.common.billing.vo.BillingApproveResultVO;
import com.petcare.petcare.common.billing.vo.BillingCardVO;
import com.petcare.petcare.common.external.service.TossBillingService;

import java.util.HashMap;
import java.util.Map;

import jakarta.servlet.http.HttpSession;

@Controller("storeController")
@RequestMapping("/store")
public class StoreShopController {

    //HYJ 26.07.03 토스결제 api key
    @Value("${toss.client-key}")
    private String tossApiKey;

    //지윤 26.07.06 상품목록 조회용 Service 주입
    @Autowired
    private StoreShopService storeShopService;

    //지윤 26.07.29 추가: 배송지록 기본배송지 조회용
    @Autowired
    private com.petcare.petcare.mypage.address.service.MypageAddressService mypageAddressService;

    //지윤 26.07.23 추가: 결제승인(confirm) API 호출용
    @Autowired
    private com.petcare.petcare.common.external.service.TossPaymentService tossPaymentService;

    // 2026/07/27 장우철 — 등록카드(빌링) 결제
    @Autowired
    private BillingCardService billingCardService;
    @Autowired
    private TossBillingService tossBillingService;

    //지윤 26.07.09 로그인 기능 연동: 세션에서 로그인한 회원번호 가져오기 (없으면 null)
    private Long getLoginMemberNo(HttpSession session) {
    MemberVO memberInfo = (MemberVO) session.getAttribute("memberInfo");
    return (memberInfo != null) ? memberInfo.getMemberNo() : null;
}

    // ----- 수정 전 원본 -----
    // @GetMapping({"", "/"})
    // public String store(@RequestParam(required = false) String q) {
    //     if (q != null && !q.isBlank()) {
    //         return "redirect:/search?q=" + java.net.URLEncoder.encode(q.trim(), java.nio.charset.StandardCharsets.UTF_8);}
    //     return "store/list";}
    
    //지윤 26.07.06 카테고리/검색어/정렬/페이지네이션 파라미터
    //지윤 26.07.06 카테고리 트리(species/category/age 3단계) 적용
    //우선순위: age > category > species (더 세부적으로 고른 게 있으면 그걸로 필터링)
    //지윤 26.07.12 가격대(minPrice/maxPrice)·브랜드(brand) 필터 파라미터 추가
    //지윤 26.07.30 수정: 브랜드 단일선택(String) -> 다중선택(List<String>) 체크박스로 변경
    @GetMapping({"", "/"})
    public String store(@RequestParam(required = false) String q,
                         @RequestParam(required = false, defaultValue = "5") Long species,
                         @RequestParam(required = false) Long category,
                         @RequestParam(required = false) Long age,
                         @RequestParam(required = false) String keyword,
                         @RequestParam(required = false) Integer minPrice,
                         @RequestParam(required = false) Integer maxPrice,
                         @RequestParam(required = false) List<String> brand,
                         @RequestParam(required = false, defaultValue = "popular") String sort,
                         @RequestParam(required = false, defaultValue = "1") int page,
                         @RequestParam(required = false) Long bizNo,
                         Model model) {
        if (q != null && !q.isBlank()) {
            return "redirect:/search?q=" + java.net.URLEncoder.encode(q.trim(), java.nio.charset.StandardCharsets.UTF_8);
        }
        Long effectiveCategoryId = (age != null) ? age : (category != null ? category : species);

        model.addAttribute("productList", storeShopService.getProductList(effectiveCategoryId, keyword, minPrice, maxPrice, brand, sort, page, bizNo));
        model.addAttribute("categoryTree", storeShopService.getCategoryTree());
        model.addAttribute("brandList", storeShopService.getBrandList(effectiveCategoryId, keyword, minPrice, maxPrice, bizNo));
        model.addAttribute("selectedSpecies", species);
        model.addAttribute("selectedCategory", category);
        model.addAttribute("selectedAge", age);
        model.addAttribute("selectedKeyword", keyword);
        model.addAttribute("selectedMinPrice", minPrice);
        model.addAttribute("selectedMaxPrice", maxPrice);
        model.addAttribute("selectedBrand", brand);
        model.addAttribute("selectedSort", sort);
        model.addAttribute("currentPage", page);
        model.addAttribute("selectedBizNo", bizNo);
        model.addAttribute("totalPages", storeShopService.getTotalPages(effectiveCategoryId, keyword, minPrice, maxPrice, brand, bizNo));
        model.addAttribute("totalCount", storeShopService.getTotalCount(effectiveCategoryId, keyword, minPrice, maxPrice, brand, bizNo));
        return "store/list";
    }
    
    
   //지윤 26.07.07 상품 상세 실데이터 연동
    @GetMapping("/detail")
    public String detail(@RequestParam(defaultValue = "1") Long id, Model model) {
    model.addAttribute("product", storeShopService.getProductDetail(id));
    return "store/detail";
}

//지윤 26.07.08 장바구니 담기 (POST). 로그인 기능 없어서 MEMBER_NO=1 임시 고정
//지윤 26.07.09 수정: 로그인 안 했으면 장바구니 담기 막고 알림 후 로그인페이지로 이동
@PostMapping("/cart/add")
public String addToCart(@RequestParam Long productId,
                         @RequestParam(required = false) String optionId,
                         @RequestParam(defaultValue = "1") int qty,
                         @RequestParam int price,
                         HttpSession session,
                         RedirectAttributes redirectAttributes) {
    Long memberNo = getLoginMemberNo(session);
    if (memberNo == null) {
        redirectAttributes.addFlashAttribute("loginRequired", true);
        return "redirect:/login";
    }
    Long optionIdLong = (optionId == null || optionId.isBlank()) ? null : Long.valueOf(optionId);
    storeShopService.addToCart(memberNo, productId, optionIdLong, qty, price);
    redirectAttributes.addFlashAttribute("cartAddSuccess", true);
    return "redirect:/store/cart";
}

//지윤 26.07.08 장바구니 수량 변경 (AJAX, cart.jsp에서 호출)
@PostMapping("/cart/updateQty")
@ResponseBody
public String updateCartQty(@RequestParam Long cartItemId, @RequestParam int qty) {
    storeShopService.updateCartItemQty(cartItemId, qty);
    return "OK";
}

//지윤 26.07.08 장바구니 항목 삭제 (AJAX, cart.jsp에서 호출)
@PostMapping("/cart/delete")
@ResponseBody
public String deleteCartItem(@RequestParam Long cartItemId) {
    storeShopService.deleteCartItem(cartItemId);
    return "OK";
}

//지윤 26.07.08 장바구니 선택삭제/전체삭제 (AJAX)
@PostMapping("/cart/deleteAll")
@ResponseBody
public String deleteCartItems(@RequestParam java.util.List<Long> cartItemIds) {
    storeShopService.deleteCartItems(cartItemIds);
    return "OK";
}

//지윤 26.07.08 헤더 장바구니 뱃지용 (AJAX, 모든 페이지 로드 시 header에서 호출)
@GetMapping("/cart/count")
@ResponseBody
public int getCartCount(HttpSession session) {
    Long memberNo = getLoginMemberNo(session);
    if (memberNo == null) return 0;
    return storeShopService.getCartItemCount(memberNo);
}

//지윤 26.07.09 장바구니 실데이터 연동 
@GetMapping("/cart")
public String cart(Model model, HttpSession session) {
    Long memberNo = getLoginMemberNo(session);
    if (memberNo == null) {
        return "redirect:/login";
    }
    model.addAttribute("cartItems", storeShopService.getCartItems(memberNo));
    return "store/cart";
}

/*@GetMapping("/payment")
public String payment(Model model) {
    //HYJ 26.07.03 결제 api key
    model.addAttribute("tossApiKey", tossApiKey);
    return "store/payment";
}*/
//지윤 26.07.30 수정: 배송비/쿠폰을 사업자(BIZ_NO)별로 계산하도록 전면 수정 (다중 사업자 주문 대응)
@PostMapping("/payment")
public String payment(@RequestParam(required = false) Long productId,
                       @RequestParam(required = false) Long optionId,
                       @RequestParam(defaultValue = "1") int qty,
                       @RequestParam(required = false) List<Long> cartItemIds,
                       @RequestParam(required = false, defaultValue = "0") Long couponId,
                       @RequestParam(required = false, defaultValue = "0") Long point,
                       @RequestParam String recvName,
                       @RequestParam String recvPhone,
                       @RequestParam String zipCode,
                       @RequestParam String addr1,
                       @RequestParam(required = false) String addr2,
                       @RequestParam(required = false) String deliveryMemo,
                       Model model,
                       HttpSession session) {
    Long memberNo = getLoginMemberNo(session);
    if (memberNo == null) {
        return "redirect:/login";
    }
    MemberVO memberInfo = (MemberVO) session.getAttribute("memberInfo");

    // 지윤 26.07.10 주문 아이템은 클라이언트 값 안 믿고 서버에서 다시 조회
    List<CartItemVO> orderItems = (productId != null)
            ? storeShopService.getDirectOrderItem(productId, optionId, qty)
            : storeShopService.getCartOrderItems(cartItemIds);

    int productTotal = 0;
    for (CartItemVO item : orderItems) {
        productTotal += item.getPrice() * item.getQty();
    }

    //지윤 26.07.30 추가: 사업자(bizNo)별로 상품금액을 묶어서, 배송비도 사업자별로 5만원 기준 계산 후 합산
    java.util.Map<Long, Integer> groupSubtotals = new java.util.LinkedHashMap<>();
    for (CartItemVO item : orderItems) {
        groupSubtotals.merge(item.getBizNo(), item.getPrice() * item.getQty(), Integer::sum);
    }
    int deliveryFee = 0;
    for (int groupSubtotal : groupSubtotals.values()) {
        deliveryFee += (groupSubtotal >= 50000) ? 0 : 3000;
    }

    // 지윤 26.07.10 쿠폰 재검증: 본인이 실제 보유한(UNUSED) 쿠폰인지 확인
    // 지윤 26.07.30 수정: 쿠폰은 발급한 사업자(BIZ_NO) 상품에만 적용, 최소주문금액도 그 사업자 몫 기준으로 검증
    int couponDiscount = 0;
    String couponName = null;
    String couponBizNoStr = null;
    if (couponId != null && couponId > 0) {
        // 2026-08-13 박유정 — 결제 시에도 주문 사업자(BIZ_NO)에 해당하는 쿠폰만 재검증
        java.util.List<Long> orderBizNos = new java.util.ArrayList<>(groupSubtotals.keySet());
        for (CouponVO c : storeShopService.getMemberCouponsForOrder(memberNo, orderBizNos)) {
            if (c.getMemberCouponId().equals(couponId)) {
                Long couponBizNo = c.getBizNo() != null ? Long.valueOf(c.getBizNo()) : null;
                int couponTargetAmt = groupSubtotals.getOrDefault(couponBizNo, 0);
                if (couponTargetAmt >= c.getMinOrderAmt()) {
                    if ("RATE".equals(c.getCouponType())) {
                        int rawDiscount = couponTargetAmt * c.getDiscountValue() / 100;
                        Integer maxAmt = c.getMaxDiscountAmt();
                        couponDiscount = (maxAmt != null && maxAmt > 0)
                                ? Math.min(rawDiscount, maxAmt)
                                : rawDiscount;
                    } else {
                        couponDiscount = c.getDiscountValue();
                    }
                    // 2026/08/13 장우철 — 쿠폰은 상품금액에만, 배송비에는 적용하지 않음
                    couponDiscount = Math.min(couponDiscount, couponTargetAmt);
                    couponName = c.getCouponName();
                    couponBizNoStr = c.getBizNo();
                }
                break;
            }
        }
    }

    // 지윤 26.07.10 포인트 재검증: 보유 포인트, 결제금액 넘게 사용 못 하도록 제한
    // 2026/07/27 장우철 — 세션이 아니라 DB 실제 잔액 기준으로 상한
    Long dbPoint = storeShopService.getMemberPointBalance(memberNo);
    long memberPoint = Math.max(0L, dbPoint != null ? dbPoint : 0L);
    long maxUsable = Math.min(memberPoint, Math.max(0, productTotal + deliveryFee - couponDiscount));
    long pointUsed = Math.max(0, Math.min(point == null ? 0 : point, maxUsable));

    int totalDiscount = couponDiscount + (int) pointUsed;
    int finalTotal = Math.max(0, productTotal + deliveryFee - totalDiscount);

    model.addAttribute("orderItems", orderItems);
    model.addAttribute("productTotal", productTotal);
    model.addAttribute("deliveryFee", deliveryFee);
    model.addAttribute("couponName", couponName);
    model.addAttribute("couponDiscount", couponDiscount);
    model.addAttribute("pointUsed", pointUsed);
    model.addAttribute("totalDiscount", totalDiscount);
    model.addAttribute("finalTotal", finalTotal);
    model.addAttribute("recvName", recvName);
    model.addAttribute("recvPhone", recvPhone);
    model.addAttribute("zipCode", zipCode);
    model.addAttribute("addr1", addr1);
    model.addAttribute("addr2", addr2);
    model.addAttribute("deliveryMemo", deliveryMemo);
    //HYJ 26.07.03 결제 api key
    model.addAttribute("tossApiKey", tossApiKey);

    //지윤 26.07.13 추가: 토스 위젯이 결제 인증 후 우리 서버를 거치지 않고 order-complete로 바로 이동시키기 때문에,
    //그 사이 없어질 주문정보(상품/배송지/쿠폰/포인트)를 세션에 담아뒀다가 order-complete에서 꺼내 씀
    OrderTempVO orderTemp = new OrderTempVO();
    orderTemp.setMemberNo(memberNo);
    orderTemp.setOrderItems(orderItems);
    orderTemp.setProductTotal(productTotal);
    orderTemp.setDeliveryFee(deliveryFee);
    orderTemp.setCouponMemberCouponId((couponId != null && couponId > 0) ? couponId : null);
    orderTemp.setCouponBizNo(couponBizNoStr);
    orderTemp.setCouponDiscount(couponDiscount);
    orderTemp.setPointUsed((int) pointUsed);
    orderTemp.setTotalDiscount(totalDiscount);
    orderTemp.setFinalTotal(finalTotal);
    orderTemp.setRecvName(recvName);
    orderTemp.setRecvPhone(recvPhone);
    orderTemp.setZipCode(zipCode);
    orderTemp.setAddr1(addr1);
    orderTemp.setAddr2(addr2);
    orderTemp.setDeliveryMemo(deliveryMemo);
    orderTemp.setCartItemIds(cartItemIds);
    session.setAttribute("orderTemp", orderTemp);

    return "store/payment";
}

    // HYJ 26.07.03 결제 요청 성공 시 여기로 돌아옴 (아직 승인 API는 호출 안 함)
    @GetMapping("/test/payment/success")
    @ResponseBody
    public String success(@RequestParam String orderId,
                            @RequestParam String amount,
                            @RequestParam String paymentKey) {
        return "결제 요청 성공! orderId=" + orderId + ", amount=" + amount + ", paymentKey=" + paymentKey;
    }

    @GetMapping("/test/payment/fail")
    @ResponseBody
    public String fail(@RequestParam(required = false) String code,
                        @RequestParam(required = false) String message) {
        return "결제 요청 실패: " + code + " - " + message;
    }

    /**
     * 지윤 26.08.07: 쿠폰·포인트로 최종 결제금액이 0원이 된 경우 전용 경로
     * 토스 결제위젯은 0원 결제를 처리하지 못해서(최소 결제금액 제한), 아예 위젯을 거치지 않고
     * 서버에서 바로 주문을 확정 처리한다. (stay/payment의 point-only 흐름과 동일한 패턴)
     */
    @GetMapping("/payment/zero-amount")
    public String zeroAmountOrder(HttpSession session, Model model) {
        OrderTempVO orderTemp = (OrderTempVO) session.getAttribute("orderTemp");

        if (orderTemp == null) {
            model.addAttribute("noOrderData", true);
            return "store/order-complete";
        }
        // 실제로 0원인 주문만 이 경로로 처리 (클라이언트가 URL 직접 호출해도 방어)
        if (orderTemp.getFinalTotal() == null || orderTemp.getFinalTotal() != 0) {
            model.addAttribute("noOrderData", true);
            return "store/order-complete";
        }

        String tossOrderId = "zero-" + orderTemp.getMemberNo() + "-" + System.currentTimeMillis();
        String orderNo = storeShopService.completeOrder(orderTemp, "ZERO_AMOUNT", tossOrderId, "POINT");
        session.removeAttribute("orderTemp");

        syncSessionPointBalance(session);

        model.addAttribute("orderNo", orderNo);
        model.addAttribute("orderItems", orderTemp.getOrderItems());
        model.addAttribute("payAmount", 0);
        model.addAttribute("payMethodLabel", "쿠폰/포인트");
        return "store/order-complete";
    }

    //지윤 26.07.13 수정: 하드코딩된 화면 -> 세션에 저장해둔 주문정보로 실제 DB 저장 후 실데이터 표시
    @GetMapping("/order-complete")
    public String orderComplete(@RequestParam(required = false) String orderId,
                                 @RequestParam(required = false) String paymentKey,
                                 @RequestParam(required = false) String paymentType,
                                 HttpSession session, Model model) {
        OrderTempVO orderTemp = (OrderTempVO) session.getAttribute("orderTemp");

        // 새로고침 등으로 세션에 남은 주문정보가 없으면 저장할 게 없다는 안내만 보여줌
        if (orderTemp == null) {
            model.addAttribute("noOrderData", true);
            return "store/order-complete";
        }

        //지윤 26.07.23 추가: DB에 저장하기 전에 토스 승인(confirm) API 먼저 호출
        //이걸 안 하면 토스 쪽에선 이 결제가 "완료"된 적이 없어서, 나중에 취소하려 해도 계속 거절당함
        String confirmError = tossPaymentService.confirmPayment(paymentKey, orderId, orderTemp.getFinalTotal());
        if (confirmError != null) {
            session.removeAttribute("orderTemp");
            model.addAttribute("noOrderData", true);
            model.addAttribute("confirmError", confirmError);
            return "store/order-complete";
        }

        String orderNo = storeShopService.completeOrder(orderTemp, paymentKey, orderId, "TOSS");
        session.removeAttribute("orderTemp"); // 새로고침해도 중복저장 안 되게 바로 비움

        //지윤 26.07.23 추가: 주문 시 포인트를 썼으면, 화면이 옛날 세션 값을 계속 보여주던 문제 수정
        // 2026/07/27 장우철 — 계산 차감 대신 DB 잔액을 다시 읽어 세션 동기화
        syncSessionPointBalance(session);

        model.addAttribute("orderNo", orderNo);
        model.addAttribute("orderItems", orderTemp.getOrderItems());
        model.addAttribute("payAmount", orderTemp.getFinalTotal());
        model.addAttribute("payMethodLabel", "NORMAL".equals(paymentType) ? "일반결제" : paymentType);
        return "store/order-complete";
    }

    /**
     * 2026/07/27 장우철 — 등록카드(빌링키) Ajax 결제
     * POST /store/payment/billing-card
     * 1) 세션 orderTemp 금액으로 토스 자동결제 승인
     * 2) 성공 시 completeOrder → TB_ORDER / TB_PAYMENT
     * 3) JSON { ok, redirectUrl } 또는 { ok:false, message }
     */
    @PostMapping("/payment/billing-card")
    @ResponseBody
    public Map<String, Object> payWithBillingCard(
            @RequestParam Long billingCardId,
            HttpSession session) {

        Map<String, Object> res = new HashMap<>();
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null || member.getMemberNo() == null) {
            res.put("ok", false);
            res.put("message", "로그인이 필요합니다.");
            return res;
        }

        OrderTempVO orderTemp = (OrderTempVO) session.getAttribute("orderTemp");
        if (orderTemp == null || orderTemp.getFinalTotal() == null) {
            res.put("ok", false);
            res.put("message", "주문 정보가 없습니다. 주문서부터 다시 진행해 주세요.");
            return res;
        }
        if (!member.getMemberNo().equals(orderTemp.getMemberNo())) {
            res.put("ok", false);
            res.put("message", "주문 소유자가 일치하지 않습니다.");
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

        int amount = orderTemp.getFinalTotal();
        if (amount <= 0) {
            res.put("ok", false);
            res.put("message", "결제 금액이 올바르지 않습니다.");
            return res;
        }

        // 토스 orderId: 영문/숫자/하이픈, 6~64자
        String tossOrderId = "store-" + member.getMemberNo() + "-" + System.currentTimeMillis();
        String orderName = "펫케어 스토어 주문";
        if (orderTemp.getOrderItems() != null && !orderTemp.getOrderItems().isEmpty()) {
            String firstName = orderTemp.getOrderItems().get(0).getProductName();
            int extra = orderTemp.getOrderItems().size() - 1;
            orderName = (firstName != null ? firstName : orderName)
                    + (extra > 0 ? (" 외 " + extra + "건") : "");
            if (orderName.length() > 100) {
                orderName = orderName.substring(0, 100);
            }
        }

        StringBuilder err = new StringBuilder();
        BillingApproveResultVO approved = tossBillingService.approveBilling(
                card.getBillingKey(), card.getCustomerKey(), amount,
                tossOrderId, orderName, err);

        if (approved == null) {
            res.put("ok", false);
            res.put("message", err.length() > 0 ? err.toString() : "등록카드 결제에 실패했습니다.");
            return res;
        }

        try {
            String paymentKey = approved.getPaymentKey() != null
                    ? approved.getPaymentKey() : ("BILLING-" + tossOrderId);
            // 2026/08/11 장우철 — 빌링 결제는 PAY_METHOD=BILLING 으로 저장 (취소 시 billing 시크릿)
            String orderNo = storeShopService.completeOrder(orderTemp, paymentKey, tossOrderId, "BILLING");
            session.removeAttribute("orderTemp");

            // 2026/07/27 장우철 — 등록카드 결제도 DB 잔액으로 세션 동기화
            syncSessionPointBalance(session);

            // 완료 화면은 GET order-complete 인데 세션을 이미 비움 → 전용 완료 redirect 파라미터
            res.put("ok", true);
            res.put("orderNo", orderNo);
            res.put("redirectUrl", "/store/order-complete-billing?orderNo="
                    + java.net.URLEncoder.encode(orderNo, java.nio.charset.StandardCharsets.UTF_8)
                    + "&amount=" + amount);
            return res;
        } catch (Exception e) {
            res.put("ok", false);
            res.put("message", "결제는 승인됐으나 주문 저장 중 오류: " + e.getMessage());
            return res;
        }
    }

    /**
     * 2026/07/27 장우철 — 빌링 Ajax 결제 완료 화면
     * (세션 orderTemp 없이 orderNo·금액만 표시)
     */
    @GetMapping("/order-complete-billing")
    public String orderCompleteBilling(@RequestParam String orderNo,
                                       @RequestParam(required = false) Integer amount,
                                       Model model) {
        model.addAttribute("orderNo", orderNo);
        model.addAttribute("payAmount", amount);
        model.addAttribute("payMethodLabel", "등록카드(빌링)");
        // noOrderData 는 넣지 않음 (JSP: not empty noOrderData 이면 오류 화면)
        return "store/order-complete";
    }

    //지윤 26.07.09 수정: cartItemIds 파라미터 추가 - 장바구니에서 주문하기로 들어온 경우 처리
    //2026/08/06 장우철: 결제→「주문서로 돌아가기」 시 세션 orderTemp로 주문서 복원
@GetMapping("/order")
public String order(@RequestParam(required = false) Long productId,
                @RequestParam(required = false) Long optionId,
                @RequestParam(defaultValue = "1") int qty,
                @RequestParam(required = false) java.util.List<Long> cartItemIds,
                Model model,
                HttpSession session) {
    Long memberNo = getLoginMemberNo(session);
    if (memberNo == null) {
        return "redirect:/login";
    }

//지윤 26.07.10 보유 포인트 + 기본 배송지 실데이터 연동
// 2026/07/27 장우철 — 주문서 보유포인트는 DB 실잔액 (세션도 맞춤)
MemberVO memberInfo = (MemberVO) session.getAttribute("memberInfo");
Long dbPoint = storeShopService.getMemberPointBalance(memberNo);
long heldPoint = dbPoint != null ? dbPoint : 0L;
if (memberInfo != null) {
    memberInfo.setPointBalance(heldPoint);
    session.setAttribute("memberInfo", memberInfo);
}
model.addAttribute("memberPoint", heldPoint);

//지윤 26.07.29 수정: 배송지록(TB_MEMBER_ADDRESS)에 기본배송지가 있으면 그걸 우선 사용, 없으면 기존처럼 회원정보(TB_MEMBER) 주소로 fallback
// 2026/08/11 장우철 — 전화 숫자만(01012341234)도 주문서에 들어가도록 하이픈 정규화
com.petcare.petcare.mypage.address.vo.MypageAddressVO defaultAddr = mypageAddressService.getDefaultAddress(memberNo);
if (defaultAddr != null) {
    model.addAttribute("memberRecvName", defaultAddr.getRecvName());
    model.addAttribute("memberPhone", com.petcare.petcare.common.util.PhoneNormalizeUtil.toHyphenPhone(defaultAddr.getRecvPhone()));
    model.addAttribute("memberZipCode", defaultAddr.getZipCode());
    model.addAttribute("memberAddr1", defaultAddr.getAddr1());
    model.addAttribute("memberAddr2", defaultAddr.getAddr2());
} else {
    model.addAttribute("memberRecvName", memberInfo != null ? memberInfo.getMemberName() : "");
    model.addAttribute("memberPhone", memberInfo != null && memberInfo.getPhone() != null
            ? com.petcare.petcare.common.util.PhoneNormalizeUtil.toHyphenPhone(memberInfo.getPhone()) : "");
    model.addAttribute("memberZipCode", memberInfo != null && memberInfo.getZipcode() != null ? memberInfo.getZipcode() : "");
    model.addAttribute("memberAddr1", memberInfo != null && memberInfo.getAddr1() != null ? memberInfo.getAddr1() : "");
    model.addAttribute("memberAddr2", memberInfo != null && memberInfo.getAddr2() != null ? memberInfo.getAddr2() : "");
}

    // 바로구매 / 장바구니 / 결제 복귀 — orderItems 변수로 통일
    java.util.List<CartItemVO> orderItems = null;
    if (productId != null) {
        orderItems = storeShopService.getDirectOrderItem(productId, optionId, qty);
        model.addAttribute("orderItems", orderItems);
    }
    else if (cartItemIds != null && !cartItemIds.isEmpty()) {
        orderItems = storeShopService.getCartOrderItems(cartItemIds);
        model.addAttribute("orderItems", orderItems);
    }
    else {
        // 2026/08/06 장우철: 결제 화면에서 돌아온 경우 — 세션 orderTemp로 복원
        OrderTempVO orderTemp = (OrderTempVO) session.getAttribute("orderTemp");
        if (orderTemp != null
                && memberNo.equals(orderTemp.getMemberNo())
                && orderTemp.getOrderItems() != null
                && !orderTemp.getOrderItems().isEmpty()) {
            orderItems = orderTemp.getOrderItems();
            model.addAttribute("orderItems", orderItems);
            if (orderTemp.getRecvName() != null) {
                model.addAttribute("memberRecvName", orderTemp.getRecvName());
            }
            if (orderTemp.getRecvPhone() != null) {
                model.addAttribute("memberPhone",
                        com.petcare.petcare.common.util.PhoneNormalizeUtil.toHyphenPhone(orderTemp.getRecvPhone()));
            }
            if (orderTemp.getZipCode() != null) {
                model.addAttribute("memberZipCode", orderTemp.getZipCode());
            }
            if (orderTemp.getAddr1() != null) {
                model.addAttribute("memberAddr1", orderTemp.getAddr1());
            }
            if (orderTemp.getAddr2() != null) {
                model.addAttribute("memberAddr2", orderTemp.getAddr2());
            }
            model.addAttribute("restoreCouponId", orderTemp.getCouponMemberCouponId());
            model.addAttribute("restorePoint", orderTemp.getPointUsed());
            model.addAttribute("restoreDeliveryMemo", orderTemp.getDeliveryMemo());
        } else {
            return "redirect:/store/cart";
        }
    }

    // 2026-08-13 박유정 — 주문 상품 사업자(BIZ_NO)에 해당하는 쿠폰만 노출
    java.util.List<Long> orderBizNos = new java.util.ArrayList<>();
    if (orderItems != null) {
        for (CartItemVO item : orderItems) {
            if (item.getBizNo() != null && !orderBizNos.contains(item.getBizNo())) {
                orderBizNos.add(item.getBizNo());
            }
        }
    }
    model.addAttribute("memberCoupons",
            storeShopService.getMemberCouponsForOrder(memberNo, orderBizNos));
    return "store/order";
}

//지윤 26.07.10 상품 Q&A 문의 등록 (AJAX)
//지윤 26.07.12 수정: 응답을 "OK:qnaId" 형식으로 변경 (등록 직후 삭제버튼 붙이기 위함)
@PostMapping("/qna/add")
@ResponseBody
public String addQna(@RequestParam Long productId, @RequestParam String question,
                      @RequestParam(required = false) Long optionId, HttpSession session) {
    Long memberNo = getLoginMemberNo(session);
    if (memberNo == null) {
        return "LOGIN_REQUIRED";
    }
    if (question == null || question.isBlank()) {
        return "EMPTY";
    }
    Long qnaId = storeShopService.addProductQna(productId, memberNo, question.trim(), optionId);
    return "OK:" + qnaId;
}

//지윤 26.07.12 상품 Q&A 삭제 (AJAX, 본인 글 + 답변 미완료 건만 삭제 가능)
@PostMapping("/qna/delete")
@ResponseBody
public String deleteQna(@RequestParam Long qnaId, HttpSession session) {
    Long memberNo = getLoginMemberNo(session);
    if (memberNo == null) {
        return "LOGIN_REQUIRED";
    }
    boolean deleted = storeShopService.deleteProductQna(qnaId, memberNo);
    return deleted ? "OK" : "FAILED";
}

//지윤 26.07.21 추가: 유저 리뷰 신고 (AJAX). 이미 신고한 리뷰면 ALREADY 반환
@PostMapping("/review/report")
@ResponseBody
public String reportReview(@RequestParam Long reviewId, @RequestParam(required = false) String reason, HttpSession session) {
    Long memberNo = getLoginMemberNo(session);
    if (memberNo == null) {
        return "LOGIN_REQUIRED";
    }
    boolean ok = storeShopService.reportReview(reviewId, memberNo, reason);
    return ok ? "OK" : "ALREADY";
}

//지윤 26.07.21 추가: 본인이 작성한 상품 리뷰 삭제 (AJAX)
@PostMapping("/review/delete")
@ResponseBody
public String deleteReview(@RequestParam Long reviewId, HttpSession session) {
    Long memberNo = getLoginMemberNo(session);
    if (memberNo == null) {
        return "LOGIN_REQUIRED";
    }
    boolean deleted = storeShopService.deleteProductReview(reviewId, memberNo);
    return deleted ? "OK" : "FAILED";
}

/**
 * 2026/07/27 장우철 — 결제 후 세션 포인트를 DB 실잔액과 맞춤
 */
private void syncSessionPointBalance(HttpSession session) {
    MemberVO sessionMember = (MemberVO) session.getAttribute("memberInfo");
    if (sessionMember == null || sessionMember.getMemberNo() == null) {
        return;
    }
    Long bal = storeShopService.getMemberPointBalance(sessionMember.getMemberNo());
    sessionMember.setPointBalance(bal != null ? bal : 0L);
    session.setAttribute("memberInfo", sessionMember);
}
}
