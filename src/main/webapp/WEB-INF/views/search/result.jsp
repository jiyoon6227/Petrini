<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="search" />

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
.search-page {
    max-width: var(--inner-width);
    margin: 32px auto 80px;
    padding: 0 20px;
}
.search-page-title {
    font-size: 24px;
    font-weight: 800;
    color: var(--text-main);
    margin: 0 0 8px;
}
.search-page-desc {
    font-size: 14px;
    color: var(--text-muted);
    margin: 0 0 28px;
}
.search-page-desc strong {
    color: var(--primary-dark);
}
.search-section {
    margin-bottom: 36px;
}
.search-section-title {
    font-size: 16px;
    font-weight: 800;
    color: var(--text-main);
    margin: 0 0 14px;
    padding-bottom: 10px;
    border-bottom: 2px solid var(--border);
}
.search-result-list {
    display: flex;
    flex-direction: column;
    gap: 10px;
}
.search-result-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 16px;
    padding: 16px 18px;
    background: var(--bg-card);
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    text-decoration: none;
    color: inherit;
    transition: var(--transition);
}
.search-result-item:hover {
    box-shadow: var(--shadow-md);
    transform: translateY(-2px);
}
.search-result-name {
    font-size: 15px;
    font-weight: 700;
    color: var(--text-main);
    margin-bottom: 4px;
}
.search-result-meta {
    font-size: 13px;
    color: var(--text-muted);
}
.search-result-tag {
    font-size: 11px;
    font-weight: 700;
    padding: 4px 10px;
    border-radius: 20px;
    background: var(--primary-light);
    color: var(--primary-dark);
    flex-shrink: 0;
}
.search-empty {
    padding: 56px 20px;
    text-align: center;
    color: var(--text-muted);
    font-size: 15px;
    background: var(--bg-card);
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    line-height: 1.7;
}
.search-total {
    display: inline-block;
    margin-left: 8px;
    font-size: 13px;
    font-weight: 700;
    color: var(--primary-dark);
}
</style>

<main class="search-page">
    <h1 class="search-page-title">통합 검색</h1>

    <c:choose>
    <c:when test="${empty keyword}">
        <p class="search-page-desc">검색어를 입력해 주세요.</p>
        <div class="search-empty">
            숙소, 쇼핑, 병원, 산책, 커뮤니티, 기부, 이벤트, 미용, 스튜디오, 펫맵, 공지사항 등<br>
            사이트 전체에서 검색할 수 있습니다.
        </div>
    </c:when>
    <c:when test="${totalCount == 0}">
        <p class="search-page-desc">
            <strong>'${keyword}'</strong> 검색 결과
            <span class="search-total">0건</span>
        </p>
        <div class="search-empty">
            '${keyword}'에 대한 검색 결과가 없습니다.<br>
            다른 키워드로 다시 검색해 보세요.
        </div>
    </c:when>
    <c:otherwise>
        <p class="search-page-desc">
            <strong>'${keyword}'</strong> 검색 결과
            <span class="search-total">${totalCount}건</span>
        </p>

        <c:forEach var="section" items="${sections}">
            <section class="search-section">
                <h2 class="search-section-title">${section.label}</h2>
                <div class="search-result-list">
                    <c:forEach var="item" items="${section.items}">
                        <a href="${contextPath}${item.url}" class="search-result-item">
                            <div>
                                <div class="search-result-name">${item.title}</div>
                                <div class="search-result-meta">${item.meta}</div>
                            </div>
                            <span class="search-result-tag">${item.categoryLabel}</span>
                        </a>
                    </c:forEach>
                </div>
            </section>
        </c:forEach>
    </c:otherwise>
    </c:choose>
</main>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
