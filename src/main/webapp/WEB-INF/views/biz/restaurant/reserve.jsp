<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath"  value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="반려동물 동반 요식업" />
<c:set var="bizPage"      value="reserve" />
<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_restaurant.jsp" %>
<link href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.js"></script>
<style>
.fc .fc-button-primary{background:#EA580C;border-color:#EA580C}
.fc .fc-button-primary:hover,.fc .fc-button-primary:not(:disabled).fc-button-active{background:#C2410C;border-color:#C2410C}
.fc .fc-today-button{background:#C2410C;border-color:#C2410C}
.fc .fc-daygrid-day.fc-day-today,.fc .fc-timegrid-col.fc-day-today{background:rgba(234,88,12,.05)!important}
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
.btn-confirm{border:none;background:#EA580C;color:#fff}
.btn-cancel-biz{border:2px solid #E2E8E4;background:#fff;color:#555}
.btn-close-modal{border:none;background:#F5F5F5;color:#555}
</style>
<main class="biz-main">
  <div class="biz-page-head">
    <h1 class="biz-page-title">예약 관리</h1>
    <p class="biz-page-desc">테이블 예약 현황을 시간대별로 확인하고 처리하세요.</p>
  </div>
  <div class="biz-card" style="padding:20px">
    <div class="biz-legend">
      <span><span class="legend-dot" style="background:#FED7AA"></span>대기</span>
      <span><span class="legend-dot" style="background:#EA580C"></span>확정</span>
      <span><span class="legend-dot" style="background:#6B7280"></span>이용완료</span>
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
    <div class="biz-modal-row"><span>테이블</span><span id="mTable"></span></div>
    <div class="biz-modal-row"><span>인원</span><span id="mGuest"></span></div>
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
  {title:'김예진 — A1 (2명)',  start:d(0,12,0), end:d(0,13,30),color:'#EA580C', extendedProps:{name:'김예진',pet:'코코 (비숑)',table:'A1 (창가)',guest:'2명',status:'확정'}},
  {title:'이성민 — B2 (4명)',  start:d(0,13,0), end:d(0,14,30),color:'#FED7AA', extendedProps:{name:'이성민',pet:'두부 (포메)',table:'B2 (실내)',guest:'4명',status:'대기'}},
  {title:'박지훈 — A2 (2명)',  start:d(0,18,0), end:d(0,19,30),color:'#EA580C', extendedProps:{name:'박지훈',pet:'망고 (말티푸)',table:'A2 (테라스)',guest:'2명',status:'확정'}},
  {title:'최유나 — C1 (6명)',  start:d(0,19,0), end:d(0,21,0), color:'#FED7AA', extendedProps:{name:'최유나',pet:'몽이 (골든)',table:'C1 (프라이빗)',guest:'6명',status:'대기'}},
  {title:'정수빈 — A1 (2명)',  start:d(1,12,30),end:d(1,14,0), color:'#EA580C', extendedProps:{name:'정수빈',pet:'하루 (시츄)',table:'A1 (창가)',guest:'2명',status:'확정'}},
  {title:'한지우 — B1 (3명)',  start:d(1,18,30),end:d(1,20,0), color:'#FED7AA', extendedProps:{name:'한지우',pet:'보리 (골든)',table:'B1 (실내)',guest:'3명',status:'대기'}},
  {title:'오세영 — A2 (2명)',  start:d(2,19,0), end:d(2,20,30),color:'#EA580C', extendedProps:{name:'오세영',pet:'달이 (사모예드)',table:'A2 (테라스)',guest:'2명',status:'확정'}},
  {title:'신다은 — C1 (4명)',  start:d(-1,13,0),end:d(-1,14,30),color:'#6B7280',extendedProps:{name:'신다은',pet:'봄이 (비숑)',table:'C1 (프라이빗)',guest:'4명',status:'이용완료'}},
];
document.addEventListener('DOMContentLoaded', function(){
  var cal = new FullCalendar.Calendar(document.getElementById('calendar'),{
    locale:'ko', initialView:'timeGridWeek',
    headerToolbar:{left:'prev,next today',center:'title',right:'timeGridWeek,timeGridDay'},
    buttonText:{today:'오늘',week:'주간',day:'일간'},
    slotMinTime:'11:00:00', slotMaxTime:'22:00:00', slotDuration:'00:30:00',
    allDaySlot:false, nowIndicator:true, height:680, events:events,
    eventClick:function(info){
      var p=info.event.extendedProps, s=info.event.start, e=info.event.end;
      var fmt=function(dt){return dt.getHours()+':'+(dt.getMinutes()<10?'0':'')+dt.getMinutes();};
      document.getElementById('mName').textContent=p.name;
      document.getElementById('mPet').textContent=p.pet;
      document.getElementById('mTable').textContent=p.table;
      document.getElementById('mGuest').textContent=p.guest;
      document.getElementById('mTime').textContent=fmt(s)+' ~ '+fmt(e);
      document.getElementById('mStatus').textContent=p.status;
      document.getElementById('modalOverlay').classList.add('on');
    }
  });
  cal.render();
});
</script>
<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>
