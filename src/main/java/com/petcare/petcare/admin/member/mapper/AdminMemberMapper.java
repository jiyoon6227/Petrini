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

    // 관리자 회원 목록 (검색·필터·페이징)
    List<AdminMemberVO> selectAdminMemberList(
            @Param("keyword") String keyword,
            @Param("statusCd") String statusCd,
            @Param("roleType") String roleType,
            @Param("offset") int offset,
            @Param("limit") int limit);

    // 목록 총 건수
    int selectAdminMemberCount(
            @Param("keyword") String keyword,
            @Param("statusCd") String statusCd,
            @Param("roleType") String roleType);

    // 관리자 회원 상세
    AdminMemberVO selectAdminMemberDetail(@Param("memberNo") long memberNo);

    // 회원 상태 변경
    int updateMemberStatus(
            @Param("memberNo") long memberNo,
            @Param("statusCd") String statusCd);

    // 회원 활동 현황 통계
    AdminMemberVO selectAdminMemberActivityStats(@Param("memberNo") long memberNo);

    // 회원 등급 변경
    int updateMemberGrade(
            @Param("memberNo") long memberNo,
            @Param("gradeCd") String gradeCd);


    // 포인트 적립·사용 합계
    AdminMemberVO selectAdminMemberPointSummary(@Param("memberNo") long memberNo);
    // 포인트 이력 목록
    List<AdminMemberPointVO> selectAdminMemberPointHistory(@Param("memberNo") long memberNo);
    // 보유 포인트 증가
    int addMemberPointBalance(@Param("memberNo") long memberNo, @Param("amount") int amount);
    // 보유 포인트 차감
    int subtractMemberPointBalance(@Param("memberNo") long memberNo, @Param("amount") int amount);
    // 포인트 이력 INSERT
    int insertMemberPointHistory(
            @Param("memberNo") long memberNo,
            @Param("pointType") String pointType,
            @Param("pointAmount") int pointAmount,
            @Param("balanceAfter") int balanceAfter,
            @Param("reasonCd") String reasonCd,
            @Param("reasonDetail") String reasonDetail);

    // 회원 최근 주문 목록
    List<AdminMemberOrderVO> selectAdminMemberRecentOrders(@Param("memberNo") long memberNo);

    // 회원 상태 일괄 변경
    int updateMemberStatusBulk(
           @Param("memberNos") List<Long> memberNos,
           @Param("statusCd") String statusCd);

    // 회원 목록 CSV보내기
    List<AdminMemberVO> selectAdminMemberListForExport(
           @Param("keyword") String keyword,
           @Param("statusCd") String statusCd,
           @Param("roleType") String roleType);

    // 기간 정지
    int updateMemberSuspend(
           @Param("memberNo") long memberNo,
           @Param("suspendEndDate") LocalDateTime suspendEndDate);

    // 복구 (종료일 NULL)
    int restoreMemberStatus(@Param("memberNo") long memberNo);

    // 만료 정지 자동 복구
    int releaseExpiredSuspensions();
    
    // 일괄 기간 정지
    int updateMemberSuspendBulk(
          @Param("memberNos") List<Long> memberNos,
          @Param("suspendEndDate") LocalDateTime suspendEndDate);

    // 일괄 복구 (SUSPEND_END_DATE NULL)
    int restoreMemberStatusBulk(@Param("memberNos") List<Long> memberNos);
          
}