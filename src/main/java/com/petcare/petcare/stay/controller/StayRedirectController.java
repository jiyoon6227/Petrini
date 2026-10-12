/**
 * 역할: 구 URL /hotel → /stay 리다이렉트 (북마크·예전 링크 호환)
 */
package com.petcare.petcare.stay.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/hotel")
public class StayRedirectController {
}
