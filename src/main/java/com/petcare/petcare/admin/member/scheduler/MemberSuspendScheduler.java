/**
 * 역할: 기간 정지 만료 회원 자동 복구 (스케줄)
 *
 * - 박유정 / 2026-07-21
 *
 * 매일 0시 TB_MEMBER.SUSPEND_END_DATE 만료 건 → STATUS_CD = NORMAL
 * (로그인 시 releaseExpiredSuspensions 와 동일 로직, 미접속 회원 처리용)
 *
 * 연결
 * - AdminMemberService.releaseExpiredSuspensions()
 * - PetcareApplication @EnableScheduling
 */

package com.petcare.petcare.admin.member.scheduler;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.petcare.petcare.admin.member.service.AdminMemberService;

@Component
public class MemberSuspendScheduler {

    private final AdminMemberService adminMemberService;

    public MemberSuspendScheduler(AdminMemberService adminMemberService) {
        this.adminMemberService = adminMemberService;
    }

    // 2026-07-21 박유정 — 매일 0시 기간 정지 만료 회원 복구
    @Scheduled(cron = "0 0 0 * * *")
    public void releaseExpiredSuspensions() {
        adminMemberService.releaseExpiredSuspensions();
    }
}
