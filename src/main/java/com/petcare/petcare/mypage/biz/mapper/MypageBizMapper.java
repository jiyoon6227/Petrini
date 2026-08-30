/**
 * 역할: 마이페이지 사업자 DB 접근 (MyBatis interface)
 *
 * XML: resources/mybatis/mapper/mypage/biz/MypageBizMapper.xml
 * namespace: com.petcare.petcare.mypage.biz.mapper.MypageBizMapper
 *
 * 참고 테이블: TB_BUSINESS, TB_BUSINESS_AUTH
 */

package com.petcare.petcare.mypage.biz.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.biz.vo.BusinessVO;

@Mapper
public interface MypageBizMapper {

    public void insertBusiness(BusinessVO vo) throws Exception;

    public void insertBusinessAuth(BusinessVO vo) throws Exception;

    public BusinessVO selectBizAuthStatus(String bizId) throws Exception;

    // 2026-07-09 장우철 — 회원 이메일(BIZ_ID) 기준 TB_BUSINESS 1건
    // 이유: 재신청 시 INSERT 대신 UPDATE 판단용
    BusinessVO selectBusinessByBizId(@Param("bizId") String bizId) throws Exception;

    // 2026-07-09 장우철 — 반려 후 재신청 UPDATE
    // 이유: UK(BIZ_ID, BIZ_REG_NO) 충돌 없이 같은 행을 PENDING 으로 되돌림
    int updateBusinessForReapply(BusinessVO vo) throws Exception;

    // 2026-07-09 장우철 — 다른 사람이 쓰는 활성 사업자번호인지
    // 이유: 본인(bizId) 제외, PENDING/APPROVED 만 중복 체크
    int countActiveBizRegNo(@Param("bizRegNo") String bizRegNo,
                            @Param("bizId") String bizId) throws Exception;

    //HYJ 26.08.04 사업자번호 중복검사
    int countBizRegNo(@Param("bizRegNo") String bizRegNo) throws Exception;
}
