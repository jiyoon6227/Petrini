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