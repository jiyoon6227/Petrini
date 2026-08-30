/**
 * 역할: 아이디·비밀번호 찾기 URL 처리 → Service 호출 → JSP 반환
 *
 * 연결
 * - Service: MemberFindService
 *
 * SQL·비즈니스 로직은 넣지 말 것 → Service로 위임
 * return 경로는 담당 JSP와 동일하게 맞출 것
 */

package com.petcare.petcare.member.find.controller;

import java.util.LinkedHashMap;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.petcare.petcare.member.find.service.MemberFindService;

@Controller
public class MemberFindController {

    private final MemberFindService memberFindService;

    public MemberFindController(MemberFindService memberFindService) {
        this.memberFindService = memberFindService;
    }

    /** 아이디 찾기 페이지 */
    @GetMapping("/find/id")
    public String findId() {
        return "member/find-id";
    }

    /** 비밀번호 찾기 페이지 */
    @GetMapping("/find/pw")
    public String findPw() {
        return "member/find-pw";
    }

    /**
     * 아이디 찾기 (AJAX)
     * POST /find/id
     */
    @PostMapping("/find/id")
    @ResponseBody
    public Map<String, Object> findIdPost(@RequestParam String memberName,
                                           @RequestParam String phone) {
        String maskedEmail = memberFindService.findMemberId(memberName, phone);
        if (maskedEmail == null) {
            return result(false, "일치하는 회원 정보가 없습니다.", null);
        }
        return result(true, null, maskedEmail);
    }

    /**
     * 비밀번호 찾기 (AJAX)
     * POST /find/pw
     */
    @PostMapping("/find/pw")
    @ResponseBody
    public Map<String, Object> findPwPost(@RequestParam String email,
                                           @RequestParam String memberName) {
        String error = memberFindService.resetPassword(email, memberName);
        if (error != null) {
            return result(false, error, null);
        }
        return result(true, "임시 비밀번호가 이메일로 발송되었습니다.", null);
    }

    private Map<String, Object> result(boolean ok, String msg, Object data) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("ok", ok);
        if (msg != null) m.put("msg", msg);
        if (data != null) m.put("data", data);
        return m;
    }
}
