<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="반려동물 쇼핑몰" />
<c:set var="bizPage"      value="delivery" />

<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_store.jsp" %>

<%--
     Controller: BizStoreController.storeDelivery() / bulkDelivery()
     Service: BizStoreService.getDeliveryList / getDeliverySummary / bulkRegisterDelivery
     개별 "송장수정" 저장은 새로 안 만들고, 주문관리(orders.jsp) 때 만든
     POST /biz/store/orders/{id}/status API를 그대로 재사용함
     화면 레이아웃(CSS, HTML 뼈대)은 원본 그대로 유지 --%>
<style>
  .dlv-summary{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:16px}
  .dlv-summary-card{background:#fff;border:1px solid var(--biz-border);border-radius:12px;padding:16px 18px}
  .dlv-summary-card .label{font-size:12px;color:#888;margin-bottom:6px}
  .dlv-summary-card .val{font-size:22px;font-weight:800;color:#1A1A2E}
  .dlv-summary-card .val span{font-size:13px;font-weight:600;color:#888;margin-left:2px}
  .dlv-summary-card.warn .val{color:#E24B4A}

  .dlv-filter{display:flex;flex-wrap:wrap;align-items:center;gap:10px;padding:18px 20px}
  .dlv-filter select,.dlv-filter input{border:1px solid var(--biz-border);border-radius:8px;padding:8px 10px;font-size:13px;color:#333}
  .dlv-filter .btn-search{background:var(--biz-primary);color:#fff;border:none;border-radius:8px;padding:9px 18px;font-size:13px;font-weight:700;cursor:pointer}
  .dlv-filter .btn-reset{background:#fff;border:1px solid var(--biz-border);border-radius:8px;padding:9px 16px;font-size:13px;font-weight:600;color:#555;cursor:pointer}
  .dlv-table-head{display:flex;align-items:center;justify-content:space-between;padding:0 20px}

  .dlv-bulk-box{padding:20px}
  .dlv-bulk-box textarea{width:100%;min-height:120px;border:1px solid var(--biz-border);border-radius:8px;padding:10px;font-size:13px;font-family:monospace}
  .dlv-bulk-hint{font-size:12px;color:#888;margin:6px 0 14px}
  .dlv-bulk-actions{display:flex;justify-content:flex-end;gap:8px}
</style>

<main class="biz-main">
  <div class="biz-page-head">
    <h1 class="biz-page-title">배송 관리</h1>
    <p class="biz-page-desc">택배사·송장번호를 등록하고 배송 현황을 추적하세요.</p>
  </div>

  <%-- ${summary.READY} 등 Controller 집계값 출력 --%>
  <div class="dlv-summary" id="dlvSummaryBox">
    <div class="dlv-summary-card"><div class="label">배송준비</div><div class="val">${summary.READY}<span>건</span></div></div>
    <div class="dlv-summary-card"><div class="label">배송중</div><div class="val">${summary.SHIPPING}<span>건</span></div></div>
    <div class="dlv-summary-card"><div class="label">배송완료</div><div class="val">${summary.DONE}<span>건</span></div></div>
    <div class="dlv-summary-card warn"><div class="label">배송지연 (3일 이상 배송중)</div><div class="val">${summary.DELAY}<span>건</span></div></div>
  </div>

  <%-- method="get" 폼 제출 (쿼리 파라미터로 서버 필터) --%>
  <div class="biz-card" style="margin-bottom:16px">
    <form class="dlv-filter" method="get" action="${contextPath}/biz/store/delivery">
      <select name="carrier" id="filterCarrier">
        <option value="">택배사 전체</option>
        <%-- JS에서 스마트택배 API로 택배사 전체 목록 채움 --%>
      </select>
      <select name="statusCd">
        <option value="">배송상태 전체</option>
        <option value="READY"    ${selectedStatusCd == 'READY' ? 'selected' : ''}>배송준비</option>
        <option value="SHIPPING" ${selectedStatusCd == 'SHIPPING' ? 'selected' : ''}>배송중</option>
        <option value="DONE"     ${selectedStatusCd == 'DONE' ? 'selected' : ''}>배송완료</option>
      </select>
      <input type="text" name="keyword" value="${selectedKeyword}" placeholder="주문번호 또는 구매자명">
      <button type="submit" class="btn-search">검색</button>
      <button type="button" class="btn-reset" onclick="location.href='${contextPath}/biz/store/delivery'">초기화</button>
    </form>
  </div>

  <div class="biz-card" style="margin-bottom:16px" id="dlvListCard">
    <div class="dlv-table-head">
      <%-- ${deliveryList.size()} 서버값 출력 --%>
      <div class="biz-card-head" style="padding:20px 0 12px"><span>배송 목록</span><small>총 ${deliveryList.size()}건</small></div>
    </div>
    <table class="biz-table">
      <thead><tr><th>주문번호</th><th>구매자</th><th>택배사</th><th>송장번호</th><th>상태</th><th>발송일</th><th>관리</th></tr></thead>
      <%-- JSTL로 ${deliveryList} 렌더링 --%>
      <tbody>
        <c:choose>
          <c:when test="${empty deliveryList}">
            <tr><td colspan="7" style="text-align:center;color:#999;padding:24px 0">해당하는 배송 건이 없습니다.</td></tr>
          </c:when>
          <c:otherwise>
            <c:forEach var="d" items="${deliveryList}">
              <tr>
                <td>#${d.orderNo}</td>
                <td>${d.buyerName}</td>
                <%-- JSTL c:choose로 택배사코드 → 한글명 분기 --%>
                <%-- 예전 영문코드값 데이터도 표시, 신규 택배사명은 그대로 출력 --%>
                <td>
                  <c:choose>
                    <c:when test="${d.courierName == 'cj'}">CJ대한통운</c:when>
                    <c:when test="${d.courierName == 'hanjin'}">한진택배</c:when>
                    <c:when test="${d.courierName == 'lotte'}">롯데택배</c:when>
                    <c:when test="${d.courierName == 'post'}">우체국택배</c:when>
                    <c:when test="${empty d.courierName}">-</c:when>
                    <c:otherwise>${d.courierName}</c:otherwise>
                  </c:choose>
                </td>
                <td>${empty d.trackingNo ? '-' : d.trackingNo}</td>
                <td>
                  <c:choose>
                    <%-- orders.jsp와 동일한 색상 (READY=보라, SHIPPING=파랑, DONE=초록) --%>
                    <c:when test="${d.orderStatus == 'READY'}"><span class="bs-badge bs-prep">배송준비</span></c:when>
                    <c:when test="${d.orderStatus == 'SHIPPING'}"><span class="bs-badge bs-ready">배송중</span></c:when>
                    <c:when test="${d.orderStatus == 'DONE'}"><span class="bs-badge bs-done">배송완료</span></c:when>
                  </c:choose>
                  <%-- Service에서 계산한 d.delayed(boolean) 사용 --%>
                  <c:if test="${d.delayed}"><span class="bs-badge bs-cancel" style="margin-left:4px">지연</span></c:if>
                </td>
                <td>${empty d.shipDate ? '-' : d.shipDate}</td>
                <%-- openEdit(ORDER_ID, 현재값들)로 모달 바로 채움 (AJAX 재조회 없음) --%>
                <td>
  <button class="biz-btn" onclick="openEdit(${d.orderId}, '${d.orderNo}', '${d.orderStatus}', '${d.courierName}', '${d.courierCode}', '${d.trackingNo}')">${empty d.trackingNo ? '송장등록' : '수정'}</button>
  <c:if test="${not empty d.trackingNo and not empty d.courierCode}">
    <button class="biz-btn" onclick="trackDelivery(${d.orderId}, '${d.courierCode}', '${d.trackingNo}')">배송조회</button>
  </c:if>
  <%-- 배송완료 수동처리 (SHIPPING일 때만, 확인창 후 실행) --%>
  <c:if test="${d.orderStatus == 'SHIPPING'}">
    <button class="biz-btn" onclick="forceComplete(${d.orderId})">수동완료</button>
  </c:if>
</td>

              </tr>
            </c:forEach>
          </c:otherwise>
        </c:choose>
      </tbody>
    </table>
  </div>

  <%-- 아래 일괄등록/수정 폼 HTML 뼈대는 원본 그대로, 안 건드림 --%>
  <div class="biz-card" id="bulkCard" style="display:none">
    <div class="biz-card-head"><span>송장 일괄등록</span></div>
    <div class="dlv-bulk-box">
      <p class="dlv-bulk-hint">한 줄에 하나씩, <b>주문번호,택배사코드,송장번호</b> 형식으로 입력하세요. 택배사코드: cj / hanjin / lotte / post<br>예) ORD-2026-0892,cj,651234567890</p>
      <textarea id="bulkText" placeholder="ORD-2026-0892,cj,651234567890&#10;ORD-2026-0891,hanjin,482910384710"></textarea>
      <div class="dlv-bulk-actions">
        <button type="button" class="biz-btn-ghost" onclick="closeBulk()">취소</button>
        <button type="button" class="biz-btn-primary" onclick="submitBulk()">일괄 등록</button>
      </div>
    </div>
  </div>

  <div class="biz-card" id="editCard" style="display:none">
    <div class="biz-card-head"><span>송장 수정</span></div>
    <form style="padding:20px;max-width:480px">
      <div class="biz-form-fields">
        <div class="biz-form-row">
          <label>주문번호</label>
          <input type="text" id="eOrderNo" readonly style="background:#FAFBFA">
        </div>
        <div class="biz-form-row">
          <label>배송상태<span class="req">*</span></label>
          <%-- value는 DB(TB_ORDER.ORDER_STATUS) 코드값(READY 등) --%>
          <%-- DONE(배송완료) 옵션 없음 (자동완료/수동완료 버튼으로만 처리) --%>
<select id="eStatus">
  <option value="READY">배송준비</option>
  <option value="SHIPPING">배송중</option>
</select>
        </div>
        <div class="biz-form-row">
          <label>택배사<span class="req">*</span></label>
          <select id="eCarrier">
            <%-- JS에서 스마트택배 API로 택배사 전체 목록 채움 --%>
          </select>
        </div>
        <div class="biz-form-row">
          <label>송장번호<span class="req">*</span></label>
          <input type="text" id="eTrackingNo" placeholder="송장번호를 입력하세요">
        </div>
      </div>
      <div class="dlv-bulk-actions" style="margin-top:16px">
        <button type="button" class="biz-btn-ghost" onclick="closeEdit()">취소</button>
        <button type="button" class="biz-btn-primary" onclick="submitEdit()">저장</button>
      </div>
    </form>
  </div>

  <%-- 실시간 배송조회 결과 모달 --%>
  <div class="biz-card" id="trackCard" style="display:none">
    <div class="biz-card-head"><span>실시간 배송조회</span></div>
    <div id="trackResultBox" style="padding:20px"></div>
    <div class="dlv-bulk-actions" style="padding:0 20px 20px">
      <button type="button" class="biz-btn-ghost" onclick="closeTrack()">닫기</button>
    </div>
  </div>
</main>

<div class="biz-toast" id="saveToast">
  <svg viewBox="0 0 24 24" fill="none" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
  <span id="saveToastMsg">처리되었습니다.</span>
</div>

<script>
  var contextPath = '${contextPath}';
  var eOrderId = null;

  // 스마트택배 API로 전체 택배사 목록 가져와서 드롭다운 2개(필터/수정모달) 채움
  var courierList = [];
  fetch(contextPath + '/biz/store/delivery/companies')
    .then(function (res) { return res.json(); })
    .then(function (list) {
      courierList = list || [];
      var filterSel = document.getElementById('filterCarrier');
      var editSel = document.getElementById('eCarrier');
      courierList.forEach(function (c) {
        var opt1 = document.createElement('option');
        opt1.value = c.id; opt1.textContent = c.name;
        if ('${selectedCarrier}' === c.id) opt1.selected = true;
        filterSel.appendChild(opt1);

        var opt2 = document.createElement('option');
        opt2.value = c.id; opt2.textContent = c.name;
        editSel.appendChild(opt2);
      });
    })
    .catch(function () {
      var filterSel = document.getElementById('filterCarrier');
      var editSel = document.getElementById('eCarrier');
      var msg = '<option value="">택배사 목록을 불러올 수 없습니다</option>';
      filterSel.insertAdjacentHTML('beforeend', msg);
      editSel.insertAdjacentHTML('beforeend', msg);
    });

  function openBulk() {
    document.getElementById('bulkCard').style.display = 'block';
    document.getElementById('editCard').style.display = 'none';
    document.getElementById('bulkCard').scrollIntoView({ behavior: 'smooth', block: 'start' });
  }
  function closeBulk() {
    document.getElementById('bulkCard').style.display = 'none';
    document.getElementById('bulkText').value = '';
  }

  // submitBulk(): 서버(/biz/store/delivery/bulk)에 텍스트 전송, 파싱/저장은 BizStoreServiceImpl.bulkRegisterDelivery
  function submitBulk() {
    var bulkText = document.getElementById('bulkText').value.trim();
    if (!bulkText) { alert('입력된 내용이 없습니다.'); return; }
    csrfFetch(contextPath + '/biz/store/delivery/bulk', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: 'bulkText=' + encodeURIComponent(bulkText)
    })
      .then(function (res) { return res.json(); })
      .then(function (result) {
        closeBulk();
        if (result.failLines && result.failLines.length > 0) {
          alert(result.okCount + '건 등록 완료, ' + result.failLines.length + '건은 형식이 맞지 않거나 존재하지 않는 주문이라 실패했습니다:\n' + result.failLines.join('\n'));
        } else {
          alert(result.okCount + '건의 송장이 등록되었습니다.');
        }
        location.reload();
      });
  }

  // openEdit(): 목록 렌더링 시 넘긴 값으로 별도 AJAX 조회 없이 모달 채움
  function openEdit(orderId, orderNo, status, carrier, courierCode, trackingNo) {
    eOrderId = orderId;
    document.getElementById('eOrderNo').value = orderNo;
    document.getElementById('eStatus').value = status;
    document.getElementById('eCarrier').value = (courierCode && courierCode !== 'null') ? courierCode : '';
    document.getElementById('eTrackingNo').value = (trackingNo === 'null' ? '' : trackingNo);
    document.getElementById('bulkCard').style.display = 'none';
    document.getElementById('editCard').style.display = 'block';
    document.getElementById('editCard').scrollIntoView({ behavior: 'smooth', block: 'start' });
  }
  function closeEdit() {
    document.getElementById('editCard').style.display = 'none';
  }

  // submitEdit(): POST /biz/store/orders/{id}/status 재사용해 DB 저장
  function submitEdit() {
    var trackingNo = document.getElementById('eTrackingNo').value.trim();
    if (!trackingNo) { alert('송장번호를 입력해주세요.'); return; }

    var carrierSelect = document.getElementById('eCarrier');
    var selectedOption = carrierSelect.options[carrierSelect.selectedIndex];

    var formData = new URLSearchParams();
    formData.set('orderStatus', document.getElementById('eStatus').value);
    formData.set('courierName', selectedOption ? selectedOption.textContent : '');
    formData.set('courierCode', carrierSelect.value);
    formData.set('trackingNo', trackingNo);
    csrfFetch(contextPath + '/biz/store/orders/' + eOrderId + '/status', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: formData.toString()
    })
      .then(function (res) { return res.text(); })
      .then(function (result) {
        if (result === 'OK') {
          location.reload();
        } else {
          alert('저장에 실패했습니다.');
        }
      });
  }

  // 실시간 배송조회 (스마트택배 API 호출 결과를 화면에 표시)
  var levelLabel = { 1: '배송준비중', 2: '집화완료', 3: '배송중', 4: '지점도착', 5: '배송출발', 6: '배송완료' };

  function trackDelivery(orderId, courierCode, trackingNo) {
  document.getElementById('trackResultBox').innerHTML = '<p style="text-align:center;color:#999">조회 중...</p>';
  document.getElementById('bulkCard').style.display = 'none';
  document.getElementById('editCard').style.display = 'none';
  document.getElementById('trackCard').style.display = 'block';
  document.getElementById('trackCard').scrollIntoView({ behavior: 'smooth', block: 'start' });

  // orderId 함께 전송 (서버에서 level==6 확인 시 주문상태 자동 DONE)
  fetch(contextPath + '/biz/store/delivery/track?orderId=' + orderId + '&courierCode=' + encodeURIComponent(courierCode) + '&trackingNo=' + encodeURIComponent(trackingNo))
    .then(function (res) { return res.json(); })
    .then(function (data) {
      var box = document.getElementById('trackResultBox');
      if (!data || data.status === false || data.result === 'N') {
        box.innerHTML = '<p style="color:#E24B4A">배송 정보를 조회할 수 없습니다. (' + (data && data.msg ? data.msg : '알 수 없는 운송장번호') + ')</p>';
        return;
      }

      var html = '<p style="font-sweight:700;font-size:15px;margin-bottom:12px">현재 상태: ' + (levelLabel[data.level] || data.level) + '</p>';
// level 2~5(이동중) 자동승격 안내, level 6 완료 안내
if (data.level === 6) {
  html += '<p style="color:#2BAB82;font-size:13px;margin-bottom:12px">✓ 실제 배송완료가 확인되어 주문상태가 자동으로 "배송완료"로 갱신되었습니다.</p>';
} else if (data.level >= 2) {
  html += '<p style="color:#2B7FE0;font-size:13px;margin-bottom:12px">✓ 배송 진행이 확인되어 주문상태가 자동으로 "배송중"으로 갱신되었을 수 있습니다.</p>';
}
if (data.trackingDetails && data.trackingDetails.length > 0) {
  html += '<table class="biz-table"><thead><tr><th>시각</th><th>위치</th><th>처리내용</th></tr></thead><tbody>';
  data.trackingDetails.forEach(function (d) {
    html += '<tr><td>' + (d.timeString || '-') + '</td><td>' + (d.where || '-') + '</td><td>' + (d.kind || '-') + '</td></tr>';
  });
  html += '</tbody></table>';
} else {
  html += '<p style="color:#999">아직 상세 배송 이력이 없습니다. 택배사가 상품을 인수하면 표시됩니다.</p>';
}
// 새로고침 버튼은 level 2 이상(자동승격 가능)일 때 노출
if (data.level >= 2) {
 html += '<button type="button" class="biz-btn-primary" onclick="refreshDeliveryList(this)" style="margin-top:8px">목록 새로고침</button>';
}
box.innerHTML = html;
    })
    .catch(function () {
      document.getElementById('trackResultBox').innerHTML = '<p style="color:#E24B4A">조회 중 오류가 발생했습니다.</p>';
    });
}

  // 배송완료 수동처리 (확인창 필수, orders.jsp와 동일 서버 엔드포인트 재사용)
function forceComplete(orderId) {
  if (!confirm('이 처리는 보통 스마트택배 API로 자동으로 이뤄집니다.\n실제로 배송이 완료된 것이 맞습니까?')) return;

  csrfFetch(contextPath + '/biz/store/orders/' + orderId + '/force-complete', { method: 'POST' })
    .then(function (res) { return res.text(); })
    .then(function (result) {
      if (result === 'OK') {
        alert('배송완료로 처리되었습니다.');
        location.reload();
      } else {
        alert('처리에 실패했습니다.');
      }
    });
}

// 반복 클릭 방지 disabled 없음 (DB 재조회라 API 호출 없음)
function refreshDeliveryList(btn) {
  if (btn) { btn.textContent = '새로고침 중...'; }
  fetch(location.href)
    .then(function (res) { return res.text(); })
    .then(function (html) {
      var doc = new DOMParser().parseFromString(html, 'text/html');
      document.getElementById('dlvSummaryBox').innerHTML = doc.getElementById('dlvSummaryBox').innerHTML;
      document.getElementById('dlvListCard').innerHTML = doc.getElementById('dlvListCard').innerHTML;
      if (btn) { btn.textContent = '목록 새로고침'; }
    })
    .catch(function () {
      if (btn) { btn.textContent = '목록 새로고침'; }
      // 버튼 클릭 시에만 alert, 자동 타이머는 콘솔 로그만 (서버 다운 시 alert 반복 방지)
      if (btn) {
        alert('목록 갱신 중 오류가 발생했습니다.');
      } else {
        console.log('자동 새로고침 실패 (서버 연결 안 됨) - 15초 후 재시도');
      }
    });
}

function closeTrack() {
  document.getElementById('trackCard').style.display = 'none';
}

</script>

<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>
