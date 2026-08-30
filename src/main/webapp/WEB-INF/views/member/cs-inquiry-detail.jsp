<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="cs" />
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
.cs-inquiry-detail-wrap {
    max-width: 800px;
    margin: 36px auto 80px;
    padding: 0 20px;
}
.cs-inquiry-back {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    font-size: 14px;
    color: var(--text-muted);
    text-decoration: none;
    margin-bottom: 20px;
}
.cs-inquiry-back:hover { color: var(--primary); }
.cs-inquiry-back svg {
    width: 16px;
    height: 16px;
    stroke: currentColor;
    fill: none;
    stroke-width: 2;
    stroke-linecap: round;
    stroke-linejoin: round;
}
.cs-inquiry-detail-card {
    background: var(--bg-card);
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    padding: 28px 24px;
    margin-bottom: 16px;
}
.cs-inquiry-detail-meta {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    align-items: center;
    margin-bottom: 14px;
}
.cs-inquiry-detail-cat {
    font-size: 11px;
    font-weight: 700;
    padding: 4px 10px;
    border-radius: 20px;
    background: var(--primary-light);
    color: var(--primary-dark);
}
.cs-inquiry-detail-status {
    font-size: 11px;
    font-weight: 700;
    padding: 4px 10px;
    border-radius: 20px;
}
.cs-inquiry-detail-status.waiting {
    background: #FEF3C7;
    color: #B45309;
}
.cs-inquiry-detail-status.answered {
    background: #DCFCE7;
    color: #16A34A;
}
.cs-inquiry-detail-date {
    font-size: 13px;
    color: var(--text-muted);
}
.cs-inquiry-detail-title {
    font-size: 20px;
    font-weight: 800;
    color: var(--text-main);
    margin: 0 0 18px;
    line-height: 1.4;
}
.cs-inquiry-detail-body {
    font-size: 15px;
    color: var(--text-sub);
    line-height: 1.85;
    white-space: pre-wrap;
}
.cs-inquiry-answer-card {
    background: #F8FAFC;
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    padding: 24px;
}
.cs-inquiry-answer-title {
    font-size: 15px;
    font-weight: 800;
    color: var(--text-main);
    margin: 0 0 8px;
}
.cs-inquiry-answer-date {
    font-size: 12px;
    color: var(--text-muted);
    margin-bottom: 14px;
}
.cs-inquiry-answer-body {
    font-size: 14px;
    color: var(--text-sub);
    line-height: 1.8;
    white-space: pre-wrap;
}
.cs-inquiry-waiting-msg {
    padding: 24px;
    text-align: center;
    color: var(--text-muted);
    font-size: 14px;
    background: #FFFBEB;
    border: 1px solid #FDE68A;
    border-radius: var(--radius-md);
}
</style>

<div class="cs-inquiry-detail-wrap">
    <a href="${contextPath}/member/cs/inquiry" class="cs-inquiry-back">
        <svg viewBox="0 0 24 24"><path d="M19 12H5"/><polyline points="12 19 5 12 12 5"/></svg>
        문의 목록
    </a>

    <c:if test="${not empty successMsg}">
        <div style="background:#ECFDF5;border:1px solid #BBF7D0;color:#166534;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:14px">
            <c:out value="${successMsg}"/>
        </div>
    </c:if>

    <article class="cs-inquiry-detail-card">
        <div class="cs-inquiry-detail-meta">
            <span class="cs-inquiry-detail-cat">${inquiry.category}</span>
            <span class="cs-inquiry-detail-status ${inquiry.answered ? 'answered' : 'waiting'}">
                ${inquiry.answered ? '답변완료' : '답변대기'}
            </span>
            <span class="cs-inquiry-detail-date">${inquiry.createdAtText}</span>
        </div>
        <h1 class="cs-inquiry-detail-title">${inquiry.title}</h1>
        <div class="cs-inquiry-detail-body">${inquiry.content}</div>
    </article>

    <c:choose>
    <c:when test="${inquiry.answered}">
        <section class="cs-inquiry-answer-card">
            <h2 class="cs-inquiry-answer-title">펫린이 고객센터 답변</h2>
            <div class="cs-inquiry-answer-date">${inquiry.answeredAtText}</div>
            <div class="cs-inquiry-answer-body">${inquiry.answer}</div>
        </section>
    </c:when>
    <c:otherwise>
        <div class="cs-inquiry-waiting-msg">
            담당자가 확인 중입니다. 영업일 기준 1~2일 내 답변드리겠습니다.
        </div>
    </c:otherwise>
    </c:choose>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
