/**
 * 역할: 가족찾기(Give) 탭바 건수 공통 주입 (give/index.jsp)
 * - 곽지윤 / 2026-09-23 — 재능나눔 탭 건수 추가, 재능나눔 페이지에서 분실·보호 0 표시 버그 수정
 */
package com.petcare.petcare.give.controller;

import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

import com.petcare.petcare.give.report.service.GiveReportService;
import com.petcare.petcare.give.talent.service.GiveTalentService;

@ControllerAdvice(basePackages = "com.petcare.petcare.give")
public class GiveTabCountAdvice {

    private final GiveReportService giveReportService;
    private final GiveTalentService giveTalentService;

    public GiveTabCountAdvice(GiveReportService giveReportService,
                              GiveTalentService giveTalentService) {
        this.giveReportService = giveReportService;
        this.giveTalentService = giveTalentService;
    }

    @ModelAttribute
    public void addTabCounts(Model model) {
        model.addAttribute("reportCount", giveReportService.getReportCount());
        model.addAttribute("talentCount", giveTalentService.getApprovedTalentCount());
    }
}