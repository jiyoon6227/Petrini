/**
 * 역할: 마이페이지 알림 URL 처리 → Service 호출 → JSP 반환
 */

package com.petcare.petcare.mypage.notify.controller;

import com.petcare.petcare.member.vo.MemberVO;
import com.petcare.petcare.mypage.notify.service.MypageNotifyService;
import com.petcare.petcare.mypage.notify.vo.MypageNotifyVO;

import jakarta.servlet.http.HttpSession;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/mypage")
public class MypageNotifyController {

    @Autowired
    private MypageNotifyService mypageNotifyService;

    // 2026-07-09 장우철 — [변경 후] TB_NOTIFICATION 목록 연동
    @GetMapping("/notifications")
    public String notifications(HttpSession session, Model model) {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null)
            return "redirect:/login";

        List<MypageNotifyVO> list = mypageNotifyService.getNotificationList(member.getMemberNo());
        model.addAttribute("list", list);
        return "mypage/notifications";

        /* [변경 전] 2026-07-09 장우철 — 더미 JSP 만 반환
        return "mypage/notifications";
        */
    }

    // 2026-07-09 장우철 — [변경 후] notiId 기준 상세 + 읽음 처리
    @GetMapping("/notifications/detail")
    public String notificationDetail(@RequestParam Long notiId,
                                     HttpSession session,
                                     Model model) {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null)
            return "redirect:/login";

        MypageNotifyVO noti = mypageNotifyService.getNotificationDetail(notiId, member.getMemberNo());
        if (noti == null) {
            return "redirect:/mypage/notifications";
        }
        model.addAttribute("noti", noti);
        return "mypage/notification-detail";

        /* [변경 전] 2026-07-09 장우철 — param.type 더미 분기만
        return "mypage/notification-detail";
        */
    }

    // 2026-07-10 장우철 — 알림함 전체 읽음
    @PostMapping("/notifications/read-all")
    public String readAllNotifications(HttpSession session, RedirectAttributes rttr) {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null) {
            return "redirect:/login";
        }
        int count = mypageNotifyService.markAllNotificationsRead(member.getMemberNo());
        rttr.addFlashAttribute("msg", count > 0 ? "모든 알림을 읽음 처리했습니다." : "읽지 않은 알림이 없습니다.");
        return "redirect:/mypage/notifications";
    }

    // 2026-07-10 장우철 — 알림함 전체 삭제
    @PostMapping("/notifications/delete-all")
    public String deleteAllNotifications(HttpSession session, RedirectAttributes rttr) {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null) {
            return "redirect:/login";
        }
        int count = mypageNotifyService.deleteAllNotifications(member.getMemberNo());
        rttr.addFlashAttribute("msg", count > 0 ? "모든 알림을 삭제했습니다." : "삭제할 알림이 없습니다.");
        return "redirect:/mypage/notifications";
    }

    // 2026/07/11 장우철 — 헤더 미읽음 알림 배지 (장바구니 /store/cart/count 와 동일 패턴)
    @GetMapping("/notifications/count")
    @ResponseBody
    public int unreadNotificationCount(HttpSession session) {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null || member.getMemberNo() == null) {
            return 0;
        }
        return mypageNotifyService.countUnreadNotifications(member.getMemberNo());
    }
}
