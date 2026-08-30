package com.petcare.petcare.biz.grooming;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.petcare.petcare.biz.controller.BizBaseController;

import jakarta.servlet.http.HttpSession;

@Controller("bizGroomingController")
@RequestMapping("/biz/grooming")
public class GroomingController extends BizBaseController {

    // ── 사업자 공통 (GROOMING) ─────────────────────────────────────
    @GetMapping({"", "/"})
    public String groomingDashboard(HttpSession session) {
        if (getBizMember(session) == null)
            return "redirect:/login";

        return "biz/grooming/dashboard";
    }

    @GetMapping("/info")
    public String groomingInfo(HttpSession session) {
        if (getBizMember(session) == null)
            return "redirect:/login";

        return "biz/grooming/info";
    }

    @GetMapping("/reserve")
    public String groomingReserve(HttpSession session) {
        if (getBizMember(session) == null)
            return "redirect:/login";

        return "biz/grooming/reserve";
    }

    @GetMapping("/reviews")
    public String groomingReviews(HttpSession session) {
        if (getBizMember(session) == null)
            return "redirect:/login";

        return "biz/grooming/reviews";
    }

    @GetMapping("/talent")
    public String groomingTalent(HttpSession session) {
        if (getBizMember(session) == null)
            return "redirect:/login";

        return "biz/grooming/talent";
    }

    @GetMapping("/settlement")
    public String groomingSettlement(HttpSession session) {
        if (getBizMember(session) == null)
            return "redirect:/login";

        return "biz/grooming/settlement";
    }

    // ── 미용실 개별(GROOMING) ─────────────────────────────────────
    @GetMapping("/services")
    public String groomingServices(HttpSession session) {
        if (getBizMember(session) == null)
            return "redirect:/login";

        return "biz/grooming/services";
    }

    @GetMapping("/stylists")
    public String groomingStylists(HttpSession session) {
        if (getBizMember(session) == null)
            return "redirect:/login";

        return "biz/grooming/stylists";
    }
}
