<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="studio" />
<%@ include file="/WEB-INF/views/common/header.jsp" %>
<style>
  .sdetail-wrap{max-width:var(--inner-width);margin:32px auto 80px;padding:0 20px;display:grid;grid-template-columns:1fr 320px;gap:28px;align-items:flex-start}
  .sdetail-photos{display:grid;grid-template-columns:2fr 1fr 1fr;gap:8px;margin-bottom:24px;border-radius:var(--radius-md);overflow:hidden}
  .sdetail-photos img{width:100%;height:200px;object-fit:cover;display:block}
  .sdetail-photos img:first-child{height:100%;grid-row:span 2}
  .sdetail-head{margin-bottom:16px}
  .sdetail-tags{display:flex;gap:6px;flex-wrap:wrap;margin-bottom:6px}
  .sdtag{font-size:11px;font-weight:700;padding:3px 10px;border-radius:20px}
  .sdtag.type{background:#F3E8FF;color:#9333EA}
  .sdtag.open{background:#DCFCE7;color:#16A34A}
  .sdetail-name{font-size:24px;font-weight:800;color:var(--text-main);margin-bottom:8px}
  .sdetail-rating{display:flex;align-items:center;gap:6px;font-size:15px;font-weight:700;color:var(--text-main)}
  .sdetail-rating svg{width:16px;height:16px;fill:var(--yellow)}
  .sdetail-info-grid{display:grid;grid-template-columns:1fr 1fr;gap:14px;margin-bottom:28px}
  .sdinfo-card{background:var(--bg-page);border-radius:var(--radius-sm);padding:16px}
  .sdinfo-label{font-size:12px;color:var(--text-muted);font-weight:600;margin-bottom:6px;display:flex;align-items:center;gap:5px}
  .sdinfo-label svg{width:13px;height:13px;stroke:var(--text-muted);fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}
  .sdinfo-val{font-size:14px;color:var(--text-main);line-height:1.5}
  /* 포트폴리오 갤러리 */
  .port-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:10px;margin-bottom:28px}
  .port-grid img{width:100%;aspect-ratio:1/1;object-fit:cover;border-radius:var(--radius-sm);display:block;cursor:pointer;transition:var(--transition)}
  .port-grid img:hover{opacity:.85}
  /* 패키지 */
  .pkg-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:16px;margin-bottom:28px}
  .pkg-card{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);overflow:hidden;text-align:center;transition:var(--transition)}
  .pkg-card.reco{border-color:#9333EA;box-shadow:0 4px 16px rgba(147,51,234,.15)}
  .pkg-card-head{padding:18px 18px 0}
  .pkg-badge{display:inline-block;font-size:11px;font-weight:700;padding:3px 10px;border-radius:20px;margin-bottom:10px}
  .pkg-badge.basic{background:#E0F2FE;color:#0284C7}
  .pkg-badge.profile{background:#F3E8FF;color:#9333EA}
  .pkg-badge.premium{background:#FFF8E1;color:#F59E0B}
  .pkg-name{font-size:17px;font-weight:800;color:var(--text-main);margin-bottom:4px}
  .pkg-price{font-size:22px;font-weight:800;color:#9333EA;margin-bottom:14px}
  .pkg-features{list-style:none;padding:0 18px;margin:0 0 16px;text-align:left;font-size:13px;color:var(--text-sub);line-height:2}
  .pkg-features li::before{content:"✓ ";color:#9333EA;font-weight:700}
  .pkg-select-btn{display:block;width:100%;padding:11px;border:none;border-top:1px solid var(--border);background:#FAFBFA;color:#555;font-size:13px;font-weight:700;cursor:pointer;transition:var(--transition)}
  .pkg-select-btn:hover{background:#9333EA;color:#fff}
  /* 리뷰 */
  .review-item{border:1px solid var(--border);border-radius:var(--radius-md);padding:16px;margin-bottom:12px}
  .review-item-head{display:flex;justify-content:space-between;margin-bottom:8px}
  .reviewer-name{font-size:14px;font-weight:700;color:var(--text-main)}
  .review-item-stars{display:flex;gap:2px}
  .review-item-stars svg{width:13px;height:13px;fill:var(--yellow)}
  .review-item-date{font-size:12px;color:var(--text-muted)}
  .review-item-text{font-size:14px;color:var(--text-sub);line-height:1.6}
  /* 사이드 예약 카드 */
  .reserve-card{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);padding:24px;position:sticky;top:20px}
  .reserve-card h3{font-size:16px;font-weight:800;margin:0 0 20px;color:var(--text-main)}
  .reserve-info-row{display:flex;justify-content:space-between;font-size:14px;margin-bottom:12px;color:var(--text-sub)}
  .reserve-info-row strong{color:var(--text-main)}
  .btn-st-reserve-big{width:100%;padding:15px;border:none;border-radius:var(--radius-sm);background:#9333EA;color:#fff;font-size:16px;font-weight:800;cursor:pointer;margin-top:8px;transition:var(--transition)}
  .btn-st-reserve-big:hover{background:#6B21A8}
  .btn-call{width:100%;padding:12px;border:2px solid #9333EA;border-radius:var(--radius-sm);background:#fff;color:#9333EA;font-size:14px;font-weight:700;cursor:pointer;margin-top:10px;display:flex;align-items:center;justify-content:center;gap:6px}
  .btn-call svg{width:16px;height:16px;stroke:currentColor;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}
</style>
<div class="sdetail-wrap">
  <div>
    <div class="sdetail-photos">
      <img src="https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=600&q=70&auto=format&fit=crop" alt="스튜디오메인" onerror="this.src='https://placehold.co/600x400/F3E8FF/9333EA?text=스튜디오'">
      <img src="https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=300&q=70&auto=format&fit=crop" alt="스튜디오2" onerror="this.src='https://placehold.co/300x200/F3E8FF/9333EA?text=스튜디오'">
      <img src="https://images.unsplash.com/photo-1552053831-71594a27632d?w=300&q=70&auto=format&fit=crop" alt="스튜디오3" onerror="this.src='https://placehold.co/300x200/F3E8FF/9333EA?text=스튜디오'">
    </div>
    <div class="sdetail-head">
      <div class="sdetail-tags"><span class="sdtag type">애완동물 사진관</span><span class="sdtag open">예약가능</span></div>
      <div class="sdetail-name">하루필름 스튜디오</div>
      <div class="sdetail-rating">
        <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
        4.9 <span style="font-size:13px;color:var(--text-muted);font-weight:400">(96개 리뷰)</span>
      </div>
    </div>
    <div class="sdetail-info-grid">
      <div class="sdinfo-card">
        <div class="sdinfo-label"><svg viewBox="0 0 24 24"><path d="M21 10c0 7-9 13-9 13S3 17 3 10a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/></svg>주소</div>
        <div class="sdinfo-val">서울특별시 중구 명동길 45<br><small style="color:var(--text-muted)">현재 위치에서 0.9km</small></div>
      </div>
      <div class="sdinfo-card">
        <div class="sdinfo-label"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>영업시간</div>
        <div class="sdinfo-val">평일 11:00 ~ 20:00<br>주말 10:00 ~ 19:00<br>화요일 휴무</div>
      </div>
      <div class="sdinfo-card">
        <div class="sdinfo-label"><svg viewBox="0 0 24 24"><path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07A19.5 19.5 0 013.86 9.87 19.79 19.79 0 01.75 1.22 2 2 0 012.72 0h3a2 2 0 012 1.72 12.84 12.84 0 00.7 2.81 2 2 0 01-.45 2.11L6.91 7.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45c.9.356 1.844.559 2.81.7A2 2 0 0122 16.92z"/></svg>전화번호</div>
        <div class="sdinfo-val">02-2345-6789</div>
      </div>
      <div class="sdinfo-card">
        <div class="sdinfo-label"><svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>촬영 형태</div>
        <div class="sdinfo-val">실내 스튜디오 · 자연광 촬영<br>가족사진 / 프로필 / 시즌 컨셉</div>
      </div>
    </div>

    <div id="kakao-map" style="width:100%;height:280px;border-radius:12px;overflow:hidden;margin-bottom:28px"></div>
    <%@ include file="/WEB-INF/views/common/kakaomap.jsp" %>
    
    <h3 style="font-size:18px;font-weight:800;margin-bottom:16px">포트폴리오</h3>
    <div class="port-grid">
      <img src="https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=300&q=70&auto=format&fit=crop" alt="작품1" onerror="this.src='https://placehold.co/300x300/F3E8FF/9333EA?text=사진'">
      <img src="https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=300&q=70&auto=format&fit=crop" alt="작품2" onerror="this.src='https://placehold.co/300x300/F3E8FF/9333EA?text=사진'">
      <img src="https://images.unsplash.com/photo-1552053831-71594a27632d?w=300&q=70&auto=format&fit=crop" alt="작품3" onerror="this.src='https://placehold.co/300x300/F3E8FF/9333EA?text=사진'">
      <img src="https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=300&q=70&auto=format&fit=crop" alt="작품4" onerror="this.src='https://placehold.co/300x300/F3E8FF/9333EA?text=사진'">
    </div>

    <h3 style="font-size:18px;font-weight:800;margin-bottom:16px">촬영 패키지</h3>
    <div class="pkg-grid">
      <div class="pkg-card">
        <div class="pkg-card-head">
          <span class="pkg-badge basic">BASIC</span>
          <div class="pkg-name">베이직</div>
          <div class="pkg-price">30,000원</div>
        </div>
        <ul class="pkg-features"><li>실내 촬영 30분</li><li>보정 사진 10장</li><li>디지털 파일 제공</li></ul>
        <button class="pkg-select-btn" onclick="location.href='${contextPath}/studio/reserve?id=${id}&pkg=basic'">이 패키지로 예약</button>
      </div>
      <div class="pkg-card reco">
        <div class="pkg-card-head">
          <span class="pkg-badge profile">PROFILE</span>
          <div class="pkg-name">프로필</div>
          <div class="pkg-price">55,000원</div>
        </div>
        <ul class="pkg-features"><li>실내 촬영 1시간</li><li>보정 사진 20장</li><li>배경 2종 선택</li><li>디지털 파일 제공</li></ul>
        <button class="pkg-select-btn" onclick="location.href='${contextPath}/studio/reserve?id=${id}&pkg=profile'">이 패키지로 예약</button>
      </div>
      <div class="pkg-card">
        <div class="pkg-card-head">
          <span class="pkg-badge premium">PREMIUM</span>
          <div class="pkg-name">프리미엄</div>
          <div class="pkg-price">90,000원</div>
        </div>
        <ul class="pkg-features"><li>실내+야외 촬영 2시간</li><li>보정 사진 40장</li><li>배경 무제한</li><li>앨범 제작 포함</li></ul>
        <button class="pkg-select-btn" onclick="location.href='${contextPath}/studio/reserve?id=${id}&pkg=premium'">이 패키지로 예약</button>
      </div>
    </div>

    <h3 style="font-size:18px;font-weight:800;margin-bottom:16px">리뷰 (96)</h3>
    <div class="review-item">
      <div class="review-item-head">
        <div><span class="reviewer-name">최유나</span> <span style="color:var(--text-muted);font-size:12px">· 비숑 · 프리미엄</span></div>
        <div style="display:flex;flex-direction:column;align-items:flex-end;gap:3px">
          <div class="review-item-stars"><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg></div>
          <span class="review-item-date">2025.06.25</span>
        </div>
      </div>
      <div class="review-item-text">콩이 표정 하나하나가 다 살아있는 느낌이에요. 보정도 자연스럽고 앨범 퀄리티도 정말 좋았습니다!</div>
    </div>
    <div class="review-item">
      <div class="review-item-head">
        <div><span class="reviewer-name">박지호</span> <span style="color:var(--text-muted);font-size:12px">· 푸들 · 베이직</span></div>
        <div style="display:flex;flex-direction:column;align-items:flex-end;gap:3px">
          <div class="review-item-stars"><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg></div>
          <span class="review-item-date">2025.06.20</span>
        </div>
      </div>
      <div class="review-item-text">가성비 최고예요! 베이직 패키지인데도 사진 퀄리티가 기대 이상이었습니다.</div>
    </div>
  </div>

  <div class="reserve-card">
    <h3>촬영 예약하기</h3>
    <div class="reserve-info-row"><span>예약 가능 시간</span><strong>오늘 3슬롯 남음</strong></div>
    <div class="reserve-info-row"><span>평균 촬영시간</span><strong>30~120분</strong></div>
    <div class="reserve-info-row"><span>촬영 비용</span><strong>30,000원~</strong></div>
    <button class="btn-st-reserve-big" onclick="location.href='${contextPath}/studio/reserve?id=${id}'">예약하기</button>
    <button class="btn-call"><svg viewBox="0 0 24 24"><path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07A19.5 19.5 0 013.86 9.87 19.79 19.79 0 01.75 1.22 2 2 0 012.72 0h3a2 2 0 012 1.72 12.84 12.84 0 00.7 2.81 2 2 0 01-.45 2.11L6.91 7.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45c.9.356 1.844.559 2.81.7A2 2 0 0122 16.92z"/></svg>02-2345-6789</button>
  </div>
</div>
<%@ include file="/WEB-INF/views/common/footer.jsp" %>
