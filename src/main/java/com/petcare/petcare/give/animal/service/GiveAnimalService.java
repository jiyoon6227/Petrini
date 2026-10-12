package com.petcare.petcare.give.animal.service;

import com.petcare.petcare.give.animal.vo.GiveAnimalListResult;
import com.petcare.petcare.give.vo.AbandonmentVO;

public interface GiveAnimalService {

    /** 검색 조건으로 유기견 목록 가져오기 */
    GiveAnimalListResult getAnimalList(String sido, String upkind, String state, int pageNo);

    /** 유기번호로 유기견 1마리 상세 가져오기 */
    AbandonmentVO getAnimalDetail(String desertionNo) throws Exception;
}
