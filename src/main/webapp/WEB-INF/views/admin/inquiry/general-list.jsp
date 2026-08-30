<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%-- 2026-08-11 박유정 — 관리자 일반 1:1 문의 목록 (숙소 예약 관리 UI 통일) --%>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="adminPage" value="general-inquiry" />
<%@ include file="/WEB-INF/views/admin/common/header.jsp" %>
<%@ include file="/WEB-INF/views/admin/common/sidebar.jsp" %>

<main class="adm-main">
  <div class="adm-page-head">
    <div class="adm-page-head-left">
      <h1 class="adm-page-title">1:1 문의</h1>
      <p class="adm-page-desc">회원·예약·기타 문의를 조회하고 답변을 등록하세요.</p>
    </div>
  </div>

  <c:if test="${not empty successMsg}">
    <div style="background:#ECFDF5;border:1px solid #BBF7D0;color:#166534;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:14px"><c:out value="${successMsg}"/></div>
  </c:if>
  <c:if test="${not empty errorMsg}">
    <div style="background:#FEF2F2;border:1px solid #FECACA;color:#B91C1C;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:14px"><c:out value="${errorMsg}"/></div>
  </c:if>

  <div style="display:flex;gap:0;border-bottom:2px solid #E4E6ED;margin-bottom:16px;flex-wrap:wrap">
    <a href="${contextPath}/admin/inquiry/general?status=ALL&amp;keyword=${keyword}"
       style="padding:10px 14px;font-size:13px;font-weight:${status eq 'ALL' ? '700' : '600'};color:${status eq 'ALL' ? '#3B5BDB' : '#999'};text-decoration:none;border-bottom:2px solid ${status eq 'ALL' ? '#3B5BDB' : 'transparent'};margin-bottom:-2px">
      전체 <span style="background:#F3F4F6;font-size:11px;padding:1px 7px;border-radius:20px;margin-left:4px">${statusCounts.ALL}</span>
    </a>
    <a href="${contextPath}/admin/inquiry/general?status=WAIT&amp;keyword=${keyword}"
       style="padding:10px 14px;font-size:13px;font-weight:${status eq 'WAIT' ? '700' : '600'};color:${status eq 'WAIT' ? '#3B5BDB' : '#999'};text-decoration:none;border-bottom:2px solid ${status eq 'WAIT' ? '#3B5BDB' : 'transparent'};margin-bottom:-2px">
      답변대기 <span style="background:#F3F4F6;font-size:11px;padding:1px 7px;border-radius:20px;margin-left:4px">${statusCounts.WAIT}</span>
    </a>
    <a href="${contextPath}/admin/inquiry/general?status=DONE&amp;keyword=${keyword}"
       style="padding:10px 14px;font-size:13px;font-weight:${status eq 'DONE' ? '700' : '600'};color:${status eq 'DONE' ? '#3B5BDB' : '#999'};text-decoration:none;border-bottom:2px solid ${status eq 'DONE' ? '#3B5BDB' : 'transparent'};margin-bottom:-2px">
      답변완료 <span style="background:#F3F4F6;font-size:11px;padding:1px 7px;border-radius:20px;margin-left:4px">${statusCounts.DONE}</span>
    </a>
  </div>

  <form method="get" action="${contextPath}/admin/inquiry/general" style="margin-bottom:16px;display:flex;gap:8px">
    <input type="hidden" name="status" value="${status}">
    <input type="text" name="keyword" value="${keyword}" placeholder="문의번호·제목·회원명"
           style="flex:1;max-width:320px;padding:10px 12px;border:1px solid #E4E6ED;border-radius:8px;font-size:14px">
    <button type="submit" class="adm-filter-btn" style="cursor:pointer">검색</button>
  </form>

  <div class="adm-card" style="overflow:auto">
    <table class="adm-table" style="width:100%;border-collapse:collapse;font-size:13px">
      <thead>
        <tr style="background:#FAFBFC;text-align:left">
          <th style="padding:12px">번호</th>
          <th style="padding:12px">유형</th>
          <th style="padding:12px">제목</th>
          <th style="padding:12px">회원</th>
          <th style="padding:12px">상태</th>
          <th style="padding:12px">등록일</th>
          <th style="padding:12px"></th>
        </tr>
      </thead>
      <tbody>
        <c:if test="${empty list}">
          <tr><td colspan="7" style="padding:32px;text-align:center;color:#999">문의가 없습니다.</td></tr>
        </c:if>
        <c:forEach var="i" items="${list}">
          <tr style="border-top:1px solid #EEF0F4">
            <td style="padding:12px"><c:out value="${i.inquiryId}"/></td>
            <td style="padding:12px">
              <c:choose>
                <c:when test="${i.inquiryType eq 'MEMBER'}">회원</c:when>
                <c:when test="${i.inquiryType eq 'RESERVE'}">예약</c:when>
                <c:otherwise>기타</c:otherwise>
              </c:choose>
            </td>
            <td style="padding:12px"><c:out value="${i.title}"/></td>
            <td style="padding:12px">
              <c:out value="${i.memberName}"/>
              <c:if test="${not empty i.memberEmail}"><div style="font-size:11px;color:#888"><c:out value="${i.memberEmail}"/></div></c:if>
            </td>
            <td style="padding:12px">
              <c:choose>
                <c:when test="${i.statusCd eq 'WAIT'}">답변대기</c:when>
                <c:otherwise>답변완료</c:otherwise>
              </c:choose>
            </td>
            <td style="padding:12px"><fmt:formatDate value="${i.regDate}" pattern="yyyy.MM.dd HH:mm"/></td>
            <td style="padding:12px">
              <a href="${contextPath}/admin/inquiry/general/detail?inquiryId=${i.inquiryId}" style="color:#3B5BDB;font-weight:600">상세</a>
            </td>
          </tr>
        </c:forEach>
      </tbody>
    </table>
  </div>
</main>
<%@ include file="/WEB-INF/views/admin/common/footer.jsp" %>
