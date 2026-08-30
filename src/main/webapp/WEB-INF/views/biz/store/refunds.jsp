<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%-- 2026/08/04 장우철 — 사업자 환불신청 처리 목록 --%>
<%-- 2026/08/11 장우철 — P8: 숙소 예약관리와 유사한 탭·카드·뱃지 UI --%>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="반려동물 쇼핑몰" />
<c:set var="bizPage" value="refunds" />
<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_store.jsp" %>

<main class="biz-main">
  <div class="biz-page-head">
    <h1 class="biz-page-title">환불 신청</h1>
    <p class="biz-page-desc">상품 환불 신청을 확인하고 승인·거절·회수완료를 처리하세요.</p>
  </div>

  <c:if test="${not empty msg}">
    <div style="margin-bottom:12px;padding:12px 16px;background:#E8F8F1;color:#1F8464;border-radius:8px;font-size:14px">${msg}</div>
  </c:if>
  <c:if test="${not empty errorMsg}">
    <div style="margin-bottom:12px;padding:12px 16px;background:#FEF2F2;color:#B91C1C;border-radius:8px;font-size:14px">${errorMsg}</div>
  </c:if>

  <div class="biz-card">
    <div class="biz-card-head" style="padding:20px 20px 0;border-bottom:none">
      <span>환불 목록</span>
      <small>처리 대기 <fmt:formatNumber value="${requestedCount + returningCount}" pattern="#,###"/>건</small>
    </div>

    <div style="padding:12px 20px 0">
      <div class="biz-tabs">
        <a href="${contextPath}/biz/store/refunds?statusCd=REQUESTED"
           class="biz-tab ${selectedStatusCd == 'REQUESTED' ? 'active' : ''}">
          신청대기<span class="biz-tab-count">${requestedCount}</span>
        </a>
        <a href="${contextPath}/biz/store/refunds?statusCd=RETURNING"
           class="biz-tab ${selectedStatusCd == 'RETURNING' ? 'active' : ''}">
          환불진행<span class="biz-tab-count">${returningCount}</span>
        </a>
        <a href="${contextPath}/biz/store/refunds?statusCd=DONE"
           class="biz-tab ${selectedStatusCd == 'DONE' ? 'active' : ''}">
          환불완료<span class="biz-tab-count">${doneCount}</span>
        </a>
        <a href="${contextPath}/biz/store/refunds?statusCd=REJECTED"
           class="biz-tab ${selectedStatusCd == 'REJECTED' ? 'active' : ''}">
          거절<span class="biz-tab-count">${rejectedCount}</span>
        </a>
      </div>
    </div>

    <table class="biz-table">
      <thead>
        <tr>
          <th style="width:12%">신청일</th>
          <th style="width:12%">주문번호</th>
          <th style="width:10%">구매자</th>
          <th style="width:22%">상품</th>
          <th style="width:10%">유형</th>
          <th style="width:10%">상품금액</th>
          <th style="width:10%">상태</th>
          <th>관리</th>
        </tr>
      </thead>
      <tbody>
        <c:choose>
          <c:when test="${empty returnList}">
            <tr><td colspan="8" style="text-align:center;color:#999;padding:40px 0">해당하는 환불 신청이 없습니다.</td></tr>
          </c:when>
          <c:otherwise>
            <c:forEach var="r" items="${returnList}">
              <tr>
                <td><fmt:formatDate value="${r.returnRequestedAt}" pattern="yyyy.MM.dd HH:mm"/></td>
                <td><c:out value="${r.orderNo}"/></td>
                <td><c:out value="${r.buyerName}"/></td>
                <td>
                  <c:out value="${r.productName}"/>
                  <c:if test="${not empty r.optionColor || not empty r.optionSize}">
                    <div style="font-size:11px;color:#888;margin-top:2px">
                      <c:if test="${not empty r.optionColor}"><c:out value="${r.optionColor}"/></c:if>
                      <c:if test="${not empty r.optionColor && not empty r.optionSize}"> · </c:if>
                      <c:if test="${not empty r.optionSize}"><c:out value="${r.optionSize}"/></c:if>
                      · ${r.qty}개
                    </div>
                  </c:if>
                </td>
                <td>
                  <c:choose>
                    <c:when test="${r.returnReasonCd == 'DEFECT'}">상품이상</c:when>
                    <c:otherwise>단순변심</c:otherwise>
                  </c:choose>
                </td>
                <td><fmt:formatNumber value="${r.totalPrice}" pattern="#,###"/>원</td>
                <td>
                  <c:choose>
                    <c:when test="${r.returnStatusCd == 'REQUESTED'}"><span class="bs-badge bs-wait">신청대기</span></c:when>
                    <c:when test="${r.returnStatusCd == 'RETURNING'}"><span class="bs-badge bs-prep">환불진행</span></c:when>
                    <c:when test="${r.returnStatusCd == 'DONE'}"><span class="bs-badge bs-done">환불완료</span></c:when>
                    <c:when test="${r.returnStatusCd == 'REJECTED'}"><span class="bs-badge bs-cancel">거절</span></c:when>
                    <c:otherwise><span class="bs-badge bs-empty">${r.returnStatusCd}</span></c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <a class="biz-btn" style="text-decoration:none"
                     href="${contextPath}/biz/store/refunds/detail?orderItemId=${r.orderItemId}">상세</a>
                </td>
              </tr>
            </c:forEach>
          </c:otherwise>
        </c:choose>
      </tbody>
    </table>
  </div>
</main>

<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>
