<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="반려동물 숙소" />
<c:set var="bizPage"      value="reserve" />

<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_stay.jsp" %>

<style>
  .rv-modal-bg{display:none;position:fixed;inset:0;background:rgba(0,0,0,.45);z-index:1000;align-items:center;justify-content:center;padding:20px}
  .rv-modal-bg.open{display:flex}
  .rv-modal{background:#fff;border-radius:14px;width:100%;max-width:520px;max-height:90vh;overflow:auto;box-shadow:0 12px 40px rgba(0,0,0,.15)}
  .rv-modal-head{display:flex;justify-content:space-between;align-items:center;padding:18px 20px;border-bottom:1px solid #E2E8E4}
  .rv-modal-head h3{margin:0;font-size:17px;font-weight:800;color:#1A1A2E}
  .rv-modal-close{background:none;border:none;font-size:24px;cursor:pointer;color:#888;line-height:1}
  .rv-modal-body{padding:20px;display:flex;flex-direction:column;gap:12px}
  .rv-row{display:flex;justify-content:space-between;font-size:14px;gap:12px}
  .rv-row span:first-child{color:#888;flex-shrink:0}
  .rv-row span:last-child{color:#1A1A2E;font-weight:600;text-align:right}
</style>

<%-- 2026-07-14 — 사업자(숙소) 예약 관리 DB 연동 --%>
<main class="biz-main">
  <div class="biz-page-head">
    <h1 class="biz-page-title">예약 관리</h1>
    <p class="biz-page-desc">숙박 예약을 확인하고 상태를 관리하세요.</p>
  </div>

  <c:if test="${not empty msg}">
    <div style="margin-bottom:12px;padding:12px 16px;background:#E8F8F1;color:#1F8464;border-radius:8px;font-size:14px">${msg}</div>
  </c:if>
  <c:if test="${not empty errorMsg}">
    <div style="margin-bottom:12px;padding:12px 16px;background:#FEF2F2;color:#B91C1C;border-radius:8px;font-size:14px">${errorMsg}</div>
  </c:if>

  <div class="biz-card">
    <div style="padding:20px 20px 0">
      <div class="biz-tabs">
        <button type="button" class="biz-tab active" data-tab="all" onclick="switchTab('all')">전체<span class="biz-tab-count" id="cntAll"></span></button>
        <button type="button" class="biz-tab" data-tab="pending" onclick="switchTab('pending')">예약신청<span class="biz-tab-count" id="cntPending"></span></button>
        <button type="button" class="biz-tab" data-tab="confirmed" onclick="switchTab('confirmed')">예약확정<span class="biz-tab-count" id="cntConfirmed"></span></button>
        <button type="button" class="biz-tab" data-tab="checkin" onclick="switchTab('checkin')">체크인<span class="biz-tab-count" id="cntCheckin"></span></button>
        <button type="button" class="biz-tab" data-tab="checkout" onclick="switchTab('checkout')">체크아웃<span class="biz-tab-count" id="cntCheckout"></span></button>
        <button type="button" class="biz-tab" data-tab="done" onclick="switchTab('done')">숙박완료<span class="biz-tab-count" id="cntDone"></span></button>
        <button type="button" class="biz-tab" data-tab="cancel" onclick="switchTab('cancel')">취소<span class="biz-tab-count" id="cntCancel"></span></button>
      </div>
    </div>

    <table class="biz-table">
      <thead>
        <tr>
          <th style="width:11%">예약번호</th>
          <th style="width:10%">예약자</th>
          <th style="width:14%">반려동물</th>
          <th style="width:12%">객실</th>
          <th style="width:18%">숙박기간</th>
          <th style="width:10%">결제금액</th>
          <th style="width:8%">상태</th>
          <th>관리</th>
        </tr>
      </thead>
      <tbody id="reserveBody"></tbody>
    </table>
  </div>
</main>

<div class="biz-toast" id="saveToast">
  <svg viewBox="0 0 24 24" fill="none" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
  <span id="toastMsg">처리되었습니다.</span>
</div>

<%-- 예약 상세 모달 --%>
<div class="rv-modal-bg" id="reserveModalBg" onclick="if(event.target===this) closeReserveModal()">
  <div class="rv-modal">
    <div class="rv-modal-head">
      <h3>예약 상세</h3>
      <button type="button" class="rv-modal-close" onclick="closeReserveModal()">×</button>
    </div>
    <div class="rv-modal-body">
      <div class="rv-row"><span>예약자</span><span id="mdMember">-</span></div>
      <div class="rv-row"><span>반려동물</span><span id="mdPet">-</span></div>
      <div class="rv-row"><span>동반 마리수</span><span id="mdPetCnt">-</span></div>
      <div class="rv-row"><span>객실</span><span id="mdRoom">-</span></div>
      <div class="rv-row"><span>체크인</span><span id="mdCheckin">-</span></div>
      <div class="rv-row"><span>체크아웃</span><span id="mdCheckout">-</span></div>
      <div class="rv-row"><span>숙박일수</span><span id="mdNights">-</span></div>
      <div class="rv-row"><span>결제금액</span><span id="mdAmount">-</span></div>
      <div class="rv-row"><span>요청사항</span><span id="mdMemo">-</span></div>
    </div>
  </div>
</div>

<%-- 예약취소 사유 모달 --%>
<div class="rv-modal-bg" id="cancelModalBg" onclick="if(event.target===this) closeCancelModal()">
  <div class="rv-modal">
    <div class="rv-modal-head">
      <h3>예약 취소</h3>
      <button type="button" class="rv-modal-close" onclick="closeCancelModal()">×</button>
    </div>
    <div class="rv-modal-body">
      <p style="margin:0 0 8px;font-size:13px;color:#666">취소 사유를 입력해 주세요. (필수)</p>
      <textarea id="cancelReasonInput" maxlength="500" rows="4"
        style="width:100%;box-sizing:border-box;border:1px solid #E2E8E4;border-radius:8px;padding:12px;font-size:14px;font-family:inherit;resize:vertical"
        placeholder="예: 시설 점검으로 해당 일자 운영이 어렵습니다."></textarea>
      <div style="display:flex;gap:8px;justify-content:flex-end;margin-top:14px">
        <button type="button" class="biz-btn ghost" onclick="closeCancelModal()">닫기</button>
        <button type="button" class="biz-btn danger" onclick="submitCancel()">예약취소</button>
      </div>
    </div>
  </div>
</div>

<script>
  // 서버 데이터 → JS 배열
  // 2026/08/06 장우철 — CSRF는 문자열로 보관 (UUID 미인용 삽입 시 스크립트 파싱 깨짐)
  // meta 우선 (헤더에 항상 있음)
  var csrfToken = (document.querySelector('meta[name="_csrf"]') || {}).content
      || '<c:out value="${_csrf}"/>';
  var reservations = [
    <c:forEach var="r" items="${reservationList}" varStatus="st">
    {
      resvId: ${r.resvId},
      resvNo: '<c:out value="${r.resvNo}"/>',
      name: '<c:out value="${r.memberName}"/>',
      pet: '<c:out value="${r.petName}"/> (<c:out value="${r.petSpecies}"/>)',
      roomName: '<c:out value="${r.roomName}"/>',
      checkinStr: '<fmt:formatDate value="${r.checkinDate}" pattern="yyyy-MM-dd"/>',
      checkinLabel: '<fmt:formatDate value="${r.checkinDate}" pattern="M/d"/>',
      checkoutStr: '<fmt:formatDate value="${r.checkoutDate}" pattern="yyyy-MM-dd"/>',
      checkoutLabel: '<fmt:formatDate value="${r.checkoutDate}" pattern="M/d"/>',
      nightCnt: ${r.nightCnt != null ? r.nightCnt : 0},
      totalAmount: ${r.totalAmount != null ? r.totalAmount : 0},
      requestMemo: '<c:out value="${r.requestMemo}"/>',
      statusCd: '<c:out value="${r.statusCd}"/>',
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

  var currentTab = 'all';
  var contextPath = '${contextPath}';

  var badgeMap = {
    pending:   { cls: 'bs-wait',   label: '예약신청' },
    confirmed: { cls: 'bs-ready',  label: '예약확정' },
    checkin:   { cls: 'bs-ready',  label: '체크인' },
    checkout:  { cls: 'bs-ready',  label: '체크아웃' },
    done:      { cls: 'bs-done',   label: '숙박완료' },
    cancel:    { cls: 'bs-cancel', label: '취소' }
  };

  function fmtWon(n) { return n ? n.toLocaleString('ko-KR') + '원' : '-'; }

  function switchTab(tab) {
    currentTab = tab;
    document.querySelectorAll('.biz-tab').forEach(function(b) { b.classList.toggle('active', b.dataset.tab === tab); });
    renderTable();
  }

  function renderTable() {
    var list = reservations.filter(function(r) { return currentTab === 'all' || r.status === currentTab; });

    document.getElementById('cntAll').textContent = reservations.length;
    document.getElementById('cntPending').textContent = reservations.filter(function(r) { return r.status === 'pending'; }).length;
    document.getElementById('cntConfirmed').textContent = reservations.filter(function(r) { return r.status === 'confirmed'; }).length;
    document.getElementById('cntCheckin').textContent = reservations.filter(function(r) { return r.status === 'checkin'; }).length;
    document.getElementById('cntCheckout').textContent = reservations.filter(function(r) { return r.status === 'checkout'; }).length;
    document.getElementById('cntDone').textContent = reservations.filter(function(r) { return r.status === 'done'; }).length;
    document.getElementById('cntCancel').textContent = reservations.filter(function(r) { return r.status === 'cancel'; }).length;

    var body = document.getElementById('reserveBody');
    body.innerHTML = '';

    if (list.length === 0) {
      body.innerHTML = '<tr><td colspan="8" style="text-align:center;color:#aaa;padding:60px 0">해당 예약이 없습니다.</td></tr>';
      return;
    }

    list.forEach(function(r) {
      var badge = badgeMap[r.status] || badgeMap.pending;
      var tr = document.createElement('tr');

      var actionHtml = '<button type="button" class="biz-btn ghost" onclick="openReserveModal(' + r.resvId + ')">상세</button> ';
      if (r.status === 'pending') {
        actionHtml +=
          '<button type="button" class="biz-btn" onclick="postStatus(' + r.resvId + ',\'CONFIRMED\')">예약확정</button> ' +
          '<button type="button" class="biz-btn danger" onclick="openCancelModal(' + r.resvId + ')">예약취소</button>';
      } else if (r.status === 'confirmed') {
        actionHtml +=
          '<button type="button" class="biz-btn" onclick="postStatus(' + r.resvId + ',\'CHECKIN\')">체크인</button> ' +
          '<button type="button" class="biz-btn danger" onclick="openCancelModal(' + r.resvId + ')">예약취소</button>';
      } else if (r.status === 'checkin') {
        actionHtml +=
          '<button type="button" class="biz-btn" onclick="postStatus(' + r.resvId + ',\'CHECKOUT\')">체크아웃</button> ' +
          '<button type="button" class="biz-btn danger" onclick="openCancelModal(' + r.resvId + ')">예약취소</button>';
      } else if (r.status === 'checkout') {
        actionHtml += '<span style="font-size:12px;color:#888">완료 대기(자동)</span>';
      }

      var periodHtml = r.checkinLabel + '~' + r.checkoutLabel;
      if (r.nightCnt > 0) periodHtml += '<br><small style="color:#999">(' + r.nightCnt + '박' + (r.nightCnt+1) + '일)</small>';

      tr.innerHTML =
        '<td>' + r.resvNo + '</td>' +
        '<td>' + r.name + '</td>' +
        '<td>' + r.pet + '</td>' +
        '<td>' + (r.roomName || '-') + '</td>' +
        '<td>' + periodHtml + '</td>' +
        '<td>' + fmtWon(r.totalAmount) + '</td>' +
        '<td><span class="bs-badge ' + badge.cls + '">' + badge.label + '</span></td>' +
        '<td>' + actionHtml + '</td>';
      body.appendChild(tr);
    });
  }

  function postStatus(resvId, statusCd) {
    if (statusCd === 'CONFIRMED' && !confirm('예약을 확정하시겠습니까?')) return;
    if (statusCd === 'CHECKIN' && !confirm('체크인 처리하시겠습니까?')) return;
    if (statusCd === 'CHECKOUT' && !confirm('체크아웃 처리하시겠습니까?')) return;

    var form = document.createElement('form');
    form.method = 'POST';
    form.action = contextPath + '/biz/stay/reserve/status';
    form.innerHTML =
      '<input type="hidden" name="resvId" value="' + resvId + '">' +
      '<input type="hidden" name="statusCd" value="' + statusCd + '">' +
      '<input type="hidden" name="_csrf" value="${_csrf}">';
    document.body.appendChild(form);
    form.submit();
  }

  // 취소 사유 모달
  var cancelTargetResvId = null;

  function openCancelModal(resvId) {
    cancelTargetResvId = resvId;
    document.getElementById('cancelReasonInput').value = '';
    document.getElementById('cancelModalBg').classList.add('open');
  }

  function closeCancelModal() {
    cancelTargetResvId = null;
    document.getElementById('cancelModalBg').classList.remove('open');
  }

  function submitCancel() {
    var reason = document.getElementById('cancelReasonInput').value.trim();
    if (!reason) {
      alert('취소 사유를 입력해 주세요.');
      document.getElementById('cancelReasonInput').focus();
      return;
    }
    if (!cancelTargetResvId) return;

    var form = document.createElement('form');
    form.method = 'POST';
    form.action = contextPath + '/biz/stay/reserve/status';
    form.innerHTML =
      '<input type="hidden" name="resvId" value="' + cancelTargetResvId + '">' +
      '<input type="hidden" name="statusCd" value="CANCEL">' +
      '<input type="hidden" name="cancelReason" value="">' +
      '<input type="hidden" name="_csrf" value="${_csrf}">';
    form.querySelector('input[name="cancelReason"]').value = reason;
    document.body.appendChild(form);
    form.submit();
  }

  // 상세 모달
  function openReserveModal(resvId) {
    fetch(contextPath + '/biz/stay/reserve/detail?resvId=' + resvId)
      .then(function(res) { return res.json(); })
      .then(function(data) {
        if (!data) { alert('예약 정보를 불러올 수 없습니다.'); return; }
        document.getElementById('mdMember').textContent = data.memberName || '-';
        var petLabel = data.petName || '-';
        if (data.petBreed) petLabel += ' (' + data.petBreed + ')';
        document.getElementById('mdPet').textContent = petLabel;
        var petCnt = data.petCnt != null ? data.petCnt : 1;
        document.getElementById('mdPetCnt').textContent = petCnt + '마리'
            + (petCnt > 1 ? ' (대표 펫 + 추가 ' + (petCnt - 1) + ')' : '');
        document.getElementById('mdRoom').textContent = data.roomName || '-';
        document.getElementById('mdCheckin').textContent = data.checkinDate ? String(data.checkinDate).substring(0, 10) : '-';
        document.getElementById('mdCheckout').textContent = data.checkoutDate ? String(data.checkoutDate).substring(0, 10) : '-';
        document.getElementById('mdNights').textContent = data.nightCnt ? data.nightCnt + '박' + (data.nightCnt+1) + '일' : '-';
        document.getElementById('mdAmount').textContent = data.totalAmount ? data.totalAmount.toLocaleString('ko-KR') + '원' : '-';
        document.getElementById('mdMemo').textContent = data.requestMemo || '-';
        document.getElementById('reserveModalBg').classList.add('open');
      })
      .catch(function() { alert('예약 정보를 불러올 수 없습니다.'); });
  }

  function closeReserveModal() {
    document.getElementById('reserveModalBg').classList.remove('open');
  }

  renderTable();
</script>

<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>
