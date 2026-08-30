<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="mypage" />
<c:set var="sec" value="notifications" />

<%@ include file="/WEB-INF/views/common/header.jsp" %>
<link rel="stylesheet" href="${contextPath}/resources/css/mypage.css">

<style>
.noti-detail-back{display:inline-flex;align-items:center;gap:6px;font-size:14px;color:var(--text-muted);text-decoration:none;margin-bottom:20px}
.noti-detail-back:hover{color:var(--primary)}
.noti-detail-back svg{width:16px;height:16px;stroke:currentColor;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}
.noti-detail-card{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);padding:28px}
.noti-detail-type{display:inline-flex;align-items:center;gap:8px;font-size:12px;font-weight:700;padding:4px 12px;border-radius:20px;margin-bottom:14px}
.noti-type-order{background:#EEF2FF;color:#3B5BDB}
.noti-type-resv{background:#E0F2FE;color:#0284C7}
.noti-type-notice{background:#FFF8E1;color:#F59E0B}
.noti-type-chat{background:#F3E8FF;color:#7C3AED}
.noti-detail-title{font-size:20px;font-weight:800;color:var(--text-main);margin-bottom:10px;line-height:1.4}
.noti-detail-time{font-size:13px;color:var(--text-muted);margin-bottom:24px;padding-bottom:20px;border-bottom:1px solid var(--border)}
.noti-detail-body{font-size:15px;color:var(--text-sub);line-height:1.8;margin-bottom:28px;white-space:pre-line}
.noti-detail-actions{display:flex;gap:10px;flex-wrap:wrap}
.noti-detail-actions a,.noti-detail-actions button{padding:10px 20px;border-radius:var(--radius-sm);font-size:14px;font-weight:700;cursor:pointer;text-decoration:none}
.btn-noti-primary{background:var(--primary);color:#fff;border:none}
.btn-noti-outline{background:#fff;color:var(--text-sub);border:1px solid var(--border)}
</style>

<div class="mypage-wrap">
<%@ include file="/WEB-INF/views/mypage/sidebar.jsp" %>
<div class="mypage-content">

<div class="mp-section active">
    <a href="${contextPath}/mypage/notifications" class="noti-detail-back">
        <svg viewBox="0 0 24 24"><path d="M19 12H5"/><polyline points="12 19 5 12 12 5"/></svg>
        알림함으로
    </a>

    <%-- 2026-07-09 장우철 — TB_NOTIFICATION 상세 (열람 시 읽음 처리) --%>
    <div class="noti-detail-card">
        <c:set var="typeClass" value="noti-type-notice" />
        <c:set var="typeLabel" value="시스템 알림" />
        <c:choose>
            <c:when test="${noti.notiType eq 'ORDER'}">
                <c:set var="typeClass" value="noti-type-order" />
                <c:set var="typeLabel" value="주문 알림" />
            </c:when>
            <c:when test="${noti.notiType eq 'RESERVE'}">
                <c:set var="typeClass" value="noti-type-resv" />
                <c:set var="typeLabel" value="예약 알림" />
            </c:when>
            <c:when test="${noti.notiType eq 'COMMUNITY'}">
                <c:set var="typeClass" value="noti-type-chat" />
                <c:set var="typeLabel" value="커뮤니티 알림" />
            </c:when>
        </c:choose>

        <span class="noti-detail-type ${typeClass}">${typeLabel}</span>
        <h2 class="noti-detail-title"><c:out value="${noti.title}"/></h2>
        <div class="noti-detail-time">
            <fmt:formatDate value="${noti.regDate}" pattern="yyyy.MM.dd HH:mm"/>
        </div>
        <div class="noti-detail-body"><c:out value="${noti.content}"/></div>

        <%-- 2026/07/13 장우철 — 알림 종류별 CTA 문구 --%>
        <c:if test="${not empty noti.linkUrl}">
        <c:set var="ctaLabel" value="관련 화면으로 이동"/>
        <c:choose>
            <c:when test="${fn:contains(noti.title, '확정')}">
                <c:set var="ctaLabel" value="예약 상세 보기"/>
            </c:when>
            <c:when test="${fn:contains(noti.title, '완료')}">
                <c:set var="ctaLabel" value="예약 상세 · 리뷰 작성"/>
            </c:when>
            <c:when test="${fn:contains(noti.title, '취소')}">
                <c:set var="ctaLabel" value="취소 내역 보기"/>
            </c:when>
            <c:when test="${fn:contains(noti.title, '답글')}">
                <c:set var="ctaLabel" value="병원 상세 · 리뷰 확인"/>
            </c:when>
            <c:when test="${fn:contains(noti.title, '리뷰')}">
                <c:set var="ctaLabel" value="리뷰 관리로 이동"/>
            </c:when>
        </c:choose>
        <div class="noti-detail-actions">
            <a href="${contextPath}${noti.linkUrl}" class="btn-noti-primary"><c:out value="${ctaLabel}"/></a>
        </div>
        </c:if>

        <button type="button" class="btn-noti-outline" style="margin-top:12px" onclick="location.href='${contextPath}/mypage/notifications'">목록으로</button>
    </div>
</div>

<%--
[변경 전 더미 UI] 2026-07-09 장우철 — param.type 분기 (order/resv/notice/chat)
    <c:choose>
        <c:when test="${notiType eq 'order'}"> ... </c:when>
        ...
    </c:choose>
--%>

</div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
