<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="contextPath"  value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="반려동물 숙소" />
<c:set var="bizPage"      value="dashboard" />

<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_stay.jsp" %>

<%--HYJ 26.08.06 DB 연동--%>
<%-- 7/2, 사업자(숙박) 대시보드 UI 구성 — 병원 대시보드와 동일한 공용 클래스(summary-grid, dash-card 등) 재사용 --%>
<main class="biz-main hospital-dashboard">
  <div class="dashboard-top">
    <div>
      <h1>안녕하세요, ${stay.name} 사장님!</h1>
      <p>오늘의 숙소 현황을 한눈에 확인하세요.</p>
    </div>
    <div class="date-select">
      <fmt:formatDate value="<%= new java.util.Date() %>" pattern="yyyy-MM-dd (E)" />
    </div>
  </div>

  <%-- ── 요약 카드 ── --%>
  <section class="summary-grid">
    <div class="summary-card">
      <div class="summary-icon green">📅</div>
      <div>
        <p>오늘 체크인</p>
        <strong>${dash.todayResvCount} <span>건</span></strong>
        <small>어제 대비
          <c:choose>
            <c:when test="${dash.resvDiff > 0}">▲ ${dash.resvDiff}건</c:when>
            <c:when test="${dash.resvDiff < 0}">▼ ${-dash.resvDiff}건</c:when>
            <c:otherwise>동일</c:otherwise>
          </c:choose>
        </small>
      </div>
    </div>
    <div class="summary-card">
      <div class="summary-icon blue">🏠</div>
      <div>
        <p>예약 대기</p>
        <strong>${dash.pendingCount} <span>건</span></strong>
        <small>승인 대기 중</small>
      </div>
    </div>
    <div class="summary-card">
      <div class="summary-icon purple">🚪</div>
      <div>
        <p>오늘 체크아웃</p>
        <strong>${dash.doneCount} <span>건</span></strong>
        <small>어제 대비
          <c:choose>
            <c:when test="${dash.doneDiff > 0}">▲ ${dash.doneDiff}건</c:when>
            <c:when test="${dash.doneDiff < 0}">▼ ${-dash.doneDiff}건</c:when>
            <c:otherwise>동일</c:otherwise>
          </c:choose>
        </small>
      </div>
    </div>
    <div class="summary-card">
      <div class="summary-icon orange">₩</div>
      <div>
        <p>이번 달 매출</p>
        <strong><fmt:formatNumber value="${dash.monthRevenue}" type="number"/> <span>원</span></strong>
        <small>어제 대비
          <c:choose>
            <c:when test="${dash.revenueDiff > 0}">▲ <fmt:formatNumber value="${dash.revenueDiff}" type="number"/>원</c:when>
            <c:when test="${dash.revenueDiff < 0}">▼ <fmt:formatNumber value="${-dash.revenueDiff}" type="number"/>원</c:when>
            <c:otherwise>동일</c:otherwise>
          </c:choose>
        </small>
      </div>
    </div>
  </section>

  <%-- ── 차트 + 도넛 ── --%>
  <section class="dashboard-grid">
    <div class="dash-card chart-card">
      <div class="card-head">
        <h3>예약 / 매출 통계</h3>
        <div class="tab-btns">
          <button class="active" data-days="7">일간</button>
          <button data-days="30">월간</button>
        </div>
      </div>
      <div class="line-chart">
        <div class="chart-legend">
          <span class="green-dot"></span> 예약 건수(건)
          <span class="blue-dot"></span> 매출(원)
        </div>
        <canvas id="dashChart" height="220"></canvas>
      </div>
    </div>

    <div class="dash-card status-card">
      <div class="card-head"><h3>예약 상태 현황</h3></div>
      <div class="donut-wrap">
        <div class="donut-chart"><div><span>총 예약</span><strong>${dash.totalStatusCount}건</strong></div></div>
        <ul class="status-list">
          <li><span class="box green-box"></span>예약 확정 <b>${dash.statusConfirmed}건</b></li>
          <li><span class="box blue-box"></span>예약 대기 <b>${dash.statusPending}건</b></li>
          <li><span class="box orange-box"></span>입실중 <b>${dash.statusCheckin}건</b></li>
          <li><span class="box gray-box"></span>취소 <b>${dash.statusCancel}건</b></li>
        </ul>
      </div>
    </div>
  </section>

  <%-- ── 오늘 체크인 + 최근 리뷰 ── --%>
  <section class="bottom-grid">
    <div class="dash-card">
      <div class="card-head">
        <h3>오늘의 체크인</h3>
        <a href="${contextPath}/biz/stay/reserve" class="outline-btn">전체 예약 보기</a>
      </div>
      <table class="biz-table">
        <thead><tr><th>예약자</th><th>반려동물</th><th>객실</th><th>상태</th><th>관리</th></tr></thead>
        <tbody>
          <c:forEach var="r" items="${todayList}">
          <tr>
            <td>${r.memberName}</td>
            <td>${r.petName} (${r.petBreed})</td>
            <td>${r.roomName}</td>
            <td>
              <c:choose>
                <c:when test="${r.statusCd eq 'CONFIRMED'}"><span class="badge confirm">예약 확정</span></c:when>
                <c:when test="${r.statusCd eq 'CHECKIN'}"><span class="badge confirm">입실중</span></c:when>
                <c:when test="${r.statusCd eq 'PENDING'}"><span class="badge wait">예약 대기</span></c:when>
                <c:otherwise><span class="badge">${r.statusCd}</span></c:otherwise>
              </c:choose>
            </td>
            <td><a href="${contextPath}/biz/stay/reserve" class="detail-btn">상세보기</a></td>
          </tr>
          </c:forEach>
          <c:if test="${empty todayList}">
          <tr><td colspan="5" style="text-align:center; color:#999; padding:24px;">오늘 체크인 예약이 없습니다.</td></tr>
          </c:if>
        </tbody>
      </table>
    </div>

    <div class="dash-card review-card">
      <div class="card-head">
        <h3>최근 리뷰</h3>
        <a href="${contextPath}/biz/stay/reviews" class="outline-btn">전체 리뷰 보기</a>
      </div>
      <c:forEach var="rv" items="${recentReviews}">
      <div class="review-item">
        <div class="avatar"></div>
        <div>
          <p><b>${rv.nickname} 님</b>
            <span class="stars"><c:forEach begin="1" end="5" var="i"><c:choose><c:when test="${i <= rv.rating}">★</c:when><c:otherwise>☆</c:otherwise></c:choose></c:forEach></span>
          </p>
          <small>${rv.content}</small>
        </div>
        <em><fmt:formatDate value="${rv.regDate}" pattern="yyyy-MM-dd"/></em>
      </div>
      </c:forEach>
      <c:if test="${empty recentReviews}">
      <p style="text-align:center; color:#999; padding:24px;">아직 리뷰가 없습니다.</p>
      </c:if>
    </div>
  </section>
</main>

<%-- 차트 JS --%>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
<script>
(function(){
  var labels = [<c:forEach var="l" items="${dash.chartLabels}" varStatus="s">'${l}'<c:if test="${!s.last}">,</c:if></c:forEach>];
  var resvData = [<c:forEach var="c" items="${dash.chartResvCounts}" varStatus="s">${c}<c:if test="${!s.last}">,</c:if></c:forEach>];
  var revData = [<c:forEach var="r" items="${dash.chartRevenues}" varStatus="s">${r}<c:if test="${!s.last}">,</c:if></c:forEach>];

  var ctx = document.getElementById('dashChart').getContext('2d');
  new Chart(ctx, {
    type: 'line',
    data: {
      labels: labels,
      datasets: [
        { label: '예약 건수', data: resvData, borderColor: '#2BAB82', backgroundColor: 'rgba(43,171,130,0.1)', tension: 0.3, yAxisID: 'y' },
        { label: '매출(원)', data: revData, borderColor: '#0284C7', backgroundColor: 'rgba(2,132,199,0.1)', tension: 0.3, yAxisID: 'y1' }
      ]
    },
    options: {
      responsive: true,
      interaction: { mode: 'index', intersect: false },
      plugins: { legend: { display: false } },
      scales: {
        y:  { type: 'linear', position: 'left',  beginAtZero: true, ticks: { precision: 0 } },
        y1: { type: 'linear', position: 'right', beginAtZero: true, grid: { drawOnChartArea: false },
              ticks: { callback: function(v){ return (v/10000).toFixed(0) + '만'; } } }
      }
    }
  });
})();
</script>

<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>
