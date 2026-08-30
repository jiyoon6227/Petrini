<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%-- 2026-08-11 박유정 — 관리자 일반 1:1 문의 상세 (숙소 예약 관리 UI 통일) --%>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="adminPage" value="general-inquiry" />
<%@ include file="/WEB-INF/views/admin/common/header.jsp" %>
<%@ include file="/WEB-INF/views/admin/common/sidebar.jsp" %>

<style>
  .rd-card{background:#fff;border:1px solid #E4E6ED;border-radius:12px;padding:20px;margin-bottom:16px}
  .rd-row{display:flex;justify-content:space-between;gap:16px;padding:10px 0;border-bottom:1px solid #F3F4F6;font-size:14px}
  .rd-row:last-child{border-bottom:none}
  .rd-row span:first-child{color:#888;min-width:100px}
  .rd-body{margin-top:6px;color:#333;line-height:1.7;white-space:pre-wrap}
  .rd-action{background:#F8FAFC;border:1px solid #E4E6ED;border-radius:12px;padding:20px}
  .rd-action textarea{width:100%;min-height:120px;border:1px solid #E4E6ED;border-radius:8px;padding:10px;box-sizing:border-box;font-size:14px}
  .rd-action .btn{margin-top:12px;background:#3B5BDB;color:#fff;border:none;border-radius:8px;padding:10px 16px;font-weight:700;cursor:pointer}
</style>

<main class="adm-main">
  <div class="adm-page-head">
    <div class="adm-page-head-left">
      <h1 class="adm-page-title">1:1 문의 상세</h1>
      <p class="adm-page-desc">문의번호 <strong><c:out value="${inquiry.inquiryId}"/></strong></p>
    </div>
    <div class="adm-page-actions">
      <a href="${contextPath}/admin/inquiry/general" class="adm-filter-btn outline" style="text-decoration:none">← 목록</a>
    </div>
  </div>

  <c:if test="${not empty successMsg}">
    <div style="background:#ECFDF5;border:1px solid #BBF7D0;color:#166534;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:14px"><c:out value="${successMsg}"/></div>
  </c:if>
  <c:if test="${not empty errorMsg}">
    <div style="background:#FEF2F2;border:1px solid #FECACA;color:#B91C1C;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:14px"><c:out value="${errorMsg}"/></div>
  </c:if>

  <div class="rd-card">
    <div class="rd-row">
      <span>상태</span>
      <span>
        <c:choose>
          <c:when test="${inquiry.statusCd eq 'WAIT'}">답변대기</c:when>
          <c:otherwise>답변완료</c:otherwise>
        </c:choose>
      </span>
    </div>
    <div class="rd-row">
      <span>유형</span>
      <span>
        <c:choose>
          <c:when test="${inquiry.inquiryType eq 'MEMBER'}">회원</c:when>
          <c:when test="${inquiry.inquiryType eq 'RESERVE'}">예약</c:when>
          <c:otherwise>기타</c:otherwise>
        </c:choose>
      </span>
    </div>
    <div class="rd-row"><span>회원</span><span><c:out value="${inquiry.memberName}"/> (<c:out value="${inquiry.memberEmail}"/>)</span></div>
    <div class="rd-row"><span>등록일</span><span><fmt:formatDate value="${inquiry.regDate}" pattern="yyyy.MM.dd HH:mm"/></span></div>
    <div class="rd-row"><span>제목</span><span><c:out value="${inquiry.title}"/></span></div>
    <div class="rd-row" style="display:block">
      <span>문의 내용</span>
      <div class="rd-body"><c:out value="${inquiry.body}"/></div>
    </div>
    <c:if test="${not empty inquiry.answer}">
      <div class="rd-row" style="display:block">
        <span>답변</span>
        <div class="rd-body"><c:out value="${inquiry.answer}"/></div>
      </div>
      <c:if test="${not empty inquiry.answerDate}">
        <div class="rd-row"><span>답변일</span><span><fmt:formatDate value="${inquiry.answerDate}" pattern="yyyy.MM.dd HH:mm"/></span></div>
      </c:if>
    </c:if>
  </div>

  <c:if test="${inquiry.statusCd eq 'WAIT'}">
    <div class="rd-action">
      <h3 style="margin:0 0 8px;font-size:16px">답변 작성</h3>
      <p style="font-size:13px;color:#666;margin:0 0 10px;line-height:1.5">
        회원 고객센터 문의 상세에 답변이 노출됩니다.
      </p>
      <form method="post" action="${contextPath}/admin/inquiry/general/answer"
            onsubmit="return confirm('답변을 등록할까요?');">
        <input type="hidden" name="_csrf" value="${_csrf}">
        <input type="hidden" name="inquiryId" value="${inquiry.inquiryId}">
        <textarea name="answer" placeholder="답변 내용을 입력하세요" required></textarea>
        <button type="submit" class="btn">답변 등록</button>
      </form>
    </div>
  </c:if>
</main>
<%@ include file="/WEB-INF/views/admin/common/footer.jsp" %>
