<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="hospital" />
<%@ include file="/WEB-INF/views/common/header.jsp" %>
<style>
  .complete-wrap{max-width:560px;margin:60px auto 80px;padding:0 20px;text-align:center}
  .complete-icon{width:80px;height:80px;border-radius:50%;background:#E0F2FE;display:flex;align-items:center;justify-content:center;margin:0 auto 24px}
  .complete-icon svg{width:40px;height:40px;stroke:#0284C7;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}
  .complete-title{font-size:24px;font-weight:800;color:var(--text-main);margin-bottom:8px}
  .complete-desc{font-size:15px;color:var(--text-muted);margin-bottom:32px}
  .complete-card{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);padding:24px;text-align:left;margin-bottom:24px}
  .complete-card h3{font-size:14px;font-weight:700;color:var(--text-main);margin:0 0 16px;padding-bottom:12px;border-bottom:1px solid var(--border)}
  .complete-row{display:flex;justify-content:space-between;font-size:14px;margin-bottom:10px}
  .complete-row:last-child{margin-bottom:0}
  .complete-row span:first-child{color:var(--text-muted)}
  .complete-row span:last-child{color:var(--text-main);font-weight:600;text-align:right}
  .complete-notice{background:var(--bg-page);border-radius:var(--radius-sm);padding:14px 16px;font-size:13px;color:var(--text-sub);line-height:1.6;text-align:left;margin-bottom:24px}
  .complete-notice strong{color:#0284C7}
  .complete-btns{display:flex;gap:12px}
  .btn-complete-my{flex:1;padding:13px;border:2px solid #0284C7;border-radius:var(--radius-sm);background:#fff;color:#0284C7;font-size:15px;font-weight:700;cursor:pointer}
  .btn-complete-store{flex:1;padding:13px;border:none;border-radius:var(--radius-sm);background:#0284C7;color:#fff;font-size:15px;font-weight:700;cursor:pointer}
</style>

<%-- 2026-07-10 장우철 — 예약 완료 DB 연동 (F3) --%>
<%-- 2026/07/16 장우철 — reservation null·resvDate null 시 JSP 500 방지 (숙소 complete.jsp 패턴) --%>
<div class="complete-wrap">
  <div class="complete-icon"><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg></div>
  <div class="complete-title">예약이 완료되었습니다!</div>
  <c:choose>
    <c:when test="${not empty reservation}">
      <div class="complete-desc">
        예약번호 <strong>#${reservation.resvNo}</strong><br>
        예약 내역은 마이페이지에서 확인하세요.
      </div>
      <div class="complete-card">
        <h3>예약 정보</h3>
        <div class="complete-row"><span>예약번호</span><span>#${reservation.resvNo}</span></div>
        <div class="complete-row"><span>병원</span><span>${empty reservation.hospitalName ? '-' : reservation.hospitalName}</span></div>
        <div class="complete-row"><span>반려동물</span><span>${reservation.petName}
          <c:if test="${not empty reservation.petBreed}"> (${reservation.petBreed}<c:if test="${not empty reservation.petAge}"> · ${reservation.petAge}세</c:if>)</c:if>
        </span></div>
        <div class="complete-row"><span>예약 일시</span><span>
          <c:choose>
            <c:when test="${not empty reservation.resvDate}">
              <fmt:formatDate value="${reservation.resvDate}" pattern="yyyy.MM.dd"/> ${reservation.resvTime}
              <c:if test="${not empty reservation.endTime}"> ~ ${reservation.endTime}</c:if>
            </c:when>
            <c:otherwise>${reservation.resvTime}</c:otherwise>
          </c:choose>
        </span></div>
        <div class="complete-row"><span>담당 의사</span><span>${empty reservation.doctorName ? '-' : reservation.doctorName}</span></div>
        <div class="complete-row"><span>진료 유형</span><span>${empty reservation.treatTypeName ? '-' : reservation.treatTypeName}</span></div>
        <div class="complete-row"><span>주증상</span><span>${empty reservation.symptoms ? '-' : reservation.symptoms}</span></div>
      </div>
    </c:when>
    <c:otherwise>
      <div class="complete-desc">예약은 접수되었습니다. 내역은 마이페이지에서 확인하세요.</div>
    </c:otherwise>
  </c:choose>
  <div class="complete-notice">
    진료 시간 <strong>10분 전</strong>까지 내원해주세요. 예약 변경·취소는 마이페이지 &gt; 예약내역에서 가능합니다.
  </div>
  <div class="complete-btns">
    <button class="btn-complete-my" onclick="location.href='${contextPath}/mypage/reserve'">예약 내역 보기</button>
    <button class="btn-complete-store" onclick="location.href='${contextPath}/hospital'">둘러보기 계속하기</button>
  </div>
</div>
<%@ include file="/WEB-INF/views/common/footer.jsp" %>
