<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="반려동물 쇼핑몰" />
<c:set var="bizPage"      value="orders" />

<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_store.jsp" %>

<%-- 지윤 26.07.20 수정: 하드코딩(JS mock 배열 orders[]) -> 실데이터 연동
     Controller: BizStoreController.storeOrders() / getOrderDetailJson() / updateOrderStatus()
     Service: BizStoreService.getOrderList / getOrderDetail / updateOrderStatus
     화면 레이아웃(CSS, HTML 뼈대)은 원본 그대로 유지, 데이터 표시/저장 로직만 실데이터로 교체 --%>
<style>
  /* =========================================================
     주문관리 상세 화면 UI 개선
     - 기존 데이터/JS 로직은 그대로 유지
     - 목록/상세 카드 폭 확장
     - 주문정보/배송정보 2열
     - 주문상품/결제금액 2열
     - 반응형 대응
     ========================================================= */

  /* 이 페이지 전용 전체 폭 */
  .order-page-wrap{
    width:100%;
    max-width:1200px;
  }

  /* 상세 카드 내부 */
  .od-card{
    width:100%;
    max-width:none;
    margin:0;
    padding:24px 28px 28px;
    box-sizing:border-box;
  }

  /* 주문 정보 + 배송 정보 */
  .od-info-grid{
    display:grid;
    grid-template-columns:1fr 1fr;
    gap:32px;
    padding:0;
  }

  .od-info-grid > div{
    min-width:0;
  }

  .od-info-grid h4{
    font-size:14px;
    font-weight:800;
    color:#1A1A2E;
    margin:0 0 14px;
    padding-bottom:10px;
    border-bottom:2px solid #1A1A2E;
  }

  .od-info-row{
    display:flex;
    justify-content:space-between;
    align-items:center;
    gap:20px;
    min-height:32px;
    padding:6px 4px;
    border-bottom:1px solid #F0F2F0;
    font-size:12px;
  }

  .od-info-row span:first-child{
    color:#8A8FA3;
    flex-shrink:0;
  }

  .od-info-row span:last-child{
    color:#1A1A2E;
    font-weight:600;
    text-align:right;
    word-break:break-word;
  }

  /* 배송 상태/택배사/송장번호 */
  .od-ship-manage{
    display:flex;
    flex-direction:column;
    gap:10px;
    margin-top:16px;
  }

  .od-ship-row{
    display:grid;
    grid-template-columns:1fr 1fr;
    gap:10px;
  }

  .od-info-grid label{
    font-size:11px;
    color:#666;
    font-weight:600;
    display:block;
    margin-bottom:5px;
  }

  .od-info-grid select,
  .od-info-grid input{
    width:100%;
    height:38px;
    border:1px solid #DDE1E8;
    border-radius:8px;
    padding:0 11px;
    background:#fff;
    font-size:12px;
    box-sizing:border-box;
    outline:none;
  }

  .od-info-grid select:focus,
  .od-info-grid input:focus{
    border-color:#2BAB82;
  }

  /* 주문상품 + 결제금액 좌우 배치 */
  .od-bottom-grid{
    display:grid;
    grid-template-columns:1fr 1fr;
    gap:20px;
    margin-top:20px;
  }

  .od-items-box{
    margin:0;
    padding:18px 16px 14px;
    background:#FFFFFF;
    border:1px solid #E4E6ED;
    border-radius:12px;
    box-sizing:border-box;
  }

  .od-items-box h4{
    font-size:13px;
    font-weight:800;
    color:#1A1A2E;
    margin:0 0 14px;
  }

  /* 레이아웃2: 주문상품 테이블형 */
  .od-item-table{
    width:100%;
    border:1px solid #E7E9EF;
    border-radius:10px;
    overflow:hidden;
    background:#fff;
  }

  .od-item-head,
  .od-item-row{
    display:grid;
    grid-template-columns:minmax(180px, 1.8fr) minmax(90px, .8fr) 60px 85px 95px;
    align-items:center;
  }

  .od-item-head{
    min-height:38px;
    background:#F8F9FB;
    border-bottom:1px solid #E7E9EF;
    color:#6F7585;
    font-size:11px;
    font-weight:700;
    text-align:center;
  }

  .od-item-head > span,
  .od-item-row > div{
    padding:0 10px;
    box-sizing:border-box;
  }

  .od-item-row{
    min-height:70px;
    border-bottom:1px solid #EEF0F4;
  }

  .od-item-row:last-child{
    border-bottom:none;
  }

  .od-item-product{
    display:flex;
    align-items:center;
    gap:10px;
    min-width:0;
  }

  .od-item-thumb{
    width:42px;
    height:42px;
    border-radius:8px;
    background:#E4E6ED;
    flex-shrink:0;
    overflow:hidden;
  }

  .od-item-thumb img{
    width:100%;
    height:100%;
    object-fit:cover;
    display:block;
  }

  .od-item-name{
    font-size:12px;
    font-weight:700;
    color:#1A1A2E;
    white-space:nowrap;
    overflow:hidden;
    text-overflow:ellipsis;
  }

  .od-item-option,
  .od-item-qty,
  .od-item-unit,
  .od-item-price{
    font-size:12px;
    color:#1A1A2E;
    text-align:center;
  }

  .od-item-price{
    font-weight:800;
    white-space:nowrap;
  }

  .od-item-summary{
    display:grid;
    grid-template-columns:1fr 1fr 1fr;
    margin-top:12px;
    padding:12px 10px;
    background:#F2FAF7;
    border-radius:9px;
  }

  .od-item-summary > div{
    display:flex;
    justify-content:center;
    align-items:center;
    gap:7px;
    font-size:12px;
    color:#33413C;
    border-right:1px solid #DCEDE6;
  }

  .od-item-summary > div:last-child{
    border-right:none;
  }

  .od-item-summary strong{
    color:#15966E;
    font-size:13px;
  }

  .od-price-box{
    margin:0;
    padding:18px 20px;
    background:#FFFFFF;
    border:1px solid #E4E6ED;
    border-radius:12px;
    box-sizing:border-box;
  }

  .od-price-row{
    display:flex;
    justify-content:space-between;
    align-items:center;
    padding:7px 0;
    font-size:14px;
    font-weight:700;
    color:#1A1A2E;
  }

  .od-price-row.discount span:first-child{
    color:#E2445C;
    font-weight:700;
  }

  .od-price-row.discount span:last-child{
    color:#E2445C;
    font-weight:800;
  }
  .od-price-total{
    display:flex;
    justify-content:space-between;
    align-items:center;
    margin-top:10px;
    padding-top:12px;
    border-top:2px solid #15966E;
    font-size:20px;
    font-weight:900;
    color:#15966E;
  }

  /* 하단 버튼 */
  .od-actions{
    display:flex;
    width:100%;
    box-sizing:border-box;
    justify-content:center;
    gap:12px;
    margin-top:28px;
    padding-top:20px;
    border-top:1px solid #EEF0F4;
    flex-wrap:wrap;
  }

  .od-actions .biz-btn-primary,
  .od-actions .biz-btn-ghost{
    min-width:120px;
    font-size:13px;
    padding:10px 16px;
  }

  /* 작은 화면 대응 */
  @media (max-width: 900px){
    .order-page-wrap{
      max-width:100%;
    }

    .od-card{
      padding:20px;
    }

    .od-info-grid,
    .od-bottom-grid{
      grid-template-columns:1fr;
      gap:18px;
    }

    .od-item-head,
    .od-item-row{
      grid-template-columns:minmax(160px, 1.6fr) minmax(80px, .8fr) 55px 80px 90px;
    }
  }

  @media (max-width: 600px){
    .od-card{
      padding:16px;
    }

    .od-ship-row{
      grid-template-columns:1fr;
    }

    .od-info-row{
      align-items:flex-start;
    }
  }
</style>

<main class="biz-main">
  <div class="biz-page-head">
    <h1 class="biz-page-title">주문 관리</h1>
    <p class="biz-page-desc">주문 확인·출고 처리. 배송·송장은 배송 관리, 환불은 환불 신청에서 처리합니다.</p>
  </div>

  <%-- 지윤 26.08.07: biz-main은 다른 관리자 화면도 같이 쓰는 공통 클래스라 여기서 못 줄임
       -> 이 페이지 전용 래퍼로 목록 카드 + 상세 카드를 한 번에 좁게 잡음 --%>
  <div class="order-page-wrap">

  <div class="biz-card" style="margin-bottom:16px">
    <div style="padding:20px 20px 0">
      <%-- 지윤 26.07.20 수정: <button onclick="switchTab(...)"> (JS로 배열 필터링) -> <a href="?statusCd=..."> (서버에 GET 요청, statusCd 파라미터로 필터)
           탭 옆 숫자도 JS로 orders.filter().length 세던 것 -> Controller가 넘겨준 statusCounts(Map)로 표시 --%>
      <%-- 2026/08/13 장우철 — 전체·결제완료·배송준비·배송전취소. 배송중/완료는 배송관리, 환불은 환불신청 --%>
      <div class="biz-tabs">
        <a href="${contextPath}/biz/store/orders" class="biz-tab ${empty selectedStatusCd ? 'active' : ''}">전체<span class="biz-tab-count">${statusCounts.PAID + statusCounts.READY + statusCounts.SHIPPING + statusCounts.DONE + statusCounts.CANCEL}</span></a>
        <a href="${contextPath}/biz/store/orders?statusCd=PAID" class="biz-tab ${selectedStatusCd == 'PAID' ? 'active' : ''}">결제완료<span class="biz-tab-count">${statusCounts.PAID}</span></a>
        <a href="${contextPath}/biz/store/orders?statusCd=READY" class="biz-tab ${selectedStatusCd == 'READY' ? 'active' : ''}">배송준비<span class="biz-tab-count">${statusCounts.READY}</span></a>
        <a href="${contextPath}/biz/store/orders?statusCd=CLAIM_PENDING" class="biz-tab ${selectedStatusCd == 'CLAIM_PENDING' ? 'active' : ''}" style="color:#E2445C;">배송전취소<span class="biz-tab-count">${statusCounts.CLAIM_PENDING}</span></a>
      </div>
    </div>

    <table class="biz-table">
      <thead><tr><th>주문번호</th><th>구매자</th><th>상품명</th><th>결제금액</th><th>상태</th><th>관리</th></tr></thead>
      <%-- 지윤 26.07.20 수정: <tbody id="orderBody"></tbody> (JS render()가 채워넣던 빈 껍데기)
           -> JSTL <c:forEach>로 ${orderList}(Controller가 넘겨준 실데이터) 바로 렌더링. render() 함수 자체가 필요없어져서 삭제됨 --%>
      <tbody>
        <c:choose>
          <c:when test="${empty orderList}">
            <tr><td colspan="6" style="text-align:center;color:#999;padding:24px 0">해당하는 주문이 없습니다.</td></tr>
          </c:when>
          <c:otherwise>
            <c:forEach var="o" items="${orderList}">
              <tr>
                <td>#${o.orderNo}</td>
                <td>${o.buyerName}</td>
                <td>
                  ${o.firstProductName}
                  <c:if test="${o.itemCount > 1}"> 외 ${o.itemCount - 1}건</c:if>
                </td>
                <td><fmt:formatNumber value="${o.payAmount}" pattern="#,###"/>원</td>
                <%-- 지윤 26.07.20 수정: JS statusBadgeClass 딕셔너리 조회 -> JSTL c:choose로 상태별 배지 클래스 직접 분기 --%>
                <td>
                  <%-- 2026/08/13 장우철 — 유저와 동일: 환불완료/부분환불/환불진행중/결제취소신청 --%>
                  <c:choose>
                    <c:when test="${o.statusBadge == 'CANCEL_REQUEST'}"><span class="bs-badge bs-cancel">결제취소신청</span></c:when>
                    <c:when test="${o.statusBadge == 'REFUND_DONE'}"><span class="bs-badge bs-cancel">환불완료</span></c:when>
                    <c:when test="${o.statusBadge == 'PARTIAL_REFUND'}"><span class="bs-badge bs-cancel">부분환불</span></c:when>
                    <c:when test="${o.statusBadge == 'REFUND_PROGRESS'}"><span class="bs-badge bs-cancel">환불진행중</span></c:when>
                    <c:when test="${o.statusBadge == 'PAID' || o.orderStatus == 'PAID'}"><span class="bs-badge bs-wait">결제완료</span></c:when>
                    <c:when test="${o.statusBadge == 'READY' || o.orderStatus == 'READY'}"><span class="bs-badge bs-prep">배송준비</span></c:when>
                    <c:when test="${o.statusBadge == 'SHIPPING' || o.orderStatus == 'SHIPPING'}"><span class="bs-badge bs-ready">배송중</span></c:when>
                    <c:when test="${o.statusBadge == 'DONE' || o.orderStatus == 'DONE'}"><span class="bs-badge bs-done">배송완료</span></c:when>
                    <c:when test="${o.statusBadge == 'CANCEL' || o.orderStatus == 'CANCEL'}"><span class="bs-badge bs-cancel">취소완료</span></c:when>
                    <c:otherwise><span class="bs-badge bs-empty"><c:out value="${o.orderStatus}"/></span></c:otherwise>
                  </c:choose>
                </td>
                <%-- 지윤 26.07.20 수정: onclick="openDetail('ORD-2026-0892')" (문자열 주문코드로 배열 검색)
                     -> onclick="openDetail(25)" (진짜 ORDER_ID 숫자키로 AJAX 조회) --%>
                <td><button class="biz-btn" onclick="openDetail(${o.orderId})">상세</button></td>
              </tr>
            </c:forEach>
          </c:otherwise>
        </c:choose>
      </tbody>
    </table>
  </div>

  <div class="biz-card" id="detailCard" style="display:none">
    <div class="biz-card-head"><span>주문 상세정보</span></div>

    <div class="od-card">
      <div class="od-info-grid">
        <div>
          <h4>주문 정보</h4>
          <div class="od-info-row"><span>주문번호</span><span id="dOrderNo"></span></div>
          <div class="od-info-row"><span>주문일</span><span id="dOrderDate"></span></div>
          <div class="od-info-row"><span>구매자</span><span id="dBuyer"></span></div>
          <div class="od-info-row"><span>연락처</span><span id="dPhone"></span></div>
          <div class="od-info-row"><span>이메일</span><span id="dEmail"></span></div>
          <div class="od-info-row"><span>결제방법</span><span id="dPayMethod"></span></div>
          <div class="od-info-row"><span>주문상태</span><span id="dStatusLabel"></span></div>
        </div>

        <div>
          <h4>배송 정보</h4>
          <div class="od-info-row"><span>수령인</span><span id="dReceiver"></span></div>
          <div class="od-info-row"><span>연락처</span><span id="dReceiverPhone"></span></div>
          <div class="od-info-row"><span>배송지</span><span id="dAddress"></span></div>

          <div class="od-ship-manage">
            <div class="od-ship-row">
              <div>
                <label>주문상태</label>
                <select id="dStatusSelect">
                  <option value="PAID">결제완료</option>
                  <option value="READY">배송준비</option>
                </select>
              </div>
              <div>
                <label>택배사</label>
                <select id="dCarrier">
                  <option value="">선택 안 함</option>
                </select>
              </div>
            </div>
            <label>송장번호</label>
            <input type="text" id="dTrackingNo" placeholder="송장번호를 입력하세요">
          </div>
        </div>
      </div>

      <div id="claimInfoBox" style="display:none; margin:16px 20px 0; padding:14px 16px; background:#FFF5F5; border:1px solid #FFD4D4; border-radius:12px;">
        <p style="font-weight:700; font-size:12px; color:#E2445C; margin:0 0 8px;">🚫 취소신청 대기중</p>
        <div class="od-info-row"><span>신청사유</span><span id="dCancelReason"></span></div>
        <div class="od-info-row"><span>신청일시</span><span id="dRequestedAt"></span></div>
      </div>

      <div class="od-bottom-grid">

    <div class="od-items-box">
        <h4>주문 상품</h4>
        <div class="od-item-table">
          <div class="od-item-head">
            <span>상품</span>
            <span>옵션</span>
            <span>수량</span>
            <span>판매가</span>
            <span>상품금액</span>
          </div>
          <div id="orderItemsBody"></div>
        </div>
        <div class="od-item-summary">
          <div><span>총 상품</span><strong id="dItemCount">0개</strong></div>
          <div><span>총 수량</span><strong id="dItemQty">0개</strong></div>
          <div><span>상품금액</span><strong id="dItemSummaryTotal">0원</strong></div>
        </div>
    </div>

    <div class="od-price-box">
        <div class="od-price-row">
            <span>상품 금액</span>
            <span id="dProductTotal">-</span>
        </div>

        <div class="od-price-row">
            <span>배송비</span>
            <span id="dDeliveryFee">-</span>
        </div>

        <div class="od-price-row discount">
            <span id="dCouponLabel">쿠폰 할인</span>
            <span id="dCouponDiscount">-</span>
        </div>

        <div class="od-price-row discount">
            <span>포인트 사용</span>
            <span id="dPointUsed">-</span>
        </div>

        <div class="od-price-total">
            <span>총 결제금액</span>
            <span id="dTotalAmount">-</span>
        </div>
    </div>

</div>
      <span id="dPayAmount" style="display:none"></span>

      <div class="od-actions">
        <button type="button" class="biz-btn-ghost" onclick="closeDetail()">이전 목록으로</button>
        <button type="button" class="biz-btn-primary" id="saveBtn" onclick="saveStatus()">상태변경</button>
        <button type="button" class="biz-btn-primary" id="forceCompleteBtn" style="display:none; background:#2BAB82;" onclick="forceComplete()">배송완료 수동처리</button>
        <button type="button" class="biz-btn-primary" id="rejectBtn" style="display:none; background:#999;" onclick="rejectCancel()">취소반려</button>
        <button type="button" class="biz-btn-primary" id="approveBtn" style="display:none; background:#E2445C;" onclick="approveCancel()">취소승인</button>
      </div>
   </div>
  </div>

  </div>
</main>

<%-- 지윤 26.07.20 참고: 이 토스트 팝업은 원본엔 showToast()가 호출하던 건데,
     지금은 상태변경 성공 시 location.reload()로 바로 새로고침하는 방식이라 안 쓰임.
     화면에 남겨는 두지만 지금은 죽은 코드 - 필요하면 saveStatus()에서 다시 연결 가능 --%>
<div class="biz-toast" id="saveToast">
  <svg viewBox="0 0 24 24" fill="none" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
  <span id="saveToastMsg">처리되었습니다.</span>
</div>

<script>
  var contextPath = '${contextPath}';

  //지윤 26.07.20 수정: statusLabel 딕셔너리는 그대로 유지(상세보기 라벨 표시용), key만 소문자(paid) -> 대문자(PAID)로 변경
  //지윤 26.07.20 삭제: statusBadgeClass 딕셔너리 - 목록 배지는 이제 JSTL c:choose로 서버에서 렌더링해서 JS에서 더 이상 안 씀
  var statusLabel = { PAID:'결제완료', READY:'배송준비', SHIPPING:'배송중', DONE:'배송완료', CANCEL:'취소완료' };

  //지윤 26.07.20 삭제: var orders = [ {...}, {...}, ... ] 하드코딩 배열 5건 통째로 삭제 (이제 서버가 실데이터를 줌)
  //지윤 26.07.20 삭제: var currentTab = 'all' - 탭 필터링이 서버 GET 파라미터 방식으로 바뀌면서 필요없어짐
  var currentOrderId = null;

//지윤 26.07.27 추가: delivery.jsp와 동일 - 스마트택배 API로 전체 택배사 목록 가져와서 드롭다운 채움
//courierList는 openDetail()에서 courierCode -> 옵션 매칭할 때도 재사용
var courierList = [];
fetch(contextPath + '/biz/store/delivery/companies')
  .then(function (res) { return res.json(); })
  .then(function (list) {
    courierList = list || [];
    var editSel = document.getElementById('dCarrier');
    courierList.forEach(function (c) {
      var opt = document.createElement('option');
      opt.value = c.id; opt.textContent = c.name;
      editSel.appendChild(opt);
    });
  })
  .catch(function () {
    document.getElementById('dCarrier').insertAdjacentHTML('beforeend', '<option value="">택배사 목록을 불러올 수 없습니다</option>');
  });

function fmtWon(n){ return (n || 0).toLocaleString('ko-KR') + '원'; }

  //지윤 26.07.20 삭제: function switchTab(tab) {...} - JS로 탭 active 토글 + orders 배열 필터링하던 함수.
  //탭이 이제 실제 <a href="?statusCd=...">라 페이지 이동만으로 처리, JS 함수 자체가 필요없어져서 삭제

  //지윤 26.07.20 수정: function openDetail(id) - orders.find(x => x.id === id)로 로컬 배열에서 찾던 것
  //-> fetch()로 서버(/biz/store/orders/{id})에 AJAX 요청해서 실제 DB 값 받아오는 방식으로 교체
  function openDetail(orderId) {
    fetch(contextPath + '/biz/store/orders/' + orderId)
      .then(function (res) { return res.json(); })
      .then(function (o) {
        if (!o) { alert('조회에 실패했습니다.'); return; }
        currentOrderId = orderId;

        document.getElementById('dOrderNo').textContent    = o.orderNo;
        document.getElementById('dOrderDate').textContent  = o.orderDate;
        document.getElementById('dBuyer').textContent      = o.buyerName;
        //지윤 26.07.20 추가: 구매자 연락처/이메일 - 원본은 목업 데이터 그대로 표시, 지금은 TB_MEMBER 조인해서 가져온 실제 값
        document.getElementById('dPhone').textContent      = o.buyerPhone || '-';
        document.getElementById('dEmail').textContent      = o.buyerEmail || '-';
        document.getElementById('dPayAmount').textContent  = fmtWon(o.payAmount);
        //지윤 26.07.20 수정: 결제방법 - 원본은 o.payMethod 목업 문자열, 지금은 TB_PAYMENT.PAY_METHOD 조인값
        // 2026/08/11 장우철 — BILLING/TOSS 한글 라벨
        document.getElementById('dPayMethod').textContent  = (function(m) {
          if (!m) return '-';
          var u = String(m).toUpperCase();
          if (u === 'BILLING') return '등록카드(빌링)';
          if (u === 'TOSS' || u === 'CARD' || u === 'NORMAL') return '토스 결제(위젯)';
          if (u === 'POINT' || u === 'ZERO') return '포인트/쿠폰';
          return m;
        })(o.payMethod);
        document.getElementById('dStatusLabel').textContent = (function() {
          // 2026/08/13 장우철 — 목록과 동일: 환불완료/부분환불/환불진행중
          if (o.claimStatus === 'PENDING') return '결제취소신청';
          var items = o.itemList || [];
          var total = items.length, done = 0, active = 0;
          for (var i = 0; i < total; i++) {
            var rs = items[i].returnStatusCd;
            if (rs === 'DONE') done++;
            else if (rs === 'REQUESTED' || rs === 'RETURNING') active++;
          }
          if (total > 0 && done === total) return '환불완료';
          if ((done + active) > 0 && (done + active) < total) return '부분환불';
          if (active > 0) return '환불진행중';
          return statusLabel[o.orderStatus] || o.orderStatus;
        })();

        document.getElementById('dReceiver').textContent      = o.recvName;
        document.getElementById('dReceiverPhone').textContent = o.recvPhone;
        //지윤 26.07.20 수정: 배송지 - 원본은 o.address 문자열 하나, 지금은 ZIP_CODE+ADDR1+ADDR2를 조합해서 표시
        document.getElementById('dAddress').textContent       = (o.zipCode ? '[' + o.zipCode + '] ' : '') + o.addr1 + ' ' + (o.addr2 || '');

        //지윤 26.07.28 수정: select에 이제 PAID/READY만 남음. SHIPPING/DONE/CANCEL 상태인 주문을 열면
//표시용 임시 옵션을 하나 끼워넣어서 값이 정확히 보이게 함 (선택 불가 disabled 처리는 아래 별도)
var dSelect = document.getElementById('dStatusSelect');
var extraLabels = { SHIPPING: '배송중', DONE: '배송완료', CANCEL: '취소/반품' };
if (extraLabels[o.orderStatus] && !dSelect.querySelector('option[value="' + o.orderStatus + '"]')) {
  var extraOpt = document.createElement('option');
  extraOpt.value = o.orderStatus; extraOpt.textContent = extraLabels[o.orderStatus];
  dSelect.appendChild(extraOpt);
}
dSelect.value = o.orderStatus;

//지윤 26.07.20 수정: 택배사/송장번호 - 원본은 o.carrier/o.trackingNo(주문 객체 안 하드코딩), 지금은 TB_ORDER_DELIVERY 조인값(courierName/trackingNo)
//지윤 26.07.27 수정: select value로 courierCode(예: "04") 우선 사용 -> API 목록의 실제 옵션과 매칭됨.
//courierCode가 없는 예전 데이터(하드코딩 시절 저장된 cj/hanjin 등)는 courierName 값을 그대로 넣어 폴백(못 찾으면 "선택 안 함"으로 보임)
document.getElementById('dCarrier').value       = o.courierCode || o.courierName || '';
document.getElementById('dTrackingNo').value    = o.trackingNo || '';

        // 지윤 26.08.07: 주문상품 영역을 테이블형(레이아웃2)으로 정리
        var itemsBody = document.getElementById('orderItemsBody');
        itemsBody.innerHTML = '';

        var itemList = o.itemList || [];
        var totalQty = 0;

        itemList.forEach(function (it) {
          var optionText = '';
          if (it.optionColor && it.optionColor !== '기본') optionText += it.optionColor + ' / ';
          optionText += it.optionSize || '기본';
          totalQty += Number(it.qty || 0);

          var row = document.createElement('div');
          row.className = 'od-item-row';

          // 지윤 26.08.07: 실제 서버 응답 필드명(thumbnailUrl)으로 수정 + 로컬 업로드 이미지 /upload/ 접두사 처리
          var imageHtml = '<div class="od-item-thumb">';
          var imageUrl = it.thumbnailUrl || '';
          if (imageUrl) {
            var imageSrc = imageUrl.indexOf('http') === 0 ? imageUrl : contextPath + '/upload/' + imageUrl;
            imageHtml += '<img src="' + imageSrc + '" alt="상품 이미지" onerror="this.remove()">';
          }
          imageHtml += '</div>';

          row.innerHTML =
            '<div class="od-item-product">' +
              imageHtml +
              '<div class="od-item-name">' + it.productName + '</div>' +
            '</div>' +
            '<div class="od-item-option">' + optionText + '</div>' +
            '<div class="od-item-qty">' + (it.qty || 0) + '개</div>' +
            '<div class="od-item-unit">' + fmtWon(it.unitPrice) + '</div>' +
            '<div class="od-item-price">' + fmtWon(it.totalPrice) + '</div>';

          itemsBody.appendChild(row);
        });

        document.getElementById('dItemCount').textContent = itemList.length + '개';
        document.getElementById('dItemQty').textContent = totalQty + '개';
        document.getElementById('dItemSummaryTotal').textContent = fmtWon(o.productTotal);

        // 지윤 26.08.07: 결제금액 세부내역 - 쿠폰/포인트 안 썼어도 행 자체는 항상 표시
        document.getElementById('dProductTotal').textContent = fmtWon(o.productTotal);
        document.getElementById('dDeliveryFee').textContent  = fmtWon(o.deliveryFee);

        var pointUsed = o.pointUsed || 0;
        var totalDiscount = o.discountAmount || 0;
        var couponDiscount = Math.max(0, totalDiscount - pointUsed);

        if (o.couponName && couponDiscount > 0) {
          document.getElementById('dCouponLabel').textContent = o.couponName + ' 할인';
          document.getElementById('dCouponDiscount').textContent = '-' + fmtWon(couponDiscount);
        } else {
          document.getElementById('dCouponLabel').textContent = '쿠폰 할인';
          document.getElementById('dCouponDiscount').textContent = '미사용';
        }

        if (pointUsed > 0) {
          document.getElementById('dPointUsed').textContent = '-' + pointUsed.toLocaleString('ko-KR') + 'P';
        } else {
          document.getElementById('dPointUsed').textContent = '0P';
        }

        document.getElementById('dTotalAmount').textContent = fmtWon(o.payAmount);

        var isPending = (o.claimStatus === 'PENDING');
document.getElementById('claimInfoBox').style.display = isPending ? 'block' : 'none';
document.getElementById('approveBtn').style.display = isPending ? 'inline-block' : 'none';
document.getElementById('rejectBtn').style.display = isPending ? 'inline-block' : 'none';
//지윤 26.07.28 수정: isDone -> isLocked로 확장. PAID/READY가 아니면(SHIPPING/DONE/CANCEL) 전부 읽기전용으로 잠금
var isLocked = !(o.orderStatus === 'PAID' || o.orderStatus === 'READY');
document.getElementById('saveBtn').style.display = (isPending || isLocked) ? 'none' : 'inline-block';
document.getElementById('dStatusSelect').disabled = isLocked;
document.getElementById('dCarrier').disabled = isLocked;
document.getElementById('dTrackingNo').disabled = isLocked;

//지윤 26.07.27 추가: 배송완료 수동처리 버튼은 SHIPPING 상태일 때만 노출 (READY/PAID면 아직 발송 전이라 의미없고, 이미 DONE이면 중복처리 방지)
document.getElementById('forceCompleteBtn').style.display = (o.orderStatus === 'SHIPPING') ? 'inline-block' : 'none';
if (isPending) {
  document.getElementById('dCancelReason').textContent = o.cancelReason || '-';
  document.getElementById('dRequestedAt').textContent = o.requestedAt || '-';
}

        document.getElementById('detailCard').style.display = 'block';
        document.getElementById('detailCard').scrollIntoView({ behavior: 'smooth', block: 'start' });
      });
  }

  function approveCancel() {
    if (!currentOrderId) return;
    if (!confirm('취소를 승인하시겠습니까? 승인 즉시 결제가 취소되고 재고/포인트/쿠폰이 복구됩니다.')) return;
    //HYJ 26.08.05
    csrfFetch(contextPath + '/biz/store/orders/' + currentOrderId + '/cancel/approve', { method: 'POST' })
      .then(function (res) { return res.text(); })
      .then(function (result) {
        if (result === 'OK') {
          alert('취소가 승인되었습니다.');
          location.reload();
        } else {
          alert('승인 실패: ' + result);
        }
      });
  }

  function rejectCancel() {
    if (!currentOrderId) return;
    if (!confirm('취소신청을 반려하시겠습니까?')) return;
    //HYJ 26.08.05
    csrfFetch(contextPath + '/biz/store/orders/' + currentOrderId + '/cancel/reject', { method: 'POST' })
      .then(function (res) { return res.text(); })
      .then(function (result) {
        if (result === 'OK') {
          alert('취소신청이 반려되었습니다.');
          location.reload();
        } else {
          alert('반려 처리에 실패했습니다.');
        }
      });
  }

  //지윤 26.07.20 수정: closeDetail()은 원본 그대로 (화면 숨기기만 하는 단순 함수라 안 건드림)
  function closeDetail() {
    document.getElementById('detailCard').style.display = 'none';
  }

  //지윤 26.07.20 수정: function saveStatus() - orders.find()로 로컬 배열 값만 바꾸고 render() 다시 그리던 것(진짜 저장 안 됨)
  //-> fetch()로 서버(/biz/store/orders/{id}/status)에 실제 POST, 성공하면 location.reload()로 최신 데이터 다시 불러옴
  //지윤 26.07.27 추가: 배송완료 수동처리 (확인창 필수 - 실수로 누르는 것 방지, 서버는 autoCompleteDeliveryIfDone 재사용)
function forceComplete() {
  if (!currentOrderId) return;
  if (!confirm('이 처리는 보통 스마트택배 API로 자동으로 이뤄집니다.\n실제로 배송이 완료된 것이 맞습니까?')) return;
  //HYJ 26.08.05
  csrfFetch(contextPath + '/biz/store/orders/' + currentOrderId + '/force-complete', { method: 'POST' })
    .then(function (res) { return res.text(); })
    .then(function (result) {
      if (result === 'OK') {
        alert('배송완료로 처리되었습니다.');
        location.reload();
      } else {
        alert('처리에 실패했습니다.');
      }
    });
}

function saveStatus() {
  if (!currentOrderId) return;
  //지윤 26.07.27 수정: delivery.jsp와 동일 패턴 - courierName은 선택된 옵션의 실제 택배사명(텍스트), courierCode는 API 코드(value)로 분리해서 전송
  var carrierSelect = document.getElementById('dCarrier');
  var selectedOption = carrierSelect.options[carrierSelect.selectedIndex];

  var formData = new URLSearchParams();
  formData.set('orderStatus', document.getElementById('dStatusSelect').value);
  formData.set('courierName', selectedOption ? selectedOption.textContent : '');
  formData.set('courierCode', carrierSelect.value);
  formData.set('trackingNo', document.getElementById('dTrackingNo').value.trim());

    csrfFetch(contextPath + '/biz/store/orders/' + currentOrderId + '/status', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: formData.toString()
    })
      .then(function (res) { return res.text(); })
      .then(function (result) {
        if (result === 'OK') {
          location.reload();
        } else {
          alert('상태 변경에 실패했습니다.');
        }
      });
  }

  //지윤 26.07.20 삭제: function showToast(msg) {...} - saveStatus()가 이제 location.reload() 방식이라 토스트 팝업 호출 안 함
  //지윤 26.07.20 삭제: function render() {...} - JS로 orders 배열 필터링해서 <tbody> DOM 새로 그리던 함수. 이제 JSTL이 서버에서 다 그려줘서 필요없어짐
  //지윤 26.07.20 삭제: render(); (페이지 로드 시 초기 렌더링 호출) - 위와 같은 이유로 삭제
</script>

<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>
