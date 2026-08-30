<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="contextPath"  value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="동물병원" />
<c:set var="bizPage"      value="dashboard" />

<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_hospital.jsp" %>


<%--HYJ 26.08.06 DB 연동--%>
<%--7/1, 곽지윤, 사업자(병원)대시보드 ui구성변경(after)--%>
<main class="biz-main hospital-dashboard">
  <div class="dashboard-top">
    <div>
      <h1>안녕하세요, ${hospital.name} 원장님!</h1>
      <p>오늘의 병원 현황을 한눈에 확인하세요.</p>
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
        <p>오늘 예약</p>
        <strong>${dash.todayResvCount} <span>건</span></strong>
        <c:if test="${dash.todayCancelCount > 0}">
          <span style="font-size:12px;color:#DC2626;margin-left:4px">(취소 ${dash.todayCancelCount}건)</span>
        </c:if>
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
      <div class="summary-icon purple">🩺</div>
      <div>
        <p>진료 대기</p>
        <strong>${dash.pendingCount} <span>건</span></strong>
        <small>승인 대기 중</small>
      </div>
    </div>
    <div class="summary-card">
      <div class="summary-icon blue">📋</div>
      <div>
        <p>진료 완료</p>
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
  <div class="summary-icon orange">✓</div>
  <div>
    <p>이번 달 진료완료</p>
    <strong><fmt:formatNumber value="${dash.monthDoneCount}" type="number"/> <span>건</span></strong>
    <small>어제 대비
      <c:choose>
        <c:when test="${dash.monthDoneDiff > 0}">▲ <fmt:formatNumber value="${dash.monthDoneDiff}" type="number"/>건</c:when>
        <c:when test="${dash.monthDoneDiff < 0}">▼ <fmt:formatNumber value="${-dash.monthDoneDiff}" type="number"/>건</c:when>
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
        <h3>예약 / 진료 현황</h3>
        <div class="tab-btns">
          <button class="active" data-period="daily">주간</button>
          <button data-period="monthly">월간</button>
        </div>
      </div>
      <div class="line-chart">
        <div class="chart-legend">
          <span class="green-dot"></span> 예약 건수
          <span class="blue-dot"></span> 진료완료
          <span class="red-dot"></span> 취소·노쇼
        </div>
        <canvas id="dashChart"></canvas>
      </div>
    </div>

    <div class="dash-card status-card">
      <div class="card-head"><h3>예약 상태 현황</h3></div>
      <div class="donut-wrap">
        <div class="donut-chart"><div><span>총 예약</span><strong>${dash.totalStatusCount}건</strong></div></div>
        <ul class="status-list">
          <li><span class="box green-box"></span>예약 확정 <b>${dash.statusConfirmed}건</b></li>
          <li><span class="box blue-box"></span>예약 대기 <b>${dash.statusPending}건</b></li>
          <li><span class="box orange-box"></span>진료 완료 <b>${dash.statusDone}건</b></li>
          <li><span class="box gray-box"></span>취소 <b>${dash.statusCancel}건</b></li>
        </ul>
      </div>
    </div>
  </section>

  <%-- ── 오늘 예약 + 최근 리뷰 ── --%>
  <section class="bottom-grid">
    <div class="dash-card">
      <div class="card-head">
        <h3>오늘의 예약 목록</h3>
        <a href="${contextPath}/biz/hospital/reserve" class="outline-btn">전체 예약 보기</a>
      </div>
      <table class="biz-table">
        <thead><tr><th>예약 시간</th><th>예약자</th><th>반려동물</th><th>담당 수의사</th><th>진료 항목</th><th>상태</th><th>관리</th></tr></thead>
        <tbody>
          <c:forEach var="r" items="${todayList}">
          <tr>
            <td>${r.resvTime}</td>
            <td>${r.memberName}</td>
            <td>${r.petName} (${r.petSpecies})</td>
            <td>${r.doctorName}</td>
            <td>${r.treatTypeName}</td>
            <td>
              <c:choose>
                <c:when test="${r.statusCd eq 'CONFIRMED'}"><span class="badge confirm">예약 확정</span></c:when>
                <c:when test="${r.statusCd eq 'PENDING'}"><span class="badge wait">예약 대기</span></c:when>
                <c:when test="${r.statusCd eq 'DONE'}"><span class="badge confirm">진료 완료</span></c:when>
                <c:when test="${r.statusCd eq 'CANCEL' || r.statusCd eq 'REJECTED'}"><span class="badge cancel">취소</span></c:when>
                <c:otherwise><span class="badge">${r.statusCd}</span></c:otherwise>
              </c:choose>
            </td>
            <td><a href="${contextPath}/biz/hospital/reserve" class="detail-btn">상세보기</a></td>
          </tr>
          </c:forEach>
          <c:if test="${empty todayList}">
          <tr><td colspan="7" style="text-align:center; color:#999; padding:24px;">오늘 예약이 없습니다.</td></tr>
          </c:if>
        </tbody>
      </table>
    </div>

    <div class="dash-card review-card">
      <div class="card-head">
        <h3>최근 리뷰</h3>
        <a href="${contextPath}/biz/hospital/reviews" class="outline-btn">전체 리뷰 보기</a>
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
  var doneData = [<c:forEach var="c" items="${dash.chartDoneCounts}" varStatus="s">${c}<c:if test="${!s.last}">,</c:if></c:forEach>];
  var cancelData = [<c:forEach var="c" items="${dash.chartCancelCounts}" varStatus="s">${c}<c:if test="${!s.last}">,</c:if></c:forEach>];

  var ctx = document.getElementById('dashChart').getContext('2d');
  var chart = new Chart(ctx, {
    data: {
      labels: labels,
      datasets: [
        { type: 'bar', label: '예약 건수', data: resvData, backgroundColor: '#2BAB82', borderRadius: 4, maxBarThickness: 36, order: 2 },
        { type: 'line', label: '진료완료', data: doneData, borderColor: '#0284C7', backgroundColor: '#0284C7', tension: 0, pointRadius: 4, pointBackgroundColor: '#0284C7', order: 1 },
        { type: 'line', label: '취소·노쇼', data: cancelData, borderColor: '#E34948', backgroundColor: '#E34948', borderDash: [5, 4], tension: 0, pointRadius: 3, pointBackgroundColor: '#E34948', order: 0 }
      ]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      interaction: { mode: 'index', intersect: false },
      plugins: { legend: { display: false } },
      scales: {
        x: { ticks: { maxTicksLimit: 10, padding: 20 } },
        y: { beginAtZero: true, ticks: { precision: 0 } }
      }
    }
  });

  var tabBtns = document.querySelectorAll('.tab-btns button');
  tabBtns.forEach(function(btn){
    btn.addEventListener('click', function(){
      tabBtns.forEach(function(b){ b.classList.remove('active'); });
      btn.classList.add('active');

      var period = btn.getAttribute('data-period');
      fetch('${contextPath}/biz/hospital/dashboard/chart?period=' + period)
        .then(function(res){ return res.json(); })
        .then(function(list){
          chart.data.labels = list.map(function(d){ return d.dt; });
          chart.data.datasets[0].data = list.map(function(d){ return d.resvCount; });
          chart.data.datasets[1].data = list.map(function(d){ return d.doneCount; });
          chart.data.datasets[2].data = list.map(function(d){ return d.cancelCount; });
          chart.update();
        });
    });
  });
})();
</script>

<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>
