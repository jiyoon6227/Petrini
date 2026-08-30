/**
 * 역할: 고객센터 URL 처리 → Service 호출 → JSP 반환
 *
 * 연결
 * - Service: MemberCsService
 *
 * SQL·비즈니스 로직은 넣지 말 것 → Service로 위임
 * return 경로는 담당 JSP와 동일하게 맞출 것
 */

package com.petcare.petcare.member.cs.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.petcare.petcare.member.cs.service.MemberCsService;

import com.petcare.petcare.admin.cms.vo.NoticeVO;

@Controller
public class MemberCsController {

    private final MemberCsService memberCsService;
    public MemberCsController(MemberCsService memberCsService) {
        this.memberCsService = memberCsService;
    }
  
    @GetMapping("/member/cs")
    public String cs(Model model) {
        model.addAttribute("faqList", memberCsService.getVisibleFaqList());
        model.addAttribute("noticeList", memberCsService.getVisibleNoticeList());
        return "member/cs";
    }

    // 2026/08/11 장우철 — 공지 상세: noticeId만 넘기면 JSP에서 비어 보임 → 노출 공지 조회
    @GetMapping("/member/cs/notice")
    public String csNotice(@RequestParam(defaultValue = "1") String id, Model model) {
        Long noticeId = null;
        try {
            noticeId = Long.parseLong(id.trim());
        } catch (NumberFormatException ignored) {
            // id 파싱 실패 시 notice=null → JSP "찾을 수 없음" 표시
        }
        model.addAttribute("noticeId", id);
        model.addAttribute("notice", memberCsService.getVisibleNoticeDetail(noticeId));
        return "member/cs-notice";
    }
}
