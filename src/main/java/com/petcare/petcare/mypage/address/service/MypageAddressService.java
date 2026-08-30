/**
 * 역할: 마이페이지 배송지록 비즈니스 로직 (interface)
 * 지윤 26.07.29 추가
 */
package com.petcare.petcare.mypage.address.service;

import java.util.List;
import com.petcare.petcare.mypage.address.vo.MypageAddressVO;

public interface MypageAddressService {

    //지윤 26.07.29 추가: 배송지 목록 조회
    List<MypageAddressVO> getAddressList(Long memberNo);

    //지윤 26.07.29 추가: 기본배송지 1건 조회 (없으면 null)
    MypageAddressVO getDefaultAddress(Long memberNo);

    //지윤 26.07.29 추가: 배송지 신규 등록. setDefault=true면 기존 기본배송지 해제 후 이걸 기본으로 지정
    void addAddress(Long memberNo, String recvName, String recvPhone, String zipCode,
                     String addr1, String addr2, boolean setDefault);

    //지윤 26.07.29 추가: 특정 배송지를 기본배송지로 지정 (기존 기본은 자동 해제)
    boolean selectAsDefault(Long addrId, Long memberNo);

    //지윤 26.07.29 추가: 배송지 수정
    boolean updateAddress(Long addrId, Long memberNo, String recvName, String recvPhone,
                           String zipCode, String addr1, String addr2);

    //지윤 26.07.29 추가: 배송지 삭제
    boolean deleteAddress(Long addrId, Long memberNo);
}