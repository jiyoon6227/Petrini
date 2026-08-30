<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- 2026-08-07 박유정 — 사업자 배너 목록: effectiveStatusLabel·미리보기 URL 분기 --%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%-- 2026-08-07 박유정 — fn:startsWith (이미지 URL 분기) --%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="반려동물 숙소" />
<c:set var="bizPage" value="banner" />
<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_stay.jsp" %>

<main class="biz-main">
    <div class="biz-page-head has-action">
        <div>
            <h1 class="biz-page-title">배너 광고</h1>
            <p class="biz-page-desc">메인페이지 및 서비스 페이지에 노출할 배너를 신청하세요.</p>
        </div>
        <a href="${contextPath}/biz/stay/banner/form" class="biz-btn primary">
            <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            배너 신청
        </a>
    </div>

    <%-- 알림 메시지 (reviews.jsp 와 동일 패턴) --%>
    <c:if test="${not empty msg}">
        <div style="margin-bottom:12px;padding:12px 16px;background:#E8F8F1;color:#1F8464;border-radius:8px;font-size:14px;font-weight:600">${msg}</div>
    </c:if>
    <c:if test="${not empty errorMsg}">
        <div style="margin-bottom:12px;padding:12px 16px;background:#FEF2F2;color:#B91C1C;border-radius:8px;font-size:14px;font-weight:600">${errorMsg}</div>
    </c:if>

    <div class="biz-card">
        <div class="biz-card-head">
            <span class="biz-card-title">내 배너 목록</span>
            <span class="biz-card-sub">총 ${bannerList.size()}건</span>
        </div>

        <c:choose>
            <c:when test="${not empty bannerList}">
                <div class="biz-table-wrap">
                    <table class="biz-table">
                        <thead>
                            <tr>
                                <th>미리보기</th>
                                <th>제목</th>
                                <th>노출 위치</th>
                                <th>노출 기간</th>
                                <th>상태</th>
                                <th>비고</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="banner" items="${bannerList}">
                                <tr>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty banner.imageUrl}">
                                                <%-- 2026-08-07 박유정 — /upload/ 접두어·외부 URL 분기 (ad-banner.jsp 동일) --%>
                                                <c:set var="imgSrc" value="${banner.imageUrl}" />
                                                <c:choose>
                                                    <c:when test="${fn:startsWith(banner.imageUrl, 'http')}">
                                                        <c:set var="imgSrc" value="${banner.imageUrl}" />
                                                    </c:when>
                                                    <c:when test="${fn:startsWith(banner.imageUrl, '/upload/')}">
                                                        <c:set var="imgSrc" value="${contextPath}${banner.imageUrl}" />
                                                    </c:when>
                                                    <c:otherwise>
                                                        <c:set var="imgSrc" value="${contextPath}/upload/${banner.imageUrl}" />
                                                    </c:otherwise>
                                                </c:choose>
                                                <img src="${imgSrc}" alt=""
                                                     style="width:120px;height:50px;object-fit:cover;border-radius:6px"
                                                     onerror="this.src='https://placehold.co/120x50/EAF7F2/2BAB82?text=배너'">
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color:#999;font-size:13px">이미지 없음</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td><strong>${banner.title}</strong></td>
                                    <td>
                                        <span class="biz-badge">${banner.positionLabel}</span>
                                    </td>
                                    <td>
                                        ${banner.startDate} ~ ${banner.endDate}
                                    </td>
                                    <td>
                                        <%-- 2026-08-07 박유정 — effectiveStatusLabel (기간 반영, 관리자 목록과 동일) --%>
                                        <c:choose>
                                            <c:when test="${banner.effectiveStatusLabel eq '심사중'}">
                                                <span class="biz-badge warning">심사중</span>
                                            </c:when>
                                            <c:when test="${banner.effectiveStatusLabel eq '노출예정'}">
                                                <span class="biz-badge warning">노출예정</span>
                                            </c:when>
                                            <c:when test="${banner.effectiveStatusLabel eq '노출중'}">
                                                <span class="biz-badge success">노출중</span>
                                            </c:when>
                                            <c:when test="${banner.effectiveStatusLabel eq '노출 예정'}">
                                                <span class="biz-badge warning">노출 예정</span>
                                            </c:when>
                                            <c:when test="${banner.effectiveStatusLabel eq '반려'}">
                                                <span class="biz-badge danger">반려</span>
                                            </c:when>
                                            <c:when test="${banner.effectiveStatusLabel eq '미노출'}">
                                                <span class="biz-badge inactive">미노출</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="biz-badge">${banner.effectiveStatusLabel}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:if test="${banner.statusCd eq 'HOLD' and not empty banner.rejectReason}">
                                            <span style="color:#3B5BDB;font-size:13px">${banner.rejectReason}</span>
                                        </c:if>
                                        <c:if test="${banner.statusCd eq 'REJECTED' and not empty banner.rejectReason}">
                                            <span style="color:#e74c3c;font-size:13px">${banner.rejectReason}</span>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:when>
            <c:otherwise>
                <div style="padding:60px 20px;text-align:center;color:#999">
                    <p>신청한 배너가 없습니다.</p>
                    <a href="${contextPath}/biz/stay/banner/form" style="color:#2BAB82;text-decoration:underline;margin-top:8px;display:inline-block">배너 신청하기</a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</main>
<jsp:include page="/WEB-INF/views/biz/common/footer.jsp" />
