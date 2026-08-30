<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- 사업자센터 반려동물 숙소 사이드바 — bizPage 변수로 active 제어 --%>
<aside class="biz-sidebar">
  <div class="biz-sidebar-profile">
    <div class="biz-sidebar-biz-icon stay">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
        <path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z"/>
        <path d="M9 22V12h6v10"/>
      </svg>
    </div>
    <div class="biz-sidebar-bizname">${memberInfo.memberName}</div>
    <div class="biz-sidebar-biztype">반려동물 숙소</div>
  </div>
  <nav class="biz-nav">
    <a href="${contextPath}/biz/stay" class="biz-nav-link ${bizPage eq 'dashboard' ? 'active' : ''}">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
        <rect x="3" y="3" width="7" height="7" rx="1"/>
        <rect x="14" y="3" width="7" height="7" rx="1"/>
        <rect x="3" y="14" width="7" height="7" rx="1"/>
        <rect x="14" y="14" width="7" height="7" rx="1"/>
      </svg>
      홈
    </a>
    <%--사업자(숙박) 숙소관리 왼쪽 메뉴사이드바에 추가(지윤)--%>
    <div class="biz-nav-group">숙소 관리</div>
    <a href="${contextPath}/biz/stay/profile" class="biz-nav-link ${bizPage eq 'profile' ? 'active' : ''}">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
        <path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z"/>
        <path d="M9 22V12h6v10"/>
      </svg>
      숙소 관리
    </a>
    <a href="${contextPath}/biz/stay/rooms" class="biz-nav-link ${bizPage eq 'rooms' ? 'active' : ''}">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
      <rect x="2" y="3" width="20" height="14" rx="2"/><path d="M8 21h8M12 17v4"/></svg>
      객실 관리
    </a>
    <a href="${contextPath}/biz/stay/reserve" class="biz-nav-link ${bizPage eq 'reserve' ? 'active' : ''}">

      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
        <rect x="3" y="4" width="18" height="18" rx="2"/>
        <line x1="3" y1="10" x2="21" y2="10"/>
        <line x1="8" y1="2" x2="8" y2="6"/>
        <line x1="16" y1="2" x2="16" y2="6"/>
      </svg>
      예약 관리<c:if test="${pendingReserveCount > 0}"><span class="biz-nav-badge">${pendingReserveCount}</span></c:if>
    </a>
    <%-- 2026-08-11 박유정 — 환불 신청 메뉴·대기 배지 (승인은 관리자) --%>
    <a href="${contextPath}/biz/stay/refunds" class="biz-nav-link ${bizPage eq 'refunds' ? 'active' : ''}">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
        <path d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"/>
      </svg>
      환불 신청<c:if test="${not empty stayRefundRequestCount && stayRefundRequestCount > 0}"><span class="biz-nav-badge">${stayRefundRequestCount}</span></c:if>
    </a>
    <a href="${contextPath}/biz/stay/calendar" class="biz-nav-link ${bizPage eq 'calendar' ? 'active' : ''}">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
        <rect x="3" y="4" width="18" height="18" rx="2"/><line x1="3" y1="10" x2="21" y2="10"/>
      </svg>
      예약 캘린더<c:if test="${todayConfirmedCount > 0}"><span class="biz-nav-badge">${todayConfirmedCount}</span></c:if>
    </a>

    <div class="biz-nav-group">운영 관리</div>
    
    <a href="${contextPath}/biz/stay/coupon" class="biz-nav-link ${bizPage eq 'coupon' ? 'active' : ''}">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
        <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/>
      </svg>
      쿠폰 신청
    </a>

    <a href="${contextPath}/biz/stay/reviews" class="biz-nav-link ${bizPage eq 'reviews' ? 'active' : ''}">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
        <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/>
      </svg>
      리뷰 관리
    </a>
    
    <%--HYJ 26.07.31 교체 <a href="${contextPath}/biz/stay/contract" class="biz-nav-link ${bizPage eq 'contract' ? 'active' : ''}">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
        <line x1="12" y1="1" x2="12" y2="23"/>
        <path d="M17 5H9.5a3.5 3.5 0 000 7h5a3.5 3.5 0 010 7H6"/>
      </svg>
      계약 관리
    </a> --%>
    <a href="${contextPath}/biz/stay/banner" class="biz-nav-link ${bizPage eq 'banner' ? 'active' : ''}">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"
           stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
          <rect x="2" y="3" width="20" height="14" rx="2"/>
          <line x1="8" y1="21" x2="16" y2="21"/>
          <line x1="12" y1="17" x2="12" y2="21"/>
      </svg>
      배너 광고
    </a>
    <a href="${contextPath}/biz/stay/settlement" class="biz-nav-link ${bizPage eq 'settlement' ? 'active' : ''}">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
        <line x1="12" y1="1" x2="12" y2="23"/>
        <path d="M17 5H9.5a3.5 3.5 0 000 7h5a3.5 3.5 0 010 7H6"/>
      </svg>
      정산 내역
    </a>

    <a href="${contextPath}/biz/stay/info" class="biz-nav-link ${bizPage eq 'info' ? 'active' : ''}">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
        <circle cx="12" cy="12" r="10"/>
        <line x1="12" y1="8" x2="12" y2="12"/>
        <line x1="12" y1="16" x2="12.01" y2="16"/>
      </svg>
      사업자 정보
    </a>
  </nav>
</aside>