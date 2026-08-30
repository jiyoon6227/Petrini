/**
 * 역할: 구 URL /hotel → /stay 리다이렉트 (북마크·예전 링크 호환)
 */
package com.petcare.petcare.stay.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/hotel")
public class StayRedirectController {

    //@GetMapping({"", "/", "/detail", "/reserve", "/complete"})
    // public String redirectToStay(HttpServletRequest request) {
    //     String uri = request.getRequestURI();
    //     String suffix = uri.substring(uri.indexOf("/hotel") + "/hotel".length());
    //     String query = request.getQueryString();
    //     String target = "/stay" + suffix;
    //     if (query != null && !query.isBlank()) {
    //         target += "?" + query;
    //     }
    //     return "redirect:" + target;
    // }
}
