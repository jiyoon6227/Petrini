<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="adminPage"   value="order-list" />
<%@ include file="/WEB-INF/views/admin/common/header.jsp" %>
<%@ include file="/WEB-INF/views/admin/common/sidebar.jsp" %>

<%-- 2026/08/11 장우철 — 더미 4건 제거, 전 사업자 주문 실조회 --%>
<main class="adm-main">
    <div class="adm-page-head">
        <div class="adm-page-head-left">
            <h1 class="adm-page-title">주문 관리</h1>
            <p class="adm-page-desc">전체 사업자가 받은 주문을 조회합니다.</p>
        </div>
    </div>

    <div class="adm-card">
        <div class="adm-card-head">
            <span class="adm-card-head-title">주문 목록</span>
            <span class="adm-card-head-sub">총 <fmt:formatNumber value="${totalCount}" pattern="#,###"/>건</span>
        </div>
        <div class="adm-card-body" style="padding-bottom:0">
            <form class="adm-filter-bar" method="get" action="${contextPath}/admin/store/order-list">
                <input type="text" name="keyword" class="adm-filter-input"
                       value="${keyword}" placeholder="주문번호, 회원명, 사업자명으로 검색">
                <select name="statusCd" class="adm-filter-select">
                    <option value="">주문 상태 전체</option>
                    <option value="PAID" ${statusCd eq 'PAID' ? 'selected' : ''}>결제완료</option>
                    <option value="READY" ${statusCd eq 'READY' ? 'selected' : ''}>배송준비</option>
                    <option value="SHIPPING" ${statusCd eq 'SHIPPING' ? 'selected' : ''}>배송중</option>
                    <option value="DONE" ${statusCd eq 'DONE' ? 'selected' : ''}>배송완료/구매확정</option>
                    <option value="CANCEL" ${statusCd eq 'CANCEL' ? 'selected' : ''}>취소</option>
                </select>
                <button type="submit" class="adm-filter-btn primary">
                    <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                    검색
                </button>
            </form>
        </div>
        <div class="adm-table-wrap">
            <table class="adm-table">
                <thead>
                    <tr>
                        <th>주문번호</th>
                        <th>사업자</th>
                        <th>주문자</th>
                        <th>상품</th>
                        <th>금액</th>
                        <th>결제수단</th>
                        <th>상태</th>
                        <th>주문일</th>
                        <th>처리</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty orderList}">
                            <tr><td colspan="9" style="text-align:center;padding:40px;color:#999;">주문 내역이 없습니다.</td></tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="o" items="${orderList}">
                                <tr>
                                    <td>${o.orderNo}</td>
                                    <td>${o.bizName}</td>
                                    <td>${o.buyerName}</td>
                                    <td>
                                        ${o.firstProductName}
                                        <c:if test="${o.itemCount != null and o.itemCount > 1}">
                                            외 ${o.itemCount - 1}건
                                        </c:if>
                                    </td>
                                    <td><fmt:formatNumber value="${o.payAmount}" pattern="#,###"/>원</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${empty o.payMethod}">-</c:when>
                                            <c:when test="${o.payMethod eq 'CARD'}">카드</c:when>
                                            <c:when test="${o.payMethod eq 'BILLING'}">등록카드</c:when>
                                            <c:otherwise>${o.payMethod}</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${o.orderStatus eq 'PAID'}"><span class="adm-badge wait">결제완료</span></c:when>
                                            <c:when test="${o.orderStatus eq 'READY'}"><span class="adm-badge wait">배송준비</span></c:when>
                                            <c:when test="${o.orderStatus eq 'SHIPPING'}"><span class="adm-badge shipping">배송중</span></c:when>
                                            <c:when test="${o.orderStatus eq 'DONE'}"><span class="adm-badge done">배송완료</span></c:when>
                                            <c:when test="${o.orderStatus eq 'CANCEL'}"><span class="adm-badge cancel">취소</span></c:when>
                                            <c:otherwise><span class="adm-badge">${o.orderStatus}</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>${o.orderDate}</td>
                                    <td>
                                        <a href="${contextPath}/admin/store/order-detail?id=${o.orderId}" class="adm-btn blue">상세</a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
        <c:if test="${totalPages > 1}">
            <div style="padding:16px 20px;border-top:1px solid #E4E6ED;display:flex;justify-content:center">
                <div class="adm-pagination" style="margin:0">
                    <c:forEach begin="1" end="${totalPages}" var="pno">
                        <c:url var="pageUrl" value="/admin/store/order-list">
                            <c:param name="page" value="${pno}"/>
                            <c:if test="${not empty keyword}"><c:param name="keyword" value="${keyword}"/></c:if>
                            <c:if test="${not empty statusCd}"><c:param name="statusCd" value="${statusCd}"/></c:if>
                        </c:url>
                        <a href="${pageUrl}" class="adm-page-btn ${page eq pno ? 'active' : ''}">${pno}</a>
                    </c:forEach>
                </div>
            </div>
        </c:if>
    </div>
</main>

<%@ include file="/WEB-INF/views/admin/common/footer.jsp" %>
