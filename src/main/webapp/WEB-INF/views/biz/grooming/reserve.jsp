<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath"  value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="애견미용실" />
<c:set var="bizPage"      value="reserve" />
<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_grooming.jsp" %>
<link href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.js"></script>
<style>
.fc-theme-standard .fc-scrollgrid{border-color:#E2E8E4}
.fc .fc-button-primary{background:#DB2777;border-color:#DB2777}
.fc .fc-button-primary:hover,.fc .fc-button-primary:not(:disabled).fc-button-active{background:#9D174D;border-color:#9D174D}
.fc .fc-today-button{background:#9D174D;border-color:#9D174D}
.fc .fc-col-header-cell-cushion,.fc .fc-timegrid-slot-label-cushion{color:#1A1A2E;font-size:13px}
.fc-timegrid-event{border-radius:6px!important;padding:2px 4px!important;font-size:12px!important}
.fc .fc-daygrid-day.fc-day-today,.fc .fc-timegrid-col.fc-day-today{background:rgba(219,39,119,.05)!important}
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
.btn-confirm{border:none;background:#DB2777;color:#fff}
.btn-cancel-biz{border:2px solid #E2E8E4;background:#fff;color:#555}
.btn-close-modal{border:none;background:#F5F5F5;color:#555}
</style>
<main class="biz-main">
  <div class="biz-page-head">
    <h1 class="biz-page-title">예약 관리</h1>
    <p class="biz-page-desc">클릭하면 예약 상세 및 처리를 할 수 있습니다.</p>
  </div>
  <div class="biz-card" style="padding:20px">
    <div class="biz-legend">
      <span><span class="legend-dot" style="background:#FCA5A5"></span>대기</span>
      <span><span class="legend-dot" style="background:#DB2777"></span>확정</span>
      <span><span class="legend-dot" style="background:#6B7280"></span>완료</span>
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
    <div class="biz-modal-row"><span>시술 메뉴</span><span id="mMenu"></span></div>
    <div class="biz-modal-row"><span>담당 스타일리스트</span><span id="mStaff"></span></div>
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
function d(dayOff, h, m){ var dt=new Date(today); dt.setDate(today.getDate()+dayOff); dt.setHours(h,m,0); return dt.toISOString(); }
function d2(dayOff, h, m){ var dt=new Date(today); dt.setDate(today.getDate()+dayOff); dt.setHours(h,m,0); return dt.toISOString(); }

var events = [
  {title:'코코 — 전체미용',     start:d(0,10,0),  end:d(0,11,30), color:'#DB2777', extendedProps:{name:'김예진',pet:'코코 (비숑 · 2세)',menu:'전체미용',staff:'박채원',status:'확정'}},
  {title:'두부 — 발톱정리',     start:d(0,13,0),  end:d(0,13,30), color:'#DB2777', extendedProps:{name:'이성민',pet:'두부 (포메 · 4세)',menu:'발톱 정리',staff:'김지수',status:'확정'}},
  {title:'망고 — 목욕+드라이',  start:d(0,15,0),  end:d(0,16,0),  color:'#FCA5A5', extendedProps:{name:'최아린',pet:'망고 (말티푸 · 1세)',menu:'목욕+드라이',staff:'박채원',status:'대기'}},
  {title:'하루 — 위생미용',     start:d(1,10,30), end:d(1,11,0),  color:'#DB2777', extendedProps:{name:'정우찬',pet:'하루 (시츄 · 3세)',menu:'위생미용',staff:'이도윤',status:'확정'}},
  {title:'보리 — 가위컷',      start:d(1,14,0),  end:d(1,16,0),  color:'#FCA5A5', extendedProps:{name:'한지우',pet:'보리 (골든 · 5세)',menu:'가위컷 스타일링',staff:'박채원',status:'대기'}},
  {title:'딸기 — 전체미용',    start:d(2,11,0),  end:d(2,12,30), color:'#DB2777', extendedProps:{name:'오세영',pet:'딸기 (말티즈 · 2세)',menu:'전체미용',staff:'김지수',status:'확정'}},
  {title:'몽이 — 목욕',        start:d(3,10,0),  end:d(3,11,0),  color:'#6B7280', extendedProps:{name:'박소현',pet:'몽이 (비숑 · 3세)',menu:'기본 목욕+드라이',staff:'이도윤',status:'완료'}},
  {title:'루비 — 부분염색',    start:d(4,13,0),  end:d(4,14,0),  color:'#FCA5A5', extendedProps:{name:'김도윤',pet:'루비 (푸들 · 2세)',menu:'부분 염색',staff:'박채원',status:'대기'}},
  {title:'콩이 — 위생미용',    start:d(-1,10,0), end:d(-1,10,30),color:'#6B7280', extendedProps:{name:'이나연',pet:'콩이 (비숑 · 1세)',menu:'위생미용',staff:'이도윤',status:'완료'}},
];

document.addEventListener('DOMContentLoaded', function(){
  var cal = new FullCalendar.Calendar(document.getElementById('calendar'), {
    locale: 'ko',
    initialView: 'timeGridWeek',
    headerToolbar: { left:'prev,next today', center:'title', right:'timeGridWeek,timeGridDay' },
    buttonText: { today:'오늘', week:'주간', day:'일간' },
    slotMinTime: '09:00:00',
    slotMaxTime: '21:00:00',
    slotDuration: '00:30:00',
    allDaySlot: false,
    nowIndicator: true,
    height: 680,
    events: events,
    eventClick: function(info){
      var p = info.event.extendedProps;
      var s = info.event.start;
      var e = info.event.end;
      var fmt = function(dt){ return dt.getHours()+':'+(dt.getMinutes()<10?'0':'')+dt.getMinutes(); };
      document.getElementById('mName').textContent   = p.name;
      document.getElementById('mPet').textContent    = p.pet;
      document.getElementById('mMenu').textContent   = p.menu;
      document.getElementById('mStaff').textContent  = p.staff;
      document.getElementById('mTime').textContent   = fmt(s)+' ~ '+fmt(e);
      document.getElementById('mStatus').textContent = p.status;
      document.getElementById('modalOverlay').classList.add('on');
    }
  });
  cal.render();
});
</script>
<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>
