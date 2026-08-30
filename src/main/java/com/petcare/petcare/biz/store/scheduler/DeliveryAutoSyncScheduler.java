/**
 * 지윤 26.07.28 추가: 배송상태 자동 폴링 스케줄러
 *
 * 역할: SHIPPING(또는 PAID/READY인데 송장이 이미 등록된) 주문들을 주기적으로 돌면서
 *      스마트택배 API로 실제 배송상태를 확인하고, 자동으로 DB 상태를 갱신함
 *      (배송관리 화면에서 사람이 [배송조회]를 직접 눌러야만 동기화되던 것을, 스케줄러가 대신 해주는 버전)
 *
 * ⚠️ 기본값: 비활성화 상태 (@Component 주석처리됨)
 *    이유: 스마트택배 무료 플랜은 월 100건 제한이라, 이 스케줄러를 켜두면
 *          API 호출이 자동으로 계속 발생해서 순식간에 할당량을 다 씀.
 *    테스트하고 싶을 때만 아래 @Component 주석을 풀고 재기동 -> 테스트 끝나면 반드시 다시 주석처리 후 재기동.
 *    (@EnableScheduling 자체는 PetcareApplication에 이미 켜져있음 - 박유정님이 다른 스케줄러용으로 추가해둠)
 *
 * 연결
 * - Mapper: BizStoreMapper.selectOrdersNeedingSync()
 * - Service: SmartTrackerService.getTrackingInfo(), BizStoreService.autoElevateToShippingIfNeeded()/autoCompleteDeliveryIfDone()
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

// 지윤 26.07.28: 테스트할 때만 아래 줄 주석 풀기! 평소엔 반드시 주석 상태로 유지 (API 100건/월 제한 보호)
 //@Component //TEST시 이거 주석처리or해제 -> 실시간 변경
public class DeliveryAutoSyncScheduler {

    @Autowired
    private BizStoreMapper bizStoreMapper;

    @Autowired
    private BizStoreService bizStoreService;

    @Autowired
    private SmartTrackerService smartTrackerService;

    //지윤 26.07.28 수정: 테스트용으로 30초마다 실행 (평소/실서비스라면 30분 이상으로 늘려야 함 - API 100건/월 제한 때문)
    //테스트 다 끝나면 30 * 60 * 1000(30분) 등으로 다시 늘려놓을 것
    @Scheduled(fixedDelay = 30 * 1000)
    public void syncDeliveryStatus() {
        List<Map<String, Object>> targets = bizStoreMapper.selectOrdersNeedingSync();
        System.out.println("===== 배송상태 자동동기화 시작: 대상 " + targets.size() + "건 =====");

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
            } catch (Exception e) {
                //한 건 실패해도 나머지 건 계속 처리되게 여기서 잡고 다음 건으로 넘어감
                System.out.println("===== 배송상태 자동동기화 실패 (orderId=" + orderId + "): " + e.getMessage() + " =====");
            }
        }
        System.out.println("===== 배송상태 자동동기화 종료 =====");
    }
}