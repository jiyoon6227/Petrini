<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="동물병원" />
<c:set var="bizPage"      value="calendar" />

<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_hospital.jsp" %>

<%-- 7/3, 사업자(병원) 예약 캘린더 — FullCalendar 라이브러리 적용 버전 --%>
<link href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.js"></script>

<style>
  .cal-legend{display:flex;gap:14px;align-items:center;flex-wrap:wrap;padding:18px 20px 0;font-size:12px;color:#666}
  .cal-legend .dot{width:9px;height:9px;border-radius:50%;display:inline-block;margin-right:5px}
  #calendar{padding:20px}

  .cal-detail{padding:18px 20px}
  .cal-detail-empty{text-align:center;color:#aaa;font-size:13px;padding:24px 0}
  .cal-detail-item{display:flex;align-items:center;gap:12px;padding:12px 0;border-bottom:1px solid #F5F6F4}
  .cal-detail-item:last-child{border-bottom:none}
  .cal-detail-item .badge{flex-shrink:0}
  .cal-detail-item .info b{font-size:13px;color:#1A1A2E}
  .cal-detail-item .info small{display:block;font-size:12px;color:#888;margin-top:2px}

  .fc{font-family:inherit}
  .fc .fc-button-primary{background:var(--biz-primary);border-color:var(--biz-primary)}
  .fc .fc-button-primary:hover{background:#238f6c;border-color:#238f6c}
  .fc .fc-daygrid-event{border:none;padding:1px 4px;font-size:11px}
  .fc .fc-toolbar-title{font-size:16px;font-weight:800;color:#1A1A2E}
</style>

<main class="biz-main">
  <div class="biz-page-head">
    <h1 class="biz-page-title">예약 캘린더</h1>
    <p class="biz-page-desc">월별 진료 예약 현황을 한눈에 확인하세요. 오늘 남은 확정 예약 수는 사이드바 캘린더 배지에서 확인하세요.</p>
  </div>

  <div class="biz-card" style="margin-bottom:16px">
    <div class="cal-legend">
      <span><span class="dot" style="background:#F5A623"></span>예약신청</span>
      <span><span class="dot" style="background:#3B82F6"></span>예약확정</span>
      <span><span class="dot" style="background:#2BAB82"></span>진료완료</span>
    </div>
    <div id="calendar"></div>
  </div>

  <div class="biz-card">
    <div class="biz-card-head"><span id="detailTitle">선택한 날짜의 예약</span></div>
    <div class="cal-detail" id="calDetail"></div>
  </div>
</main>

<script>
  // 2026-07-10 장우철 — 서버 예약 데이터 → FullCalendar (F7)
  // 2026/07/11 장우철 — 상태 분리 / 날짜 칸 숫자 제거(사이드바 배지로 이동)
  function toKey(d) {
    return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0');
  }

  var statusLabel = { pending:'예약신청', confirmed:'예약확정', done:'진료완료' };
  var statusColor = { pending:'#F5A623', confirmed:'#3B82F6', done:'#2BAB82' };
  var statusBadgeClass = { pending:'bs-wait', confirmed:'bs-ready', done:'bs-done' };

  var reservations = [
    <c:forEach var="r" items="${calendarReservations}" varStatus="st">
    {
      name: '<c:out value="${r.memberName}"/>',
      pet: '<c:out value="${r.petName}"/>',
      time: '<c:out value="${r.resvTime}"/>',
      endTime: '<c:out value="${r.endTime}"/>',
      doctor: '<c:out value="${r.doctorName}"/>',
      treatType: '<c:out value="${r.treatTypeName}"/>',
      date: '<fmt:formatDate value="${r.resvDate}" pattern="yyyy-MM-dd"/>',
      status: (function(cd){
        if (cd === 'PENDING') return 'pending';
        if (cd === 'CONFIRMED') return 'confirmed';
        if (cd === 'DONE') return 'done';
        return 'pending';
      })('<c:out value="${r.statusCd}"/>')
    }<c:if test="${!st.last}">,</c:if>
    </c:forEach>
  ];

  var events = reservations.map(function (r) {
    var timeLabel = r.time;
    if (r.endTime) timeLabel += '~' + r.endTime;
    var parts = [timeLabel];
    if (r.doctor) parts.push(r.doctor);
    if (r.treatType) parts.push(r.treatType);
    parts.push(r.name);
    return {
      title: parts.join(' · '),
      start: r.date + 'T' + r.time,
      color: statusColor[r.status],
      extendedProps: r
    };
  });

  function eventsOnDay(key) {
    return reservations.filter(function (r) { return r.date === key; })
                        .sort(function (a, b) { return a.time.localeCompare(b.time); });
  }

  function confirmedCountOnDay(key) {
    return reservations.filter(function (r) { return r.date === key && r.status === 'confirmed'; }).length;
  }

  function renderDetail(key) {
    var d = new Date(key);
    var confirmedCnt = confirmedCountOnDay(key);
    document.getElementById('detailTitle').textContent =
      (d.getMonth() + 1) + '월 ' + d.getDate() + '일 예약 (확정 ' + confirmedCnt + '건 / 전체 ' + eventsOnDay(key).length + '건)';

    var box = document.getElementById('calDetail');
    var list = eventsOnDay(key);

    if (list.length === 0) {
      box.innerHTML = '<div class="cal-detail-empty">해당 날짜에 예약이 없습니다.</div>';
      return;
    }

    box.innerHTML = '';
    list.forEach(function (r) {
      var item = document.createElement('div');
      item.className = 'cal-detail-item';
      item.innerHTML =
        '<span class="bs-badge ' + statusBadgeClass[r.status] + ' badge">' + statusLabel[r.status] + '</span>' +
        '<div class="info"><b>' + (r.endTime ? r.time + '~' + r.endTime : r.time)
        + (r.doctor ? ' · ' + r.doctor : '')
        + (r.treatType ? ' · ' + r.treatType : '')
        + ' · ' + r.name + '</b><small>' + r.pet + '</small></div>';
      box.appendChild(item);
    });
  }

  document.addEventListener('DOMContentLoaded', function () {
    var calendarEl = document.getElementById('calendar');
    var calendar = new FullCalendar.Calendar(calendarEl, {
      initialView: 'dayGridMonth',
      locale: 'ko',
      height: 'auto',
      headerToolbar: { left: 'prev,next today', center: 'title', right: '' },
      buttonText: { today: '오늘' },
      events: events,
      eventTimeFormat: { hour: '2-digit', minute: '2-digit', hour12: false },
      dateClick: function (info) {
        renderDetail(info.dateStr);
      },
      eventClick: function (info) {
        renderDetail(toKey(info.event.start));
      }
    });
    calendar.render();

    renderDetail(toKey(new Date()));
  });
</script>

<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>
