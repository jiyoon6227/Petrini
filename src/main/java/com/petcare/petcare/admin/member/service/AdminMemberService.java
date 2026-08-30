/**
 * 역할: 관리자 회원 관리 비즈니스 로직 (interface)
 *
 * - 박유정 / 2026-07-16 (목록·상세), 2026-07-20 (STEP 7·8)
 *
 * 담당 화면
 * - admin/member/list.jsp     회원 목록
 * - admin/member/detail.jsp   회원 상세
 *
 * 구현 기능
 * - 회원 목록 조회 (검색·필터·페이징)
 * - 회원 상세 조회 (기본정보 + 활동현황 통계)
 * - 회원 상태 변경 — 정지·복구·강제탈퇴 (STEP 7)
 *
 * 연결
 * - 구현: AdminMemberServiceImpl
 * - 호출: AdminMemberController
 * - DB: AdminMemberMapper
 *
 * 참고 테이블
 * - TB_MEMBER
 * - TB_ORDER, TB_RESERVATION, TB_POST, TB_POST_REPORT (STEP 8 활동현황)
 * - TB_MEMBER_COUPON, TB_FAVORITE, TB_PET (STEP 8 활동현황)
 */

package com.petcare.petcare.admin.member.service;

import java.util.List;
import com.petcare.petcare.admin.member.vo.AdminMemberVO;

import com.petcare.petcare.admin.member.vo.AdminMemberPointVO;

import com.petcare.petcare.admin.member.vo.AdminMemberOrderVO;


public interface AdminMemberService {
    
    // 2026-07-16 박유정 — 관리자 회원 목록 (검색·필터·페이징)
    List<AdminMemberVO> getAdminMemberList(String keyword, String statusCd, String roleType, int page);
    
    // 2026-07-16 박유정 — 목록 총 건수
    int getAdminMemberCount(String keyword, String statusCd, String roleType);
    
    // 2026-07-16 박유정 — 관리자 회원 상세 (기본정보)
    AdminMemberVO getAdminMemberDetail(long memberNo);
   
    // 2026-07-20 박유정 STEP 7 — 계정 정지 (DAY3 / DAY7 / PERMANENT)
    void suspendMember(long memberNo, String suspendType);

    // 2026-07-20 박유정 STEP 7 — 계정 복구 (STATUS_CD = NORMAL)
    void restoreMember(long memberNo);

    // 2026-07-20 박유정 STEP 7 — 강제 탈퇴 (STATUS_CD = WITHDRAWN)
    void withdrawMember(long memberNo);

    // 2026-07-21 박유정 STEP 9 — 등급 변경 (GRADE_CD)
    void updateMemberGrade(long memberNo, String gradeCd);

    // 2026-07-21 박유정 STEP 10 — 포인트 이력 목록
    List<AdminMemberPointVO> getAdminMemberPointHistory(long memberNo);

    // 2026-07-21 박유정 STEP 10 — 포인트 지급·차감
    void adjustMemberPoint(long memberNo, String adjustType, int amount, String reason);

    // 2026-07-21 박유정 STEP 11 — 회원 최근 주문 목록
    List<AdminMemberOrderVO> getAdminMemberRecentOrders(long memberNo);
    
    // 2026-07-21 박유정 STEP 12 — 선택 회원 일괄 정지
    int bulkSuspendMembers(List<Long> memberNos, String suspendType);

    // 2026-07-21 박유정 STEP 12 — 선택 회원 일괄 탈퇴
    int bulkWithdrawMembers(List<Long> memberNos);

    // 2026-07-22 박유정 — 선택 회원 일괄 복구
    int bulkRestoreMembers(List<Long> memberNos);

    // 2026-07-21 박유정 — 회원 목록 CSV보내기
    void exportMemberCsv(String keyword, String statusCd, String roleType,
            java.io.OutputStream out) throws java.io.IOException;

    // 2026-07-21 박유정 — 기간 정지 만료 자동 복구
    void releaseExpiredSuspensions();
}
