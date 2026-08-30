package com.petcare.petcare.grooming;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.petcare.petcare.common.util.controller.CommonUtilController;

@Controller("groomingController")
@RequestMapping("/grooming")
public class GroomingController extends CommonUtilController {

    // ── 애견미용실 목록 ─────────────────────────────────────
    @GetMapping({"", "/"})
    public String list(Model model) throws JsonMappingException, JsonProcessingException {
        //test
        //addMapAttributes(model, "서울 중구 세종대로 110", "행복 동물병원");
        
        return "grooming/list";
    }

    // ── 애견미용실 상세 ─────────────────────────────────────
    @GetMapping("/detail")
    public String detail(@RequestParam(defaultValue = "1") String id, Model model) {
        model.addAttribute("id", id);

        //addMapAttributes(model, "서울 중구 세종대로 110", "행복 동물병원");

        return "grooming/detail";
    }

    // ── 미용 예약 ───────────────────────────────────────────
    @GetMapping("/reserve")
    public String reserve(@RequestParam(defaultValue = "1") String id, Model model) {
        model.addAttribute("id", id);
        return "grooming/reserve";
    }

    // ── 예약 완료 ───────────────────────────────────────────
    @GetMapping("/complete")
    public String complete() {
        return "grooming/complete";
    }
}
