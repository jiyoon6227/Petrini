/**
 * 역할: 마이페이지 포인트 URL 처리 → Service 호출 → JSP 반환
 *
 * 연결
 * - Service: MypagePointService / CouponService
 *
 * SQL·비즈니스 로직은 넣지 말 것 → Service로 위임
 * return 경로는 담당 JSP와 동일하게 맞출 것
 *
 * 2026/08/01 장우철 — yeju 머지: 포인트 실데이터(HEAD/jiyoon) + 쿠폰함 목록(yeju) 동시 유지
 */

package com.petcare.petcare.mypage.point.controller;

import java.util.List;

import jakarta.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.petcare.petcare.coupon.service.CouponService;
import com.petcare.petcare.member.vo.MemberVO;
import com.petcare.petcare.mypage.home.service.MypageHomeService;
import com.petcare.petcare.mypage.point.service.MypagePointService;
import com.petcare.petcare.store.vo.CouponVO;

@Controller
@RequestMapping("/mypage")
public class MypagePointController {

    @Autowired
    private MypagePointService mypagePointService;

    @Autowired
    private MypageHomeService mypageHomeService;

    @Autowired
    private CouponService couponService;

    @GetMapping("/points")
    public String points(HttpSession session, Model model) {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null) return "redirect:/login";

        // HEAD(jiyoon): 포인트 잔액·이번달 적립·이력
        model.addAttribute("pointBalance", mypagePointService.getPointBalance(member.getMemberNo()));
        model.addAttribute("thisMonthEarned", mypagePointService.getThisMonthEarnedPoint(member.getMemberNo()));
        model.addAttribute("pointHistory", mypagePointService.getPointHistory(member.getMemberNo()));

        // yeju: 쿠폰함 목록 + 사용가능 개수
        List<CouponVO> myCoupons = couponService.getMyCoupons(member.getMemberNo());
        model.addAttribute("myCoupons", myCoupons);
        int usableCouponCount = couponService.countUsableCoupons(member.getMemberNo());
        model.addAttribute("usableCouponCount", usableCouponCount);
        // 기존 JSP 호환 (요약 칸)
        model.addAttribute("couponCount", usableCouponCount);

        return "mypage/points";
    }
}
