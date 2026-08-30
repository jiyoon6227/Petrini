package com.petcare.petcare.biz.store.vo;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import lombok.NoArgsConstructor;

//지윤 26.07.23 사업자 정보 조회/수정용 VO
@Getter @Setter
@ToString
@NoArgsConstructor
public class BizInfoVO {
    private String shopName;      //지윤 26.07.23 추가: 상호명
    private String ceoName;
    private String bizRegNo;
    private String bizType;
    private String addr;
    private String addrDetail;
    private String phone;
    private String certFileUrl;   //현재 등록된 사업자등록증 URL (없으면 null)
    private String certFileName;  //현재 등록된 사업자등록증 원본파일명

    //2026/08/06 장우철 — 정산 계좌 (TB_BUSINESS.SETTLE_*)
    private String settleBank;
    private String settleBankCode;
    private String settleAccount;
    private String settleHolder;
    private String settleVerifyYn;
}