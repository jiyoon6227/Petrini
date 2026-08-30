<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="stay" />
<%@ include file="/WEB-INF/views/common/header.jsp" %>
<style>
  .pay-wrap{max-width:720px;margin:32px auto 80px;padding:0 20px}
  .pay-back{display:inline-flex;align-items:center;gap:6px;font-size:13px;color:var(--text-muted);text-decoration:none;margin-bottom:18px;transition:var(--transition)}
  .pay-back:hover{color:var(--primary)}
  .pay-back svg{width:14px;height:14px;stroke:currentColor;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}
  .pay-title{font-size:22px;font-weight:800;color:var(--text-main);margin-bottom:6px}
  .pay-sub{font-size:14px;color:var(--text-muted);margin-bottom:28px}
  .pay-section{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);padding:22px;margin-bottom:16px}
  .pay-section h3{font-size:15px;font-weight:800;color:var(--text-main);margin:0 0 16px;padding-bottom:12px;border-bottom:1px solid var(--border);display:flex;align-items:center;gap:8px}
  .pay-section h3 svg{width:16px;height:16px;stroke:var(--primary);fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}
  .pay-row{display:flex;justify-content:space-between;font-size:14px;color:var(--text-sub);margin-bottom:10px}
  .pay-row:last-child{margin-bottom:0}
  .pay-row span:last-child{color:var(--text-main);font-weight:600;text-align:right}
  .pay-total-box{background:var(--bg-page);border-radius:var(--radius-sm);padding:18px;margin-top:14px}
  .pay-total-row{display:flex;justify-content:space-between;font-size:18px;font-weight:800;color:var(--text-main)}
  .pay-total-row span:last-child{color:var(--primary-dark)}
  .btn-pay{width:100%;padding:16px;border:none;border-radius:var(--radius-sm);background:var(--primary);color:#fff;font-size:17px;font-weight:800;cursor:pointer;margin-top:16px;transition:var(--transition)}
  .btn-pay:hover{background:var(--primary-dark)}
  .btn-pay:disabled{background:var(--border);cursor:not-allowed}
  .agree-row{display:flex;align-items:center;gap:8px;font-size:13px;color:var(--text-sub);margin-top:14px}
  .agree-row input{accent-color:var(--primary);width:16px;height:16px}
  /* 2026/07/27 장우철 — 결제수단 선택 UI */
  .pay-type-list{display:flex;flex-direction:column;gap:10px;margin-bottom:16px}
  .pay-type-item{display:flex;align-items:flex-start;gap:10px;padding:14px 16px;border:2px solid var(--border);border-radius:var(--radius-sm);cursor:pointer;transition:var(--transition);background:#fff}
  .pay-type-item:has(input:checked){border-color:var(--primary);background:var(--primary-light)}
  .pay-type-item input{margin-top:3px;accent-color:var(--primary);width:18px;height:18px;flex-shrink:0}
  .pay-type-item .pay-type-text{display:flex;flex-direction:column;gap:4px}
  .pay-type-item .pay-type-text strong{font-size:14px;color:var(--text-main)}
  .pay-type-item .pay-type-text span{font-size:12px;color:var(--text-muted);line-height:1.4}
  .pay-panel{display:none;margin-top:4px;padding-top:16px;border-top:1px dashed var(--border)}
  .pay-panel.active{display:block}
  .pay-card-preview{border:1px solid #BBF7D0;background:#F0FDF4;border-radius:var(--radius-sm);padding:16px}
  .pay-card-preview .label{font-size:12px;font-weight:700;color:#166534;margin-bottom:6px}
  .pay-card-preview .num{font-size:16px;font-weight:800;color:var(--text-main)}
  .pay-card-preview .hint{font-size:12px;color:var(--text-muted);margin-top:8px}
  /* 2026/08/11 장우철 — 등록카드 2장 이상 선택 */
  .pay-card-list{display:flex;flex-direction:column;gap:8px;margin:10px 0}
  .pay-card-option{display:flex;align-items:center;gap:10px;padding:12px 14px;border:1.5px solid #BBF7D0;border-radius:var(--radius-sm);cursor:pointer;background:#fff;margin:0}
  .pay-card-option:has(input:checked){border-color:var(--primary);background:var(--primary-light)}
  .pay-card-option input{accent-color:var(--primary);width:16px;height:16px;flex-shrink:0}
  .pay-card-option-text{font-size:14px;font-weight:700;color:var(--text-main)}
</style>

<div class="pay-wrap">
  <a href="${contextPath}/stay/reserve?id=${reservation.targetId}&roomId=${reservation.roomId}" class="pay-back">
    <svg viewBox="0 0 24 24"><path d="M19 12H5"/><polyline points="12 19 5 12 12 5"/></svg>
    예약 정보로 돌아가기
  </a>

  <h1 class="pay-title">결제</h1>
  <p class="pay-sub">예약 내용을 확인하고 결제를 진행하세요.</p>

  <%-- 예약 요약 --%>
  <div class="pay-section">
    <h3>
      <svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
      예약 정보
    </h3>
    <div class="pay-row"><span>예약번호</span><span>${reservation.resvNo}</span></div>
    <div class="pay-row"><span>숙소</span><span>${reservation.stayName}</span></div>
    <div class="pay-row"><span>객실</span><span>${reservation.serviceName}</span></div>
    <div class="pay-row"><span>이용 기간</span>
      <span>
        <fmt:formatDate value="${reservation.checkinDate}" pattern="yyyy.MM.dd"/> ~
        <fmt:formatDate value="${reservation.checkoutDate}" pattern="MM.dd"/>
        · ${reservation.nightCnt}박
      </span>
    </div>
    <div class="pay-row"><span>반려동물</span><span>${reservation.petName}</span></div>
  </div>

  <%-- 결제 수단 — 2026/07/27 장우철: 등록카드 / 계좌이체 선택 UI --%>
  <div class="pay-section" id="tossSection">
    <h3>
      <svg viewBox="0 0 24 24"><rect x="1" y="4" width="22" height="16" rx="2" ry="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
      결제 수단
    </h3>
    <div class="pay-type-list">
      <label class="pay-type-item">
        <input type="checkbox" name="payType" id="payTypeCard" value="CARD">
        <span class="pay-type-text">
          <strong>등록 카드로 결제</strong>
          <span>마이페이지에 등록한 카드로 간편결제합니다.</span>
        </span>
      </label>
      <label class="pay-type-item">
        <input type="checkbox" name="payType" id="payTypeTransfer" value="TRANSFER" checked>
        <span class="pay-type-text">
          <strong>계좌이체 · 기타 결제</strong>
          <span>토스 결제창에서 계좌이체·카드 등 수단을 선택합니다.</span>
        </span>
      </label>
    </div>
    <div id="panelCard" class="pay-panel">
      <%-- 2026/08/11 장우철 — 등록카드 목록에서 결제 카드 선택 --%>
      <div class="pay-card-preview" id="payCardPreviewRegistered" style="display:none">
        <div class="label">결제할 카드를 선택하세요</div>
        <div class="pay-card-list" id="payCardList"></div>
        <div class="hint">선택한 등록 카드로 바로 결제됩니다. (결제창 없음)</div>
      </div>
      <div class="pay-card-preview" id="payCardPreviewEmpty" style="display:none;border-color:var(--border);background:var(--bg-page)">
        <div class="label" style="color:var(--text-muted)">등록된 카드 없음</div>
        <div class="hint" style="margin-top:0">회원정보에서 카드를 먼저 등록해 주세요.</div>
      </div>
    </div>
    <div id="panelTransfer" class="pay-panel active">
      <div id="payment-method"></div>
      <div id="agreement"></div>
    </div>
  </div>

  <%-- 결제 금액 --%>
  <div class="pay-section">
    <h3>
      <svg viewBox="0 0 24 24"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 000 7h5a3.5 3.5 0 010 7H6"/></svg>
      결제 금액
    </h3>
    <div class="pay-row">
      <span>숙박 요금</span>
      <span><fmt:formatNumber value="${reservation.totalAmount}" pattern="#,###"/>원</span>
    </div>

    <%-- 지윤 26.08.07: 쿠폰 사용 --%>
    <div style="background:#FFFBEB;border:1px solid #FDE68A;border-radius:8px;padding:14px 16px;margin:12px 0">
      <div style="font-size:13px;font-weight:700;color:#92400E;margin-bottom:8px">보유 쿠폰</div>
      <select id="couponSelect" onchange="calcFinalAmount()"
              style="width:100%;border:1px solid #FDE68A;border-radius:6px;padding:8px 12px;font-size:14px;outline:none;font-family:inherit">
        <option value="0" data-type="" data-value="0" data-max="0" data-min="0">쿠폰 선택 안 함</option>
        <c:forEach var="c" items="${usableCoupons}">
          <option value="${c.memberCouponId}" data-type="${c.couponType}" data-value="${c.discountValue}" data-max="${c.maxDiscountAmt}" data-min="${c.minOrderAmt}">
            ${c.couponName}
            <c:if test="${c.couponType == 'RATE'}">
              (${c.discountValue}% 할인, 최대 <fmt:formatNumber value="${c.maxDiscountAmt}" pattern="#,###"/>원)
            </c:if>
            <c:if test="${c.couponType == 'FIXED'}"> (<fmt:formatNumber value="${c.discountValue}" pattern="#,###"/>원 할인)</c:if>
          </option>
        </c:forEach>
      </select>
      <c:if test="${empty usableCoupons}">
        <small style="color:var(--text-muted)">이 숙소에 사용 가능한 쿠폰이 없습니다.</small>
      </c:if>
    </div>

    <%-- 포인트 사용 --%>
      <div style="background:#F0FDF4;border:1px solid #BBF7D0;border-radius:8px;padding:14px 16px;margin:12px 0">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
          <span style="font-size:13px;font-weight:700;color:#166534">보유 포인트</span>
          <span style="font-size:14px;font-weight:800;color:#16A34A"><fmt:formatNumber value="${memberPoint}" pattern="#,###"/>P</span>
        </div>
        <div style="display:flex;gap:8px;align-items:center">
          <input type="number" id="pointInput" min="0" max="${memberPoint > reservation.totalAmount ? reservation.totalAmount : memberPoint}"
                 value="0" style="flex:1;border:1px solid #BBF7D0;border-radius:6px;padding:8px 12px;font-size:14px;outline:none"
                 oninput="calcFinalAmount()">
          <button type="button" onclick="useAllPoints()" style="flex-shrink:0;padding:8px 14px;border:1px solid #16A34A;border-radius:6px;background:#fff;color:#16A34A;font-size:13px;font-weight:700;cursor:pointer">전액 사용</button>
        </div>
        <div id="pointMsg" style="font-size:12px;color:#888;margin-top:6px"></div>
      </div>

    <div style="display:none"><span id="pointDiscountRow"></span></div>

    <div class="pay-total-box">
        <%-- 지윤 26.08.07: 쿠폰 할인 표시 행 --%>
        <div class="pay-row" id="couponDiscountDisplay" style="display:none;margin-bottom:10px">
          <span>쿠폰 할인</span>
          <span id="couponDiscountLabel" style="color:#D97706">-0원</span>
        </div>
        <div class="pay-row" id="pointDiscountDisplay" style="display:none;margin-bottom:10px">
          <span>포인트 사용</span>
          <span id="pointDiscountLabel" style="color:#16A34A">0P</span>
        </div>
      <div class="pay-total-row">
        <span>총 결제금액</span>
        <span id="finalAmountLabel"><fmt:formatNumber value="${reservation.totalAmount}" pattern="#,###"/>원</span>
      </div>
    </div>
    <div class="agree-row">
      <input type="checkbox" id="agreePay" checked onchange="document.getElementById('btnPayFinal').disabled=!this.checked">
      <label for="agreePay">예약 내용을 확인했으며 결제에 동의합니다.</label>
    </div>
    <button id="btnPayFinal" class="btn-pay" onclick="requestPayment()">
      <fmt:formatNumber value="${reservation.totalAmount}" pattern="#,###"/>원 결제하기
    </button>
  </div>
</div>

<script src="https://js.tosspayments.com/v2/standard"></script>
<script src="${contextPath}/resources/js/billing-card.js"></script>
<script>
  var totalAmount = ${reservation.totalAmount};
  // 2026/07/27 장우철 — 보유 포인트(실잔액). 사용 상한만 0 이상·보유분 이내
  var memberPoint = ${memberPoint != null ? memberPoint : 0};
  var clientKey = "${tossApiKey}";
  var customerKey = "petcare_user_${memberInfo.memberId}";
  var resvId = ${reservation.resvId};
  var resvNo = "${reservation.resvNo}";
  var contextPath = "${contextPath}";
  var usedPoint = 0;
  // 지윤 26.08.07: 쿠폰 상태
  var couponDiscount = 0;
  var couponMemberCouponId = 0;

  var tossPayments = TossPayments(clientKey);
  var widgets = tossPayments.widgets({ customerKey: customerKey });
  // 2026/07/27 장우철 — 등록카드 목록 Ajax
  var hasRegisteredCard = false;
  var selectedBillingCardId = null;

  (async function() {
    await widgets.setAmount({ currency: "KRW", value: totalAmount });
    await widgets.renderPaymentMethods({ selector: "#payment-method", variantKey: "DEFAULT" });
    await widgets.renderAgreement({ selector: "#agreement" });
  })();

  /* 2026/07/27 장우철 — 결제수단 택1 + 등록카드 Ajax */
  (function () {
    var card = document.getElementById('payTypeCard');
    var transfer = document.getElementById('payTypeTransfer');
    var panelCard = document.getElementById('panelCard');
    var panelTransfer = document.getElementById('panelTransfer');
    var previewOk = document.getElementById('payCardPreviewRegistered');
    var previewEmpty = document.getElementById('payCardPreviewEmpty');
    var listEl = document.getElementById('payCardList');

    function syncPanels() {
      var useCard = card.checked;
      panelCard.classList.toggle('active', useCard);
      panelTransfer.classList.toggle('active', !useCard);
      if (useCard) {
        previewOk.style.display = hasRegisteredCard ? 'block' : 'none';
        previewEmpty.style.display = hasRegisteredCard ? 'none' : 'block';
      }
    }

    // 2026/08/11 장우철 — 등록카드 라디오 목록 렌더
    function renderCardList(cards) {
      listEl.innerHTML = '';
      cards.forEach(function (c, i) {
        var opt = document.createElement('label');
        opt.className = 'pay-card-option';
        var radio = document.createElement('input');
        radio.type = 'radio';
        radio.name = 'billingCardPick';
        radio.value = c.billingCardId;
        if (i === 0) radio.checked = true;
        radio.addEventListener('change', function () {
          if (radio.checked) selectedBillingCardId = c.billingCardId;
        });
        var text = document.createElement('span');
        text.className = 'pay-card-option-text';
        text.textContent = c.label || ('카드 #' + c.billingCardId);
        opt.appendChild(radio);
        opt.appendChild(text);
        listEl.appendChild(opt);
      });
      selectedBillingCardId = cards[0].billingCardId;
    }

    async function refreshCards() {
      try {
        var data = await PetcareBilling.loadCards();
        if (data.ok && data.cards && data.cards.length > 0) {
          hasRegisteredCard = true;
          renderCardList(data.cards);
        } else {
          hasRegisteredCard = false;
          selectedBillingCardId = null;
          listEl.innerHTML = '';
        }
      } catch (e) {
        hasRegisteredCard = false;
        selectedBillingCardId = null;
        listEl.innerHTML = '';
      }
      syncPanels();
    }

    card.addEventListener('change', function () {
      if (card.checked) transfer.checked = false;
      else if (!transfer.checked) transfer.checked = true;
      syncPanels();
    });
    transfer.addEventListener('change', function () {
      if (transfer.checked) card.checked = false;
      else if (!card.checked) card.checked = true;
      syncPanels();
    });
    refreshCards();
  })();

  // 지윤 26.08.07: 선택된 쿠폰으로 할인 계산 (store/order.jsp와 동일 패턴)
  function calcCouponDiscount() {
    var couponSel = document.getElementById('couponSelect');
    var opt = couponSel.options[couponSel.selectedIndex];
    var couponType = opt.dataset.type;
    var couponValue = parseInt(opt.dataset.value) || 0;
    var couponMax = parseInt(opt.dataset.max) || 0;
    var minOrderAmt = parseInt(opt.dataset.min) || 0;

    couponMemberCouponId = parseInt(couponSel.value) || 0;
    couponDiscount = 0;

    if (couponType) {
      if (totalAmount < minOrderAmt) {
        alert('최소 예약금액 ' + minOrderAmt.toLocaleString() + '원 이상부터 사용 가능한 쿠폰입니다.');
        couponSel.value = '0';
        couponMemberCouponId = 0;
      } else if (couponType === 'RATE') {
        var rawDiscount = Math.floor(totalAmount * couponValue / 100);
        couponDiscount = couponMax > 0 ? Math.min(rawDiscount, couponMax) : rawDiscount;
      } else if (couponType === 'FIXED') {
        couponDiscount = couponValue;
      }
    }
    if (couponDiscount > totalAmount) couponDiscount = totalAmount;

    var discountDisplay = document.getElementById('couponDiscountDisplay');
    if (discountDisplay) {
      if (couponDiscount > 0) {
        discountDisplay.style.display = 'flex';
        document.getElementById('couponDiscountLabel').textContent = '-' + couponDiscount.toLocaleString() + '원';
      } else {
        discountDisplay.style.display = 'none';
      }
    }
  }

  function useAllPoints() {
    // 2026/07/27 장우철 — 전액 사용도 보유분·결제액 이내
    // 지윤 26.08.07 — 쿠폰 할인 반영한 금액 기준으로 상한 계산
    var held = Math.max(0, memberPoint || 0);
    var payableAfterCoupon = totalAmount - couponDiscount;
    var maxUsable = Math.min(held, payableAfterCoupon);
    document.getElementById('pointInput').value = maxUsable;
    calcFinalAmount();
  }

  function calcFinalAmount() {
    // 지윤 26.08.07: 쿠폰 먼저 계산 -> 그 결과 금액 기준으로 포인트 계산
    calcCouponDiscount();

    var input = document.getElementById('pointInput');
    var val = parseInt(input.value) || 0;
    var held = Math.max(0, memberPoint || 0);
    var payableAfterCoupon = totalAmount - couponDiscount;
    var maxUsable = Math.min(held, payableAfterCoupon);

    if (val < 0) val = 0;
    if (val > maxUsable) val = maxUsable;
    input.value = val;
    input.max = maxUsable;

    usedPoint = val;
    var finalAmount = payableAfterCoupon - usedPoint;

    var discountDisplay = document.getElementById('pointDiscountDisplay');
    if (discountDisplay) {
      if (usedPoint > 0) {
        discountDisplay.style.display = 'flex';
        document.getElementById('pointDiscountLabel').textContent = '-' + usedPoint.toLocaleString() + 'P';
      } else {
        discountDisplay.style.display = 'none';
      }
    }

    document.getElementById('finalAmountLabel').textContent = finalAmount.toLocaleString() + '원';
    var btn = document.getElementById('btnPayFinal');

    if (finalAmount === 0) {
      btn.textContent = '포인트/쿠폰으로 결제하기';
      document.getElementById('tossSection').style.display = 'none';
    } else {
      btn.textContent = finalAmount.toLocaleString() + '원 결제하기';
      document.getElementById('tossSection').style.display = 'block';
      widgets.setAmount({ currency: "KRW", value: finalAmount });
    }

    var msgEl = document.getElementById('pointMsg');
    if (msgEl) {
      if (usedPoint > 0) {
        msgEl.textContent = usedPoint.toLocaleString() + 'P 사용 → 실결제 ' + finalAmount.toLocaleString() + '원';
        msgEl.style.color = '#16A34A';
      } else {
        msgEl.textContent = '';
      }
    }
  }

  async function requestPayment() {
    // 지윤 26.08.07: 쿠폰 할인까지 반영한 최종 결제 금액
    var payableAfterCoupon = totalAmount - couponDiscount;
    var finalAmount = payableAfterCoupon - usedPoint;

    // 전액 포인트/쿠폰 결제 — Toss 없이 서버로 직접 요청
    if (finalAmount === 0) {
      location.href = contextPath + '/stay/payment/point-only?resvId=' + resvId
        + '&usedPoint=' + usedPoint + '&couponMemberCouponId=' + couponMemberCouponId;
      return;
    }

    // 2026/07/27 장우철 — 등록카드 Ajax 빌링 승인
    if (document.getElementById('payTypeCard').checked) {
      if (!hasRegisteredCard || !selectedBillingCardId) {
        alert('등록된 카드가 없습니다. 회원정보에서 카드를 등록해 주세요.');
        return;
      }
      if (!document.getElementById('agreePay').checked) {
        alert('결제에 동의해 주세요.');
        return;
      }
      try {
        var body = 'billingCardId=' + encodeURIComponent(selectedBillingCardId)
          + '&resvId=' + encodeURIComponent(resvId)
          + '&usedPoint=' + encodeURIComponent(usedPoint)
          + '&couponMemberCouponId=' + encodeURIComponent(couponMemberCouponId);
        //HYJ 26.08.05
        var res = await csrfFetch(contextPath + '/stay/payment/billing-card', {
          method: 'POST',
          credentials: 'same-origin',
          headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
          body: body
        });
        var data = await res.json();
        if (!data.ok) {
          alert(data.message || '등록카드 결제에 실패했습니다.');
          return;
        }
        location.href = contextPath + data.redirectUrl;
      } catch (e) {
        console.error(e);
        alert('등록카드 결제 중 오류가 발생했습니다.');
      }
      return;
    }

    try {
      // 포인트·쿠폰 사용 정보를 orderId에 포함시켜 서버에서 파싱
      var orderId = 'stay-' + resvId + '-' + usedPoint + '-' + couponMemberCouponId + '-' + Date.now();
      await widgets.requestPayment({
        orderId: orderId,
        orderName: "${reservation.stayName} - ${reservation.serviceName} ${reservation.nightCnt}박",
        successUrl: window.location.origin + contextPath + "/stay/payment/success",
        failUrl: window.location.origin + contextPath + "/stay/payment/fail"
      });
    } catch (error) {
      if (error.code === "USER_CANCEL") {
        // 사용자가 결제창을 닫음
      } else {
        alert("결제 요청 중 오류가 발생했습니다: " + error.message);
      }
    }
  }
</script>
<%@ include file="/WEB-INF/views/common/footer.jsp" %>
