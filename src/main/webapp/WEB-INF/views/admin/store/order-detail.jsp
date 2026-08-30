<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="adminPage"   value="order-list" />
<%@ include file="/WEB-INF/views/admin/common/header.jsp" %>
<%@ include file="/WEB-INF/views/admin/common/sidebar.jsp" %>

<%-- 2026/08/11 장우철 — 더미 상세 제거, 실주문 요약 표시 --%>
<main class="adm-main">
    <div class="adm-page-head">
        <div class="adm-page-head-left">
            <h1 class="adm-page-title">주문 상세</h1>
            <p class="adm-page-desc">
                <a href="${contextPath}/admin/store/order-list" style="color:inherit;">← 주문 목록</a>
            </p>
        </div>
    </div>

    <c:choose>
        <c:when test="${empty order}">
            <div class="adm-card"><div class="adm-card-body" style="padding:40px;text-align:center;color:#999;">
                주문을 찾을 수 없습니다.
            </div></div>
        </c:when>
        <c:otherwise>
            <div class="adm-card">
                <div class="adm-card-head">
                    <span class="adm-card-head-title">${order.orderNo}</span>
                    <span class="adm-card-head-sub">${order.orderStatus}</span>
                </div>
                <div class="adm-card-body">
                    <table class="adm-table">
                        <tbody>
                            <tr><th style="width:140px">사업자</th><td>${order.bizName}</td></tr>
                            <tr><th>주문자</th><td>${order.buyerName}</td></tr>
                            <tr><th>상품</th>
                                <td>
                                    ${order.firstProductName}
                                    <c:if test="${order.itemCount != null and order.itemCount > 1}">
                                        외 ${order.itemCount - 1}건
                                    </c:if>
                                </td>
                            </tr>
                            <tr><th>결제금액</th>
                                <td><fmt:formatNumber value="${order.payAmount}" pattern="#,###"/>원</td>
                            </tr>
                            <tr><th>결제수단</th>
                                <td>
                                    <c:choose>
                                        <c:when test="${empty order.payMethod}">-</c:when>
                                        <c:when test="${order.payMethod eq 'CARD'}">카드</c:when>
                                        <c:when test="${order.payMethod eq 'BILLING'}">등록카드</c:when>
                                        <c:otherwise>${order.payMethod}</c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                            <tr><th>주문일</th><td>${order.orderDate}</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</main>

<%@ include file="/WEB-INF/views/admin/common/footer.jsp" %>
