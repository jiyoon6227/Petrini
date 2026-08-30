<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="adminPage"   value="cms-faq" />
<%@ include file="/WEB-INF/views/admin/common/header.jsp" %>
<%@ include file="/WEB-INF/views/admin/common/sidebar.jsp" %>
<main class="adm-main">
    <c:if test="${not empty successMsg}">
        <div style="background:#ECFDF5;border:1px solid #BBF7D0;color:#166534;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:14px">
            <c:out value="${successMsg}"/>
        </div>
    </c:if>
    <c:if test="${not empty errorMsg}">
        <div style="background:#FEF2F2;border:1px solid #FECACA;color:#B91C1C;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:14px">
            <c:out value="${errorMsg}"/>
        </div>
    </c:if>
    <div class="adm-page-head">
        <div class="adm-page-head-left">
            <h1 class="adm-page-title">FAQ</h1>
            <p class="adm-page-desc">자주 묻는 질문을 관리하세요.</p>
        </div>
        <div class="adm-page-actions">
            <a href="${contextPath}/admin/cms/faq/form" class="adm-filter-btn primary" style="text-decoration:none;display:inline-flex;align-items:center;gap:6px">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="16" height="16"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                FAQ 등록
            </a>
        </div>
    </div>
    <div class="adm-card">
        <div class="adm-card-head">
            <span class="adm-card-head-title">FAQ 목록</span>
            <span class="adm-card-head-sub">총 4건</span>
        </div>
        <div class="adm-table-wrap">
            <table class="adm-table">
                <thead>
                    <tr><th>번호</th><th>카테고리</th><th>질문</th><th>노출</th><th>등록일</th><th>관리</th></tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty faqList}">
                            <tr>
                                <td colspan="6" style="text-align:center;padding:40px;color:#999">
                                    등록된 FAQ가 없습니다.
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="item" items="${faqList}">
                                <tr>
                                    <td><c:out value="${item.faqId}"/></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${item.categoryCd eq 'SERVICE'}">서비스</c:when>
                                            <c:when test="${item.categoryCd eq 'ORDER'}">주문/배송</c:when>
                                            <c:when test="${item.categoryCd eq 'MEMBER'}">회원</c:when>
                                            <c:when test="${item.categoryCd eq 'RESERVE'}">예약</c:when>
                                            <c:otherwise><c:out value="${item.categoryCd}"/></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td><strong><c:out value="${item.question}"/></strong></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${item.visibleYn eq 'Y'}">
                                                <span class="adm-badge active">노출</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="adm-badge">숨김</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <fmt:formatDate value="${item.regDate}" pattern="yyyy.MM.dd"/>
                                    </td>
                                    <td>
                                        <a href="${contextPath}/admin/cms/faq/form?faqId=${item.faqId}" class="adm-btn blue">수정</a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</main>
<%@ include file="/WEB-INF/views/admin/common/footer.jsp" %>
