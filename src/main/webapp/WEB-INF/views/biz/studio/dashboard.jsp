<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath"  value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="애완동물 사진관" />
<c:set var="bizPage"      value="dashboard" />
<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_studio.jsp" %>
<main class="biz-main">
    <div class="biz-page-head">
        <h1 class="biz-page-title">대시보드</h1>
    </div>
    
<style>
.studio-stats{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:24px}
.ss-card{background:#fff;border:1px solid var(--biz-border);border-radius:12px;padding:18px;display:flex;align-items:center;gap:14px}
.ss-icon{width:44px;height:44px;border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0}
.ss-icon svg{width:22px;height:22px;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round}
.ss-icon.purple{background:#F3E8FF} .ss-icon.purple svg{stroke:#9333EA}
.ss-icon.green{background:#DCFCE7}  .ss-icon.green svg{stroke:#16A34A}
.ss-icon.orange{background:#FFF7ED} .ss-icon.orange svg{stroke:#EA580C}
.ss-icon.blue{background:#E0F2FE}   .ss-icon.blue svg{stroke:#0284C7}
.ss-label{font-size:12px;color:#999;margin-bottom:4px}
.ss-val{font-size:22px;font-weight:800;color:#1A1A2E}
.ss-unit{font-size:12px;color:#888;font-weight:400}

.studio-section{background:#fff;border:1px solid var(--biz-border);border-radius:12px;overflow:hidden;margin-bottom:20px}
.studio-section-head{display:flex;justify-content:space-between;align-items:center;padding:14px 18px;border-bottom:1px solid var(--biz-border);background:#FAFBFA}
.studio-section-head span{font-size:14px;font-weight:700;color:#1A1A2E}

.res-row{display:flex;align-items:center;gap:14px;padding:14px 18px;border-bottom:1px solid #F5F5F5}
.res-row:last-child{border-bottom:none}
.res-thumb{width:50px;height:50px;border-radius:50%;object-fit:cover;flex-shrink:0}
.res-info{flex:1}
.res-name{font-size:14px;font-weight:700;color:#1A1A2E}
.res-meta{font-size:12px;color:#999;margin-top:2px}
.res-time{font-size:13px;font-weight:700;color:var(--biz-primary);flex-shrink:0}

.gallery-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:10px;padding:14px 18px}
.gallery-thumb{width:100%;aspect-ratio:1/1;object-fit:cover;border-radius:8px;display:block}
</style>
<div class="studio-stats">
  <div class="ss-card">
    <div class="ss-icon purple"><svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="3" y1="10" x2="21" y2="10"/></svg></div>
    <div><div class="ss-label">오늘 예약</div><div class="ss-val">3<span class="ss-unit">건</span></div></div>
  </div>
  <div class="ss-card">
    <div class="ss-icon green"><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg></div>
    <div><div class="ss-label">이번 달 촬영</div><div class="ss-val">28<span class="ss-unit">건</span></div></div>
  </div>
  <div class="ss-card">
    <div class="ss-icon orange"><svg viewBox="0 0 24 24"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 000 7h5a3.5 3.5 0 010 7H6"/></svg></div>
    <div><div class="ss-label">이번 달 매출</div><div class="ss-val">1.4<span class="ss-unit">백만원</span></div></div>
  </div>
  <div class="ss-card">
    <div class="ss-icon blue"><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg></div>
    <div><div class="ss-label">평균 별점</div><div class="ss-val">4.9<span class="ss-unit">점</span></div></div>
  </div>
</div>

<div style="display:grid;grid-template-columns:1fr 1fr;gap:20px">
  <div class="studio-section">
    <div class="studio-section-head">
      <span>오늘 예약 일정</span>
      <a href="${contextPath}/biz/studio/reserve" class="biz-btn">전체보기</a>
    </div>
    <div class="res-row">
      <img class="res-thumb" src="https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=100&q=70&auto=format&fit=crop" alt="강아지" onerror="this.src='https://placehold.co/50x50/F3E8FF/9333EA?text=DOG'">
      <div class="res-info"><div class="res-name">김민준 · 몽이 (골든 리트리버)</div><div class="res-meta">프리미엄 패키지 · 1시간</div></div>
      <span class="res-time">10:00</span>
    </div>
    <div class="res-row">
      <img class="res-thumb" src="https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=100&q=70&auto=format&fit=crop" alt="고양이" onerror="this.src='https://placehold.co/50x50/F3E8FF/9333EA?text=CAT'">
      <div class="res-info"><div class="res-name">이서연 · 나비 (페르시안)</div><div class="res-meta">프로필 패키지 · 30분</div></div>
      <span class="res-time">13:00</span>
    </div>
    <div class="res-row">
      <img class="res-thumb" src="https://images.unsplash.com/photo-1552053831-71594a27632d?w=100&q=70&auto=format&fit=crop" alt="푸들" onerror="this.src='https://placehold.co/50x50/F3E8FF/9333EA?text=DOG'">
      <div class="res-info"><div class="res-name">박지호 · 루비 (푸들)</div><div class="res-meta">베이직 패키지 · 30분</div></div>
      <span class="res-time">15:00</span>
    </div>
  </div>

  <div class="studio-section">
    <div class="studio-section-head">
      <span>최근 포트폴리오</span>
      <a href="${contextPath}/biz/studio/gallery" class="biz-btn">갤러리 관리</a>
    </div>
    <div class="gallery-grid">
      <img class="gallery-thumb" src="https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=200&q=70&auto=format&fit=crop" alt="작품1" onerror="this.src='https://placehold.co/200x200/F3E8FF/9333EA?text=사진'">
      <img class="gallery-thumb" src="https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=200&q=70&auto=format&fit=crop" alt="작품2" onerror="this.src='https://placehold.co/200x200/F3E8FF/9333EA?text=사진'">
      <img class="gallery-thumb" src="https://images.unsplash.com/photo-1552053831-71594a27632d?w=200&q=70&auto=format&fit=crop" alt="작품3" onerror="this.src='https://placehold.co/200x200/F3E8FF/9333EA?text=사진'">
      <img class="gallery-thumb" src="https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=200&q=70&auto=format&fit=crop" alt="작품4" onerror="this.src='https://placehold.co/200x200/F3E8FF/9333EA?text=사진'">
    </div>
  </div>
</div>

</main>
<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>
