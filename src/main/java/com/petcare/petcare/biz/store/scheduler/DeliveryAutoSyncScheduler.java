/**
 * 배송상태 자동 동기화 스케줄러 (기본 비활성: @Component 주석 처리)
 * 스마트택배 무료 플랜 월 100건 제한 — 테스트 때만 @Component 활성화 후 재기동
 */
package com.petcare.petcare.biz.store.scheduler;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
 //import org.springframework.stereotype.Component;  //TEST시 이거 주석처리or해제 -> 실시간 변경
import org.springframework.scheduling.annotation.Scheduled;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.petcare.petcare.biz.store.mapper.BizStoreMapper;
import com.petcare.petcare.biz.store.service.BizStoreService;
import com.petcare.petcare.common.external.service.SmartTrackerService;

import lombok.extern.slf4j.Slf4j;

// 테스트할 때만 아래 줄 주석 풀기! 평소엔 반드시 주석 상태로 유지 (API 100건/월 제한 보호)
@Slf4j
 //@Component //TEST시 이거 주석처리or해제 -> 실시간 변경
public class DeliveryAutoSyncScheduler {

    @Autowired
    private BizStoreMapper bizStoreMapper;

    @Autowired
    private BizStoreService bizStoreService;

    @Autowired
    private SmartTrackerService smartTrackerService;

    // 테스트용 30초 주기 (실서비스는 30분 이상, API 월 100건 제한)
    //테스트 다 끝나면 30 * 60 * 1000(30분) 등으로 다시 늘려놓을 것
    @Scheduled(fixedDelay = 30 * 1000)
    public void syncDeliveryStatus() {
        List<Map<String, Object>> targets = bizStoreMapper.selectOrdersNeedingSync();
        log.info("배송상태 자동동기화 시작: 대상 {}건", targets.size());

        int successCount = 0;
        int failCount = 0;

        for (Map<String, Object> t : targets) {
            Long orderId = ((Number) t.get("ORDER_ID")).longValue();
            Long bizNo = ((Number) t.get("BIZ_NO")).longValue();
            String courierCode = (String) t.get("COURIER_CODE");
            String trackingNo = (String) t.get("TRACKING_NO");

            try {
                String json = smartTrackerService.getTrackingInfo(courierCode, trackingNo);
                JsonNode node = new ObjectMapper().readTree(json);
                int level = node.path("level").asInt(-1);

                if (level == 6) {
                    bizStoreService.autoCompleteDeliveryIfDone(orderId, bizNo);
                } else if (level >= 2) {
                    bizStoreService.autoElevateToShippingIfNeeded(orderId, bizNo);
                }
                successCount++;
            } catch (Exception e) {
                //한 건 실패해도 나머지 건 계속 처리되게 여기서 잡고 다음 건으로 넘어감
                failCount++;
                log.error("배송상태 자동동기화 실패 orderId={}, courierCode={}, trackingNo={}", orderId, courierCode, trackingNo, e);
            }
        }
        log.info("배송상태 자동동기화 종료: 성공 {}건, 실패 {}건", successCount, failCount);
    }
}