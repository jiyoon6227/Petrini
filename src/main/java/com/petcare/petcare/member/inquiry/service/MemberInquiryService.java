/**
 * 역할: 1:1 문의 비즈니스 로직 (interface)
 * 2026/07/31 장우철 — 숙소 환불신청 추가
 */
package com.petcare.petcare.member.inquiry.service;

import java.util.List;
import java.util.Optional;

import com.petcare.petcare.member.vo.InquiryVO;
import com.petcare.petcare.member.vo.MemberVO;

public interface MemberInquiryService {

    List<InquiryVO> getListForMember(String memberId);

    List<InquiryVO> getListForMemberNo(Long memberNo);

    List<InquiryVO> getListForSessionMember(MemberVO member);

    Optional<InquiryVO> findForMember(String memberId, long id);

    Optional<InquiryVO> findForMemberNo(Long memberNo, long id);

    Optional<InquiryVO> findForSessionMember(MemberVO member, long id);

    InquiryVO create(MemberVO member, String category, String title, String content);

    InquiryVO create(MemberVO member, String category, String title, String content,
                     String refType, Long refId);

    InquiryVO createStayRefundInquiry(MemberVO member, Long resvId, String content);
}
