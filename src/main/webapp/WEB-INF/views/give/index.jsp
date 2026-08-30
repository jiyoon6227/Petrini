<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
    .give-hero{background:linear-gradient(135deg,#1F8464 0%,#2BAB82 60%,#5BC8A8 100%);padding:56px 0 64px;text-align:center;color:#fff}
    .give-hero-inner{max-width:var(--inner-width);margin:0 auto;padding:0 20px}
    .give-hero-badge{display:inline-block;font-size:13px;font-weight:700;background:rgba(255,255,255,.2);padding:5px 16px;border-radius:50px;margin-bottom:20px}
    .give-hero h1{font-size:36px;font-weight:800;margin:0;line-height:1.45}
    .give-hero p{font-size:16px;opacity:.85;margin:0 0 32px}
    .give-hero-stats{display:flex;justify-content:center;gap:48px;padding:24px 0;border-top:1px solid rgba(255,255,255,.2);margin-top:8px}
    .ghs{text-align:center}
    .ghs .num{font-size:28px;font-weight:800}
    .ghs .label{font-size:13px;opacity:.8;margin-top:2px}
    .give-tab-wrap{background:#fff;border-bottom:1px solid var(--border);position:sticky;top:0;z-index:10;box-shadow:0 2px 8px rgba(0,0,0,.05)}
    .give-tabs{max-width:var(--inner-width);margin:0 auto;padding:0 20px;display:flex;gap:0}
    .give-tab{display:flex;align-items:center;gap:8px;padding:16px 28px;font-size:15px;font-weight:600;color:var(--text-muted);border:none;background:none;cursor:pointer;border-bottom:3px solid transparent;margin-bottom:-1px;transition:var(--transition);text-decoration:none}
    .give-tab:hover{color:var(--primary)}
    .give-tab.active{color:var(--primary);border-bottom-color:var(--primary)}
    .give-tab svg{width:18px;height:18px;stroke:currentColor;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round}
    .give-tab .tab-count{background:var(--primary-light);color:var(--primary-dark);font-size:11px;font-weight:700;padding:2px 7px;border-radius:20px}
    .give-tab.active .tab-count{background:var(--primary);color:#fff}
    .give-content{max-width:var(--inner-width);margin:36px auto 80px;padding:0 20px}
</style>

<%-- 히어로 배너 --%>
<div class="give-hero">
  <div class="give-hero-inner">
    <span class="give-hero-badge">PetCare 가족찾기</span>
    <h1>다시 한번 사랑받고 싶은 아이들의<br>간절한 기다림에 응답해 주세요.</h1>
  </div>
</div>

<%-- 탭바 --%>
<div class="give-tab-wrap">
    <div class="give-tabs">
        <a href="${contextPath}/give/animal/list"
           class="give-tab ${giveTab eq 'animal' ? 'active' : ''}">
          <svg viewBox="0 0 24 24"><circle cx="4.5" cy="9.5" r="2"/><circle cx="9" cy="5.5" r="2"/><circle cx="15" cy="5.5" r="2"/><circle cx="19.5" cy="9.5" r="2"/><path d="M12 13c-3.87 0-7 1.79-7 4v1h14v-1c0-2.21-3.13-4-7-4z"/></svg>
          유기동물 조회
          <span class="tab-count">실시간</span>
        </a>
        <a href="${contextPath}/give/report/list"
           class="give-tab ${giveTab eq 'report' ? 'active' : ''}">
          <svg viewBox="0 0 24 24"><path d="M21 10c0 7-9 13-9 13S3 17 3 10a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/></svg>
          분실·보호
          <span class="tab-count">${empty reportCount ? 0 : reportCount}</span>
        </a>
        <%-- 2026-07-16 박유정 — 재능나눔 탭 (커뮤니티에서 give 모듈로 분리) --%>
        <a href="${contextPath}/give/talent/list"
           class="give-tab ${giveTab eq 'talent' ? 'active' : ''}">
          <svg viewBox="0 0 24 24"><path d="M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78L12 21.23l8.84-8.84a5.5 5.5 0 000-7.78z"/></svg>
          재능나눔
        </a>
    </div>
</div>
