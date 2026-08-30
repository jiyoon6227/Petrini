<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath"  value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="반려동물 동반 요식업" />
<c:set var="bizPage"      value="dashboard" />

<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_restaurant.jsp" %>

<main class="biz-main">
  <div class="biz-page-head">
    <h1 class="biz-page-title">매장 대시보드</h1>
    <p class="biz-page-desc">오늘 예약과 테이블 현황을 확인하세요.</p>
  </div>
  <div class="biz-stats">
    <div class="biz-stat-card"><div class="bsc-icon appt"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="3" y1="10" x2="21" y2="10"/></svg></div><div class="bsc-body"><span class="bsc-label">오늘 예약</span><span class="bsc-val">7<span class="bsc-unit">팀</span></span></div></div>
    <div class="biz-stat-card"><div class="bsc-icon done"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="7" width="20" height="14" rx="2"/></svg></div><div class="bsc-body"><span class="bsc-label">테이블 가동률</span><span class="bsc-val">60<span class="bsc-unit">%</span></span></div></div>
    <div class="biz-stat-card"><div class="bsc-icon revenue"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 000 7h5a3.5 3.5 0 010 7H6"/></svg></div><div class="bsc-body"><span class="bsc-label">이번 달 매출</span><span class="bsc-val">8.1<span class="bsc-unit">백만원</span></span></div></div>
    <div class="biz-stat-card"><div class="bsc-icon review"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg></div><div class="bsc-body"><span class="bsc-label">평균 리뷰</span><span class="bsc-val">4.6<span class="bsc-unit">/ 5.0</span></span></div></div>
  </div>
  <div class="biz-card">
    <div class="biz-card-head"><span>오늘 예약 현황</span><small>2025.06.26 기준</small></div>
    <table class="biz-table">
      <thead><tr><th>시간</th><th>예약자</th><th>인원</th><th>동반 반려동물</th><th>테이블</th><th>상태</th></tr></thead>
      <tbody>
        <tr><td>11:30</td><td>김하은</td><td>2명</td><td>말티즈 1마리</td><td>펫존 T-1</td><td><span class="bs-badge bs-done">착석중</span></td></tr>
        <tr><td>12:00</td><td>이준혁</td><td>3명</td><td>골든 리트리버 1마리</td><td>펫존 T-3</td><td><span class="bs-badge bs-done">착석중</span></td></tr>
        <tr><td>13:00</td><td>박소연</td><td>2명</td><td>고양이 2마리</td><td>—</td><td><span class="bs-badge bs-wait">대기</span></td></tr>
        <tr><td>14:00</td><td>최민서</td><td>4명</td><td>푸들 1마리</td><td>—</td><td><span class="bs-badge bs-wait">대기</span></td></tr>
        <tr><td>15:30</td><td>정우찬</td><td>2명</td><td>시바이누 1마리</td><td>—</td><td><span class="bs-badge bs-wait">대기</span></td></tr>
      </tbody>
    </table>
  </div>
</main>

<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>
