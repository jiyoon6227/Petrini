package com.petcare.petcare.studio;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;

@Controller("userStudioController")
@RequestMapping("/studio")
public class StudioController {

    // ── 사진관 목록 ─────────────────────────────────────────
    @GetMapping({"", "/"})
    public String list(Model model) throws JsonMappingException, JsonProcessingException {
        //test
        //kakaoMapService.addMapAttributes(model, "서울 중구 세종대로 110", "행복 동물병원");
        return "studio/list";
    }

    // ── 사진관 상세 ─────────────────────────────────────────
    @GetMapping("/detail")
    public String detail(@RequestParam(defaultValue = "1") String id, Model model) {
        model.addAttribute("id", id);

        //test
        //kakaoMapService.addMapAttributes(model, "서울 중구 세종대로 110", "행복 동물병원");
        return "studio/detail";
    }

    // ── 촬영 예약 ───────────────────────────────────────────
    @GetMapping("/reserve")
    public String reserve(@RequestParam(defaultValue = "1") String id, Model model) {
        model.addAttribute("id", id);
        return "studio/reserve";
    }

    // ── 예약 완료 ───────────────────────────────────────────
    @GetMapping("/complete")
    public String complete() {
        return "studio/complete";
    }
}
