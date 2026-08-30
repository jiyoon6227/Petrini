<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="adminPage"   value="product-list" />
<%@ include file="/WEB-INF/views/admin/common/header.jsp" %>
<%@ include file="/WEB-INF/views/admin/common/sidebar.jsp" %>

<%-- 2026/08/11 장우철 — 더미 제거, 전 사업자 등록 상품 실조회 --%>
<main class="adm-main">
    <div class="adm-page-head">
        <div class="adm-page-head-left">
            <h1 class="adm-page-title">상품 관리</h1>
            <p class="adm-page-desc">전체 사업자가 등록한 상품을 조회합니다.</p>
        </div>
    </div>

    <div class="adm-card">
        <div class="adm-card-head">
            <span class="adm-card-head-title">상품 목록</span>
            <span class="adm-card-head-sub">총 <fmt:formatNumber value="${totalCount}" pattern="#,###"/>건</span>
        </div>
        <div class="adm-card-body" style="padding-bottom:0">
            <form class="adm-filter-bar" method="get" action="${contextPath}/admin/store/product-list">
                <input type="text" name="keyword" class="adm-filter-input"
                       value="${keyword}" placeholder="상품명, 사업자명으로 검색">
                <select name="statusCd" class="adm-filter-select">
                    <option value="">판매 상태 전체</option>
                    <option value="NORMAL" ${statusCd eq 'NORMAL' ? 'selected' : ''}>판매중</option>
                    <option value="SOLDOUT" ${statusCd eq 'SOLDOUT' ? 'selected' : ''}>품절</option>
                    <option value="WAITING" ${statusCd eq 'WAITING' ? 'selected' : ''}>입고대기</option>
                    <option value="STOPPED" ${statusCd eq 'STOPPED' ? 'selected' : ''}>판매중지</option>
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
                        <th>상품 이미지</th>
                        <th>상품명</th>
                        <th>사업자</th>
                        <th>카테고리</th>
                        <th>가격</th>
                        <th>재고</th>
                        <th>상태</th>
                        <th>등록일</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty productList}">
                            <tr><td colspan="8" style="text-align:center;padding:40px;color:#999;">등록된 상품이 없습니다.</td></tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="p" items="${productList}">
                                <tr>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty p.thumbnailUrl}">
                                               <img src="${contextPath}/upload/${p.thumbnailUrl}" style="width:44px;height:44px;border-radius:8px;object-fit:cover" alt=""
                                                    onerror="this.src='https://placehold.co/44x44/EAF7F2/2BAB82?text=IMG'">
                                            </c:when>
                                            <c:otherwise>
                                                <img src="https://placehold.co/44x44/EAF7F2/2BAB82?text=IMG" style="width:44px;height:44px;border-radius:8px;object-fit:cover" alt="">
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td><strong>${p.productName}</strong></td>
                                    <td>${p.bizName}</td>
                                    <td>${p.categoryName}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${p.salePrice != null and p.salePrice > 0}">
                                                <fmt:formatNumber value="${p.salePrice}" pattern="#,###"/>원
                                            </c:when>
                                            <c:otherwise>
                                                <fmt:formatNumber value="${p.price}" pattern="#,###"/>원
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>${p.stockQty}개</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${p.statusCd eq 'NORMAL'}"><span class="adm-badge active">판매중</span></c:when>
                                            <c:when test="${p.statusCd eq 'SOLDOUT'}"><span class="adm-badge cancel">품절</span></c:when>
                                            <c:when test="${p.statusCd eq 'WAITING'}"><span class="adm-badge wait">입고대기</span></c:when>
                                            <c:when test="${p.statusCd eq 'STOPPED'}"><span class="adm-badge cancel">판매중지</span></c:when>
                                            <c:otherwise><span class="adm-badge">${p.statusCd}</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>${p.regDate}</td>
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
                        <c:url var="pageUrl" value="/admin/store/product-list">
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
