<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="mypage" />
<c:set var="sec" value="orders" />

<%@ include file="/WEB-INF/views/common/header.jsp" %>
<link rel="stylesheet" href="${contextPath}/resources/css/mypage.css">

<%-- 지윤 26.07.20 수정: 밋밋했던 rd-card 스타일 -> 섹션별 라벨/아이콘/여백 보강한 od- 전용 스타일로 리디자인
     결제내역/배송지/배송정보까지 자세히 보여주는 읽기전용 페이지. 리뷰작성은 여기 없음 (목록에서 모달로 처리) --%>
<style>
.od-head { display:flex; align-items:center; justify-content:space-between; margin-bottom:20px; }
.od-head-status { display:flex; align-items:center; gap:12px; }
.od-section { background:#fff; border:1px solid #E2E8E4; border-radius:14px; padding:22px 24px; margin-bottom:16px; }
.od-section-title { font-size:14px; font-weight:800; color:var(--text-main); margin:0 0 14px; display:flex; align-items:center; gap:6px; }
.od-row { display:flex; justify-content:space-between; gap:16px; padding:10px 0; border-bottom:1px solid #F5F6F4; font-size:14px; }
.od-row:last-child { border-bottom:none; }
.od-row .label { color:var(--text-muted); flex-shrink:0; min-width:90px; }
.od-row .value { color:var(--text-main); font-weight:600; text-align:right; }
.od-row.total .value { color:var(--primary); font-size:17px; font-weight:800; }
.od-item { display:flex; align-items:center; gap:14px; padding:14px 0; border-bottom:1px solid #F5F6F4; }
.od-item:last-child { border-bottom:none; }
.od-item img { width:60px; height:60px; border-radius:10px; object-fit:cover; flex-shrink:0; background:#F5F6F4; }
.od-item .name { font-weight:700; font-size:14px; color:var(--text-main); }
.od-item .meta { font-size:13px; color:var(--text-muted); margin-top:4px; }
.od-item .price { margin-left:auto; font-weight:700; color:var(--text-main); }
.od-tracking { display:flex; align-items:center; gap:10px; background:var(--primary-light); border-radius:10px; padding:14px 16px; font-size:14px; margin-bottom:18px; }
.od-tracking b { color:var(--primary); }
.od-empty-tracking { color:var(--text-muted); font-size:13px; }
.od-stepper { display:flex; align-items:flex-start; padding-top:6px; }
.od-step { display:flex; flex-direction:column; align-items:center; width:25%; }
.od-step-dot { width:14px; height:14px; border-radius:50%; border:1.5px solid #D8DEDA; background:#fff; }
.od-step-dot.done { background:var(--primary); border-color:var(--primary); }
.od-step-dot.current { box-shadow:0 0 0 3px var(--primary-light); }
.od-step-label { font-size:13px; font-weight:600; margin:8px 0 2px; text-align:center; color:var(--text-muted); }
.od-step-label.done { color:var(--text-main); font-weight:700; }
.od-step-label.current { color:var(--primary); }
.od-step-time { font-size:11px; color:var(--text-muted); margin:0; text-align:center; }
.od-step-line { flex:1; height:1.5px; background:#E2E8E4; margin-top:7px; }
.od-step-line.done { background:var(--primary); }
</style>

<div class="mypage-wrap">
<%@ include file="/WEB-INF/views/mypage/sidebar.jsp" %>
<div class="mypage-content">

<div class="mp-section active">
  <div class="od-head">
    <div>
      <h2 class="mp-title" style="margin-bottom:4px">주문 상세</h2>
      <p class="mp-desc" style="margin:0">주문번호 <strong>#${order.orderNo}</strong> · ${order.orderDate}</p>
    </div>
  </div>

  <%-- 지윤 26.07.21 추가: 주문정보 섹션 - 주문번호/주문일자/주문자 한눈에 정리 --%>
  <%-- 지윤 26.07.30 수정: 주문처리상태는 사업자마다 다를 수 있어서 이 섹션에서 빼고, 사업자별 블록으로 이동 --%>
  <div class="od-section">
    <p class="od-section-title">📋 주문정보</p>
    <div class="od-row"><span class="label">주문번호</span><span class="value">#${order.orderNo}</span></div>
    <div class="od-row"><span class="label">주문일자</span><span class="value">${order.orderDate}</span></div>
    <div class="od-row"><span class="label">주문자</span><span class="value">${order.ordererName}</span></div>
  </div>

  <%-- 지윤 26.07.30 수정: 같은 결제로 쪼개진 사업자별 주문(orderGroup)을 각각 섹션으로 반복 렌더링.
       사업자마다 상태/배송정보/상품/소계(상품금액·배송비)가 따로 있고, 취소신청도 사업자 단위로 가능함 --%>
  <c:forEach var="o" items="${orderGroup}">
    <div class="od-section">
      <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:16px;">
        <p class="od-section-title" style="margin-bottom:0"><c:out value="${o.bizName}"/></p>
        <div style="display:flex;align-items:center;gap:10px">
          <%-- 2026/08/13 장우철 — #7 환불완료/부분환불 뱃지 --%>
          <%@ include file="/WEB-INF/views/mypage/orders-status-badge.jsp" %>
          <%-- 지윤 26.07.30 수정: 주문취소 버튼을 사업자 단위로 이동 (하단 공용 버튼 -> 여기로) --%>
          <%-- 2026/08/04 장우철 — 결제완료·배송준비 = 주문취소 (배송중부터는 환불) --%>
          <c:if test="${(o.orderStatus == 'PAID' || o.orderStatus == 'READY') && empty o.claimStatus}">
            <button type="button" class="btn-sm" style="background:#fff;border:1px solid #E2445C;color:#E2445C;" onclick="openCancelModal(${o.orderId})">주문취소</button>
          </c:if>
          <c:if test="${not empty o.trackingNo}">
            <a href="javascript:void(0)" onclick="trackDelivery(${o.orderId}, '${o.courierCode}', '${o.trackingNo}')"
               style="font-size:13px;color:var(--text-muted);text-decoration:none">📦배송조회 &gt;</a>
          </c:if>
        </div>
      </div>

      <c:if test="${not empty o.courierName}">
        <div class="od-tracking">
          <span><b>${o.courierName}</b></span>
          <span>송장번호 ${o.trackingNo}</span>
        </div>
      </c:if>

      <c:if test="${o.statusBadge != 'REFUND_DONE' && o.statusBadge != 'CANCEL' && o.statusBadge != 'CANCEL_REQUEST'}">
      <c:choose>
        <c:when test="${not empty o.deliveredAt}"><c:set var="curStep" value="4"/></c:when>
        <c:when test="${not empty o.shippingAt}"><c:set var="curStep" value="3"/></c:when>
        <c:when test="${not empty o.readyAt}"><c:set var="curStep" value="2"/></c:when>
        <c:otherwise><c:set var="curStep" value="1"/></c:otherwise>
      </c:choose>

      <div class="od-stepper">
        <div class="od-step">
          <div class="od-step-dot done"></div>
          <p class="od-step-label done">결제완료</p>
          <p class="od-step-time">${order.orderDate}</p>
        </div>
        <div class="od-step-line ${curStep >= 2 ? 'done' : ''}"></div>

        <div class="od-step">
          <div class="od-step-dot ${curStep >= 2 ? 'done' : ''} ${curStep == 2 ? 'current' : ''}"></div>
          <p class="od-step-label ${curStep >= 2 ? 'done' : ''} ${curStep == 2 ? 'current' : ''}">배송준비</p>
          <p class="od-step-time"><fmt:formatDate value="${o.readyAt}" pattern="yyyy.MM.dd HH:mm"/></p>
        </div>
        <div class="od-step-line ${curStep >= 3 ? 'done' : ''}"></div>

        <div class="od-step">
          <div class="od-step-dot ${curStep >= 3 ? 'done' : ''} ${curStep == 3 ? 'current' : ''}"></div>
          <p class="od-step-label ${curStep >= 3 ? 'done' : ''} ${curStep == 3 ? 'current' : ''}">배송중</p>
          <p class="od-step-time"><fmt:formatDate value="${o.shippingAt}" pattern="yyyy.MM.dd HH:mm"/></p>
        </div>
        <div class="od-step-line ${curStep >= 4 ? 'done' : ''}"></div>

        <div class="od-step">
          <div class="od-step-dot ${curStep >= 4 ? 'done' : ''}"></div>
          <p class="od-step-label ${curStep >= 4 ? 'done' : ''}">배송완료</p>
          <p class="od-step-time">${curStep < 4 ? '예정' : ''}<fmt:formatDate value="${o.deliveredAt}" pattern="yyyy.MM.dd HH:mm"/></p>
        </div>
      </div>
      </c:if>

      <div style="margin-top:16px;">
        <c:forEach var="it" items="${o.itemList}">
          <div class="od-item">
            <%-- 2026/08/18 장우철 — FILE_URL이 /upload/ 포함이어도 경로가 겹치지 않게 --%>
            <c:choose>
              <c:when test="${not empty it.thumbnailUrl}">
                <c:choose>
                  <c:when test="${fn:startsWith(it.thumbnailUrl, 'http')}">
                    <c:set var="detailThumbSrc" value="${it.thumbnailUrl}" />
                  </c:when>
                  <c:when test="${fn:startsWith(it.thumbnailUrl, '/')}">
                    <c:set var="detailThumbSrc" value="${contextPath}${it.thumbnailUrl}" />
                  </c:when>
                  <c:otherwise>
                    <c:set var="detailThumbSrc" value="${contextPath}/upload/${it.thumbnailUrl}" />
                  </c:otherwise>
                </c:choose>
                <img src="${detailThumbSrc}"
                     alt="${it.productName}" onerror="this.src='https://placehold.co/60x60/EAF7F2/2BAB82?text=IMG'">
              </c:when>
              <c:otherwise>
                <img src="https://placehold.co/60x60/EAF7F2/2BAB82?text=IMG" alt="${it.productName}">
              </c:otherwise>
            </c:choose>
            <div>
              <div class="name">${it.productName}</div>
              <div class="meta">
                수량 ${it.qty}개
                <c:if test="${not empty it.optionSize}">
                  · 옵션: <c:if test="${not empty it.optionColor && it.optionColor != '기본'}">${it.optionColor} / </c:if>${it.optionSize}
                </c:if>
                <c:if test="${it.returnStatusCd == 'REQUESTED'}"> · 환불신청중</c:if>
                <c:if test="${it.returnStatusCd == 'RETURNING'}"> · 환불진행중</c:if>
                <c:if test="${it.returnStatusCd == 'DONE'}"> · 환불완료</c:if>
              </div>
            </div>
            <span class="price"><fmt:formatNumber value="${it.totalPrice}" pattern="#,###"/>원</span>
          </div>
        </c:forEach>
      </div>

      <%-- 지윤 26.07.30 추가: 이 사업자 몫만의 소계 (장바구니/주문서와 동일한 방식) --%>
      <div class="od-row" style="margin-top:8px;"><span class="label">상품금액</span><span class="value"><fmt:formatNumber value="${o.totalAmount}" pattern="#,###"/>원</span></div>
      <div class="od-row"><span class="label">배송비</span><span class="value"><fmt:formatNumber value="${o.deliveryFee}" pattern="#,###"/>원</span></div>

      <%-- 지윤 26.07.30 수정: 취소신청 내역도 사업자 단위로 이동 --%>
      <c:if test="${not empty o.claimStatus}">
        <div class="od-row" style="border-top:1px dashed #F0AD4E;padding-top:12px;margin-top:8px;">
          <span class="label">취소상태</span>
          <span class="value">
            <c:choose>
              <c:when test="${o.claimStatus == 'PENDING'}">사업자 확인중</c:when>
              <c:when test="${o.claimStatus == 'DONE'}">취소완료 (환불 <fmt:formatNumber value="${o.refundAmount}" pattern="#,###"/>원)</c:when>
              <c:when test="${o.claimStatus == 'REJECTED'}">취소 반려됨</c:when>
            </c:choose>
          </span>
        </div>
        <div class="od-row"><span class="label">신청사유</span><span class="value">${o.cancelReason}</span></div>
      </c:if>
    </div>
  </c:forEach>

  <%-- 지윤 26.07.30 수정: 결제 내역은 사업자별 소계를 전부 합산한 "전체 결제 그룹" 기준으로 표시 --%>
  <div class="od-section">
    <p class="od-section-title">💳 결제 내역</p>
    <c:set var="couponOnlyAmt" value="${groupDiscountAmount - groupPointUsed}" />
    <div class="od-row"><span class="label">총 상품금액</span><span class="value"><fmt:formatNumber value="${groupTotalAmount}" pattern="#,###"/>원</span></div>
    <div class="od-row"><span class="label">총 배송비</span><span class="value"><fmt:formatNumber value="${groupDeliveryFee}" pattern="#,###"/>원</span></div>
    <div class="od-row"><span class="label">쿠폰사용</span><span class="value">${couponOnlyAmt > 0 ? '-' : ''}<fmt:formatNumber value="${couponOnlyAmt}" pattern="#,###"/>원</span></div>
    <div class="od-row"><span class="label">포인트사용</span><span class="value">${groupPointUsed > 0 ? '-' : ''}<fmt:formatNumber value="${groupPointUsed}" pattern="#,###"/>원</span></div>
    <div class="od-row"><span class="label">총 할인금액</span><span class="value">${groupDiscountAmount > 0 ? '-' : ''}<fmt:formatNumber value="${groupDiscountAmount}" pattern="#,###"/>원</span></div>
    <div class="od-row total"><span class="label">총 결제금액</span><span class="value"><fmt:formatNumber value="${groupPayAmount}" pattern="#,###"/>원</span></div>
  </div>

  <div class="od-section">
    <p class="od-section-title">🏠 배송지 정보</p>
    <div class="od-row"><span class="label">받는분</span><span class="value">${order.recvName}</span></div>
    <div class="od-row"><span class="label">연락처</span><span class="value">${order.recvPhone}</span></div>
    <div class="od-row"><span class="label">주소</span><span class="value">(${order.zipCode}) ${order.addr1} ${order.addr2}</span></div>
    <div class="od-row"><span class="label">배송메시지</span><span class="value">${empty order.deliveryMemo ? '-' : order.deliveryMemo}</span></div>
  </div>

  <div style="display:flex; justify-content:flex-end; align-items:center;">
    <button type="button" class="btn-sm" onclick="location.href='${contextPath}/mypage/orders'">← 목록으로</button>
  </div>
</div>

</div>
</div>

<%-- 지윤 26.07.22 추가: 취소사유 입력 모달 --%>
<%-- 지윤 26.07.30 수정: 사업자별로 취소 버튼이 여러 개일 수 있어서, orderId를 고정값이 아니라 openCancelModal()에서 그때그때 채워넣게 변경 --%>
<div id="cancelModal" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,.4); z-index:1000; align-items:center; justify-content:center;">
  <div style="background:#fff; border-radius:14px; padding:24px; width:360px;">
    <p style="font-weight:800; font-size:15px; margin:0 0 12px;">주문취소 신청</p>
    <p style="font-size:13px; color:var(--text-muted); margin:0 0 14px;">결제완료·배송준비 단계에서만 취소 가능합니다. (배송중부터는 환불 신청) 신청 후 사업자 확인을 거쳐 환불됩니다.</p>
    <form id="cancelForm" method="post" action="${contextPath}/mypage/orders/cancel">
      <!--HYJ 26.08.05-->
      <input type="hidden" name="_csrf" value="${_csrf}">
      
      <input type="hidden" id="cancelOrderId" name="orderId" value="">
      <textarea name="reason" required placeholder="취소 사유를 입력해주세요" style="width:100%; height:80px; border:1px solid #E2E8E4; border-radius:8px; padding:10px; font-size:13px; resize:none; box-sizing:border-box;"></textarea>
      <div style="display:flex; gap:8px; margin-top:14px;">
        <button type="button" class="btn-sm" style="flex:1;" onclick="closeCancelModal()">닫기</button>
        <button type="submit" class="btn-sm" style="flex:1; background:#E2445C; color:#fff; border:none;">취소 신청</button>
      </div>
    </form>
  </div>
</div>

<%-- 지윤 26.07.29 추가: 배송조회 결과 모달 (주문목록 orders.jsp와 동일 로직) --%>
<div id="trackModalBg" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.45); z-index:999; align-items:center; justify-content:center;">
  <div style="background:#fff; border-radius:16px; padding:24px; max-width:480px; width:90%; max-height:80vh; overflow-y:auto;">
    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:16px;">
      <strong style="font-size:16px;">📦 실시간 배송조회</strong>
      <button type="button" onclick="closeTrackModal()" style="border:none; background:none; font-size:20px; cursor:pointer; color:#999;">&times;</button>
    </div>
    <div id="trackModalBody"></div>
  </div>
</div>

<script>
var contextPath = '${contextPath}';

//지윤 26.07.30 수정: 사업자별로 취소 버튼이 여러 개일 수 있어서, 클릭한 주문의 orderId를 hidden input에 채워넣도록 변경
function openCancelModal(orderId) {
  document.getElementById('cancelOrderId').value = orderId;
  document.getElementById('cancelModal').style.display = 'flex';
}
function closeCancelModal() { document.getElementById('cancelModal').style.display = 'none'; }

//지윤 26.07.29 추가: 배송조회 - orders.jsp와 동일 패턴 (levelLabel 매핑, 조회결과 표시)
var levelLabel = { 1: '배송준비중', 2: '집화완료', 3: '배송중', 4: '지점도착', 5: '배송출발', 6: '배송완료' };

function trackDelivery(orderId, courierCode, trackingNo) {
  document.getElementById('trackModalBody').innerHTML = '<p style="text-align:center;color:#999;padding:20px 0">조회 중...</p>';
  document.getElementById('trackModalBg').style.display = 'flex';

  fetch(contextPath + '/mypage/orders/track?orderId=' + orderId + '&courierCode=' + encodeURIComponent(courierCode) + '&trackingNo=' + encodeURIComponent(trackingNo))
    .then(function (res) { return res.json(); })
    .then(function (data) {
      var box = document.getElementById('trackModalBody');
      if (!data || data.status === false || data.result === 'N') {
        box.innerHTML = '<p style="color:#E24B4A">배송 정보를 조회할 수 없습니다. (' + (data && data.msg ? data.msg : '알 수 없는 운송장번호') + ')</p>';
        return;
      }

      var html = '<p style="font-weight:700;font-size:15px;margin-bottom:12px">현재 상태: ' + (levelLabel[data.level] || data.level) + '</p>';
      if (data.trackingDetails && data.trackingDetails.length > 0) {
        html += '<table style="width:100%;border-collapse:collapse;font-size:13px"><thead><tr style="border-bottom:1px solid #E4E6ED"><th style="text-align:left;padding:8px 4px">시각</th><th style="text-align:left;padding:8px 4px">위치</th><th style="text-align:left;padding:8px 4px">처리내용</th></tr></thead><tbody>';
        data.trackingDetails.forEach(function (d) {
          html += '<tr style="border-bottom:1px solid #F0F2F0"><td style="padding:8px 4px">' + (d.timeString || '-') + '</td><td style="padding:8px 4px">' + (d.where || '-') + '</td><td style="padding:8px 4px">' + (d.kind || '-') + '</td></tr>';
        });
        html += '</tbody></table>';
      } else {
        html += '<p style="color:#999">아직 상세 배송 이력이 없습니다. 택배사가 상품을 인수하면 표시됩니다.</p>';
      }
      box.innerHTML = html;
    })
    .catch(function () {
      document.getElementById('trackModalBody').innerHTML = '<p style="color:#E24B4A">조회 중 오류가 발생했습니다.</p>';
    });
}

function closeTrackModal() {
  document.getElementById('trackModalBg').style.display = 'none';
}
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>