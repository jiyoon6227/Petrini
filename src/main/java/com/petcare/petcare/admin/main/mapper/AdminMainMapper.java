/**
 * 역할: 관리자 대시보드 DB 접근 (MyBatis interface)
 *
 * XML: resources/mybatis/mapper/admin/main/AdminMainMapper.xml
 * namespace: com.petcare.petcare.admin.main.mapper.AdminMainMapper
 *
 * - 상단 통계 카드 COUNT/SUM
 * - 최근주문·회원·매출차트
 * - 이번 달 통계 요약
 * - 차트 / 지난 달 조회
 *
 * 참고 테이블
 * - TB_MEMBER
 * - TB_ORDER
 * - TB_RESERVATION
 */

package com.petcare.petcare.admin.main.mapper;

import org.apache.ibatis.annotations.Mapper;

import java.util.List;

import com.petcare.petcare.admin.main.vo.AdminMainOrderVO;

import com.petcare.petcare.admin.main.vo.AdminMainSalesDayVO;

@Mapper
public interface AdminMainMapper {

        // 오늘 신규 가입자 (TB_MEMBER.JOIN_DATE = 오늘)
        int countTodayNewMembers();
        // 오늘 주문 건수 (TB_ORDER.ORDER_DATE = 오늘)
        int countTodayOrders();
        // 오늘 매출 합계 원 (TB_ORDER.PAY_AMOUNT, 취소 제외)
        long sumTodaySalesAmount();
        // 미처리 예약 (TB_RESERVATION STATUS PENDING + CONFIRMED)
        int countPendingReservations();

        // 최근 주문 5건 (TB_ORDER + TB_MEMBER)
        List<AdminMainOrderVO> selectRecentOrders();

        // 일반회원 (탈퇴 제외, 사업자 미승인)
        int countMemberGeneral();

        // 사업자 회원 (TB_BUSINESS APPROVED)
        int countMemberBiz();
    
        // 탈퇴 회원
        int countMemberWithdrawn();

        // 최근 7일 일별 매출 (TB_ORDER)
        List<AdminMainSalesDayVO> selectWeeklySales();

        // 월간 매출: 이번 달 1일~말일 (TB_ORDER)
        List<AdminMainSalesDayVO> selectMonthlySales();

        // 이번 달 총 매출 (TB_ORDER, 취소 제외)
        long sumMonthSalesAmount();
        
        // 이번 달 신규 가입 (TB_MEMBER.JOIN_DATE)
        int countMonthNewMembers();

        // 이번 달 예약 건수 (TB_RESERVATION.REG_DATE)
        int countMonthReservations();

        // 이번 달 주문 수 (TB_ORDER.ORDER_DATE)
        int countMonthOrders();
       
        // 최근 6개월 월별 매출 (TB_ORDER, 취소 제외)
        List<AdminMainSalesDayVO> selectLast6MonthsSales();

        // 최근 6개월 월별 신규 가입 (TB_MEMBER.JOIN_DATE)
        List<AdminMainSalesDayVO> selectLast6MonthsNewMembers();

        // 이번 달 업종별 예약/주문 (병원·숙소·쇼핑)
        List<AdminMainSalesDayVO> selectMonthCategoryResvOrderStats();

        // 지난 달 총 매출 (TB_ORDER, 취소 제외)
        long sumPrevMonthSalesAmount();

        // 지난 달 신규 가입 (TB_MEMBER.JOIN_DATE)
        int countPrevMonthNewMembers();

        // 지난 달 예약 건수 (TB_RESERVATION.REG_DATE)
        int countPrevMonthReservations();

        // 지난 달 주문 수 (TB_ORDER.ORDER_DATE)
        int countPrevMonthOrders();
}
