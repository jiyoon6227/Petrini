/**
 * 역할: 사업자 컨트롤러 공통 헬퍼 (세션·권한 체크)
 *
 * 연결
 * - 상속: BizStoreController, BizStayController 등 사업자 Controller
 *
 * SQL·비즈니스 로직은 넣지 말 것 → Service로 위임
 * return 경로는 담당 JSP와 동일하게 맞출 것
 */
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
