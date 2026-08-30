<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="반려동물 숙소" />
<c:set var="bizPage"      value="calendar" />

<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_stay.jsp" %>

<%-- 2026-07-14 — 사업자(숙소) 예약 캘린더 DB 연동 --%>
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
    <p class="biz-page-desc">월별 예약 현황을 한눈에 확인하세요.</p>
  </div>

  <div class="biz-card" style="margin-bottom:16px">
    <div class="cal-legend">
      <span><span class="dot" style="background:#F5A623"></span>예약신청</span>
      <span><span class="dot" style="background:#4F6BC4"></span>예약확정</span>
      <span><span class="dot" style="background:#2BAB82"></span>숙박완료</span>
    </div>
    <div id="calendar"></div>
  </div>

  <div class="biz-card">
    <div class="biz-card-head"><span id="detailTitle">선택한 날짜의 예약</span></div>
    <div class="cal-detail" id="calDetail"></div>
  </div>
</main>

<script>
  function toKey(d) {
    return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0');
  }

  var statusLabel = { pending:'예약신청', confirmed:'예약확정', checkin:'체크인', checkout:'체크아웃', done:'숙박완료', cancel:'취소' };
  var statusColor = { pending:'#F5A623', confirmed:'#4F6BC4', checkin:'#2BAB82', checkout:'#0EA5E9', done:'#2BAB82', cancel:'#999' };
  var statusBadgeClass = { pending:'bs-wait', confirmed:'bs-ready', done:'bs-done' };

  var reservations = [
    <c:forEach var="r" items="${calendarReservations}" varStatus="st">
    {
      name: '<c:out value="${r.memberName}"/>',
      pet: '<c:out value="${r.petName}"/>',
      room: '<c:out value="${r.serviceName}"/>',
      checkin: '<fmt:formatDate value="${r.checkinDate}" pattern="yyyy-MM-dd"/>',
      checkout: '<fmt:formatDate value="${r.checkoutDate}" pattern="yyyy-MM-dd"/>',
      nightCnt: ${r.nightCnt},
      status: (function(cd){
        if (cd === 'PENDING') return 'pending';
        if (cd === 'CONFIRMED') return 'confirmed';
        if (cd === 'CHECKIN') return 'checkin';
        if (cd === 'CHECKOUT') return 'checkout';
        if (cd === 'DONE') return 'done';
        if (cd === 'CANCEL' || cd === 'REJECTED') return 'cancel';
        return 'pending';
      })('<c:out value="${r.statusCd}"/>')
    }<c:if test="${!st.last}">,</c:if>
    </c:forEach>
  ];

  // FullCalendar 이벤트: start=체크인, end=체크아웃 → 구간 막대로 표시
  var events = reservations.map(function (r) {
    return {
      title: r.room + ' · ' + r.name,
      start: r.checkin,
      end: r.checkout,
      color: statusColor[r.status],
      extendedProps: r
    };
  });

  // 해당 날짜에 이용 중인 예약: 체크인 ≤ 날짜 < 체크아웃
  function eventsOnDay(key) {
    return reservations.filter(function (r) {
      return key >= r.checkin && key < r.checkout;
    }).sort(function (a, b) { return a.checkin.localeCompare(b.checkin); });
  }

  function confirmedCountOnDay(key) {
    return reservations.filter(function (r) {
      return key >= r.checkin && key < r.checkout
        && (r.status === 'confirmed' || r.status === 'checkin' || r.status === 'checkout' || r.status === 'done');
    }).length;
  }

  function renderDetail(key) {
    var d = new Date(key);
    var confirmedCnt = confirmedCountOnDay(key);
    var allCnt = eventsOnDay(key).length;
    document.getElementById('detailTitle').textContent =
      (d.getMonth() + 1) + '월 ' + d.getDate() + '일 이용 현황 (확정 ' + confirmedCnt + '건 / 전체 ' + allCnt + '건)';

    var box = document.getElementById('calDetail');
    var list = eventsOnDay(key);

    if (list.length === 0) {
      box.innerHTML = '<div class="cal-detail-empty">해당 날짜에 이용 중인 예약이 없습니다.</div>';
      return;
    }

    box.innerHTML = '';
    list.forEach(function (r) {
      var item = document.createElement('div');
      item.className = 'cal-detail-item';
      item.innerHTML =
        '<span class="bs-badge ' + (statusBadgeClass[r.status] || '') + ' badge">' + statusLabel[r.status] + '</span>' +
        '<div class="info"><b>' + r.room + ' · ' + r.name + '</b>' +
        '<small>' + r.pet + ' · ' + r.checkin + ' ~ ' + r.checkout + ' (' + r.nightCnt + '박)</small></div>';
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
