<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %> <%-- 2026-07-30 박유정 — ADMIN-04: 매출 백만원 포맷 --%>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="adminPage"   value="stats" />
<%@ include file="/WEB-INF/views/admin/common/header.jsp" %>
<%@ include file="/WEB-INF/views/admin/common/sidebar.jsp" %>

<main class="adm-main">
    <div class="adm-page-head">
        <div class="adm-page-head-left">
            <h1 class="adm-page-title">통계 &amp; 분석</h1>
            <p class="adm-page-desc">기간별 매출·회원·예약 현황을 분석하세요.</p>
        </div>
        <div class="adm-page-actions">
            <%-- TODO: Phase 5-B 기간 필터 (7d/30d/3m/year) — 보류, UI만 존재 --%>
            <select class="adm-filter-select">
                <option>최근 7일</option>
                <option>최근 30일</option>
                <option>최근 3개월</option>
                <option>올해</option>
            </select>
    <%-- 2026-07-31 박유정 — Phase 5-C: 통계 CSV(Excel) 다운로드 --%>
        <a href="${contextPath}/admin/stats/export"
         class="adm-filter-btn outline" style="margin-left:8px">
         <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
         Excel보내기
        </a>
        </div>
    </div>

    <%-- 2026-07-30 박유정 — ADMIN-04 Phase 1: 이번 달 요약 카드 4종 (stats.monthXxx 실데이터) --%>
    <div class="adm-stats" style="margin-bottom:24px">
        <div class="adm-stat-card">
            <div class="adm-stat-icon blue"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 000 7h5a3.5 3.5 0 010 7H6"/></svg></div>
            <div class="adm-stat-body">
                <div class="adm-stat-label">이번 달 총 매출</div>
                <%-- 2026-07-30 박유정 — 원 → 백만원 (÷1000000) --%>
                <div class="adm-stat-val">
                    <fmt:formatNumber value="${stats.monthSalesAmount / 1000000}"
                                      maxFractionDigits="1" minFractionDigits="0" />
                 <span class="adm-stat-unit">백만원</span>
                </div>
                <%-- 2026-07-31 박유정 — Phase 5-A: stats.monthSalesChangeRate --%>
                <c:choose>
                    <c:when test="${stats.monthSalesChangeRate >= 0}">
                        <div class="adm-stat-diff up">▲ 전월 대비 +<fmt:formatNumber value="${stats.monthSalesChangeRate}" maxFractionDigits="1" minFractionDigits="0" />%</div>
                    </c:when>
                    <c:otherwise>
                        <div class="adm-stat-diff down">▼ 전월 대비 <fmt:formatNumber value="${stats.monthSalesChangeRate}" maxFractionDigits="1" minFractionDigits="0" />%</div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
        <div class="adm-stat-card">
            <div class="adm-stat-icon green"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87M16 3.13a4 4 0 010 7.75"/></svg></div>
            <div class="adm-stat-body">
                <div class="adm-stat-label">이번 달 신규 가입</div>
                <%-- 2026-07-30 박유정 — stats.monthNewMemberCount --%>
                <div class="adm-stat-val">${stats.monthNewMemberCount}<span class="adm-stat-unit">명</span></div>
                <%-- 2026-07-31 박유정 — Phase 5-A: stats.monthNewMemberChangeRate --%>
                <c:choose>
                   <c:when test="${stats.monthNewMemberChangeRate >= 0}">
                        <div class="adm-stat-diff up">▲ 전월 대비 +<fmt:formatNumber value="${stats.monthNewMemberChangeRate}" maxFractionDigits="1" minFractionDigits="0" />%</div>
                 </c:when>
                 <c:otherwise>
                     <div class="adm-stat-diff down">▼ 전월 대비 <fmt:formatNumber value="${stats.monthNewMemberChangeRate}" maxFractionDigits="1" minFractionDigits="0" />%</div>
                 </c:otherwise>
                </c:choose>
            </div>
        </div>
        <div class="adm-stat-card">
            <div class="adm-stat-icon orange"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="3" y1="10" x2="21" y2="10"/></svg></div>
            <div class="adm-stat-body">
                <div class="adm-stat-label">이번 달 예약 건수</div>
                <%-- 2026-07-30 박유정 — stats.monthReservationCount (REG_DATE 기준) --%>
                <div class="adm-stat-val">${stats.monthReservationCount}<span class="adm-stat-unit">건</span></div>
                <%-- 2026-07-31 박유정 — Phase 5-A: stats.monthReservationChangeRate --%>
                <c:choose>
                   <c:when test="${stats.monthReservationChangeRate >= 0}">
                      <div class="adm-stat-diff up">▲ 전월 대비 +<fmt:formatNumber value="${stats.monthReservationChangeRate}" maxFractionDigits="1" minFractionDigits="0" />%</div>
                  </c:when>
                  <c:otherwise>
                     <div class="adm-stat-diff down">▼ 전월 대비 <fmt:formatNumber value="${stats.monthReservationChangeRate}" maxFractionDigits="1" minFractionDigits="0" />%</div>
                  </c:otherwise>
                </c:choose>
            </div>
        </div>
        <div class="adm-stat-card">
            <div class="adm-stat-icon red"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M6 2L3 6v14a2 2 0 002 2h14a2 2 0 002-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 01-8 0"/></svg></div>
            <div class="adm-stat-body">
                <div class="adm-stat-label">이번 달 주문 수</div>
                <%-- 2026-07-30 박유정 — stats.monthOrderCount --%>
                <div class="adm-stat-val">${stats.monthOrderCount}<span class="adm-stat-unit">건</span></div>
                <%-- 2026-07-31 박유정 — Phase 5-A: stats.monthOrderChangeRate --%>
                <c:choose>
                  <c:when test="${stats.monthOrderChangeRate >= 0}">
                     <div class="adm-stat-diff up">▲ 전월 대비 +<fmt:formatNumber value="${stats.monthOrderChangeRate}" maxFractionDigits="1" minFractionDigits="0" />%</div>
                  </c:when>
                  <c:otherwise>
                     <div class="adm-stat-diff down">▼ 전월 대비 <fmt:formatNumber value="${stats.monthOrderChangeRate}" maxFractionDigits="1" minFractionDigits="0" />%</div>
                 </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <div class="adm-grid-2">
        <%-- 2026-07-31 박유정 — Phase 2: 월별 매출 추이 (stats.monthlySalesTrendList) --%>
        <div class="adm-card">
            <div class="adm-card-head">
                <span class="adm-card-head-title">월별 매출 추이</span>
                <span class="adm-card-head-sub">최근 6개월 · 단위: 백만원</span>
            </div>
            <div class="adm-card-body">
                <canvas id="monthSales" height="220"></canvas>
            </div>
        </div>

        <%-- 2026-07-31 박유정 — Phase 3: 월별 신규 가입자 (stats.monthlyMemberTrendList) --%>
        <div class="adm-card">
            <div class="adm-card-head">
                <span class="adm-card-head-title">월별 신규 가입자</span>
                <span class="adm-card-head-sub">최근 6개월 · 단위: 명</span>
            </div>
            <div class="adm-card-body">
                <canvas id="memberGrowth" height="220"></canvas>
            </div>
        </div>
    </div>

    <%-- 2026-07-31 박유정 — Phase 4: 업종별 예약/주문 현황 (stats.categoryResvOrderList) --%>
    <div class="adm-card">
        <div class="adm-card-head">
            <span class="adm-card-head-title">업종별 예약/주문 현황</span>
            <span class="adm-card-head-sub">이번 달 기준 · 병원·숙소=예약, 쇼핑=주문</span>
        </div>
        <div class="adm-card-body">
            <canvas id="reservationChart" height="120"></canvas>
        </div>
    </div>
</main>

<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.0/chart.umd.min.js"></script>
<script>

/* 2026-07-31 박유정 — Phase 2: 월별 매출 추이 (원 → 백만원 ÷1000000) */
const salesTrendLabels = [
    <c:forEach var="month" items="${stats.monthlySalesTrendList}" varStatus="st">
        '${month.dayLabel}'<c:if test="${!st.last}">,</c:if>
    </c:forEach>
];
const salesTrendData = [
    <c:forEach var="month" items="${stats.monthlySalesTrendList}" varStatus="st">
        ${month.salesAmount / 1000000}<c:if test="${!st.last}">,</c:if>
    </c:forEach>
];

new Chart(document.getElementById('monthSales'), {
    type: 'line',
    data: {
        labels: salesTrendLabels,
        datasets: [{
            label: '매출 (백만원)',
            data: salesTrendData,
            borderColor: '#3B5BDB',
            backgroundColor: 'rgba(59,91,219,.08)',
            borderWidth: 2.5,
            pointRadius: 4,
            fill: true,
            tension: .35
        }]
    },
    options: {
        responsive: true,
        plugins: { legend: { display: false } },
        scales: {
            y: { beginAtZero: true, grid: { color: '#F1F3F7' } },
            x: { grid: { display: false } }
        }
    }
});

/* 2026-07-31 박유정 — Phase 3: 월별 신규 가입자 (salesAmount = 가입자 수) */
const memberTrendLabels = [
    <c:forEach var="month" items="${stats.monthlyMemberTrendList}" varStatus="st">
        '${month.dayLabel}'<c:if test="${!st.last}">,</c:if>
    </c:forEach>
];
const memberTrendData = [
    <c:forEach var="month" items="${stats.monthlyMemberTrendList}" varStatus="st">
        ${month.salesAmount}<c:if test="${!st.last}">,</c:if>
    </c:forEach>
];

new Chart(document.getElementById('memberGrowth'), {
    type: 'bar',
    data: {
        labels: memberTrendLabels,
        datasets: [{
            label: '신규 가입자 (명)',
            data: memberTrendData,
            backgroundColor: 'rgba(43,171,130,.2)',
            borderColor: '#2BAB82',
            borderWidth: 2,
            borderRadius: 6
        }]
    },
    options: {
        responsive: true,
        plugins: { legend: { display: false } },
        scales: {
            y: { beginAtZero: true, grid: { color: '#F1F3F7' } },
            x: { grid: { display: false } }
        }
    }
});

/* 2026-07-31 박유정 — Phase 4: 업종별 예약/주문 (salesAmount = 건수) */
const categoryLabels = [
    <c:forEach var="item" items="${stats.categoryResvOrderList}" varStatus="st">
        '${item.dayLabel}'<c:if test="${!st.last}">,</c:if>
    </c:forEach>
];
const categoryData = [
    <c:forEach var="item" items="${stats.categoryResvOrderList}" varStatus="st">
        ${item.salesAmount}<c:if test="${!st.last}">,</c:if>
    </c:forEach>
];

new Chart(document.getElementById('reservationChart'), {
    type: 'bar',
    data: {
        labels: categoryLabels,
        datasets: [{
            label: '건수',
            data: categoryData,
            backgroundColor: [
                'rgba(59,91,219,.7)',
                'rgba(147,51,234,.7)',
                'rgba(234,88,12,.7)'
            ],
            borderRadius: 6
        }]
    },
    options: {
        indexAxis: 'y',
        responsive: true,
        plugins: { legend: { display: false } },
        scales: {
            x: { beginAtZero: true, grid: { color: '#F1F3F7' } },
            y: { grid: { display: false } }
        }
    }
});
</script>

<%@ include file="/WEB-INF/views/admin/common/footer.jsp" %>
