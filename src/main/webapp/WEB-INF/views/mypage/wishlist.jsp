<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="mypage" />
<c:set var="sec" value="wishlist" />

<%@ include file="/WEB-INF/views/common/header.jsp" %>
<link rel="stylesheet" href="${contextPath}/resources/css/mypage.css">

<div class="mypage-wrap">
<%@ include file="/WEB-INF/views/mypage/sidebar.jsp" %>
<div class="mypage-content">

<div class="mp-section active">
    <h2 class="mp-title">관심상품</h2>
    <c:if test="${not empty errorMsg}">
      <p class="mp-desc" style="color:#B91C1C">${errorMsg}</p>
    </c:if>
    <%-- 2026/08/13 장우철 — TB_FAVORITE 실데이터 --%>
    <p class="mp-desc">찜한 항목 <strong id="wishCount">${fn:length(wishList)}</strong>개</p>
    <div class="wishlist-grid" id="wishlistGrid" data-server="true">
        <c:choose>
            <c:when test="${empty wishList}">
                <div class="search-empty" style="grid-column:1/-1;padding:48px 20px;text-align:center;color:var(--text-muted);">
                    찜한 상품이 없습니다.
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach var="w" items="${wishList}">
                    <c:choose>
                        <c:when test="${fn:startsWith(w.imageUrl, 'http://') || fn:startsWith(w.imageUrl, 'https://')}">
                            <c:set var="thumbSrc" value="${w.imageUrl}" />
                        </c:when>
                        <c:when test="${not empty w.imageUrl}">
                            <c:set var="thumbSrc" value="${contextPath}/upload/${w.imageUrl}" />
                        </c:when>
                        <c:otherwise>
                            <c:set var="thumbSrc" value="https://placehold.co/300x300/EAF7F2/2BAB82?text=찜" />
                        </c:otherwise>
                    </c:choose>
                    <div class="wish-card" onclick="location.href='${contextPath}${w.link}'">
                        <div class="wish-thumb-wrap">
                            <img class="wish-thumb" src="${thumbSrc}" alt=""
                                 onerror="this.src='https://placehold.co/300x300/EAF7F2/2BAB82?text=찜'">
                            <button type="button" class="wish-heart wish-btn" data-wish-id="${w.wishKey}"
                                    aria-label="찜 해제">
                                <svg viewBox="0 0 24 24"><path d="M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78L12 21.23l8.84-8.84a5.5 5.5 0 000-7.78z"/></svg>
                            </button>
                        </div>
                        <div class="wish-body">
                            <div class="w-name">${w.title}</div>
                            <div>
                                <c:if test="${w.price != null and w.price > 0}">
                                    <span class="w-price"><fmt:formatNumber value="${w.price}" pattern="#,###"/>원</span>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </div>
</div>

</div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
