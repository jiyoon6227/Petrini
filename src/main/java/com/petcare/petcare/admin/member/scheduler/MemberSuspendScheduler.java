/** 로그인 시 releaseExpiredSuspensions와 같은 처리 (미접속 회원용) */

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

    // 매일 0시 기간 정지 만료 회원 복구
    @Scheduled(cron = "0 0 0 * * *")
    public void releaseExpiredSuspensions() {
        adminMemberService.releaseExpiredSuspensions();
    }
}
