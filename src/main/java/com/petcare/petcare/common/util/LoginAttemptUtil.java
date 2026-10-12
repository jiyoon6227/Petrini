package com.petcare.petcare.common.util;

import java.time.LocalDateTime;
import java.util.concurrent.ConcurrentHashMap;
/* 로그인 실패 횟수는 메모리에 보관 (일시 데이터라 DB 부하 회피, 재시작 시 초기화 무방), 동시 접근 대비 ConcurrentHashMap */
public class LoginAttemptUtil {
    /** 최대 허용 실패 횟수 — 5회 초과 시 잠금 */
    private static final int MAX_ATTEMPTS = 5;

    /** 잠금 시간 (분) — 30분 후 자동 해제 */
    private static final int LOCK_MINUTES = 30;    

    private static final ConcurrentHashMap<String, AttemptInfo> attempts = new ConcurrentHashMap<>();

    public static boolean isLocked(String loginId) {
        AttemptInfo info = attempts.get(loginId);
        if (info == null || info.lockedAt == null)
            return false;
        
        if (info.lockedAt.plusMinutes(LOCK_MINUTES).isBefore(LocalDateTime.now())) {
            attempts.remove(loginId);
            return false;
        }

        return true;
    }

    public static void recordFailure(String loginId) {
        //키가 없으면 값을 생성하고, 있으면 기존 값을 반환
        AttemptInfo info = attempts.computeIfAbsent(loginId, k -> new AttemptInfo());
        info.failCount++;

        if (info.failCount >= MAX_ATTEMPTS) {
            info.lockedAt = LocalDateTime.now();
        }
    }

    public static void resetAttempts(String loginId) {
        attempts.remove(loginId);
    }

    public static int getRemainingAttempts(String loginId) {
        AttemptInfo info = attempts.get(loginId);
        if (info == null) {
            return MAX_ATTEMPTS;
        }

        if (info.lockedAt != null) {
            return 0;
        }

        return Math.max(0, MAX_ATTEMPTS - info.failCount);
    }

    public static long getRemainingLockMinutes(String loginId) {
        AttemptInfo info = attempts.get(loginId);
        if (info == null || info.lockedAt == null) {
            return 0;
        }

        LocalDateTime unlockAt = info.lockedAt.plusMinutes(LOCK_MINUTES);
        long remaining = java.time.Duration.between(LocalDateTime.now(), unlockAt).toMinutes();
        return Math.max(0, remaining);
    }


    private static class AttemptInfo {
        int failCount;
        LocalDateTime lockedAt;

        AttemptInfo() {
            this.failCount = 0;
            this.lockedAt = null;
        }
    }

}
