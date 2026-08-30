<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="mypage" />
<c:set var="sec" value="dashboard" />

<%@ include file="/WEB-INF/views/common/header.jsp" %>
<link rel="stylesheet" href="${contextPath}/resources/css/mypage.css">

<div class="mypage-wrap">
<%@ include file="/WEB-INF/views/mypage/sidebar.jsp" %>
<div class="mypage-content">

<%-- ── 마이홈 ── --%>
<div class="mp-section active">
    <h2 class="mp-title">마이홈</h2>
    <%-- 2026/07/08 장우철 — 인사말: 세션 memberInfo.memberName (로그인 시 TB_MEMBER) --%>
    <p class="mp-desc">안녕하세요, <strong>${memberInfo.memberName}</strong>님 반갑습니다.</p>
    <div class="dash-cards">
        <%-- 2026/07/08 장우철 --%>
        <div class="dash-card">
            <div class="dc-label">보유 포인트</div>
            <div class="dc-value"><fmt:formatNumber value="${memberInfo.pointBalance != null ? memberInfo.pointBalance : 0}" pattern="#,###" /> <span class="dc-unit">P</span></div>
        </div>
        <%-- [변경 전] 보유 포인트 더미
        <div class="dc-value">1,200 <span class="dc-unit">P</span></div>
        --%>
        <div class="dash-card">
            <div class="dc-label">이용중인 쿠폰</div>
            <div class="dc-value">${couponCount != null ? couponCount : 0} <span class="dc-unit">장</span></div>
        </div>
        <%-- [변경 전] 이용중인 쿠폰 더미
        <div class="dc-value">2 <span class="dc-unit">장</span></div>
        --%>
        <div class="dash-card">
            <div class="dc-label">관심상품</div>
            <div class="dc-value">${wishlistCount != null ? wishlistCount : 0} <span class="dc-unit">개</span></div>
        </div>
        <%-- [변경 전] 관심상품 더미
        <div class="dc-value">5 <span class="dc-unit">개</span></div>
        --%>
    </div>
    <div class="dash-shortcuts">
        <a href="${contextPath}/mypage/orders" class="dash-sc">
            <svg viewBox="0 0 24 24"><path d="M6 2L3 6v14a2 2 0 002 2h14a2 2 0 002-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 01-8 0"/></svg>
            주문내역
        </a>
        <a href="${contextPath}/mypage/reserve" class="dash-sc">
            <svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
            예약내역
        </a>
        <a href="${contextPath}/mypage/pets" class="dash-sc">
            <svg viewBox="0 0 24 24"><circle cx="4.5" cy="9.5" r="2"/><circle cx="9" cy="5.5" r="2"/><circle cx="15" cy="5.5" r="2"/><circle cx="19.5" cy="9.5" r="2"/><path d="M12 13c-3.87 0-7 1.79-7 4v1h14v-1c0-2.21-3.13-4-7-4z"/></svg>
            반려동물
        </a>
        <a href="${contextPath}/mypage/notifications" class="dash-sc">
            <svg viewBox="0 0 24 24"><path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 01-3.46 0"/></svg>
            알림함
        </a>
    </div>
</div>



</div><%-- /mypage-content --%>
</div><%-- /mypage-wrap --%>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
