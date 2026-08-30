/**
 * 역할: 유기동물(정부 API) URL 처리 → Service 호출 → JSP 반환
 *
 * - 박유정 / 2026-07-06
 * - 파일 안에서 API 를 직접 호출했는데, Service 로 옮김
 *
 * [목록 화면 흐름] (2026-07-06 조건 후 조회 추가)
 * 1. 사용자가 /give/animal/list 주소로 들어옴 → API 안 부름, 안내만 표시
 * 2. 조건 고르고 [조회] 클릭 → search=true 와 함께 Service 호출
 * 3. giveAnimalService.getAnimalList() (캐시 적용)
 * 4. 받은 결과를 model 에 넣고 list.jsp 보여줌
 *
 * [상세 화면 흐름]
 * 1. 사용자가 /give/animal/detail?desertionNo=번호 로 들어옴
 * 2. giveAnimalService.getAnimalDetail() 에 맡김
 * 3. 받은 유기견 1마리 정보를 detail.jsp 에 보여줌
 */

package com.petcare.petcare.give.animal.controller;

import java.util.Collections;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.petcare.petcare.give.animal.service.GiveAnimalService;
import com.petcare.petcare.give.animal.vo.GiveAnimalListResult;
import com.petcare.petcare.give.report.service.GiveReportService;

@Controller("giveAnimalController")
@RequestMapping("/give/animal")
public class GiveAnimalController {

    @Autowired
    private GiveAnimalService giveAnimalService;

    @Autowired
    private GiveReportService giveReportService;

    /**
     * 유기견 목록 페이지
     *
     * [조건 고른 뒤에만 조회] 박유정 2026-07-06
     * - 페이지 첫 진입(search=false) : API 호출 안 함 → 빠르게 화면만 보여줌
     * - [조회] 버튼 클릭(search=true) : 그때 Service → 정부 API 호출
     * - 같은 조건 재조회는 Service 의 @Cacheable 캐시가 처리 (두 번째부터 빠름)
     */
    @GetMapping("/list")
    public String animalList(
            @RequestParam(defaultValue = "") String sido,
            @RequestParam(defaultValue = "") String upkind,
            @RequestParam(defaultValue = "") String state,
            @RequestParam(defaultValue = "1") int pageNo,
            @RequestParam(defaultValue = "false") boolean search,
            Model model) {

        // JSP 검색 폼·페이징에서 선택값 유지 + "조회 했는지" 여부 전달 (화면용 → Controller 담당)
        model.addAttribute("sido", sido);
        model.addAttribute("upkind", upkind);
        model.addAttribute("state", state);
        model.addAttribute("searched", search);
        model.addAttribute("reportCount", giveReportService.getReportCount());

        // 아직 [조회] 안 눌렀으면 API 스킵 (지역 첫 조회 10초+ 대기 방지)
        if (!search) {
            model.addAttribute("animals", Collections.emptyList());
            model.addAttribute("totalCount", 0);
            model.addAttribute("pageNo", 1);
            model.addAttribute("totalPages", 0);
            model.addAttribute("apiError", false);
            return "give/animal/list";
        }

        // [조회] 눌렀을 때만 Service 호출 
        GiveAnimalListResult result = giveAnimalService.getAnimalList(sido, upkind, state, pageNo);

        model.addAttribute("animals", result.getAnimals());
        model.addAttribute("totalCount", result.getTotalCount());
        model.addAttribute("pageNo", result.getPageNo());
        model.addAttribute("totalPages", result.getTotalPages());
        model.addAttribute("apiError", result.isApiError());
        if (result.isApiError()) {
            model.addAttribute("errorMsg", result.getErrorMsg());
        }
        return "give/animal/list";
    }

    /** 유기견 상세 페이지 — desertionNo 로 Service.getAnimalDetail() 호출 */
    @GetMapping("/detail")
    public String animalDetail(@RequestParam String desertionNo, Model model) {
        try {
            model.addAttribute("animal", giveAnimalService.getAnimalDetail(desertionNo));
            model.addAttribute("apiError", false);
        } catch (Exception e) {
            e.printStackTrace();
            model.addAttribute("animal", null);
            model.addAttribute("apiError", true);
        }
        return "give/animal/detail";
    }

}