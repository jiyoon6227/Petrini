<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="hospital" />
<%@ include file="/WEB-INF/views/common/header.jsp" %>
<style>
.reserve-wrap{max-width:700px;margin:32px auto 80px;padding:0 20px}
.reserve-title{font-size:22px;font-weight:800;color:var(--text-main);margin-bottom:6px}
.reserve-hospital{font-size:14px;color:var(--text-muted);margin-bottom:28px}
.reserve-alert{background:#FEF2F2;border:1px solid #FECACA;color:#B91C1C;padding:12px 14px;border-radius:var(--radius-sm);font-size:14px;margin-bottom:20px}
.step-bar{display:flex;align-items:center;margin-bottom:36px}
.step-item{display:flex;flex-direction:column;align-items:center;gap:6px;flex:1;position:relative}
.step-item:not(:last-child)::after{content:"";position:absolute;top:18px;left:50%;right:-50%;height:2px;background:var(--border);z-index:0}
.step-item.done:not(:last-child)::after,.step-item.active:not(:last-child)::after{background:var(--primary)}
.step-num{width:36px;height:36px;border-radius:50%;border:2px solid var(--border);display:flex;align-items:center;justify-content:center;font-size:13px;font-weight:700;color:var(--text-muted);background:#fff;position:relative;z-index:1}
.step-item.done .step-num{background:var(--primary);border-color:var(--primary);color:#fff}
.step-item.active .step-num{background:var(--primary-light);border-color:var(--primary);color:var(--primary-dark)}
.step-label{font-size:12px;color:var(--text-muted);font-weight:500}
.step-item.active .step-label{color:var(--primary-dark);font-weight:700}
.step-section{display:none}.step-section.on{display:block}
.step-section-title{font-size:18px;font-weight:800;color:var(--text-main);margin-bottom:18px}
.step-subtitle{font-size:14px;font-weight:700;color:var(--text-main);margin:22px 0 12px}
.reserve-date-input{width:100%;border:1px solid var(--border);border-radius:var(--radius-sm);padding:12px 14px;font-size:15px;box-sizing:border-box}
.select-grid{display:grid;grid-template-columns:1fr 1fr;gap:14px}
@media(max-width:560px){.select-grid{grid-template-columns:1fr}}
.select-card{border:2px solid var(--border);border-radius:var(--radius-md);padding:14px 16px;cursor:pointer;transition:var(--transition)}
.select-card:hover{border-color:var(--primary)}
.select-card.selected{border-color:var(--primary);background:var(--primary-light)}
.select-card-name{font-size:15px;font-weight:700;color:var(--text-main);margin-bottom:4px}
.select-card-meta{font-size:12px;color:var(--text-muted)}
.time-slots{display:grid;grid-template-columns:repeat(4,1fr);gap:10px}
.time-slot{padding:10px;border:1px solid var(--border);border-radius:var(--radius-sm);text-align:center;font-size:14px;cursor:pointer;transition:var(--transition);color:var(--text-sub)}
.time-slot:hover{border-color:var(--primary);color:var(--primary)}
.time-slot.selected{border-color:var(--primary);background:var(--primary);color:#fff;font-weight:700}
.time-slot.disabled{opacity:.4;cursor:not-allowed;pointer-events:none}
.pet-select-grid{display:grid;grid-template-columns:1fr 1fr;gap:14px}
.pet-select-card{border:2px solid var(--border);border-radius:var(--radius-md);padding:16px;display:flex;align-items:center;gap:14px;cursor:pointer;transition:var(--transition)}
.pet-select-card:hover{border-color:var(--primary)}
.pet-select-card.selected{border-color:var(--primary);background:var(--primary-light)}
.pet-select-thumb{width:56px;height:56px;border-radius:50%;object-fit:cover;flex-shrink:0;background:var(--primary-light);display:flex;align-items:center;justify-content:center;font-size:20px;font-weight:800;color:var(--primary-dark)}
.pet-select-name{font-size:15px;font-weight:700;color:var(--text-main);margin-bottom:3px}
.pet-select-meta{font-size:12px;color:var(--text-muted)}
.symptom-chips{display:flex;flex-wrap:wrap;gap:8px;margin-bottom:14px}
.reserve-textarea{width:100%;border:1px solid var(--border);border-radius:var(--radius-sm);padding:12px 14px;font-size:14px;min-height:100px;resize:vertical;outline:none;font-family:inherit;box-sizing:border-box}
.reserve-textarea:focus{border-color:var(--primary)}
.reserve-summary{background:var(--bg-page);border-radius:var(--radius-md);padding:20px;display:flex;flex-direction:column;gap:12px}
.rs-row{display:flex;justify-content:space-between;font-size:14px}
.rs-row span:first-child{color:var(--text-muted)}
.rs-row span:last-child{color:var(--text-main);font-weight:600;text-align:right}
.reserve-nav{display:flex;justify-content:space-between;margin-top:24px}
.btn-prev{padding:12px 28px;border:1px solid var(--border);border-radius:var(--radius-sm);background:#fff;color:var(--text-sub);font-size:15px;font-weight:700;cursor:pointer}
.btn-next{padding:12px 32px;border:none;border-radius:var(--radius-sm);background:var(--primary);color:#fff;font-size:15px;font-weight:700;cursor:pointer;transition:var(--transition)}
.btn-next:hover{background:var(--primary-dark)}
.btn-next:disabled{opacity:.5;cursor:not-allowed}
.reserve-empty{text-align:center;padding:24px 0;color:var(--text-muted);font-size:14px}
.reserve-hint{font-size:13px;color:var(--text-muted);margin-bottom:12px}
</style>

<%-- 2026/07/16 장우철 — 예약 UI: 1)일정(날짜·의사·유형·시간) 2)펫·증상, 선점(hold) --%>
<form id="reserveForm" method="post" action="${contextPath}/hospital/reserve">
  <!--HYJ 26.08.05-->
  <input type="hidden" name="_csrf" value="${_csrf}">
  
  <input type="hidden" name="hospitalId" value="${hospitalId}">
  <input type="hidden" name="holdId" id="holdIdInput" value="">
  <input type="hidden" name="petId" id="petIdInput" value="">

<div class="reserve-wrap">
  <h1 class="reserve-title">병원 예약</h1>
  <div class="reserve-hospital">${hospital.name} · ${hospital.addr}</div>

  <c:if test="${not empty errorMsg}">
    <div class="reserve-alert">${errorMsg}</div>
  </c:if>

  <div class="step-bar">
    <div class="step-item active" id="si1"><div class="step-num">1</div><span class="step-label">일정 선택</span></div>
    <div class="step-item" id="si2"><div class="step-num">2</div><span class="step-label">반려동물·내용</span></div>
  </div>

  <!-- 1단계: 날짜 → 의사·유형 → 가능시간 -->
  <div class="step-section on" id="step1">
    <div class="step-section-title">예약 일정을 선택하세요</div>

    <div class="step-subtitle">예약 날짜</div>
    <input type="date" class="reserve-date-input" id="resvDate" required>
    <div id="closedDayAlert" class="reserve-alert" style="display:none;margin-top:12px"></div>

    <div id="schedulePanel" style="display:none">
      <div class="step-subtitle">담당 의사</div>
      <c:choose>
        <c:when test="${empty doctorList}">
          <div class="reserve-empty">등록된 의사가 없습니다. 병원에 문의해 주세요.</div>
        </c:when>
        <c:otherwise>
          <div class="select-grid" id="doctorGrid">
            <c:forEach var="doc" items="${doctorList}">
              <div class="select-card" data-doctor-id="${doc.doctorId}"
                   data-doctor-name="${doc.doctorName}"
                   onclick="selectDoctor(this)">
                <div class="select-card-name">${doc.doctorName}</div>
                <div class="select-card-meta">${empty doc.specialty ? '진료' : doc.specialty}</div>
              </div>
            </c:forEach>
          </div>
        </c:otherwise>
      </c:choose>

      <div class="step-subtitle">진료 유형</div>
      <c:choose>
        <c:when test="${empty treatTypeList}">
          <div class="reserve-empty">등록된 진료 유형이 없습니다. 병원에 문의해 주세요.</div>
        </c:when>
        <c:otherwise>
          <div class="select-grid" id="treatGrid">
            <c:forEach var="tt" items="${treatTypeList}">
              <div class="select-card" data-treat-id="${tt.treatTypeId}"
                   data-treat-name="${tt.typeName}"
                   data-duration="${tt.durationMin}"
                   onclick="selectTreatType(this)">
                <div class="select-card-name">${tt.typeName}</div>
                <div class="select-card-meta">약 ${tt.durationMin}분</div>
              </div>
            </c:forEach>
          </div>
        </c:otherwise>
      </c:choose>

      <div class="step-subtitle">예약 가능 시간</div>
      <p class="reserve-hint" id="timeHint">의사와 진료 유형을 선택하면 가능한 시간이 표시됩니다.</p>
      <div class="time-slots" id="timeSlots"></div>
    </div>

    <div class="reserve-nav">
      <span></span>
      <button type="button" class="btn-next" id="btnToStep2" onclick="goToPetStep()" disabled>다음 →</button>
    </div>
  </div>

  <!-- 2단계: 펫·증상·확정 -->
  <div class="step-section" id="step2">
    <div class="step-section-title">반려동물과 증상을 입력하세요</div>

    <div class="step-subtitle">반려동물 선택</div>
    <c:choose>
      <c:when test="${empty petList}">
        <div class="reserve-empty">등록된 반려동물이 없습니다.<br>마이페이지에서 반려동물을 등록해 주세요.</div>
      </c:when>
      <c:otherwise>
        <div class="pet-select-grid">
          <c:forEach var="pet" items="${petList}" varStatus="st">
            <div class="pet-select-card ${st.first ? 'selected' : ''}" data-pet-id="${pet.petId}"
                 data-pet-name="${pet.petName}"
                 data-pet-meta="${pet.breed} · ${pet.age}세"
                 onclick="selectPet(this)">
              <div class="pet-select-thumb">${fn:substring(pet.petName, 0, 1)}</div>
              <div>
                <div class="pet-select-name">${pet.petName}</div>
                <div class="pet-select-meta">
                  <c:choose>
                    <c:when test="${pet.species eq 'DOG'}">강아지</c:when>
                    <c:when test="${pet.species eq 'CAT'}">고양이</c:when>
                    <c:otherwise>기타</c:otherwise>
                  </c:choose>
                  · ${pet.breed} · ${pet.age}세
                </div>
              </div>
            </div>
          </c:forEach>
        </div>
      </c:otherwise>
    </c:choose>

    <div class="step-subtitle" style="margin-top:24px">증상 및 요청사항</div>
    <div class="symptom-chips">
      <span class="chip" onclick="toggleChip(this)">정기검진</span>
      <span class="chip" onclick="toggleChip(this)">피부 트러블</span>
      <span class="chip" onclick="toggleChip(this)">구토/설사</span>
      <span class="chip" onclick="toggleChip(this)">식욕 저하</span>
      <span class="chip" onclick="toggleChip(this)">예방접종</span>
    </div>
    <input type="text" name="symptoms" id="symptomsInput" class="reserve-date-input" style="margin-bottom:12px" placeholder="주요 증상">
    <textarea class="reserve-textarea" name="requestMemo" id="requestMemoInput" placeholder="요청사항 (선택)"></textarea>

    <div style="margin-top:20px;margin-bottom:14px"><strong style="font-size:15px;color:var(--text-main)">예약 최종 확인</strong></div>
    <div class="reserve-summary">
      <div class="rs-row"><span>병원</span><span>${hospital.name}</span></div>
      <div class="rs-row"><span>의사</span><span id="sumDoctor">-</span></div>
      <div class="rs-row"><span>진료 유형</span><span id="sumTreat">-</span></div>
      <div class="rs-row"><span>예약 일시</span><span id="sumDateTime">-</span></div>
      <div class="rs-row"><span>반려동물</span><span id="sumPet">-</span></div>
      <div class="rs-row"><span>주증상</span><span id="sumSymptom">-</span></div>
    </div>

    <div class="reserve-nav">
      <button type="button" class="btn-prev" onclick="goBackToStep1()">이전</button>
      <button type="button" class="btn-next" onclick="submitReserve()">예약 완료</button>
    </div>
  </div>
</div>
</form>

<script>
var contextPath = '${contextPath}';
var hospitalId = ${hospitalId};
// 2026/08/07 장우철 — CSRF (hold/release POST)
var csrfToken = '${_csrf}';
var currentStep = 1;
var selectedDoctorId = null;
var selectedDoctorName = '';
var selectedTreatId = null;
var selectedTreatName = '';
var selectedDuration = 0;
var selectedResvTime = '';
var selectedResvDate = '';
var selectedPetCard = null;
var loadingTimes = false;
// 2026/08/07 장우철 — 예약 제출 중에는 이탈 해제 스킵 (서버가 hold 소비)
var skipLeaveHoldRelease = false;

function goStep(n) {
  // 2026/07/16 장우철 — 1·2단계 전환 (선점 성공 후 goStep(2) 호출)
  document.getElementById('step' + currentStep).classList.remove('on');
  for (var i = 1; i <= 2; i++) {
    var si = document.getElementById('si' + i);
    si.className = 'step-item';
    if (i < n) si.classList.add('done');
    else if (i === n) si.classList.add('active');
  }
  currentStep = n;
  document.getElementById('step' + n).classList.add('on');
  window.scrollTo(0, 0);
}

// 2026/07/20 장우철 — 2단계 이전: hold 해제 후 1단계 (다른 회원 즉시 재선택)
function goBackToStep1() {
  var holdId = document.getElementById('holdIdInput').value;
  function afterRelease() {
    document.getElementById('holdIdInput').value = '';
    goStep(1);
    if (selectedResvDate && selectedDoctorId && selectedTreatId) {
      loadAvailableTimes();
    }
  }
  if (!holdId) {
    afterRelease();
    return;
  }
  var body = new URLSearchParams();
  body.append('hospitalId', hospitalId);
  csrfFetch(contextPath + '/hospital/reserve/hold/release', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
      'X-CSRF-TOKEN': csrfToken
    },
    body: body.toString()
  })
    .then(function() { afterRelease(); })
    .catch(function() { afterRelease(); });
}

/**
 * 2026/08/07 장우철 — 예약 중 이탈 시 hold 즉시 해제 시도
 * - 성공하면 다른 회원이 바로 선택 가능
 * - 실패(브라우저 제한 등)해도 서버 TTL 5분 + 만료 스케줄러가 안전망
 */
function releaseHoldOnLeave() {
  if (skipLeaveHoldRelease) {
    return;
  }
  var holdId = document.getElementById('holdIdInput').value;
  if (!holdId) {
    return;
  }
  var body = new URLSearchParams();
  body.append('hospitalId', hospitalId);
  body.append('_csrf', csrfToken);
  var url = contextPath + '/hospital/reserve/hold/release';
  var payload = body.toString();
  try {
    if (navigator.sendBeacon) {
      var blob = new Blob([payload], { type: 'application/x-www-form-urlencoded' });
      if (navigator.sendBeacon(url, blob)) {
        document.getElementById('holdIdInput').value = '';
        return;
      }
    }
  } catch (e) { /* fallback */ }
  try {
    fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'X-CSRF-TOKEN': csrfToken
      },
      body: payload,
      keepalive: true,
      credentials: 'same-origin'
    });
  } catch (e2) { /* TTL 안전망 */ }
  document.getElementById('holdIdInput').value = '';
}

function onDateChange() {
  selectedResvDate = document.getElementById('resvDate').value;
  selectedResvTime = '';
  document.getElementById('holdIdInput').value = '';
  document.getElementById('btnToStep2').disabled = true;
  clearTimeSlots();
  document.getElementById('closedDayAlert').style.display = 'none';

  if (!selectedResvDate) {
    document.getElementById('schedulePanel').style.display = 'none';
    return;
  }

  var dayUrl = contextPath + '/hospital/reserve/day-check'
      + '?hospitalId=' + encodeURIComponent(hospitalId)
      + '&resvDate=' + encodeURIComponent(selectedResvDate);

  fetch(dayUrl, { headers: { 'Accept': 'application/json' } })
    .then(function(res) { return res.json(); })
    .then(function(json) {
      if (!json.ok) {
        document.getElementById('schedulePanel').style.display = 'none';
        document.getElementById('closedDayAlert').textContent = json.msg || '예약 가능 여부를 확인하지 못했습니다.';
        document.getElementById('closedDayAlert').style.display = 'block';
        return;
      }
      if (json.data && json.data.closed) {
        document.getElementById('schedulePanel').style.display = 'none';
        document.getElementById('closedDayAlert').textContent = json.data.message || '선택한 날짜는 예약할 수 없습니다.';
        document.getElementById('closedDayAlert').style.display = 'block';
        return;
      }
      document.getElementById('schedulePanel').style.display = 'block';
      if (selectedDoctorId && selectedTreatId) {
        loadAvailableTimes();
      }
    })
    .catch(function() {
      document.getElementById('schedulePanel').style.display = 'none';
      document.getElementById('closedDayAlert').textContent = '예약 가능 여부를 확인하지 못했습니다.';
      document.getElementById('closedDayAlert').style.display = 'block';
    });
}

function selectDoctor(el) {
  document.querySelectorAll('#doctorGrid .select-card').forEach(function(c) { c.classList.remove('selected'); });
  el.classList.add('selected');
  selectedDoctorId = el.getAttribute('data-doctor-id');
  selectedDoctorName = el.getAttribute('data-doctor-name');
  selectedResvTime = '';
  document.getElementById('holdIdInput').value = '';
  document.getElementById('btnToStep2').disabled = true;
  tryLoadTimes();
}

function selectTreatType(el) {
  document.querySelectorAll('#treatGrid .select-card').forEach(function(c) { c.classList.remove('selected'); });
  el.classList.add('selected');
  selectedTreatId = el.getAttribute('data-treat-id');
  selectedTreatName = el.getAttribute('data-treat-name');
  selectedDuration = parseInt(el.getAttribute('data-duration'), 10) || 0;
  selectedResvTime = '';
  document.getElementById('holdIdInput').value = '';
  document.getElementById('btnToStep2').disabled = true;
  tryLoadTimes();
}

function tryLoadTimes() {
  if (selectedResvDate && selectedDoctorId && selectedTreatId) {
    loadAvailableTimes();
  }
}

function clearTimeSlots() {
  document.getElementById('timeSlots').innerHTML = '';
  document.getElementById('timeHint').textContent = '의사와 진료 유형을 선택하면 가능한 시간이 표시됩니다.';
}

function loadAvailableTimes() {
  if (loadingTimes) return;
  loadingTimes = true;
  clearTimeSlots();
  document.getElementById('timeHint').textContent = '예약 가능 시간을 불러오는 중...';

  var url = contextPath + '/hospital/reserve/times'
      + '?hospitalId=' + encodeURIComponent(hospitalId)
      + '&doctorId=' + encodeURIComponent(selectedDoctorId)
      + '&treatTypeId=' + encodeURIComponent(selectedTreatId)
      + '&resvDate=' + encodeURIComponent(selectedResvDate);

  fetch(url, { headers: { 'Accept': 'application/json' } })
    .then(function(res) { return res.json(); })
    .then(function(json) {
      loadingTimes = false;
      if (!json.ok) {
        document.getElementById('timeHint').textContent = json.msg || '시간을 불러오지 못했습니다.';
        return;
      }
      var times = json.data || [];
      var box = document.getElementById('timeSlots');
      box.innerHTML = '';
      if (!times.length) {
        document.getElementById('timeHint').textContent = '선택한 조건에 예약 가능한 시간이 없습니다.';
        return;
      }
      document.getElementById('timeHint').textContent = selectedResvDate + ' 예약 가능 시간';
      times.forEach(function(t) {
        var div = document.createElement('div');
        div.className = 'time-slot';
        div.setAttribute('data-time', t);
        div.textContent = t;
        div.onclick = function() { selTime(div); };
        box.appendChild(div);
      });
    })
    .catch(function() {
      loadingTimes = false;
      document.getElementById('timeHint').textContent = '시간을 불러오지 못했습니다. 다시 시도해 주세요.';
    });
}

function selTime(el) {
  document.querySelectorAll('.time-slot').forEach(function(t) { t.classList.remove('selected'); });
  el.classList.add('selected');
  selectedResvTime = el.getAttribute('data-time');
  document.getElementById('holdIdInput').value = '';
  document.getElementById('btnToStep2').disabled = false;
}

function goToPetStep() {
  if (!selectedResvDate) { alert('예약 날짜를 선택해 주세요.'); return; }
  if (!selectedDoctorId) { alert('의사를 선택해 주세요.'); return; }
  if (!selectedTreatId) { alert('진료 유형을 선택해 주세요.'); return; }
  if (!selectedResvTime) { alert('예약 시간을 선택해 주세요.'); return; }

  var btn = document.getElementById('btnToStep2');
  btn.disabled = true;
  btn.textContent = '선점 중...';

  var body = new URLSearchParams();
  body.append('hospitalId', hospitalId);
  body.append('doctorId', selectedDoctorId);
  body.append('treatTypeId', selectedTreatId);
  body.append('resvDate', selectedResvDate);
  body.append('resvTime', selectedResvTime);
  body.append('_csrf', csrfToken);

  csrfFetch(contextPath + '/hospital/reserve/hold', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
      'X-CSRF-TOKEN': csrfToken
    },
    body: body.toString()
  })
    .then(function(res) { return res.json(); })
    .then(function(json) {
      btn.textContent = '다음 →';
      if (!json.ok) {
        btn.disabled = false;
        alert(json.msg || '시간 선점에 실패했습니다.');
        loadAvailableTimes();
        return;
      }
      document.getElementById('holdIdInput').value = json.data.holdId;
      updateSummarySchedule();
      goStep(2);
      var first = document.querySelector('.pet-select-card.selected') || document.querySelector('.pet-select-card');
      if (first) selectPet(first);
      btn.disabled = false;
    })
    .catch(function() {
      btn.textContent = '다음 →';
      btn.disabled = false;
      alert('시간 선점에 실패했습니다. 다시 시도해 주세요.');
    });
}

function selectPet(el) {
  document.querySelectorAll('.pet-select-card').forEach(function(c) { c.classList.remove('selected'); });
  el.classList.add('selected');
  selectedPetCard = el;
  document.getElementById('petIdInput').value = el.getAttribute('data-pet-id');
  updateSummaryPet();
}

function toggleChip(el) {
  el.classList.toggle('on');
  var chips = [];
  document.querySelectorAll('.symptom-chips .chip.on').forEach(function(c) { chips.push(c.textContent); });
  if (chips.length) document.getElementById('symptomsInput').value = chips.join(', ');
  document.getElementById('sumSymptom').textContent = document.getElementById('symptomsInput').value || '-';
}

function updateSummarySchedule() {
  document.getElementById('sumDoctor').textContent = selectedDoctorName || '-';
  document.getElementById('sumTreat').textContent = selectedTreatName
      ? selectedTreatName + ' (' + selectedDuration + '분)'
      : '-';
  var endLabel = selectedResvTime && selectedDuration
      ? ' ~ ' + calcEndTimeLabel(selectedResvTime, selectedDuration)
      : '';
  document.getElementById('sumDateTime').textContent = selectedResvDate + ' ' + selectedResvTime + endLabel;
}

function updateSummaryPet() {
  if (!selectedPetCard) return;
  document.getElementById('sumPet').textContent =
      selectedPetCard.getAttribute('data-pet-name') + ' (' + selectedPetCard.getAttribute('data-pet-meta') + ')';
}

function calcEndTimeLabel(start, durationMin) {
  var p = start.split(':');
  var h = parseInt(p[0], 10);
  var m = parseInt(p[1], 10) + durationMin;
  h += Math.floor(m / 60);
  m = m % 60;
  return (h < 10 ? '0' : '') + h + ':' + (m < 10 ? '0' : '') + m;
}

function submitReserve() {
  if (!document.getElementById('holdIdInput').value) {
    alert('예약 일정이 만료되었습니다. 처음부터 다시 선택해 주세요.');
    goStep(1);
    return;
  }
  if (!document.getElementById('petIdInput').value) {
    alert('반려동물을 선택해 주세요.');
    return;
  }
  if (confirm('예약을 확정하시겠습니까?')) {
    // 2026/08/07 장우철 — 제출 시 unload 해제와 경합 방지
    skipLeaveHoldRelease = true;
    document.getElementById('reserveForm').submit();
  }
}

(function init() {
  var today = new Date().toISOString().slice(0, 10);
  var dateInput = document.getElementById('resvDate');
  dateInput.setAttribute('min', today);
  dateInput.addEventListener('change', onDateChange);
  var firstPet = document.querySelector('.pet-select-card');
  if (firstPet) selectPet(firstPet);

  // 2026/08/07 장우철 — 이탈(닫기/뒤로/다른 페이지) 시 hold 즉시 해제 시도
  window.addEventListener('pagehide', releaseHoldOnLeave);
  window.addEventListener('beforeunload', releaseHoldOnLeave);
})();
</script>
<%@ include file="/WEB-INF/views/common/footer.jsp" %>
