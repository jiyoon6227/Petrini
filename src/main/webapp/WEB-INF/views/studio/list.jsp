<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="studio" />
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
  .st-hero{background:linear-gradient(135deg,#3B0764 0%,#9333EA 60%,#C084FC 100%);padding:40px 0;color:#fff;text-align:center}
  .st-hero-inner{max-width:var(--inner-width);margin:0 auto;padding:0 20px}
  .st-hero h1{font-size:28px;font-weight:800;margin:0 0 8px}
  .st-hero p{font-size:14px;opacity:.85;margin:0}
  .st-wrap{max-width:var(--inner-width);margin:32px auto 80px;padding:0 20px;display:grid;grid-template-columns:280px 1fr;gap:24px}
  .st-filter-card{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);padding:20px;margin-bottom:14px}
  .st-filter-title{font-size:14px;font-weight:800;color:var(--text-main);margin:0 0 14px}
  .st-filter-input{width:100%;border:1px solid var(--border);border-radius:var(--radius-sm);padding:10px 14px;font-size:14px;outline:none;font-family:inherit;box-sizing:border-box}
  .st-filter-input:focus{border-color:#9333EA}
  .st-chip{padding:6px 14px;border:1px solid var(--border);border-radius:50px;font-size:12px;font-weight:600;color:var(--text-sub);cursor:pointer;transition:var(--transition);background:#fff;display:inline-block}
  .st-chip:hover,.st-chip.on{border-color:#9333EA;background:#F3E8FF;color:#6B21A8}
  .st-chips{display:flex;flex-wrap:wrap;gap:7px}
  .st-toggle-row{display:flex;justify-content:space-between;align-items:center;font-size:14px;color:var(--text-sub)}
  .toggle{position:relative;display:inline-block;width:42px;height:24px}
  .toggle input{opacity:0;width:0;height:0}
  .toggle-slider{position:absolute;cursor:pointer;inset:0;background:#ccc;border-radius:24px;transition:.3s}
  .toggle-slider:before{content:"";position:absolute;width:18px;height:18px;left:3px;bottom:3px;background:#fff;border-radius:50%;transition:.3s}
  .toggle input:checked+.toggle-slider{background:#9333EA}
  .toggle input:checked+.toggle-slider:before{transform:translateX(18px)} 
  .st-list-head{display:flex;justify-content:space-between;align-items:center;margin-bottom:14px}
  .st-list-head span{font-size:14px;color:var(--text-sub)}
  .st-list-head strong{color:var(--text-main);font-weight:700}
  /* 목록형 카드 */
  .st-card{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);padding:18px;margin-bottom:12px;display:flex;gap:16px;align-items:flex-start;transition:var(--transition);cursor:pointer}
  .st-card:hover{box-shadow:var(--shadow-md);transform:translateY(-2px)}
  .st-thumb{width:88px;height:88px;border-radius:var(--radius-sm);object-fit:cover;flex-shrink:0}
  .st-body{flex:1;min-width:0}
  .st-tags{display:flex;gap:6px;flex-wrap:wrap;margin-bottom:6px}
  .st-tag{font-size:11px;font-weight:700;padding:2px 8px;border-radius:20px}
  .st-tag.type{background:#F3E8FF;color:#9333EA}
  .st-tag.open{background:#DCFCE7;color:#16A34A}
  .st-tag.close{background:#FEE2E2;color:#DC2626}
  .st-name{font-size:16px;font-weight:800;color:var(--text-main);margin-bottom:4px}
  .st-meta{font-size:13px;color:var(--text-muted);display:flex;flex-direction:column;gap:3px}
  .st-meta-row{display:flex;align-items:center;gap:5px}
  .st-meta-row svg{width:13px;height:13px;stroke:var(--text-muted);fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;flex-shrink:0}
  .st-right{display:flex;flex-direction:column;align-items:flex-end;gap:8px;flex-shrink:0}
  .st-rating{display:flex;align-items:center;gap:4px;font-size:14px;font-weight:700;color:var(--text-main)}
  .st-rating svg{width:14px;height:14px;fill:var(--yellow)}
  .st-price{font-size:13px;color:#9333EA;font-weight:800}
  .btn-st-reserve{padding:8px 16px;border:none;border-radius:var(--radius-sm);background:#9333EA;color:#fff;font-size:13px;font-weight:700;cursor:pointer;white-space:nowrap}
  .btn-st-reserve:hover{background:#6B21A8}
</style>

<div class="st-hero">
  <div class="st-hero-inner">
    <h1>반려동물의 특별한 순간을 담다</h1>
    <p>전문 작가가 찍어주는 우리 아이만의 프로필 사진과 가족사진</p>
  </div>
</div>

<div class="st-wrap">
  <aside>
    <div class="st-filter-card">
      <div class="st-filter-title">지역 검색</div>
      <input type="text" class="st-filter-input" placeholder="지역명, 사진관명 검색...">
    </div>
    <div class="st-filter-card">
      <div class="st-filter-title">촬영 스타일</div>
      <div class="st-chips">
        <span class="st-chip on">전체</span>
        <span class="st-chip">프로필</span>
        <span class="st-chip">가족사진</span>
        <span class="st-chip">야외촬영</span>
        <span class="st-chip">시즌 컨셉</span>
      </div>
    </div>
    <div class="st-filter-card">
      <div class="st-filter-title">반려동물 종류</div>
      <div class="st-chips">
        <span class="st-chip on">전체</span>
        <span class="st-chip">강아지</span>
        <span class="st-chip">고양이</span>
        <span class="st-chip">소동물</span>
      </div>
    </div>
    <div class="st-filter-card">
      <div class="st-filter-title">가격대</div>
      <div class="st-chips">
        <span class="st-chip on">전체</span>
        <span class="st-chip">~5만원</span>
        <span class="st-chip">5~10만원</span>
        <span class="st-chip">10만원~</span>
      </div>
    </div>
    <div class="st-filter-card">
      <div class="st-toggle-row">
        <span>당일 예약 가능만 보기</span>
        <label class="toggle"><input type="checkbox" checked><span class="toggle-slider"></span></label>
      </div>
    </div>
  </aside>

  <div>
    <%-- <div style="background:var(--bg-page);border-radius:var(--radius-md);overflow:hidden;height:280px;margin-bottom:28px" id="map">
      <img src="https://images.unsplash.com/photo-1524661135-423995f22d0b?w=900&q=70&auto=format&fit=crop" alt="지도" onerror="this.src='https://placehold.co/900x280/EAF7F2/2BAB82?text=카카오맵+API+연동+예정'">
    </div>   --%>
    <div id="kakao-map" style="width:100%;height:280px;border-radius:12px;overflow:hidden;margin-bottom:28px"></div>
    <%@ include file="/WEB-INF/views/common/kakaomap.jsp" %>
    <div class="st-list-head">
      <span>검색 결과 <strong>12개</strong> 사진관</span>
      <div style="display:flex;gap:8px">
        <span class="st-chip on" style="font-size:12px">인기순</span>
        <span class="st-chip" style="font-size:12px">별점순</span>
        <span class="st-chip" style="font-size:12px">가격순</span>
      </div>
    </div>

    <div class="st-card" onclick="location.href='${contextPath}/studio/detail?id=1'">
      <img class="st-thumb" src="https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=176&q=70&auto=format&fit=crop" alt="하루필름 스튜디오" onerror="this.src='https://placehold.co/88x88/F3E8FF/9333EA?text=사진'">
      <div class="st-body">
        <div class="st-tags"><span class="st-tag type">애완동물 사진관</span><span class="st-tag open">예약가능</span></div>
        <div class="st-name">하루필름 스튜디오</div>
        <div class="st-meta">
          <div class="st-meta-row"><svg viewBox="0 0 24 24"><path d="M21 10c0 7-9 13-9 13S3 17 3 10a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/></svg>서울 중구 명동 · 0.9km</div>
          <div class="st-meta-row"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>평일 11:00~20:00 · 화요일 휴무</div>
          <div class="st-meta-row"><svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>프로필·가족사진·시즌 컨셉</div>
        </div>
      </div>
      <div class="st-right">
        <div class="st-rating"><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>4.9 (96)</div>
        <span class="st-price">30,000원~</span>
        <button class="btn-st-reserve" onclick="event.stopPropagation();location.href='${contextPath}/studio/reserve?id=1'">예약하기</button>
      </div>
    </div>

    <div class="st-card" onclick="location.href='${contextPath}/studio/detail?id=2'">
      <img class="st-thumb" src="https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=176&q=70&auto=format&fit=crop" alt="몽글몽글 펫스튜디오" onerror="this.src='https://placehold.co/88x88/F3E8FF/9333EA?text=사진'">
      <div class="st-body">
        <div class="st-tags"><span class="st-tag type">애완동물 사진관</span><span class="st-tag open">예약가능</span></div>
        <div class="st-name">몽글몽글 펫스튜디오</div>
        <div class="st-meta">
          <div class="st-meta-row"><svg viewBox="0 0 24 24"><path d="M21 10c0 7-9 13-9 13S3 17 3 10a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/></svg>서울 마포구 연남동 · 1.5km</div>
          <div class="st-meta-row"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>매일 10:00~21:00</div>
          <div class="st-meta-row"><svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>야외촬영·가족사진</div>
        </div>
      </div>
      <div class="st-right">
        <div class="st-rating"><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>4.7 (61)</div>
        <span class="st-price">35,000원~</span>
        <button class="btn-st-reserve" onclick="event.stopPropagation();location.href='${contextPath}/studio/reserve?id=2'">예약하기</button>
      </div>
    </div>

    <div class="st-card" onclick="location.href='${contextPath}/studio/detail?id=3'">
      <img class="st-thumb" src="https://images.unsplash.com/photo-1601758125946-6ac4633a26e3?w=176&q=70&auto=format&fit=crop" alt="포레스트 펫포토" onerror="this.src='https://placehold.co/88x88/F3E8FF/9333EA?text=사진'">
      <div class="st-body">
        <div class="st-tags"><span class="st-tag type">애완동물 사진관</span><span class="st-tag open">예약가능</span></div>
        <div class="st-name">포레스트 펫포토</div>
        <div class="st-meta">
          <div class="st-meta-row"><svg viewBox="0 0 24 24"><path d="M21 10c0 7-9 13-9 13S3 17 3 10a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/></svg>서울 성동구 성수동 · 2.8km</div>
          <div class="st-meta-row"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>평일 10:00~19:00 (점심 13~14시)</div>
          <div class="st-meta-row"><svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>야외촬영 전문·시즌 컨셉</div>
        </div>
      </div>
      <div class="st-right">
        <div class="st-rating"><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>4.8 (44)</div>
        <span class="st-price">40,000원~</span>
        <button class="btn-st-reserve" onclick="event.stopPropagation();location.href='${contextPath}/studio/reserve?id=3'">예약하기</button>
      </div>
    </div>

    <div class="st-card" onclick="location.href='${contextPath}/studio/detail?id=4'">
      <img class="st-thumb" src="https://images.unsplash.com/photo-1583337130417-3346a1be7dee?w=176&q=70&auto=format&fit=crop" alt="위드펫 포토그래피" onerror="this.src='https://placehold.co/88x88/F3E8FF/9333EA?text=사진'">
      <div class="st-body">
        <div class="st-tags"><span class="st-tag type">애완동물 사진관</span><span class="st-tag close">금일마감</span></div>
        <div class="st-name">위드펫 포토그래피</div>
        <div class="st-meta">
          <div class="st-meta-row"><svg viewBox="0 0 24 24"><path d="M21 10c0 7-9 13-9 13S3 17 3 10a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/></svg>경기 성남시 분당구 · 5.2km</div>
          <div class="st-meta-row"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>평일 11:00~20:00 · 주말 10:00~18:00</div>
          <div class="st-meta-row"><svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>프로필·소동물 촬영 가능</div>
        </div>
      </div>
      <div class="st-right">
        <div class="st-rating"><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>4.9 (118)</div>
        <span class="st-price">30,000원~</span>
        <button class="btn-st-reserve" onclick="event.stopPropagation();location.href='${contextPath}/studio/reserve?id=4'" style="background:var(--text-muted)">예약하기</button>
      </div>
    </div>
  </div>
</div>

<script>
  document.querySelectorAll('.st-chip').forEach(c=>c.addEventListener('click',function(){
    this.closest('.st-chips,.st-list-head div').querySelectorAll('.st-chip').forEach(x=>x.classList.remove('on'));
    this.classList.add('on');
  }));
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
