<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="store" />
<%@ include file="/WEB-INF/views/common/header.jsp" %>
<style>
.complete-wrap{max-width:560px;margin:60px auto 80px;padding:0 20px;text-align:center}
.complete-icon{width:80px;height:80px;border-radius:50%;background:var(--primary-light);display:flex;align-items:center;justify-content:center;margin:0 auto 24px}
.complete-icon svg{width:40px;height:40px;stroke:var(--primary);fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}
.complete-title{font-size:24px;font-weight:800;color:var(--text-main);margin-bottom:8px}
.complete-desc{font-size:15px;color:var(--text-muted);margin-bottom:32px}
.complete-card{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);padding:24px;text-align:left;margin-bottom:24px}
.complete-card h3{font-size:14px;font-weight:700;color:var(--text-main);margin:0 0 16px;padding-bottom:12px;border-bottom:1px solid var(--border)}
.complete-row{display:flex;justify-content:space-between;font-size:14px;margin-bottom:10px}
.complete-row:last-child{margin-bottom:0}
.complete-row span:first-child{color:var(--text-muted)}
.complete-row span:last-child{color:var(--text-main);font-weight:600}
.complete-btns{display:flex;gap:12px}
.btn-complete-my{flex:1;padding:13px;border:2px solid var(--primary);border-radius:var(--radius-sm);background:#fff;color:var(--primary);font-size:15px;font-weight:700;cursor:pointer}
.btn-complete-store{flex:1;padding:13px;border:none;border-radius:var(--radius-sm);background:var(--primary);color:#fff;font-size:15px;font-weight:700;cursor:pointer}
</style>
<div class="complete-wrap">
<%-- 지윤 26.07.13 수정: 하드코딩 -> 세션 정보로 실제 저장된 orderNo/orderItems/payAmount 표시. 세션 만료 시 안내문구로 대체 --%>
<c:choose>
  <c:when test="${not empty noOrderData}">
    <%-- 지윤 26.07.23 추가: confirmError 있으면(승인 실패) 그 이유를, 없으면(세션만료 등) 기존 문구를 보여줌 --%>
    <c:choose>
      <c:when test="${not empty confirmError}">
        <div class="complete-title">결제 승인에 실패했습니다.</div>
        <div class="complete-desc" style="color:#E2445C;">${confirmError}</div>
      </c:when>
      <c:otherwise>
        <div class="complete-title">주문 정보를 찾을 수 없습니다.</div>
        <div class="complete-desc">이 페이지는 결제 직후에만 확인할 수 있어요.<br>주문 내역은 마이페이지에서 확인해주세요.</div>
      </c:otherwise>
    </c:choose>
    <div class="complete-btns">
      <button class="btn-complete-store" onclick="location.href='${contextPath}/store'">쇼핑 계속하기</button>
    </div>
  </c:when>
  <c:otherwise>
    <div class="complete-icon"><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg></div>
    <div class="complete-title">주문이 완료되었습니다!</div>
    <div class="complete-desc">주문번호 <strong>#${orderNo}</strong><br>주문 내역은 마이페이지에서 확인하세요.</div>
    <div class="complete-card">
      <h3>주문 정보</h3>
      <div class="complete-row"><span>주문번호</span><span>#${orderNo}</span></div>
      <div class="complete-row"><span>주문 상품</span>
        <span>
          <c:out value="${orderItems[0].productName}"/>
          <c:if test="${fn:length(orderItems) > 1}"> 외 ${fn:length(orderItems) - 1}건</c:if>
        </span>
      </div>
      <div class="complete-row"><span>결제 금액</span><span style="color:var(--primary-dark);font-size:16px;font-weight:800"><fmt:formatNumber value="${payAmount}" pattern="#,###"/>원</span></div>
      <div class="complete-row"><span>결제 수단</span><span>${payMethodLabel}</span></div>
    </div>
    <div class="complete-btns">
      <button class="btn-complete-my" onclick="location.href='${contextPath}/mypage/orders'">주문 내역 보기</button>
      <button class="btn-complete-store" onclick="location.href='${contextPath}/store'">쇼핑 계속하기</button>
    </div>
  </c:otherwise>
</c:choose>
</div>
<%@ include file="/WEB-INF/views/common/footer.jsp" %>