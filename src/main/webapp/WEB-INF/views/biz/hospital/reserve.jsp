<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="동물병원" />
<c:set var="bizPage"      value="reserve" />

<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_hospital.jsp" %>

<style>
  .rv-modal-bg{display:none;position:fixed;inset:0;background:rgba(0,0,0,.45);z-index:1000;align-items:center;justify-content:center;padding:20px}
  .rv-modal-bg.open{display:flex}
  .rv-modal{background:#fff;border-radius:14px;width:100%;max-width:480px;max-height:90vh;overflow:auto;box-shadow:0 12px 40px rgba(0,0,0,.15)}
  .rv-modal-head{display:flex;justify-content:space-between;align-items:center;padding:18px 20px;border-bottom:1px solid #E2E8E4}
  .rv-modal-head h3{margin:0;font-size:17px;font-weight:800;color:#1A1A2E}
  .rv-modal-close{background:none;border:none;font-size:24px;cursor:pointer;color:#888;line-height:1}
  .rv-modal-body{padding:20px;display:flex;flex-direction:column;gap:12px}
  .rv-row{display:flex;justify-content:space-between;font-size:14px;gap:12px}
  .rv-row span:first-child{color:#888;flex-shrink:0}
  .rv-row span:last-child{color:#1A1A2E;font-weight:600;text-align:right}

  /* 2026/07/13 장우철 — 진료완료 풀모달 (records 와 동일) */
  .rm-modal-bg{display:none;position:fixed;inset:0;background:rgba(0,0,0,.5);z-index:1000;align-items:center;justify-content:center;padding:20px}
  .rm-modal-bg.open{display:flex}
  .rm-modal{background:#fff;border-radius:16px;width:100%;max-width:640px;max-height:90vh;overflow-y:auto;box-shadow:0 20px 60px rgba(0,0,0,.2)}
  .rm-header{display:flex;justify-content:space-between;align-items:center;padding:20px 24px 16px;border-bottom:1px solid #E2E8E4;position:sticky;top:0;background:#fff;z-index:1}
  .rm-header h3{font-size:18px;font-weight:800;color:#1A1A2E;margin:0}
  .rm-close{width:32px;height:32px;border:none;background:#F0F4F8;border-radius:50%;cursor:pointer;font-size:18px;color:#999}
  .rm-body{padding:22px 24px}
  .rm-patient-card{display:flex;align-items:center;gap:14px;background:#FAFBFA;border:1px solid #E2E8E4;border-radius:10px;padding:14px 16px;margin-bottom:20px}
  .rm-patient-thumb{width:52px;height:52px;border-radius:50%;object-fit:cover;flex-shrink:0;border:2px solid #E2E8E4}
  .rm-patient-name{font-size:15px;font-weight:700;color:#1A1A2E}
  .rm-patient-meta{font-size:12.5px;color:#999;margin-top:3px}
  .rm-patient-badge{margin-left:auto;font-size:11px;font-weight:700;padding:4px 12px;border-radius:20px;background:#EAF7F2;color:#1F8464;white-space:nowrap}
  .rm-section-label{font-size:13px;font-weight:700;color:#2BAB82;margin:4px 0 12px;padding-top:14px;border-top:1px solid #F0F4F8}
  .rm-section-label:first-of-type{padding-top:0;border-top:none}
  .rm-grid{display:grid;grid-template-columns:1fr 1fr;gap:14px;margin-bottom:4px}
  .rm-group{display:flex;flex-direction:column;gap:5px}
  .rm-group.full{grid-column:1/-1}
  .rm-group label{font-size:13px;font-weight:600;color:#555}
  .rm-group label .req{color:#FF6B6B;margin-left:2px}
  .rm-group input,.rm-group select,.rm-group textarea{border:1px solid #E2E8E4;border-radius:8px;padding:9px 13px;font-size:14px;color:#1A1A2E;outline:none;font-family:inherit;width:100%;box-sizing:border-box}
  .rm-group textarea{min-height:64px;resize:vertical;line-height:1.6}
  .rm-input-unit{display:flex;align-items:center;gap:8px}
  .rm-input-unit input{flex:1}
  .rm-input-unit span{font-size:13px;color:#555;white-space:nowrap}
  .rm-hint{font-size:11px;color:#aaa;margin-top:2px}
  .rm-type-group{display:flex;gap:8px;flex-wrap:wrap}
  .rm-type-item{display:none}
  .rm-type-label{padding:7px 16px;border:1px solid #E2E8E4;border-radius:50px;font-size:13px;font-weight:600;color:#555;cursor:pointer}
  .rm-type-item:checked+.rm-type-label{background:#EAF7F2;border-color:#2BAB82;color:#1F8464}
  .rm-footer{display:flex;gap:10px;padding:16px 24px;border-top:1px solid #E2E8E4;position:sticky;bottom:0;background:#fff}
  .btn-rm-cancel{flex:1;padding:12px;border:1px solid #E2E8E4;border-radius:8px;background:#fff;color:#555;font-size:14px;font-weight:700;cursor:pointer}
  .btn-rm-save{flex:2;padding:12px;border:none;border-radius:8px;background:#2BAB82;color:#fff;font-size:14px;font-weight:800;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:8px}
  .btn-rm-save svg{width:16px;height:16px;stroke:#fff;fill:none;stroke-width:2.2;stroke-linecap:round;stroke-linejoin:round}
  @media (max-width:600px){.rm-grid{grid-template-columns:1fr}}
</style>

<%-- 2026-07-10 장우철 — 사업자 예약 관리 DB 연동 (F4~F6) --%>
<main class="biz-main">
  <div class="biz-page-head">
    <h1 class="biz-page-title">예약 관리</h1>
    <p class="biz-page-desc">진료 예약을 확인하고 상태를 관리하세요.</p>
  </div>

  <c:if test="${not empty msg}">
    <div style="margin-bottom:12px;padding:12px 16px;background:#E8F8F1;color:#1F8464;border-radius:8px;font-size:14px">${msg}</div>
  </c:if>
  <c:if test="${not empty errorMsg}">
    <div style="margin-bottom:12px;padding:12px 16px;background:#FEF2F2;color:#B91C1C;border-radius:8px;font-size:14px">${errorMsg}</div>
  </c:if>

  <div class="biz-card">
    <div style="padding:20px 20px 0">
      <%-- 2026/07/11 장우철 — 예약신청(PENDING) / 예약확정(CONFIRMED) 탭 분리 --%>
      <div class="biz-tabs">
        <button type="button" class="biz-tab active" data-tab="all" onclick="switchTab('all')">전체<span class="biz-tab-count" id="cntAll"></span></button>
        <button type="button" class="biz-tab" data-tab="pending" onclick="switchTab('pending')">예약신청<span class="biz-tab-count" id="cntPending"></span></button>
        <button type="button" class="biz-tab" data-tab="confirmed" onclick="switchTab('confirmed')">예약확정<span class="biz-tab-count" id="cntConfirmed"></span></button>
        <button type="button" class="biz-tab" data-tab="done" onclick="switchTab('done')">진료완료<span class="biz-tab-count" id="cntDone"></span></button>
        <button type="button" class="biz-tab" data-tab="cancel" onclick="switchTab('cancel')">취소<span class="biz-tab-count" id="cntCancel"></span></button>
      </div>
    </div>

    <table class="biz-table">
      <thead>
        <tr>
          <th style="width:12%">예약번호</th>
          <th style="width:10%">예약자</th>
          <th style="width:14%">반려동물</th>
          <th style="width:18%">예약일시</th>
          <th style="width:14%">의사·유형</th>
          <th style="width:10%">상태</th>
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

<div class="rv-modal-bg" id="reserveModalBg" onclick="if(event.target===this) closeReserveModal()">
  <div class="rv-modal">
    <div class="rv-modal-head">
      <h3>예약 상세</h3>
      <button type="button" class="rv-modal-close" onclick="closeReserveModal()">×</button>
    </div>
    <div class="rv-modal-body">
      <div class="rv-row"><span>예약자</span><span id="mdMember">-</span></div>
      <div class="rv-row"><span>반려동물</span><span id="mdPet">-</span></div>
      <div class="rv-row"><span>예약일</span><span id="mdDate">-</span></div>
      <div class="rv-row"><span>예약시간</span><span id="mdTime">-</span></div>
      <div class="rv-row"><span>담당 의사</span><span id="mdDoctor">-</span></div>
      <div class="rv-row"><span>진료 유형</span><span id="mdTreat">-</span></div>
      <div class="rv-row"><span>증상</span><span id="mdSymptoms">-</span></div>
      <div class="rv-row"><span>요청사항</span><span id="mdMemo">-</span></div>
    </div>
  </div>
</div>

<%-- 2026/07/13 장우철 — 진료완료 + 풀 진료기록 모달 (records 와 동일 필드) --%>
<div class="rm-modal-bg" id="completeModalBg" onclick="if(event.target===this) closeCompleteModal()">
  <div class="rm-modal">
    <div class="rm-header">
      <h3>진료완료 · 진료기록 작성</h3>
      <button type="button" class="rm-close" onclick="closeCompleteModal()">×</button>
    </div>
    <form id="completeRecordForm" method="post" action="${contextPath}/biz/hospital/records/complete">
      <!--HYJ 26.08.05-->
      <input type="hidden" name="_csrf" value="${_csrf}">

      <input type="hidden" name="resvId" id="cmResvId" value="">
      <input type="hidden" name="treatType" id="cmTreatType" value="진료">
      <div class="rm-body">
        <div class="rm-patient-card">
          <img class="rm-patient-thumb" src="https://placehold.co/44x44/EAF7F2/2BAB82?text=PET" alt="환자">
          <div>
            <div class="rm-patient-name" id="cmPet">-</div>
            <div class="rm-patient-meta" id="cmMemberMeta">-</div>
          </div>
          <span class="rm-patient-badge" id="cmDateBadge">-</span>
        </div>

        <div class="rm-section-label">진료 정보</div>
        <div class="rm-grid">
          <div class="rm-group full">
            <label>진료 유형 <span class="req">*</span></label>
            <div class="rm-type-group">
              <input type="radio" name="cmRecType" id="cm-type-check" class="rm-type-item" value="정기검진" onchange="syncCmTreatType()">
              <label for="cm-type-check" class="rm-type-label">정기검진</label>
              <input type="radio" name="cmRecType" id="cm-type-treat" class="rm-type-item" value="진료" checked onchange="syncCmTreatType()">
              <label for="cm-type-treat" class="rm-type-label">진료</label>
              <input type="radio" name="cmRecType" id="cm-type-vaccine" class="rm-type-item" value="예방접종" onchange="syncCmTreatType()">
              <label for="cm-type-vaccine" class="rm-type-label">예방접종</label>
              <input type="radio" name="cmRecType" id="cm-type-surgery" class="rm-type-item" value="수술" onchange="syncCmTreatType()">
              <label for="cm-type-surgery" class="rm-type-label">수술</label>
            </div>
          </div>
          <div class="rm-group full">
            <label>주증상 <span class="req">*</span></label>
            <input type="text" name="symptoms" id="cmSymptoms" placeholder="예) 피부 트러블, 긁음 반복">
          </div>
          <div class="rm-group">
            <label>진단명 <span class="req">*</span></label>
            <input type="text" name="diagnosis" id="cmDiagnosis" placeholder="예) 알레르기성 피부염">
          </div>
          <div class="rm-group">
            <label>검사 항목</label>
            <input type="text" name="examItems" id="cmExam" placeholder="예) 혈액검사, 심장사상충">
          </div>
          <div class="rm-group full">
            <label>처방 내용</label>
            <textarea name="prescription" id="cmPrescription" placeholder="처방한 약물명, 용량, 투약 기간 등을 입력하세요."></textarea>
          </div>
        </div>

        <div class="rm-section-label">신체 계측</div>
        <div class="rm-grid">
          <div class="rm-group">
            <label>체중</label>
            <div class="rm-input-unit"><input type="number" name="weight" id="cmWeight" placeholder="0.0" step="0.1"><span>kg</span></div>
          </div>
          <div class="rm-group">
            <label>체온</label>
            <div class="rm-input-unit"><input type="number" name="temperature" id="cmTemp" placeholder="0.0" step="0.1"><span>℃</span></div>
            <span class="rm-hint">정상 범위: 개 37.5~39.2℃ / 고양이 38.1~39.2℃</span>
          </div>
          <div class="rm-group">
            <label>심박수</label>
            <div class="rm-input-unit"><input type="number" name="heartRate" id="cmHeart" placeholder="0"><span>bpm</span></div>
          </div>
          <div class="rm-group">
            <label>호흡수</label>
            <div class="rm-input-unit"><input type="number" name="breathRate" id="cmBreath" placeholder="0"><span>회/분</span></div>
          </div>
        </div>

        <div class="rm-section-label">추가 정보</div>
        <div class="rm-grid">
          <div class="rm-group full">
            <label>수의사 메모</label>
            <textarea name="memo" id="cmMemo" placeholder="보호자에게 전달할 주의사항, 재방문 권장 이유, 관리 방법 등을 입력하세요."></textarea>
          </div>
          <div class="rm-group">
            <label>다음 방문 권장일</label>
            <input type="date" name="nextVisit" id="cmNextVisit">
            <span class="rm-hint">기록에 함께 저장됩니다.</span>
          </div>
          <div class="rm-group">
            <label>담당 수의사</label>
            <input type="text" name="vetName" id="cmVetName" placeholder="예) 김철수 수의사">
          </div>
        </div>
      </div>
      <div class="rm-footer">
        <button type="button" class="btn-rm-cancel" onclick="closeCompleteModal()">취소</button>
        <button type="button" class="btn-rm-save" onclick="submitCompleteRecord()">
          <svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>
          저장 · 진료완료
        </button>
      </div>
    </form>
  </div>
</div>

<%-- 2026/07/11 장우철 — 예약취소 사유 필수 모달 --%>
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
        placeholder="예: 당일 진료 일정 변경으로 예약이 어렵습니다."></textarea>
      <div style="display:flex;gap:8px;justify-content:flex-end;margin-top:14px">
        <button type="button" class="biz-btn ghost" onclick="closeCancelModal()">닫기</button>
        <button type="button" class="biz-btn danger" onclick="submitCancel()">예약취소</button>
      </div>
    </div>
  </div>
</div>

<script>
  // 2026-07-10 장우철 — 서버 목록 → JS (탭 필터·모달)
  // 2026/07/11 장우철 — PENDING/CONFIRMED 분리, 신청→확정→완료 버튼
  // 2026/08/06 장우철 — CSRF는 문자열로 보관 (UUID 미인용 삽입 시 스크립트 파싱 깨짐)
  var csrfToken = (document.querySelector('meta[name="_csrf"]') || {}).content
      || '<c:out value="${_csrf}"/>';
  var reservations = [
    <c:forEach var="r" items="${reservationList}" varStatus="st">
    {
      resvId: ${r.resvId},
      resvNo: '<c:out value="${r.resvNo}"/>',
      name: '<c:out value="${r.memberName}"/>',
      pet: '<c:out value="${r.petName}"/> (<c:out value="${r.petSpecies}"/>)',
      dateStr: '<fmt:formatDate value="${r.resvDate}" pattern="yyyy-MM-dd"/>',
      dateLabel: '<fmt:formatDate value="${r.resvDate}" pattern="M/d"/>',
      time: '<c:out value="${r.resvTime}"/>',
      endTime: '<c:out value="${r.endTime}"/>',
      doctorName: '<c:out value="${r.doctorName}"/>',
      treatTypeName: '<c:out value="${r.treatTypeName}"/>',
      symptoms: '<c:out value="${r.symptoms}"/>',
      requestMemo: '<c:out value="${r.requestMemo}"/>',
      statusCd: '<c:out value="${r.statusCd}"/>',
      status: (function(cd){
        if (cd === 'PENDING') return 'pending';
        if (cd === 'CONFIRMED') return 'confirmed';
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
    done:      { cls: 'bs-done',   label: '진료완료' },
    cancel:    { cls: 'bs-cancel', label: '취소' }
  };

  function switchTab(tab) {
    currentTab = tab;
    document.querySelectorAll('.biz-tab').forEach(function (b) { b.classList.toggle('active', b.dataset.tab === tab); });
    renderTable();
  }

  function renderTable() {
    var list = reservations.filter(function (r) { return currentTab === 'all' || r.status === currentTab; });

    document.getElementById('cntAll').textContent = reservations.length;
    document.getElementById('cntPending').textContent = reservations.filter(function (r) { return r.status === 'pending'; }).length;
    document.getElementById('cntConfirmed').textContent = reservations.filter(function (r) { return r.status === 'confirmed'; }).length;
    document.getElementById('cntDone').textContent = reservations.filter(function (r) { return r.status === 'done'; }).length;
    document.getElementById('cntCancel').textContent = reservations.filter(function (r) { return r.status === 'cancel'; }).length;

    var body = document.getElementById('reserveBody');
    body.innerHTML = '';

    if (list.length === 0) {
      body.innerHTML = '<tr><td colspan="7" style="text-align:center; color:#aaa; padding:60px 0;">해당 예약이 없습니다.</td></tr>';
      return;
    }

    list.forEach(function (r) {
      var badge = badgeMap[r.status] || badgeMap.pending;
      var tr = document.createElement('tr');
      var timeLabel = r.time + (r.endTime ? '~' + r.endTime : '');
      var staffLabel = (r.doctorName || '-') + ' · ' + (r.treatTypeName || '-');

      var actionHtml =
        '<button type="button" class="biz-btn ghost" onclick="openReserveModal(' + r.resvId + ')">상세</button> ';
      if (r.status === 'pending') {
        actionHtml +=
          '<button type="button" class="biz-btn" onclick="postStatus(' + r.resvId + ',\'CONFIRMED\')">예약확정</button> ' +
          '<button type="button" class="biz-btn danger" onclick="openCancelModal(' + r.resvId + ')">예약취소</button>';
      } else if (r.status === 'confirmed') {
        actionHtml +=
          '<button type="button" class="biz-btn" onclick="openCompleteModal(' + r.resvId + ')">진료완료</button> ' +
          '<button type="button" class="biz-btn danger" onclick="openCancelModal(' + r.resvId + ')">예약취소</button>';
      }

      tr.innerHTML =
        '<td>' + r.resvNo + '</td>' +
        '<td>' + r.name + '</td>' +
        '<td>' + r.pet + '</td>' +
        '<td>' + r.dateLabel + ' ' + timeLabel + '</td>' +
        '<td>' + staffLabel + '</td>' +
        '<td><span class="bs-badge ' + badge.cls + '">' + badge.label + '</span></td>' +
        '<td>' + actionHtml + '</td>';
      body.appendChild(tr);
    });
  }

  function postStatus(resvId, statusCd) {
    if (statusCd === 'CONFIRMED' && !confirm('예약을 확정하시겠습니까?')) return;
    // 2026/07/13 장우철 — DONE 은 openCompleteModal 로 분리 (바로 postStatus 호출 안 함)

    var form = document.createElement('form');
    form.method = 'POST';
    form.action = contextPath + '/biz/hospital/reserve/status';
    form.innerHTML =
      '<input type="hidden" name="resvId" value="' + resvId + '">' +
      '<input type="hidden" name="statusCd" value="' + statusCd + '">' +
      '<input type="hidden" name="_csrf" value="${_csrf}">';
    document.body.appendChild(form);
    form.submit();
  }

  // 2026/07/13 장우철 — 진료완료: 상세 조회 후 풀모달 자동채움
  function syncCmTreatType() {
    var checked = document.querySelector('input[name="cmRecType"]:checked');
    document.getElementById('cmTreatType').value = checked ? checked.value : '진료';
  }

  function openCompleteModal(resvId) {
    fetch(contextPath + '/biz/hospital/reserve/detail?resvId=' + resvId)
      .then(function(res) { return res.json(); })
      .then(function(data) {
        if (!data) { alert('예약 정보를 불러올 수 없습니다.'); return; }
        document.getElementById('completeRecordForm').reset();
        document.getElementById('cm-type-treat').checked = true;
        document.getElementById('cmTreatType').value = '진료';
        document.getElementById('cmResvId').value = data.resvId;
        var petLabel = data.petName || '-';
        if (data.petBreed) petLabel += ' (' + data.petBreed + ')';
        if (data.petSpecies) petLabel += ' / ' + data.petSpecies;
        document.getElementById('cmPet').textContent = petLabel;
        document.getElementById('cmMemberMeta').textContent = '보호자: ' + (data.memberName || '-');
        var dateLabel = data.resvDate ? String(data.resvDate).substring(0, 10) : '-';
        if (data.resvTime) dateLabel += ' ' + data.resvTime;
        document.getElementById('cmDateBadge').textContent = dateLabel;
        document.getElementById('cmSymptoms').value = data.symptoms || '';
        document.getElementById('completeModalBg').classList.add('open');
        document.body.style.overflow = 'hidden';
      })
      .catch(function() { alert('예약 정보를 불러올 수 없습니다.'); });
  }

  function closeCompleteModal() {
    document.getElementById('completeModalBg').classList.remove('open');
    document.body.style.overflow = '';
  }

  function submitCompleteRecord() {
    var symptoms = document.getElementById('cmSymptoms').value.trim();
    var diagnosis = document.getElementById('cmDiagnosis').value.trim();
    if (!symptoms) { alert('주증상을 입력해 주세요.'); return; }
    if (!diagnosis) { alert('진단명을 입력해 주세요.'); return; }
    syncCmTreatType();
    if (!confirm('진료완료로 처리하고 기록을 저장할까요?')) return;
    document.getElementById('completeRecordForm').submit();
  }

  // 2026/07/11 장우철 — 취소 사유 모달
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
    form.action = contextPath + '/biz/hospital/reserve/status';
    form.innerHTML =
      '<input type="hidden" name="resvId" value="' + cancelTargetResvId + '">' +
      '<input type="hidden" name="statusCd" value="CANCEL">' +
      '<input type="hidden" name="cancelReason" value="">' +
      '<input type="hidden" name="_csrf" value="${_csrf}">';
    form.querySelector('input[name="cancelReason"]').value = reason;
    document.body.appendChild(form);
    form.submit();
  }

  function openReserveModal(resvId) {
    fetch(contextPath + '/biz/hospital/reserve/detail?resvId=' + resvId)
      .then(function(res) { return res.json(); })
      .then(function(data) {
        if (!data) { alert('예약 정보를 불러올 수 없습니다.'); return; }
        document.getElementById('mdMember').textContent = data.memberName || '-';
        var petLabel = data.petName || '-';
        if (data.petBreed) petLabel += ' (' + data.petBreed + ')';
        document.getElementById('mdPet').textContent = petLabel;
        document.getElementById('mdDate').textContent = data.resvDate ? String(data.resvDate).substring(0, 10) : '-';
        var timeText = data.resvTime || '-';
        if (data.endTime) timeText += ' ~ ' + data.endTime;
        document.getElementById('mdTime').textContent = timeText;
        document.getElementById('mdDoctor').textContent = data.doctorName || '-';
        document.getElementById('mdTreat').textContent = data.treatTypeName || '-';
        document.getElementById('mdSymptoms').textContent = data.symptoms || '-';
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
