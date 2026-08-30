/**
 * 역할: 유기동물 API 비즈니스 로직 (interface)
 *
 * - 박유정 / 2026-07-06
 * - Controller 에 있던 API 호출을 Service 로 분리
 * - 목록·상세 조회 메서드 정의
 */

package com.petcare.petcare.give.animal.service;

import com.petcare.petcare.give.animal.vo.GiveAnimalListResult;
import com.petcare.petcare.give.vo.AbandonmentVO;

public interface GiveAnimalService {

    /** 검색 조건으로 유기견 목록 가져오기 */
    GiveAnimalListResult getAnimalList(String sido, String upkind, String state, int pageNo);

    /** 유기번호로 유기견 1마리 상세 가져오기 */
    AbandonmentVO getAnimalDetail(String desertionNo) throws Exception;
}
