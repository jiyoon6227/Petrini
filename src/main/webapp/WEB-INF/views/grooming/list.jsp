<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="grooming" />
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
  .gr-hero{background:linear-gradient(135deg,#831843 0%,#DB2777 60%,#F472B6 100%);padding:40px 0;color:#fff;text-align:center}
  .gr-hero-inner{max-width:var(--inner-width);margin:0 auto;padding:0 20px}
  .gr-hero h1{font-size:28px;font-weight:800;margin:0 0 8px}
  .gr-hero p{font-size:14px;opacity:.85;margin:0}
  .gr-wrap{max-width:var(--inner-width);margin:32px auto 80px;padding:0 20px;display:grid;grid-template-columns:280px 1fr;gap:24px}
  .gr-filter-card{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);padding:20px;margin-bottom:14px}
  .gr-filter-title{font-size:14px;font-weight:800;color:var(--text-main);margin:0 0 14px}
  .gr-filter-input{width:100%;border:1px solid var(--border);border-radius:var(--radius-sm);padding:10px 14px;font-size:14px;outline:none;font-family:inherit;box-sizing:border-box}
  .gr-filter-input:focus{border-color:#DB2777}
  .gr-chip{padding:6px 14px;border:1px solid var(--border);border-radius:50px;font-size:12px;font-weight:600;color:var(--text-sub);cursor:pointer;transition:var(--transition);background:#fff;display:inline-block}
  .gr-chip:hover,.gr-chip.on{border-color:#DB2777;background:#FDF2F8;color:#9D174D}
  .gr-chips{display:flex;flex-wrap:wrap;gap:7px}
  .gr-toggle-row{display:flex;justify-content:space-between;align-items:center;font-size:14px;color:var(--text-sub)}
  .toggle{position:relative;display:inline-block;width:42px;height:24px}
  .toggle input{opacity:0;width:0;height:0}
  .toggle-slider{position:absolute;cursor:pointer;inset:0;background:#ccc;border-radius:24px;transition:.3s}
  .toggle-slider:before{content:"";position:absolute;width:18px;height:18px;left:3px;bottom:3px;background:#fff;border-radius:50%;transition:.3s}
  .toggle input:checked+.toggle-slider{background:#9333EA}
  .toggle input:checked+.toggle-slider:before{transform:translateX(18px)}
  .gr-list-head{display:flex;justify-content:space-between;align-items:center;margin-bottom:14px}
  .gr-list-head span{font-size:14px;color:var(--text-sub)}
  .gr-list-head strong{color:var(--text-main);font-weight:700}
  .gr-card{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);padding:18px;margin-bottom:12px;display:flex;gap:16px;align-items:flex-start;transition:var(--transition);cursor:pointer}
  .gr-card:hover{box-shadow:var(--shadow-md);transform:translateY(-2px)}
  .gr-thumb{width:88px;height:88px;border-radius:var(--radius-sm);object-fit:cover;flex-shrink:0}
  .gr-body{flex:1;min-width:0}
  .gr-tags{display:flex;gap:6px;flex-wrap:wrap;margin-bottom:6px}
  .gr-tag{font-size:11px;font-weight:700;padding:2px 8px;border-radius:20px}
  .gr-tag.type{background:#FDF2F8;color:#DB2777}
  .gr-tag.open{background:#DCFCE7;color:#16A34A}
  .gr-tag.close{background:#FEE2E2;color:#DC2626}
  .gr-name{font-size:16px;font-weight:800;color:var(--text-main);margin-bottom:4px}
  .gr-meta{font-size:13px;color:var(--text-muted);display:flex;flex-direction:column;gap:3px}
  .gr-meta-row{display:flex;align-items:center;gap:5px}
  .gr-meta-row svg{width:13px;height:13px;stroke:var(--text-muted);fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;flex-shrink:0}
  .gr-right{display:flex;flex-direction:column;align-items:flex-end;gap:8px;flex-shrink:0}
  .gr-rating{display:flex;align-items:center;gap:4px;font-size:14px;font-weight:700;color:var(--text-main)}
  .gr-rating svg{width:14px;height:14px;fill:var(--yellow)}
  .gr-dist{font-size:12px;color:var(--text-muted)}
  .btn-gr-reserve{padding:8px 16px;border:none;border-radius:var(--radius-sm);background:#DB2777;color:#fff;font-size:13px;font-weight:700;cursor:pointer;white-space:nowrap}
  .btn-gr-reserve:hover{background:#9D174D}

</style>

<div class="gr-hero">
  <div class="gr-hero-inner">
    <h1>믿고 맡기는 애견미용실</h1>
    <p>전문 스타일리스트가 우리 아이를 더 예쁘고 건강하게 단장해드려요.</p>
  </div>
</div>

<%-- 2026-08-07 박유정 — 미용 목록 광고 배너 (POSITION_CD=GROOMING, store/list.jsp 동일) --%>
<%@ include file="/WEB-INF/views/common/ad-banner.jsp" %>

<div class="gr-wrap">
  <aside>
    <div class="gr-filter-card">
      <div class="gr-filter-title">지역 검색</div>
      <input type="text" class="gr-filter-input" placeholder="지역명, 미용실명 검색...">
    </div>
    <div class="gr-filter-card">
      <div class="gr-filter-title">시술 종류</div>
      <div class="gr-chips">
        <span class="gr-chip on">전체</span>
        <span class="gr-chip">전체미용</span>
        <span class="gr-chip">부분미용</span>
        <span class="gr-chip">목욕</span>
        <span class="gr-chip">염색</span>
      </div>
    </div>
    <div class="gr-filter-card">
      <div class="gr-filter-title">반려동물 종류</div>
      <div class="gr-chips">
        <span class="gr-chip on">전체</span>
        <span class="gr-chip">강아지</span>
        <span class="gr-chip">고양이</span>
      </div>
    </div>
    <div class="gr-filter-card">
      <div style="display:flex;justify-content:space-between;align-items:center;font-size:14px;color:var(--text-sub)">
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
    <div class="gr-list-head">  
      <span>검색 결과 <strong>16개</strong> 미용실</span>
      <div style="display:flex;gap:8px">
        <span class="gr-chip on" style="font-size:12px">거리순</span>
        <span class="gr-chip" style="font-size:12px">별점순</span>
        <span class="gr-chip" style="font-size:12px">리뷰순</span>
      </div>
    </div>

    <div class="gr-card" onclick="location.href='${contextPath}/grooming/detail?id=1'">
      <img class="gr-thumb" src="https://images.unsplash.com/photo-1591946614720-90a587da4a36?w=176&q=70&auto=format&fit=crop" alt="냥냥 그루밍샵" onerror="this.src='https://placehold.co/88x88/FDF2F8/DB2777?text=미용'">
      <div class="gr-body">
        <div class="gr-tags"><span class="gr-tag type">애견미용실</span><span class="gr-tag open">예약가능</span></div>
        <div class="gr-name">냥냥 그루밍샵</div>
        <div class="gr-meta">
          <div class="gr-meta-row"><svg viewBox="0 0 24 24"><path d="M21 10c0 7-9 13-9 13S3 17 3 10a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/></svg>서울 마포구 합정동 · 0.6km</div>
          <div class="gr-meta-row"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>평일 10:00~20:00 · 일요일 휴무</div>
          <div class="gr-meta-row"><svg viewBox="0 0 24 24"><path d="M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78L12 21.23l8.84-8.84a5.5 5.5 0 000-7.78z"/></svg>전체미용·가위컷·염색</div>
        </div>
      </div>
      <div class="gr-right">
        <div class="gr-rating"><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>4.8 (96)</div>
        <div class="gr-dist">0.6km</div>
        <button class="btn-gr-reserve" onclick="event.stopPropagation();location.href='${contextPath}/grooming/reserve?id=1'">예약하기</button>
      </div>
    </div>

    <div class="gr-card" onclick="location.href='${contextPath}/grooming/detail?id=2'">
      <img class="gr-thumb" src="https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=176&q=70&auto=format&fit=crop" alt="멍멍 펫살롱" onerror="this.src='https://placehold.co/88x88/FDF2F8/DB2777?text=미용'">
      <div class="gr-body">
        <div class="gr-tags"><span class="gr-tag type">애견미용실</span><span class="gr-tag open">예약가능</span></div>
        <div class="gr-name">멍멍 펫살롱</div>
        <div class="gr-meta">
          <div class="gr-meta-row"><svg viewBox="0 0 24 24"><path d="M21 10c0 7-9 13-9 13S3 17 3 10a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/></svg>서울 강남구 역삼동 · 1.2km</div>
          <div class="gr-meta-row"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>매일 09:00~21:00</div>
          <div class="gr-meta-row"><svg viewBox="0 0 24 24"><path d="M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78L12 21.23l8.84-8.84a5.5 5.5 0 000-7.78z"/></svg>위생미용·목욕·발톱정리</div>
        </div>
      </div>
      <div class="gr-right">
        <div class="gr-rating"><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>4.6 (54)</div>
        <div class="gr-dist">1.2km</div>
        <button class="btn-gr-reserve" onclick="event.stopPropagation();location.href='${contextPath}/grooming/reserve?id=2'">예약하기</button>
      </div>
    </div>

    <div class="gr-card" onclick="location.href='${contextPath}/grooming/detail?id=3'">
      <img class="gr-thumb" src="https://images.unsplash.com/photo-1516734212186-a967f81ad0d7?w=176&q=70&auto=format&fit=crop" alt="포메라니안 살롱" onerror="this.src='https://placehold.co/88x88/FDF2F8/DB2777?text=미용'">
      <div class="gr-body">
        <div class="gr-tags"><span class="gr-tag type">애견미용실</span><span class="gr-tag close">금일마감</span></div>
        <div class="gr-name">위드펫 그루밍 스튜디오</div>
        <div class="gr-meta">
          <div class="gr-meta-row"><svg viewBox="0 0 24 24"><path d="M21 10c0 7-9 13-9 13S3 17 3 10a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/></svg>서울 서초구 방배동 · 2.4km</div>
          <div class="gr-meta-row"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>평일 10:00~19:00 (점심 13~14시)</div>
          <div class="gr-meta-row"><svg viewBox="0 0 24 24"><path d="M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78L12 21.23l8.84-8.84a5.5 5.5 0 000-7.78z"/></svg>가위컷 전문·고양이 미용 가능</div>
        </div>
      </div>
      <div class="gr-right">
        <div class="gr-rating"><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>4.9 (137)</div>
        <div class="gr-dist">2.4km</div>
        <button class="btn-gr-reserve" onclick="event.stopPropagation();location.href='${contextPath}/grooming/reserve?id=3'" style="background:var(--text-muted)">예약하기</button>
      </div>
    </div>
  </div>
</div>

<script>
  document.querySelectorAll('.gr-chip').forEach(c=>c.addEventListener('click',function(){
    this.closest('.gr-chips,.gr-list-head div').querySelectorAll('.gr-chip').forEach(x=>x.classList.remove('on'));
    this.classList.add('on');
  }));
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
