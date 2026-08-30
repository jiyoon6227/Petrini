<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- 지윤 26.07.08 가격 콤마 표시용 fmt 태그 --%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%-- 지윤 26.07.30 추가: 이미지 URL이 http로 시작하는지 검사용 (fn:startsWith 쓰려고 필요) --%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<c:set var="pageId" value="store" />
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<%-- 지윤 26.07.08 추가: 상세페이지에서 장바구니 담기 성공 시 이 페이지로 리다이렉트되면서 뜨는 팝업 --%>
<c:if test="${cartAddSuccess}">
<script>alert('장바구니에 상품을 담았습니다.');</script>
</c:if>



<style>
  .cart-wrap{max-width:var(--inner-width);margin:32px auto 80px;padding:0 20px;display:grid;grid-template-columns:1fr 340px;gap:28px;align-items:flex-start}
  .cart-section{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);overflow:hidden}
  .cart-section-head{display:flex;align-items:center;gap:12px;padding:16px 20px;border-bottom:1px solid var(--border);background:var(--bg-page)}
  .cart-section-head h2{font-size:16px;font-weight:800;color:var(--text-main);margin:0}
  .cart-count{background:var(--primary);color:#fff;font-size:12px;font-weight:700;padding:2px 8px;border-radius:20px}
  .cart-item{display:flex;gap:16px;padding:18px 20px;border-bottom:1px solid var(--border);align-items:center}
  .cart-item:last-child{border-bottom:none}
  .cart-cb{appearance:none;-webkit-appearance:none;width:18px;height:18px;border:1.5px solid var(--border);border-radius:4px;background:#fff;position:relative;cursor:pointer;flex-shrink:0;transition:border-color .15s}
  .cart-cb:checked{border-color:var(--primary)}
  .cart-cb:checked::after{content:"";position:absolute;left:5px;top:1px;width:5px;height:9px;border:solid var(--primary);border-width:0 2px 2px 0;transform:rotate(45deg)}
  .cart-thumb{width:80px;height:80px;border-radius:var(--radius-sm);object-fit:cover;flex-shrink:0}
  .cart-info{flex:1;min-width:0}
  .cart-brand{font-size:12px;color:var(--text-muted);margin-bottom:3px}
  .cart-name{font-size:14px;font-weight:600;color:var(--text-main);margin-bottom:4px}
  .cart-opt{font-size:12px;color:var(--text-muted)}
  .cart-qty-wrap{display:flex;border:1px solid var(--border);border-radius:var(--radius-sm);overflow:hidden;width:100px;flex-shrink:0}
  .cart-qty-wrap button{width:32px;border:none;background:#f5f5f5;font-size:16px;cursor:pointer;color:var(--text-sub)}
  .cart-qty-wrap button:hover{background:var(--primary-light);color:var(--primary)}
  .cart-qty-wrap input{border:none;border-left:1px solid var(--border);border-right:1px solid var(--border);text-align:center;width:36px;font-size:14px}
  .cart-price{font-size:16px;font-weight:800;color:var(--text-main);text-align:right;flex-shrink:0;min-width:90px}
  .cart-del{background:none;border:none;color:var(--text-muted);cursor:pointer;font-size:18px;line-height:1;padding:4px;flex-shrink:0}
  .cart-del:hover{color:var(--accent)}
  /* 지윤 26.07.30 추가: 사업자별 그룹 헤더/미니요약 (화해 앱 스타일) */
  .cart-seller-head{display:flex;align-items:center;gap:8px;padding:14px 20px;background:var(--bg-page);border-bottom:1px solid var(--border);font-size:14px;font-weight:800;color:var(--text-main)}
  .cart-seller-summary{display:flex;flex-direction:column;gap:6px;padding:14px 20px;background:var(--bg-page);border-bottom:1px solid var(--border);font-size:13px;color:var(--text-sub)}
  .cart-seller-summary .row{display:flex;justify-content:space-between}

  .cart-summary{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);padding:24px;position:sticky;top:20px}
  .cart-summary h3{font-size:16px;font-weight:800;margin:0 0 20px;color:var(--text-main)}
  .summary-row{display:flex;justify-content:space-between;align-items:center;margin-bottom:12px;font-size:14px;color:var(--text-sub)}
  .summary-row.total{font-size:16px;font-weight:800;color:var(--text-main);padding-top:14px;border-top:1px solid var(--border);margin-top:14px}
  .summary-row.total span:last-child{color:var(--primary-dark);font-size:20px}
  .btn-order{width:100%;padding:15px;border:none;border-radius:var(--radius-sm);background:var(--primary);color:#fff;font-size:16px;font-weight:800;cursor:pointer;margin-top:16px;transition:var(--transition)}
  .btn-order:hover{background:var(--primary-dark)}
  .coupon-input{display:flex;gap:8px;margin-top:12px}
  .coupon-input input{flex:1;border:1px solid var(--border);border-radius:var(--radius-sm);padding:8px 12px;font-size:13px;outline:none}
  .coupon-input input:focus{border-color:var(--primary)}
  .coupon-input button{padding:8px 14px;border:1px solid var(--primary);border-radius:var(--radius-sm);background:#fff;color:var(--primary);font-size:13px;font-weight:600;cursor:pointer}
</style>
<div class="cart-wrap">
  <div>
    <div class="cart-section">

   <div class="cart-section-head">
  <input type="checkbox" class="cart-cb" id="checkAll" checked>
  <h2>전체 선택</h2>
  <span class="cart-count">${cartItems.size()}</span>
  <%-- 지윤 26.07.08 추가: 선택삭제(체크된 것만) / 전체삭제(장바구니 통째로) 버튼 --%>
  <div style="margin-left:auto;display:flex;gap:8px;">
    <button type="button" id="btnDeleteSelected" style="background:none;border:1px solid var(--border);border-radius:var(--radius-sm);padding:6px 12px;font-size:13px;color:var(--text-sub);cursor:pointer;">선택 삭제</button>
    <button type="button" id="btnDeleteAll" style="background:none;border:1px solid var(--border);border-radius:var(--radius-sm);padding:6px 12px;font-size:13px;color:var(--text-sub);cursor:pointer;">전체 삭제</button>
  </div>
</div>

      <c:if test="${empty cartItems}">
        <div style="text-align:center;padding:60px 20px;color:var(--text-muted)">장바구니가 비어있습니다.</div>
      </c:if>
      <%-- 지윤 26.07.30 수정: 사업자(BIZ_NO)별로 묶어서 렌더링. 쿼리가 BIZ_NO 순으로 정렬해서 주므로 같은 사업자 상품끼리 붙어있음을 전제로,
           이전/다음 상품의 bizNo와 비교해서 그룹의 시작/끝을 판단함 --%>
      <c:forEach var="item" items="${cartItems}" varStatus="vs">
        <c:if test="${vs.first || item.bizNo != cartItems[vs.index-1].bizNo}">
          <div class="cart-seller-head" data-biz-no="${item.bizNo}"> ${item.bizName}</div>
        </c:if>

        <%-- 지윤 26.07.30 추가: 로컬 업로드 이미지는 /upload/ 접두사 필요, 외부(목업) URL은 그대로 (list.jsp와 동일 패턴) --%>
        <c:set var="cartThumbSrc" value="${fn:startsWith(item.thumbnailUrl,'http') ? item.thumbnailUrl : contextPath.concat('/upload/').concat(item.thumbnailUrl)}"/>
        <div class="cart-item" data-price="${item.price}" data-cart-item-id="${item.cartItemId}" data-biz-no="${item.bizNo}">
          <input type="checkbox" class="cart-cb" checked>
          <img class="cart-thumb" src="${cartThumbSrc}" alt="${item.productName}" onerror="this.src='https://placehold.co/80x80/EAF7F2/2BAB82?text=IMG'">
          <div class="cart-info">
            <div class="cart-brand">${item.brandName}</div>
            <div class="cart-name">${item.productName}</div>
            <div class="cart-opt">
              <c:choose>
                <c:when test="${not empty item.optionColor && item.optionColor != '기본'}">옵션: ${item.optionColor} / ${item.optionSize}</c:when>
                <c:when test="${not empty item.optionSize}">옵션: ${item.optionSize}</c:when>
                <c:otherwise>단일 옵션</c:otherwise>
              </c:choose>
            </div>
          </div>
          <div style="flex-shrink:0">
            <div class="cart-qty-wrap">
              <button >−</button>
              <!--HYJ 26.08.16 · 2026/08/13 장우철 — id 중복 제거, 항목별 data-stock 사용-->
              <input type="number" class="cart-qty-input" min="1" value="${item.qty}" data-stock="${item.stockQty}" data-option-id="${item.optionId}" readonly>
              <button >+</button>
            </div>
            <div class="stockWarning" style="display:none; color:var(--accent); font-size:12px; margin-top:6px;">재고가 부족합니다.</div>
            <div class="qtyLimitMsg" style="display:none; color:var(--accent); font-size:12px; margin-top:6px;"></div>
          </div>
          <div class="cart-price"><fmt:formatNumber value="${item.price * item.qty}" pattern="#,###"/>원</div>
          <button class="cart-del">×</button>
        </div>

        <c:if test="${vs.last || item.bizNo != cartItems[vs.index+1].bizNo}">
          <div class="cart-seller-summary" data-biz-no="${item.bizNo}">
            <div class="row"><span>상품금액</span><span id="groupProduct-${item.bizNo}">0원</span></div>
            <div class="row"><span>배송비</span><span id="groupDelivery-${item.bizNo}">무료</span></div>
          </div>
        </c:if>
      </c:forEach>

    </div>
  </div>
  <div class="cart-summary">
    <h3>주문 요약</h3>
    <div class="summary-row"><span>상품 금액</span><span id="sumProduct">98,900원</span></div>
    <%-- 지윤 26.07.09 배송비 무료 고정 텍스트 -> 5만원 기준 실시간 계산으로 변경 --%>
    <div class="summary-row"><span>배송비</span><span id="sumDelivery" style="color:var(--primary);font-weight:700">무료</span></div>
    <div class="summary-row total"><span>총 결제금액</span><span id="sumTotal">98,900원</span></div>
    <button class="btn-order" id="btnOrder">주문하기 (3개)</button>
  </div>
</div>
<script>
  function won(n){ return n.toLocaleString('ko-KR') + '원'; }

  //지윤 26.07.30 추가: 삭제 후 남은 상품 없는 사업자 그룹의 헤더/미니요약을 정리
  function cleanupEmptyGroups(){
    var remainingBizNos = new Set(
      Array.from(document.querySelectorAll('.cart-item')).map(function(item){ return item.dataset.bizNo; })
    );
    document.querySelectorAll('.cart-seller-head, .cart-seller-summary').forEach(function(el){
      if (!remainingBizNos.has(el.dataset.bizNo)) {
        el.remove();
      }
    });
  }

  //지윤 26.07.09 배송비 계산 추가 (5만원 이상 무료, 미만은 3,000원)
  //지윤 26.07.30 수정: 전체 합산 -> 사업자(bizNo)별로 따로 계산 후 합산. 그룹별 소계 DOM도 같이 갱신
  function recalc(){
    var groups = {}; // bizNo -> { total, count }
    var total = 0, count = 0;

    document.querySelectorAll('.cart-item').forEach(function(item){
      var checked = item.querySelector('.cart-cb').checked;
      var unitPrice = parseInt(item.dataset.price, 10);
      var qty = parseInt(item.querySelector('.cart-qty-wrap input').value, 10);
      var lineTotal = unitPrice * qty;
      item.querySelector('.cart-price').textContent = won(lineTotal);

      var bizNo = item.dataset.bizNo;
      if (!groups[bizNo]) groups[bizNo] = { total: 0, count: 0 };

      if(checked){
        groups[bizNo].total += lineTotal;
        groups[bizNo].count++;
        total += lineTotal;
        count++;
      }
    });

    var deliveryTotal = 0;
    Object.keys(groups).forEach(function(bizNo){
      var g = groups[bizNo];
      var fee = (g.total === 0 || g.total >= 50000) ? 0 : 3000;
      deliveryTotal += fee;
      var pEl = document.getElementById('groupProduct-' + bizNo);
      var dEl = document.getElementById('groupDelivery-' + bizNo);
      if (pEl) pEl.textContent = won(g.total);
      if (dEl) dEl.textContent = fee === 0 ? '무료' : won(fee);
    });

    document.getElementById('sumProduct').textContent = won(total);
    document.getElementById('sumDelivery').textContent = deliveryTotal === 0 ? '무료' : won(deliveryTotal);
    document.getElementById('sumTotal').textContent = won(total + deliveryTotal);
    var btn = document.getElementById('btnOrder');
    btn.textContent = '주문하기 (' + count + '개)';
    btn.disabled = count === 0;
  }

  document.querySelectorAll('.cart-qty-wrap button').forEach(function(btn){
    btn.addEventListener('click', function(){
      var item = this.closest('.cart-item');
      var input = this.parentElement.querySelector('input');
      var val = parseInt(input.value, 10);
      var isPlus = this.textContent.trim() === '+';
      val = isPlus ? val + 1 : Math.max(1, val - 1);
      //HYJ 26.08.16 재고확인 추가 · 2026/08/13 장우철 — 해당 줄 input 기준으로 재고 제한
      val = applyQtyLimit(val, input);
      input.value = val;
      recalc();
      //HYJ 26.08.05
      csrfFetch('${contextPath}/store/cart/updateQty', {
        method: 'POST',
        headers: {'Content-Type':'application/x-www-form-urlencoded'},
        body: 'cartItemId=' + item.dataset.cartItemId + '&qty=' + val
      });
    });
  });

  document.querySelectorAll('.cart-cb').forEach(function(cb){
    cb.addEventListener('change', function(){
      if(this.closest('.cart-section-head')){
        var allChecked = this.checked;
        document.querySelectorAll('.cart-item .cart-cb').forEach(function(c){ c.checked = allChecked; });
      }
      recalc();
    });
  });

  document.querySelectorAll('.cart-del').forEach(function(btn){
    btn.addEventListener('click', function(){
      var item = this.closest('.cart-item');
      var cartItemId = item.dataset.cartItemId;
      item.remove();
      cleanupEmptyGroups();
      recalc();
      //HYJ 26.08.05
      csrfFetch('${contextPath}/store/cart/delete', {
        method: 'POST',
        headers: {'Content-Type':'application/x-www-form-urlencoded'},
        body: 'cartItemId=' + cartItemId
      }).then(function(){ refreshCartCount(); });
    });
  });

  //지윤 26.07.08 추가: 선택삭제(체크된 것만) / 전체삭제(장바구니 통째로) 버튼
  document.getElementById('btnDeleteSelected').addEventListener('click', function(){
    var checkedItems = Array.from(document.querySelectorAll('.cart-item')).filter(function(item){
      return item.querySelector('.cart-cb').checked;
    });
    if (checkedItems.length === 0) {
      alert('삭제할 상품을 선택해주세요.');
      return;
    }
    if (!confirm(checkedItems.length + '개 상품을 삭제하시겠습니까?')) return;

    var params = new URLSearchParams();
    checkedItems.forEach(function(item){
      params.append('cartItemIds', item.dataset.cartItemId);
    });

    //HYJ 26.08.05
   csrfFetch('${contextPath}/store/cart/deleteAll', {
      method: 'POST',
      headers: {'Content-Type':'application/x-www-form-urlencoded'},
      body: params.toString()
    }).then(function(res){
      if (res.ok) {
        checkedItems.forEach(function(item){ item.remove(); });
        cleanupEmptyGroups();
        recalc();
      } else {
        alert('삭제에 실패했습니다.');
      }
    });
  });

  //지윤 26.07.08 추가: 전체삭제 (체크 여부 상관없이 장바구니에 있는 항목 전부 삭제)
  document.getElementById('btnDeleteAll').addEventListener('click', function(){
    var allItems = Array.from(document.querySelectorAll('.cart-item'));
    if (allItems.length === 0) {
      alert('장바구니가 비어있습니다.');
      return;
    }
    if (!confirm('장바구니를 전체 삭제하시겠습니까?')) return;

    var params = new URLSearchParams();
    allItems.forEach(function(item){
      params.append('cartItemIds', item.dataset.cartItemId);
    });
    
    //HYJ 26.08.05 · 2026/08/07 장우철 CSRF (csrfFetch)
    csrfFetch('${contextPath}/store/cart/deleteAll', {
      method: 'POST',
      headers: {'Content-Type':'application/x-www-form-urlencoded'},
      body: params.toString()
    }).then(function(res){
      if (res.ok) {
        allItems.forEach(function(item){ item.remove(); });
        cleanupEmptyGroups();
        recalc();
      } else {
        alert('삭제에 실패했습니다.');
      }
    });
  });

  //지윤 26.07.09 추가: 주문하기 클릭 시 체크된 장바구니 항목ID들을 파라미터로 넘김
  document.getElementById('btnOrder').addEventListener('click', function () {
    var checkedIds = Array.from(document.querySelectorAll('.cart-item'))
      .filter(function(item){ return item.querySelector('.cart-cb').checked; })
      .map(function(item){ return item.dataset.cartItemId; });
    if (checkedIds.length === 0) {
      alert('주문할 상품을 선택해주세요.');
      return;
    }
    location.href = '${contextPath}/store/order?cartItemIds=' + checkedIds.join(',');
  });

  recalc();
  //HYJ 26.08.13 재고확인 메시지 초기화
  hideQtyMessages();

  //HYJ 26.08.16 재고확인 · 2026/08/13 장우철 — getElementById('qty')가 첫 상품만 보던 문제 수정
  function applyQtyLimit(v, input) {
    var item = input.closest('.cart-item');
    var warn = item.querySelector('.stockWarning');
    var limitMsg = item.querySelector('.qtyLimitMsg');
    hideQtyMessages(warn, limitMsg);
    var stock = parseInt(input.dataset.stock, 10) || 0;

    if (v < 1) {
      v = 1;
      limitMsg.textContent = '1개 이상부터 구매할 수 있는 상품입니다.';
      limitMsg.style.display = 'block';
    } else if (v > stock) {
      v = stock;
      warn.textContent = '재고 ' + stock + '개까지만 구매할 수 있습니다.';
      warn.style.display = 'block';
    }
    return v;
  }

  function hideQtyMessages(warn, limitMsg) {
    if (warn) warn.style.display = 'none';
    if (limitMsg) limitMsg.style.display = 'none';
  }
</script>
<%@ include file="/WEB-INF/views/common/footer.jsp" %>
