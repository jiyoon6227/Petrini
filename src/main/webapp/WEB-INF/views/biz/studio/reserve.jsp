<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath"  value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="애완동물 사진관" />
<c:set var="bizPage"      value="reserve" />
<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_studio.jsp" %>
<link href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.js"></script>
<style>
  .fc .fc-button-primary{background:#9333EA;border-color:#9333EA}
  .fc .fc-button-primary:hover,.fc .fc-button-primary:not(:disabled).fc-button-active{background:#6B21A8;border-color:#6B21A8}
  .fc .fc-today-button{background:#6B21A8;border-color:#6B21A8}
  .fc .fc-daygrid-day.fc-day-today,.fc .fc-timegrid-col.fc-day-today{background:rgba(147,51,234,.05)!important}
  .fc-timegrid-event{border-radius:6px!important;padding:2px 4px!important;font-size:12px!important}
  .biz-legend{display:flex;gap:14px;align-items:center;flex-wrap:wrap;margin-bottom:14px}
  .legend-dot{width:10px;height:10px;border-radius:50%;display:inline-block;margin-right:4px}
  .biz-modal-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,.4);z-index:9999;align-items:center;justify-content:center}
  .biz-modal-overlay.on{display:flex}
  .biz-modal{background:#fff;border-radius:12px;padding:28px;min-width:340px;max-width:460px;width:90%}
  .biz-modal h3{font-size:17px;font-weight:800;color:#1A1A2E;margin:0 0 18px}
  .biz-modal-row{display:flex;justify-content:space-between;font-size:14px;margin-bottom:10px}
  .biz-modal-row span:first-child{color:#888}
  .biz-modal-row span:last-child{font-weight:600;color:#1A1A2E}
  .biz-modal-actions{display:flex;gap:8px;margin-top:20px}
  .biz-modal-actions button{flex:1;padding:10px;border-radius:8px;font-size:14px;font-weight:700;cursor:pointer}
  .btn-confirm{border:none;background:#9333EA;color:#fff}
  .btn-cancel-biz{border:2px solid #E2E8E4;background:#fff;color:#555}
  .btn-close-modal{border:none;background:#F5F5F5;color:#555}
</style>
<main class="biz-main">
  <div class="biz-page-head">
    <h1 class="biz-page-title">예약 관리</h1>
    <p class="biz-page-desc">촬영 일정을 캘린더에서 확인하고 처리하세요.</p>
  </div>
  <div class="biz-card" style="padding:20px">
    <div class="biz-legend">
      <span><span class="legend-dot" style="background:#C4B5FD"></span>대기</span>
      <span><span class="legend-dot" style="background:#9333EA"></span>확정</span>
      <span><span class="legend-dot" style="background:#6B7280"></span>촬영완료</span>
      <span><span class="legend-dot" style="background:#E5E7EB"></span>취소</span>
    </div>
    <div id="calendar"></div>
  </div>
</main>

<div class="biz-modal-overlay" id="modalOverlay">
  <div class="biz-modal">
    <h3>예약 상세</h3>
    <div class="biz-modal-row"><span>고객명</span><span id="mName"></span></div>
    <div class="biz-modal-row"><span>반려동물</span><span id="mPet"></span></div>
    <div class="biz-modal-row"><span>촬영 패키지</span><span id="mPkg"></span></div>
    <div class="biz-modal-row"><span>예약 시간</span><span id="mTime"></span></div>
    <div class="biz-modal-row"><span>상태</span><span id="mStatus"></span></div>
    <div class="biz-modal-actions">
      <button class="btn-confirm" onclick="alert('예약이 확정되었습니다.')">확정</button>
      <button class="btn-cancel-biz" onclick="if(confirm('예약을 취소하시겠습니까?'))alert('취소되었습니다.')">취소</button>
      <button class="btn-close-modal" onclick="closeModal()">닫기</button>
    </div>
  </div>
</div>
<script>
function closeModal(){ document.getElementById('modalOverlay').classList.remove('on'); }
document.getElementById('modalOverlay').addEventListener('click', function(e){ if(e.target===this) closeModal(); });
var today = new Date();
function d(dayOff,h,m){ var dt=new Date(today); dt.setDate(today.getDate()+dayOff); dt.setHours(h,m,0); return dt.toISOString(); }
var events=[
  {title:'콩이 — 프리미엄',  start:d(0,10,0), end:d(0,12,0), color:'#9333EA', extendedProps:{name:'최유나',pet:'콩이 (비숑)',pkg:'프리미엄 패키지 (2시간)',status:'확정'}},
  {title:'나비 — 프로필',    start:d(0,13,0), end:d(0,14,0), color:'#C4B5FD', extendedProps:{name:'이서연',pet:'나비 (페르시안)',pkg:'프로필 패키지 (1시간)',status:'대기'}},
  {title:'루비 — 베이직',    start:d(0,15,0), end:d(0,15,30),color:'#9333EA', extendedProps:{name:'박지호',pet:'루비 (푸들)',pkg:'베이직 패키지 (30분)',status:'확정'}},
  {title:'몽이 — 프리미엄',  start:d(1,11,0), end:d(1,13,0), color:'#C4B5FD', extendedProps:{name:'김민준',pet:'몽이 (골든 리트리버)',pkg:'프리미엄 패키지 (2시간)',status:'대기'}},
  {title:'하루 — 프로필',    start:d(2,14,0), end:d(2,15,0), color:'#9333EA', extendedProps:{name:'정수빈',pet:'하루 (말티즈)',pkg:'프로필 패키지 (1시간)',status:'확정'}},
  {title:'두부 — 베이직',    start:d(3,10,30),end:d(3,11,0), color:'#6B7280', extendedProps:{name:'오다은',pet:'두부 (포메)',pkg:'베이직 패키지',status:'촬영완료'}},
  {title:'달이 — 프리미엄',  start:d(4,13,0), end:d(4,15,0), color:'#C4B5FD', extendedProps:{name:'한승우',pet:'달이 (사모예드)',pkg:'프리미엄 패키지 (2시간)',status:'대기'}},
  {title:'봄이 — 프로필',    start:d(-1,11,0),end:d(-1,12,0),color:'#6B7280', extendedProps:{name:'신지아',pet:'봄이 (비숑)',pkg:'프로필 패키지',status:'촬영완료'}},
];
document.addEventListener('DOMContentLoaded', function(){
  var cal = new FullCalendar.Calendar(document.getElementById('calendar'),{
    locale:'ko', initialView:'timeGridWeek',
    headerToolbar:{left:'prev,next today',center:'title',right:'timeGridWeek,timeGridDay'},
    buttonText:{today:'오늘',week:'주간',day:'일간'},
    slotMinTime:'10:00:00', slotMaxTime:'21:00:00', slotDuration:'00:30:00',
    allDaySlot:false, nowIndicator:true, height:680, events:events,
    eventClick:function(info){
      var p=info.event.extendedProps, s=info.event.start, e=info.event.end;
      var fmt=function(dt){return dt.getHours()+':'+(dt.getMinutes()<10?'0':'')+dt.getMinutes();};
      document.getElementById('mName').textContent=p.name;
      document.getElementById('mPet').textContent=p.pet;
      document.getElementById('mPkg').textContent=p.pkg;
      document.getElementById('mTime').textContent=fmt(s)+' ~ '+fmt(e);
      document.getElementById('mStatus').textContent=p.status;
      document.getElementById('modalOverlay').classList.add('on');
    }
  });
  cal.render();
});
</script>
<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>
