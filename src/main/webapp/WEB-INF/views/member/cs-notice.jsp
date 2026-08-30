<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="cs" />

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
.cs-notice-detail-wrap {
    max-width: 800px;
    margin: 36px auto 80px;
    padding: 0 20px;
}
.cs-notice-back {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    font-size: 14px;
    color: var(--text-muted);
    text-decoration: none;
    margin-bottom: 20px;
}
.cs-notice-back:hover { color: var(--primary); }
.cs-notice-back svg {
    width: 16px;
    height: 16px;
    stroke: currentColor;
    fill: none;
    stroke-width: 2;
    stroke-linecap: round;
    stroke-linejoin: round;
}
.cs-notice-detail-card {
    background: var(--bg-card);
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    padding: 32px 28px;
}
.cs-notice-detail-badge {
    display: inline-block;
    font-size: 11px;
    font-weight: 700;
    padding: 4px 10px;
    border-radius: 4px;
    background: var(--primary-light);
    color: var(--primary-dark);
    margin-bottom: 14px;
}
.cs-notice-detail-badge.info {
    background: #E0F2FE;
    color: #0284C7;
}
.cs-notice-detail-title {
    font-size: 22px;
    font-weight: 800;
    color: var(--text-main);
    margin: 0 0 12px;
    line-height: 1.4;
}
.cs-notice-detail-meta {
    font-size: 13px;
    color: var(--text-muted);
    padding-bottom: 20px;
    margin-bottom: 24px;
    border-bottom: 1px solid var(--border);
}
.cs-notice-detail-body {
    font-size: 15px;
    color: var(--text-sub);
    line-height: 1.85;
    white-space: pre-wrap;   /* ← 줄바꿈 유지 (DB 본문) */
}
.cs-notice-detail-body p { margin: 0 0 14px; }
.cs-notice-detail-body ul {
    margin: 0 0 14px;
    padding-left: 20px;
}
.cs-notice-detail-body li { margin-bottom: 6px; }
.cs-notice-empty {
    text-align: center;
    padding: 48px 20px;
    color: var(--text-muted);
}
</style>

<div class="cs-notice-detail-wrap">
    <a href="${contextPath}/member/cs" class="cs-notice-back">
        <svg viewBox="0 0 24 24"><path d="M19 12H5"/><polyline points="12 19 5 12 12 5"/></svg>
        공지사항 목록
    </a>

    <article class="cs-notice-detail-card">
        <c:choose>
            <c:when test="${not empty notice}">
                <span class="cs-notice-detail-badge${notice.noticeTypeCd eq 'INFO' ? ' info' : ''}">
                    <c:choose>
                        <c:when test="${notice.noticeTypeCd eq 'INFO'}">안내</c:when>
                        <c:otherwise>공지</c:otherwise>
                    </c:choose>
                </span>
                <h1 class="cs-notice-detail-title"><c:out value="${notice.title}"/></h1>
                <div class="cs-notice-detail-meta">
                    <fmt:formatDate value="${notice.regDate}" pattern="yyyy.MM.dd"/>
                    · <c:out value="${notice.writerName}"/>
                </div>
                <div class="cs-notice-detail-body"><c:out value="${notice.body}"/></div>
            </c:when>
            <c:otherwise>
                <div class="cs-notice-empty">
                    <p>요청하신 공지를 찾을 수 없습니다.</p>
                    <a href="${contextPath}/member/cs" class="cs-notice-back" style="margin-top:16px">목록으로 돌아가기</a>
                </div>
            </c:otherwise>
        </c:choose>
    </article>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
