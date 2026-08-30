package com.petcare.petcare.biz.studio;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.petcare.petcare.biz.controller.BizBaseController;

import jakarta.servlet.http.HttpSession;

@Controller("bizStudioController")
@RequestMapping("/biz/studio")
public class StudioController extends BizBaseController {
    // ── 쇼핑몰 (store) ─────────────────────────────────────────
    @GetMapping({"", "/"})
    public String studioDashboard(HttpSession session) {
        if (getBizMember(session) == null) 
            return "redirect:/login";

        return "biz/studio/dashboard";
    }

    @GetMapping("/talent")
    public String studioTalent(HttpSession session) {
        if (getBizMember(session) == null) 
            return "redirect:/login";

        return "biz/studio/talent";
    } 

    @GetMapping("/reserve")
    public String studioReserve(HttpSession session) {
        if (getBizMember(session) == null) 
            return "redirect:/login";

        return "biz/studio/reserve";
    }

    @GetMapping("/info")
    public String studioInfo(HttpSession session) {
        if (getBizMember(session) == null) 
            return "redirect:/login";

        return "biz/studio/info";
    }  
}
