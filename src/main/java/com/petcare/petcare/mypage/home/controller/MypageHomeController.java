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

    // 쿠폰·관심상품 COUNT
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

    // /mypage/pets 는 PetProfileController 로 이동
    // /mypage/health 는 PetHealthController 로 이동
}
