<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%-- 2026/07/31 장우철 — 관리자 숙소 예약 목록 --%>
<%-- 2026/08/11 장우철 — 주문관리와 유사 레이아웃 + 결제수단·결제일·한글상태 --%>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="adminPage"   value="reservation-list" />
<%@ include file="/WEB-INF/views/admin/common/header.jsp" %>
<%@ include file="/WEB-INF/views/admin/common/sidebar.jsp" %>

<main class="adm-main">
  <div class="adm-page-head">
    <div class="adm-page-head-left">
      <h1 class="adm-page-title">숙소 예약 관리</h1>
      <p class="adm-page-desc">숙소 예약을 조회하고, 필요 시 전액 환불 취소를 처리하세요.</p>
    </div>
  </div>

  <c:if test="${not empty successMsg}">
    <div style="background:#ECFDF5;border:1px solid #BBF7D0;color:#166534;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:14px">${successMsg}</div>
  </c:if>
  <c:if test="${not empty errorMsg}">
    <div style="background:#FEF2F2;border:1px solid #FECACA;color:#B91C1C;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:14px">${errorMsg}</div>
  </c:if>

  <div class="adm-card">
    <div class="adm-card-head">
      <span class="adm-card-head-title">예약 목록</span>
      <span class="adm-card-head-sub">총 <fmt:formatNumber value="${statusCounts.ALL}" pattern="#,###"/>건</span>
    </div>

    <div style="display:flex;gap:0;border-bottom:1px solid #E4E6ED;padding:0 20px;flex-wrap:wrap">
      <a href="${contextPath}/admin/reservation/list?status=ALL&amp;keyword=${keyword}"
         style="padding:12px 14px;font-size:13px;font-weight:${status eq 'ALL' ? '700' : '600'};color:${status eq 'ALL' ? '#3B5BDB' : '#999'};text-decoration:none;border-bottom:2px solid ${status eq 'ALL' ? '#3B5BDB' : 'transparent'};margin-bottom:-1px">
        전체 <span style="background:#F3F4F6;font-size:11px;padding:1px 7px;border-radius:20px;margin-left:4px">${statusCounts.ALL}</span>
      </a>
      <a href="${contextPath}/admin/reservation/list?status=PENDING&amp;keyword=${keyword}"
         style="padding:12px 14px;font-size:13px;font-weight:${status eq 'PENDING' ? '700' : '600'};color:${status eq 'PENDING' ? '#3B5BDB' : '#999'};text-decoration:none;border-bottom:2px solid ${status eq 'PENDING' ? '#3B5BDB' : 'transparent'};margin-bottom:-1px">
        예약신청 <span style="background:#F3F4F6;font-size:11px;padding:1px 7px;border-radius:20px;margin-left:4px">${statusCounts.PENDING}</span>
      </a>
      <a href="${contextPath}/admin/reservation/list?status=CONFIRMED&amp;keyword=${keyword}"
         style="padding:12px 14px;font-size:13px;font-weight:${status eq 'CONFIRMED' ? '700' : '600'};color:${status eq 'CONFIRMED' ? '#3B5BDB' : '#999'};text-decoration:none;border-bottom:2px solid ${status eq 'CONFIRMED' ? '#3B5BDB' : 'transparent'};margin-bottom:-1px">
        예약확정 <span style="background:#F3F4F6;font-size:11px;padding:1px 7px;border-radius:20px;margin-left:4px">${statusCounts.CONFIRMED}</span>
      </a>
      <a href="${contextPath}/admin/reservation/list?status=CHECKIN&amp;keyword=${keyword}"
         style="padding:12px 14px;font-size:13px;font-weight:${status eq 'CHECKIN' ? '700' : '600'};color:${status eq 'CHECKIN' ? '#3B5BDB' : '#999'};text-decoration:none;border-bottom:2px solid ${status eq 'CHECKIN' ? '#3B5BDB' : 'transparent'};margin-bottom:-1px">
        체크인 <span style="background:#F3F4F6;font-size:11px;padding:1px 7px;border-radius:20px;margin-left:4px">${statusCounts.CHECKIN}</span>
      </a>
      <a href="${contextPath}/admin/reservation/list?status=CHECKOUT&amp;keyword=${keyword}"
         style="padding:12px 14px;font-size:13px;font-weight:${status eq 'CHECKOUT' ? '700' : '600'};color:${status eq 'CHECKOUT' ? '#3B5BDB' : '#999'};text-decoration:none;border-bottom:2px solid ${status eq 'CHECKOUT' ? '#3B5BDB' : 'transparent'};margin-bottom:-1px">
        체크아웃 <span style="background:#F3F4F6;font-size:11px;padding:1px 7px;border-radius:20px;margin-left:4px">${statusCounts.CHECKOUT}</span>
      </a>
      <a href="${contextPath}/admin/reservation/list?status=DONE&amp;keyword=${keyword}"
         style="padding:12px 14px;font-size:13px;font-weight:${status eq 'DONE' ? '700' : '600'};color:${status eq 'DONE' ? '#3B5BDB' : '#999'};text-decoration:none;border-bottom:2px solid ${status eq 'DONE' ? '#3B5BDB' : 'transparent'};margin-bottom:-1px">
        이용완료 <span style="background:#F3F4F6;font-size:11px;padding:1px 7px;border-radius:20px;margin-left:4px">${statusCounts.DONE}</span>
      </a>
      <a href="${contextPath}/admin/reservation/list?status=CANCEL&amp;keyword=${keyword}"
         style="padding:12px 14px;font-size:13px;font-weight:${status eq 'CANCEL' ? '700' : '600'};color:${status eq 'CANCEL' ? '#3B5BDB' : '#999'};text-decoration:none;border-bottom:2px solid ${status eq 'CANCEL' ? '#3B5BDB' : 'transparent'};margin-bottom:-1px">
        취소 <span style="background:#F3F4F6;font-size:11px;padding:1px 7px;border-radius:20px;margin-left:4px">${statusCounts.CANCEL}</span>
      </a>
    </div>

    <div class="adm-card-body" style="padding-bottom:0">
      <form class="adm-filter-bar" method="get" action="${contextPath}/admin/reservation/list">
        <input type="hidden" name="status" value="${status}">
        <input type="text" name="keyword" class="adm-filter-input"
               value="${keyword}" placeholder="예약번호, 회원명, 숙소명으로 검색">
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
            <th>예약번호</th>
            <th>숙소</th>
            <th>회원</th>
            <th>체크인~아웃</th>
            <th>금액</th>
            <th>결제수단</th>
            <th>상태</th>
            <th>결제일</th>
            <th>처리</th>
          </tr>
        </thead>
        <tbody>
          <c:choose>
            <c:when test="${empty list}">
              <tr><td colspan="9" style="text-align:center;padding:40px;color:#999;">예약이 없습니다.</td></tr>
            </c:when>
            <c:otherwise>
              <c:forEach var="r" items="${list}">
                <tr>
                  <td><c:out value="${r.resvNo}"/></td>
                  <td>
                    <c:out value="${r.stayName}"/>
                    <c:if test="${not empty r.roomName}">
                      <div style="font-size:11px;color:#888;margin-top:2px"><c:out value="${r.roomName}"/></div>
                    </c:if>
                  </td>
                  <td><c:out value="${r.memberName}"/></td>
                  <td>
                    <fmt:formatDate value="${r.checkinDate}" pattern="yyyy.MM.dd"/>
                    ~
                    <fmt:formatDate value="${r.checkoutDate}" pattern="MM.dd"/>
                  </td>
                  <td>
                    <c:choose>
                      <c:when test="${not empty r.totalAmount}">
                        <fmt:formatNumber value="${r.totalAmount}" pattern="#,###"/>원
                      </c:when>
                      <c:otherwise>-</c:otherwise>
                    </c:choose>
                  </td>
                  <td>
                    <c:choose>
                      <c:when test="${empty r.payMethod}">-</c:when>
                      <c:when test="${r.payMethod eq 'BILLING'}">등록카드(빌링)</c:when>
                      <c:otherwise>토스결제</c:otherwise>
                    </c:choose>
                  </td>
                  <td>
                    <c:choose>
                      <c:when test="${r.statusCd eq 'PENDING'}"><span class="adm-badge wait">예약신청</span></c:when>
                      <c:when test="${r.statusCd eq 'CONFIRMED'}"><span class="adm-badge done">예약확정</span></c:when>
                      <c:when test="${r.statusCd eq 'CHECKIN'}"><span class="adm-badge shipping">체크인</span></c:when>
                      <c:when test="${r.statusCd eq 'CHECKOUT'}"><span class="adm-badge shipping">체크아웃</span></c:when>
                      <c:when test="${r.statusCd eq 'DONE'}"><span class="adm-badge done">이용완료</span></c:when>
                      <c:when test="${r.statusCd eq 'CANCEL' or r.statusCd eq 'REJECTED'}"><span class="adm-badge cancel">취소</span></c:when>
                      <c:otherwise><span class="adm-badge"><c:out value="${r.statusCd}"/></span></c:otherwise>
                    </c:choose>
                  </td>
                  <td>
                    <c:choose>
                      <c:when test="${not empty r.payDate}">
                        <fmt:formatDate value="${r.payDate}" pattern="yyyy.MM.dd HH:mm"/>
                      </c:when>
                      <c:otherwise>-</c:otherwise>
                    </c:choose>
                  </td>
                  <td>
                    <a href="${contextPath}/admin/reservation/detail?resvId=${r.resvId}" class="adm-btn blue">상세</a>
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
