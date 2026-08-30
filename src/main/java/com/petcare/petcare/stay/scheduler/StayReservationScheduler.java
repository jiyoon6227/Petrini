/**
 * 역할: 숙소 예약 자동 DONE 스케줄러
 * 2026/07/31 장우철 — CHECKOUT + 체크아웃일 경과 → DONE (하루 1회 의미, 감지 주기 1분)
 * 2026/08/07 장우철 — DONE 전환 시 회원 알림
 */
package com.petcare.petcare.stay.scheduler;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.petcare.petcare.mypage.notify.service.MypageNotifyService;
import com.petcare.petcare.stay.mapper.StayMapper;
import com.petcare.petcare.stay.vo.ReservationVO;

@Component
public class StayReservationScheduler {

    private static final Logger log = LoggerFactory.getLogger(StayReservationScheduler.class);

    @Autowired
    private StayMapper stayMapper;

    @Autowired
    private MypageNotifyService mypageNotifyService;

    /**
     * 체크아웃일 &lt; 오늘 인 CHECKOUT 예약 → DONE
     * cron 매분 감지로 자정 넘어간 건을 하루 1회 처리 (중복 UPDATE 0건)
     */
    @Scheduled(cron = "0 * * * * *")
    public void autoCompleteStayReservations() {
        try {
            // 2026/08/07 장우철 — UPDATE 전에 대상 조회 후 알림
            List<ReservationVO> dueList = stayMapper.selectCheckoutDueForDone();
            int updatedCount = stayMapper.updateConfirmedToDone();
            if (updatedCount > 0) {
                log.info("[StayScheduler] 숙박 완료 자동 처리 — {}건 CHECKOUT → DONE", updatedCount);
            }
            if (dueList != null) {
                for (ReservationVO r : dueList) {
                    try {
                        String stayName = r.getStayName() != null && !r.getStayName().isBlank()
                                ? r.getStayName() : "숙소";
                        mypageNotifyService.sendStayDoneNotification(
                                r.getMemberNo(), stayName, r.getResvId());
                    } catch (Exception ne) {
                        log.warn("[StayScheduler] 이용완료 알림 실패 resvId={}", r.getResvId(), ne);
                    }
                }
            }
        } catch (Exception e) {
            log.error("[StayScheduler] 숙박 완료 자동 처리 실패", e);
        }
    }

    /**
     * HYJ 26.07.28 — 5분마다 실행
     * 생성 후 15분 경과한 PENDING 예약 → CANCEL 자동 취소
     * 결제 없이 이탈한 "유령 예약"을 정리하여 객실 가용성 복구
     */
    @Scheduled(fixedRate = 300000)
    public void cancelExpiredPendingReservations() {
        try {
            int cancelledCount = stayMapper.cancelExpiredPending();
            if (cancelledCount > 0) {
                log.info("[StayScheduler] 만료 PENDING 예약 자동 취소 — {}건 PENDING → CANCEL", cancelledCount);
            }
        } catch (Exception e) {
            log.error("[StayScheduler] 만료 PENDING 자동 취소 실패", e);
        }
    }
}
