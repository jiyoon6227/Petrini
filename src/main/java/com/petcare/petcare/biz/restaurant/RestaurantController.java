package com.petcare.petcare.biz.restaurant;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.petcare.petcare.biz.controller.BizBaseController;

import jakarta.servlet.http.HttpSession;

@Controller("bizRestaurantController")
@RequestMapping("/biz/restaurant")
public class RestaurantController extends BizBaseController {

    // ── 요식업 (RESTAURANT) ───────────────────────────────────
    @GetMapping({"", "/"})
    public String restaurantDashboard(HttpSession session) {
        if (getBizMember(session) == null) 
            return "redirect:/login";

        return "biz/restaurant/dashboard";
    }

    @GetMapping("/reserve")
    public String restaurantReserve(HttpSession session) {
        if (getBizMember(session) == null) 
            return "redirect:/login";

        return "biz/restaurant/reserve";
    }

    @GetMapping("/menu")
    public String restaurantMenu(HttpSession session) {
        if (getBizMember(session) == null) 
            return "redirect:/login";

        return "biz/restaurant/menu";
    }

    @GetMapping("/tables")
    public String restaurantTables(HttpSession session) {
        if (getBizMember(session) == null) 
            return "redirect:/login";

        return "biz/restaurant/tables";
    }

    @GetMapping("/reviews")
    public String restaurantReviews(HttpSession session) {
        if (getBizMember(session) == null) 
            return "redirect:/login";

        return "biz/restaurant/reviews";
    }

    @GetMapping("/settlement")
    public String restaurantSettlement(HttpSession session) {
        if (getBizMember(session) == null) 
            return "redirect:/login";

        return "biz/restaurant/settlement";
    }
    
    @GetMapping("/info")
    public String restaurantInfo(HttpSession session) {
        if (getBizMember(session) == null) 
            return "redirect:/login";

        return "biz/restaurant/info";
    }    
}
