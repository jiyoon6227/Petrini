<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
  역할: 이벤트/혜택 메인 — 받을 수 있는 쿠폰 목록 + 발급 (event/list)

  [model]
  - availableCoupons : 받을 수 있는 쿠폰 (APPROVED + ACTIVE + 기간 내)
    └ alreadyClaimed : 로그인 사용자가 이미 받았으면 true
  2026-08-13 박유정 — 소진(EXHAUSTED) 쿠폰 「쿠폰 소진」 표시, 다운 버튼 제거
--%>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="coupon" />
<%@ include file="/WEB-INF/views/common/header.jsp" %>
<style>
  .ev-hero{background:linear-gradient(135deg,#92400E 0%,#F59E0B 60%,#FCD34D 100%);padding:48px 0;color:#fff;text-align:center}
  .ev-hero-inner{max-width:var(--inner-width);margin:0 auto;padding:0 20px}
  .ev-hero-badge{display:inline-block;font-size:13px;font-weight:700;background:rgba(255,255,255,.22);padding:5px 16px;border-radius:50px;margin-bottom:14px}
  .ev-hero h1{font-size:30px;font-weight:800;margin:0 0 8px}
  .ev-hero p{font-size:14px;opacity:.9;margin:0}

  .ev-wrap{max-width:860px;margin:32px auto 80px;padding:0 20px}

  .ev-count{font-size:14px;color:var(--text-muted);margin-bottom:18px}
  .ev-count strong{color:#D97706;font-weight:800}

  /* 지윤 26.08.07: 업종별 필터 탭 */
  .cp-tabs{display:flex;gap:8px;margin-bottom:18px}
  .cp-tab{padding:8px 18px;border:1px solid var(--border);border-radius:50px;background:var(--bg-card);color:var(--text-muted);font-size:13px;font-weight:700;cursor:pointer}
  .cp-tab:hover{border-color:#F59E0B}
  .cp-tab.active{background:#F59E0B;border-color:#F59E0B;color:#fff}

  /* 쿠폰 티켓 */
  .cp-ticket{display:flex;background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);overflow:hidden;margin-bottom:14px;transition:box-shadow .2s}
  .cp-ticket:hover{box-shadow:var(--shadow-sm)}
  .cp-ticket-left{width:120px;flex-shrink:0;background:#FFFBEB;display:flex;flex-direction:column;align-items:center;justify-content:center;padding:16px;position:relative;border-right:2px dashed #FDE68A}
  .cp-ticket-left::before,.cp-ticket-left::after{content:"";position:absolute;width:18px;height:18px;background:var(--bg-body,#F7F9F7);border-radius:50%;right:-10px}
  .cp-ticket-left::before{top:-9px}
  .cp-ticket-left::after{bottom:-9px}
  .cp-ticket-pct{font-size:22px;font-weight:800;color:#B45309;line-height:1.1}
  .cp-ticket-unit{font-size:12px;color:#B45309;font-weight:700}
  .cp-ticket-body{flex:1;padding:16px 20px;display:flex;justify-content:space-between;align-items:center;gap:14px}
  .cp-ticket-info{flex:1;min-width:0}
  .cp-ticket-name{font-size:14px;font-weight:700;color:var(--text-main);margin-bottom:4px}
  .cp-ticket-cond{font-size:12px;color:var(--text-muted);margin-bottom:2px}
  .cp-ticket-date{font-size:12px;color:var(--text-muted)}

/* 지윤 26.08.06: 적용 상품·병원·숙소 이동 링크 */
.cp-ticket-target{
  display:inline-block;
  margin-top:7px;
  color:#0D9F75;
  font-size:12px;
  font-weight:700;
  text-decoration:none;
}

.cp-ticket-target:hover{
  text-decoration:underline;
}

  .cp-ticket-btn{padding:9px 18px;border:none;border-radius:var(--radius-sm);background:#F59E0B;color:#fff;font-size:13px;font-weight:700;cursor:pointer;white-space:nowrap;flex-shrink:0}
  .cp-ticket-btn:hover{background:#D97706}
  .cp-ticket-btn.claimed,
  .cp-ticket-btn.exhausted{background:#F5F5F5;color:#aaa;cursor:not-allowed}
  .cp-ticket-btn.exhausted:hover,
  .cp-ticket-btn.claimed:hover{background:#F5F5F5}
  .cp-ticket.ended{opacity:.5}
  .cp-ticket-badge{font-size:11px;font-weight:700;padding:2px 8px;border-radius:12px;margin-left:8px}
  .cp-ticket-badge.expired{background:#FEE2E2;color:#DC2626}
  .cp-ticket-badge.exhausted{background:#F1F3F7;color:#999}

  .ev-empty{text-align:center;padding:60px 0;color:var(--text-muted);font-size:14px}

  @media(max-width:640px){
    .cp-ticket{flex-direction:column}
    .cp-ticket-left{width:100%;flex-direction:row;gap:8px;padding:12px 16px;border-right:none;border-bottom:2px dashed #FDE68A}
    .cp-ticket-left::before,.cp-ticket-left::after{display:none}
  }
</style>

<div class="ev-hero">
  <div class="ev-hero-inner">
    <span class="ev-hero-badge">PetCare 혜택</span>
    <h1>지금 받을 수 있는 쿠폰</h1>
    <p>사업자가 제공하는 할인 쿠폰을 받고, 쇼핑·예약 시 사용하세요</p>
  </div>
</div>

<div class="ev-wrap">

  <c:choose>
    <c:when test="${empty availableCoupons}">
      <div class="ev-empty">현재 받을 수 있는 쿠폰이 없습니다.</div>
    </c:when>
    <c:otherwise>
      <%-- 지윤 26.08.07: 업종별 필터 탭 (클라이언트 필터, 재조회 없음) --%>
      <div class="cp-tabs">
        <button type="button" class="cp-tab active" data-filter="ALL">전체</button>
        <button type="button" class="cp-tab" data-filter="HOSPITAL">병원</button>
        <button type="button" class="cp-tab" data-filter="STAY">숙소</button>
        <button type="button" class="cp-tab" data-filter="STORE">쇼핑몰</button>
      </div>

      <%-- 건수 표시 --%>
      <c:set var="claimableCount" value="0" />
      <c:forEach var="cpn" items="${availableCoupons}">
        <c:if test="${!cpn.alreadyClaimed}"><c:set var="claimableCount" value="${claimableCount + 1}" /></c:if>
      </c:forEach>
      <div class="ev-count">총 <strong id="evCountNum">${availableCoupons.size()}장</strong>의 쿠폰이 있습니다.</div>

      <%-- 지윤 26.08.07: 필터 결과 0건일 때 표시 --%>
      <div class="ev-empty" id="evFilterEmpty" style="display:none">해당 카테고리에 쿠폰이 없습니다.</div>

      <c:forEach var="cpn" items="${availableCoupons}">
        <%--
          지윤 26.08.10 수정
          - 조기마감(INACTIVE), 기간만료는 쿼리 단계에서 이미 제외되어 여기 안 옴
          2026/08/12 장우철 — 소진 쿠폰은 받기 불가
          2026-08-13 박유정 — isExhausted 시 「쿠폰 소진」 표시, 받기 버튼 제거
        --%>
        <c:set var="isExhausted" value="${cpn.statusCd eq 'EXHAUSTED'
                                          || cpn.issuedQty >= cpn.totalQty
                                          || (cpn.totalBudget > 0 && cpn.issuedBudget >= cpn.totalBudget)}" />

        <div class="cp-ticket" data-biz-type="${cpn.bizType}">
          <div class="cp-ticket-left">
            <c:choose>
              <c:when test="${cpn.couponType eq 'FIXED'}">
                <span class="cp-ticket-pct"><fmt:formatNumber value="${cpn.discountValue}" type="number"/></span>
                <span class="cp-ticket-unit">원 할인</span>
              </c:when>
              <c:when test="${cpn.couponType eq 'RATE'}">
                <span class="cp-ticket-pct">${cpn.discountValue}%</span>
                <span class="cp-ticket-unit">할인</span>
              </c:when>
            </c:choose>
          </div>
          <div class="cp-ticket-body">
            <div class="cp-ticket-info">
              <div class="cp-ticket-name">
                ${cpn.couponName}
                <c:if test="${isExhausted}"><span class="cp-ticket-badge exhausted">소진</span></c:if>
              </div>
              <div class="cp-ticket-cond">
                <c:if test="${cpn.minOrderAmt > 0}"><fmt:formatNumber value="${cpn.minOrderAmt}" type="number"/>원 이상 구매 시</c:if>
                <c:if test="${not empty cpn.bizName}"> · ${cpn.bizName}</c:if>
              </div>
              <div class="cp-ticket-date">
  ${cpn.useEndDate.substring(0,4)}.${cpn.useEndDate.substring(4,6)}.${cpn.useEndDate.substring(6,8)}까지
</div>

<%--
  지윤 26.08.06
  쿠폰 발급 사업자 업종에 따라 적용 대상 이동
--%>
<c:choose>

  <%-- 쇼핑몰 쿠폰: 해당 사업자의 상품 목록 --%>
  <c:when test="${cpn.bizType eq 'STORE'}">
    <a class="cp-ticket-target"
       href="${contextPath}/coupon/products?couponId=${cpn.couponId}">
      적용 상품 &gt;
    </a>
  </c:when>

  <%-- 병원 쿠폰: 해당 병원 상세 페이지 --%>
  <c:when test="${cpn.bizType eq 'HOSPITAL'
                  && not empty cpn.targetId}">
    <a class="cp-ticket-target"
       href="${contextPath}/hospital/detail?id=${cpn.targetId}">
      적용 병원 &gt;
    </a>
  </c:when>

  <%-- 숙소 쿠폰: 해당 숙소 상세 페이지 --%>
  <c:when test="${cpn.bizType eq 'STAY'
                  && not empty cpn.targetId}">
    <a class="cp-ticket-target"
       href="${contextPath}/stay/detail?id=${cpn.targetId}">
      적용 숙소 &gt;
    </a>
  </c:when>

</c:choose>
            </div>
            <c:choose>
              <c:when test="${cpn.alreadyClaimed}">
                <button class="cp-ticket-btn claimed" disabled>받기 완료</button>
              </c:when>
              <%-- 2026-08-13 박유정 — 소진 쿠폰: 받기 버튼 없음 · 문구는 기존 「받기」 유지 --%>
              <c:when test="${isExhausted}">
                <span class="cp-ticket-btn claimed">쿠폰 소진</span>
              </c:when>
              <c:otherwise>
                <button class="cp-ticket-btn" onclick="claimCoupon(this, ${cpn.couponId})">받기</button>
              </c:otherwise>
            </c:choose>
          </div>
        </div>
      </c:forEach>
    </c:otherwise>
  </c:choose>

</div>

<script>
// 지윤 26.08.07: 업종별 쿠폰 필터 (전체/병원/숙소/쇼핑몰)
document.querySelectorAll('.cp-tab').forEach(function(tab) {
    tab.addEventListener('click', function() {
        document.querySelectorAll('.cp-tab').forEach(function(t) { t.classList.remove('active'); });
        tab.classList.add('active');

        var filter = tab.dataset.filter;
        var visibleCount = 0;

        document.querySelectorAll('.cp-ticket').forEach(function(ticket) {
            var match = (filter === 'ALL' || ticket.dataset.bizType === filter);
            ticket.style.display = match ? '' : 'none';
            if (match) visibleCount++;
        });

        var countEl = document.getElementById('evCountNum');
        if (countEl) countEl.textContent = visibleCount + '장';

        var emptyEl = document.getElementById('evFilterEmpty');
        if (emptyEl) emptyEl.style.display = (visibleCount === 0) ? '' : 'none';
    });
});

function claimCoupon(btn, couponId) {
    if (btn.disabled) return;

    var xhr = new XMLHttpRequest();
    xhr.open('POST', '${contextPath}/coupon/claim');
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    
    //HYJ 26.08.05
    xhr.setRequestHeader('X-CSRF-TOKEN', document.querySelector('meta[name="_csrf"]').getAttribute('content'));									
	
    xhr.onload = function() {
        if (xhr.status === 200) {
            var res = JSON.parse(xhr.responseText);
            if (res.ok) {
                btn.textContent = '받기 완료';
                btn.disabled = true;
                btn.classList.add('claimed');
                alert(res.message);
            } else {
                if (res.message === '로그인이 필요합니다.') {
                    if (confirm('로그인이 필요합니다. 로그인 페이지로 이동하시겠습니까?')) {
                        location.href = '${contextPath}/login';
                    }
                } else {
                    // 2026/08/12 장우철 — 소진 응답 시 버튼도 즉시 비활성화
                    if (res.message && res.message.indexOf('소진') >= 0) {
                        btn.textContent = '소진됨';
                        btn.disabled = true;
                        btn.classList.add('exhausted');
                        btn.onclick = null;
                    }
                    alert(res.message);
                }
            }
        }
    };
    xhr.send('couponId=' + couponId);
}
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
