package com.petcare.petcare.mypage.address.vo;

public class MypageAddressVO {

    private Long addrId;
    private Long memberNo;
    private String recvName;
    private String recvPhone;
    private String zipCode;
    private String addr1;
    private String addr2;
    private String isDefault;   // 'Y' / 'N'

    public Long getAddrId() { return addrId; }
    public void setAddrId(Long addrId) { this.addrId = addrId; }
    public Long getMemberNo() { return memberNo; }
    public void setMemberNo(Long memberNo) { this.memberNo = memberNo; }
    public String getRecvName() { return recvName; }
    public void setRecvName(String recvName) { this.recvName = recvName; }
    public String getRecvPhone() { return recvPhone; }
    public void setRecvPhone(String recvPhone) { this.recvPhone = recvPhone; }
    public String getZipCode() { return zipCode; }
    public void setZipCode(String zipCode) { this.zipCode = zipCode; }
    public String getAddr1() { return addr1; }
    public void setAddr1(String addr1) { this.addr1 = addr1; }
    public String getAddr2() { return addr2; }
    public void setAddr2(String addr2) { this.addr2 = addr2; }
    public String getIsDefault() { return isDefault; }
    public void setIsDefault(String isDefault) { this.isDefault = isDefault; }
}
