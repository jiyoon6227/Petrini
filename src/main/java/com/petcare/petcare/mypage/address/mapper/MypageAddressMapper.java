package com.petcare.petcare.mypage.address.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import com.petcare.petcare.mypage.address.vo.MypageAddressVO;

@Mapper
public interface MypageAddressMapper {

    // 배송지 목록 전체 조회 (기본배송지 먼저, 그다음 최신순)
    List<MypageAddressVO> selectAddressList(@Param("memberNo") Long memberNo);

    // 기본배송지 1건 조회 (없으면 null, 주문서 프리필용)
    MypageAddressVO selectDefaultAddress(@Param("memberNo") Long memberNo);

    // 다음 ADDR_ID 미리 조회 (SEQ_TB_MEMBER_ADDRESS로 번호를 먼저 받아 둠)
    Long selectNextAddrId();

    // 배송지 신규 등록
    void insertAddress(@Param("addrId") Long addrId, @Param("memberNo") Long memberNo,
                        @Param("recvName") String recvName, @Param("recvPhone") String recvPhone,
                        @Param("zipCode") String zipCode, @Param("addr1") String addr1, @Param("addr2") String addr2,
                        @Param("isDefault") String isDefault);

    // 이 회원의 기존 기본배송지를 전부 N으로 해제 (새 기본배송지 지정 전 선행 처리)
    void clearDefaultAddress(@Param("memberNo") Long memberNo);

    // 특정 배송지를 기본배송지(Y)로 지정 (본인 소유 주소인지 memberNo로 같이 체크)
    int setDefaultAddress(@Param("addrId") Long addrId, @Param("memberNo") Long memberNo);

    // 배송지 수정 (본인 소유 주소인지 memberNo로 같이 체크)
    int updateAddress(@Param("addrId") Long addrId, @Param("memberNo") Long memberNo,
                       @Param("recvName") String recvName, @Param("recvPhone") String recvPhone,
                       @Param("zipCode") String zipCode, @Param("addr1") String addr1, @Param("addr2") String addr2);

    // 배송지 삭제 (본인 소유 주소인지 memberNo로 같이 체크)
    int deleteAddress(@Param("addrId") Long addrId, @Param("memberNo") Long memberNo);
}