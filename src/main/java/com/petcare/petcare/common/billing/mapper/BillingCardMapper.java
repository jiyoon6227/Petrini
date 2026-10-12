package com.petcare.petcare.common.billing.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.common.billing.vo.BillingCardVO;

@Mapper
public interface BillingCardMapper {

    // 소유자(MEMBER/ADMIN) 활성 카드 목록
    List<BillingCardVO> selectBillingCardList(@Param("ownerType") String ownerType,
                                              @Param("ownerNo") Long ownerNo);

    // PK 단건 조회 (삭제·결제 전 소유권 확인용)
    BillingCardVO selectBillingCard(@Param("billingCardId") Long billingCardId);

    // 빌링키 저장 (등록)
    int insertBillingCard(BillingCardVO vo);

    // 논리삭제 (STATUS_CD = DELETED)
    int deleteBillingCard(@Param("billingCardId") Long billingCardId);
}
