package com.petcare.petcare.biz.controller;

import com.petcare.petcare.member.vo.MemberVO;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller("bizController")
@RequestMapping("/biz")
public class BizBaseController {

    public MemberVO getBizMember(HttpSession session) {
        MemberVO m = (MemberVO) session.getAttribute("memberInfo");
        if (m == null || !"BIZ".equals(m.getRole())) return null;
        return m;
    }
}
