<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="store" />
<%@ include file="/WEB-INF/views/common/header.jsp" %>
<style>
  .order-wrap{max-width:900px;margin:32px auto 80px;padding:0 20px}
  .order-title{font-size:24px;font-weight:800;color:var(--text-main);margin-bottom:28px}
  .order-section{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);padding:24px;margin-bottom:20px}
  .order-section h3{font-size:16px;font-weight:800;color:var(--text-main);margin:0 0 18px;padding-bottom:14px;border-bottom:1px solid var(--border)}
  .order-form-grid{display:grid;grid-template-columns:1fr 1fr;gap:14px}
  .order-form-group{display:flex;flex-direction:column;gap:6px}
  .order-form-group.full{grid-column:1/-1}
  .order-form-group label{font-size:13px;font-weight:600;color:var(--text-sub)}
  .order-form-group input,.order-form-group select{border:1px solid var(--border);border-radius:var(--radius-sm);padding:10px 14px;font-size:14px;color:var(--text-main);outline:none;transition:border-color .2s;font-family:inherit}
  .order-form-group input:focus,.order-form-group select:focus{border-color:var(--primary)}
  .addr-row{display:flex;gap:8px}
  .addr-row input{flex:1}
  .addr-btn{padding:10px 14px;border:1px solid var(--primary);border-radius:var(--radius-sm);background:#fff;color:var(--primary);font-size:13px;font-weight:600;cursor:pointer;white-space:nowrap}
  .order-product-row{display:flex;gap:14px;align-items:center;padding:14px 0;border-bottom:1px solid var(--border)}
  .order-product-row:last-child{border-bottom:none}
  .order-product-thumb{width:60px;height:60px;border-radius:var(--radius-sm);object-fit:cover;flex-shrink:0}
  .order-product-name{flex:1;font-size:14px;font-weight:600;color:var(--text-main)}
  .order-product-price{font-size:14px;font-weight:700;color:var(--text-main)}
  .order-seller-group{border:1px solid var(--border);border-radius:var(--radius-sm);margin-bottom:16px;overflow:hidden}
  .order-seller-group:last-child{margin-bottom:0}
  .order-seller-head{display:flex;align-items:center;gap:6px;font-size:14px;font-weight:800;color:var(--primary-dark);background:var(--primary-light);padding:12px 16px}
  .order-seller-group .order-product-row{padding:14px 16px;border-bottom:1px solid var(--border)}
  .order-seller-summary{display:flex;flex-direction:column;gap:4px;padding:12px 16px;font-size:13px;color:var(--text-sub);background:var(--bg-page)}
  .order-seller-summary .row{display:flex;justify-content:space-between}
  .coupon-input{display:flex;gap:8px}
  .coupon-input input{flex:1;border:1px solid var(--border);border-radius:var(--radius-sm);padding:10px 14px;font-size:14px;outline:none;font-family:inherit}
  .coupon-input input:focus{border-color:var(--primary)}
  .order-total-box{background:var(--bg-page);border-radius:var(--radius-sm);padding:18px;display:flex;flex-direction:column;gap:10px}
  .order-total-row{display:flex;justify-content:space-between;font-size:14px;color:var(--text-sub)}
  .order-total-row.final{font-size:18px;font-weight:800;color:var(--text-main);padding-top:10px;border-top:1px solid var(--border);margin-top:4px}
  .order-total-row.final span:last-child{color:var(--primary-dark)}
  .btn-pay{width:100%;padding:16px;border:none;border-radius:var(--radius-sm);background:var(--primary);color:#fff;font-size:17px;font-weight:800;cursor:pointer;margin-top:16px;transition:var(--transition)}
  .btn-pay:hover{background:var(--primary-dark)}
</style>
<div class="order-wrap">
<form id="orderForm" action="${contextPath}/store/payment" method="post">
  <!--HYJ 26.08.05-->
  <input type="hidden" name="_csrf" value="${_csrf}">

  <c:forEach var="item" items="${orderItems}">
    <c:choose>
      <c:when test="${not empty item.cartItemId}">
        <input type="hidden" name="cartItemIds" value="${item.cartItemId}">
      </c:when>
      <c:otherwise>
        <input type="hidden" name="productId" value="${item.productId}">
        <input type="hidden" name="optionId" value="${item.optionId}">
        <input type="hidden" name="qty" value="${item.qty}">
      </c:otherwise>
    </c:choose>
  </c:forEach>
  <input type="hidden" name="couponId" id="hiddenCouponId">
  <input type="hidden" name="point" id="hiddenPoint">
  <input type="hidden" name="recvName" id="hiddenRecvName">
  <input type="hidden" name="recvPhone" id="hiddenRecvPhone">
  <input type="hidden" name="zipCode" id="hiddenZipCode">
  <input type="hidden" name="addr1" id="hiddenAddr1">
  <input type="hidden" name="addr2" id="hiddenAddr2">
  <input type="hidden" name="deliveryMemo" id="hiddenDeliveryMemo">

  <h1 class="order-title">주문서 작성</h1>

  <%-- After --%>
  <div class="order-section">
    <h3>주문 상품</h3>
    <%-- 지윤 26.07.30 수정: 사업자(BIZ_NO)별로 묶어서 렌더링, 그룹별 소계+배송비 계산 후 전체 배송비(totalDeliveryFee)로 누적 --%>
    <c:set var="productTotal" value="0" />
    <c:set var="totalDeliveryFee" value="0" />
    <c:set var="groupSubtotal" value="0" />

<%-- After --%>
<c:forEach var="item" items="${orderItems}" varStatus="vs">
  <c:if test="${vs.first || item.bizNo != orderItems[vs.index-1].bizNo}">
    <c:set var="groupSubtotal" value="0" />
    <div class="order-seller-group">
    <div class="order-seller-head">🏪 ${item.bizName}</div>
  </c:if>

  <c:set var="lineTotal" value="${item.price * item.qty}" />
  <c:set var="productTotal" value="${productTotal + lineTotal}" />
  <c:set var="groupSubtotal" value="${groupSubtotal + lineTotal}" />

  <c:set var="orderThumbSrc" value="${fn:startsWith(item.thumbnailUrl,'http') ? item.thumbnailUrl : contextPath.concat('/upload/').concat(item.thumbnailUrl)}"/>
  <div class="order-product-row">
    <img class="order-product-thumb"
         src="${orderThumbSrc}"
         alt="${item.productName}"
         onerror="this.src='https://placehold.co/60x60/EAF7F2/2BAB82?text=IMG'">

    <div class="order-product-name">
      ${item.productName}
      <c:choose>
        <c:when test="${not empty item.optionColor && item.optionColor != '기본'}">
          <span style="color:var(--text-muted); font-weight:500; font-size:13px;"> (${item.optionColor} / ${item.optionSize})</span>
        </c:when>
        <c:when test="${not empty item.optionSize}">
          <span style="color:var(--text-muted); font-weight:500; font-size:13px;"> (${item.optionSize})</span>
        </c:when>
      </c:choose>
      <span style="color:var(--text-muted); font-weight:500; font-size:13px;"> / 수량: ${item.qty}개</span>
    </div>

    <div class="order-product-price">
      <fmt:formatNumber value="${lineTotal}" pattern="#,###"/>원
    </div>
  </div>

  <c:if test="${vs.last || item.bizNo != orderItems[vs.index+1].bizNo}">
    <c:set var="groupFee" value="${groupSubtotal >= 50000 ? 0 : 3000}" />
    <c:set var="totalDeliveryFee" value="${totalDeliveryFee + groupFee}" />
    <div class="order-seller-summary">
      <div class="row"><span>상품금액</span><span><fmt:formatNumber value="${groupSubtotal}" pattern="#,###"/>원</span></div>
      <div class="row"><span>배송비</span><span>
        <c:choose>
          <c:when test="${groupFee == 0}">무료</c:when>
          <c:otherwise><fmt:formatNumber value="${groupFee}" pattern="#,###"/>원</c:otherwise>
        </c:choose>
      </span></div>
    </div>
    </div>
  </c:if>
</c:forEach>
  </div>

  <%-- After --%>
  <div class="order-section">
    <%-- 지윤 26.07.30 수정: h3의 margin:0으로 인해 다른 섹션(h3 기본 여백 18px+밑줄)보다 간격이 좁아 보이던 문제 -> 감싸는 div에 동일한 여백/밑줄 부여 --%>
    <div style="display:flex;justify-content:space-between;align-items:center;padding-bottom:14px;border-bottom:1px solid var(--border);margin-bottom:18px;">
      <h3 style="margin:0;padding:0;border:none;">배송지 정보</h3>
      <%-- 지윤 26.07.30 수정: 초기화 버튼은 가시성 낮아서 주소 입력폼 하단으로 이동함 (아래 수정② 참고) --%>
      <button type="button" onclick="openAddressModal()" style="font-size:13px;color:var(--primary,#2BAB82);background:none;border:none;text-decoration:underline;cursor:pointer;">배송지 관리 &gt;</button>
    </div>

    <div class="order-form-grid">
      
    <%-- 지윤 26.07.29 수정: memberInfo.memberName 직접참조 -> Controller에서 배송지록 우선순위 계산해서 넘겨준 memberRecvName 사용 --%>
  <div class="order-form-group"><label>받는 분</label><input type="text" id="recvName" value="${memberRecvName}" placeholder="이름"></div>
      <div class="order-form-group">
        <label>연락처</label>
        <div style="display:flex; gap:6px; align-items:center;">
          <c:set var="phonePrefixVal" value="010" />
          <c:set var="phoneMidVal" value="" />
          <c:set var="phoneEndVal" value="" />
          <c:if test="${not empty memberPhone}">
            <%-- 2026/08/11 장우철 — 하이픈·숫자만 모두 지원 (컨트롤러 정규화 + 방어) --%>
            <c:set var="phoneParts" value="${fn:split(memberPhone, '-')}" />
            <c:choose>
              <c:when test="${fn:length(phoneParts) == 3}">
                <c:set var="phonePrefixVal" value="${phoneParts[0]}" />
                <c:set var="phoneMidVal" value="${phoneParts[1]}" />
                <c:set var="phoneEndVal" value="${phoneParts[2]}" />
              </c:when>
              <c:otherwise>
                <c:set var="phoneDigitsOnly" value="${fn:replace(fn:replace(fn:replace(memberPhone,'-',''),' ',''),'.','')}" />
              </c:otherwise>
            </c:choose>
          </c:if>
          <select id="phonePrefix" style="width:90px">
            <option value="010" ${phonePrefixVal == '010' ? 'selected' : ''}>010</option>
            <option value="011" ${phonePrefixVal == '011' ? 'selected' : ''}>011</option>
            <option value="016" ${phonePrefixVal == '016' ? 'selected' : ''}>016</option>
            <option value="017" ${phonePrefixVal == '017' ? 'selected' : ''}>017</option>
            <option value="018" ${phonePrefixVal == '018' ? 'selected' : ''}>018</option>
            <option value="019" ${phonePrefixVal == '019' ? 'selected' : ''}>019</option>
          </select>
          <span>-</span>
         <input type="text" id="phoneMid" maxlength="4" value="${phoneMidVal}" placeholder="0000" style="text-align:center; width:70px; flex:none;">
          <span>-</span>
          <input type="text" id="phoneEnd" maxlength="4" value="${phoneEndVal}" placeholder="0000" style="text-align:center; width:70px; flex:none;">
        </div>
      </div>
      <%-- After --%>
      <script>
      (function() {
        var raw = '${phoneDigitsOnly}';
        if (raw && raw.length >= 10) {
          var p = document.getElementById('phonePrefix');
          var m = document.getElementById('phoneMid');
          var e = document.getElementById('phoneEnd');
          if (p) p.value = raw.substring(0, 3);
          if (m && !m.value) m.value = raw.substring(3, 7);
          if (e && !e.value) e.value = raw.substring(7, 11);
        }
      })();
      </script>
      <div class="order-form-group full">
        <label>주소</label>
        <div class="addr-row">
       <%-- 지윤 26.07.29 수정: memberInfo 직접참조 -> Controller에서 배송지록 우선순위 계산해서 넘겨준 값으로 원복 --%>
        <input type="text" id="orderZipcode" name="orderZipcode" value="${memberZipCode}" placeholder="우편번호" style="max-width:120px" readonly>
        <button type="button" class="addr-btn" id="btnSearchAddr">주소 검색</button>
        </div>
        <input type="text" id="orderAddr1" name="orderAddr1" value="${memberAddr1}" placeholder="기본 주소" style="margin-top:8px" readonly>
        <input type="text" id="orderAddr2" name="orderAddr2" value="${memberAddr2}" placeholder="상세 주소" style="margin-top:8px">
        <%-- 지윤 26.07.30 이동+수정: 헤더에 있던 초기화 버튼을 주소 필드 바로 아래로 이동, 아이콘+테두리 스타일로 변경 (가시성 개선) --%>
        <div style="text-align:right;margin-top:8px;">
          <%-- After --%>
          <button type="button" onclick="resetAddressForm()" style="display:inline-flex;align-items:center;gap:4px;font-size:13px;color:var(--text-secondary);background:#f5f5f5;border:1px solid var(--border-strong);border-radius:6px;padding:5px 10px;cursor:pointer;font-weight:500;">
            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 4v6h6"/><path d="M3.51 15a9 9 0 1 0 2.13-9.36L1 10"/></svg>
            입력 초기화
          </button>
        </div>
      </div>
    </div>
  </div>

 <div class="order-section">
    <h3>주문 시 요청사항</h3>
    <div class="order-form-grid">
      <div class="order-form-group full">
        <label>배송 메모</label>
        <select id="deliveryMemoSelect" onchange="toggleMemoInput()">
          <option value="문 앞에 놓아주세요">문 앞에 놓아주세요</option>
          <option value="경비실에 맡겨주세요">경비실에 맡겨주세요</option>
          <option value="부재 시 연락 부탁드려요">부재 시 연락 부탁드려요</option>
          <option value="배송 전에 연락 주세요">배송 전에 연락 주세요</option>
          <option value="직접입력">직접 입력</option>
        </select>
        <input type="text" id="deliveryMemoCustom" maxlength="50" placeholder="배송 메모를 입력해주세요 (최대 50자)" style="margin-top:8px; display:none;">
      </div>
    </div>
  </div>

  <%-- 지윤 26.07.09 수정: 쿠폰 코드 직접입력 -> 보유쿠폰 드롭다운으로 변경 (등록은 마이페이지에서, 여기선 적용만) --%>
<div class="order-section">
    <h3>쿠폰 / 포인트</h3>
    <div class="order-form-group">
      <label>보유 쿠폰</label>
      <select id="couponSelect" onchange="updateOrderTotal()">
        <option value="0" data-type="" data-value="0" data-max="0" data-min="0">쿠폰 선택 안 함</option>
        <c:forEach var="c" items="${memberCoupons}">
          <%-- 지윤 26.08.11 추가: data-max = 정률쿠폰 최대할인금액(원), FIXED는 사용 안 함 --%>
          <option value="${c.memberCouponId}" data-type="${c.couponType}" data-value="${c.discountValue}" data-max="${c.maxDiscountAmt}" data-min="${c.minOrderAmt}" data-biz="${c.bizNo}">
            ${c.couponName}
            <c:if test="${c.couponType == 'RATE'}">
              (${c.discountValue}% 할인, 최대 <fmt:formatNumber value="${c.maxDiscountAmt}" pattern="#,###"/>원)
            </c:if>
            <c:if test="${c.couponType == 'FIXED'}"> (<fmt:formatNumber value="${c.discountValue}" pattern="#,###"/>원 할인)</c:if>
          </option>
        </c:forEach>
      </select>
      <c:if test="${empty memberCoupons}">
        <small style="color:var(--text-muted)">사용 가능한 쿠폰이 없습니다.</small>
      </c:if>
    </div>

    <div class="order-form-grid" style="margin-top:14px">
      <div class="order-form-group">
        <label>보유 포인트 <fmt:formatNumber value="${memberPoint}" pattern="#,###"/>P</label>
        <div style="display:flex;gap:8px">
          <input type="number" id="pointInput" placeholder="사용할 포인트 입력" value="0" min="0" style="flex:1"
       oninput="this.value = this.value.replace(/^0+(?=\d)/, '')" onchange="updateOrderTotal()">
          <button type="button" id="btnUseAllPoint" class="addr-btn">최대사용</button>
        </div>
      </div>
    </div>
</div>

  <div class="order-section">
    <h3>결제 예정 금액</h3>
    <div class="order-total-box">
      <div class="order-total-row">
  <span>상품 금액</span>
  <span id="orderProductTotal"><fmt:formatNumber value="${productTotal}" pattern="#,###"/>원</span>
</div>
<div class="order-total-row">
  <span>배송비</span>
  <span id="orderDeliveryFee" style="color:var(--primary)">무료</span>
</div>
<div class="order-total-row">
  <span>쿠폰/포인트 할인</span>
  <span id="orderDiscount" style="color:var(--accent)">-0원</span>
</div>
<div class="order-total-row final">
  <span>결제 예정 금액</span>
  <span id="orderFinalTotal"><fmt:formatNumber value="${productTotal}" pattern="#,###"/>원</span>
</div>
    </div>
    <button type="button" class="btn-pay" onclick="goToPayment()">결제수단 선택하기</button> 
  </div>
</form>
</div>

<%-- 2026/08/06 장우철: 결제에서 돌아온 복원값 (XSS 대비 c:out, JS는 data 속성으로 읽음) --%>
<c:if test="${not empty restoreCouponId or not empty restorePoint or not empty restoreDeliveryMemo}">
  <div id="restoreOrderMeta" style="display:none"
       data-coupon-id="<c:out value='${restoreCouponId}'/>"
       data-point="<c:out value='${restorePoint}'/>"
       data-memo="<c:out value='${restoreDeliveryMemo}'/>"></div>
</c:if>

<%-- 지윤 26.07.29 추가: 배송지 목록 모달 (네이버페이 스타일 - 목록조회 + 선택 + 신규등록) --%>
<div id="addressModalBg" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.45); z-index:999; align-items:center; justify-content:center;">
  <div style="background:#fff; border-radius:16px; padding:24px; max-width:480px; width:90%; max-height:80vh; overflow-y:auto;">
    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:16px;">
      <strong style="font-size:16px;">배송지 목록</strong>
      <button type="button" onclick="closeAddressModal()" style="border:none; background:none; font-size:20px; cursor:pointer; color:#999;">&times;</button>
    </div>

    <button type="button" onclick="toggleNewAddressForm()"
            style="width:100%; padding:12px; border:1.5px dashed #D8DEDA; border-radius:10px; background:#fff; color:#666; font-size:13px; font-weight:600; cursor:pointer; margin-bottom:14px;">
      + 배송지 신규입력
    </button>

    <%-- 지윤 26.07.29 추가: 신규 배송지 등록 폼 (평소엔 숨김) --%>
    <div id="newAddressForm" style="display:none; border:1px solid #E2E8E4; border-radius:10px; padding:16px; margin-bottom:14px;">
      <div style="display:flex; gap:8px; margin-bottom:8px;">
        <input type="text" id="newRecvName" placeholder="받는 분" style="flex:1; border:1px solid #E2E8E4; border-radius:8px; padding:8px 10px; font-size:13px;">
        <input type="text" id="newRecvPhone" placeholder="연락처 (010-0000-0000)" style="flex:1; border:1px solid #E2E8E4; border-radius:8px; padding:8px 10px; font-size:13px;">
      </div>
      <div style="display:flex; gap:8px; margin-bottom:8px;">
        <input type="text" id="newZipcode" placeholder="우편번호" readonly style="width:110px; border:1px solid #E2E8E4; border-radius:8px; padding:8px 10px; font-size:13px;">
        <button type="button" onclick="searchNewAddress()" style="border:1px solid var(--primary,#2BAB82); color:var(--primary,#2BAB82); background:#fff; border-radius:8px; padding:8px 12px; font-size:13px; cursor:pointer;">주소 검색</button>
      </div>
      <input type="text" id="newAddr1" placeholder="기본 주소" readonly style="width:100%; box-sizing:border-box; border:1px solid #E2E8E4; border-radius:8px; padding:8px 10px; font-size:13px; margin-bottom:8px;">
      <input type="text" id="newAddr2" placeholder="상세 주소" style="width:100%; box-sizing:border-box; border:1px solid #E2E8E4; border-radius:8px; padding:8px 10px; font-size:13px; margin-bottom:10px;">
      <button type="button" onclick="saveNewAddress()" style="width:100%; padding:10px; background:var(--primary,#2BAB82); color:#fff; border:none; border-radius:8px; font-size:13px; font-weight:700; cursor:pointer;">이 배송지 저장</button>
    </div>

    <div id="addressListBox"></div>
  </div>
</div>

<!-- 카카오 우편번호 API -->
<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<script>
//지윤 26.07.29 추가: 배송지 목록 모달 fetch 호출에 필요한 contextPath 선언 (누락되어 있었음)
var contextPath = '${contextPath}';

//지윤 26.07.09 추가: 쿠폰/포인트 선택 시 결제 예정 금액 실시간 계산
var PRODUCT_TOTAL = ${productTotal};
var MEMBER_POINT = ${memberPoint != null ? memberPoint : 0};

//지윤 26.08.07 추가: 사업자(bizNo)별 상품 소계 — 쿠폰이 실제 적용 가능한 대상 금액을 알기 위함
//백엔드 StoreShopController의 groupSubtotals 계산과 동일한 개념
var BIZ_SUBTOTALS = {};
<c:forEach var="item" items="${orderItems}">
BIZ_SUBTOTALS[${item.bizNo}] = (BIZ_SUBTOTALS[${item.bizNo}] || 0) + ${item.price * item.qty};
</c:forEach>
//지윤 26.07.30 추가: 배송비를 전체금액 기준(50000원)이 아니라, JSP에서 사업자별로 이미 계산해둔 합계로 사용
var TOTAL_DELIVERY_FEE = ${totalDeliveryFee};
function won(n){ return n.toLocaleString('ko-KR') + '원'; }


function updateOrderTotal() {
  var couponSel = document.getElementById('couponSelect');
  var opt = couponSel.options[couponSel.selectedIndex];
  var couponType = opt.dataset.type;
  var couponValue = parseInt(opt.dataset.value) || 0;
  var couponMax = parseInt(opt.dataset.max) || 0; // 지윤 26.08.11 추가: 정률쿠폰 최대할인금액
  var minOrderAmt = parseInt(opt.dataset.min) || 0;
  var couponBizNo = opt.dataset.biz; // 지윤 26.08.07: 쿠폰 발급 사업자

  //지윤 26.07.30 수정: 전체금액 기준 계산 -> 사업자별로 미리 합산해둔 TOTAL_DELIVERY_FEE 그대로 사용
  var deliveryFee = TOTAL_DELIVERY_FEE;

  var couponDiscount = 0;
  if (couponType) {
    // 지윤 26.08.07: 쿠폰은 발급한 사업자의 상품 소계 기준으로만 적용 (전체 장바구니 금액 X)
    // 지윤 26.08.07(수정): 최소주문금액이 0으로 설정된 쿠폰은 "bizSubtotal < minOrderAmt"만으로는
    // 안 걸러짐(0 < 0은 false) -> 이 주문에 해당 사업자 상품 자체가 있는지도 별도로 확인
    var hasBizItems = Object.prototype.hasOwnProperty.call(BIZ_SUBTOTALS, couponBizNo);
    var bizSubtotal = BIZ_SUBTOTALS[couponBizNo] || 0;

    if (!hasBizItems || bizSubtotal < minOrderAmt) {
      alert('이 쿠폰은 발급한 사업자의 상품에만 적용되며, 최소 주문금액 ' + won(minOrderAmt) + ' 이상부터 사용 가능합니다.');
      couponSel.value = '0';
    } else if (couponType === 'RATE') {
    var rawDiscount = Math.floor(bizSubtotal * couponValue / 100);
   // 지윤 26.08.11 수정: 최대할인금액 캡 적용 (없으면 무제한으로 새던 버그 수정)
   // couponMax가 0(=DB에 값 없는 레거시 쿠폰)이면 캡 미적용, 있으면 min으로 제한
   couponDiscount = couponMax > 0 ? Math.min(rawDiscount, couponMax) : rawDiscount;
} else if (couponType === 'FIXED') {
   couponDiscount = couponValue;
    }
  }

  var pointInput = document.getElementById('pointInput');
  var pointUsed = parseInt(pointInput.value) || 0;
  if (pointUsed < 0) pointUsed = 0;
  //지윤 26.07.10 추가: 보유포인트와 결제금액(상품+배송비) 중 작은 값 넘지 못하게 제한
  // 2026/07/27 장우철 — 사용량은 보유분·결제액 이내만 (보유가 음수면 0까지만)
  var held = Math.max(0, MEMBER_POINT || 0);
  var maxUsablePoint = Math.min(held, PRODUCT_TOTAL + deliveryFee);
  if (pointUsed > maxUsablePoint) {
    pointUsed = maxUsablePoint;
    pointInput.value = pointUsed;
  }

  var totalDiscount = couponDiscount + pointUsed;
  var finalTotal = PRODUCT_TOTAL + deliveryFee - totalDiscount;
  if (finalTotal < 0) finalTotal = 0;

  document.getElementById('orderDeliveryFee').textContent = deliveryFee === 0 ? '무료' : won(deliveryFee);
  document.getElementById('orderDiscount').textContent = '-' + won(totalDiscount);
  document.getElementById('orderFinalTotal').textContent = won(finalTotal);
}

//지윤 26.07.10 추가: 보유포인트 "최대사용" <-> "사용취소" 토글 버튼
document.getElementById('btnUseAllPoint').addEventListener('click', function () {
  var btn = this;
  var pointInput = document.getElementById('pointInput');

  if (btn.textContent === '최대사용') {
    //지윤 26.07.30 수정: TOTAL_DELIVERY_FEE 그대로 사용
    var deliveryFee = TOTAL_DELIVERY_FEE;
    var paymentAmount = PRODUCT_TOTAL + deliveryFee;
    // 2026/07/27 장우철 — 최대사용도 보유분 초과 불가
    var maxUsable = Math.min(Math.max(0, MEMBER_POINT || 0), paymentAmount);
    pointInput.value = maxUsable;
    btn.textContent = '사용취소';
  } else {
    pointInput.value = 0;
    btn.textContent = '최대사용';
  }
  updateOrderTotal();
});

//지윤 26.07.10 추가: 주문결제화면 연락처는 숫자만 입력, 4자리 채우면 다음 칸으로 자동 이동
document.getElementById('phoneMid').addEventListener('input', function () {
  this.value = this.value.replace(/[^0-9]/g, '');
  if (this.value.length >= 4) document.getElementById('phoneEnd').focus();
});
document.getElementById('phoneEnd').addEventListener('input', function () {
  this.value = this.value.replace(/[^0-9]/g, '');
});

//지윤 26.07.10 추가: 결제 진행 전 배송지 필수 항목 검증
function goToPayment() {
  var recvName = document.getElementById('recvName').value.trim();
  if (recvName === '') {
    alert('받는 분 이름을 입력해주세요.');
    return;
  }
  var prefix = document.getElementById('phonePrefix').value;
  var mid = document.getElementById('phoneMid').value;
  var end = document.getElementById('phoneEnd').value;
  if (mid.length !== 4 || end.length !== 4) {
    alert('휴대전화번호를 정확히 입력해주세요.');
    return;
  }
  var zipCode = document.getElementById('orderZipcode').value.trim();
  if (zipCode === '') {
    alert('우편번호를 입력해주세요. (주소 검색 버튼을 눌러주세요)');
    return;
  }
  var addr1 = document.getElementById('orderAddr1').value.trim();
  if (addr1 === '') {
    alert('기본 주소를 입력해주세요.');
    return;
  }
  var memoSelect = document.getElementById('deliveryMemoSelect');
  var memo = memoSelect.value === '직접입력'
      ? document.getElementById('deliveryMemoCustom').value.trim()
      : memoSelect.value;
  var couponSel = document.getElementById('couponSelect');

  document.getElementById('hiddenCouponId').value = couponSel.value;
  document.getElementById('hiddenPoint').value = document.getElementById('pointInput').value || 0;
  document.getElementById('hiddenRecvName').value = recvName;
  document.getElementById('hiddenRecvPhone').value = prefix + '-' + mid + '-' + end;
  document.getElementById('hiddenZipCode').value = zipCode;
  document.getElementById('hiddenAddr1').value = addr1;
  document.getElementById('hiddenAddr2').value = document.getElementById('orderAddr2').value.trim();
  document.getElementById('hiddenDeliveryMemo').value = memo;
  document.getElementById('orderForm').submit();
}

//지윤 26.07.10 추가: 배송메모 "직접입력" 선택 시 텍스트박스 보이기/숨기기
function toggleMemoInput() {
  var select = document.getElementById('deliveryMemoSelect');
  var customInput = document.getElementById('deliveryMemoCustom');
  if (select.value === '직접입력') {
    customInput.style.display = 'block';
    customInput.focus();
  } else {
    customInput.style.display = 'none';
    customInput.value = '';
  }
}

//2026/08/06 장우철: 결제→주문서 복원 시 쿠폰/포인트/배송메모 재적용
(function restoreFromPayment() {
  var meta = document.getElementById('restoreOrderMeta');
  if (!meta) return;

  var restoreCouponId = meta.getAttribute('data-coupon-id') || '';
  var restorePoint = meta.getAttribute('data-point') || '';
  var restoreMemo = meta.getAttribute('data-memo') || '';

  if (restoreCouponId) {
    var couponSel = document.getElementById('couponSelect');
    if (couponSel) couponSel.value = restoreCouponId;
  }
  if (restorePoint !== '' && restorePoint !== '0') {
    var pointInput = document.getElementById('pointInput');
    if (pointInput) pointInput.value = restorePoint;
  }
  if (restoreMemo) {
    var memoSelect = document.getElementById('deliveryMemoSelect');
    var customInput = document.getElementById('deliveryMemoCustom');
    if (!memoSelect) return;
    var matched = false;
    for (var i = 0; i < memoSelect.options.length; i++) {
      if (memoSelect.options[i].value === restoreMemo) {
        memoSelect.selectedIndex = i;
        matched = true;
        break;
      }
    }
    if (!matched) {
      memoSelect.value = '직접입력';
      if (customInput) {
        customInput.style.display = 'block';
        customInput.value = restoreMemo;
      }
    }
  }
})();

//지윤 26.07.09 추가: 페이지 로드 시 배송비/총액 한 번 자동 계산 (쿠폰 안 골라도 정확한 값 보이게)
updateOrderTotal();

// 주소 검색 (카카오/다음 우편번호 API)
document.getElementById('btnSearchAddr').addEventListener('click', function () {
  if (typeof daum === 'undefined' || !daum.Postcode) {
    alert('주소 검색 API를 불러오지 못했습니다.');
    return;
  }
  new daum.Postcode({
    oncomplete: function (data) {
      var addr = '';
      var extraAddr = '';
      if (data.userSelectedType === 'R') {
        addr = data.roadAddress;
        if (data.bname !== '') {
          extraAddr += data.bname;
        }
        if (data.buildingName !== '') {
          extraAddr += (extraAddr ? ', ' : '') + data.buildingName;
        }
        if (extraAddr !== '') {
          extraAddr = ' (' + extraAddr + ')';
        }
      } else {
        addr = data.jibunAddress;
      }
      document.getElementById('orderZipcode').value = data.zonecode;
      document.getElementById('orderAddr1').value = addr + extraAddr;
      document.getElementById('orderAddr2').focus();
    }
  }).open();
});

//지윤 26.07.29 추가: 배송지 목록 모달
function openAddressModal() {
  document.getElementById('newAddressForm').style.display = 'none';
  document.getElementById('addressModalBg').style.display = 'flex';
  loadAddressList();
}
function closeAddressModal() {
  document.getElementById('addressModalBg').style.display = 'none';
}

//지윤 26.07.29 수정: 네이버페이 스타일로 재구성 - 이름 옆에 "기본배송지"+"✓ 선택됨" 표시, 우측에 수정/삭제/선택 버튼
function loadAddressList() {
  var box = document.getElementById('addressListBox');
  box.innerHTML = '<p style="text-align:center;color:#999;padding:16px 0">불러오는 중...</p>';

  fetch(contextPath + '/mypage/address/list')
    .then(function (res) { return res.json(); })
    .then(function (list) {
      if (!list || list.length === 0) {
        box.innerHTML = '<p style="text-align:center;color:#999;padding:16px 0">등록된 배송지가 없습니다.<br>위 "배송지 신규입력"으로 추가해보세요.</p>';
        return;
      }
      var html = '';
      list.forEach(function (a) {
        var isDefault = a.isDefault === 'Y';
        var esc = function (s) { return (s || '').replace(/'/g, "\\'"); };
        var argStr = a.addrId + ", '" + esc(a.recvName) + "', '" + esc(a.recvPhone) + "', '" + esc(a.zipCode) + "', '" + esc(a.addr1) + "', '" + esc(a.addr2) + "'";

        //지윤 26.07.29 수정: 네이버페이 레이아웃 그대로 - 이름줄 오른쪽 끝에 선택/선택됨 표시, 수정·삭제는 주소 아래 별도 줄
        html += '<div style="border:1px solid ' + (isDefault ? 'var(--primary,#2BAB82)' : '#E2E8E4') + '; background:' + (isDefault ? 'var(--primary-light,#EAF7F2)' : '#fff') + '; border-radius:10px; padding:14px 16px; margin-bottom:10px;">';
        html += '  <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:6px;">';
        html += '    <div style="display:flex; align-items:center; gap:6px;">';
        html += '      <b style="font-size:14px; color:' + (isDefault ? 'var(--primary,#2BAB82)' : '#333') + ';">' + a.recvName + '</b>';
        if (isDefault) {
          html += '      <span style="font-size:11px; background:var(--primary-light,#EAF7F2); color:var(--primary,#2BAB82); padding:2px 8px; border-radius:20px; font-weight:700;">기본배송지</span>';
        }
        html += '    </div>';
        if (isDefault) {
          html += '    <span style="font-size:12px; color:var(--primary,#2BAB82); font-weight:700; flex-shrink:0;">✓ 선택됨</span>';
        } else {
          html += '    <button type="button" onclick="selectAddress(' + argStr + ')" style="border:1px solid var(--primary,#2BAB82); background:#fff; color:var(--primary,#2BAB82); font-size:12px; padding:4px 10px; border-radius:6px; cursor:pointer; font-weight:700; flex-shrink:0;">선택</button>';
        }
        html += '  </div>';
        html += '  <p style="font-size:13px; color:#666; margin:0 0 4px;">' + a.recvPhone + '</p>';
        html += '  <p style="font-size:13px; color:#666; margin:0 0 10px;">(' + a.zipCode + ') ' + a.addr1 + ' ' + (a.addr2 || '') + '</p>';
        html += '  <div style="display:flex; gap:6px;">';
        html += '    <button type="button" onclick="editAddress(' + argStr + ')" style="border:1px solid #D8DEDA; background:#fff; color:#666; font-size:12px; padding:5px 10px; border-radius:6px; cursor:pointer;">수정</button>';
        html += '    <button type="button" onclick="removeAddress(' + a.addrId + ')" style="border:1px solid #D8DEDA; background:#fff; color:#666; font-size:12px; padding:5px 10px; border-radius:6px; cursor:pointer;">삭제</button>';
        html += '  </div>';
        html += '</div>';
      });
      box.innerHTML = html;
    })
    .catch(function () {
      box.innerHTML = '<p style="text-align:center;color:#E24B4A;padding:16px 0">목록을 불러오지 못했습니다.</p>';
    });
}

//지윤 26.07.29 수정: "폼에 값 채우기"와 "서버에 기본배송지로 저장"을 분리
//기존엔 새 배송지 저장 시 selectAddress(null, ...)을 불러서 addrId 없이 /select를 또 호출 -> 항상 실패하는 불필요한 API 호출이 있었음
// 2026/08/01 장우철 — 010-1234-5678 / 01012345678 둘 다 주문서 3칸에 반영
function fillOrderForm(recvName, recvPhone, zipCode, addr1, addr2) {
  document.getElementById('recvName').value = recvName;
  var digits = (recvPhone || '').replace(/[^0-9]/g, '');
  if (digits.length >= 10) {
    document.getElementById('phonePrefix').value = digits.substring(0, 3);
    document.getElementById('phoneMid').value = digits.substring(3, 7);
    document.getElementById('phoneEnd').value = digits.substring(7, 11);
  } else {
    var phoneParts = (recvPhone || '').split('-');
    if (phoneParts.length === 3) {
      document.getElementById('phonePrefix').value = phoneParts[0];
      document.getElementById('phoneMid').value = phoneParts[1];
      document.getElementById('phoneEnd').value = phoneParts[2];
    }
  }
  document.getElementById('orderZipcode').value = zipCode;
  document.getElementById('orderAddr1').value = addr1;
  document.getElementById('orderAddr2').value = addr2;
}

//지윤 26.07.29 수정: 목록에서 기존 배송지를 선택할 때만 호출 (진짜 addrId가 있을 때만 /select 호출)
function selectAddress(addrId, recvName, recvPhone, zipCode, addr1, addr2) {
  fillOrderForm(recvName, recvPhone, zipCode, addr1, addr2);

  //HYJ 26.08.05
  csrfFetch(contextPath + '/mypage/address/select', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: 'addrId=' + addrId
  });

  closeAddressModal();
}

//지윤 26.07.29 추가: 지금 수정 중인 배송지 ID (null이면 "신규 등록" 모드, 값 있으면 "수정" 모드)
var editingAddrId = null;

//지윤 26.07.29 수정: 신규 배송지 입력폼 토글 (신규 버튼으로 열 때는 수정모드 해제)
function toggleNewAddressForm() {
  editingAddrId = null;
  document.getElementById('newRecvName').value = '';
  document.getElementById('newRecvPhone').value = '';
  document.getElementById('newZipcode').value = '';
  document.getElementById('newAddr1').value = '';
  document.getElementById('newAddr2').value = '';
  var form = document.getElementById('newAddressForm');
  form.style.display = (form.style.display === 'none') ? 'block' : 'none';
}

//지윤 26.07.29 추가: "수정" 버튼 클릭 -> 같은 폼에 기존 값 채워서 열고, 수정모드로 전환
function editAddress(addrId, recvName, recvPhone, zipCode, addr1, addr2) {
  editingAddrId = addrId;
  document.getElementById('newRecvName').value = recvName;
  document.getElementById('newRecvPhone').value = recvPhone;
  document.getElementById('newZipcode').value = zipCode;
  document.getElementById('newAddr1').value = addr1;
  document.getElementById('newAddr2').value = addr2;
  document.getElementById('newAddressForm').style.display = 'block';
}

//지윤 26.07.29 추가: "삭제" 버튼 클릭 -> 확인창 거쳐서 삭제 후 목록 새로고침
function removeAddress(addrId) {
  if (!confirm('이 배송지를 삭제하시겠습니까?')) return;

  //HYJ 26.08.05
  csrfFetch(contextPath + '/mypage/address/delete', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: 'addrId=' + addrId
  })
    .then(function (res) { return res.text(); })
    .then(function (result) {
      if (result === 'OK') {
        loadAddressList();
      } else {
        alert('삭제에 실패했습니다.');
      }
    });
}

//지윤 26.07.29 추가: 신규 배송지용 우편번호 검색 (기존 daum.Postcode 재사용, 대상만 다름)
function searchNewAddress() {
  if (typeof daum === 'undefined' || !daum.Postcode) {
    alert('주소 검색 API를 불러오지 못했습니다.');
    return;
  }
  new daum.Postcode({
    oncomplete: function (data) {
      var addr = (data.userSelectedType === 'R') ? data.roadAddress : data.jibunAddress;
      document.getElementById('newZipcode').value = data.zonecode;
      document.getElementById('newAddr1').value = addr;
      document.getElementById('newAddr2').focus();
    }
  }).open();
}

//지윤 26.07.29 수정: editingAddrId가 있으면 수정(/update), 없으면 신규등록(/add)으로 분기
//기존 코드는 editingAddrId를 아예 확인 안 하고 무조건 /add만 호출해서, 수정해도 새 주소가 하나 더 생기는 버그가 있었음
function saveNewAddress() {
  var recvName = document.getElementById('newRecvName').value.trim();
  var recvPhone = document.getElementById('newRecvPhone').value.trim();
  var zipCode = document.getElementById('newZipcode').value.trim();
  var addr1 = document.getElementById('newAddr1').value.trim();
  var addr2 = document.getElementById('newAddr2').value.trim();

  if (!recvName || !recvPhone || !zipCode || !addr1) {
    alert('받는 분 / 연락처 / 주소를 모두 입력해주세요.');
    return;
  }

  var isEdit = editingAddrId !== null;
  var url = isEdit ? '/mypage/address/update' : '/mypage/address/add';

  var formData = new URLSearchParams();
  if (isEdit) formData.set('addrId', editingAddrId);
  formData.set('recvName', recvName);
  formData.set('recvPhone', recvPhone);
  formData.set('zipCode', zipCode);
  formData.set('addr1', addr1);
  formData.set('addr2', addr2);
  if (!isEdit) formData.set('setDefault', 'true');

  //HYJ 26.08.05
  csrfFetch(contextPath + url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: formData.toString()
  })
    .then(function (res) { return res.text(); })
    .then(function (result) {
      if (result === 'OK') {
        if (!isEdit) {
          fillOrderForm(recvName, recvPhone, zipCode, addr1, addr2);
        }
        editingAddrId = null;
        document.getElementById('newAddressForm').style.display = 'none';
        document.getElementById('newRecvName').value = '';
        document.getElementById('newRecvPhone').value = '';
        document.getElementById('newZipcode').value = '';
        document.getElementById('newAddr1').value = '';
        document.getElementById('newAddr2').value = '';
        loadAddressList();
      } else if (result === 'LOGIN_REQUIRED') {
        alert('로그인 세션이 없습니다.');
      } else {
        alert('저장에 실패했습니다.');
      }
    })
    .catch(function () {
      alert('저장 중 오류가 발생했습니다.');
    });
}

//지윤 26.07.30 추가: 배송지 입력 필드 일괄 초기화 (일회성 주소 입력 후 빠르게 지우고 싶을 때)
function resetAddressForm() {
  if (!confirm('입력하신 배송지 정보를 모두 지우시겠습니까?')) return;
  document.getElementById('recvName').value = '';
  document.getElementById('phonePrefix').value = '010';
  document.getElementById('phoneMid').value = '';
  document.getElementById('phoneEnd').value = '';
  document.getElementById('orderZipcode').value = '';
  document.getElementById('orderAddr1').value = '';
  document.getElementById('orderAddr2').value = '';
}
</script>
<%@ include file="/WEB-INF/views/common/footer.jsp" %>
