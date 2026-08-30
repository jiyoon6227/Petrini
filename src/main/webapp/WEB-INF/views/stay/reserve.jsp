<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="stay" />
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
  .res-wrap{max-width:740px;margin:32px auto 80px;padding:0 20px}
  .res-title{font-size:22px;font-weight:800;color:var(--text-main);margin-bottom:6px}
  .res-sub{font-size:14px;color:var(--text-muted);margin-bottom:28px}
  .res-place-card{display:flex;gap:14px;align-items:center;background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);padding:16px 18px;margin-bottom:22px}
  .res-place-thumb{width:80px;height:80px;border-radius:var(--radius-sm);object-fit:cover;flex-shrink:0}
  .res-place-name{font-size:15px;font-weight:800;color:var(--text-main);margin-bottom:4px}
  .res-place-meta{font-size:13px;color:var(--text-muted)}
  .res-section{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);padding:22px;margin-bottom:16px}
  .res-section h3{font-size:15px;font-weight:800;color:var(--text-main);margin:0 0 16px;padding-bottom:12px;border-bottom:1px solid var(--border);display:flex;align-items:center;gap:8px}
  .res-section h3 svg{width:16px;height:16px;stroke:var(--primary);fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}
  .res-grid{display:grid;grid-template-columns:1fr 1fr;gap:14px}
  .res-group{display:flex;flex-direction:column;gap:5px}
  .res-group.full{grid-column:1/-1}
  .res-group label{font-size:13px;font-weight:600;color:var(--text-sub)}
  .res-group label .req{color:var(--accent);margin-left:2px}
  .res-group input,.res-group select,.res-group textarea{border:1px solid var(--border);border-radius:var(--radius-sm);padding:10px 13px;font-size:14px;color:var(--text-main);outline:none;font-family:inherit;width:100%;box-sizing:border-box;transition:border-color .2s}
  .res-group input:focus,.res-group select:focus,.res-group textarea:focus{border-color:var(--primary)}
  .res-group textarea{min-height:80px;resize:vertical;line-height:1.6}
  .pet-pick-grid{display:grid;grid-template-columns:1fr 1fr;gap:10px}
  .pet-pick-card{display:flex;align-items:center;gap:12px;border:2px solid var(--border);border-radius:var(--radius-sm);padding:12px 14px;cursor:pointer;transition:.2s}
  .pet-pick-card:hover{border-color:var(--primary)}
  .pet-pick-card.selected{border-color:var(--primary);background:var(--primary-light)}
  .pet-pick-card input[type="radio"],
  .pet-pick-card input[type="checkbox"]{display:none}
  .pet-limit-hint{font-size:13px;color:var(--text-muted);margin:0 0 12px;line-height:1.5}
  .pet-pick-name{font-size:14px;font-weight:700;color:var(--text-main)}
  .pet-pick-meta{font-size:12px;color:var(--text-muted)}
  .price-summary{background:var(--bg-page);border-radius:var(--radius-sm);padding:18px}
  .ps-row{display:flex;justify-content:space-between;font-size:14px;color:var(--text-sub);margin-bottom:10px}
  .ps-row.total{font-size:18px;font-weight:800;color:var(--text-main);padding-top:12px;border-top:1px solid var(--border);margin-top:6px}
  .ps-row.total span:last-child{color:var(--primary-dark)}
  .btn-pay-submit{width:100%;padding:16px;border:none;border-radius:var(--radius-sm);background:var(--primary);color:#fff;font-size:17px;font-weight:800;cursor:pointer;margin-top:16px;transition:.15s}
  .btn-pay-submit:hover{background:var(--primary-dark)}
  .btn-pay-submit:disabled{background:var(--border);cursor:not-allowed}

  /* 예약 확인 모달 */
  .confirm-overlay{display:none;position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,.45);z-index:9999;justify-content:center;align-items:center}
  .confirm-overlay.show{display:flex}
  .confirm-box{background:#fff;border-radius:16px;padding:28px 24px;max-width:400px;width:90%;box-shadow:0 20px 60px rgba(0,0,0,.2);text-align:center}
  .confirm-box .icon{width:56px;height:56px;border-radius:50%;background:#FEF3C7;display:flex;align-items:center;justify-content:center;margin:0 auto 16px}
  .confirm-box .icon svg{width:28px;height:28px;stroke:#D97706;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}
  .confirm-box h3{font-size:18px;font-weight:800;color:var(--text-main);margin:0 0 10px}
  .confirm-box p{font-size:14px;color:var(--text-sub);line-height:1.7;margin:0 0 8px}
  .confirm-box .timer-notice{background:#FEF2F2;border-radius:8px;padding:10px 14px;font-size:13px;font-weight:700;color:#DC2626;margin:12px 0 20px;line-height:1.5}
  .confirm-box .btn-group{display:flex;gap:10px}
  .confirm-box .btn-cancel{flex:1;padding:12px;border:1px solid var(--border);border-radius:8px;background:#fff;color:var(--text-sub);font-size:14px;font-weight:600;cursor:pointer}
  .confirm-box .btn-cancel:hover{background:var(--bg-page)}
  .confirm-box .btn-confirm{flex:1;padding:12px;border:none;border-radius:8px;background:var(--primary);color:#fff;font-size:14px;font-weight:800;cursor:pointer}
  .confirm-box .btn-confirm:hover{background:var(--primary-dark)}
</style>

<div class="res-wrap">
  <h1 class="res-title">예약 / 결제</h1>
  <p class="res-sub">예약 정보를 확인하고 결제를 진행하세요.</p>

  <%-- 에러 메시지 (서버 검증 실패 시) --%>
  <c:if test="${not empty errorMsg}">
    <div style="background:#FEF2F2;border:1px solid #FECACA;color:#DC2626;
                padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:14px;font-weight:600">
      ${errorMsg}
    </div>
  </c:if>

  <%-- 숙소 요약 --%>
  <div class="res-place-card">
    <c:choose>
      <c:when test="${not empty imgList}">
        <img class="res-place-thumb" src="${contextPath}/upload/${imgList[0].fileUrl}" alt="${stay.name}">
      </c:when>
      <c:otherwise>
        <img class="res-place-thumb" src="https://placehold.co/80x80/E0F2FE/0284C7?text=숙소" alt="숙소">
      </c:otherwise>
    </c:choose>
    <div>
      <div class="res-place-name">${stay.name}</div>
      <div class="res-place-meta">${stay.addr}</div>
    </div>
  </div>

  <form id="reserveForm" action="${contextPath}/stay/reserve" method="post">
    <!--HYJ 26.08.05-->
    <input type="hidden" name="_csrf" value="${_csrf}">
    
    <input type="hidden" name="stayId" value="${stay.stayId}">

    <%-- 객실 + 날짜 --%>
    <div class="res-section">
      <h3>
        <svg viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
        객실 및 일정
      </h3>
      <div class="res-grid">
        <div class="res-group full">
          <label>객실 선택 <span class="req">*</span></label>
          <select name="roomId" id="roomSelect" required onchange="calcPrice()">
            <option value="">객실을 선택하세요</option>
            <c:forEach var="room" items="${stay.rooms}">
              <option value="${room.roomId}"
                      data-price="${room.pricePerNight}"
                      data-petlimit="${room.petLimit}"
                      ${room.roomId == roomId ? 'selected' : ''}>
                ${room.name} — <fmt:formatNumber value="${room.pricePerNight}" pattern="#,###"/>원/박
                (반려동물 최대 ${room.petLimit}마리)
              </option>
            </c:forEach>
          </select>
        </div>
        <div class="res-group">
          <label>체크인 <span class="req">*</span></label>
          <input type="date" name="checkinDate" id="checkinDate" required onchange="calcPrice()"
                 value="${param.checkinDate}">
        </div>
        <div class="res-group">
          <label>체크아웃 <span class="req">*</span></label>
          <input type="date" name="checkoutDate" id="checkoutDate" required onchange="calcPrice()"
                 value="${param.checkoutDate}">
        </div>
      </div>
      <%-- 가용성 체크 결과 --%>
      <div id="availabilityMsg"></div>
    </div>

    <%-- 반려동물 선택 — 2026/08/11 장우철: PET_LIMIT에 따라 단건/다건 --%>
    <div class="res-section">
      <h3>
        <svg viewBox="0 0 24 24"><circle cx="11" cy="4" r="2"/><circle cx="18" cy="8" r="2"/><circle cx="20" cy="16" r="2"/><circle cx="4" cy="8" r="2"/><path d="M12 10c-1.5 2-3 3.5-3 5a3 3 0 006 0c0-1.5-1.5-3-3-5z"/></svg>
        함께 가는 반려동물
      </h3>
      <p class="pet-limit-hint" id="petLimitHint">객실을 선택하면 동반 가능 마리수가 표시됩니다.</p>
      <input type="hidden" name="petCnt" id="petCntInput" value="1">
      <c:choose>
        <c:when test="${not empty petList}">
          <div class="pet-pick-grid" id="petPickGrid">
            <c:forEach var="pet" items="${petList}" varStatus="st">
              <label class="pet-pick-card ${st.index == 0 ? 'selected' : ''}">
                <input type="checkbox" name="petIds" value="${pet.petId}" class="pet-check"
                       ${st.index == 0 ? 'checked' : ''} onchange="onPetToggle(this)">
                <div>
                  <div class="pet-pick-name">${pet.petName}</div>
                  <div class="pet-pick-meta">${pet.breed} · ${pet.age}세</div>
                </div>
              </label>
            </c:forEach>
          </div>
        </c:when>
        <c:otherwise>
          <p style="color:var(--text-muted);font-size:14px">
            등록된 반려동물이 없습니다.
            <a href="${contextPath}/mypage/pets" style="color:var(--primary)">반려동물 등록</a> 후 이용해주세요.
          </p>
        </c:otherwise>
      </c:choose>
    </div>

    <%-- 예약자 정보 --%>
    <div class="res-section">
      <h3>
        <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
        예약자 정보
      </h3>
      <div class="res-grid">
        <div class="res-group"><label>이름</label><input type="text" value="${memberInfo.memberName}" readonly></div>
        <div class="res-group"><label>연락처</label><input type="tel" value="${memberInfo.phone}" readonly></div>
        <div class="res-group full"><label>요청사항</label><textarea name="requestMemo" placeholder="숙소에 요청하실 사항을 입력하세요."></textarea></div>
      </div>
    </div>

    <%-- 결제 금액 --%>
    <input type="hidden" name="nightCnt" id="nightCntInput" value="0">
    <input type="hidden" name="totalAmount" id="totalAmountInput" value="0">

    <div class="res-section">
      <h3>
        <svg viewBox="0 0 24 24"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 000 7h5a3.5 3.5 0 010 7H6"/></svg>
        결제 금액
      </h3>
      <div class="price-summary">
        <div class="ps-row"><span>숙박 요금</span><span id="priceLabel">객실과 날짜를 선택하세요</span></div>
        <div class="ps-row" id="petFeeRow" style="display:none"><span>반려동물 추가 비용</span><span id="petFeeLabel">-</span></div>
        <div class="ps-row total"><span>총 결제금액</span><span id="totalLabel">-</span></div>
      </div>
      <button type="button" class="btn-pay-submit" id="submitBtn" disabled onclick="showConfirmModal()">예약 신청하기</button>
    </div>
  </form>

  <%-- 예약 확인 모달 --%>
  <div class="confirm-overlay" id="confirmModal">
    <div class="confirm-box">
      <div class="icon">
        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
      </div>
      <h3>예약을 진행하시겠습니까?</h3>
      <p>예약 신청 후 결제 페이지로 이동합니다.</p>
      <div class="timer-notice">
        ⏱ 예약 후 <strong>15분 이내</strong>에 결제를 완료해야 합니다.<br>
        미결제 시 예약이 자동 취소됩니다.
      </div>
      <p style="font-size:13px;color:#888;margin:0 0 16px" id="confirmSummary"></p>
      <div class="btn-group">
        <button class="btn-cancel" onclick="closeConfirmModal()">취소</button>
        <button class="btn-confirm" onclick="submitReservation()">예약하기</button>
      </div>
    </div>
  </div>
</div>

<script>
  var contextPath = '${contextPath}';
  var hasPet = ${not empty petList};
  var petFeeAmt = ${stay.petFee != null ? stay.petFee : 0};

  var today = new Date().toISOString().split('T')[0];
  document.getElementById('checkinDate').min = today;
  document.getElementById('checkoutDate').min = today;

  function getPetLimit() {
    var roomSel = document.getElementById('roomSelect');
    if (!roomSel.value) return 1;
    var lim = Number(roomSel.options[roomSel.selectedIndex].dataset.petlimit);
    return lim > 0 ? lim : 1;
  }

  function getSelectedPetCount() {
    return document.querySelectorAll('.pet-check:checked').length;
  }

  function syncPetUi() {
    var limit = getPetLimit();
    var hint = document.getElementById('petLimitHint');
    if (hint) {
      hint.textContent = '이 객실은 반려동물 최대 ' + limit + '마리까지 가능합니다.'
          + (limit >= 2 ? ' (추가 마리당 ' + Number(petFeeAmt).toLocaleString() + '원 × 박수)' : '');
    }
    var checked = document.querySelectorAll('.pet-check:checked');
    if (checked.length > limit) {
      for (var i = limit; i < checked.length; i++) {
        checked[i].checked = false;
        checked[i].closest('.pet-pick-card').classList.remove('selected');
      }
    }
    document.querySelectorAll('.pet-pick-card').forEach(function(card) {
      var input = card.querySelector('.pet-check');
      if (input && input.checked) card.classList.add('selected');
      else card.classList.remove('selected');
    });
    document.getElementById('petCntInput').value = String(Math.max(1, getSelectedPetCount()) || 1);
  }

  function onPetToggle(el) {
    var limit = getPetLimit();
    var checked = document.querySelectorAll('.pet-check:checked');
    if (limit <= 1) {
      document.querySelectorAll('.pet-check').forEach(function(c) {
        if (c !== el) {
          c.checked = false;
          c.closest('.pet-pick-card').classList.remove('selected');
        }
      });
      el.checked = true;
    } else if (checked.length > limit) {
      el.checked = false;
      alert('이 객실은 최대 ' + limit + '마리까지 선택할 수 있습니다.');
    }
    syncPetUi();
    calcPrice();
  }

  function calcPrice() {
    var roomSel = document.getElementById('roomSelect');
    var ci = document.getElementById('checkinDate').value;
    var co = document.getElementById('checkoutDate').value;
    var availMsg = document.getElementById('availabilityMsg');
    availMsg.innerHTML = '';
    syncPetUi();

    if (ci) {
      var nextDay = new Date(ci);
      nextDay.setDate(nextDay.getDate() + 1);
      document.getElementById('checkoutDate').min = nextDay.toISOString().split('T')[0];
      if (co && co <= ci) {
        document.getElementById('checkoutDate').value = '';
        co = '';
      }
    }

    var petFeeRow = document.getElementById('petFeeRow');
    if (!roomSel.value || !ci || !co) {
      document.getElementById('priceLabel').textContent = '객실과 날짜를 선택하세요';
      document.getElementById('totalLabel').textContent = '-';
      if (petFeeRow) petFeeRow.style.display = 'none';
      document.getElementById('submitBtn').disabled = true;
      document.getElementById('submitBtn').textContent = '예약 신청하기';
      return;
    }

    var nights = Math.round((new Date(co) - new Date(ci)) / 86400000);
    if (nights <= 0) {
      document.getElementById('priceLabel').textContent = '체크아웃은 체크인 이후여야 합니다';
      document.getElementById('totalLabel').textContent = '-';
      document.getElementById('submitBtn').disabled = true;
      return;
    }

    var price = Number(roomSel.options[roomSel.selectedIndex].dataset.price);
    var petCnt = getSelectedPetCount();
    if (petCnt < 1) petCnt = 0;
    var roomTotal = price * nights;
    var extraPets = Math.max(0, petCnt - 1);
    var petExtra = extraPets * Number(petFeeAmt) * nights;
    var total = roomTotal + petExtra;

    document.getElementById('nightCntInput').value = nights;
    document.getElementById('totalAmountInput').value = total;
    document.getElementById('petCntInput').value = String(Math.max(1, petCnt));
    document.getElementById('priceLabel').textContent =
        price.toLocaleString() + '원 × ' + nights + '박';
    if (petFeeRow) {
      if (petExtra > 0) {
        petFeeRow.style.display = '';
        document.getElementById('petFeeLabel').textContent =
            Number(petFeeAmt).toLocaleString() + '원 × 추가 ' + extraPets + '마리 × ' + nights + '박';
      } else {
        petFeeRow.style.display = 'none';
      }
    }
    document.getElementById('totalLabel').textContent = total.toLocaleString() + '원';

    document.getElementById('submitBtn').disabled = true;
    document.getElementById('submitBtn').textContent = '예약 가능 여부 확인 중...';
    availMsg.innerHTML = '<div style="padding:8px 12px;border-radius:6px;font-size:12px;font-weight:600;'
        + 'background:var(--bg-page);border:1px solid var(--border);color:var(--text-muted)">확인 중...</div>';

    var xhr = new XMLHttpRequest();
    xhr.open('GET', contextPath + '/stay/checkAvailability'
        + '?roomId=' + roomSel.value
        + '&checkinDate=' + ci
        + '&checkoutDate=' + co);
    xhr.onload = function() {
      var res = JSON.parse(xhr.responseText);
      if (res.available) {
        availMsg.innerHTML = '<div style="padding:8px 12px;border-radius:6px;font-size:12px;font-weight:600;'
            + 'background:#F0FDF4;border:1px solid #BBF7D0;color:#16A34A;margin-top:10px">'
            + '✓ 예약 가능한 날짜입니다.</div>';
        if (!hasPet) {
          availMsg.innerHTML += '<div style="padding:8px 12px;border-radius:6px;font-size:12px;font-weight:600;'
              + 'background:#FEF2F2;border:1px solid #FECACA;color:#DC2626;margin-top:8px">'
              + '✕ 반려동물을 등록한 후 예약할 수 있습니다.</div>';
          document.getElementById('submitBtn').disabled = true;
          document.getElementById('submitBtn').textContent = '반려동물 등록 필요';
        } else if (getSelectedPetCount() < 1) {
          document.getElementById('submitBtn').disabled = true;
          document.getElementById('submitBtn').textContent = '반려동물 선택 필요';
        } else {
          document.getElementById('submitBtn').disabled = false;
          document.getElementById('submitBtn').textContent =
              total.toLocaleString() + '원 예약 신청하기';
        }
      } else {
        availMsg.innerHTML = '<div style="padding:8px 12px;border-radius:6px;font-size:12px;font-weight:600;'
            + 'background:#FEF2F2;border:1px solid #FECACA;color:#DC2626;margin-top:10px">'
            + '✕ ' + res.message + '</div>';
        document.getElementById('submitBtn').disabled = true;
        document.getElementById('submitBtn').textContent = '예약 불가';
      }
    };
    xhr.onerror = function() {
      availMsg.innerHTML = '';
      document.getElementById('submitBtn').disabled = false;
      document.getElementById('submitBtn').textContent =
          total.toLocaleString() + '원 예약 신청하기';
    };
    xhr.send();
  }

  document.getElementById('roomSelect').addEventListener('change', function() {
    syncPetUi();
    calcPrice();
  });

  window.addEventListener('DOMContentLoaded', function() {
    syncPetUi();
    var roomSel = document.getElementById('roomSelect');
    var ci = document.getElementById('checkinDate').value;
    if (roomSel.value && ci) {
      calcPrice();
    }
  });

  function showConfirmModal() {
    if (getSelectedPetCount() < 1) {
      alert('반려동물을 선택해 주세요.\n등록된 반려동물이 없으면 마이페이지에서 등록 후 이용해 주세요.');
      return;
    }
    var limit = getPetLimit();
    if (getSelectedPetCount() > limit) {
      alert('이 객실은 최대 ' + limit + '마리까지 가능합니다.');
      return;
    }

    var roomSel = document.getElementById('roomSelect');
    var roomName = roomSel.options[roomSel.selectedIndex].text.split(' — ')[0];
    var ci = document.getElementById('checkinDate').value;
    var co = document.getElementById('checkoutDate').value;
    var nights = Math.round((new Date(co) - new Date(ci)) / 86400000);
    var total = document.getElementById('totalLabel').textContent;
    var petCnt = getSelectedPetCount();

    document.getElementById('confirmSummary').textContent =
        roomName + ' · ' + ci + ' ~ ' + co + ' (' + nights + '박) · 반려동물 ' + petCnt + '마리 · ' + total;
    document.getElementById('confirmModal').classList.add('show');
  }

  function closeConfirmModal() {
    document.getElementById('confirmModal').classList.remove('show');
  }

  function submitReservation() {
    closeConfirmModal();
    document.getElementById('reserveForm').submit();
  }

  document.getElementById('confirmModal').addEventListener('click', function(e) {
    if (e.target === this) closeConfirmModal();
  });
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
