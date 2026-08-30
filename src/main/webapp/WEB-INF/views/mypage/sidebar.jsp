<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%-- 마이페이지 공통 사이드바: sec 변수는 각 섹션 JSP에서 미리 set 되어 있어야 함 --%>
<aside class="mypage-sidebar">
    <div class="sidebar-profile">
        <div class="profile-avatar">
            <%-- 2026-08-04 박유정 — 세션 memberInfo.profileImgUrl 표시 (로그인·저장 시 갱신) --%>
            <img src="${not empty memberInfo.profileImgUrl ? contextPath.concat(memberInfo.profileImgUrl) : 'https://placehold.co/76x76/EAF7F2/2BAB82?text=ME'}"
                 alt="프로필"
                 onerror="this.src='https://placehold.co/76x76/EAF7F2/2BAB82?text=ME'">
        </div>
        <div class="profile-name">${memberInfo.memberName}<span>님</span></div>
        <%-- 2026/07/08 장우철 — 등급: role 기준 (일반회원/사업자/관리자), 추후 GRADE_CD 로 변경 가능 --%>
        <div class="profile-grade">
            <c:choose>
                <c:when test="${memberInfo.role eq 'ADMIN'}">관리자</c:when>
                <c:when test="${memberInfo.role eq 'BIZ'}">사업자</c:when>
                <c:otherwise>일반회원</c:otherwise>
            </c:choose>
        </div>
        <%-- 2026/07/08 장우철 — 보유 포인트: 세션 memberInfo.pointBalance (TB_MEMBER.POINT_BALANCE) --%>
        <div class="profile-points">보유 포인트 <strong><fmt:formatNumber value="${memberInfo.pointBalance != null ? memberInfo.pointBalance : 0}" pattern="#,###" /> P</strong></div>
        <%-- [변경 전] 하드코딩 더미
        <div class="profile-points">보유 포인트 <strong>1,200 P</strong></div>
        --%>
    </div>
    <ul class="sidebar-menu">
        <li><a href="${contextPath}/mypage" class="${sec eq 'dashboard' ? 'active' : ''}">
            <svg class="mi" viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>마이홈
        </a></li>
        <li><div class="sidebar-divider"></div></li>
        <li><a href="${contextPath}/mypage/orders" class="${sec eq 'orders' ? 'active' : ''}">
            <svg class="mi" viewBox="0 0 24 24"><path d="M6 2L3 6v14a2 2 0 002 2h14a2 2 0 002-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 01-8 0"/></svg>주문내역
        </a></li>
        <li><a href="${contextPath}/mypage/reserve" class="${sec eq 'reserve' ? 'active' : ''}">
            <svg class="mi" viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>예약내역
        </a></li>
        <li><a href="${contextPath}/mypage/points" class="${sec eq 'points' ? 'active' : ''}">
            <svg class="mi" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M12 8v4l3 3"/></svg>포인트/쿠폰
        </a></li>
        <li><a href="${contextPath}/mypage/wishlist" class="${sec eq 'wishlist' ? 'active' : ''}">
            <svg class="mi" viewBox="0 0 24 24"><path d="M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78L12 21.23l8.84-8.84a5.5 5.5 0 000-7.78z"/></svg>관심상품
        </a></li>
        <li><div class="sidebar-divider"></div></li>
        <li><a href="${contextPath}/mypage/pets" class="${sec eq 'pets' ? 'active' : ''}">
            <svg class="mi" viewBox="0 0 24 24"><circle cx="4.5" cy="9.5" r="2"/><circle cx="9" cy="5.5" r="2"/><circle cx="15" cy="5.5" r="2"/><circle cx="19.5" cy="9.5" r="2"/><path d="M12 13c-3.87 0-7 1.79-7 4v1h14v-1c0-2.21-3.13-4-7-4z"/></svg>반려동물 관리
        </a></li>
        <li><a href="${contextPath}/mypage/health" class="${sec eq 'health' ? 'active' : ''}">
            <svg class="mi" viewBox="0 0 24 24"><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></svg>건강수첩
        </a></li>
        <li><a href="${contextPath}/mypage/notifications" class="${sec eq 'notifications' ? 'active' : ''}">
            <svg class="mi" viewBox="0 0 24 24"><path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 01-3.46 0"/></svg>알림함
        </a></li>
        <li><div class="sidebar-divider"></div></li>
        <li><a href="${contextPath}/mypage/edit" class="${sec eq 'edit' ? 'active' : ''}">
            <svg class="mi" viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>회원정보 수정
        </a></li>
        <li><a href="${contextPath}/mypage/biz" class="${sec eq 'biz' or sec eq 'biz/apply' ? 'active' : ''}">
            <svg class="mi" viewBox="0 0 24 24"><rect x="2" y="7" width="20" height="14" rx="2"/><path d="M16 7V5a2 2 0 00-2-2h-4a2 2 0 00-2 2v2"/><line x1="12" y1="12" x2="12" y2="16"/><line x1="10" y1="14" x2="14" y2="14"/></svg>사업자센터
        </a></li>
    </ul>
</aside>
