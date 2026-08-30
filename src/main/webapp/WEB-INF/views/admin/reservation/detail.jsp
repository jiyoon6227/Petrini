<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%-- 2026/07/31 장우철 — 관리자 숙소 예약 상세 · 전액 환불 취소 --%>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="adminPage"   value="reservation-list" />
<%@ include file="/WEB-INF/views/admin/common/header.jsp" %>
<%@ include file="/WEB-INF/views/admin/common/sidebar.jsp" %>

<style>
  .rd-card{background:#fff;border:1px solid #E4E6ED;border-radius:12px;padding:20px;margin-bottom:16px}
  .rd-row{display:flex;justify-content:space-between;gap:16px;padding:10px 0;border-bottom:1px solid #F3F4F6;font-size:14px}
  .rd-row:last-child{border-bottom:none}
  .rd-row span:first-child{color:#888;min-width:100px}
  .rd-cancel{background:#FFF8F8;border:1px solid #FECACA;border-radius:12px;padding:20px}
  .rd-cancel textarea{width:100%;min-height:90px;border:1px solid #E4E6ED;border-radius:8px;padding:10px;box-sizing:border-box}
  .rd-cancel .btn{margin-top:12px;background:#DC2626;color:#fff;border:none;border-radius:8px;padding:10px 16px;font-weight:700;cursor:pointer}
</style>

<main class="adm-main">
  <div class="adm-page-head">
    <div class="adm-page-head-left">
      <h1 class="adm-page-title">숙소 예약 상세</h1>
      <p class="adm-page-desc">예약번호 <strong><c:out value="${reservation.resvNo}"/></strong></p>
    </div>
    <div class="adm-page-actions">
      <a href="${contextPath}/admin/reservation/list" class="adm-filter-btn outline" style="text-decoration:none">← 목록</a>
    </div>
  </div>

  <c:if test="${not empty successMsg}">
    <div style="background:#ECFDF5;border:1px solid #BBF7D0;color:#166534;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:14px">${successMsg}</div>
  </c:if>
  <c:if test="${not empty errorMsg}">
    <div style="background:#FEF2F2;border:1px solid #FECACA;color:#B91C1C;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:14px">${errorMsg}</div>
  </c:if>

  <div class="rd-card">
    <div class="rd-row">
      <span>상태</span>
      <span>
        <c:choose>
          <c:when test="${reservation.statusCd eq 'PENDING'}">예약신청</c:when>
          <c:when test="${reservation.statusCd eq 'CONFIRMED'}">예약확정</c:when>
          <c:when test="${reservation.statusCd eq 'CHECKIN'}">체크인</c:when>
          <c:when test="${reservation.statusCd eq 'CHECKOUT'}">체크아웃</c:when>
          <c:when test="${reservation.statusCd eq 'DONE'}">이용완료</c:when>
          <c:when test="${reservation.statusCd eq 'CANCEL' or reservation.statusCd eq 'REJECTED'}">취소</c:when>
          <c:otherwise><c:out value="${reservation.statusCd}"/></c:otherwise>
        </c:choose>
      </span>
    </div>
    <div class="rd-row"><span>숙소</span><span><c:out value="${reservation.stayName}"/> <c:if test="${not empty reservation.roomName}"> / <c:out value="${reservation.roomName}"/></c:if></span></div>
    <div class="rd-row"><span>회원</span><span><c:out value="${reservation.memberName}"/> (<c:out value="${reservation.memberEmail}"/>)</span></div>
    <div class="rd-row"><span>반려동물</span><span><c:out value="${reservation.petName}"/></span></div>
    <div class="rd-row">
      <span>일정</span>
      <span>
        <fmt:formatDate value="${reservation.checkinDate}" pattern="yyyy-MM-dd"/>
        ~
        <fmt:formatDate value="${reservation.checkoutDate}" pattern="yyyy-MM-dd"/>
        <c:if test="${not empty reservation.nightCnt}"> (${reservation.nightCnt}박)</c:if>
      </span>
    </div>
    <div class="rd-row">
      <span>결제금액</span>
      <span>
        <c:if test="${not empty reservation.totalAmount}"><fmt:formatNumber value="${reservation.totalAmount}" pattern="#,###"/>원</c:if>
        <c:if test="${empty reservation.totalAmount}">-</c:if>
      </span>
    </div>
    <%-- 2026/08/11 장우철 — 결제수단·결제일 표시 --%>
    <div class="rd-row">
      <span>결제수단</span>
      <span>
        <c:choose>
          <c:when test="${empty reservation.payMethod}">-</c:when>
          <c:when test="${reservation.payMethod eq 'BILLING'}">등록카드(빌링)</c:when>
          <c:otherwise>토스결제</c:otherwise>
        </c:choose>
      </span>
    </div>
    <div class="rd-row">
      <span>결제일</span>
      <span>
        <c:choose>
          <c:when test="${not empty reservation.payDate}">
            <fmt:formatDate value="${reservation.payDate}" pattern="yyyy-MM-dd HH:mm"/>
          </c:when>
          <c:otherwise>-</c:otherwise>
        </c:choose>
      </span>
    </div>
    <c:if test="${reservation.statusCd eq 'CANCEL' or reservation.statusCd eq 'REJECTED'}">
      <div class="rd-row"><span>취소 사유</span><span><c:out value="${reservation.rejectReason}"/></span></div>
      <div class="rd-row">
        <span>취소수수료</span>
        <span><fmt:formatNumber value="${reservation.cancelFeeAmt}" pattern="#,###"/>원</span>
      </div>
      <div class="rd-row">
        <span>환불금액</span>
        <span><fmt:formatNumber value="${reservation.refundAmt}" pattern="#,###"/>원</span>
      </div>
    </c:if>
  </div>

  <c:if test="${reservation.statusCd ne 'CANCEL' and reservation.statusCd ne 'REJECTED' and reservation.statusCd ne 'DONE'}">
    <div class="rd-cancel">
      <h3 style="margin:0 0 8px;font-size:16px">관리자 취소 (전액 환불)</h3>
      <p style="font-size:13px;color:#666;margin:0 0 10px;line-height:1.5">
        수수료 없이 결제금액 전액을 환불합니다. CS 승인 후 잘못 예약 등에 사용하세요.
      </p>
      <form method="post" action="${contextPath}/admin/reservation/cancel"
            onsubmit="return confirm('전액 환불 취소하시겠습니까?');">
        <!--HYJ 26.08.05-->
        <input type="hidden" name="_csrf" value="${_csrf}">    
        
        <input type="hidden" name="resvId" value="${reservation.resvId}">
        <textarea name="cancelReason" maxlength="500" placeholder="취소 사유 (필수)" required></textarea>
        <button type="submit" class="btn">전액 환불 취소</button>
      </form>
    </div>
  </c:if>
</main>

<%@ include file="/WEB-INF/views/admin/common/footer.jsp" %>
