<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="cs" />
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
.cs-inquiry-wrap {
    max-width: 900px;
    margin: 36px auto 80px;
    padding: 0 20px;
}
.cs-inquiry-head {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 16px;
    margin-bottom: 20px;
    flex-wrap: wrap;
}
.cs-inquiry-head h1 {
    font-size: 22px;
    font-weight: 800;
    color: var(--text-main);
    margin: 0;
}
.cs-inquiry-back {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    font-size: 14px;
    color: var(--text-muted);
    text-decoration: none;
    margin-bottom: 16px;
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
.btn-inquiry-write {
    padding: 10px 18px;
    border: none;
    border-radius: var(--radius-sm);
    background: var(--primary);
    color: #fff;
    font-size: 14px;
    font-weight: 700;
    text-decoration: none;
}
.btn-inquiry-write:hover { background: var(--primary-dark); }
.cs-inquiry-list {
    background: var(--bg-card);
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    overflow: hidden;
}
.cs-inquiry-item {
    display: grid;
    grid-template-columns: 88px 1fr 110px 100px;
    gap: 12px;
    align-items: center;
    padding: 16px 18px;
    border-bottom: 1px solid var(--border);
    text-decoration: none;
    color: inherit;
    transition: var(--transition);
}
.cs-inquiry-item:last-child { border-bottom: none; }
.cs-inquiry-item:hover { background: #F8FAFC; }
.cs-inquiry-cat {
    font-size: 12px;
    font-weight: 700;
    color: var(--primary-dark);
    background: var(--primary-light);
    padding: 4px 10px;
    border-radius: 20px;
    text-align: center;
}
.cs-inquiry-title {
    font-size: 14px;
    font-weight: 600;
    color: var(--text-main);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}
.cs-inquiry-date {
    font-size: 12px;
    color: var(--text-muted);
    text-align: center;
}
.cs-inquiry-status {
    font-size: 12px;
    font-weight: 700;
    text-align: center;
    padding: 4px 10px;
    border-radius: 20px;
}
.cs-inquiry-status.waiting {
    background: #FEF3C7;
    color: #B45309;
}
.cs-inquiry-status.answered {
    background: #DCFCE7;
    color: #16A34A;
}
.cs-inquiry-empty {
    padding: 56px 20px;
    text-align: center;
    color: var(--text-muted);
    font-size: 14px;
}
.cs-inquiry-list-head {
    display: grid;
    grid-template-columns: 88px 1fr 110px 100px;
    gap: 12px;
    padding: 12px 18px;
    background: var(--bg-page);
    border-bottom: 1px solid var(--border);
    font-size: 12px;
    font-weight: 700;
    color: var(--text-muted);
    text-align: center;
}
.cs-inquiry-list-head span:nth-child(2) { text-align: left; }
@media (max-width: 768px) {
    .cs-inquiry-list-head { display: none; }
    .cs-inquiry-item {
        grid-template-columns: 1fr;
        gap: 8px;
    }
    .cs-inquiry-date, .cs-inquiry-status { text-align: left; }
}
</style>

<div class="cs-inquiry-wrap">
    <a href="${contextPath}/member/cs" class="cs-inquiry-back">
        <svg viewBox="0 0 24 24"><path d="M19 12H5"/><polyline points="12 19 5 12 12 5"/></svg>
        고객센터
    </a>

    <div class="cs-inquiry-head">
        <h1>1:1 문의</h1>
        <a href="${contextPath}/member/cs/inquiry/write" class="btn-inquiry-write">문의 작성</a>
    </div>

    <c:if test="${not empty successMsg}">
        <div class="cs-form-error" style="background:#ECFDF5;border-color:#BBF7D0;color:#166534;margin-bottom:16px">
            <c:out value="${successMsg}"/>
        </div>
    </c:if>
    <c:if test="${not empty errorMsg}">
        <div class="cs-form-error" style="margin-bottom:16px">
            <c:out value="${errorMsg}"/>
        </div>
    </c:if>

    <div class="cs-inquiry-list">
        <div class="cs-inquiry-list-head">
            <span>유형</span>
            <span>제목</span>
            <span>등록일</span>
            <span>상태</span>
        </div>

        <c:choose>
        <c:when test="${empty inquiries}">
            <div class="cs-inquiry-empty">
                등록된 문의가 없습니다.<br>
                <a href="${contextPath}/member/cs/inquiry/write" style="color:var(--primary);font-weight:700">첫 문의 작성하기</a>
            </div>
        </c:when>
        <c:otherwise>
            <c:forEach var="item" items="${inquiries}">
                <a href="${contextPath}/member/cs/inquiry/detail?id=${item.id}" class="cs-inquiry-item">
                    <span class="cs-inquiry-cat">${item.category}</span>
                    <span class="cs-inquiry-title">${item.title}</span>
                    <span class="cs-inquiry-date">${item.createdAtText}</span>
                    <span class="cs-inquiry-status ${item.answered ? 'answered' : 'waiting'}">
                        ${item.answered ? '답변완료' : '답변대기'}
                    </span>
                </a>
            </c:forEach>
        </c:otherwise>
        </c:choose>
    </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
