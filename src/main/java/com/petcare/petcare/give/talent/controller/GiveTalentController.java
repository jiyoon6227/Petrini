/**
 * 역할: 재능나눔 URL 처리 → JSP 반환 (가족찾기 Give 모듈)
 *
 * - 박유정 / 2026-07-13~14
 *
 * 담당 화면
 * - give/talent/list.jsp   APPROVED 재능나눔 목록
 * - give/talent/detail.jsp APPROVED 재능나눔 상세
 *
 * 연결
 * - Service: GiveTalentService
 *
 * SQL·비즈니스 로직은 넣지 말 것 → Service로 위임
 * return 경로는 담당 JSP와 동일하게 맞출 것
 */

package com.petcare.petcare.give.talent.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.petcare.petcare.give.talent.service.GiveTalentService;
import com.petcare.petcare.give.talent.vo.GiveTalentVO;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import com.petcare.petcare.give.talent.vo.GiveTalentApplyVO;
import com.petcare.petcare.member.vo.MemberVO;
import jakarta.servlet.http.HttpSession;

@Controller("giveTalentController")
@RequestMapping("/give/talent")
public class GiveTalentController {

    private final GiveTalentService giveTalentService;

    public GiveTalentController(GiveTalentService giveTalentService) {
        this.giveTalentService = giveTalentService;
    }

    /**
     * 재능나눔 목록 — APPROVED(승인)만 노출
     * talentType: GROOMING / HOSPITAL / PHOTO / TRANSPORT / ETC (빈값=전체)
     * 2026-07-13 박유정 — admin 승인 후 TB_TALENT STATUS_CD=APPROVED 건만 조회
     */
    @GetMapping("/list")
    public String talentList(
            @RequestParam(defaultValue = "") String talentType,
            Model model) {

        String type = talentType != null ? talentType.trim() : "";

        model.addAttribute("list", giveTalentService.getApprovedTalentList(type));
        model.addAttribute("talentType", type);

        return "give/talent/list";
    }

/**
 * 재능나눔 상세 — APPROVED(모집중) 또는 DONE(모집마감) 글 노출
 * 2026-08-10 박유정 — myApply, recruitmentOpen 추가 (STEP 4)
 */
@GetMapping("/detail")
public String talentDetail(@RequestParam long id,
                           Model model,
                           HttpSession session) {
    GiveTalentVO talent = giveTalentService.getTalentDetail(id);
    if (talent == null || talent.getStatusCd() == null) {
        return "redirect:/give/talent/list";
    }

    String status = talent.getStatusCd().trim().toUpperCase();
    // PENDING, REJECTED 는 사용자에게 안 보임
    if (!"APPROVED".equals(status) && !"DONE".equals(status)) {
        return "redirect:/give/talent/list";
    }

    model.addAttribute("talent", talent);
    model.addAttribute("recruitmentOpen", giveTalentService.isRecruitmentOpen(talent));
    model.addAttribute("recruitmentLabel", giveTalentService.getRecruitmentStatusLabel(talent));

    // 로그인했으면 내 신청 여부 조회
    MemberVO member = (MemberVO) session.getAttribute("memberInfo");
    GiveTalentApplyVO myApply = null;
    if (member != null && member.getMemberNo() != null) {
        myApply = giveTalentService.getMyApply(id, member.getMemberNo());
    }
    model.addAttribute("myApply", myApply);
    model.addAttribute("isLoggedIn", member != null);

    return "give/talent/detail";
}

/**
 * 일반 회원 참여 신청
 * POST /give/talent/apply
 * 2026-08-10 박유정 — STEP 4
 */
@PostMapping("/apply")
public String applyTalent(@RequestParam long talentId,
                          @RequestParam(required = false) String message,
                          HttpSession session,
                          RedirectAttributes rttr) {
    MemberVO member = (MemberVO) session.getAttribute("memberInfo");
    if (member == null || member.getMemberNo() == null) {
        return "redirect:/login";
    }

    try {
        giveTalentService.applyForTalent(member.getMemberNo(), talentId, message);
        rttr.addFlashAttribute("msg", "참여 신청이 완료되었습니다.");
    } catch (IllegalStateException e) {
        String err = "신청할 수 없습니다.";
        switch (e.getMessage()) {
            case "TALENT_NOT_FOUND" -> err = "재능나눔을 찾을 수 없습니다.";
            case "TALENT_NOT_OPEN"  -> err = "모집이 마감되었습니다.";
            case "ALREADY_APPLIED"  -> err = "이미 신청하셨습니다.";
            default -> { }
        }
        rttr.addFlashAttribute("errorMsg", err);
    }

    return "redirect:/give/talent/detail?id=" + talentId;
}
}