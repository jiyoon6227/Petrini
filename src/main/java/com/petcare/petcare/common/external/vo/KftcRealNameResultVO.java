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
