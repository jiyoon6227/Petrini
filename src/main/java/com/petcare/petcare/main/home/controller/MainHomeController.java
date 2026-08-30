package com.petcare.petcare.main.home.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import com.petcare.petcare.main.section.service.MainSectionService;

/*
 *  2026/07/06 장우철
 *  메인 홈 URL "/" 처리 (service 호출)
 */
@Controller
public class MainHomeController {

    private final MainSectionService mainSectionService;

    public MainHomeController(MainSectionService mainSectionService) {
        this.mainSectionService = mainSectionService;
    }
/*
 * 인기상품 , 게시글 각각 TOP 8 , 최신글 3건 출력
 */
    @GetMapping("/")
    public String main(Model model) {
        model.addAttribute("popularProducts", mainSectionService.getPopularProducts(4));
        model.addAttribute("communityPreview", mainSectionService.getLatestPosts(3));
        return "main/main";
    }
}
