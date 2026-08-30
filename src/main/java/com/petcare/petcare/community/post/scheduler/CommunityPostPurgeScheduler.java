/**
 * 역할: STATUS_CD='DELETED' 후 7일 경과 LIFE 게시글 자동 물리 삭제
 * 2026-07-23 HYJ
 *
 * [동작]
 * - 매일 새벽 3시 실행 (cron)
 * - DELETE_DATE 기준 7일 경과한 STATUS_CD='DELETED' LIFE 게시글 조회
 * - 댓글 → 파일 → 게시글 순으로 물리 삭제
 *
 * 연결
 * - CommunityPostService.purgeExpiredDeletedPosts()
 * - PetcareApplication @EnableScheduling
 */
package com.petcare.petcare.community.post.scheduler;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.petcare.petcare.community.post.service.CommunityPostService;

@Component
public class CommunityPostPurgeScheduler {

    private static final Logger log = LoggerFactory.getLogger(CommunityPostPurgeScheduler.class);

    /** 삭제 후 물리 삭제까지 보관 일수 */
    private static final int RETENTION_DAYS = 7;

    private final CommunityPostService communityPostService;

    public CommunityPostPurgeScheduler(CommunityPostService communityPostService) {
        this.communityPostService = communityPostService;
    }

    /**
     * 매일 새벽 3시 — 7일 경과 DELETED LIFE 게시글 물리 삭제
     * (댓글·대댓글·파일 포함)
     */
    @Scheduled(cron = "0 0 3 * * *")
    public void purgeExpiredPosts() {
        try {
            int purged = communityPostService.purgeExpiredDeletedPosts(RETENTION_DAYS);
            if (purged > 0) {
                log.info("[community-purge] {}일 경과 DELETED 게시글 {}건 물리 삭제 완료",
                        RETENTION_DAYS, purged);
            }
        } catch (Exception e) {
            log.error("[community-purge] DELETED 게시글 정리 실패", e);
        }
    }
}
