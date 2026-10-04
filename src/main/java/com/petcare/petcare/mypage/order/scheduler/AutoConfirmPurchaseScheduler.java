/**
 * 지윤 26.07.30 추가: 구매확정 자동처리 스케줄러
 * 지윤 26.10.05 수정: System.out.println -> @Slf4j 로그로 변경 (레벨/시각/클래스 기록, 실패 시 스택트레이스 포함)
 *
 * 역할: 배송완료(DONE) 후 7일이 지나도록 유저가 구매확정 버튼을 안 눌렀으면
 *      자동으로 구매확정 처리하고 포인트를 적립해줌
 *
 * 매일 새벽 3시에 1회 실행 (부하 적은 시간대)
 * @EnableScheduling은 PetcareApplication에 이미 켜져있음
 *
 * 연결
 * - Mapper: MypageOrderMapper.selectOrdersNeedingAutoConfirm()
 * - Service: MypageOrderService.confirmPurchase() (구매확정 버튼 눌렀을 때와 동일 로직 재사용)
 */
package com.petcare.petcare.mypage.order.scheduler;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.petcare.petcare.mypage.order.mapper.MypageOrderMapper;
import com.petcare.petcare.mypage.order.service.MypageOrderService;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
public class AutoConfirmPurchaseScheduler {

    @Autowired
    private MypageOrderMapper mypageOrderMapper;

    @Autowired
    private MypageOrderService mypageOrderService;

    //사용자 트랙픽이 가장 적은 시간대 -> 매일 새벽 3시 실행 (초 분 시 일 월 요일) DB데이터 긁어옴
    @Scheduled(cron = "0 0 3 * * *")
    public void autoConfirmPurchase() {
        List<Map<String, Object>> targets = mypageOrderMapper.selectOrdersNeedingAutoConfirm();
        log.info("구매확정 자동처리 시작: 대상 {}건", targets.size());

        int successCount = 0;
        int failCount = 0;

        for (Map<String, Object> t : targets) {
            Long orderId = ((Number) t.get("ORDER_ID")).longValue();
            Long memberNo = ((Number) t.get("MEMBER_NO")).longValue();

            try {
                mypageOrderService.confirmPurchase(memberNo, orderId);
                successCount++;
            } catch (Exception e) {
                //한 건 실패해도 나머지 건 계속 처리되게 여기서 잡고 다음 건으로 넘어감
                failCount++;
                log.error("구매확정 자동처리 실패 orderId={}, memberNo={}", orderId, memberNo, e);
            }
        }
        log.info("구매확정 자동처리 종료: 성공 {}건, 실패 {}건", successCount, failCount);
    }
}