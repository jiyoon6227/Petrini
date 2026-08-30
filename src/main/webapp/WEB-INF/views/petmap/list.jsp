<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="petmap" />
<%@ include file="/WEB-INF/views/common/header.jsp" %>
<style>
  .pm-hero{background:linear-gradient(135deg,#0F766E 0%,#14B8A6 60%,#5EEAD4 100%);padding:40px 0;color:#fff;text-align:center}
  .pm-hero-inner{max-width:var(--inner-width);margin:0 auto;padding:0 20px}
  .pm-hero h1{font-size:28px;font-weight:800;margin:0 0 8px}
  .pm-hero p{font-size:14px;opacity:.85;margin:0}
  .pm-wrap{max-width:var(--inner-width);margin:28px auto 80px;padding:0 20px}

  /* ── 검색 카드 (give/animal 패턴) ── */
  .search-card{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);padding:20px;margin-bottom:20px}
  .search-title{font-size:14px;font-weight:700;color:var(--text-main);margin:0 0 14px;display:flex;align-items:center;gap:7px}
  .search-title svg{width:15px;height:15px;stroke:#14B8A6;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}
  .search-form{display:flex;gap:10px;align-items:flex-end;flex-wrap:wrap}
  .sf-group{display:flex;flex-direction:column;gap:5px;min-width:130px}
  .sf-group label{font-size:12px;font-weight:600;color:var(--text-muted)}
  .sf-group select{border:1px solid var(--border);border-radius:var(--radius-sm);padding:9px 12px;font-size:14px;color:var(--text-main);outline:none;width:100%;box-sizing:border-box;font-family:inherit}
  .sf-group select:focus{border-color:#14B8A6}
  .btn-search{padding:9px 22px;border:none;border-radius:var(--radius-sm);background:#14B8A6;color:#fff;font-size:14px;font-weight:700;cursor:pointer;display:flex;align-items:center;gap:6px;white-space:nowrap;height:40px}
  .btn-search:hover{background:#0F766E}
  .btn-search svg{width:15px;height:15px;stroke:#fff;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}

  /* ── 하위 카테고리 행 ── */
  .sub-filter{margin-top:12px;padding-top:12px;border-top:1px solid var(--border);display:flex;gap:6px;flex-wrap:wrap;align-items:center}
  .sub-label{font-size:12px;font-weight:600;color:var(--text-muted);margin-right:4px}
  .sub-chip{padding:5px 14px;border:1.5px solid var(--border);border-radius:50px;font-size:12px;font-weight:600;color:var(--text-sub);cursor:pointer;background:var(--bg-card);text-decoration:none;display:inline-block}
  .sub-chip:hover{border-color:#14B8A6;color:#0F766E}
  .sub-chip.on{border-color:#14B8A6;background:#14B8A6;color:#fff}

  /* ── 본문: 지도 + 목록 ── */
  .pm-body{display:grid;grid-template-columns:1fr 360px;gap:20px;align-items:flex-start}
  .pm-map-wrap{position:sticky;top:20px}
  .pm-map{width:100%;height:520px;border-radius:var(--radius-md);overflow:hidden;border:1px solid var(--border)}
  .pm-map-search{display:flex;gap:8px;margin-bottom:12px}
  .pm-map-search input{flex:1;border:1px solid var(--border);border-radius:var(--radius-sm);padding:10px 14px;font-size:14px;outline:none;font-family:inherit}
  .pm-map-search input:focus{border-color:#14B8A6}
  .pm-map-search button{padding:10px 18px;border:none;border-radius:var(--radius-sm);background:#14B8A6;color:#fff;font-size:13px;font-weight:700;cursor:pointer;white-space:nowrap}
  .pm-list-head{display:flex;justify-content:space-between;align-items:center;margin-bottom:14px;font-size:14px;color:var(--text-sub)}
  .pm-list-head strong{color:var(--text-main)}
  .pm-place-card{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);padding:14px;margin-bottom:10px;display:flex;gap:12px;cursor:pointer;transition:var(--transition)}
  .pm-place-card:hover{box-shadow:var(--shadow-md);border-color:#14B8A6}
  .pm-place-card.active{border-color:#14B8A6;box-shadow:0 0 0 2px rgba(20,184,166,.2)}
  .pm-thumb{width:72px;height:72px;border-radius:var(--radius-sm);object-fit:cover;flex-shrink:0}
  .pm-info{flex:1;min-width:0}
  .pm-cat-badge{font-size:11px;font-weight:700;padding:2px 8px;border-radius:20px;display:inline-block;margin-bottom:5px;background:#F0FDFA;color:#0F766E}
  .pm-name{font-size:14px;font-weight:800;color:var(--text-main);margin-bottom:3px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
  .pm-addr{font-size:12px;color:var(--text-muted);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}

  /* 빈 상태 */
  .empty-box{display:flex;flex-direction:column;align-items:center;gap:14px;padding:80px 0;text-align:center;grid-column:1/-1}
  .empty-icon{width:64px;height:64px;border-radius:50%;background:#F0FDFA;display:flex;align-items:center;justify-content:center}
  .empty-icon svg{width:30px;height:30px;stroke:#14B8A6;fill:none;stroke-width:1.6;stroke-linecap:round;stroke-linejoin:round}

  /* 페이징 */
  .pm-paging{display:flex;justify-content:center;gap:5px;margin-top:20px;flex-wrap:wrap}
  .pm-paging a{display:inline-flex;align-items:center;justify-content:center;width:36px;height:36px;border:1px solid var(--border);border-radius:var(--radius-sm);font-size:13px;color:var(--text-sub);text-decoration:none;cursor:pointer}
  .pm-paging a:hover{border-color:#14B8A6;color:#14B8A6}
  .pm-paging a.on{background:#14B8A6;color:#fff;border-color:#14B8A6}
  .pm-paging a svg{width:14px;height:14px;stroke:currentColor;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}

  /* 로딩 */
  .search-loading{display:none;flex-direction:column;align-items:center;gap:16px;padding:60px 0;text-align:center;grid-column:1/-1}
  .search-loading.is-show{display:flex}
  .search-loading p{margin:0;font-size:18px;font-weight:700;color:var(--text-main)}
  .search-loading small{font-size:13px;color:var(--text-muted)}
  .loading-spinner{width:40px;height:40px;border:4px solid var(--border);border-top-color:#14B8A6;border-radius:50%;animation:spin .8s linear infinite}
  @keyframes spin{to{transform:rotate(360deg)}}
</style>

<div class="pm-hero">
  <div class="pm-hero-inner">
    <h1>펫맵</h1>
    <p>반려동물과 함께 갈 수 있는 장소를 지도에서 찾아보세요</p>
  </div>
</div>

<div class="pm-wrap">

  <%-- ═══════════ 검색 카드 (give/animal 패턴) ═══════════ --%>
  <div class="search-card">
    <div class="search-title">
      <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
      반려동물 동반 장소 검색
    </div>
    <form class="search-form" id="searchForm" method="get" action="${contextPath}/petmap">
      <div class="sf-group">
        <label>관광타입</label>
        <select name="contentTypeId">
          <option value="">전체</option>
          <option value="12" ${contentTypeId eq '12' ? 'selected' : ''}>관광지</option>
          <option value="14" ${contentTypeId eq '14' ? 'selected' : ''}>문화시설</option>
          <option value="15" ${contentTypeId eq '15' ? 'selected' : ''}>축제/행사</option>
          <option value="28" ${contentTypeId eq '28' ? 'selected' : ''}>레포츠</option>
          <option value="32" ${contentTypeId eq '32' ? 'selected' : ''}>숙박</option>
          <option value="38" ${contentTypeId eq '38' ? 'selected' : ''}>쇼핑</option>
          <option value="39" ${contentTypeId eq '39' ? 'selected' : ''}>음식점</option>
        </select>
      </div>
      <div class="sf-group">
        <label>지역</label>
        <select name="areaCode">
          <option value="">전체 지역</option>
          <option value="1"  ${areaCode eq '1'  ? 'selected' : ''}>서울</option>
          <option value="2"  ${areaCode eq '2'  ? 'selected' : ''}>인천</option>
          <option value="3"  ${areaCode eq '3'  ? 'selected' : ''}>대전</option>
          <option value="4"  ${areaCode eq '4'  ? 'selected' : ''}>대구</option>
          <option value="5"  ${areaCode eq '5'  ? 'selected' : ''}>광주</option>
          <option value="6"  ${areaCode eq '6'  ? 'selected' : ''}>부산</option>
          <option value="7"  ${areaCode eq '7'  ? 'selected' : ''}>울산</option>
          <option value="8"  ${areaCode eq '8'  ? 'selected' : ''}>세종</option>
          <option value="31" ${areaCode eq '31' ? 'selected' : ''}>경기</option>
          <option value="32" ${areaCode eq '32' ? 'selected' : ''}>강원</option>
          <option value="33" ${areaCode eq '33' ? 'selected' : ''}>충북</option>
          <option value="34" ${areaCode eq '34' ? 'selected' : ''}>충남</option>
          <option value="35" ${areaCode eq '35' ? 'selected' : ''}>경북</option>
          <option value="36" ${areaCode eq '36' ? 'selected' : ''}>경남</option>
          <option value="37" ${areaCode eq '37' ? 'selected' : ''}>전북</option>
          <option value="38" ${areaCode eq '38' ? 'selected' : ''}>전남</option>
          <option value="39" ${areaCode eq '39' ? 'selected' : ''}>제주</option>
        </select>
      </div>
      <input type="hidden" name="pageNo" value="1">
      <input type="hidden" name="search" value="true">
      <button type="submit" class="btn-search">
        <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
        조회
      </button>
    </form>

    <%-- 하위 카테고리 (조회 후 + contentTypeId 선택 시에만 표시) --%>
    <c:if test="${not empty cat1List}">
      <div class="sub-filter">
        <span class="sub-label">대분류</span>
        <a class="sub-chip ${empty cat1 ? 'on' : ''}"
           onclick="buildUrl('cat1','')">전체</a>
        <c:forEach var="c" items="${cat1List}">
          <a class="sub-chip ${cat1 eq c.code ? 'on' : ''}"
             onclick="buildUrl('cat1','${c.code}')">${c.name}</a>
        </c:forEach>
      </div>
    </c:if>
    <c:if test="${not empty cat2List}">
      <div class="sub-filter">
        <span class="sub-label">중분류</span>
        <a class="sub-chip ${empty cat2 ? 'on' : ''}"
           onclick="buildUrl('cat2','')">전체</a>
        <c:forEach var="c" items="${cat2List}">
          <a class="sub-chip ${cat2 eq c.code ? 'on' : ''}"
             onclick="buildUrl('cat2','${c.code}')">${c.name}</a>
        </c:forEach>
      </div>
    </c:if>
  </div>

  <%-- ═══════════ 결과 영역 ═══════════ --%>

  <%-- 로딩 인디케이터 --%>
  <div id="searchLoading" class="search-loading">
    <div class="loading-spinner"></div>
    <p>반려동물 동반 장소를 찾고 있어요</p>
    <small>잠시만 기다려주세요!</small>
  </div>

  <%-- [조회] 안 눌렀을 때 — 안내 메시지 --%>
  <c:if test="${!searched}">
    <div class="empty-box">
      <div class="empty-icon">
        <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
      </div>
      <p style="font-size:15px;font-weight:600;color:var(--text-main);margin:0">
        조건을 선택한 뒤 [조회]를 눌러 주세요.
      </p>
      <small style="font-size:13px;color:var(--text-muted)">
        관광타입·지역을 고른 후 조회하면 결과가 빠르게 표시됩니다.
      </small>
    </div>
  </c:if>

  <%-- [조회] 눌렀을 때 — 지도 + 목록 --%>
  <c:if test="${searched}">
    <div class="pm-body">
      <%-- 지도 --%>
      <div class="pm-map-wrap">
        <%-- <div class="pm-map-search">
          <input type="text" id="mapSearchInput" placeholder="장소명으로 지도 이동...">
          <button type="button" onclick="searchPlace()">검색</button>
        </div> --%>
        <div class="pm-map" id="kakao-map"></div>
        <%@ include file="/WEB-INF/views/common/kakaomap.jsp" %>
      </div>

      <%-- 장소 목록 --%>
      <div>
        <div class="pm-list-head">
          <span>총 <strong>${totalCount}</strong>개 장소 (${pageNo}/${totalPages} 페이지)</span>
        </div>

        <c:choose>
          <c:when test="${not empty places}">
            <c:forEach var="p" items="${places}" varStatus="st">
              <div class="pm-place-card" id="card-${st.count}" onclick="selectPlace(${st.count})">
                <img class="pm-thumb"
                     src="${not empty p.firstimage ? p.firstimage : 'https://placehold.co/72x72/F0FDFA/14B8A6?text=사진없음'}"
                     alt="${p.title}"
                     onerror="this.src='https://placehold.co/72x72/F0FDFA/14B8A6?text=사진없음'">
                <div class="pm-info">
                  <%-- contenttypeid를 한글 라벨로 변환 --%>
                  <span class="pm-cat-badge">
                    <c:choose>
                      <c:when test="${not empty typeLabels[p.contenttypeid]}">${typeLabels[p.contenttypeid]}</c:when>
                      <c:otherwise>${p.contenttypeid}</c:otherwise>
                    </c:choose>
                  </span>
                  <div class="pm-name">${p.title}</div>
                  <div class="pm-addr">${p.addr1}</div>
                </div>
              </div>
            </c:forEach>
          </c:when>
          <c:otherwise>
            <div class="empty-box">
              <div class="empty-icon">
                <svg viewBox="0 0 24 24"><path d="M21 10c0 7-9 13-9 13S3 17 3 10a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/></svg>
              </div>
              <p style="font-size:15px;font-weight:600;color:var(--text-main);margin:0">검색 결과가 없습니다.</p>
              <small style="font-size:13px;color:var(--text-muted)">다른 조건으로 검색해보세요.</small>
            </div>
          </c:otherwise>
        </c:choose>

        <%-- 페이징 (search=true 유지) --%>
        <c:if test="${totalPages > 1}">
          <div class="pm-paging">
            <c:if test="${pageNo > 1}">
              <a onclick="buildUrl('pageNo','${pageNo - 1}')">
                <svg viewBox="0 0 24 24"><polyline points="15 18 9 12 15 6"/></svg>
              </a>
            </c:if>
            <c:set var="startPage" value="${pageNo - ((pageNo - 1) % 5)}" />
            <c:set var="endPage" value="${startPage + 4 > totalPages ? totalPages : startPage + 4}" />
            <c:forEach begin="${startPage}" end="${endPage}" var="p">
              <a class="${p == pageNo ? 'on' : ''}"
                 onclick="buildUrl('pageNo','${p}')">${p}</a>
            </c:forEach>
            <c:if test="${pageNo < totalPages}">
              <a onclick="buildUrl('pageNo','${pageNo + 1}')">
                <svg viewBox="0 0 24 24"><polyline points="9 18 15 12 9 6"/></svg>
              </a>
            </c:if>
          </div>
        </c:if>
      </div>
    </div>
  </c:if>
</div>

<script>
/* ═══ 필터 URL 빌더 (search=true 항상 포함) ═══ */
function buildUrl(param, value) {
    var filters = {
        contentTypeId: '${contentTypeId}',
        areaCode:      '${areaCode}',
        cat1:          '${cat1}',
        cat2:          '${cat2}',
        pageNo:        '${pageNo}'
    };
    filters[param] = value;

    if (param === 'contentTypeId') { filters.cat1 = ''; filters.cat2 = ''; filters.pageNo = '1'; }
    if (param === 'cat1') { filters.cat2 = ''; filters.pageNo = '1'; }
    if (param === 'cat2' || param === 'areaCode') { filters.pageNo = '1'; }

    var url = '${contextPath}/petmap?search=true&pageNo=' + filters.pageNo;
    if (filters.contentTypeId) url += '&contentTypeId=' + filters.contentTypeId;
    if (filters.areaCode)      url += '&areaCode=' + filters.areaCode;
    if (filters.cat1)          url += '&cat1=' + filters.cat1;
    if (filters.cat2)          url += '&cat2=' + filters.cat2;

    showLoading();
    location.href = url;
}

/* ═══ 로딩 표시 ═══ */
function showLoading() {
    var el = document.getElementById('searchLoading');
    if (el) el.classList.add('is-show');
}
// 검색 폼 제출 시 로딩
var form = document.getElementById('searchForm');
if (form) {
    form.addEventListener('submit', showLoading);
}

/* ═══ 지도 인터랙션 ═══ */
var PLACES = [
  <c:if test="${searched}">
  <c:forEach items="${places}" var="p" varStatus="st">
    {
      id: ${st.count},
      title: "${p.title}",
      addr1: "${p.addr1}",
      mapx: ${not empty p.mapx ? p.mapx : '0'},
      mapy: ${not empty p.mapy ? p.mapy : '0'}
    }
    <c:if test="${!st.last}">,</c:if>
  </c:forEach>
  </c:if>
];

var map;
var markers = [];
var infowindows = [];

document.addEventListener('DOMContentLoaded', function() { initMap(); });

function initMap() {
    if (!window.kakaoMap) { setTimeout(initMap, 100); return; }
    map = window.kakaoMap;
    if (PLACES.length > 0) renderMarkers(PLACES);
}

function renderMarkers(list) {
    for (var i = 0; i < markers.length; i++) { markers[i].setMap(null); }
    markers = []; infowindows = [];
    var bounds = new kakao.maps.LatLngBounds();
    var hasMarker = false;

    for (var i = 0; i < list.length; i++) {
        var p = list[i];
        if (p.mapx === 0 || p.mapy === 0) continue;
        var pos = new kakao.maps.LatLng(p.mapy, p.mapx);
        var marker = new kakao.maps.Marker({ position: pos, map: map });
        var iw = new kakao.maps.InfoWindow({
            content: '<div style="padding:6px 10px;font-size:12px;font-weight:700;white-space:nowrap">' + p.title + '</div>',
            removable: true
        });
        addMarkerEvent(marker, iw, p.id);
        markers.push(marker); infowindows.push(iw);
        bounds.extend(pos); hasMarker = true;
    }
    if (hasMarker) map.setBounds(bounds);
}

function addMarkerEvent(marker, infowindow, placeId) {
    kakao.maps.event.addListener(marker, 'click', function() {
        for (var i = 0; i < infowindows.length; i++) { infowindows[i].close(); }
        infowindow.open(map, marker);
        highlightCard(placeId);
    });
}

function selectPlace(id) {
    var place = null; var idx = -1; var mi = 0;
    for (var i = 0; i < PLACES.length; i++) {
        if (PLACES[i].mapx === 0 || PLACES[i].mapy === 0) continue;
        if (PLACES[i].id === id) { place = PLACES[i]; idx = mi; break; }
        mi++;
    }
    if (!place) return;
    map.setCenter(new kakao.maps.LatLng(place.mapy, place.mapx));
    map.setLevel(4);
    if (idx >= 0) {
        for (var i = 0; i < infowindows.length; i++) { infowindows[i].close(); }
        infowindows[idx].open(map, markers[idx]);
    }
    highlightCard(id);
}

function highlightCard(id) {
    var cards = document.querySelectorAll('.pm-place-card');
    for (var i = 0; i < cards.length; i++) { cards[i].classList.remove('active'); }
    var card = document.getElementById('card-' + id);
    if (card) { card.classList.add('active'); card.scrollIntoView({ behavior:'smooth', block:'nearest' }); }
}

function searchPlace() {
    var keyword = document.getElementById('mapSearchInput').value.trim();
    if (!keyword) return;
    window.kakaoPs.keywordSearch(keyword, function(results, status) {
        if (status === kakao.maps.services.Status.OK) {
            map.setCenter(new kakao.maps.LatLng(results[0].y, results[0].x));
            map.setLevel(5);
        } else { alert('검색 결과가 없습니다.'); }
    });
}
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
