/**
 * 역할: MypageAddressService 구현체
 * 지윤 26.07.29 추가
 */
package com.petcare.petcare.mypage.address.service;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.petcare.petcare.mypage.address.mapper.MypageAddressMapper;
import com.petcare.petcare.mypage.address.vo.MypageAddressVO;

@Service
public class MypageAddressServiceImpl implements MypageAddressService {

    @Autowired
    private MypageAddressMapper mypageAddressMapper;

    @Override
    public List<MypageAddressVO> getAddressList(Long memberNo) {
        return mypageAddressMapper.selectAddressList(memberNo);
    }

    @Override
    public MypageAddressVO getDefaultAddress(Long memberNo) {
        return mypageAddressMapper.selectDefaultAddress(memberNo);
    }

    //지윤 26.07.29 추가: 기본배송지로 등록 시, 기존 기본배송지 해제 -> 신규 INSERT 순서로 처리
    @Override
    @Transactional
    public void addAddress(Long memberNo, String recvName, String recvPhone, String zipCode,
                            String addr1, String addr2, boolean setDefault) {
        if (setDefault) {
            mypageAddressMapper.clearDefaultAddress(memberNo);
        }
        Long addrId = mypageAddressMapper.selectNextAddrId();
        // 2026/08/11 장우철 — 배송지 전화 하이픈 정규화
        String phone = com.petcare.petcare.common.util.PhoneNormalizeUtil.toHyphenPhone(recvPhone);
        mypageAddressMapper.insertAddress(addrId, memberNo, recvName, phone, zipCode, addr1, addr2,
                setDefault ? "Y" : "N");
    }

    //지윤 26.07.29 추가: 기존 기본배송지 해제 -> 선택한 배송지를 기본으로 지정
    @Override
    @Transactional
    public boolean selectAsDefault(Long addrId, Long memberNo) {
        mypageAddressMapper.clearDefaultAddress(memberNo);
        return mypageAddressMapper.setDefaultAddress(addrId, memberNo) > 0;
    }

    //지윤 26.07.29 추가: 배송지 수정
    @Override
    public boolean updateAddress(Long addrId, Long memberNo, String recvName, String recvPhone,
                                  String zipCode, String addr1, String addr2) {
        String phone = com.petcare.petcare.common.util.PhoneNormalizeUtil.toHyphenPhone(recvPhone);
        return mypageAddressMapper.updateAddress(addrId, memberNo, recvName, phone, zipCode, addr1, addr2) > 0;
    }

    //지윤 26.07.29 추가: 배송지 삭제
    @Override
    public boolean deleteAddress(Long addrId, Long memberNo) {
        return mypageAddressMapper.deleteAddress(addrId, memberNo) > 0;
    }
}