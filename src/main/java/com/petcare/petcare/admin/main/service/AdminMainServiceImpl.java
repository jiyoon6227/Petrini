/**
 * 역할: AdminMainService 구현체 (@Service)
 *
 * 구현 내용
 * - Controller에서 넘어온 요청 처리
 * - Mapper 호출하여 DB 조회·수정
 * - 비즈니스 규칙 검증 및 결과 반환
 *
 * 연결
 * - implements: AdminMainService
 * - 사용: AdminMainMapper
 *
 * 비즈니스 로직은 여기에 작성 (Controller, Mapper에 직접 작성 X)
 *
 * - 박유정 / 2026-07-29 — Phase 1: 승인 대기 사업자 목록
 * - 박유정 / 2026-07-30 — ADMIN-01: 대시보드 통계·차트 / ADMIN-04: 통계 Phase 1
 * - 박유정 / 2026-07-31 — ADMIN-04: 통계 Phase 2~5 (차트·전월대비·CSV)
 */

package com.petcare.petcare.admin.main.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.petcare.petcare.admin.biz.service.AdminBizService;
import com.petcare.petcare.admin.biz.vo.AdminBizVO;
import com.petcare.petcare.admin.main.vo.AdminMainVO;

import com.petcare.petcare.admin.main.mapper.AdminMainMapper;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import com.petcare.petcare.admin.main.vo.AdminMainSalesDayVO;
import com.petcare.petcare.admin.main.vo.AdminStatsVO;

import java.time.format.DateTimeFormatter;

import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.nio.charset.StandardCharsets;


@Service
public class AdminMainServiceImpl implements AdminMainService {

    // 2026-07-29 박유정 — 사업자 승인 목록 재사용 (AdminBizMapper 직접 호출 X, /admin/biz/list 와 동일 데이터)
    @Autowired
    private AdminBizService adminBizService;

    // 2026-07-30 박유정 — 대시보드 통계 (Phase 2: AdminMainMapper → TB_MEMBER/ORDER/RESERVATION)
    @Autowired
    private AdminMainMapper adminMainMapper;

    // 2026-07-29 박유정 — 대시보드 요약 조회 
    public AdminMainVO getDashboardSummary() {

        // 2026-07-29 박유정 — STATUS_CD=PENDING 전체 목록 (DB 0건이면 빈 리스트)
        // 2026/08/01 장우철 — getBizApplyList(status, bizType): null/ALL = 업종 전체
        List<AdminBizVO> allPending = adminBizService.getBizApplyList("PENDING", null);

        // 2026-07-29 박유정 — dashboard.jsp 표는 최대 5건 (subList(0,0) → 빈 리스트, 에러 없음)
        int limit = Math.min(5, allPending.size());
        List<AdminBizVO> topFive = allPending.subList(0, limit);

        // 2026-07-29 박유정 — AdminMainVO.pendingBizList 에 담아 Controller 로 전달
        AdminMainVO summary = new AdminMainVO();
        summary.setPendingBizList(topFive);

        // 2026-07-30 박유정 — Phase 2: 상단 통계 카드 4종 (dashboard.jsp adm-stats)
        summary.setTodayNewMemberCount(adminMainMapper.countTodayNewMembers());
        summary.setTodayOrderCount(adminMainMapper.countTodayOrders());
        summary.setTodaySalesAmount(adminMainMapper.sumTodaySalesAmount());
        summary.setPendingReservationCount(adminMainMapper.countPendingReservations());

        // 2026-07-30 박유정 — Phase 3-A: 최근 주문 5건 (dashboard.jsp)
        summary.setRecentOrderList(adminMainMapper.selectRecentOrders());

        // 2026-07-30 박유정 — Phase 3-B: 회원 현황 도넛 (dashboard.jsp memberChart)
        summary.setMemberGeneralCount(adminMainMapper.countMemberGeneral());
        summary.setMemberBizCount(adminMainMapper.countMemberBiz());
        summary.setMemberWithdrawnCount(adminMainMapper.countMemberWithdrawn());

        // 2026-07-30 박유정 — Phase 3-C: 주간 매출 7일 (주문 없는 날 = 0원)
        List<AdminMainSalesDayVO> salesFromDb = adminMainMapper.selectWeeklySales();

        // 2026-07-30 박유정 — DB 결과를 Map으로 (요일 라벨 → 매출)
        Map<String, Long> salesByDayLabel = new HashMap<>();
        for (AdminMainSalesDayVO row : salesFromDb) {
            salesByDayLabel.put(row.getDayLabel(), row.getSalesAmount());
        }

        // 2026-07-30 박유정 — 최근 7일 고정, 주문 없는 날은 0원
        String[] korDayLabels = {"월", "화", "수", "목", "금", "토", "일"};
        List<AdminMainSalesDayVO> weeklySalesList = new ArrayList<>();
        LocalDate startDate = LocalDate.now().minusDays(6);

        for (int i = 0; i < 7; i++) {
            LocalDate date = startDate.plusDays(i);
            String dayLabel = korDayLabels[date.getDayOfWeek().getValue() - 1];

            AdminMainSalesDayVO day = new AdminMainSalesDayVO();
            day.setDayLabel(dayLabel);
            day.setSalesAmount(salesByDayLabel.getOrDefault(dayLabel, 0L));
            weeklySalesList.add(day);
        }

        summary.setWeeklySalesList(weeklySalesList);

        // 2026-07-30 박유정 — 월간 매출: 이번 달 1일~말일 (주문·미래 날 = 0원)
        List<AdminMainSalesDayVO> monthlyFromDb = adminMainMapper.selectMonthlySales();

        // 2026-07-30 박유정 — DB 결과를 Map으로 (일 숫자 라벨 → 매출)
        Map<String, Long> monthlyByDayLabel = new HashMap<>();
        for (AdminMainSalesDayVO row : monthlyFromDb) {
            monthlyByDayLabel.put(row.getDayLabel(), row.getSalesAmount());
        }

        // 2026-07-30 박유정 — 이번 달 1일~말일 전체 일자 채움 (미래·무주문일 = 0원)
        LocalDate monthStart = LocalDate.now().withDayOfMonth(1);
        int daysInMonth = monthStart.lengthOfMonth();
        List<AdminMainSalesDayVO> monthlySalesList = new ArrayList<>();

        for (int day = 1; day <= daysInMonth; day++) {
            String dayLabel = String.valueOf(day);

            AdminMainSalesDayVO dayVo = new AdminMainSalesDayVO();
            dayVo.setDayLabel(dayLabel);
            dayVo.setSalesAmount(monthlyByDayLabel.getOrDefault(dayLabel, 0L));
            monthlySalesList.add(dayVo);
        }

        summary.setMonthlySalesList(monthlySalesList);
        return summary;
    }

    // 2026-07-30 박유정 — ADMIN-04: 통계 페이지 (admin/stats/index.jsp, Phase 1~5)
    @Override
    public AdminStatsVO getStatsSummary() {
        AdminStatsVO stats = new AdminStatsVO();

        // ── Phase 1: 이번 달 요약 카드 4종 ──
        // 2026-07-30 박유정 — 이번 달 총 매출 (원, 취소 제외)
        stats.setMonthSalesAmount(adminMainMapper.sumMonthSalesAmount());
        // 2026-07-30 박유정 — 이번 달 신규 가입 (TB_MEMBER.JOIN_DATE)
        stats.setMonthNewMemberCount(adminMainMapper.countMonthNewMembers());
        // 2026-07-30 박유정 — 이번 달 예약 건수 (TB_RESERVATION.REG_DATE)
        stats.setMonthReservationCount(adminMainMapper.countMonthReservations());
        // 2026-07-30 박유정 — 이번 달 주문 수 (TB_ORDER.ORDER_DATE, 취소 포함)
        stats.setMonthOrderCount(adminMainMapper.countMonthOrders());

        // ── Phase 5-A: 전월 대비 증감률 (지난 달 vs 이번 달) ──
        // 2026-07-31 박유정 — 지난 달 4지표 조회
        long prevSales = adminMainMapper.sumPrevMonthSalesAmount();
        int prevMembers = adminMainMapper.countPrevMonthNewMembers();
        int prevReservations = adminMainMapper.countPrevMonthReservations();
        int prevOrders = adminMainMapper.countPrevMonthOrders();

        // 2026-07-31 박유정 — calcChangeRate()로 % 계산 후 VO set
        stats.setMonthSalesChangeRate(calcChangeRate(stats.getMonthSalesAmount(), prevSales));
        stats.setMonthNewMemberChangeRate(calcChangeRate(stats.getMonthNewMemberCount(), prevMembers));
        stats.setMonthReservationChangeRate(calcChangeRate(stats.getMonthReservationCount(), prevReservations));
        stats.setMonthOrderChangeRate(calcChangeRate(stats.getMonthOrderCount(), prevOrders));

        // ── Phase 2: 월별 매출 추이 (최근 6개월 line chart) ──
        // 2026-07-31 박유정 — DB 월별 SUM → Map(YYYY-MM → 원)
        List<AdminMainSalesDayVO> salesFromDb = adminMainMapper.selectLast6MonthsSales();

        // 2026-07-31 박유정 — Map에 담기 (키: YYYY-MM)
        Map<String, Long> salesByMonthKey = new HashMap<>();
        for (AdminMainSalesDayVO row : salesFromDb) {
            salesByMonthKey.put(row.getDayLabel(), row.getSalesAmount());
        }

        // 2026-07-31 박유정 — 6개월 고정 패딩 (주문 없는 달 = 0원, X축 "3월" 형식)
        List<AdminMainSalesDayVO> monthlySalesTrendList = new ArrayList<>();
        LocalDate monthStart = LocalDate.now().withDayOfMonth(1).minusMonths(5);
        DateTimeFormatter monthKeyFmt = DateTimeFormatter.ofPattern("yyyy-MM");

        for (int i = 0; i < 6; i++) {
            LocalDate month = monthStart.plusMonths(i);
            String monthKey = month.format(monthKeyFmt);       // DB 매칭: "2026-07"
            String monthLabel = month.getMonthValue() + "월";  // 차트 표시: "7월"

            AdminMainSalesDayVO monthVo = new AdminMainSalesDayVO();
            monthVo.setDayLabel(monthLabel);
            monthVo.setSalesAmount(salesByMonthKey.getOrDefault(monthKey, 0L));
            monthlySalesTrendList.add(monthVo);
        }

        stats.setMonthlySalesTrendList(monthlySalesTrendList);

        // ── Phase 3: 월별 신규 가입자 (최근 6개월 bar chart) ──
        // 2026-07-31 박유정 — DB 월별 COUNT → Map(YYYY-MM → 명)
        List<AdminMainSalesDayVO> membersFromDb = adminMainMapper.selectLast6MonthsNewMembers();

        // 2026-07-31 박유정 — DB 결과 Map (YYYY-MM 키 → 가입자 수)
        Map<String, Long> membersByMonthKey = new HashMap<>();
        for (AdminMainSalesDayVO row : membersFromDb) {
            membersByMonthKey.put(row.getDayLabel(), row.getSalesAmount());
        }

        // 2026-07-31 박유정 — 6개월 고정 패딩 (가입 없는 달 = 0명, Phase 2와 동일 기간)
        List<AdminMainSalesDayVO> monthlyMemberTrendList = new ArrayList<>();
        LocalDate memberMonthStart = LocalDate.now().withDayOfMonth(1).minusMonths(5);

        for (int i = 0; i < 6; i++) {
            LocalDate month = memberMonthStart.plusMonths(i);
            String monthKey = month.format(monthKeyFmt);
            String monthLabel = month.getMonthValue() + "월";

            AdminMainSalesDayVO monthVo = new AdminMainSalesDayVO();
            monthVo.setDayLabel(monthLabel);
            monthVo.setSalesAmount(membersByMonthKey.getOrDefault(monthKey, 0L));
            monthlyMemberTrendList.add(monthVo);
        }

        stats.setMonthlyMemberTrendList(monthlyMemberTrendList);

        // ── Phase 4: 업종별 예약/주문 (병원·숙소=예약, 쇼핑=주문) ──
        // 2026-07-31 박유정 — UNION ALL 3행, Service 패딩 없음
        stats.setCategoryResvOrderList(adminMainMapper.selectMonthCategoryResvOrderStats());
        return stats;
    }

    // 2026-07-31 박유정 — Phase 5-C: 통계 CSV(Excel)보내기 (getStatsSummary 재사용)
    @Override
    public void exportStatsCsv(OutputStream out) throws IOException {
        AdminStatsVO stats = getStatsSummary();

        try (OutputStreamWriter writer = new OutputStreamWriter(out, StandardCharsets.UTF_8)) {
            writer.write('\uFEFF'); // 2026-07-31 박유정 — Excel 한글 BOM

            // 2026-07-31 박유정 — 섹션1: 요약 카드 + 전월대비 %
            writer.write("[요약 - 이번 달]\n");
            writer.write("항목,값,전월대비(%)\n");
            writeSummaryRow(writer, "총 매출(원)", stats.getMonthSalesAmount(), stats.getMonthSalesChangeRate());
            writeSummaryRow(writer, "신규 가입(명)", stats.getMonthNewMemberCount(), stats.getMonthNewMemberChangeRate());
            writeSummaryRow(writer, "예약 건수(건)", stats.getMonthReservationCount(), stats.getMonthReservationChangeRate());
            writeSummaryRow(writer, "주문 수(건)", stats.getMonthOrderCount(), stats.getMonthOrderChangeRate());

            // 2026-07-31 박유정 — 섹션2: 월별 매출 추이 (최근 6개월, 원 단위)
            writer.write("\n[월별 매출 추이 - 최근 6개월]\n");
            writer.write("월,매출(원)\n");
            for (AdminMainSalesDayVO row : stats.getMonthlySalesTrendList()) {
                writer.write(csvCell(row.getDayLabel()));
                writer.write(",");
                writer.write(csvCell(row.getSalesAmount()));
                writer.write("\n");
            }

            // 2026-07-31 박유정 — 섹션3: 월별 신규 가입자 (최근 6개월)
            writer.write("\n[월별 신규 가입자 - 최근 6개월]\n");
            writer.write("월,가입자(명)\n");
            for (AdminMainSalesDayVO row : stats.getMonthlyMemberTrendList()) {
                writer.write(csvCell(row.getDayLabel()));
                writer.write(",");
                writer.write(csvCell(row.getSalesAmount()));
                writer.write("\n");
            }

            // 2026-07-31 박유정 — 섹션4: 업종별 예약/주문 (병원·숙소·쇼핑)
            writer.write("\n[업종별 예약/주문 - 이번 달]\n");
            writer.write("구분,건수\n");
            for (AdminMainSalesDayVO row : stats.getCategoryResvOrderList()) {
                writer.write(csvCell(row.getDayLabel()));
                writer.write(",");
                writer.write(csvCell(row.getSalesAmount()));
                writer.write("\n");
            }
        }
    }

    // 2026-07-31 박유정 — Phase 5-C: 요약 1행 (항목, 값, 전월대비%)
    private void writeSummaryRow(OutputStreamWriter writer, String label, long value, double changeRate)
            throws IOException {
        writer.write(csvCell(label));
        writer.write(",");
        writer.write(csvCell(value));
        writer.write(",");
        writer.write(csvCell(changeRate));
        writer.write("\n");
    }

    // 2026-07-31 박유정 — Phase 5-C: CSV 셀 이스케이프 (회원 export 와 동일)
    private String csvCell(Object value) {
        if (value == null) return "";
        String s = String.valueOf(value);
        if (s.contains(",") || s.contains("\"") || s.contains("\n")) {
            return "\"" + s.replace("\"", "\"\"") + "\"";
        }
        return s;
    }

    // 2026-07-31 박유정 — Phase 5-A: 전월 대비 증감률 (소수 1자리, + 증가 · - 감소)
    private double calcChangeRate(long current, long previous) {
        if (previous == 0) {
            return current > 0 ? 100.0 : 0.0;
        }
        double rate = (current - previous) * 100.0 / previous;
        return Math.round(rate * 10.0) / 10.0;
    }
}
