<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%-- 2026/08/13 장우철 — 관리자 숙소 관리 목록 --%>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="adminPage"   value="stay-list" />
<%@ include file="/WEB-INF/views/admin/common/header.jsp" %>
<%@ include file="/WEB-INF/views/admin/common/sidebar.jsp" %>

<main class="adm-main">
  <div class="adm-page-head">
    <div class="adm-page-head-left">
      <h1 class="adm-page-title">숙소 관리</h1>
      <p class="adm-page-desc">등록된 숙소를 조회하고, 객실 운영 상태를 확인하세요.</p>
    </div>
  </div>

  <c:if test="${not empty errorMsg}">
    <div style="background:#FEF2F2;border:1px solid #FECACA;color:#B91C1C;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:14px">${errorMsg}</div>
  </c:if>

  <div class="adm-card">
    <div class="adm-card-head">
      <span class="adm-card-head-title">숙소 목록</span>
      <span class="adm-card-head-sub">총 <fmt:formatNumber value="${statusCounts.ALL}" pattern="#,###"/>건</span>
    </div>

    <div style="display:flex;gap:0;border-bottom:1px solid #E4E6ED;padding:0 20px;flex-wrap:wrap">
      <a href="${contextPath}/admin/stay/list?status=ALL&amp;keyword=${keyword}"
         style="padding:12px 14px;font-size:13px;font-weight:${status eq 'ALL' ? '700' : '600'};color:${status eq 'ALL' ? '#3B5BDB' : '#999'};text-decoration:none;border-bottom:2px solid ${status eq 'ALL' ? '#3B5BDB' : 'transparent'};margin-bottom:-1px">
        전체 <span style="background:#F3F4F6;font-size:11px;padding:1px 7px;border-radius:20px;margin-left:4px">${statusCounts.ALL}</span>
      </a>
      <a href="${contextPath}/admin/stay/list?status=ACTIVE&amp;keyword=${keyword}"
         style="padding:12px 14px;font-size:13px;font-weight:${status eq 'ACTIVE' ? '700' : '600'};color:${status eq 'ACTIVE' ? '#3B5BDB' : '#999'};text-decoration:none;border-bottom:2px solid ${status eq 'ACTIVE' ? '#3B5BDB' : 'transparent'};margin-bottom:-1px">
        운영중 <span style="background:#F3F4F6;font-size:11px;padding:1px 7px;border-radius:20px;margin-left:4px">${statusCounts.ACTIVE}</span>
      </a>
    </div>

    <div class="adm-card-body" style="padding-bottom:0">
      <form class="adm-filter-bar" method="get" action="${contextPath}/admin/stay/list">
        <input type="hidden" name="status" value="${status}">
        <input type="text" name="keyword" class="adm-filter-input"
               value="${keyword}" placeholder="숙소명, 사업자명, 주소로 검색">
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
            <th>숙소</th>
            <th>사업자</th>
            <th>주소</th>
            <th>객실</th>
            <th>숙소상태</th>
            <th>등록일</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          <c:choose>
            <c:when test="${empty list}">
              <tr><td colspan="7" style="text-align:center;padding:40px;color:#999;">등록된 숙소가 없습니다.</td></tr>
            </c:when>
            <c:otherwise>
              <c:forEach var="s" items="${list}">
                <tr>
                  <td>
                    <div style="display:flex;align-items:center;gap:10px">
                      <c:choose>
                        <c:when test="${not empty s.thumbPath}">
                          <img src="${contextPath}/upload/${s.thumbPath}" alt=""
                               style="width:44px;height:44px;border-radius:8px;object-fit:cover"
                               onerror="this.style.display='none'">
                        </c:when>
                      </c:choose>
                      <div>
                        <strong><c:out value="${s.name}"/></strong>
                        <c:if test="${not empty s.phone}">
                          <div style="font-size:11px;color:#888;margin-top:2px"><c:out value="${s.phone}"/></div>
                        </c:if>
                      </div>
                    </div>
                  </td>
                  <td><c:out value="${s.bizName}"/></td>
                  <td>
                    <c:out value="${s.addr}"/>
                    <c:if test="${not empty s.addrDetail}">
                      <div style="font-size:11px;color:#888;margin-top:2px"><c:out value="${s.addrDetail}"/></div>
                    </c:if>
                  </td>
                  <td>
                    <div style="font-size:12px;line-height:1.6">
                      운영중 ${s.approveRoomCount}
                      <c:if test="${s.holdRoomCount > 0}"><span style="color:#D97706"> · 중지 ${s.holdRoomCount}</span></c:if>
                      <c:if test="${s.closedRoomCount > 0}"><span style="color:#DC2626"> · 종료 ${s.closedRoomCount}</span></c:if>
                      <div style="font-size:11px;color:#888">총 ${s.roomCount}실</div>
                    </div>
                  </td>
                  <td>
                    <c:choose>
                      <c:when test="${s.statusCd eq 'ACTIVE' or s.statusCd eq 'NORMAL'}"><span class="adm-badge active">운영중</span></c:when>
                      <c:otherwise><span class="adm-badge inactive"><c:out value="${s.statusCd}"/></span></c:otherwise>
                    </c:choose>
                  </td>
                  <td>
                    <c:choose>
                      <c:when test="${not empty s.approveDate}"><c:out value="${s.approveDate}"/></c:when>
                      <c:otherwise>-</c:otherwise>
                    </c:choose>
                  </td>
                  <td>
                    <a href="${contextPath}/admin/stay/detail?stayId=${s.stayId}" class="adm-btn blue">상세</a>
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
