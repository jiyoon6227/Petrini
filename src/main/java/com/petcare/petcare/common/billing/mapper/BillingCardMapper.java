/**
 * 2026/07/27 장우철 — TB_BILLING_CARD DB 접근 (MyBatis)
 *
 * XML: resources/mybatis/mapper/common/billing/BillingCardMapper.xml
 * namespace: com.petcare.petcare.common.billing.mapper.BillingCardMapper
 *
 * 쿼리
 * - selectBillingCardList   : 소유자 활성 카드 목록
 * - selectBillingCard       : PK 단건 조회
 * - insertBillingCard       : 카드(빌링키) 등록
 * - deleteBillingCard       : 논리삭제 (STATUS_CD=DELETED)
 *
 * SQL은 XML에만 작성 (@Select 등 어노테이션 사용 X)
 */
package com.petcare.petcare.common.billing.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.common.billing.vo.BillingCardVO;

@Mapper
public interface BillingCardMapper {

    // 2026/07/27 장우철 — 소유자(MEMBER/ADMIN) 활성 카드 목록
    List<BillingCardVO> selectBillingCardList(@Param("ownerType") String ownerType,
                                              @Param("ownerNo") Long ownerNo);

    // 2026/07/27 장우철 — PK 단건 조회 (삭제·결제 전 소유권 확인용)
    BillingCardVO selectBillingCard(@Param("billingCardId") Long billingCardId);

    // 2026/07/27 장우철 — 빌링키 저장 (등록)
    int insertBillingCard(BillingCardVO vo);

    // 2026/07/27 장우철 — 논리삭제 (STATUS_CD = DELETED)
    int deleteBillingCard(@Param("billingCardId") Long billingCardId);
}
