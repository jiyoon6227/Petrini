<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath"  value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="애견미용실" />
<c:set var="bizPage"      value="dashboard" />

<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_grooming.jsp" %>

<main class="biz-main">
  <div class="biz-page-head">
    <h1 class="biz-page-title">미용실 대시보드</h1>
    <p class="biz-page-desc">오늘 예약 현황과 스타일리스트별 일정을 확인하세요.</p>
  </div>
  <div class="biz-stats">
    <div class="biz-stat-card"><div class="bsc-icon appt"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="3" y1="10" x2="21" y2="10"/></svg></div><div class="bsc-body"><span class="bsc-label">오늘 예약</span><span class="bsc-val">4<span class="bsc-unit">건</span></span></div></div>
    <div class="biz-stat-card"><div class="bsc-icon done"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></div><div class="bsc-body"><span class="bsc-label">시술 완료</span><span class="bsc-val">2<span class="bsc-unit">건</span></span></div></div>
    <div class="biz-stat-card"><div class="bsc-icon revenue"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 000 7h5a3.5 3.5 0 010 7H6"/></svg></div><div class="bsc-body"><span class="bsc-label">이번 달 매출</span><span class="bsc-val">2.4<span class="bsc-unit">백만원</span></span></div></div>
    <div class="biz-stat-card"><div class="bsc-icon review"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg></div><div class="bsc-body"><span class="bsc-label">평균 리뷰</span><span class="bsc-val">4.8<span class="bsc-unit">/ 5.0</span></span></div></div>
  </div>
  <div class="biz-card">
    <div class="biz-card-head"><span>오늘 예약 현황</span><small>2025.06.26 기준</small></div>
    <table class="biz-table">
      <thead><tr><th>시간</th><th>보호자</th><th>반려동물</th><th>시술 종류</th><th>담당</th><th>상태</th></tr></thead>
      <tbody>
        <tr><td>10:00</td><td>김예진</td><td>코코 (비숑 / 2세)</td><td>전체 미용</td><td>박채원</td><td><span class="bs-badge bs-done">완료</span></td></tr>
        <tr><td>11:30</td><td>이성민</td><td>두부 (포메 / 4세)</td><td>발 / 발톱 정리</td><td>김지수</td><td><span class="bs-badge bs-done">완료</span></td></tr>
        <tr><td>14:00</td><td>최아린</td><td>망고 (말티푸 / 1세)</td><td>전체 미용 + 염색</td><td>박채원</td><td><span class="bs-badge bs-wait">대기</span></td></tr>
        <tr><td>15:30</td><td>정우찬</td><td>하루 (시츄 / 3세)</td><td>목욕 + 드라이</td><td>김지수</td><td><span class="bs-badge bs-wait">대기</span></td></tr>
      </tbody>
    </table>
  </div>
</main>

<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>
