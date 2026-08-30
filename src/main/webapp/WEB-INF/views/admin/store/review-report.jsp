<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="adminPage"   value="review-report" />
<%@ include file="/WEB-INF/views/admin/common/header.jsp" %>
<%@ include file="/WEB-INF/views/admin/common/sidebar.jsp" %>

<main class="adm-main">
    <div class="adm-page-head">
        <div class="adm-page-head-left">
            <h1 class="adm-page-title">리뷰 관리</h1>
            <p class="adm-page-desc">사업자가 요청한 리뷰 삭제건을 승인·반려하세요.</p>
        </div>
    </div>

    <%-- 지윤 26.07.21 추가: 승인/반려 후 플래시 메시지 --%>
    <c:if test="${not empty msg}">
        <div class="adm-card" style="padding:14px 20px;margin-bottom:16px;color:#16A34A;font-weight:700">${msg}</div>
    </c:if>

    <div class="adm-card">
        <div class="adm-card-head">
            <span class="adm-card-head-title">삭제요청 대기 목록</span>
            <span class="adm-card-head-sub" style="color:#E74C3C;font-weight:700">대기중 ${fn:length(reportList)}건</span>
        </div>

        <c:choose>
            <c:when test="${empty reportList}">
                <p style="padding:40px 20px;text-align:center;color:#888">대기중인 삭제요청이 없습니다.</p>
            </c:when>
            <c:otherwise>
                <div class="adm-table-wrap">
                    <table class="adm-table">
                        <thead>
                            <tr>
                                <th>사업자</th>
                                <th>상품명</th>
                                <th>리뷰 내용</th>
                                <th>별점</th>
                                <th>작성자</th>
                                <th>삭제 사유</th>
                                <th>요청일</th>
                                <th>처리</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="rr" items="${reportList}">
                                <tr>
                                    <td>${rr.bizName}</td>
                                    <td>${rr.productName}</td>
                                    <td style="max-width:220px;white-space:normal">${rr.content}</td>
                                    <td>★ ${rr.rating}</td>
                                    <td>${rr.nickname}</td>
                                    <td style="max-width:180px;white-space:normal">${empty rr.reason ? '-' : rr.reason}</td>
                                    <td><fmt:formatDate value="${rr.regDate}" pattern="yyyy-MM-dd HH:mm"/></td>
                                    <td style="white-space:nowrap">
                                        <form method="post" action="${contextPath}/admin/store/review-report/${rr.reportId}/approve" style="display:inline">
                                            <!--HYJ 26.08.05-->
                                            <input type="hidden" name="_csrf" value="${_csrf}">
                                            
                                            <input type="hidden" name="reviewId" value="${rr.reviewId}">
                                            <button type="submit" class="adm-btn green" onclick="return confirm('이 리뷰를 삭제하시겠습니까? 되돌릴 수 없습니다.')">승인</button>
                                        </form>
                                        <form method="post" action="${contextPath}/admin/store/review-report/${rr.reportId}/reject" style="display:inline">
                                            <!--HYJ 26.08.05-->
                                            <input type="hidden" name="_csrf" value="${_csrf}">
                                            
                                            <button type="submit" class="adm-btn red" onclick="return confirm('삭제요청을 반려하시겠습니까?')">반려</button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</main>

<%@ include file="/WEB-INF/views/admin/common/footer.jsp" %>