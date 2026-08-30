<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- adminPage 변수로 active 제어 --%>
<aside class="adm-sidebar">
    <div class="adm-sidebar-profile">
        <img class="adm-avatar"
             src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=76&q=80&auto=format&fit=crop"
             alt="관리자"
             onerror="this.src='https://placehold.co/38x38/EEF2FF/3B5BDB?text=A'">
        <div>
            <div class="adm-profile-name">${memberInfo.memberName}</div>
            <span class="adm-profile-role">ADMIN</span>
        </div>
    </div>

    <%-- 2026/08/13 장우철 — 사이드바 그룹: 대시보드 → 회원 → 쇼핑 → 숙소 → 커뮤니티 → 사업자 → CMS → 고객응대 → 통계 --%>
    <nav class="adm-nav">
        <a href="${contextPath}/admin" class="adm-nav-link ${adminPage eq 'dashboard' ? 'active' : ''}">
            <svg viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
            대시보드
        </a>

        <div class="adm-nav-group">회원</div>
        <a href="${contextPath}/admin/member/list" class="adm-nav-link ${adminPage eq 'member-list' ? 'active' : ''}">
            <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87M16 3.13a4 4 0 010 7.75"/></svg>
            회원 관리
        </a>

        <div class="adm-nav-group">쇼핑</div>
        <a href="${contextPath}/admin/store/product-list" class="adm-nav-link ${adminPage eq 'product-list' ? 'active' : ''}">
            <svg viewBox="0 0 24 24"><path d="M6 2L3 6v14a2 2 0 002 2h14a2 2 0 002-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 01-8 0"/></svg>
            상품 관리
        </a>
        <%-- 2026/08/11 장우철 — 카테고리 관리 미사용(DB 더미 카테고리만 사용) → 메뉴 제거
        <a href="${contextPath}/admin/store/category" ...>카테고리 관리</a>
        --%>
        <a href="${contextPath}/admin/store/order-list" class="adm-nav-link ${adminPage eq 'order-list' ? 'active' : ''}">
            <svg viewBox="0 0 24 24"><rect x="1" y="3" width="15" height="13" rx="1"/><path d="M16 8h4l3 3v5h-7V8z"/><circle cx="5.5" cy="18.5" r="2.5"/><circle cx="18.5" cy="18.5" r="2.5"/></svg>
            주문 관리
        </a>
        <%-- 2026/08/11 장우철 — 리뷰관리(/admin/store/review-report) 제거 → 사업자 리뷰로 통합 --%>

        <div class="adm-nav-group">숙소</div>
        <%-- 2026/08/13 장우철 — 숙소 관리 (전체 숙소·객실 운영 상태) --%>
        <a href="${contextPath}/admin/stay/list" class="adm-nav-link ${adminPage eq 'stay-list' ? 'active' : ''}">
            <svg viewBox="0 0 24 24"><path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
            숙소 관리
        </a>
        <%-- 2026/07/31 장우철 — 숙소 예약 관리 (전액 환불 취소) --%>
        <a href="${contextPath}/admin/reservation/list" class="adm-nav-link ${adminPage eq 'reservation-list' ? 'active' : ''}">
            <svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
            숙소 예약 관리
        </a>
        <%-- 2026/07/31 장우철 — 숙소 환불신청(1:1) 승인/거절 --%>
        <%-- 2026-08-11 박유정 — 대기 건수 배지 (AdminSidebarAdvice.pendingStayRefundCount) --%>
        <a href="${contextPath}/admin/inquiry/stay-refund?status=WAIT" class="adm-nav-link ${adminPage eq 'stay-refund' ? 'active' : ''}">
            <svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg>
            숙소 환불 신청
            <c:if test="${pendingStayRefundCount > 0}">
              <span class="adm-nav-badge">${pendingStayRefundCount}</span>
            </c:if>
        </a>

        <div class="adm-nav-group">커뮤니티</div>
        <a href="${contextPath}/admin/community/list" class="adm-nav-link ${adminPage eq 'community-list' ? 'active' : ''}">
            <svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg>
            커뮤니티 관리
        </a>
        <a href="${contextPath}/admin/biz/talent?status=PENDING" class="adm-nav-link ${adminPage eq 'biz-talent' ? 'active' : ''}">
            <svg viewBox="0 0 24 24"><path d="M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78L12 21.23l8.84-8.84a5.5 5.5 0 000-7.78z"/></svg>
            재능나눔 승인
            <%-- 2026-07-14 박유정 — PENDING 승인대기 건수 (AdminSidebarAdvice.pendingTalentApproveCount) --%>
            <c:if test="${pendingTalentApproveCount > 0}">
              <span class="adm-nav-badge">${pendingTalentApproveCount}</span>
            </c:if>
        </a>

        <div class="adm-nav-group">사업자</div>
        <a href="${contextPath}/admin/biz/list" class="adm-nav-link ${adminPage eq 'biz-list' ? 'active' : ''}">
            <svg viewBox="0 0 24 24"><rect x="2" y="7" width="20" height="14" rx="2"/><path d="M16 7V5a2 2 0 00-2-2h-4a2 2 0 00-2 2v2"/></svg>
            사업자 승인/관리
            <%-- 2026/07/11 장우철 — PENDING 승인대기 건수 (더미 3 제거) --%>
            <c:if test="${pendingBizApproveCount > 0}">
              <span class="adm-nav-badge">${pendingBizApproveCount}</span>
            </c:if>
        </a>
        <!--HYJ 26.07.29 쿠폰 승인-->
        <!-- 지윤 26.08.11 추가: 승인대기 건수 뱃지 (AdminSidebarAdvice.pendingCouponApproveCount) -->
        <%-- 2026-08-13 박유정 — 쿠폰 관리 기본: 관리자 승인 > 승인 대기 --%>
        <a href="${contextPath}/admin/biz/coupon/list?tab=review&status=PENDING" class="adm-nav-link ${adminPage eq 'coupon-list' ? 'active' : ''}">
            <svg viewBox="0 0 24 24"><rect x="2" y="7" width="20" height="14" rx="2"/><path d="M16 7V5a2 2 0 00-2-2h-4a2 2 0 00-2 2v2"/></svg>
            쿠폰 승인
            <c:if test="${pendingCouponApproveCount > 0}">
              <span class="adm-nav-badge">${pendingCouponApproveCount}</span>
            </c:if>
        </a>
        <%-- 2026-07-24 박유정 — 사업자 리뷰 삭제 요청 --%>
        <a href="${contextPath}/admin/review/list?statusCd=PENDING" class="adm-nav-link ${adminPage eq 'review-list' ? 'active' : ''}">
            <svg viewBox="0 0 24 24"><path d="M12 20h9"/><path d="M16.5 3.5a2.12 2.12 0 013 3L7 19l-4 1 1-4z"/></svg>
            사업자 리뷰
            <c:if test="${pendingReviewDeleteCount > 0}">
              <span class="adm-nav-badge">${pendingReviewDeleteCount}</span>
            </c:if>
        </a>
        <a href="${contextPath}/admin/settlement?tab=STAY" class="adm-nav-link ${adminPage eq 'settlement' ? 'active' : ''}">
            <svg viewBox="0 0 24 24"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 000 7h5a3.5 3.5 0 010 7H6"/></svg>
            정산 관리
            <%-- 2026/07/30 장우철 — 숙소 중간정산 REQUESTED 배지 --%>
            <c:if test="${pendingStaySettleRequestCount > 0}">
              <span class="adm-nav-badge">
                <c:choose>
                  <c:when test="${pendingStaySettleRequestCount > 99}">99+</c:when>
                  <c:otherwise>${pendingStaySettleRequestCount}</c:otherwise>
                </c:choose>
              </span>
            </c:if>
        </a>

        <div class="adm-nav-group">CMS</div>
        <a href="${contextPath}/admin/cms/banner" class="adm-nav-link ${adminPage eq 'cms-banner' ? 'active' : ''}">
            <svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M3 9h18"/><path d="M9 21V9"/></svg>
            배너 관리
            <%-- 2026-08-06 박유정 — PENDING 심사대기 건수 (AdminSidebarAdvice.pendingBannerCount) --%>
            <c:if test="${pendingBannerCount > 0}">
              <span class="adm-nav-badge">${pendingBannerCount}</span>
            </c:if>
        </a>
        <a href="${contextPath}/admin/cms/notice" class="adm-nav-link ${adminPage eq 'cms-notice' ? 'active' : ''}">
            <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
            공지사항
        </a>
        <a href="${contextPath}/admin/cms/faq" class="adm-nav-link ${adminPage eq 'cms-faq' ? 'active' : ''}">
            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 015.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
            FAQ
        </a>
        <div class="adm-nav-group">고객응대</div>
        <%-- 2026-08-11 박유정 — 일반 1:1 문의 답변 (숙소 환불 제외) · 대기 배지 --%>
        <a href="${contextPath}/admin/inquiry/general?status=WAIT" class="adm-nav-link ${adminPage eq 'general-inquiry' ? 'active' : ''}">
            <svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg>
            1:1 문의
            <c:if test="${pendingGeneralInquiryCount > 0}">
              <span class="adm-nav-badge">${pendingGeneralInquiryCount}</span>
            </c:if>
        </a>

        <div class="adm-nav-group">통계</div>
        <a href="${contextPath}/admin/stats" class="adm-nav-link ${adminPage eq 'stats' ? 'active' : ''}">
            <svg viewBox="0 0 24 24"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg>
            통계 &amp; 분석
        </a>
    </nav>
</aside>
