package com.petcare.petcare.admin.member.service;

import java.util.List;
import com.petcare.petcare.admin.member.vo.AdminMemberVO;

import com.petcare.petcare.admin.member.vo.AdminMemberPointVO;

import com.petcare.petcare.admin.member.vo.AdminMemberOrderVO;


public interface AdminMemberService {
    
    // 관리자 회원 목록 (검색·필터·페이징)
    List<AdminMemberVO> getAdminMemberList(String keyword, String statusCd, String roleType, int page);
    
    // 목록 총 건수
    int getAdminMemberCount(String keyword, String statusCd, String roleType);
    
    // 관리자 회원 상세 (기본정보)
    AdminMemberVO getAdminMemberDetail(long memberNo);
   
    // 계정 정지 (DAY3 / DAY7 / PERMANENT)
    void suspendMember(long memberNo, String suspendType);

    // 계정 복구 (STATUS_CD = NORMAL)
    void restoreMember(long memberNo);

    // 강제 탈퇴 (STATUS_CD = WITHDRAWN)
    void withdrawMember(long memberNo);

    // 등급 변경 (GRADE_CD)
    void updateMemberGrade(long memberNo, String gradeCd);

    // 포인트 이력 목록
    List<AdminMemberPointVO> getAdminMemberPointHistory(long memberNo);

    // 포인트 지급·차감
    void adjustMemberPoint(long memberNo, String adjustType, int amount, String reason);

    // 회원 최근 주문 목록
    List<AdminMemberOrderVO> getAdminMemberRecentOrders(long memberNo);
    
    // 선택 회원 일괄 정지
    int bulkSuspendMembers(List<Long> memberNos, String suspendType);

    // 선택 회원 일괄 탈퇴
    int bulkWithdrawMembers(List<Long> memberNos);

    // 선택 회원 일괄 복구
    int bulkRestoreMembers(List<Long> memberNos);

    // 회원 목록 CSV보내기
    void exportMemberCsv(String keyword, String statusCd, String roleType,
            java.io.OutputStream out) throws java.io.IOException;

    // 기간 정지 만료 자동 복구
    void releaseExpiredSuspensions();
}
