/**
 * 역할: 관리자 회원 DB 접근 (MyBatis interface)
 *
 * - 박유정 / 2026-07-16 (목록·상세), 2026-07-20 (STEP 7·8)
 *
 * XML: resources/mybatis/mapper/admin/member/AdminMemberMapper.xml
 * namespace: com.petcare.petcare.admin.member.mapper.AdminMemberMapper
 *
 * 쿼리 id
 * - selectAdminMemberList / selectAdminMemberCount
 * - selectAdminMemberDetail
 * - updateMemberStatus (STEP 7)
 * - selectAdminMemberActivityStats (STEP 8)
 *
 * 참고 테이블
 * - TB_MEMBER, TB_BUSINESS (역할 판별)
 * - TB_ORDER, TB_RESERVATION, TB_POST, TB_POST_REPORT (STEP 8)
 * - TB_MEMBER_COUPON, TB_FAVORITE, TB_PET (STEP 8)
 *
 * SQL은 XML에만 작성 (@Select 등 어노테이션 사용 X)
 * 메서드명은 Service에서 호출하는 이름과 동일하게
 */

package com.petcare.petcare.admin.member.mapper;

import org.apache.ibatis.annotations.Mapper;
import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.petcare.petcare.admin.member.vo.AdminMemberVO;

import com.petcare.petcare.admin.member.vo.AdminMemberPointVO;

import com.petcare.petcare.admin.member.vo.AdminMemberOrderVO;

import java.time.LocalDateTime;

@Mapper
public interface AdminMemberMapper {

    // 2026-07-16 박유정 — 관리자 회원 목록 (검색·필터·페이징)
    List<AdminMemberVO> selectAdminMemberList(
            @Param("keyword") String keyword,
            @Param("statusCd") String statusCd,
            @Param("roleType") String roleType,
            @Param("offset") int offset,
            @Param("limit") int limit);

    // 2026-07-16 박유정 — 목록 총 건수
    int selectAdminMemberCount(
            @Param("keyword") String keyword,
            @Param("statusCd") String statusCd,
            @Param("roleType") String roleType);

    // 2026-07-16 박유정 — 관리자 회원 상세
    AdminMemberVO selectAdminMemberDetail(@Param("memberNo") long memberNo);

    // 2026-07-20 박유정 STEP 7 — 회원 상태 변경
    int updateMemberStatus(
            @Param("memberNo") long memberNo,
            @Param("statusCd") String statusCd);

    // 2026-07-20 박유정 STEP 8 — 회원 활동 현황 통계
    AdminMemberVO selectAdminMemberActivityStats(@Param("memberNo") long memberNo);

    // 2026-07-21 박유정 STEP 9 — 회원 등급 변경
    int updateMemberGrade(
            @Param("memberNo") long memberNo,
            @Param("gradeCd") String gradeCd);


    // 2026-07-21 박유정 STEP 10 — 포인트 적립·사용 합계
    AdminMemberVO selectAdminMemberPointSummary(@Param("memberNo") long memberNo);
    // 2026-07-21 박유정 STEP 10 — 포인트 이력 목록
    List<AdminMemberPointVO> selectAdminMemberPointHistory(@Param("memberNo") long memberNo);
    // 2026-07-21 박유정 STEP 10 — 보유 포인트 증가
    int addMemberPointBalance(@Param("memberNo") long memberNo, @Param("amount") int amount);
    // 2026-07-21 박유정 STEP 10 — 보유 포인트 차감
    int subtractMemberPointBalance(@Param("memberNo") long memberNo, @Param("amount") int amount);
    // 2026-07-21 박유정 STEP 10 — 포인트 이력 INSERT
    int insertMemberPointHistory(
            @Param("memberNo") long memberNo,
            @Param("pointType") String pointType,
            @Param("pointAmount") int pointAmount,
            @Param("balanceAfter") int balanceAfter,
            @Param("reasonCd") String reasonCd,
            @Param("reasonDetail") String reasonDetail);

    // 2026-07-21 박유정 STEP 11 — 회원 최근 주문 목록
    List<AdminMemberOrderVO> selectAdminMemberRecentOrders(@Param("memberNo") long memberNo);

    // 2026-07-21 박유정 STEP 12 — 회원 상태 일괄 변경
    int updateMemberStatusBulk(
           @Param("memberNos") List<Long> memberNos,
           @Param("statusCd") String statusCd);

    // 2026-07-21 박유정 — 회원 목록 CSV보내기
    List<AdminMemberVO> selectAdminMemberListForExport(
           @Param("keyword") String keyword,
           @Param("statusCd") String statusCd,
           @Param("roleType") String roleType);

    // 2026-07-21 박유정 — 기간 정지
    int updateMemberSuspend(
           @Param("memberNo") long memberNo,
           @Param("suspendEndDate") LocalDateTime suspendEndDate);

    // 2026-07-21 박유정 — 복구 (종료일 NULL)
    int restoreMemberStatus(@Param("memberNo") long memberNo);

    // 2026-07-21 박유정 — 만료 정지 자동 복구
    int releaseExpiredSuspensions();
    
    // 2026-07-21 박유정 — 일괄 기간 정지
    int updateMemberSuspendBulk(
          @Param("memberNos") List<Long> memberNos,
          @Param("suspendEndDate") LocalDateTime suspendEndDate);

    // 2026-07-22 박유정 — 일괄 복구 (SUSPEND_END_DATE NULL)
    int restoreMemberStatusBulk(@Param("memberNos") List<Long> memberNos);
          
}