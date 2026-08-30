/**
 * 역할: 마이페이지 홈 URL 처리 → Service 호출 → JSP 반환
 *
 * 연결
 * - Service: MypageHomeService
 *
 * SQL·비즈니스 로직은 넣지 말 것 → Service로 위임
 * return 경로는 담당 JSP와 동일하게 맞출 것
 */

package com.petcare.petcare.mypage.home.controller;

import com.petcare.petcare.member.vo.MemberVO;
import com.petcare.petcare.mypage.home.service.MypageHomeService;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller("mypageController")
@RequestMapping("/mypage")
public class MypageHomeController {

    private final MypageHomeService mypageHomeService;

    public MypageHomeController(MypageHomeService mypageHomeService) {
        this.mypageHomeService = mypageHomeService;
    }

    // 2026/07/08 장우철 — 마이페이지 B단계: 쿠폰·관심상품 COUNT DB 연동
    @GetMapping({"", "/"})
    public String dashboard(HttpSession session, Model model) {
        MemberVO memberInfo = (MemberVO) session.getAttribute("memberInfo");
        if (memberInfo == null) {
            return "redirect:/login";
        }

        Long memberNo = memberInfo.getMemberNo();
        model.addAttribute("couponCount", mypageHomeService.countUsableCoupon(memberNo));
        model.addAttribute("wishlistCount", mypageHomeService.countFavoriteProduct(memberNo));

        return "mypage/dashboard";
    }

    // 2026/07/11 장우철 — /mypage/pets 는 PetProfileController 로 이동
    // 2026/07/14 장우철 — /mypage/health 는 PetHealthController 로 이동
}
