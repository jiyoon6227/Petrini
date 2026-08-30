/**
 * 역할: 탈퇴 7일 경과 회원 개인정보 자동 삭제 (스케줄)
 *
 * - 매일 자정(00:00) 실행
 * - STATUS_CD = 'WITHDRAWN' 이고 JOIN_DATE + 7일 경과 회원 대상
 * - 개인정보 익명화 + 관련 테이블 삭제
 *
 * 연결
 * - MypageAccountService.purgeExpiredWithdrawnMembers()
 * - PetcareApplication @EnableScheduling
 */

package com.petcare.petcare.mypage.account.scheduler;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.petcare.petcare.mypage.account.service.MypageAccountService;

@Component
public class WithdrawPurgeScheduler {

    private static final Logger log = LoggerFactory.getLogger(WithdrawPurgeScheduler.class);

    private final MypageAccountService mypageAccountService;

    public WithdrawPurgeScheduler(MypageAccountService mypageAccountService) {
        this.mypageAccountService = mypageAccountService;
    }

    // 매일 자정 실행
    @Scheduled(cron = "0 0 0 * * *")
    public void purgeExpiredWithdrawnMembers() {
        log.info("=== 탈퇴 회원 개인정보 삭제 스케줄러 시작 ===");
        int count = mypageAccountService.purgeExpiredWithdrawnMembers();
        log.info("=== 탈퇴 회원 개인정보 삭제 스케줄러 완료: {}명 처리 ===", count);
    }
}
