/**
 * 역할: TB_HOSPITAL_RESV_HOLD 만료 행 주기 삭제
 * 2026/07/20 장우철 — hold 만료 배치 (#10)
 *
 * 연결
 * - HospitalService.cleanupExpiredHolds()
 * - PetcareApplication @EnableScheduling
 */
package com.petcare.petcare.hospital.scheduler;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.petcare.petcare.hospital.service.HospitalService;

@Component
public class HospitalResvHoldCleanupScheduler {

    @Autowired
    private HospitalService hospitalService;

    /** 2026/07/20 장우철 — 5분마다 EXPIRE_DATE 지난 hold 삭제 */
    @Scheduled(fixedDelayString = "${petcare.hospital.hold-cleanup-ms:300000}")
    public void purgeExpiredHolds() {
        try {
            int deleted = hospitalService.cleanupExpiredHolds();
            if (deleted > 0) {
                System.out.println("[hold-cleanup] 만료 선점 " + deleted + "건 삭제");
            }
        } catch (Exception e) {
            System.out.println("[hold-cleanup] 만료 선점 정리 실패: " + e.getMessage());
        }
    }
}
