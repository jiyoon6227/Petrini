<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="adminPage"   value="dashboard" />
<%@ include file="/WEB-INF/views/admin/common/header.jsp" %>
<%@ include file="/WEB-INF/views/admin/common/sidebar.jsp" %>

<main class="adm-main">
    <div class="adm-page-head">
        <div class="adm-page-head-left">
            <h1 class="adm-page-title">대시보드</h1>
            <p class="adm-page-desc">PetCare 플랫폼 운영 현황을 한눈에 확인하세요.</p>
        </div>
        <div class="adm-page-actions">
            <span style="font-size:13px;color:#999">오늘 기준</span>
        </div>
    </div>

    <%-- 2026-07-30 박유정 — Phase 2: 상단 통계 카드 4종 (summary.todayXxx 실데이터) --%>
    <div class="adm-stats">
        <div class="adm-stat-card">
            <div class="adm-stat-icon blue">
                <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87M16 3.13a4 4 0 010 7.75"/></svg>
            </div>
            <div class="adm-stat-body">
                <div class="adm-stat-label">오늘 신규 가입자</div>
                <%-- 2026-07-30 박유정 — TB_MEMBER.JOIN_DATE = 오늘 --%>
                <div class="adm-stat-val">${summary.todayNewMemberCount}<span class="adm-stat-unit">명</span></div>
                <div class="adm-stat-diff up">오늘 기준 실시간 집계</div>
            </div>
        </div>
        <div class="adm-stat-card">
            <div class="adm-stat-icon green">
                <svg viewBox="0 0 24 24"><path d="M6 2L3 6v14a2 2 0 002 2h14a2 2 0 002-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 01-8 0"/></svg>
            </div>
            <div class="adm-stat-body">
                <div class="adm-stat-label">오늘 주문 수</div>
                <%-- 2026-07-30 박유정 — TB_ORDER.ORDER_DATE = 오늘 --%>
                <div class="adm-stat-val">${summary.todayOrderCount}<span class="adm-stat-unit">건</span></div>
                <div class="adm-stat-diff up">오늘 기준 실시간 집계</div>
            </div>
        </div>
        <div class="adm-stat-card">
            <div class="adm-stat-icon orange">
                <svg viewBox="0 0 24 24"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 000 7h5a3.5 3.5 0 010 7H6"/></svg>
            </div>
            <div class="adm-stat-body">
                <div class="adm-stat-label">오늘 매출</div>
                <%-- 2026-07-30 박유정 — 오늘 매출 원 → 백만원 (÷1000000) --%>
                <div class="adm-stat-val">
                    <fmt:formatNumber value="${summary.todaySalesAmount / 1000000}"
                                      maxFractionDigits="1" minFractionDigits="0" />
                    <span class="adm-stat-unit">백만원</span>
                </div>
                <div class="adm-stat-diff up">오늘 기준 실시간 집계</div>
            </div>
        </div>
        <div class="adm-stat-card">
            <div class="adm-stat-icon red">
                <svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="3" y1="10" x2="21" y2="10"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="16" y1="2" x2="16" y2="6"/></svg>
            </div>
            <div class="adm-stat-body">
                <div class="adm-stat-label">미처리 예약</div>
                <%-- 2026-07-30 박유정 — TB_RESERVATION PENDING + CONFIRMED --%>
                <div class="adm-stat-val">${summary.pendingReservationCount}<span class="adm-stat-unit">건</span></div>
                <c:if test="${summary.pendingReservationCount > 0}">
                    <div class="adm-stat-diff down">▼ 처리 필요</div>
                </c:if>
                <c:if test="${summary.pendingReservationCount == 0}">
                    <div class="adm-stat-diff up">처리할 예약 없음</div>
                </c:if>
            </div>
        </div>
    </div>
    <div class="adm-grid-2">
        <%-- 2026-07-30 박유정 — Phase 3-C: 매출 차트 (주간 7일 / 월간 이번달 일별, switchSalesChart) --%>
        <div class="adm-card">
            <div class="adm-card-head">
                <span class="adm-card-head-title">매출 현황</span>
                <div style="display:flex;gap:8px">
                    <button type="button" id="btnSalesWeekly" class="adm-btn blue" style="font-size:11px;padding:3px 10px">주간</button>
                    <button type="button" id="btnSalesMonthly" class="adm-btn gray" style="font-size:11px;padding:3px 10px">월간</button>
                </div>
            </div>
            <div class="adm-card-body">
                <canvas id="salesChart" height="200"></canvas>
            </div>
        </div>

        <%-- 회원 현황 도넛 차트 --%>
        <%-- 2026-07-30 박유정 — Phase 3-B: 회원 합계 (도넛·% 계산용) --%>
        <c:set var="memberTotal"
               value="${summary.memberGeneralCount + summary.memberBizCount + summary.memberWithdrawnCount}" />
        <div class="adm-card">
            <div class="adm-card-head">
                <span class="adm-card-head-title">회원 현황</span>
                <span class="adm-card-head-sub">총 <fmt:formatNumber value="${memberTotal}" groupingUsed="true" />명</span>
            </div>
            <div class="adm-card-body" style="display:flex;align-items:center;gap:24px">
                <canvas id="memberChart" width="160" height="160" style="flex-shrink:0"></canvas>
                <div style="flex:1">
                        <div style="display:flex;align-items:center;gap:10px;font-size:13px">
                            <span style="width:12px;height:12px;border-radius:3px;background:#3B5BDB;flex-shrink:0"></span>
                            <span style="flex:1;color:#555">일반회원</span>
                            <span style="font-weight:700;color:#1A1A2E">
                                <fmt:formatNumber value="${summary.memberGeneralCount}" groupingUsed="true" />명
                            </span>
                            <span style="color:#999">
                                <fmt:formatNumber value="${memberTotal > 0 ? summary.memberGeneralCount * 100 / memberTotal : 0}"
                                                  maxFractionDigits="1" minFractionDigits="0" />%
                            </span>
                        </div>
                        <div style="display:flex;align-items:center;gap:10px;font-size:13px">
                            <span style="width:12px;height:12px;border-radius:3px;background:#2BAB82;flex-shrink:0"></span>
                            <span style="flex:1;color:#555">사업자</span>
                            <span style="font-weight:700;color:#1A1A2E">
                                <fmt:formatNumber value="${summary.memberBizCount}" groupingUsed="true" />명
                            </span>
                            <span style="color:#999">
                                <fmt:formatNumber value="${memberTotal > 0 ? summary.memberBizCount * 100 / memberTotal : 0}"
                                                  maxFractionDigits="1" minFractionDigits="0" />%
                            </span>
                        </div>
                        <div style="display:flex;align-items:center;gap:10px;font-size:13px">
                            <span style="width:12px;height:12px;border-radius:3px;background:#E4E6ED;flex-shrink:0"></span>
                            <span style="flex:1;color:#555">탈퇴</span>
                            <span style="font-weight:700;color:#1A1A2E">
                                <fmt:formatNumber value="${summary.memberWithdrawnCount}" groupingUsed="true" />명
                            </span>
                            <span style="color:#999">
                                <fmt:formatNumber value="${memberTotal > 0 ? summary.memberWithdrawnCount * 100 / memberTotal : 0}"
                                                  maxFractionDigits="1" minFractionDigits="0" />%
                            </span>
                        </div>
                    </div>
                </div>
            </div>
    </div>

    <div class="adm-grid-2">
        <%-- 최근 주문 목록 --%>
        <div class="adm-card">
            <div class="adm-card-head">
                <span class="adm-card-head-title">최근 주문</span>
                <a href="${contextPath}/admin/store/order-list" class="adm-btn gray" style="font-size:12px">전체보기</a>
            </div>
            <div class="adm-table-wrap">
                <table class="adm-table">
                    <thead><tr><th>주문번호</th><th>회원</th><th>금액</th><th>상태</th></tr></thead>
                    <tbody>
                        <%-- 2026-07-30 박유정 — Phase 3-A: summary.recentOrderList 실데이터 --%>
                        <c:choose>
                            <c:when test="${empty summary.recentOrderList}">
                                <tr>
                                    <td colspan="4" style="text-align:center;color:#999;padding:32px 0">
                                        최근 주문이 없습니다.
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="order" items="${summary.recentOrderList}">
                                    <tr style="cursor:pointer"
                                        onclick="location.href='${contextPath}/admin/store/order-detail?id=${order.orderId}'">
                                        <td>#${order.orderNo}</td>
                                        <td>${order.memberName}</td>
                                        <td>
                                            <fmt:formatNumber value="${order.payAmount}" groupingUsed="true" />원
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${order.orderStatus eq 'SHIPPING'}">
                                                    <span class="adm-badge shipping">배송중</span>
                                                </c:when>
                                                <c:when test="${order.orderStatus eq 'DELIVERED' or order.orderStatus eq 'DONE'}">
                                                    <span class="adm-badge done">배송완료</span>
                                                </c:when>
                                                <c:when test="${order.orderStatus eq 'CANCEL'}">
                                                    <span class="adm-badge cancel">취소</span>
                                                </c:when>
                                                <c:when test="${order.orderStatus eq 'PAID'}">
                                                    <span class="adm-badge wait">결제완료</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="adm-badge">${order.orderStatus}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>

        <%-- 사업자 승인 대기 --%>
        <div class="adm-card">
            <div class="adm-card-head">
                <span class="adm-card-head-title">사업자 승인 대기
                    <%-- 2026/07/11 장우철 — PENDING 실건수 (더미 3건 제거) --%>
                    <span style="margin-left:8px;background:#EEF2FF;color:#3B5BDB;font-size:11px;font-weight:700;padding:2px 8px;border-radius:20px">${pendingBizApproveCount}건</span>
                </span>
                <a href="${contextPath}/admin/biz/list?status=PENDING" class="adm-btn blue" style="font-size:12px">승인 관리</a>
            </div>
            <div class="adm-table-wrap">
                <table class="adm-table">
                    <thead><tr><th>업체명</th><th>업종</th><th>신청일</th><th>처리</th></tr></thead>
                    <tbody>
                        <%-- 2026-07-30 박유정 — Phase 1: summary.pendingBizList 실데이터 (더미 3행 제거) --%>
                        <c:choose>
                            <c:when test="${empty summary.pendingBizList}">
                                <tr>
                                    <td colspan="4" style="text-align:center;color:#999;padding:32px 0">
                                        승인 대기 사업자가 없습니다.
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="item" items="${summary.pendingBizList}">
                                    <tr>
                                        <td><strong>${item.bizName}</strong></td>
                                        <td>${item.bizType}</td>
                                        <td>${item.applyDate}</td>
                                        <td>
                                            <a href="${contextPath}/admin/biz/detail?bizNo=${item.bizNo}"
                                               class="adm-btn blue">검토</a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>

<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.0/chart.umd.min.js"></script>
<script>
/* 2026-07-30 박유정 — Phase 3-C: 매출 차트 데이터 (원 → 만원 ÷10000) */
const weeklyLabels = [
    <c:forEach var="day" items="${summary.weeklySalesList}" varStatus="st">
        '${day.dayLabel}'<c:if test="${!st.last}">,</c:if>
    </c:forEach>
];
const weeklyData = [
    <c:forEach var="day" items="${summary.weeklySalesList}" varStatus="st">
        ${day.salesAmount / 10000}<c:if test="${!st.last}">,</c:if>
    </c:forEach>
];
const monthlyLabels = [
    <c:forEach var="day" items="${summary.monthlySalesList}" varStatus="st">
        '${day.dayLabel}'<c:if test="${!st.last}">,</c:if>
    </c:forEach>
];
const monthlyData = [
    <c:forEach var="day" items="${summary.monthlySalesList}" varStatus="st">
        ${day.salesAmount / 10000}<c:if test="${!st.last}">,</c:if>
    </c:forEach>
];

let salesChart = new Chart(document.getElementById('salesChart'), {
    type: 'bar',
    data: {
        labels: weeklyLabels,
        datasets: [{
            label: '매출 (만원)',
            data: weeklyData,
            backgroundColor: 'rgba(59,91,219,.18)',
            borderColor: '#3B5BDB',
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

/* 2026-07-30 박유정 — 주간/월간 버튼 전환 */
function switchSalesChart(mode) {
    const btnWeekly = document.getElementById('btnSalesWeekly');
    const btnMonthly = document.getElementById('btnSalesMonthly');

    if (mode === 'weekly') {
        salesChart.data.labels = weeklyLabels;
        salesChart.data.datasets[0].data = weeklyData;
        salesChart.options.scales.x.ticks = { autoSkip: false };
        btnWeekly.className = 'adm-btn blue';
        btnMonthly.className = 'adm-btn gray';
    } else {
        salesChart.data.labels = monthlyLabels;
        salesChart.data.datasets[0].data = monthlyData;
        salesChart.options.scales.x.ticks = { autoSkip: false, font: { size: 10 } };
        btnWeekly.className = 'adm-btn gray';
        btnMonthly.className = 'adm-btn blue';
    }
    btnWeekly.style.cssText = 'font-size:11px;padding:3px 10px';
    btnMonthly.style.cssText = 'font-size:11px;padding:3px 10px';
    salesChart.update();
}

document.getElementById('btnSalesWeekly').addEventListener('click', function() {
    switchSalesChart('weekly');
});
document.getElementById('btnSalesMonthly').addEventListener('click', function() {
    switchSalesChart('monthly');
});

/* 2026-07-30 박유정 — Phase 3-B: 회원 도넛 차트 (일반/사업자/탈퇴) */
new Chart(document.getElementById('memberChart'), {
    type: 'doughnut',
    data: {
        labels: ['일반회원', '사업자', '탈퇴'],
        datasets: [{
            data: [${summary.memberGeneralCount}, ${summary.memberBizCount}, ${summary.memberWithdrawnCount}],
            backgroundColor: ['#3B5BDB', '#2BAB82', '#E4E6ED'],
            borderWidth: 0
        }]
    },
    options: {
        responsive: false,
        plugins: { legend: { display: false } },
        cutout: '70%'
    }
});
</script>

<%@ include file="/WEB-INF/views/admin/common/footer.jsp" %>
