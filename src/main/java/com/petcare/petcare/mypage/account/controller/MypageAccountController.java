/**
 * 역할: 마이페이지 회원정보 URL 처리 → Service 호출 → JSP 반환
 *
 * - 2026-08-04 박유정 — 프로필 사진 업로드 POST /mypage/edit/profile-image
 * - 2026/08/06 장우철 — yeju merge: 회원정보·비밀번호 AJAX + 유정 프로필 사진 공존
 *
 * 연결
 * - Service: MypageAccountService
 *
 * SQL·비즈니스 로직은 넣지 말 것 → Service로 위임
 * return 경로는 담당 JSP와 동일하게 맞출 것
 */

package com.petcare.petcare.mypage.account.controller;

import java.util.LinkedHashMap;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.petcare.petcare.member.vo.MemberVO;
import com.petcare.petcare.mypage.account.service.MypageAccountService;
import com.petcare.petcare.mypage.account.vo.MypageAccountVO;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/mypage")
public class MypageAccountController {

    private final MypageAccountService mypageAccountService;

    public MypageAccountController(MypageAccountService mypageAccountService) {
        this.mypageAccountService = mypageAccountService;
    }

    // 2026-07-28 박유정 — 회원정보 수정 (DB에서 최신 프로필 조회)
    @GetMapping("/edit")
    public String edit(HttpSession session, Model model) {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null || member.getMemberNo() == null) {
            return "redirect:/login";
        }

        MypageAccountVO profile = mypageAccountService.getMemberProfile(member.getMemberNo());
        model.addAttribute("profile", profile);

        return "mypage/edit";
    }

    /**
     * 회원정보 수정 처리 (AJAX) — 닉네임·전화·주소
     * POST /mypage/edit
     */
    @PostMapping("/edit")
    @ResponseBody
    public Map<String, Object> editPost(@RequestParam String nickname,
                                         @RequestParam String phone,
                                         @RequestParam(required = false, defaultValue = "") String zipcode,
                                         @RequestParam(required = false, defaultValue = "") String addr1,
                                         @RequestParam(required = false, defaultValue = "") String addr2,
                                         HttpSession session) {

        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null || member.getMemberNo() == null) {
            return apiFail("로그인이 필요합니다.");
        }

        MypageAccountVO vo = new MypageAccountVO();
        vo.setMemberNo(member.getMemberNo());
        vo.setNickname(nickname);
        vo.setPhone(phone);
        vo.setZipcode(zipcode);
        vo.setAddr1(addr1);
        vo.setAddr2(addr2);

        String error = mypageAccountService.updateProfile(vo);
        if (error != null) {
            return apiFail(error);
        }

        member.setNickname(nickname);
        member.setPhone(phone);
        member.setZipcode(zipcode);
        member.setAddr1(addr1);
        member.setAddr2(addr2);

        return apiOk("회원정보가 수정되었습니다.");
    }

    // 2026-08-04 박유정 — 프로필 사진 저장 (multipart)
    // 2026/08/06 장우철 — yeju AJAX /edit 과 분리 → /edit/profile-image
    @PostMapping("/edit/profile-image")
    public String editProfileImage(
            @RequestParam(value = "profileImage", required = false) MultipartFile profileImage,
            HttpSession session,
            RedirectAttributes rttr) {

        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null || member.getMemberNo() == null) {
            return "redirect:/login";
        }

        if (profileImage != null && !profileImage.isEmpty()) {
            try {
                String url = mypageAccountService.updateProfileImage(member.getMemberNo(), profileImage);
                member.setProfileImgUrl(url);
                session.setAttribute("memberInfo", member);
                rttr.addFlashAttribute("msg", "프로필 사진이 변경되었습니다.");
            } catch (IllegalArgumentException e) {
                rttr.addFlashAttribute("errorMsg", e.getMessage());
            } catch (Exception e) {
                rttr.addFlashAttribute("errorMsg", "사진 저장에 실패했습니다.");
            }
        }

        return "redirect:/mypage/edit";
    }

    /**
     * 비밀번호 변경 (AJAX)
     * POST /mypage/change-password
     */
    @PostMapping("/change-password")
    @ResponseBody
    public Map<String, Object> changePassword(@RequestParam String currentPassword,
                                               @RequestParam String newPassword,
                                               @RequestParam String confirmPassword,
                                               HttpSession session) {

        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null || member.getMemberNo() == null) {
            return apiFail("로그인이 필요합니다.");
        }

        if (!newPassword.equals(confirmPassword)) {
            return apiFail("새 비밀번호가 일치하지 않습니다.");
        }

        String error = mypageAccountService.changePassword(
                member.getMemberNo(), currentPassword, newPassword);
        if (error != null) {
            return apiFail(error);
        }

        return apiOk("비밀번호가 변경되었습니다.");
    }

    // HYJ 2026/07/29 — 회원 탈퇴
    /** 탈퇴 페이지 (GET /mypage/withdraw) */
    @GetMapping("/withdraw")
    public String withdraw(HttpSession session) {
        if (session.getAttribute("memberInfo") == null)
            return "redirect:/login";
        return "mypage/withdraw";
    }

    /** 탈퇴 처리 (POST /mypage/withdraw) */
    @PostMapping("/withdraw")
    @ResponseBody
    public String withdrawPost(@RequestParam String password, HttpSession session) {

        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null) {
            return "ERROR:로그인이 필요합니다.";
        }

        String error = mypageAccountService.withdraw(member.getMemberNo(), password);
        if (error != null) {
            return "ERROR:" + error;
        }

        session.invalidate();
        return "OK";
    }

    private Map<String, Object> apiOk(Object data) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("ok", true);
        m.put("msg", data);
        return m;
    }

    private Map<String, Object> apiFail(String msg) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("ok", false);
        m.put("msg", msg);
        return m;
    }
}
