/**
 * 역할: 사용자 이벤트/쿠폰 페이지 URL 처리 → Service 호출 → JSP 반환
 *
 * 연결
 * - Service: EventCouponService
 * - JSP: event/list.jsp
 *
 * URL
 * - GET  /coupon           → 쿠폰 목록 (list.jsp)
 * - POST /coupon/claim     → 쿠폰 받기 (AJAX)
 */
package com.petcare.petcare.coupon.controller;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.petcare.petcare.coupon.service.CouponService;
import com.petcare.petcare.store.vo.CouponVO;
import com.petcare.petcare.store.vo.StoreShopVO;
import com.petcare.petcare.member.vo.MemberVO;

import jakarta.servlet.http.HttpSession;

@Controller("CouponController")
@RequestMapping("/coupon")
public class CouponController {

    @Autowired
    private CouponService couponService;

    /**
     * 쿠폰 메인 페이지 (event/list.jsp)
     * - 받을 수 있는 쿠폰 목록 + 발급(받기)
     */
    @GetMapping({"", "/"})
    public String eventMain(HttpSession session, Model model) {
        Long memberNo = getMemberNo(session);
        String today = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));

        List<CouponVO> availableCoupons = couponService.getAvailableCoupons(memberNo, today);
        model.addAttribute("availableCoupons", availableCoupons);
        model.addAttribute("today", today);

        return "coupon/list";
    }

    /**
     * 쿠폰 받기 (AJAX)
     */
    @PostMapping("/claim")
    @ResponseBody
    public Map<String, Object> claimCoupon(@RequestParam Long couponId,
                                           HttpSession session) {
        Map<String, Object> result = new LinkedHashMap<>();
        Long memberNo = getMemberNo(session);
        if (memberNo == null) {
            result.put("ok", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }

        try {
            couponService.claimCoupon(memberNo, couponId);
            result.put("ok", true);
            result.put("message", "쿠폰이 발급되었습니다!");
        } catch (IllegalStateException e) {
            result.put("ok", false);
            if ("ALREADY_CLAIMED".equals(e.getMessage())) {
                result.put("message", "이미 받은 쿠폰입니다.");
            } else if ("COUPON_EXHAUSTED".equals(e.getMessage()) || "BUDGET_EXHAUSTED".equals(e.getMessage())) {
                result.put("message", "쿠폰이 모두 소진되었습니다.");
            } else if ("COUPON_CLOSED".equals(e.getMessage())) {
                result.put("message", "조기 마감된 쿠폰입니다.");
            } else if ("COUPON_EXPIRED".equals(e.getMessage())) {
                result.put("message", "쿠폰 사용 기간이 종료되었습니다.");
            } else {
                result.put("message", "쿠폰을 받을 수 없습니다.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            result.put("ok", false);
            result.put("message", "오류가 발생했습니다.");
        }
        return result;
}

/**
 * 지윤 26.08.06
 * 쇼핑몰 쿠폰 적용 상품 목록 화면
 *
 * 쿠폰을 발급한 STORE 사업자의 상품만 조회한다.
 * 병원과 숙소 쿠폰은 쿠폰함에서 기존 상세 페이지로 이동한다.
 */
/**
 * 지윤 26.08.06
 * 쿠폰 적용 상품 목록·검색·정렬
 */
@GetMapping("/products")
public String couponProducts(
        @RequestParam Long couponId,
        @RequestParam(
                required = false,
                defaultValue = "popular"
        ) String sort,
        @RequestParam(
                required = false,
                defaultValue = ""
        ) String keyword,
        Model model
) {
    CouponVO coupon = couponService.getCouponTarget(couponId);

    if (coupon == null || !"STORE".equals(coupon.getBizType())) {
        return "redirect:/coupon";
    }

    // 검색어 앞뒤 공백 제거
    keyword = keyword.trim();

    List<StoreShopVO> productList =
            couponService.getCouponProducts(
                    coupon.getBizNo(),
                    sort,
                    keyword
            );

    model.addAttribute("coupon", coupon);
    model.addAttribute("productList", productList);
    model.addAttribute("selectedSort", sort);
    model.addAttribute("selectedKeyword", keyword);

    return "coupon/products";
}

private Long getMemberNo(HttpSession session) {
    MemberVO m = (MemberVO) session.getAttribute("memberInfo");
    if (m == null) return null;
    return m.getMemberNo();
}
}