/**
 * 역할: TB_INQUIRY MyBatis
 * 2026/07/31 장우철
 */
package com.petcare.petcare.member.inquiry.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.member.inquiry.vo.MemberInquiryVO;

@Mapper
public interface MemberInquiryMapper {

    List<MemberInquiryVO> selectByMemberNo(@Param("memberNo") Long memberNo);

    MemberInquiryVO selectByIdAndMemberNo(@Param("inquiryId") Long inquiryId,
                                          @Param("memberNo") Long memberNo);

    int insertInquiry(MemberInquiryVO vo);

    int countOpenStayRefund(@Param("memberNo") Long memberNo, @Param("resvId") Long resvId);

    // 2026/08/06 장우철 — 거절·승인·레거시 DONE 완료 건수 (재신청 불가)
    int countRejectedStayRefund(@Param("memberNo") Long memberNo, @Param("resvId") Long resvId);

    // 2026-08-11 박유정 — 사업자 숙소 환불신청 대기 건수
    int countPendingStayRefundByStayId(@Param("stayId") Long stayId);

    // 2026/08/18 장우철 — 사업자 숙소 환불 탭별 건수
    int countStayRefundByStayId(@Param("stayId") Long stayId, @Param("statusCd") String statusCd);

    // 2026-08-11 박유정 — 사업자 숙소 환불신청 목록
    List<MemberInquiryVO> selectStayRefundListByStayId(@Param("stayId") Long stayId,
                                                       @Param("statusCd") String statusCd);

    // 관리자 — 숙소 환불(1:1) 목록
    List<MemberInquiryVO> selectStayRefundList(@Param("statusCd") String statusCd);

    MemberInquiryVO selectStayRefundDetail(@Param("inquiryId") Long inquiryId);

    int updateInquiryAnswer(@Param("inquiryId") Long inquiryId,
                            @Param("statusCd") String statusCd,
                            @Param("answer") String answer,
                            @Param("adminNo") Long adminNo);

    // 2026-08-11 박유정 — 관리자 일반 1:1 문의 (숙소 환불 제외)
    List<MemberInquiryVO> selectGeneralInquiryList(@Param("statusCd") String statusCd);
    MemberInquiryVO selectGeneralInquiryDetail(@Param("inquiryId") Long inquiryId);                        
}
