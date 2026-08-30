<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- 사업자센터 반려동물 쇼핑몰 사이드바 — bizPage 변수로 active 제어 --%>
<aside class="biz-sidebar">
  <div class="biz-sidebar-profile">
    <div class="biz-sidebar-biz-icon store">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M6 2L3 6v14a2 2 0 002 2h14a2 2 0 002-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 01-8 0"/></svg>
    </div>
    <div class="biz-sidebar-bizname">${memberInfo.memberName}</div>
    <div class="biz-sidebar-biztype">반려동물 쇼핑몰</div>
  </div>
  <nav class="biz-nav">
    <a href="${contextPath}/biz/store" class="biz-nav-link ${bizPage eq 'dashboard' ? 'active' : ''}">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
        <rect x="3" y="3" width="7" height="7" rx="1"/>
        <rect x="14" y="3" width="7" height="7" rx="1"/>
        <rect x="3" y="14" width="7" height="7" rx="1"/>
        <rect x="14" y="14" width="7" height="7" rx="1"/>
      </svg>
      홈
    </a>
    <div class="biz-nav-group">상품 관리</div>
    <a href="${contextPath}/biz/store/products" class="biz-nav-link ${bizPage eq 'products' ? 'active' : ''}">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
        <path d="M6 2L3 6v14a2 2 0 002 2h14a2 2 0 002-2V6l-3-4z"/>
        <line x1="3" y1="6" x2="21" y2="6"/>
      </svg>
      상품 관리
    </a>
    
    <div class="biz-nav-group">주문 관리</div>
    <a href="${contextPath}/biz/store/orders" class="biz-nav-link ${bizPage eq 'orders' ? 'active' : ''}">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
        <path d="M9 17H5a2 2 0 00-2 2v0a2 2 0 002 2h14"/>
        <path d="M12 3v14"/>
        <path d="M8 7l4-4 4 4"/>
      </svg>
      주문 관리<c:if test="${not empty paidOrderCount && paidOrderCount > 0}"><span class="biz-nav-badge">${paidOrderCount}</span></c:if>
    </a>
    <%-- 2026/08/04 장우철 — 환불신청 처리 페이지 --%>
    <a href="${contextPath}/biz/store/refunds?statusCd=REQUESTED" class="biz-nav-link ${bizPage eq 'refunds' ? 'active' : ''}">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
        <path d="M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8"/>
        <path d="M3 3v5h5"/>
      </svg>
      환불 신청<c:if test="${not empty returnRequestedCount && returnRequestedCount > 0}"><span class="biz-nav-badge">${returnRequestedCount}</span></c:if>
    </a>
    <a href="${contextPath}/biz/store/delivery" class="biz-nav-link ${bizPage eq 'delivery' ? 'active' : ''}">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
        <rect x="1" y="3" width="15" height="13" rx="1"/>
        <path d="M16 8h4l3 3v5h-7V8z"/>
        <circle cx="5.5" cy="18.5" r="2.5"/>
        <circle cx="18.5" cy="18.5" r="2.5"/>
      </svg>
      배송 관리
    </a>
    <div class="biz-nav-group">운영 관리</div>

    <a href="${contextPath}/biz/store/coupon" class="biz-nav-link ${bizPage eq 'coupon' ? 'active' : ''}">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
        <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/>
      </svg>
      쿠폰 신청
    </a>

    <a href="${contextPath}/biz/store/reviews" class="biz-nav-link ${bizPage eq 'reviews' ? 'active' : ''}">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
        <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/>
      </svg>
      리뷰 관리
    </a>

   <a href="${contextPath}/biz/store/qna" class="biz-nav-link ${bizPage eq 'qna' ? 'active' : ''}">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
        <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/>
      </svg>
      Q&A 관리
    </a>

    <%-- 2026-08-06 박유정 — 배너 광고 --%>
    <a href="${contextPath}/biz/store/banner" class="biz-nav-link ${bizPage eq 'banner' ? 'active' : ''}">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"
           stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
        <rect x="2" y="3" width="20" height="14" rx="2"/>
        <line x1="8" y1="21" x2="16" y2="21"/>
        <line x1="12" y1="17" x2="12" y2="21"/>
      </svg>
      배너 광고
    </a>

    <a href="${contextPath}/biz/store/settlement" class="biz-nav-link ${bizPage eq 'settlement' ? 'active' : ''}">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
        <line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 000 7h5a3.5 3.5 0 010 7H6"/>
      </svg>
      정산 내역
    </a>
    
    <a href="${contextPath}/biz/store/info" class="biz-nav-link ${bizPage eq 'info' ? 'active' : ''}">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
        <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>
      </svg>
      사업자 정보
    </a>
  </nav>
</aside>