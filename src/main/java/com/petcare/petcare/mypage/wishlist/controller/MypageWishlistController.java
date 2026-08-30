/**
 * 2026/08/13 장우철 — 관심상품 목록 + 찜 토글 API
 */
package com.petcare.petcare.mypage.wishlist.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.petcare.petcare.member.vo.MemberVO;
import com.petcare.petcare.mypage.wishlist.service.MypageWishlistService;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/mypage")
public class MypageWishlistController {

    @Autowired
    private MypageWishlistService mypageWishlistService;

    @GetMapping("/wishlist")
    public String wishlist(HttpSession session, Model model) {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null) {
            return "redirect:/login";
        }
        try {
            model.addAttribute("wishList", mypageWishlistService.getMyWishlist(member.getMemberNo()));
        } catch (Exception e) {
            e.printStackTrace();
            model.addAttribute("wishList", java.util.Collections.emptyList());
            model.addAttribute("errorMsg", "관심상품을 불러오지 못했습니다.");
        }
        return "mypage/wishlist";
    }

    @GetMapping("/wishlist/keys")
    @ResponseBody
    public Map<String, Object> wishKeys(HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null) {
            result.put("loggedIn", false);
            result.put("keys", java.util.Collections.emptyList());
            return result;
        }
        result.put("loggedIn", true);
        result.put("keys", mypageWishlistService.getMyWishKeys(member.getMemberNo()));
        return result;
    }

    @PostMapping("/wishlist/toggle")
    @ResponseBody
    public Map<String, Object> toggle(@RequestParam String favType,
                                      @RequestParam Long targetId,
                                      HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null) {
            result.put("ok", false);
            result.put("loginRequired", true);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }
        try {
            boolean active = mypageWishlistService.toggle(member.getMemberNo(), favType, targetId);
            result.put("ok", true);
            result.put("active", active);
        } catch (IllegalArgumentException e) {
            result.put("ok", false);
            result.put("message", e.getMessage());
        }
        return result;
    }
}
