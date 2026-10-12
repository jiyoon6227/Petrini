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
