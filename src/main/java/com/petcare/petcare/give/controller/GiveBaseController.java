/**
 * 역할: 나눔(Give) 모듈 공통 헬퍼 (유기동물 공공 API 호출)
 *
 * 연결
 * - 상속: GiveAnimalController, GiveReportController
 *
 * SQL·비즈니스 로직은 넣지 말 것 → Service로 위임
 * return 경로는 담당 JSP와 동일하게 맞출 것
 *
 * - 박유정 / 2026-07-06 — 재능나눔은 /give/talent 별도 (GiveTalentController)
 */
package com.petcare.petcare.give.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller("giveController")
@RequestMapping("/give")
public class GiveBaseController {

    @GetMapping({"", "/"})
    public String give() {
        return "redirect:/give/animal/list";
    }
}
