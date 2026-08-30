<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="hospital" />

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
  .hosp-hero{background:linear-gradient(135deg,#0C4A6E 0%,#0284C7 60%,#38BDF8 100%);padding:40px 0;color:#fff;text-align:center}
  .hosp-hero-inner{max-width:var(--inner-width);margin:0 auto;padding:0 20px}
  .hosp-hero h1{font-size:28px;font-weight:800;margin:0 0 8px}
  .hosp-hero p{font-size:14px;opacity:.85;margin:0}
  .hosp-wrap{max-width:var(--inner-width);margin:32px auto 80px;padding:0 20px;display:grid;grid-template-columns:340px 1fr;gap:24px}
  .hosp-filter-card{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);padding:20px;margin-bottom:14px}
  .hosp-filter-title{font-size:14px;font-weight:800;color:var(--text-main);margin:0 0 14px}
  .hosp-filter-input{width:100%;border:1px solid var(--border);border-radius:var(--radius-sm);padding:10px 14px;font-size:14px;outline:none;font-family:inherit;box-sizing:border-box}
  .hosp-filter-input:focus{border-color:var(--primary)}
  .hosp-filter-chips{display:flex;flex-wrap:wrap;gap:7px}
  .chip{padding:6px 14px;border:1px solid var(--border);border-radius:50px;font-size:12px;font-weight:600;color:var(--text-sub);cursor:pointer;transition:var(--transition);background:#fff}
  .chip:hover,.chip.on{border-color:var(--primary);background:var(--primary-light);color:var(--primary-dark)}
  .hosp-toggle-row{display:flex;justify-content:space-between;align-items:center;font-size:14px;color:var(--text-sub)}
  .toggle{position:relative;display:inline-block;width:42px;height:24px}
  .toggle input{opacity:0;width:0;height:0}
  .toggle-slider{position:absolute;cursor:pointer;inset:0;background:#ccc;border-radius:24px;transition:.3s}
  .toggle-slider:before{content:"";position:absolute;width:18px;height:18px;left:3px;bottom:3px;background:#fff;border-radius:50%;transition:.3s}
  .toggle input:checked+.toggle-slider{background:var(--primary)}
  .toggle input:checked+.toggle-slider:before{transform:translateX(18px)}
  /* 지도 영역 */
  .hosp-map-area{background:var(--bg-page);border:1px solid var(--border);border-radius:var(--radius-md);height:280px;display:flex;align-items:center;justify-content:center;margin-bottom:14px;overflow:hidden}
  .hosp-map-area img{width:100%;height:100%;object-fit:cover;border-radius:var(--radius-md)}
  /* 지도 위 검색바 */
  .hosp-map-search{display:flex;gap:8px;margin-bottom:12px}
  .hosp-map-search input{
    flex:1;border:1px solid var(--border);border-radius:var(--radius-sm);
    padding:10px 14px;font-size:14px;outline:none;font-family:inherit
  }
  .hosp-map-search input:focus{border-color:var(--primary)}
  .hosp-map-search button{
    padding:10px 18px;border:none;border-radius:var(--radius-sm);
    background:var(--primary);color:#fff;font-size:13px;font-weight:700;cursor:pointer;white-space:nowrap
  }
  /* 병원 목록 */
  .hosp-list-head{display:flex;justify-content:space-between;align-items:center;margin-bottom:14px}
  .hosp-list-head span{font-size:14px;color:var(--text-sub)}
  .hosp-list-head strong{color:var(--text-main);font-weight:700}
  .hosp-card{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);padding:18px;margin-bottom:12px;display:flex;gap:16px;align-items:flex-start;transition:var(--transition);cursor:pointer}
  .hosp-card:hover{box-shadow:var(--shadow-md);transform:translateY(-2px)}
  /* 카드 활성화 (마커 클릭 시 해당 카드 강조) */
  .hosp-card.active{border-color:var(--primary);box-shadow:0 0 0 2px rgba(2,132,199,.2)}
  .hosp-thumb{width:88px;height:88px;border-radius:var(--radius-sm);object-fit:cover;flex-shrink:0}
  .hosp-body{flex:1;min-width:0}
  .hosp-tags{display:flex;gap:6px;flex-wrap:wrap;margin-bottom:6px}
  .hosp-tag{font-size:11px;font-weight:700;padding:2px 8px;border-radius:20px}
  .hosp-tag.type{background:var(--primary-light);color:var(--primary-dark)}
  .hosp-tag.open{background:#DCFCE7;color:#16A34A}
  .hosp-tag.close{background:#FEE2E2;color:#DC2626}
  .hosp-tag.prep{background:#FEF3C7;color:#D97706}
  .hosp-card.preparing{opacity:.7}
  .hosp-card.preparing .btn-reserve{display:none}
  .hosp-name{font-size:16px;font-weight:800;color:var(--text-main);margin-bottom:4px}
  .hosp-meta{font-size:13px;color:var(--text-muted);display:flex;flex-direction:column;gap:3px}
  .hosp-meta-row{display:flex;align-items:center;gap:5px}
  .hosp-meta-row svg{width:13px;height:13px;stroke:var(--text-muted);fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;flex-shrink:0}
  .hosp-right{display:flex;flex-direction:column;align-items:flex-end;gap:8px;flex-shrink:0}
  .hosp-rating{display:flex;align-items:center;gap:4px;font-size:14px;font-weight:700;color:var(--text-main)}
  .hosp-rating svg{width:14px;height:14px;fill:var(--yellow)}
  .hosp-dist{font-size:12px;color:var(--text-muted)}
  .btn-reserve{padding:8px 16px;border:none;border-radius:var(--radius-sm);background:var(--primary);color:#fff;font-size:13px;font-weight:700;cursor:pointer;white-space:nowrap}
</style>

<div class="hosp-hero">
  <div class="hosp-hero-inner">
    <h1>반려동물 관리사 1급 자격 상담사의 24시 상담</h1>
    <p>펫린이는 반려동물 관리자 1급 자격의 상담사들이 24시간 대기중이에요.</p>
  </div>
</div>

<%-- 2026-08-07 박유정 — 병원 목록 광고 배너 (POSITION_CD=HOSPITAL, store/list.jsp 동일) --%>
<%@ include file="/WEB-INF/views/common/ad-banner.jsp" %>

<%-- 검색 폼 (hidden) --%>
<form id="searchForm" method="get" action="${contextPath}/hospital">
  <input type="hidden" name="keyword"    id="hKeyword"    value="${search.keyword}" />
  <input type="hidden" name="tagFilter"  id="hTagFilter"  value="${search.tagFilter}" />
  <input type="hidden" name="target"     id="hTarget"     value="${search.target}" />
  <input type="hidden" name="sort"       id="hSort"       value="${search.sort}" />
</form>

<div class="hosp-wrap">
  <aside>
    <div class="hosp-filter-card">
      <div class="hosp-filter-title">지역 검색</div>
      <input type="text" class="hosp-filter-input" id="keywordInput"
             placeholder="지역명, 병원명 검색..." value="${search.keyword}"
             onkeydown="if(event.key==='Enter') searchByKeyword()">
    </div>
    <div class="hosp-filter-card">
      <div class="hosp-filter-title">진료과목</div>
      <c:set var="deptVal" value="${empty search.tagFilter ? 'ALL' : search.tagFilter}" />
      <div class="hosp-filter-chips" data-target="hTagFilter">
        <span class="chip ${deptVal == 'ALL' ? 'on' : ''}" onclick="selChipSearch(this, 'ALL')">전체</span>
        <span class="chip ${deptVal == '24H' ? 'on' : ''}" onclick="selChipSearch(this, '24H')">24시간 진료</span>
        <span class="chip ${deptVal == 'HOSPITEL' ? 'on' : ''}" onclick="selChipSearch(this, 'HOSPITEL')">호스피텔 가능</span>
        <span class="chip ${deptVal == 'INPATIENT' ? 'on' : ''}" onclick="selChipSearch(this, 'INPATIENT')">입원진료 가능</span>
        <span class="chip ${deptVal == 'EMERGENCY' ? 'on' : ''}" onclick="selChipSearch(this, 'EMERGENCY')">응급진료 가능</span>
        <span class="chip ${deptVal == 'PARKING' ? 'on' : ''}" onclick="selChipSearch(this, 'PARKING')">주차장 가능</span>
      </div>
    </div>
    <div class="hosp-filter-card">
      <div class="hosp-filter-title">진료 대상</div>
      <c:set var="targetVal" value="${empty search.target ? 'ALL' : search.target}" />
      <div class="hosp-filter-chips" data-target="hTarget">
        <span class="chip ${targetVal == 'ALL' ? 'on' : ''}" onclick="selChipSearch(this, 'ALL')">전체</span>
        <span class="chip ${targetVal == 'DOG' ? 'on' : ''}" onclick="selChipSearch(this, 'DOG')">강아지</span>
        <span class="chip ${targetVal == 'CAT' ? 'on' : ''}" onclick="selChipSearch(this, 'CAT')">고양이</span>
        <span class="chip ${targetVal == 'EXOTIC' ? 'on' : ''}" onclick="selChipSearch(this, 'EXOTIC')">특수동물</span>
      </div>
    </div>
  </aside>

  <div>
    <%-- 검색바 --%>
    <%-- <div class="hosp-map-search">
      <input type="text" id="mapSearchInput" placeholder="장소명, 지역명 검색...">
      <button onclick="searchPlace()">검색</button>
    </div> --%>

    <div class="hosp-map-area" id="kakao-map"></div>
    <c:set var="mapLevel" value="3"/>
    <c:set var="mapAddMarker" value="${true}"/>
    <%@ include file="/WEB-INF/views/common/kakaomap.jsp" %>
    
    <div class="hosp-list-head">
      <span>검색 결과 <strong>${hospitalList.size()}개</strong> 병원</span>
      <c:set var="sortVal" value="${empty search.sort ? '' : search.sort}" />
      <div style="display:flex;gap:8px">
        <span class="chip ${empty sortVal ? 'on' : ''}" style="font-size:12px" onclick="selSortSearch('')">기본순</span>
        <span class="chip ${sortVal == 'rating' ? 'on' : ''}" style="font-size:12px" onclick="selSortSearch('rating')">별점순</span>
        <span class="chip ${sortVal == 'review' ? 'on' : ''}" style="font-size:12px" onclick="selSortSearch('review')">리뷰순</span>
      </div>
    </div>

    <c:choose>
      <c:when test="${not empty hospitalList}">
        <c:forEach var="h" items="${hospitalList}">
          <%-- id 추가 + onclick을 selectHospital으로 --%>
          <div class="hosp-card ${h.lat == null ? 'preparing' : ''}" id="card-${h.hospitalId}" onclick="selectHospital(${h.hospitalId})">
            <c:choose>
              <c:when test="${h.lat != null && h.thumbPath != null}">
                <img class="hosp-thumb" src="${contextPath}/upload/${h.thumbPath}" alt="${h.name}">
              </c:when>
              <c:otherwise>
                <div class="hosp-thumb-placeholder">
                  <svg viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <rect x="14" y="22" width="36" height="28" rx="3" stroke="#CBD5E1" stroke-width="2"/>
                    <rect x="26" y="36" width="12" height="14" rx="1.5" stroke="#CBD5E1" stroke-width="2"/>
                    <path d="M32 8L14 22h36L32 8z" stroke="#CBD5E1" stroke-width="2" stroke-linejoin="round"/>
                    <line x1="32" y1="27" x2="32" y2="33" stroke="#CBD5E1" stroke-width="2" stroke-linecap="round"/>
                    <line x1="29" y1="30" x2="35" y2="30" stroke="#CBD5E1" stroke-width="2" stroke-linecap="round"/>
                  </svg>
                  <span>이미지 <br>등록중입니다.</span>
                </div>
              </c:otherwise>
            </c:choose>
            <div class="hosp-body">
              <div class="hosp-tags">
                <span class="hosp-tag type">동물병원</span>
                <c:if test="${h.lat == null}">
                  <span class="hosp-tag prep">이용준비중</span>
                </c:if>
              </div>
              <div class="hosp-name">${h.name}</div>
              <div class="hosp-meta">
                <div class="hosp-meta-row">
                  <svg viewBox="0 0 24 24"><path d="M21 10c0 7-9 13-9 13S3 17 3 10a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/></svg>
                  ${h.addr}
                </div>
                <%-- <div class="hosp-meta-row">
                  <svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                  ${h.tagList}
                </div> --%>
                <div class="hosp-meta-row">
                  <svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                  <c:choose>
                    <c:when test="${not empty h.tagList}">
                      <c:forEach var="tag" items="${fn:split(h.tagList, ',')}" varStatus="st">
                        <c:set var="t" value="${fn:trim(tag)}" />
                        <c:if test="${t == '24H'}"><span class="hosp-tag">24시간 진료</span></c:if>
                        <c:if test="${t == 'EXOTIC'}"><span class="hosp-tag">특수동물 진료</span></c:if>
                        <c:if test="${t == 'HOSPITEL'}"><span class="hosp-tag">호스피텔 가능</span></c:if>
                        <c:if test="${t == 'INPATIENT'}"><span class="hosp-tag">입원 진료</span></c:if>
                        <c:if test="${t == 'EMERGENCY'}"><span class="hosp-tag">응급 진료</span></c:if>
                        <c:if test="${t == 'PARKING'}"><span class="hosp-tag">주차 가능</span></c:if>
                      </c:forEach>
                    </c:when>
                    <c:otherwise>-</c:otherwise>
                  </c:choose>
                </div>
              </div>
            </div>
            <div class="hosp-right">
              <div class="hosp-rating">
                <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                <c:choose>
                  <c:when test="${h.avgRating != null}">${h.avgRating} (${h.reviewCnt})</c:when>
                  <c:otherwise>-</c:otherwise>
                </c:choose>
              </div>
              <%-- 2026/07/08 장우철 — 목록 버튼 예약하기 → 상세보기, 경로 /hospital/detail --%>
              <%--
              <button class="btn-reserve"
                      onclick="event.stopPropagation();location.href='${contextPath}/hospital/reserve?id=${h.hospitalId}'">
                예약하기
              </button>
              --%>
              <%-- HYJ 26.07.09 사업자가 아직 사업정보 등록 안했을 경우 이용중비중 --%>
              <%-- <button class="btn-reserve"
                      onclick="event.stopPropagation();location.href='${contextPath}/hospital/detail?id=${h.hospitalId}'">
                상세보기
              </button> --%>
              <c:choose>
                <c:when test="${h.lat != null}">
                  <button class="btn-reserve"
                          onclick="event.stopPropagation();location.href='${contextPath}/hospital/detail?id=${h.hospitalId}'">
                    상세보기
                  </button>
                </c:when>
                <c:otherwise>
                  <button class="btn-reserve">이용준비중</button>
                </c:otherwise>
              </c:choose>              
            </div>
          </div>
        </c:forEach>
      </c:when>
      <c:otherwise>
        <p style="font-size:15px;font-weight:600;color:var(--text-main);margin:0">등록된 병원이 없습니다.</p>
      </c:otherwise>
    </c:choose>
  </div>
</div>

<script>
  /* ── 1) JSTL → JS 배열 변환 ── */
  var HOSPITALS = [
    <c:forEach items="${hospitalList}" var="h" varStatus="st">
      {
        id: ${h.hospitalId},
        name: "${h.name}",
        lat: ${h.lat != null ? h.lat : 'null'},
        lng: ${h.lng != null ? h.lng : 'null'}
      }
      <c:if test="${!st.last}">,</c:if>
    </c:forEach>
  ];

  /* ── 2) 전역 변수 ── */
  var map;
  var markers = [];
  var infowindows = [];

  /* ── 3) 페이지 로딩 → 마커 생성 ── */
  document.addEventListener('DOMContentLoaded', function() {
      map = window.kakaoMap;
      if (!map) return;

      var bounds = new kakao.maps.LatLngBounds();
      var hasMarker = false;

      for (var i = 0; i < HOSPITALS.length; i++) {
          var h = HOSPITALS[i];
          if (h.lat === null || h.lng === null) {
              continue;
          }

          var position = new kakao.maps.LatLng(h.lat, h.lng);
          var marker = new kakao.maps.Marker({ position: position, map: map });

          var infowindow = new kakao.maps.InfoWindow({
              content: '<div style="padding:8px 12px;font-size:13px;font-weight:800;'
                     + 'color:#1A1A2E;white-space:nowrap;">'
                     + '<a href="${contextPath}/hospital/detail?id=' + h.id + '" '
                     + 'style="color:inherit;text-decoration:none">' + h.name + '</a></div>'
          });

          addMarkerEvents(marker, infowindow, h.id);

          markers.push(marker);
          infowindows.push(infowindow);
          bounds.extend(position);
          hasMarker = true;
      }

      if (hasMarker) {
          map.setBounds(bounds);
      }
  });


  /* ── 4) 마커 이벤트 등록 (클로저 해결용 별도 함수) ── */
  function addMarkerEvents(marker, infowindow, hospitalId) {
      kakao.maps.event.addListener(marker, 'mouseover', function() {
          infowindow.open(map, marker);
      });
      kakao.maps.event.addListener(marker, 'mouseout', function() {
          infowindow.close();
      });
      kakao.maps.event.addListener(marker, 'click', function() {
          highlightCard(hospitalId);
      });
  }

  /* ── 5) 카드 클릭 → 지도 이동 + 말풍선 + 강조 ── */
  function selectHospital(hospitalId) {
      var hospital = null;
      var hospitalIdx = -1;
      var markerIdx = 0;
  
      for (var i = 0; i < HOSPITALS.length; i++) {
          var h = HOSPITALS[i];
          if (h.lat === null || h.lng === null) {
              continue;
          }
          if (h.id === hospitalId) {
              hospital = h;
              hospitalIdx = markerIdx;
              break;
          }
          markerIdx++;
      }
  
      if (hospital !== null && hospitalIdx >= 0) {
          map.setCenter(new kakao.maps.LatLng(hospital.lat, hospital.lng));
          map.setLevel(4);
  
          for (var i = 0; i < infowindows.length; i++) {
              infowindows[i].close();
          }
          infowindows[hospitalIdx].open(map, markers[hospitalIdx]);
      }
  
      highlightCard(hospitalId);
  }
  
  /* ── 6) 카드 강조 ── */
  function highlightCard(hospitalId) {
      var allCards = document.querySelectorAll('.hosp-card');
      for (var i = 0; i < allCards.length; i++) {
          allCards[i].classList.remove('active');
      }
      var card = document.getElementById('card-' + hospitalId);
      if (card) {
          card.classList.add('active');
          card.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
      }
  }
  
  /* ── 7) 검색 ── */
  function searchPlace() {
      var keyword = document.getElementById('mapSearchInput').value.trim();
      if (!keyword) return;
  
      var kakaoPs = window.kakaoPs;
      kakaoPs.keywordSearch(keyword, function(results, status) {
          if (status === kakao.maps.services.Status.OK) {
              var first = results[0];
              map.setCenter(new kakao.maps.LatLng(first.y, first.x));
              map.setLevel(5);
          } else {
              alert('검색 결과가 없습니다.');
          }
      });
  }
  
  /* ── 8) 검색 폼 제출 ── */
  function submitSearch() {
      document.getElementById('searchForm').submit();
  }

  /* ── 9) 칩 클릭 (진료과목 / 진료 대상) ── */
  function selChipSearch(el, value) {
      var parent   = el.closest('.hosp-filter-chips');
      var targetId = parent.getAttribute('data-target');

      var chips = parent.querySelectorAll('.chip');
      for (var i = 0; i < chips.length; i++) { chips[i].classList.remove('on'); }
      el.classList.add('on');

      document.getElementById(targetId).value = value;
      submitSearch();
  }

  /* ── 10) 정렬 클릭 ── */
  function selSortSearch(sortValue) {
      document.getElementById('hSort').value = sortValue;
      submitSearch();
  }

  /* ── 11) 키워드 검색 (Enter 또는 버튼) ── */
  function searchByKeyword() {
      document.getElementById('hKeyword').value = document.getElementById('keywordInput').value.trim();
      submitSearch();
  }
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
