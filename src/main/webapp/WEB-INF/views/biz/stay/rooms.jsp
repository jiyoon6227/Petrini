<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="반려동물 숙소" />
<c:set var="bizPage"      value="rooms" />

<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_stay.jsp" %>

<style>
  .room-table-head{display:flex;align-items:center;justify-content:space-between;padding:0 20px}
  .room-form-actions{display:flex;justify-content:center;gap:10px;margin-top:22px}
  .room-form-actions .biz-btn-primary{min-width:180px}
  .price-cell{text-align:right;font-variant-numeric:tabular-nums}
  .room-status{display:inline-block;font-size:11px;font-weight:700;padding:2px 8px;border-radius:12px;margin-left:6px}
  .room-status.approve{background:#ECFDF5;color:#15803D}
  .room-status.hold{background:#FFFBEB;color:#B45309}
  .room-status.closed{background:#F3F4F6;color:#6B7280}
  .room-actions{display:flex;flex-wrap:wrap;gap:6px}
</style>

<main class="biz-main">
  <div class="biz-page-head">
    <h1 class="biz-page-title">객실 관리</h1>
    <p class="biz-page-desc">객실 타입·가격을 등록하고 관리하세요.</p>
  </div>
  <c:if test="${not empty errorMsg}">
    <div style="margin:0 0 12px;padding:12px 16px;background:#FEF2F2;color:#B91C1C;border-radius:8px;font-size:14px;font-weight:600">${errorMsg}</div>
  </c:if>

  <%-- ═══ 객실 목록 ═══ --%>
  <div class="biz-card" style="margin-bottom:16px">
    <div class="room-table-head">
      <div class="biz-card-head" style="padding:20px 0 12px">
        <span>객실목록</span><small>총 ${fn:length(roomList)}실</small>
      </div>
      <button type="button" class="biz-btn-primary" onclick="openForm('add')">+ 객실 등록</button>
    </div>
    <table class="biz-table">
      <thead>
        <tr>
          <th>객실명</th>
          <th>1박 요금</th>
          <th>정원</th>
          <th>반려동물 제한</th>
          <th>상태</th>
          <th>관리</th>
        </tr>
      </thead>
      <tbody>
        <c:choose>
          <c:when test="${empty roomList}">
            <tr><td colspan="6" style="text-align:center;color:#999;padding:24px 0">등록된 객실이 없습니다.</td></tr>
          </c:when>
          <c:otherwise>
            <c:forEach var="room" items="${roomList}">
              <c:set var="roomStatus" value="${empty room.statusCd ? 'APPROVE' : room.statusCd}" />
              <c:if test="${roomStatus eq 'DELETED'}"><c:set var="roomStatus" value="CLOSED" /></c:if>
              <tr>
                <td>${room.name}</td>
                <td class="price-cell"><fmt:formatNumber value="${room.pricePerNight}" pattern="#,###"/>원</td>
                <td>${room.capacity > 0 ? room.capacity : '-'}명</td>
                <td>${room.petLimit > 0 ? room.petLimit : '-'}마리</td>
                <td>
                  <c:choose>
                    <c:when test="${roomStatus eq 'HOLD'}"><span class="room-status hold">운영중지</span></c:when>
                    <c:when test="${roomStatus eq 'CLOSED'}"><span class="room-status closed">운영종료</span></c:when>
                    <c:otherwise><span class="room-status approve">운영중</span></c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <div class="room-actions">
                    <c:if test="${roomStatus ne 'CLOSED'}">
                      <button type="button" class="biz-btn"
                          data-id="${room.roomId}"
                          data-name="${room.name}"
                          data-price="${room.pricePerNight}"
                          data-capacity="${room.capacity}"
                          data-petlimit="${room.petLimit}"
                          onclick="openForm('edit', this)">수정</button>
                    </c:if>
                    <c:if test="${roomStatus eq 'APPROVE'}">
                      <button type="button" class="biz-btn"
                          onclick="changeRoomStatus(${room.roomId}, 'HOLD', '운영중지하면 다시 운영할 때까지 예약이 불가합니다. 진행할까요?')">운영중지</button>
                      <button type="button" class="biz-btn danger"
                          onclick="changeRoomStatus(${room.roomId}, 'CLOSED', '운영종료하면 유저에게 더 이상 보이지 않습니다. 진행할까요?')">운영종료</button>
                    </c:if>
                    <c:if test="${roomStatus eq 'HOLD'}">
                      <button type="button" class="biz-btn-primary"
                          onclick="changeRoomStatus(${room.roomId}, 'APPROVE', '다시 운영중으로 바꿀까요?')">운영재개</button>
                      <button type="button" class="biz-btn danger"
                          onclick="changeRoomStatus(${room.roomId}, 'CLOSED', '운영종료하면 유저에게 더 이상 보이지 않습니다. 진행할까요?')">운영종료</button>
                    </c:if>
                  </div>
                </td>
              </tr>
            </c:forEach>
          </c:otherwise>
        </c:choose>
      </tbody>
    </table>
  </div>

  <%-- ═══ 등록/수정 폼 ═══ --%>
  <div class="biz-card" id="formCard" style="display:none">
    <div class="biz-card-head"><span id="formTitle">객실 등록</span></div>
    <form id="roomForm" action="${contextPath}/biz/stay/rooms" method="post"
          style="padding:20px;max-width:640px">

      <!--HYJ 26.08.05-->
      <input type="hidden" name="_csrf" value="${_csrf}">

      <input type="hidden" id="rRoomId" name="roomId" value="">

      <div class="biz-form-fields">
        <div class="biz-form-row">
          <label>객실이름<span class="req">*</span></label>
          <input type="text" id="rName" name="name" placeholder="객실 이름을 입력하세요" required>
        </div>
        <div class="biz-form-row">
          <label>1박 요금<span class="req">*</span></label>
          <input type="number" id="rPrice" name="pricePerNight" placeholder="숫자만 입력 (예: 80000)" min="0" required>
        </div>
        <div class="biz-form-row">
          <label>정원</label>
          <input type="number" id="rCapacity" name="capacity" placeholder="숙박 가능 인원" min="0">
        </div>
        <div class="biz-form-row">
          <label>반려동물 수 제한</label>
          <input type="number" id="rPetLimit" name="petLimit" placeholder="동반 가능한 반려동물 수" min="0">
        </div>
      </div>

      <div class="room-form-actions">
        <button type="button" class="biz-btn-ghost" onclick="closeForm()">취소</button>
        <button type="submit" class="biz-btn-primary" id="submitBtn">객실 등록</button>
      </div>
    </form>
  </div>

  <form id="statusForm" action="${contextPath}/biz/stay/rooms/status" method="post" style="display:none">
    <input type="hidden" name="_csrf" value="${_csrf}">
    <input type="hidden" id="statusRoomId" name="roomId" value="">
    <input type="hidden" id="statusCd" name="statusCd" value="">
  </form>
</main>

<%-- 저장 완료 토스트 --%>
<c:if test="${not empty msg}">
  <div class="biz-toast" id="saveToast">
    <svg viewBox="0 0 24 24" fill="none" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
    <span>${msg}</span>
  </div>
</c:if>

<script>
  function openForm(mode, btn) {
    document.getElementById('roomForm').reset();
    document.getElementById('rRoomId').value = '';

    if (mode === 'edit' && btn) {
      document.getElementById('rRoomId').value     = btn.dataset.id;
      document.getElementById('rName').value       = btn.dataset.name;
      document.getElementById('rPrice').value      = btn.dataset.price;
      document.getElementById('rCapacity').value   = btn.dataset.capacity || '';
      document.getElementById('rPetLimit').value   = btn.dataset.petlimit || '';
      document.getElementById('formTitle').textContent = '객실 수정';
      document.getElementById('submitBtn').textContent = '수정완료';
    } else {
      document.getElementById('formTitle').textContent = '객실 등록';
      document.getElementById('submitBtn').textContent = '객실 등록';
    }

    document.getElementById('formCard').style.display = 'block';
    document.getElementById('formCard').scrollIntoView({ behavior: 'smooth', block: 'start' });
  }

  function closeForm() {
    document.getElementById('formCard').style.display = 'none';
  }

  function changeRoomStatus(roomId, statusCd, message) {
    if (!confirm(message)) return;
    document.getElementById('statusRoomId').value = roomId;
    document.getElementById('statusCd').value = statusCd;
    document.getElementById('statusForm').submit();
  }

  window.addEventListener('DOMContentLoaded', function() {
    var t = document.getElementById('saveToast');
    if (t) { t.classList.add('on'); setTimeout(function(){ t.classList.remove('on'); }, 2500); }
  });
</script>

<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>
