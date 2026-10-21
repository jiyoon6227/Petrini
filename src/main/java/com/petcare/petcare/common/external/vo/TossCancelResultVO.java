package com.petcare.petcare.common.external.vo;

import lombok.Getter;

/** 토스 결제취소 API 결과 (상태코드·토스 에러코드·메시지·결과 구분) */
@Getter
public class TossCancelResultVO {

    public enum ResultType {
        SUCCESS,          // 취소 성공
        ALREADY_CANCELED, // 이미 취소된 결제 (성공으로 취급)
        RETRYABLE,        // 타임아웃·네트워크 오류·5xx·409 처리중 → 다시 시도 가능
        NOT_RETRYABLE     // 그 외 4xx → 같은 요청을 다시 보내도 실패
    }

    private final ResultType type;
    private final int httpStatus;   // 응답을 못 받았으면 0
    private final String errorCode; // 토스 에러코드 (성공이면 null)
    private final String message;

    public TossCancelResultVO(ResultType type, int httpStatus, String errorCode, String message) {
        this.type = type;
        this.httpStatus = httpStatus;
        this.errorCode = errorCode;
        this.message = message;
    }

    /** SUCCESS 또는 ALREADY_CANCELED 면 환불된 상태 */
    public boolean isCanceled() {
        return type == ResultType.SUCCESS || type == ResultType.ALREADY_CANCELED;
    }

    public boolean isRetryable() {
        return type == ResultType.RETRYABLE;
    }

    /** 로그·LAST_ERROR 저장용 한 줄 요약 */
    public String toSummary() {
        return type + " (HTTP " + httpStatus
                + (errorCode != null && !errorCode.isBlank() ? ", " + errorCode : "")
                + ") " + (message != null ? message : "");
    }
}
