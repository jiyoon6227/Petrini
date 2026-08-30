<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath"  value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="애완동물 사진관" />
<c:set var="bizPage"      value="packages" />
<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_studio.jsp" %>
<main class="biz-main">
    <div class="biz-page-head">
        <h1 class="biz-page-title">촬영 패키지 관리</h1>
    </div>
    
<style>
.pkg-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:18px;margin-bottom:24px}
.pkg-card{background:#fff;border:1px solid var(--biz-border);border-radius:12px;overflow:hidden}
.pkg-card-head{padding:18px 18px 0;text-align:center}
.pkg-badge{display:inline-block;font-size:11px;font-weight:700;padding:3px 10px;border-radius:20px;margin-bottom:10px}
.pkg-badge.basic{background:#E0F2FE;color:#0284C7}
.pkg-badge.profile{background:#F3E8FF;color:#9333EA}
.pkg-badge.premium{background:#FFF8E1;color:#F59E0B}
.pkg-name{font-size:17px;font-weight:800;color:#1A1A2E;margin-bottom:4px}
.pkg-price{font-size:22px;font-weight:800;color:var(--biz-primary);margin-bottom:14px}
.pkg-features{list-style:none;padding:0 18px;margin:0 0 16px;text-align:left;font-size:13px;color:#555;line-height:2}
.pkg-features li::before{content:"✓ ";color:var(--biz-primary);font-weight:700}
.pkg-edit-btn{display:block;width:100%;padding:10px;border:none;border-top:1px solid var(--biz-border);background:#FAFBFA;color:#555;font-size:13px;font-weight:600;cursor:pointer;transition:all .15s}
.pkg-edit-btn:hover{background:var(--biz-primary);color:#fff}
</style>
<div class="pkg-grid">
  <div class="pkg-card">
    <div class="pkg-card-head">
      <span class="pkg-badge basic">BASIC</span>
      <div class="pkg-name">베이직</div>
      <div class="pkg-price">30,000원</div>
    </div>
    <ul class="pkg-features"><li>실내 촬영 30분</li><li>보정 사진 10장</li><li>디지털 파일 제공</li></ul>
    <button class="pkg-edit-btn" onclick="alert('패키지 수정')">수정</button>
  </div>
  <div class="pkg-card">
    <div class="pkg-card-head">
      <span class="pkg-badge profile">PROFILE</span>
      <div class="pkg-name">프로필</div>
      <div class="pkg-price">55,000원</div>
    </div>
    <ul class="pkg-features"><li>실내 촬영 1시간</li><li>보정 사진 20장</li><li>배경 2종 선택</li><li>디지털 파일 제공</li></ul>
    <button class="pkg-edit-btn" onclick="alert('패키지 수정')">수정</button>
  </div>
  <div class="pkg-card">
    <div class="pkg-card-head">
      <span class="pkg-badge premium">PREMIUM</span>
      <div class="pkg-name">프리미엄</div>
      <div class="pkg-price">90,000원</div>
    </div>
    <ul class="pkg-features"><li>실내+야외 촬영 2시간</li><li>보정 사진 40장</li><li>배경 무제한</li><li>앨범 제작 포함</li><li>SNS용 편집 5종</li></ul>
    <button class="pkg-edit-btn" onclick="alert('패키지 수정')">수정</button>
  </div>
</div>
<button class="biz-btn" onclick="alert('패키지 추가')">+ 새 패키지 추가</button>

</main>
<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>
