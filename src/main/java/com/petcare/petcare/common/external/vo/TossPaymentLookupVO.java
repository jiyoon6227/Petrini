package com.petcare.petcare.common.external.vo;

import lombok.Getter;

/** 토스 결제조회 API 결과 (취소 재처리 전 이미 취소됐는지 확인용) */
@Getter
public class TossPaymentLookupVO {

    private final boolean ok;       // 200 응답을 받았는지
    private final int httpStatus;   // 응답을 못 받았으면 0
    private final String status;    // 토스 결제상태 (DONE, CANCELED, PARTIAL_CANCELED ...)
    private final String message;   // 실패 시 사유

    public TossPaymentLookupVO(boolean ok, int httpStatus, String status, String message) {
        this.ok = ok;
        this.httpStatus = httpStatus;
        this.status = status;
        this.message = message;
    }

    public boolean isCanceled() {
        return ok && "CANCELED".equals(status);
    }
}
