/**
 * 역할: 유기견 목록 조회 결과 VO
 *
 * - 박유정 / 2026-07-06
 * - 목록 결과를 model 에 여러 개로 나눠 넣지 않고 한 덩어리로 넘기려고 만듦
 *
 * animals     : 유기견 카드 목록
 * totalCount  : 전체 몇 마리인지
 * pageNo      : 지금 몇 페이지인지
 * totalPages  : 페이지가 총 몇 개인지
 * apiError    : API 오류 났는지 (true/false)
 * errorMsg    : 오류 메시지
 */

package com.petcare.petcare.give.animal.vo;

import java.util.ArrayList;
import java.util.List;

import com.petcare.petcare.give.vo.AbandonmentVO;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@ToString
@NoArgsConstructor
public class GiveAnimalListResult {

    private List<AbandonmentVO> animals = new ArrayList<>();
    private int totalCount;
    private int pageNo = 1;
    private int totalPages;
    private boolean apiError;
    private String errorMsg;

    /** API 오류 났을 때 쓰는 간단한 만들기 방법 */
    public static GiveAnimalListResult error(String message) {
        GiveAnimalListResult result = new GiveAnimalListResult();
        result.apiError = true;
        result.errorMsg = message;
        return result;
    }
}
