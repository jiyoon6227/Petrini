<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="walk" />
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
  .walk-hero {
    background: linear-gradient(135deg, #14532D 0%, #16A34A 55%, #4ADE80 100%);
    padding: 44px 0;
    color: #fff;
    text-align: center;
  }
  .walk-hero-inner { max-width: var(--inner-width); margin: 0 auto; padding: 0 20px; }
  .walk-hero h1 { font-size: 28px; font-weight: 800; margin: 0 0 8px; }
  .walk-hero p { font-size: 14px; opacity: .9; margin: 0; }

  .walk-page {
    max-width: var(--inner-width);
    margin: 0 auto;
    padding: 28px 20px 80px;
  }
  .walk-toolbar {
    max-width: 720px;
    margin: 0 auto 28px;
    display: flex;
    gap: 10px;
  }
  .walk-search-input {
    flex: 1;
    height: 44px;
    padding: 0 16px;
    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
    font-size: 14px;
    outline: none;
  }
  .walk-search-input:focus { border-color: var(--primary); }
  .walk-search-btn {
    min-width: 88px;
    height: 44px;
    border: none;
    border-radius: var(--radius-sm);
    background: var(--primary);
    color: #fff;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
  }

  .walk-chips {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    justify-content: center;
    margin-bottom: 28px;
  }
  .walk-chip {
    padding: 8px 16px;
    border: 1px solid var(--border);
    border-radius: 50px;
    font-size: 13px;
    font-weight: 600;
    color: var(--text-sub);
    background: #fff;
    cursor: pointer;
    transition: var(--transition);
  }
  .walk-chip:hover, .walk-chip.on {
    border-color: var(--primary);
    background: var(--primary-light);
    color: var(--primary-dark);
  }

  .walk-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 20px;
  }
  .walk-card {
    background: var(--bg-card);
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    overflow: hidden;
    cursor: pointer;
    transition: var(--transition);
  }
  .walk-card:hover {
    box-shadow: var(--shadow-md);
    transform: translateY(-3px);
  }
  .walk-card-thumb {
    position: relative;
    aspect-ratio: 4 / 3;
    overflow: hidden;
  }
  .walk-card-thumb img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
  .walk-badge {
    position: absolute;
    top: 12px;
    left: 12px;
    padding: 4px 10px;
    border-radius: 20px;
    font-size: 11px;
    font-weight: 700;
    background: rgba(0,0,0,.55);
    color: #fff;
  }
  .walk-card-body { padding: 16px 18px 18px; }
  .walk-card-title {
    font-size: 16px;
    font-weight: 800;
    color: var(--text-main);
    margin-bottom: 8px;
  }
  .walk-meta {
    font-size: 13px;
    color: var(--text-muted);
    display: flex;
    flex-direction: column;
    gap: 4px;
    margin-bottom: 12px;
  }
  .walk-foot {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 13px;
  }
  .walk-rating {
    display: flex;
    align-items: center;
    gap: 4px;
    font-weight: 700;
    color: var(--text-main);
  }
  .walk-rating svg { width: 14px; height: 14px; fill: var(--yellow); }
  .walk-dist { color: var(--text-muted); }

  @media (max-width: 900px) {
    .walk-grid { grid-template-columns: repeat(2, 1fr); }
  }
  @media (max-width: 560px) {
    .walk-grid { grid-template-columns: 1fr; }
  }
</style>

<div class="walk-hero">
  <div class="walk-hero-inner">
    <h1>반려동물과 함께하는 산책</h1>
    <p>근처 공원·산책로·반려견 운동장을 한눈에 찾아보세요</p>
  </div>
</div>

<main class="walk-page">
  <div class="walk-toolbar">
    <input type="text" class="walk-search-input" placeholder="지역명, 공원명, 산책로 검색">
    <button type="button" class="walk-search-btn">검색</button>
  </div>

  <div class="walk-chips">
    <span class="walk-chip on">전체</span>
    <span class="walk-chip">공원</span>
    <span class="walk-chip">강변 산책로</span>
    <span class="walk-chip">반려견 운동장</span>
    <span class="walk-chip">숲길</span>
    <span class="walk-chip">대형견 가능</span>
  </div>

  <div class="walk-grid">
    <article class="walk-card">
      <div class="walk-card-thumb">
        <img src="https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=600&q=80" alt="한강 반려견 산책로"
             onerror="this.src='https://placehold.co/600x450/EAF7F2/16A34A?text=산책로'">
        <span class="walk-badge">강변 산책로</span>
      </div>
      <div class="walk-card-body">
        <h2 class="walk-card-title">한강공원 여의도 반려견 산책로</h2>
        <div class="walk-meta">
          <span>서울 영등포구 여의도동</span>
          <span>약 2.4km · 평지 · 물놀이장 인근</span>
        </div>
        <div class="walk-foot">
          <span class="walk-rating">
            <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
            4.8 (312)
          </span>
          <span class="walk-dist">1.2km</span>
        </div>
      </div>
    </article>

    <article class="walk-card">
      <div class="walk-card-thumb">
        <img src="https://images.unsplash.com/photo-1548199973-03cce0bbc87b?w=600&q=80" alt="반려견 운동장"
             onerror="this.src='https://placehold.co/600x450/EAF7F2/16A34A?text=운동장'">
        <span class="walk-badge">반려견 운동장</span>
      </div>
      <div class="walk-card-body">
        <h2 class="walk-card-title">월드컵공원 반려견 놀이터</h2>
        <div class="walk-meta">
          <span>서울 마포구 상암동</span>
          <span>운동장 분리 · 대형견 구역 있음</span>
        </div>
        <div class="walk-foot">
          <span class="walk-rating">
            <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
            4.6 (189)
          </span>
          <span class="walk-dist">2.8km</span>
        </div>
      </div>
    </article>

    <article class="walk-card">
      <div class="walk-card-thumb">
        <img src="https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=600&q=80" alt="숲길 산책"
             onerror="this.src='https://placehold.co/600x450/EAF7F2/16A34A?text=숲길'">
        <span class="walk-badge">숲길</span>
      </div>
      <div class="walk-card-body">
        <h2 class="walk-card-title">북한산 둘레길 펫코스</h2>
        <div class="walk-meta">
          <span>서울 은평구 불광동</span>
          <span>약 3.1km · 그늘 많음 · 물길 인근</span>
        </div>
        <div class="walk-foot">
          <span class="walk-rating">
            <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
            4.9 (97)
          </span>
          <span class="walk-dist">5.4km</span>
        </div>
      </div>
    </article>
  </div>
</main>

<script>
  document.querySelectorAll('.walk-chip').forEach(function(chip) {
    chip.addEventListener('click', function() {
      document.querySelectorAll('.walk-chip').forEach(function(c) { c.classList.remove('on'); });
      chip.classList.add('on');
    });
  });
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
