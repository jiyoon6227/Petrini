package com.petcare.petcare.main.banner.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.petcare.petcare.common.util.UploadUrlUtil;
import com.petcare.petcare.main.banner.service.MainBannerService;
import com.petcare.petcare.main.banner.vo.MainBannerVO;

import jakarta.servlet.http.HttpServletRequest;

@Controller
public class MainBannerController {

    @Autowired
    private MainBannerService mainBannerService;

    //  사용자: 위치별 활성 배너 API
    //  예) /api/banners?position=MAIN_HERO
    //      /api/banners?position=STORE
    @GetMapping("/api/banners")
    @ResponseBody
    public List<MainBannerVO> getActiveBanners(@RequestParam(defaultValue = "MAIN_HERO") String position,
                                               HttpServletRequest request) {
        List<MainBannerVO> result = mainBannerService.getBannersByPosition(position);
        // FILE_URL 형식 통일 후 브라우저용 절대 경로로 변환
        String ctx = request.getContextPath();
        for (MainBannerVO banner : result) {
            banner.setImageUrl(UploadUrlUtil.toPublicUrl(banner.getImageUrl(), ctx));
        }
        return result;
    }
}
