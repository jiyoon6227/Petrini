/**
 * 역할: 사업자·재능나눔 승인 URL 처리 → Service 호출 → JSP 반환
 *
 * - 박유정 / 2026-07-13~14 (재능나눔 승인)
 * - 장우철 / 2026-07-09 (사업자 승인)
 *
 * 연결
 * - Service: AdminBizService, GiveTalentService
 * - 상속: AdminBaseController (관리자 로그인 체크)
 *
 * SQL·비즈니스 로직은 넣지 말 것 → Service로 위임
 */

package com.petcare.petcare.admin.biz.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.petcare.petcare.admin.biz.service.AdminBizService;
import com.petcare.petcare.admin.controller.AdminBaseController;
import com.petcare.petcare.biz.vo.BizCouponVO;
import com.petcare.petcare.biz.vo.BusinessVO;

import jakarta.servlet.http.HttpSession;

import com.petcare.petcare.give.talent.service.GiveTalentService;
import com.petcare.petcare.member.auth.mapper.MemberAuthMapper;
import com.petcare.petcare.member.auth.service.EmailService;
import com.petcare.petcare.member.auth.vo.MemberAuthVO;
import com.petcare.petcare.member.vo.MemberVO;
import com.petcare.petcare.mypage.biz.mapper.MypageBizMapper;

@Controller("adminBizController")
@RequestMapping("/admin/biz")
public class AdminBizController extends AdminBaseController {

    // 2026-07-09 장우철 — 사업자 승인 Service 주입
    // 이유: 목록/상세/승인·반려는 Controller 가 아닌 Service·Mapper 에서 처리
    @Autowired
    private AdminBizService adminBizService;

    // 2026-07-13 박유정 — 재능나눔 승인 Service (admin/biz/talent.jsp)
    @Autowired
    private GiveTalentService giveTalentService;

    // HYJ 26.07.28 사업자승인 이메일 안내발송
    @Autowired
    private EmailService emailService;
    @Autowired
    private MypageBizMapper mypageBizMapper;
    @Autowired
    private MemberAuthMapper memberAuthMapper;


    // ── ADMIN-03 사업자 승인 ───────────────────────────────
    @GetMapping("/list")
    public String bizList(HttpSession session,
                          @RequestParam(defaultValue = "PENDING") String status,
                          @RequestParam(defaultValue = "ALL") String bizType,
                          Model model) {
        if (getAdmin(session) == null)
            return redirectToLogin();

        // 2026-07-09 장우철 — 상태 탭별 실데이터 목록 + 탭 건수
        // 2026/07/28 장우철 — APPROVED(승인/관리) 일 때만 업종 필터 적용
        String typeFilter = "APPROVED".equals(status) ? bizType : "ALL";
        model.addAttribute("list", adminBizService.getBizApplyList(status, typeFilter));
        model.addAttribute("status", status);
        model.addAttribute("bizType", typeFilter);
        model.addAttribute("statusCounts", adminBizService.getBizStatusCounts());
        return "admin/biz/list";
    }

    // ── 재능나눔 승인 (2026-07-13 박유정) ─────────────────────────────
    // 이유: biz/hospital/talent.jsp 신청(PENDING) → 관리자 검토 → APPROVED 시 /give/talent/list 노출
    @GetMapping("/talent")
    public String cmsTalent(HttpSession session,
                            @RequestParam(defaultValue = "PENDING") String status,
                            Model model) {
    if (getAdmin(session) == null) return redirectToLogin();

    model.addAttribute("list", giveTalentService.getTalentListByStatus(status));
    model.addAttribute("status", status);
    model.addAttribute("statusCounts", giveTalentService.getTalentStatusCounts());
    return "admin/biz/talent";
    }

    @GetMapping("/detail")
    public String bizDetail(HttpSession session,
                            @RequestParam Long bizNo,
                            Model model,
                            RedirectAttributes redirectAttr) {
        if (getAdmin(session) == null)
            return redirectToLogin();

        // 2026-07-09 장우철 — [변경 전] JSP 더미 상세만 반환
        // return "admin/biz/detail";

        // 2026-07-09 장우철 — [변경 후] bizNo 기준 상세 + 제출 서류
        var biz = adminBizService.getBizApplyDetail(bizNo);
        if (biz == null) {
            redirectAttr.addFlashAttribute("errorMsg", "신청 정보를 찾을 수 없습니다.");
            return "redirect:/admin/biz/list";
        }
        model.addAttribute("biz", biz);
        model.addAttribute("authFiles", adminBizService.getBizAuthFiles(bizNo));
        model.addAttribute("licenseFiles", adminBizService.getBizLicenseFiles(bizNo));
        return "admin/biz/detail";
    }

    // 2026-07-09 장우철 — 사업자 승인 POST
    // 이유: detail/list 에서 form submit 으로 TB_BUSINESS·TB_BUSINESS_AUTH 를 APPROVED 로 변경
    @PostMapping("/approve")
    public String approveBiz(HttpSession session,
                             @RequestParam Long bizNo,
                             @RequestParam String bizId,
                             RedirectAttributes redirectAttr) {
        if (getAdmin(session) == null)
            return redirectToLogin();

        try {
            adminBizService.approveBiz(bizNo);

            //HYJ 26.07.28 이메일 안내
            BusinessVO existing = mypageBizMapper.selectBusinessByBizId(bizId);
            String email = existing.getEmail();
            if (email == null || email.isEmpty()) {
                MemberAuthVO found = memberAuthMapper.selectMemberByLoginId(existing.getBizId());
                if (found != null) {
                    email = found.getEmail();
                }
            }

            emailService.sendApproveNotice(email, existing.getBizName());

            redirectAttr.addFlashAttribute("successMsg", "사업자 신청이 승인되었습니다.");
            return "redirect:/admin/biz/list?status=APPROVED";
        } catch (IllegalStateException e) {
            if ("BIZ_NOT_PENDING".equals(e.getMessage())) {
                redirectAttr.addFlashAttribute("errorMsg", "이미 처리된 신청입니다.");
            } else {
                redirectAttr.addFlashAttribute("errorMsg", "승인 처리 중 오류가 발생했습니다.");
            }
        } catch (Exception e) {
            redirectAttr.addFlashAttribute("errorMsg", "승인 처리 중 오류가 발생했습니다.");
        }
        return "redirect:/admin/biz/detail?bizNo=" + bizNo;
    }

    // 2026-07-09 장우철 — 사업자 반려 POST
    @PostMapping("/reject")
    public String rejectBiz(HttpSession session,
                            @RequestParam Long bizNo,
                             @RequestParam String bizId,
                             @RequestParam String rejectReason,
                            RedirectAttributes redirectAttr) {
        if (getAdmin(session) == null)
            return redirectToLogin();

        try {
            adminBizService.rejectBiz(bizNo, rejectReason);

            //HYJ 26.07.28 이메일 안내
            BusinessVO existing = mypageBizMapper.selectBusinessByBizId(bizId);
            String email = existing.getEmail();
            if (email == null || email.isEmpty()) {
                MemberAuthVO found = memberAuthMapper.selectMemberByLoginId(existing.getBizId());
                if (found != null) {
                    email = found.getEmail();
                }
            }

            emailService.sendRejectNotice(email, existing.getBizName(), rejectReason);

            redirectAttr.addFlashAttribute("successMsg", "사업자 신청이 반려되었습니다.");
            return "redirect:/admin/biz/list?status=REJECTED";
        } catch (IllegalArgumentException e) {
            if ("REJECT_REASON_REQUIRED".equals(e.getMessage())) {
                redirectAttr.addFlashAttribute("errorMsg", "반려 사유를 입력해 주세요.");
            } else if ("BIZ_NOT_FOUND".equals(e.getMessage())) {
                redirectAttr.addFlashAttribute("errorMsg", "신청 정보를 찾을 수 없습니다.");
            } else {
                redirectAttr.addFlashAttribute("errorMsg", "반려 처리 중 오류가 발생했습니다.");
            }
        } catch (IllegalStateException e) {
            if ("BIZ_NOT_PENDING".equals(e.getMessage())) {
                redirectAttr.addFlashAttribute("errorMsg", "이미 처리된 신청입니다.");
            } else {
                redirectAttr.addFlashAttribute("errorMsg", "반려 처리 중 오류가 발생했습니다.");
            }
        } catch (Exception e) {
            redirectAttr.addFlashAttribute("errorMsg", "반려 처리 중 오류가 발생했습니다.");
        }
        return "redirect:/admin/biz/detail?bizNo=" + bizNo;
    }

    // 2026-07-14 박유정 — 재능나눔 승인 POST
    // 이유: admin.getAdminNo() 사용 (TB_ADMIN 로그인 세션 — memberNo 아님)
    @PostMapping("/talent/approve") 
    public String approveTalent(HttpSession session,
                            @RequestParam Long talentId,
                            RedirectAttributes redirectAttr) {
    MemberVO admin = getAdmin(session);
    if (admin == null) return redirectToLogin();

    try {
        giveTalentService.approveTalent(talentId, admin.getAdminNo());
        redirectAttr.addFlashAttribute("successMsg", "재능나눔이 승인되었습니다.");
        return "redirect:/admin/biz/talent?status=APPROVED";
    } catch (Exception e) {
        redirectAttr.addFlashAttribute("errorMsg", "승인 처리 중 오류가 발생했습니다.");
        return "redirect:/admin/biz/talent?status=PENDING";
    }
}

    // 2026-07-14 박유정 — 재능나눔 반려 POST
    @PostMapping("/talent/reject")
    public String rejectTalent(HttpSession session,
                           @RequestParam Long talentId,
                           @RequestParam String rejectReason,
                           RedirectAttributes redirectAttr) {
        MemberVO admin = getAdmin(session);
        if (admin == null) return redirectToLogin();

        if (rejectReason == null || rejectReason.isBlank()) {
            redirectAttr.addFlashAttribute("errorMsg", "반려 사유를 입력해 주세요.");
            return "redirect:/admin/biz/talent?status=PENDING";
        }

        try {
            giveTalentService.rejectTalent(talentId, rejectReason.trim(), admin.getAdminNo());
            redirectAttr.addFlashAttribute("successMsg", "재능나눔이 반려되었습니다.");
            return "redirect:/admin/biz/talent?status=REJECTED";
        } catch (Exception e) {
            redirectAttr.addFlashAttribute("errorMsg", "반려 처리 중 오류가 발생했습니다.");
            return "redirect:/admin/biz/talent?status=PENDING";
        }
    }

    //HYJ 26.07.29 쿠폰관리
    // ── 쿠폰 승인 목록 ──
    @GetMapping("/coupon/list")
    public String couponList(HttpSession session,
                             @RequestParam(defaultValue = "review") String tab,
                             @RequestParam(required = false) String status,
                             Model model) {
        if (getAdmin(session) == null) return redirectToLogin();

        // 2026-08-13 박유정 — review / published(ACTIVE) / exhausted(EXHAUSTED)
        if (!"published".equals(tab) && !"exhausted".equals(tab)) {
            tab = "review";
        }

        List<BizCouponVO> list = adminBizService.getCouponListByTab(tab, status);
        Map<String, Integer> tabCounts = adminBizService.getCouponTabCounts();

        if ("review".equals(tab)) {
            if (status == null || status.isBlank()) {
                status = "PENDING";
            }
            if (!"PENDING".equals(status) && !"REJECTED".equals(status)) {
                status = "PENDING";
            }
        }

        model.addAttribute("list", list);
        model.addAttribute("tab", tab);
        model.addAttribute("status", status != null ? status : "PENDING");
        model.addAttribute("tabCounts", tabCounts);
        return "admin/biz/coupon";
    }

    // ── 쿠폰 승인 POST ──
    @PostMapping("/coupon/approve")
    public String approveCoupon(HttpSession session,
                                @RequestParam Long couponId,
                                RedirectAttributes rttr) {
        if (getAdmin(session) == null) return redirectToLogin();

        try {
            adminBizService.approveCoupon(couponId);
            rttr.addFlashAttribute("successMsg", "쿠폰이 승인되었습니다.");
            	
return "redirect:/admin/biz/coupon/list?tab=published";
        } catch (IllegalStateException e) {
            if ("NOT_PENDING".equals(e.getMessage())) {
                rttr.addFlashAttribute("errorMsg", "이미 처리된 쿠폰입니다.");
            } else {
                rttr.addFlashAttribute("errorMsg", "승인 처리 중 오류가 발생했습니다.");
            }
        } catch (Exception e) {
            rttr.addFlashAttribute("errorMsg", "승인 처리 중 오류가 발생했습니다.");
        }
        return "redirect:/admin/biz/coupon/list?tab=review&status=PENDING";
    }

    // ── 쿠폰 반려 POST ──
    @PostMapping("/coupon/reject")
    public String rejectCoupon(HttpSession session,
                                @RequestParam Long couponId,
                                @RequestParam String rejectReason,
                                RedirectAttributes rttr) {
        if (getAdmin(session) == null) return redirectToLogin();

        try {
            adminBizService.rejectCoupon(couponId, rejectReason);
            rttr.addFlashAttribute("successMsg", "쿠폰이 반려되었습니다.");
            return "redirect:/admin/biz/coupon/list?tab=review&status=REJECTED";
        } catch (IllegalArgumentException e) {
            if ("REJECT_REASON_REQUIRED".equals(e.getMessage())) {
                rttr.addFlashAttribute("errorMsg", "반려 사유를 입력해 주세요.");
            } else {
                rttr.addFlashAttribute("errorMsg", "반려 처리 중 오류가 발생했습니다.");
            }
        } catch (IllegalStateException e) {
            if ("NOT_PENDING".equals(e.getMessage())) {
                rttr.addFlashAttribute("errorMsg", "이미 처리된 쿠폰입니다.");
            } else {
                rttr.addFlashAttribute("errorMsg", "반려 처리 중 오류가 발생했습니다.");
            }
        } catch (Exception e) {
            rttr.addFlashAttribute("errorMsg", "반려 처리 중 오류가 발생했습니다.");
        }
        	
return "redirect:/admin/biz/coupon/list?tab=review&status=PENDING";
    }
}
