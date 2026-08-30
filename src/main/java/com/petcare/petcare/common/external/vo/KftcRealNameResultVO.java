/**
 * 2026/07/28 장우철 — 금결원 계좌실명조회 결과 VO
 */
package com.petcare.petcare.common.external.vo;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class KftcRealNameResultVO {
    private boolean success;
    private boolean mock;
    private String bankCodeStd;
    private String bankName;
    private String accountNum;
    private String accountHolderName;
    private String message;
}
