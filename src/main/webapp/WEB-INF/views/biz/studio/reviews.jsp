<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath"  value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="애완동물 사진관" />
<c:set var="bizPage"      value="reviews" />
<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_studio.jsp" %>
<main class="biz-main">
    <div class="biz-page-head">
        <h1 class="biz-page-title">리뷰 관리</h1>
    </div>
    <div style="display:flex;flex-direction:column;align-items:center;gap:14px;padding:80px 0;text-align:center">
  <div style="width:60px;height:60px;border-radius:50%;background:#F3E8FF;display:flex;align-items:center;justify-content:center">
    <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#9333EA" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
  </div>
  <p style="font-size:15px;font-weight:600;color:#1A1A2E;margin:0">리뷰 관리</p>
  <small style="font-size:13px;color:#999">고객 리뷰를 조회하고 답변을 달 수 있습니다.</small>
</div>
</main>
<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>
