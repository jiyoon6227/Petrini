<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- 2026/07/16 장우철 고도화작업 — 병원 스케줄 UI (유형·의사·간격·예외 / RULE→병원 통합) --%>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="동물병원" />
<c:set var="bizPage" value="schedule" />

<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_hospital.jsp" %>

<link href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.js"></script>

<style>
  .sch-head-row{display:flex;align-items:center;justify-content:space-between;padding:0 20px;gap:12px;flex-wrap:wrap}
  .sch-head-row .biz-card-head{padding:20px 0 12px}
  .sch-panel{display:none}
  .sch-panel.on{display:block}
  .sch-hint{font-size:12px;color:#999;padding:0 20px 12px;line-height:1.5}
  .sch-toast{position:fixed;bottom:28px;left:50%;transform:translateX(-50%) translateY(20px);background:#1A1A2E;color:#fff;padding:12px 20px;border-radius:10px;font-size:13px;font-weight:600;opacity:0;pointer-events:none;transition:.2s;z-index:1200;max-width:90%;text-align:center;line-height:1.45}
  .sch-toast.on{opacity:1;transform:translateX(-50%) translateY(0)}
  .sch-toast.error{background:#B91C1C}
  .sch-toast.ok{background:#1F8464}

  .sch-exc-layout{display:grid;grid-template-columns:1.15fr 1fr;gap:16px}
  @media (max-width:960px){.sch-exc-layout{grid-template-columns:1fr}}
  .sch-cal-wrap{padding:12px 16px 20px}
  .sch-legend{display:flex;gap:14px;align-items:center;flex-wrap:wrap;padding:4px 4px 12px;font-size:12px;color:#666}
  .sch-legend .dot{width:9px;height:9px;border-radius:50%;display:inline-block;margin-right:5px}
  .fc{font-family:inherit}
  .fc .fc-button-primary{background:var(--biz-primary,#2BAB82);border-color:var(--biz-primary,#2BAB82)}
  .fc .fc-button-primary:hover{background:#1F8464;border-color:#1F8464}
  .fc .fc-daygrid-event{border:none;padding:1px 4px;font-size:11px}
  .fc .fc-toolbar-title{font-size:16px;font-weight:800;color:#1A1A2E}
  .fc .fc-daygrid-day.sch-day-sel{background:#F0FAF6}

  .sch-detail{padding:18px 20px}
  .sch-detail-empty{text-align:center;color:#aaa;font-size:13px;padding:28px 0}
  .sch-exc-item{display:flex;align-items:center;gap:12px;padding:12px 0;border-bottom:1px solid #F5F6F4}
  .sch-exc-item:last-child{border-bottom:none}
  .sch-exc-item .info{flex:1;min-width:0}
  .sch-exc-item .info b{font-size:13px;color:#1A1A2E}
  .sch-exc-item .info small{display:block;font-size:12px;color:#888;margin-top:2px}

  .sch-modal-bg{display:none;position:fixed;inset:0;background:rgba(0,0,0,.45);z-index:1000;align-items:center;justify-content:center;padding:20px}
  .sch-modal-bg.open{display:flex}
  .sch-modal{background:#fff;border-radius:14px;width:100%;max-width:520px;max-height:90vh;overflow:auto;box-shadow:0 12px 40px rgba(0,0,0,.15)}
  .sch-modal-head{display:flex;justify-content:space-between;align-items:center;padding:18px 20px;border-bottom:1px solid #E2E8E4;position:sticky;top:0;background:#fff;z-index:1}
  .sch-modal-head h3{margin:0;font-size:17px;font-weight:800;color:#1A1A2E}
  .sch-modal-close{background:none;border:none;font-size:24px;cursor:pointer;color:#888;line-height:1}
  .sch-modal-body{padding:20px;display:flex;flex-direction:column;gap:14px}
  .sch-modal-foot{display:flex;gap:10px;padding:16px 20px;border-top:1px solid #E2E8E4;position:sticky;bottom:0;background:#fff}
  .sch-modal-foot .biz-btn{flex:1;text-align:center;padding:11px}
  .sch-modal-foot .biz-btn-primary{flex:2;text-align:center;padding:11px;border:none;border-radius:8px}
  .sch-mrow{display:flex;flex-direction:column;gap:6px}
  .sch-mrow label{font-size:13px;font-weight:600;color:#555}
  .sch-mrow label .req{color:#FF6B6B;margin-left:2px}
  .sch-mrow input,.sch-mrow select{
    border:1px solid #E4E6ED;border-radius:8px;padding:10px 14px;font-size:14px;color:#1A1A2E;
    outline:none;font-family:inherit;width:100%;box-sizing:border-box}
  .sch-mrow input:focus,.sch-mrow select:focus{border-color:#2BAB82}
  .sch-mrow-2{display:grid;grid-template-columns:1fr 1fr;gap:12px}
  @media (max-width:560px){.sch-mrow-2{grid-template-columns:1fr}}
  .sch-form-note{font-size:12px;color:#888;line-height:1.5;margin:0}
</style>

<main class="biz-main">
  <div class="biz-page-head">
    <h1 class="biz-page-title">병원 스케줄</h1>
    <p class="biz-page-desc">진료유형·의사·예약간격·예약예외를 관리합니다. (운영·점심시간은 병원정보에서 등록)</p>
  </div>

  <div class="biz-card" style="margin-bottom:16px">
    <div style="padding:20px 20px 0">
      <div class="biz-tabs">
        <button type="button" class="biz-tab active" data-panel="treat" onclick="switchSchTab('treat')">진료유형</button>
        <button type="button" class="biz-tab" data-panel="doctor" onclick="switchSchTab('doctor')">의사</button>
        <%-- 2026/07/16 장우철 고도화작업 — RESV_RULE 제거: 간격만 스케줄에서 관리 --%>
        <button type="button" class="biz-tab" data-panel="interval" onclick="switchSchTab('interval')">예약간격</button>
        <button type="button" class="biz-tab" data-panel="exception" onclick="switchSchTab('exception')">예약예외</button>
      </div>
    </div>
  </div>

  <%-- ═══ 진료유형 ═══ --%>
  <div class="sch-panel on" id="panelTreat">
    <div class="biz-card">
      <div class="sch-head-row">
        <div class="biz-card-head"><span>진료유형 목록</span><small id="treatCountLabel">총 0개</small></div>
        <button type="button" class="biz-btn-primary" onclick="openTreatModal('add')">+ 유형 등록</button>
      </div>
      <p class="sch-hint">유저가 고르는 진료 종류입니다. 소요분으로 예약 종료시간이 자동 계산됩니다.</p>
      <table class="biz-table">
        <thead>
          <tr>
            <th style="width:8%">정렬</th>
            <th>유형명</th>
            <th style="width:16%">소요시간</th>
            <th style="width:12%">사용</th>
            <th style="width:22%">관리</th>
          </tr>
        </thead>
        <tbody id="treatBody"></tbody>
      </table>
    </div>
  </div>

  <%-- ═══ 의사 ═══ --%>
  <div class="sch-panel" id="panelDoctor">
    <div class="biz-card">
      <div class="sch-head-row">
        <div class="biz-card-head"><span>의사 목록</span><small id="doctorCountLabel">총 0명</small></div>
        <button type="button" class="biz-btn-primary" onclick="openDoctorModal('add')">+ 의사 등록</button>
      </div>
      <p class="sch-hint">유저 예약 시 의사를 고르고, 의사별 가능 시간을 보여 줍니다.</p>
      <table class="biz-table">
        <thead>
          <tr>
            <th style="width:8%">정렬</th>
            <th>의사명</th>
            <th>전문분야</th>
            <th style="width:12%">사용</th>
            <th style="width:22%">관리</th>
          </tr>
        </thead>
        <tbody id="doctorBody"></tbody>
      </table>
    </div>
  </div>

  <%-- ═══ 예약간격 (병원 RESV_INTERVAL_MIN) ═══ --%>
  <div class="sch-panel" id="panelInterval">
    <div class="biz-card">
      <div class="sch-head-row">
        <div class="biz-card-head"><span>예약 시작 간격</span></div>
        <button type="button" class="biz-btn-primary" onclick="saveInterval()">저장</button>
      </div>
      <p class="sch-hint">유저가 고를 수 있는 시작 시각 간격입니다. (예: 15분 → 09:00, 09:15 …) 요일·오픈·마감·점심은 병원정보 운영시간에서 관리합니다.</p>
      <div style="padding:0 20px 24px;max-width:320px">
        <div class="sch-mrow">
          <label>간격<span class="req">*</span></label>
          <select id="resvIntervalMin">
            <option value="10">10분</option>
            <option value="15" selected>15분</option>
            <option value="20">20분</option>
            <option value="30">30분</option>
          </select>
        </div>
      </div>
    </div>
  </div>

  <%-- ═══ 예약예외 ═══ --%>
  <div class="sch-panel" id="panelException">
    <p class="sch-hint" style="padding:0 0 12px">특정일만 미리 규칙을 덮어씁니다. CLOSE=그날 그 구간 불가, REPLACE=그날 그 구간만 오픈.</p>
    <div class="sch-exc-layout">
      <div class="biz-card">
        <div class="biz-card-head" style="padding:18px 20px 0"><span>예외 캘린더</span></div>
        <div class="sch-cal-wrap">
          <div class="sch-legend">
            <span><span class="dot" style="background:#F59E0B"></span>CLOSE (구간 막기)</span>
            <span><span class="dot" style="background:#2BAB82"></span>REPLACE (구간만 오픈)</span>
          </div>
          <div id="excCalendar"></div>
        </div>
      </div>
      <div class="biz-card">
        <div class="sch-head-row">
          <div class="biz-card-head" style="padding:18px 0 8px"><span id="excDetailTitle">선택한 날짜의 예외</span></div>
          <button type="button" class="biz-btn-primary" onclick="openExcModal('add')">+ 예외 등록</button>
        </div>
        <div class="sch-detail" id="excDetail"></div>
      </div>
    </div>
  </div>
</main>

<%-- 진료유형 모달 --%>
<div class="sch-modal-bg" id="treatModalBg" onclick="if(event.target===this) closeModal('treatModalBg')">
  <div class="sch-modal">
    <div class="sch-modal-head">
      <h3 id="treatModalTitle">진료유형 등록</h3>
      <button type="button" class="sch-modal-close" onclick="closeModal('treatModalBg')">×</button>
    </div>
    <div class="sch-modal-body">
      <input type="hidden" id="treatEditId" value="">
      <div class="sch-mrow"><label>유형명<span class="req">*</span></label><input type="text" id="treatName" placeholder="예: 일반진료"></div>
      <div class="sch-mrow-2">
        <div class="sch-mrow">
          <label>소요 분<span class="req">*</span></label>
          <select id="treatMin"><option value="10">10분</option><option value="15">15분</option><option value="20">20분</option><option value="30" selected>30분</option><option value="60">60분</option></select>
        </div>
        <div class="sch-mrow"><label>정렬</label><input type="number" id="treatSort" value="1" min="1"></div>
      </div>
      <div class="sch-mrow"><label>사용</label><select id="treatUse"><option value="Y" selected>사용</option><option value="N">미사용</option></select></div>
    </div>
    <div class="sch-modal-foot">
      <button type="button" class="biz-btn" onclick="closeModal('treatModalBg')">취소</button>
      <button type="button" class="biz-btn-primary" onclick="saveTreat()">확인</button>
    </div>
  </div>
</div>

<%-- 의사 모달 --%>
<div class="sch-modal-bg" id="doctorModalBg" onclick="if(event.target===this) closeModal('doctorModalBg')">
  <div class="sch-modal">
    <div class="sch-modal-head">
      <h3 id="doctorModalTitle">의사 등록</h3>
      <button type="button" class="sch-modal-close" onclick="closeModal('doctorModalBg')">×</button>
    </div>
    <div class="sch-modal-body">
      <input type="hidden" id="doctorEditId" value="">
      <div class="sch-mrow"><label>의사명<span class="req">*</span></label><input type="text" id="doctorName" placeholder="예: 김수의"></div>
      <div class="sch-mrow"><label>전문분야</label><input type="text" id="doctorSpec" placeholder="예: 내과"></div>
      <div class="sch-mrow-2">
        <div class="sch-mrow"><label>정렬</label><input type="number" id="doctorSort" value="1" min="1"></div>
        <div class="sch-mrow"><label>사용</label><select id="doctorUse"><option value="Y" selected>사용</option><option value="N">미사용</option></select></div>
      </div>
    </div>
    <div class="sch-modal-foot">
      <button type="button" class="biz-btn" onclick="closeModal('doctorModalBg')">취소</button>
      <button type="button" class="biz-btn-primary" onclick="saveDoctor()">확인</button>
    </div>
  </div>
</div>

<%-- 2026/07/16 장우철 고도화작업 — 예약예외 등록/수정 모달 --%>
<div class="sch-modal-bg" id="excModalBg" onclick="if(event.target===this) closeModal('excModalBg')">
  <div class="sch-modal">
    <div class="sch-modal-head">
      <h3 id="excModalTitle">예외 등록</h3>
      <button type="button" class="sch-modal-close" onclick="closeModal('excModalBg')">×</button>
    </div>
    <div class="sch-modal-body">
      <input type="hidden" id="excEditId" value="">
      <p class="sch-form-note">CLOSE: 그날 해당 구간만 막기 · REPLACE: 그날 해당 구간만 오픈(규칙 덮어쓰기)</p>
      <div class="sch-mrow"><label>날짜<span class="req">*</span></label><input type="date" id="excDate"></div>
      <div class="sch-mrow"><label>대상<span class="req">*</span></label><select id="excTarget"></select></div>
      <div class="sch-mrow">
        <label>예외 유형<span class="req">*</span></label>
        <select id="excType">
          <option value="CLOSE">CLOSE (구간 예약 불가)</option>
          <option value="REPLACE">REPLACE (그날 이 구간만 오픈)</option>
        </select>
      </div>
      <div class="sch-mrow-2">
        <div class="sch-mrow"><label>시작<span class="req">*</span></label><input type="time" id="excStart" value="13:00" step="900"></div>
        <div class="sch-mrow"><label>종료<span class="req">*</span></label><input type="time" id="excEnd" value="18:00" step="900"></div>
      </div>
      <div class="sch-mrow"><label>메모</label><input type="text" id="excMemo" placeholder="예: 단축진료"></div>
    </div>
    <div class="sch-modal-foot">
      <button type="button" class="biz-btn" onclick="closeModal('excModalBg')">취소</button>
      <button type="button" class="biz-btn-primary" onclick="saveExc()">확인</button>
    </div>
  </div>
</div>

<div class="sch-toast" id="schToast"></div>

<script>
  // 2026/07/16 장우철 고도화작업 — 병원 스케줄 API (유형·의사·간격·예외 / RULE 제거)
  var contextPath = '${contextPath}';

  var treatList = [];
  var doctorList = [];
  var excList = [];
  var selectedExcDate = '';
  var excCal = null;

  function showSchToast(msg, type) {
    var el = document.getElementById('schToast');
    el.textContent = msg;
    el.classList.remove('error', 'ok');
    if (type === 'error') el.classList.add('error');
    else if (type === 'ok') el.classList.add('ok');
    el.classList.add('on');
    clearTimeout(window.__schToastTimer);
    window.__schToastTimer = setTimeout(function () {
      el.classList.remove('on', 'error', 'ok');
    }, 2800);
  }
  function closeModal(id) { document.getElementById(id).classList.remove('open'); }
  function openModal(id) { document.getElementById(id).classList.add('open'); }

  function switchSchTab(name) {
    document.querySelectorAll('.sch-panel').forEach(function (p) { p.classList.remove('on'); });
    document.querySelectorAll('.biz-tab').forEach(function (t) { t.classList.remove('active'); });
    var map = { treat: 'Treat', doctor: 'Doctor', interval: 'Interval', exception: 'Exception' };
    document.getElementById('panel' + map[name]).classList.add('on');
    document.querySelector('.biz-tab[data-panel="' + name + '"]').classList.add('active');
    if (name === 'exception' && excCal) setTimeout(function () { excCal.updateSize(); }, 40);
  }

  function apiGet(url) {
    return fetch(contextPath + url).then(function (res) { return res.json(); });
  }
  function apiPostJson(url, body) {
    // 2026/08/07 장우철 — CSRF (저장 POST 403 → 「네트워크 오류」 방지)
    return csrfFetch(contextPath + url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body)
    }).then(function (res) { return res.json(); });
  }
  function apiPostParam(url, params) {
    var q = new URLSearchParams(params).toString();
    //HYJ 26.08.05
    return csrfFetch(contextPath + url + '?' + q, { method: 'POST' })
      .then(function (res) { return res.json(); });
  }
  function applyListResult(res, setter, okMsg) {
    if (!res || !res.ok) {
      showSchToast((res && res.message) || '처리에 실패했습니다. 잠시 후 다시 시도해 주세요.', 'error');
      return false;
    }
    setter(res.data || []);
    if (okMsg) showSchToast(okMsg, 'ok');
    return true;
  }

  function parseTimeToMin(t) {
    if (!t) return null;
    var p = String(t).substring(0, 5).split(':');
    if (p.length < 2) return null;
    return Number(p[0]) * 60 + Number(p[1]);
  }

  function doctorName(id) {
    if (id == null) return '공통';
    var d = doctorList.find(function (x) { return x.doctorId === id; });
    return d ? d.doctorName : ('의사#' + id);
  }
  function fillTargetSelects() {
    var opts = '<option value="common">공통</option>';
    doctorList.filter(function (d) { return d.statusCd === 'Y'; }).forEach(function (d) {
      opts += '<option value="' + d.doctorId + '">' + d.doctorName + '</option>';
    });
    document.getElementById('excTarget').innerHTML = opts;
  }
  function todayStr() {
    var d = new Date();
    var m = String(d.getMonth() + 1).padStart(2, '0');
    var day = String(d.getDate()).padStart(2, '0');
    return d.getFullYear() + '-' + m + '-' + day;
  }
  function excDateKey(e) {
    return e.excDateStr || (e.excDate ? String(e.excDate).substring(0, 10) : '');
  }

  function setTreatList(list) {
    treatList = list || [];
    renderTreatTable();
  }
  function loadTreats() {
    return apiGet('/biz/hospital/schedule/treat-types').then(function (res) {
      applyListResult(res, setTreatList);
    });
  }
  function renderTreatTable() {
    document.getElementById('treatCountLabel').textContent = '총 ' + treatList.length + '개';
    var body = document.getElementById('treatBody');
    body.innerHTML = '';
    if (!treatList.length) {
      body.innerHTML = '<tr><td colspan="5" style="text-align:center;color:#999;padding:24px">등록된 유형이 없습니다.</td></tr>';
      return;
    }
    treatList.forEach(function (t) {
      var tr = document.createElement('tr');
      tr.innerHTML =
        '<td>' + (t.sortOrdr == null ? '-' : t.sortOrdr) + '</td><td>' + t.typeName + '</td><td>' + t.durationMin + '분</td>' +
        '<td><span class="bs-badge ' + (t.statusCd === 'Y' ? 'bs-done' : 'bs-empty') + '">' + (t.statusCd === 'Y' ? '사용' : '미사용') + '</span></td>' +
        '<td><button type="button" class="biz-btn" onclick="openTreatModal(\'edit\',' + t.treatTypeId + ')">수정</button> ' +
        '<button type="button" class="biz-btn danger" onclick="removeTreat(' + t.treatTypeId + ')">삭제</button></td>';
      body.appendChild(tr);
    });
  }
  function openTreatModal(mode, id) {
    document.getElementById('treatModalTitle').textContent = mode === 'edit' ? '진료유형 수정' : '진료유형 등록';
    document.getElementById('treatEditId').value = '';
    document.getElementById('treatName').value = '';
    document.getElementById('treatMin').value = '30';
    document.getElementById('treatSort').value = String(treatList.length + 1);
    document.getElementById('treatUse').value = 'Y';
    if (mode === 'edit') {
      var t = treatList.find(function (x) { return x.treatTypeId === id; });
      if (!t) return;
      document.getElementById('treatEditId').value = t.treatTypeId;
      document.getElementById('treatName').value = t.typeName;
      document.getElementById('treatMin').value = String(t.durationMin);
      document.getElementById('treatSort').value = t.sortOrdr == null ? '' : t.sortOrdr;
      document.getElementById('treatUse').value = t.statusCd || 'Y';
    }
    openModal('treatModalBg');
  }
  function saveTreat() {
    var name = document.getElementById('treatName').value.trim();
    if (!name) { showSchToast('유형명을 입력해 주세요.', 'error'); return; }
    var durationMin = Number(document.getElementById('treatMin').value);
    if (!durationMin || durationMin <= 0) {
      showSchToast('소요 시간(분)은 1 이상 숫자로 입력해 주세요.', 'error');
      return;
    }
    if (durationMin > 480) {
      showSchToast('소요 시간은 480분(8시간) 이하로 입력해 주세요.', 'error');
      return;
    }
    var editId = document.getElementById('treatEditId').value;
    var body = {
      typeName: name,
      durationMin: durationMin,
      sortOrdr: Number(document.getElementById('treatSort').value) || 1,
      statusCd: document.getElementById('treatUse').value
    };
    if (editId) body.treatTypeId = Number(editId);
    apiPostJson('/biz/hospital/schedule/treat-types/save', body).then(function (res) {
      if (applyListResult(res, setTreatList, editId ? '진료유형이 수정되었습니다.' : '진료유형이 등록되었습니다.')) {
        closeModal('treatModalBg');
      }
    }).catch(function () { showSchToast('네트워크 오류로 저장하지 못했습니다.', 'error'); });
  }
  function removeTreat(id) {
    if (!confirm('이 진료유형을 삭제할까요?')) return;
    apiPostParam('/biz/hospital/schedule/treat-types/delete', { treatTypeId: id }).then(function (res) {
      applyListResult(res, setTreatList, '진료유형이 삭제되었습니다.');
    }).catch(function () { showSchToast('네트워크 오류로 삭제하지 못했습니다.', 'error'); });
  }

  function setDoctorList(list) {
    doctorList = list || [];
    renderDoctorTable();
  }
  function loadDoctors() {
    return apiGet('/biz/hospital/schedule/doctors').then(function (res) {
      applyListResult(res, setDoctorList);
    });
  }
  function renderDoctorTable() {
    document.getElementById('doctorCountLabel').textContent = '총 ' + doctorList.length + '명';
    var body = document.getElementById('doctorBody');
    body.innerHTML = '';
    if (!doctorList.length) {
      body.innerHTML = '<tr><td colspan="5" style="text-align:center;color:#999;padding:24px">등록된 의사가 없습니다.</td></tr>';
      fillTargetSelects();
      return;
    }
    doctorList.forEach(function (d) {
      var tr = document.createElement('tr');
      tr.innerHTML =
        '<td>' + (d.sortOrdr == null ? '-' : d.sortOrdr) + '</td><td>' + d.doctorName + '</td><td>' + (d.specialty || '-') + '</td>' +
        '<td><span class="bs-badge ' + (d.statusCd === 'Y' ? 'bs-done' : 'bs-empty') + '">' + (d.statusCd === 'Y' ? '사용' : '미사용') + '</span></td>' +
        '<td><button type="button" class="biz-btn" onclick="openDoctorModal(\'edit\',' + d.doctorId + ')">수정</button> ' +
        '<button type="button" class="biz-btn danger" onclick="removeDoctor(' + d.doctorId + ')">삭제</button></td>';
      body.appendChild(tr);
    });
    fillTargetSelects();
  }
  function openDoctorModal(mode, id) {
    document.getElementById('doctorModalTitle').textContent = mode === 'edit' ? '의사 수정' : '의사 등록';
    document.getElementById('doctorEditId').value = '';
    document.getElementById('doctorName').value = '';
    document.getElementById('doctorSpec').value = '';
    document.getElementById('doctorSort').value = String(doctorList.length + 1);
    document.getElementById('doctorUse').value = 'Y';
    if (mode === 'edit') {
      var d = doctorList.find(function (x) { return x.doctorId === id; });
      if (!d) return;
      document.getElementById('doctorEditId').value = d.doctorId;
      document.getElementById('doctorName').value = d.doctorName;
      document.getElementById('doctorSpec').value = d.specialty || '';
      document.getElementById('doctorSort').value = d.sortOrdr == null ? '' : d.sortOrdr;
      document.getElementById('doctorUse').value = d.statusCd || 'Y';
    }
    openModal('doctorModalBg');
  }
  function saveDoctor() {
    var name = document.getElementById('doctorName').value.trim();
    if (!name) { showSchToast('의사명을 입력해 주세요.', 'error'); return; }
    var editId = document.getElementById('doctorEditId').value;
    var body = {
      doctorName: name,
      specialty: document.getElementById('doctorSpec').value.trim(),
      sortOrdr: Number(document.getElementById('doctorSort').value) || 1,
      statusCd: document.getElementById('doctorUse').value
    };
    if (editId) body.doctorId = Number(editId);
    apiPostJson('/biz/hospital/schedule/doctors/save', body).then(function (res) {
      if (applyListResult(res, setDoctorList, editId ? '의사가 수정되었습니다.' : '의사가 등록되었습니다.')) {
        closeModal('doctorModalBg');
      }
    }).catch(function () { showSchToast('네트워크 오류로 저장하지 못했습니다.', 'error'); });
  }
  function removeDoctor(id) {
    if (!confirm('이 의사를 삭제할까요?')) return;
    apiPostParam('/biz/hospital/schedule/doctors/delete', { doctorId: id }).then(function (res) {
      applyListResult(res, setDoctorList, '의사가 삭제되었습니다.');
    }).catch(function () { showSchToast('네트워크 오류로 삭제하지 못했습니다.', 'error'); });
  }

  function loadInterval() {
    return apiGet('/biz/hospital/schedule/interval').then(function (res) {
      if (!res || !res.ok) {
        showSchToast((res && res.message) || '예약 간격을 불러오지 못했습니다.', 'error');
        return;
      }
      var v = (res.data && res.data.resvIntervalMin) ? String(res.data.resvIntervalMin) : '15';
      document.getElementById('resvIntervalMin').value = v;
    });
  }
  function saveInterval() {
    var v = Number(document.getElementById('resvIntervalMin').value);
    if (!v || v <= 0) {
      showSchToast('예약 간격(분)을 1 이상 숫자로 입력해 주세요.', 'error');
      return;
    }
    if (v < 5 || v > 120) {
      showSchToast('예약 간격은 5~120분 사이로 입력해 주세요.', 'error');
      return;
    }
    apiPostJson('/biz/hospital/schedule/interval/save', { resvIntervalMin: v }).then(function (res) {
      if (!res || !res.ok) {
        showSchToast((res && res.message) || '예약 간격 저장에 실패했습니다.', 'error');
        return;
      }
      if (res.data && res.data.resvIntervalMin != null) {
        document.getElementById('resvIntervalMin').value = String(res.data.resvIntervalMin);
      }
      showSchToast('예약 간격이 ' + v + '분으로 저장되었습니다.', 'ok');
    }).catch(function () { showSchToast('네트워크 오류로 저장하지 못했습니다.', 'error'); });
  }

  function setExcList(list) {
    excList = list || [];
    rebuildExcEvents();
    renderExcDetail(selectedExcDate || todayStr());
  }
  function loadExceptions() {
    return apiGet('/biz/hospital/schedule/exceptions').then(function (res) {
      applyListResult(res, setExcList);
    });
  }
  function renderExcDetail(dateKey) {
    selectedExcDate = dateKey;
    var d = new Date(dateKey + 'T00:00:00');
    document.getElementById('excDetailTitle').textContent =
      (d.getMonth() + 1) + '월 ' + d.getDate() + '일 예외';
    var list = excList.filter(function (e) { return excDateKey(e) === dateKey; });
    var box = document.getElementById('excDetail');
    if (!list.length) {
      box.innerHTML = '<div class="sch-detail-empty">이 날짜에 등록된 예외가 없습니다.</div>';
      return;
    }
    box.innerHTML = '';
    list.forEach(function (e) {
      var badge = e.excType === 'CLOSE'
        ? '<span class="bs-badge bs-wait">CLOSE</span>'
        : '<span class="bs-badge bs-done">REPLACE</span>';
      var label = e.doctorId == null ? '공통' : (e.doctorName || doctorName(e.doctorId));
      var item = document.createElement('div');
      item.className = 'sch-exc-item';
      item.innerHTML =
        badge +
        '<div class="info"><b>' + label + ' · ' + e.startTime + '~' + e.endTime + '</b>' +
        '<small>' + (e.memo || '-') + '</small></div>' +
        '<button type="button" class="biz-btn" onclick="openExcModal(\'edit\',' + e.excId + ')">수정</button> ' +
        '<button type="button" class="biz-btn danger" onclick="removeExc(' + e.excId + ')">삭제</button>';
      box.appendChild(item);
    });
  }
  function rebuildExcEvents() {
    if (!excCal) return;
    excCal.removeAllEvents();
    excList.forEach(function (e) {
      var date = excDateKey(e);
      if (!date) return;
      excCal.addEvent({
        title: e.excType + ' ' + e.startTime,
        start: date,
        allDay: true,
        color: e.excType === 'CLOSE' ? '#F59E0B' : '#2BAB82'
      });
    });
  }
  function openExcModal(mode, id) {
    fillTargetSelects();
    document.getElementById('excModalTitle').textContent = mode === 'edit' ? '예외 수정' : '예외 등록';
    document.getElementById('excEditId').value = '';
    document.getElementById('excDate').value = selectedExcDate || todayStr();
    document.getElementById('excTarget').value = 'common';
    document.getElementById('excType').value = 'CLOSE';
    document.getElementById('excStart').value = '13:00';
    document.getElementById('excEnd').value = '18:00';
    document.getElementById('excMemo').value = '';
    if (mode === 'edit') {
      var e = excList.find(function (x) { return x.excId === id; });
      if (!e) return;
      document.getElementById('excEditId').value = e.excId;
      document.getElementById('excDate').value = excDateKey(e);
      document.getElementById('excTarget').value = e.doctorId == null ? 'common' : String(e.doctorId);
      document.getElementById('excType').value = e.excType;
      document.getElementById('excStart').value = e.startTime;
      document.getElementById('excEnd').value = e.endTime;
      document.getElementById('excMemo').value = e.memo || '';
    }
    openModal('excModalBg');
  }
  function saveExc() {
    var date = document.getElementById('excDate').value;
    var start = document.getElementById('excStart').value;
    var end = document.getElementById('excEnd').value;
    if (!date || !start || !end) { showSchToast('날짜·시간을 모두 입력해 주세요.', 'error'); return; }
    var startMin = parseTimeToMin(start);
    var endMin = parseTimeToMin(end);
    if (startMin == null || endMin == null) {
      showSchToast('시간 형식을 확인해 주세요. (예: 09:00)', 'error');
      return;
    }
    if (startMin >= endMin) {
      showSchToast('종료 시각은 시작 시각보다 늦어야 합니다.', 'error');
      return;
    }
    var target = document.getElementById('excTarget').value;
    var editId = document.getElementById('excEditId').value;
    var body = {
      doctorId: target === 'common' ? null : target,
      excDate: date,
      excType: document.getElementById('excType').value,
      startTime: start.substring(0, 5),
      endTime: end.substring(0, 5),
      memo: document.getElementById('excMemo').value.trim(),
      statusCd: 'Y'
    };
    if (editId) body.excId = Number(editId);
    apiPostJson('/biz/hospital/schedule/exceptions/save', body).then(function (res) {
      if (applyListResult(res, function (list) {
        setExcList(list);
        renderExcDetail(date);
      }, editId ? '예외가 수정되었습니다.' : '예외가 등록되었습니다.')) {
        closeModal('excModalBg');
      }
    }).catch(function () { showSchToast('네트워크 오류로 저장하지 못했습니다.', 'error'); });
  }
  function removeExc(id) {
    if (!confirm('이 예외를 삭제할까요?')) return;
    var hit = excList.find(function (x) { return x.excId === id; });
    var keepDate = hit ? excDateKey(hit) : selectedExcDate;
    apiPostParam('/biz/hospital/schedule/exceptions/delete', { excId: id }).then(function (res) {
      if (applyListResult(res, function (list) {
        setExcList(list);
        renderExcDetail(keepDate || todayStr());
      }, '예외 일정이 삭제되었습니다.')) { /* ok */ }
    }).catch(function () { showSchToast('네트워크 오류로 삭제하지 못했습니다.', 'error'); });
  }

  document.addEventListener('DOMContentLoaded', function () {
    selectedExcDate = todayStr();
    var calEl = document.getElementById('excCalendar');
    excCal = new FullCalendar.Calendar(calEl, {
      initialView: 'dayGridMonth',
      initialDate: selectedExcDate,
      locale: 'ko',
      height: 'auto',
      headerToolbar: { left: 'prev,next today', center: 'title', right: '' },
      buttonText: { today: '오늘' },
      dateClick: function (info) {
        calEl.querySelectorAll('.sch-day-sel').forEach(function (n) { n.classList.remove('sch-day-sel'); });
        if (info.dayEl) info.dayEl.classList.add('sch-day-sel');
        renderExcDetail(info.dateStr);
      },
      eventClick: function (info) {
        var key = info.event.startStr.substring(0, 10);
        renderExcDetail(key);
      }
    });
    excCal.render();

    Promise.all([loadTreats(), loadDoctors(), loadInterval(), loadExceptions()])
      .catch(function () { showSchToast('목록을 불러오지 못했습니다. 새로고침 후 다시 시도해 주세요.', 'error'); });
  });
</script>

<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>
