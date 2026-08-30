/**
 * 역할: 관리자 스케줄러 수동 실행 (QA·디버깅)
 * 2026/08/12 장우철 — ADMIN + CSRF, 정산 2건은 정산관리 버튼 사용
 */
package com.petcare.petcare.admin.scheduler.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.petcare.petcare.admin.controller.AdminBaseController;
import com.petcare.petcare.admin.member.scheduler.MemberSuspendScheduler;
import com.petcare.petcare.community.post.scheduler.CommunityPostPurgeScheduler;
import com.petcare.petcare.hospital.scheduler.HospitalResvHoldCleanupScheduler;
import com.petcare.petcare.main.banner.scheduler.BannerExpiryScheduler;
import com.petcare.petcare.mypage.account.scheduler.WithdrawPurgeScheduler;
import com.petcare.petcare.mypage.order.scheduler.AutoConfirmPurchaseScheduler;
import com.petcare.petcare.stay.scheduler.StayReservationScheduler;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/admin/scheduler")
public class AdminSchedulerController extends AdminBaseController {

    @Autowired
    private StayReservationScheduler stayReservationScheduler;

    @Autowired
    private AutoConfirmPurchaseScheduler autoConfirmPurchaseScheduler;

    @Autowired
    private BannerExpiryScheduler bannerExpiryScheduler;

    @Autowired
    private MemberSuspendScheduler memberSuspendScheduler;

    @Autowired
    private WithdrawPurgeScheduler withdrawPurgeScheduler;

    @Autowired
    private CommunityPostPurgeScheduler communityPostPurgeScheduler;

    @Autowired
    private HospitalResvHoldCleanupScheduler hospitalResvHoldCleanupScheduler;

    @GetMapping
    public String page(HttpSession session) {
        if (getAdmin(session) == null) {
            return redirectToLogin();
        }
        return "admin/scheduler/run";
    }

    @PostMapping("/run/{jobKey}")
    @ResponseBody
    public Map<String, Object> run(HttpSession session, @PathVariable("jobKey") String jobKey) {
        Map<String, Object> result = new HashMap<>();
        if (getAdmin(session) == null) {
            result.put("ok", false);
            result.put("message", "관리자 로그인이 필요합니다.");
            return result;
        }
        try {
            switch (jobKey) {
                case "stay-done" -> {
                    stayReservationScheduler.autoCompleteStayReservations();
                    result.put("message", "숙소 CHECKOUT→DONE 스케줄러 실행 완료. TB_RESERVATION·콘솔 로그 확인.");
                }
                case "stay-pending-cancel" -> {
                    stayReservationScheduler.cancelExpiredPendingReservations();
                    result.put("message", "숙소 PENDING 자동취소 스케줄러 실행 완료. TB_RESERVATION·콘솔 로그 확인.");
                }
                case "store-auto-confirm" -> {
                    autoConfirmPurchaseScheduler.autoConfirmPurchase();
                    result.put("message", "쇼핑 자동 구매확정 스케줄러 실행 완료. TB_ORDER_ITEM.CONFIRMED_AT·콘솔 확인.");
                }
                case "banner-expire" -> {
                    bannerExpiryScheduler.expirePastEndDateBanners();
                    result.put("message", "배너 기간만료 스케줄러 실행 완료. TB_BANNER STATUS 확인.");
                }
                case "member-suspend-release" -> {
                    memberSuspendScheduler.releaseExpiredSuspensions();
                    result.put("message", "회원 정지 만료 해제 스케줄러 실행 완료. TB_MEMBER STATUS 확인.");
                }
                case "withdraw-purge" -> {
                    withdrawPurgeScheduler.purgeExpiredWithdrawnMembers();
                    result.put("message", "탈퇴 회원 purge 스케줄러 실행 완료. TB_MEMBER·콘솔 로그 확인.");
                }
                case "community-purge" -> {
                    communityPostPurgeScheduler.purgeExpiredPosts();
                    result.put("message", "LIFE 게시글 purge 스케줄러 실행 완료. TB_POST 등 확인.");
                }
                case "hospital-hold-cleanup" -> {
                    hospitalResvHoldCleanupScheduler.purgeExpiredHolds();
                    result.put("message", "병원 예약 홀드 정리 스케줄러 실행 완료. TB_HOSPITAL_RESV_HOLD 확인.");
                }
                default -> {
                    result.put("ok", false);
                    result.put("message", "알 수 없는 jobKey: " + jobKey);
                    return result;
                }
            }
            result.put("ok", true);
        } catch (Exception e) {
            result.put("ok", false);
            result.put("message", e.getMessage() != null ? e.getMessage() : "스케줄러 실행 중 오류");
        }
        return result;
    }
}
