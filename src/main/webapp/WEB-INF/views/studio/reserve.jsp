<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="studio" />
<%@ include file="/WEB-INF/views/common/header.jsp" %>
<style>
.reserve-wrap{max-width:700px;margin:32px auto 80px;padding:0 20px}
.reserve-title{font-size:22px;font-weight:800;color:var(--text-main);margin-bottom:6px}
.reserve-shop{font-size:14px;color:var(--text-muted);margin-bottom:28px}
/* 스텝 인디케이터 */
.step-bar{display:flex;align-items:center;margin-bottom:36px}
.step-item{display:flex;flex-direction:column;align-items:center;gap:6px;flex:1;position:relative}
.step-item:not(:last-child)::after{content:"";position:absolute;top:18px;left:50%;right:-50%;height:2px;background:var(--border);z-index:0}
.step-item.done:not(:last-child)::after,.step-item.active:not(:last-child)::after{background:#9333EA}
.step-num{width:36px;height:36px;border-radius:50%;border:2px solid var(--border);display:flex;align-items:center;justify-content:center;font-size:13px;font-weight:700;color:var(--text-muted);background:#fff;position:relative;z-index:1}
.step-item.done .step-num{background:#9333EA;border-color:#9333EA;color:#fff}
.step-item.active .step-num{background:#F3E8FF;border-color:#9333EA;color:#6B21A8}
.step-label{font-size:12px;color:var(--text-muted);font-weight:500}
.step-item.active .step-label{color:#6B21A8;font-weight:700}
/* 단계별 내용 */
.step-section{display:none}.step-section.on{display:block}
.step-section-title{font-size:18px;font-weight:800;color:var(--text-main);margin-bottom:18px}
/* 반려동물 선택 */
.pet-select-grid{display:grid;grid-template-columns:1fr 1fr;gap:14px}
.pet-select-card{border:2px solid var(--border);border-radius:var(--radius-md);padding:16px;display:flex;align-items:center;gap:14px;cursor:pointer;transition:var(--transition)}
.pet-select-card:hover{border-color:#9333EA}
.pet-select-card.selected{border-color:#9333EA;background:#F3E8FF}
.pet-select-thumb{width:56px;height:56px;border-radius:50%;object-fit:cover;flex-shrink:0}
.pet-select-name{font-size:15px;font-weight:700;color:var(--text-main);margin-bottom:3px}
.pet-select-meta{font-size:12px;color:var(--text-muted)}
/* 날짜 */
.cal-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:14px}
.cal-nav-btn{background:none;border:1px solid var(--border);border-radius:var(--radius-sm);width:32px;height:32px;cursor:pointer;font-size:16px;display:flex;align-items:center;justify-content:center}
.cal-grid{display:grid;grid-template-columns:repeat(7,1fr);gap:4px}
.cal-day-head{text-align:center;font-size:12px;font-weight:600;color:var(--text-muted);padding:6px 0}
.cal-day{text-align:center;padding:10px 0;border-radius:var(--radius-sm);font-size:14px;cursor:pointer;color:var(--text-sub);transition:var(--transition)}
.cal-day:hover{background:#F3E8FF;color:#6B21A8}
.cal-day.selected{background:#9333EA;color:#fff;font-weight:700}
.cal-day.disabled{color:var(--border);cursor:not-allowed}
.cal-day.today{font-weight:800;color:#6B21A8}
/* 시간 슬롯 */
.time-slots{display:grid;grid-template-columns:repeat(4,1fr);gap:10px}
.time-slot{padding:10px;border:1px solid var(--border);border-radius:var(--radius-sm);text-align:center;font-size:14px;cursor:pointer;transition:var(--transition);color:var(--text-sub)}
.time-slot:hover{border-color:#9333EA;color:#9333EA}
.time-slot.selected{border-color:#9333EA;background:#9333EA;color:#fff;font-weight:700}
.time-slot.full{background:var(--bg-page);color:var(--border);cursor:not-allowed;text-decoration:line-through}
/* 패키지 선택 */
.pkg-select-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:12px;margin-bottom:18px}
.pkg-select-card{border:2px solid var(--border);border-radius:var(--radius-md);padding:16px 14px;text-align:center;cursor:pointer;transition:var(--transition)}
.pkg-select-card:hover{border-color:#9333EA}
.pkg-select-card.selected{border-color:#9333EA;background:#F3E8FF}
.pkg-select-name{font-size:14px;font-weight:800;color:var(--text-main);margin-bottom:4px}
.pkg-select-price{font-size:15px;font-weight:800;color:#9333EA}
.reserve-textarea{width:100%;border:1px solid var(--border);border-radius:var(--radius-sm);padding:12px 14px;font-size:14px;min-height:100px;resize:vertical;outline:none;font-family:inherit;box-sizing:border-box}
.reserve-textarea:focus{border-color:#9333EA}
/* 요약 */
.reserve-summary{background:var(--bg-page);border-radius:var(--radius-md);padding:20px;display:flex;flex-direction:column;gap:12px}
.rs-row{display:flex;justify-content:space-between;font-size:14px}
.rs-row span:first-child{color:var(--text-muted)}
.rs-row span:last-child{color:var(--text-main);font-weight:600}
/* 하단 버튼 */
.reserve-nav{display:flex;justify-content:space-between;margin-top:24px}
.btn-prev{padding:12px 28px;border:1px solid var(--border);border-radius:var(--radius-sm);background:#fff;color:var(--text-sub);font-size:15px;font-weight:700;cursor:pointer}
.btn-next{padding:12px 32px;border:none;border-radius:var(--radius-sm);background:#9333EA;color:#fff;font-size:15px;font-weight:700;cursor:pointer;transition:var(--transition)}
.btn-next:hover{background:#6B21A8}
</style>

<div class="reserve-wrap">
  <h1 class="reserve-title">촬영 예약</h1>
  <div class="reserve-shop">하루필름 스튜디오 · 서울 중구 명동</div>

  <div class="step-bar">
    <div class="step-item done" id="si1"><div class="step-num">1</div><span class="step-label">반려동물 선택</span></div>
    <div class="step-item active" id="si2"><div class="step-num">2</div><span class="step-label">날짜 선택</span></div>
    <div class="step-item" id="si3"><div class="step-num">3</div><span class="step-label">시간 선택</span></div>
    <div class="step-item" id="si4"><div class="step-num">4</div><span class="step-label">패키지 선택</span></div>
  </div>

  <%-- Step 1 --%>
  <div class="step-section" id="step1">
    <div class="step-section-title">촬영할 반려동물을 선택하세요</div>
    <div class="pet-select-grid">
      <div class="pet-select-card selected" onclick="selectPet(this)">
        <img class="pet-select-thumb" src="https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=112&q=70&auto=format&fit=crop" alt="몽이" onerror="this.src='https://placehold.co/56x56/F3E8FF/9333EA?text=DOG'">
        <div><div class="pet-select-name">몽이</div><div class="pet-select-meta">골든 리트리버 · 4세</div></div>
      </div>
      <div class="pet-select-card" onclick="selectPet(this)">
        <img class="pet-select-thumb" src="https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=112&q=70&auto=format&fit=crop" alt="나비" onerror="this.src='https://placehold.co/56x56/F3E8FF/9333EA?text=CAT'">
        <div><div class="pet-select-name">나비</div><div class="pet-select-meta">페르시안 · 2세</div></div>
      </div>
    </div>
    <div class="reserve-nav"><span></span><button class="btn-next" onclick="goStep(2)">다음</button></div>
  </div>

  <%-- Step 2 --%>
  <div class="step-section on" id="step2">
    <div class="step-section-title">촬영 날짜를 선택하세요</div>
    <div class="cal-header">
      <button class="cal-nav-btn">‹</button>
      <strong style="font-size:16px;color:var(--text-main)">2025년 7월</strong>
      <button class="cal-nav-btn">›</button>
    </div>
    <div class="cal-grid">
      <div class="cal-day-head">일</div><div class="cal-day-head">월</div><div class="cal-day-head">화</div>
      <div class="cal-day-head">수</div><div class="cal-day-head">목</div><div class="cal-day-head">금</div><div class="cal-day-head">토</div>
      <div class="cal-day disabled">29</div><div class="cal-day disabled">30</div><div class="cal-day disabled">1</div>
      <div class="cal-day disabled">2</div><div class="cal-day disabled">3</div><div class="cal-day disabled">4</div><div class="cal-day disabled">5</div>
      <div class="cal-day today" onclick="selDate(this)">6</div><div class="cal-day" onclick="selDate(this)">7</div>
      <div class="cal-day" onclick="selDate(this)">8</div><div class="cal-day" onclick="selDate(this)">9</div>
      <div class="cal-day" onclick="selDate(this)">10</div><div class="cal-day" onclick="selDate(this)">11</div>
      <div class="cal-day disabled">12</div>
      <div class="cal-day disabled">13</div><div class="cal-day selected" onclick="selDate(this)">14</div>
      <div class="cal-day" onclick="selDate(this)">15</div><div class="cal-day" onclick="selDate(this)">16</div>
      <div class="cal-day" onclick="selDate(this)">17</div><div class="cal-day" onclick="selDate(this)">18</div>
      <div class="cal-day disabled">19</div>
    </div>
    <div class="reserve-nav">
      <button class="btn-prev" onclick="goStep(1)">이전</button>
      <button class="btn-next" onclick="goStep(3)">다음</button>
    </div>
  </div>

  <%-- Step 3 --%>
  <div class="step-section" id="step3">
    <div class="step-section-title">촬영 시간을 선택하세요</div>
    <p style="font-size:13px;color:var(--text-muted);margin-bottom:16px">2025년 7월 14일 (월) — 잔여 슬롯: 3개</p>
    <strong style="font-size:13px;color:var(--text-sub);display:block;margin-bottom:10px">오전</strong>
    <div class="time-slots" style="margin-bottom:18px">
      <div class="time-slot full">11:00<br><small>마감</small></div>
      <div class="time-slot" onclick="selTime(this)">11:30</div>
      <div class="time-slot" onclick="selTime(this)">12:00</div>
      <div class="time-slot" onclick="selTime(this)">12:30</div>
    </div>
    <strong style="font-size:13px;color:var(--text-sub);display:block;margin-bottom:10px">오후</strong>
    <div class="time-slots">
      <div class="time-slot selected" onclick="selTime(this)">14:00</div>
      <div class="time-slot" onclick="selTime(this)">15:00</div>
      <div class="time-slot full">16:00<br><small>마감</small></div>
      <div class="time-slot" onclick="selTime(this)">17:00</div>
    </div>
    <div class="reserve-nav">
      <button class="btn-prev" onclick="goStep(2)">이전</button>
      <button class="btn-next" onclick="goStep(4)">다음</button>
    </div>
  </div>

  <%-- Step 4 --%>
  <div class="step-section" id="step4">
    <div class="step-section-title">촬영 패키지를 선택하세요</div>
    <div class="pkg-select-grid">
      <div class="pkg-select-card ${empty param.pkg or param.pkg eq 'basic' ? 'selected' : ''}" onclick="selectPkg(this,'베이직 (30,000원)')">
        <div class="pkg-select-name">베이직</div>
        <div class="pkg-select-price">30,000원</div>
      </div>
      <div class="pkg-select-card ${param.pkg eq 'profile' ? 'selected' : ''}" onclick="selectPkg(this,'프로필 (55,000원)')">
        <div class="pkg-select-name">프로필</div>
        <div class="pkg-select-price">55,000원</div>
      </div>
      <div class="pkg-select-card ${param.pkg eq 'premium' ? 'selected' : ''}" onclick="selectPkg(this,'프리미엄 (90,000원)')">
        <div class="pkg-select-name">프리미엄</div>
        <div class="pkg-select-price">90,000원</div>
      </div>
    </div>
    <p style="font-size:13px;color:var(--text-muted);margin-bottom:12px">촬영 시 요청사항을 입력하세요 (선택사항)</p>
    <textarea class="reserve-textarea" placeholder="원하는 배경, 의상, 컨셉 등을 자유롭게 적어주세요.">밝고 화사한 분위기로, 자연스러운 표정 위주로 촬영해주세요!</textarea>
    <div style="margin-top:20px;margin-bottom:14px">
      <strong style="font-size:15px;color:var(--text-main)">예약 최종 확인</strong>
    </div>
    <div class="reserve-summary">
      <div class="rs-row"><span>사진관</span><span>하루필름 스튜디오</span></div>
      <div class="rs-row"><span>반려동물</span><span>몽이 (골든 리트리버 · 4세)</span></div>
      <div class="rs-row"><span>예약 일시</span><span>2025.07.14 (월) 오후 2:00</span></div>
      <div class="rs-row"><span>촬영 패키지</span><span id="rsPkg">베이직 (30,000원)</span></div>
    </div>
    <div class="reserve-nav">
      <button class="btn-prev" onclick="goStep(3)">이전</button>
      <button class="btn-next" onclick="completeReserve()">예약 완료</button>
    </div>
  </div>
</div>

<script>
var currentStep = 2;
function goStep(n) {
  document.getElementById('step'+currentStep).classList.remove('on');
  for(var i=1;i<=4;i++){
    var si = document.getElementById('si'+i);
    si.className = 'step-item';
    if(i < n) si.classList.add('done');
    else if(i === n) si.classList.add('active');
  }
  currentStep = n;
  document.getElementById('step'+n).classList.add('on');
  window.scrollTo(0,0);
}
function selectPet(el){document.querySelectorAll('.pet-select-card').forEach(c=>c.classList.remove('selected'));el.classList.add('selected');}
function selDate(el){document.querySelectorAll('.cal-day').forEach(d=>d.classList.remove('selected'));el.classList.add('selected');}
function selTime(el){document.querySelectorAll('.time-slot').forEach(t=>t.classList.remove('selected'));el.classList.add('selected');}
function selectPkg(el,label){document.querySelectorAll('.pkg-select-card').forEach(c=>c.classList.remove('selected'));el.classList.add('selected');document.getElementById('rsPkg').textContent=label;}
function completeReserve(){
  if(confirm('예약을 확정하시겠습니까?\n예약 확정 후 이메일로 안내드립니다.'))
    location.href='${contextPath}/studio/complete';
}
</script>
<%@ include file="/WEB-INF/views/common/footer.jsp" %>
