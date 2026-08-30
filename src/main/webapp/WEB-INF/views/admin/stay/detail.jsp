<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%-- 2026/08/13 장우철 — 관리자 숙소 상세 · 객실 운영 상태 --%>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="adminPage"   value="stay-list" />
<%@ include file="/WEB-INF/views/admin/common/header.jsp" %>
<%@ include file="/WEB-INF/views/admin/common/sidebar.jsp" %>

<style>
  .sd-card{background:#fff;border:1px solid #E4E6ED;border-radius:12px;padding:20px;margin-bottom:16px}
  .sd-row{display:flex;justify-content:space-between;gap:16px;padding:10px 0;border-bottom:1px solid #F3F4F6;font-size:14px}
  .sd-row:last-child{border-bottom:none}
  .sd-row span:first-child{color:#888;min-width:100px;flex-shrink:0}
  .sd-title{font-size:15px;font-weight:700;margin-bottom:12px}
</style>

<main class="adm-main">
  <div class="adm-page-head">
    <div class="adm-page-head-left">
      <h1 class="adm-page-title">숙소 상세</h1>
      <p class="adm-page-desc"><c:out value="${stay.name}"/></p>
    </div>
    <div class="adm-page-actions">
      <a href="${contextPath}/admin/stay/list" class="adm-filter-btn outline" style="text-decoration:none">← 목록</a>
      <a href="${contextPath}/stay/detail?id=${stay.stayId}" target="_blank" class="adm-filter-btn outline" style="text-decoration:none">사용자 화면</a>
    </div>
  </div>

  <div class="sd-card">
    <div class="sd-title">숙소 정보</div>
    <div class="sd-row">
      <span>상태</span>
      <span>
        <c:choose>
          <c:when test="${stay.statusCd eq 'ACTIVE' or stay.statusCd eq 'NORMAL'}"><span class="adm-badge active">운영중</span></c:when>
          <c:otherwise><span class="adm-badge inactive"><c:out value="${stay.statusCd}"/></span></c:otherwise>
        </c:choose>
      </span>
    </div>
    <div class="sd-row"><span>숙소명</span><span><c:out value="${stay.name}"/></span></div>
    <div class="sd-row"><span>사업자</span><span><c:out value="${stay.bizName}"/></span></div>
    <div class="sd-row"><span>연락처</span><span><c:out value="${stay.phone}"/></span></div>
    <div class="sd-row">
      <span>주소</span>
      <span><c:out value="${stay.addr}"/> <c:out value="${stay.addrDetail}"/></span>
    </div>
    <div class="sd-row"><span>지역</span><span><c:out value="${stay.region}"/></span></div>
    <div class="sd-row">
      <span>체크인/아웃</span>
      <span>
        <c:out value="${stay.checkIn}"/> / <c:out value="${stay.checkOut}"/>
      </span>
    </div>
    <div class="sd-row">
      <span>등록일</span>
      <span>
        <c:choose>
          <c:when test="${not empty stay.approveDate}"><c:out value="${stay.approveDate}"/></c:when>
          <c:otherwise>-</c:otherwise>
        </c:choose>
      </span>
    </div>
  </div>

  <div class="sd-card" style="padding:0">
    <div style="padding:20px 20px 12px">
      <div class="sd-title" style="margin-bottom:4px">객실 운영 상태</div>
      <div style="font-size:12px;color:#888">
        운영중 ${stay.approveRoomCount}
        · 운영중지 ${stay.holdRoomCount}
        · 운영종료 ${stay.closedRoomCount}
        (총 ${stay.roomCount}실)
      </div>
    </div>
    <div class="adm-table-wrap">
      <table class="adm-table">
        <thead>
          <tr>
            <th>객실명</th>
            <th>1박 요금</th>
            <th>인원</th>
            <th>반려동물</th>
            <th>상태</th>
          </tr>
        </thead>
        <tbody>
          <c:choose>
            <c:when test="${empty rooms}">
              <tr><td colspan="5" style="text-align:center;padding:40px;color:#999;">등록된 객실이 없습니다.</td></tr>
            </c:when>
            <c:otherwise>
              <c:forEach var="room" items="${rooms}">
                <c:set var="roomStatus" value="${empty room.statusCd ? 'APPROVE' : room.statusCd}" />
                <c:if test="${roomStatus eq 'DELETED'}"><c:set var="roomStatus" value="CLOSED" /></c:if>
                <tr>
                  <td><c:out value="${room.name}"/></td>
                  <td><fmt:formatNumber value="${room.pricePerNight}" pattern="#,###"/>원</td>
                  <td>${room.capacity}명</td>
                  <td>${room.petLimit}마리</td>
                  <td>
                    <c:choose>
                      <c:when test="${roomStatus eq 'HOLD'}"><span class="adm-badge warning">운영중지</span></c:when>
                      <c:when test="${roomStatus eq 'CLOSED'}"><span class="adm-badge cancel">운영종료</span></c:when>
                      <c:otherwise><span class="adm-badge active">운영중</span></c:otherwise>
                    </c:choose>
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
