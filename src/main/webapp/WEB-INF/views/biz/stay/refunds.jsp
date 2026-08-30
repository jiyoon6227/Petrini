<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%-- 2026-08-11 박유정 — 사업자 숙소 환불신청 조회 (승인은 관리자) --%>
<%-- 2026/08/18 장우철 — 탭 건수·처리완료(APPROVED)/거절(REJECTED) 목록 분리 --%>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="bizPage" value="refunds" />
<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_stay.jsp" %>

<main class="biz-main">
  <div class="biz-page-head">
    <h1 class="biz-page-title">환불 신청</h1>
    <p class="biz-page-desc">체크인 이후 접수된 환불 신청을 확인합니다. 승인·거절은 관리자가 처리합니다.</p>
  </div>

  <div class="biz-card">
    <div style="padding:20px 20px 0">
      <div class="biz-tabs">
        <a href="${contextPath}/biz/stay/refunds?status=ALL"
           class="biz-tab ${status eq 'ALL' ? 'active' : ''}">
          전체<span class="biz-tab-count">${allCount}</span>
        </a>
        <a href="${contextPath}/biz/stay/refunds?status=WAIT"
           class="biz-tab ${status eq 'WAIT' ? 'active' : ''}">
          대기<span class="biz-tab-count">${waitCount}</span>
        </a>
        <a href="${contextPath}/biz/stay/refunds?status=DONE"
           class="biz-tab ${status eq 'DONE' ? 'active' : ''}">
          처리완료<span class="biz-tab-count">${doneCount}</span>
        </a>
        <a href="${contextPath}/biz/stay/refunds?status=REJECTED"
           class="biz-tab ${status eq 'REJECTED' ? 'active' : ''}">
          거절<span class="biz-tab-count">${rejectedCount}</span>
        </a>
      </div>
    </div>

    <table class="biz-table">
      <thead>
        <tr>
          <th>신청일</th>
          <th>예약번호</th>
          <th>회원</th>
          <th>예약상태</th>
          <th>결제금액</th>
          <th>처리상태</th>
        </tr>
      </thead>
      <tbody>
        <c:choose>
          <c:when test="${empty refundList}">
            <tr><td colspan="6" style="text-align:center;color:#999;padding:24px 0">해당하는 환불 신청이 없습니다.</td></tr>
          </c:when>
          <c:otherwise>
            <c:forEach var="r" items="${refundList}">
              <tr>
                <td><fmt:formatDate value="${r.regDate}" pattern="yyyy-MM-dd HH:mm"/></td>
                <td><c:out value="${r.resvNo}"/></td>
                <td>
                  <c:out value="${r.memberName}"/>
                  <c:if test="${not empty r.memberEmail}">
                    <div style="font-size:11px;color:#888"><c:out value="${r.memberEmail}"/></div>
                  </c:if>
                </td>
                <td><c:out value="${r.resvStatusCd}"/></td>
                <td><fmt:formatNumber value="${r.totalAmount}" pattern="#,###"/>원</td>
                <td>
                  <c:choose>
                    <c:when test="${r.statusCd eq 'WAIT'}"><span class="bs-badge bs-wait">대기</span></c:when>
                    <c:when test="${r.statusCd eq 'APPROVED'}"><span class="bs-badge bs-done">승인</span></c:when>
                    <c:when test="${r.statusCd eq 'REJECTED'}"><span class="bs-badge bs-cancel">거절</span></c:when>
                    <c:when test="${r.statusCd eq 'DONE'}"><span class="bs-badge bs-done">처리완료</span></c:when>
                    <c:otherwise><span class="bs-badge bs-empty"><c:out value="${r.statusCd}"/></span></c:otherwise>
                  </c:choose>
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
