<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
  역할: 유기동물 목록 화면 (give/animal/list)

  - 박유정 / 2026-07-06
  - 파일 안에서 API 를 직접 호출했는데, Service 로 옮김

  [목록 화면 흐름] (2026-07-06 조건 후 조회 추가)
  1. 사용자가 /give/animal/list 주소로 들어옴 → API 안 부름, 안내만 표시 (searched=false)
  2. 조건 고르고 [조회] 클릭 → hidden search=true 와 함께 Controller 호출
  3. giveAnimalService.getAnimalList() (캐시 적용)
  4. 받은 결과(animals, totalCount 등)를 이 JSP 에 표시
--%>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId"      value="give" />
<c:set var="giveTab"     value="animal" />

<%@ include file="/WEB-INF/views/give/index.jsp" %>

<style>
  .give-content{max-width:var(--inner-width);margin:32px auto 80px;padding:0 20px}
  .api-notice{display:flex;align-items:center;gap:12px;background:#EEF2FF;border:1px solid #C7D2FE;border-radius:var(--radius-sm);padding:12px 16px;margin-bottom:20px;font-size:13px;color:#3730A3}
  .api-notice svg{width:16px;height:16px;stroke:#4F46E5;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;flex-shrink:0}
  .api-notice a{color:#4F46E5;font-weight:700}
  .api-error-box{background:#FEE2E2;border:1px solid #FCA5A5;border-radius:var(--radius-sm);padding:16px;margin-bottom:20px;font-size:14px;color:#DC2626}

  .search-card{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);padding:20px;margin-bottom:20px}
  .search-title{font-size:14px;font-weight:700;color:var(--text-main);margin:0 0 14px;display:flex;align-items:center;gap:7px}
  .search-title svg{width:15px;height:15px;stroke:var(--primary);fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}
  .search-form{display:grid;grid-template-columns:repeat(4,1fr) auto;gap:10px;align-items:flex-end}
  .sf-group{display:flex;flex-direction:column;gap:5px}
  .sf-group label{font-size:12px;font-weight:600;color:var(--text-muted)}
  .sf-group select{border:1px solid var(--border);border-radius:var(--radius-sm);padding:9px 12px;font-size:14px;color:var(--text-main);outline:none;width:100%;box-sizing:border-box}
  .sf-group select:focus{border-color:var(--primary)}
  .btn-search{padding:9px 22px;border:none;border-radius:var(--radius-sm);background:var(--primary);color:#fff;font-size:14px;font-weight:700;cursor:pointer;display:flex;align-items:center;gap:6px;white-space:nowrap;transition:var(--transition)}
  .btn-search:hover{background:var(--primary-dark)}
  .btn-search svg{width:15px;height:15px;stroke:#fff;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}

  .result-bar{display:flex;justify-content:space-between;align-items:center;margin-bottom:16px;font-size:14px;color:var(--text-sub)}
  .result-bar strong{color:var(--text-main);font-weight:700}

  .animal-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:18px;margin-bottom:32px}
  .animal-card{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);overflow:hidden;transition:var(--transition);cursor:pointer}
  .animal-card:hover{box-shadow:var(--shadow-md);transform:translateY(-3px)}
  .animal-thumb-wrap{position:relative}
  .animal-thumb{width:100%;aspect-ratio:4/3;object-fit:cover;display:block;background:#f5f5f5}
  .dday-badge{position:absolute;top:8px;left:8px;font-size:11px;font-weight:700;padding:3px 8px;border-radius:20px}
  .dday-urgent{background:#FEE2E2;color:#DC2626}
  .dday-normal{background:#DCFCE7;color:#16A34A}
  .dday-end{background:#E5E7EB;color:#6B7280}
  .species-badge{position:absolute;top:8px;right:8px;font-size:11px;font-weight:700;padding:3px 8px;border-radius:20px;background:rgba(0,0,0,.55);color:#fff}
  .animal-body{padding:13px}
  .notice-no{font-size:10px;color:var(--text-muted);margin-bottom:4px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
  .animal-name{font-size:14px;font-weight:700;color:var(--text-main);margin-bottom:4px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
  .animal-info{font-size:12px;color:var(--text-muted);line-height:1.7}
  .animal-shelter{font-size:12px;color:var(--text-muted);margin-top:6px;display:flex;align-items:center;gap:4px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
  .animal-shelter svg{width:12px;height:12px;stroke:currentColor;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;flex-shrink:0}
  .btn-detail{display:block;width:100%;padding:9px;border:none;background:var(--primary-light);color:var(--primary-dark);font-size:13px;font-weight:700;cursor:pointer;transition:var(--transition)}
  .btn-detail:hover{background:var(--primary);color:#fff}

  .empty-box{display:flex;flex-direction:column;align-items:center;gap:14px;padding:80px 0;text-align:center}
  .empty-icon{width:64px;height:64px;border-radius:50%;background:var(--primary-light);display:flex;align-items:center;justify-content:center}
  .empty-icon svg{width:30px;height:30px;stroke:var(--primary);fill:none;stroke-width:1.6;stroke-linecap:round;stroke-linejoin:round}

  .pagination{display:flex;justify-content:center;gap:5px;flex-wrap:wrap}
  .page-btn{width:36px;height:36px;border:1px solid var(--border);border-radius:var(--radius-sm);background:#fff;font-size:13px;color:var(--text-sub);cursor:pointer;display:flex;align-items:center;justify-content:center;transition:var(--transition);text-decoration:none}
  .page-btn:hover{border-color:var(--primary);color:var(--primary)}
  .page-btn.active{background:var(--primary);border-color:var(--primary);color:#fff;font-weight:700}
  .page-btn svg{width:14px;height:14px;stroke:currentColor;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}

  /* 검색창 바로 아래 결과 영역만 로딩 */
  .results-panel{position:relative;min-height:320px}
  .search-loading{
    display:none;position:absolute;top:0;left:0;right:0;z-index:10;
    min-height:320px;
    background:rgba(255,255,255,.92);
    border:1px solid var(--border);border-radius:var(--radius-md);
    flex-direction:column;align-items:center;justify-content:flex-start;
    gap:20px;text-align:center;padding:32px 20px 36px;
  }
  .search-loading.is-show{display:flex}
  .loading-dog{width:min(360px,85vw);max-width:100%;height:auto;border-radius:var(--radius-sm)}
  .search-loading p{margin:0;font-size:20px;font-weight:800;color:var(--text-main);line-height:1.55}
  .search-loading .loading-sub{display:block;margin-top:10px;font-size:14px;font-weight:600;color:var(--text-sub)}
</style>

<div class="give-content">

  <%-- API 안내 --%>
  <div class="api-notice">
    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
    <span>
      <strong>동물보호관리시스템 (APMS)</strong> 공공API 실시간 데이터입니다.
      실제 입양은 해당 보호소에 직접 문의해 주세요.
      (<a href="https://www.animal.go.kr" target="_blank">animal.go.kr</a>)
    </span>
  </div>

  <%-- API 오류 시 안내 --%>
  <c:if test="${apiError}">
    <div class="api-error-box">
      <strong>API 호출 중 오류가 발생했습니다.</strong>
      잠시 후 다시 시도해 주세요. (${errorMsg})
    </div>
  </c:if>

  <%-- 검색 폼 --%>
  <div class="search-card">
    <div class="search-title">
      <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
      유기동물 검색
    </div>
    <form class="search-form" method="get" action="${contextPath}/give/animal/list">
      <div class="sf-group">
        <label>시·도</label>
        <select name="sido">
          <option value="">전체</option>
          <option value="6110000"  ${sido eq '6110000'  ? 'selected' : ''}>서울</option>
          <option value="6260000"  ${sido eq '6260000'  ? 'selected' : ''}>부산</option>
          <option value="6270000"  ${sido eq '6270000'  ? 'selected' : ''}>대구</option>
          <option value="6280000"  ${sido eq '6280000'  ? 'selected' : ''}>인천</option>
          <option value="6290000"  ${sido eq '6290000'  ? 'selected' : ''}>광주</option>
          <option value="6300000"  ${sido eq '6300000'  ? 'selected' : ''}>대전</option>
          <option value="6310000"  ${sido eq '6310000'  ? 'selected' : ''}>울산</option>
          <option value="6410000"  ${sido eq '6410000'      ? 'selected' : ''}>경기</option>
          <option value="6510000"  ${sido eq '6510000' ? 'selected' : ''}>강원</option>
          <option value="6430000"  ${sido eq '6430000'    ? 'selected' : ''}>충북</option>
          <option value="6440000"  ${sido eq '6440000'    ? 'selected' : ''}>충남</option>
          <option value="6450000"  ${sido eq '6450000' ? 'selected' : ''}>전북</option>
          <option value="6460000"  ${sido eq '6460000'    ? 'selected' : ''}>전남</option>
          <option value="6470000"  ${sido eq '6470000'    ? 'selected' : ''}>경북</option>
          <option value="6480000"  ${sido eq '6480000'    ? 'selected' : ''}>경남</option>
          <option value="6500000"  ${sido eq '6500000' ? 'selected' : ''}>제주</option>
        </select>
      </div>
      <div class="sf-group">
        <label>동물 종류</label>
        <select name="upkind">
          <option value="">전체</option>
          <option value="417000" ${upkind eq '417000' ? 'selected' : ''}>개</option>
          <option value="422400" ${upkind eq '422400' ? 'selected' : ''}>고양이</option>
          <option value="429900" ${upkind eq '429900' ? 'selected' : ''}>기타</option>
        </select>
      </div>
      <div class="sf-group">
        <label>보호 상태</label>
        <select name="state">
          <option value="">전체</option>
          <option value="notice"   ${state eq 'notice'   ? 'selected' : ''}>공고중</option>
          <option value="protect"  ${state eq 'protect'  ? 'selected' : ''}>보호중</option>
          <option value="return"   ${state eq 'return'   ? 'selected' : ''}>반환</option>
          <option value="adoption" ${state eq 'adoption' ? 'selected' : ''}>입양</option>
        </select>
      </div>
      <input type="hidden" name="pageNo" value="1">
      <%-- [조건 고른 뒤에만 조회] 조회 버튼 눌렀을 때만 search=true 로 Controller 에 전달 --%>
      <input type="hidden" name="search" value="true">
      <button type="submit" class="btn-search">
        <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
        조회
      </button>
    </form>
  </div>

  <%-- 검색창 바로 아래: 결과 + 로딩 --%>
  <div class="results-panel">

    <div id="searchLoading" class="search-loading" aria-live="polite">
      <img class="loading-dog" src="${contextPath}/resources/images/loading-dog.gif"
           alt="" aria-hidden="true">
      <p>
        아이들의 간절한 기다림에 응답하는 중입니다.<br>
        <small class="loading-sub">잠시만 기다려주세요!</small>
      </p>
    </div>

  <%-- 아직 [조회] 안 눌렀을 때 안내 (API 호출 전) --%>
  <c:if test="${!searched}">
    <div class="empty-box">
      <div class="empty-icon">
        <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
      </div>
      <p style="font-size:15px;font-weight:600;color:var(--text-main);margin:0">조건을 선택한 뒤 [조회]를 눌러 주세요.</p>
      <small style="font-size:13px;color:var(--text-muted)">지역·종류를 고른 후 조회하면 결과가 빠르게 표시됩니다.</small>
    </div>
  </c:if>

  <%-- [조회] 눌렀을 때만 결과 수·카드·페이징 표시 --%>
  <c:if test="${searched}">

  <%-- 결과 수 --%>
  <div class="result-bar">
    <span>총 <strong>${totalCount}</strong>마리 보호 중 (최근 30일, 페이지 ${pageNo}/${totalPages})</span>
    <span style="font-size:12px;color:var(--text-muted)">동물보호관리시스템 실시간 데이터</span>
  </div>

  <%-- 동물 카드 목록 --%>
  <c:choose>
    <c:when test="${empty animals}">
      <div class="empty-box">
        <div class="empty-icon">
          <svg viewBox="0 0 24 24"><circle cx="4.5" cy="9.5" r="2"/><circle cx="9" cy="5.5" r="2"/><circle cx="15" cy="5.5" r="2"/><circle cx="19.5" cy="9.5" r="2"/><path d="M12 13c-3.87 0-7 1.79-7 4v1h14v-1c0-2.21-3.13-4-7-4z"/></svg>
        </div>
        <p style="font-size:15px;font-weight:600;color:var(--text-main);margin:0">검색 결과가 없습니다.</p>
        <small style="font-size:13px;color:var(--text-muted)">다른 조건으로 검색해보세요.</small>
      </div>
    </c:when>
    <c:otherwise>
      <div class="animal-grid">
        <c:forEach var="a" items="${animals}">
          <div class="animal-card"
               onclick="location.href='${contextPath}/give/animal/detail?desertionNo=${a.desertionNo}'">
            <div class="animal-thumb-wrap">
              <%-- 실제 API 이미지 --%>
              <img class="animal-thumb"
                   src="${empty a.popfile1 ? a.popfile2 : a.popfile1}"
                   alt="${a.breedName}"
                   onerror="this.src='https://placehold.co/300x225/EAF7F2/2BAB82?text=${a.species}'">

              <%-- D-day 뱃지 --%>
              <c:choose>
                <c:when test="${a.dday <= 3}">
                  <span class="dday-badge dday-urgent">D-${a.dday}</span>
                </c:when>
                <c:when test="${a.dday > 3}">
                  <span class="dday-badge dday-normal">D-${a.dday}</span>
                </c:when>
                <c:otherwise>
                  <span class="dday-badge dday-end">종료</span>
                </c:otherwise>
              </c:choose>

              <span class="species-badge">${a.species}</span>
            </div>

            <div class="animal-body">
              <div class="notice-no">공고번호: ${a.noticeNo}</div>
              <div class="animal-name">${a.breedName} · ${a.age} · ${a.sexLabel}</div>
              <div class="animal-info">
                체중 ${a.weight} · 색상: ${a.colorCd}<br>
                중성화 ${a.neuterLabel} · ${a.processState}
              </div>
              <div class="animal-shelter">
                <svg viewBox="0 0 24 24"><path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z"/></svg>
                ${a.careNm}
              </div>
            </div>

            <button class="btn-detail"
                    onclick="event.stopPropagation();
                             location.href='${contextPath}/give/animal/detail?desertionNo=${a.desertionNo}'">
              상세보기 / 보호소 문의
            </button>
          </div>
        </c:forEach>
      </div>

      <%-- 페이지네이션 (search=true 유지해야 다음 페이지도 API 조회됨) --%>
      <div class="pagination">
        <c:if test="${pageNo > 1}">
          <a class="page-btn"
             href="${contextPath}/give/animal/list?sido=${sido}&upkind=${upkind}&state=${state}&search=true&pageNo=${pageNo-1}">
            <svg viewBox="0 0 24 24"><polyline points="15 18 9 12 15 6"/></svg>
          </a>
        </c:if>

        <%-- 페이지 버튼 5개씩 묶음 (1~5, 6~10, 11~15 ...) / 박유정 2026-07-06 --%>
        <c:set var="startPage" value="${pageNo - ((pageNo - 1) % 5)}" />
        <c:set var="endPage" value="${startPage + 4 > totalPages ? totalPages : startPage + 4}" />
        <c:forEach begin="${startPage}" end="${endPage}" var="p">
          <a class="page-btn ${p == pageNo ? 'active' : ''}"
             href="${contextPath}/give/animal/list?sido=${sido}&upkind=${upkind}&state=${state}&search=true&pageNo=${p}">
            ${p}
          </a>
        </c:forEach>

        <c:if test="${pageNo < totalPages}">
          <a class="page-btn"
             href="${contextPath}/give/animal/list?sido=${sido}&upkind=${upkind}&state=${state}&search=true&pageNo=${pageNo+1}">
            <svg viewBox="0 0 24 24"><polyline points="9 18 15 12 9 6"/></svg>
          </a>
        </c:if>
      </div>
    </c:otherwise>
  </c:choose>

  </c:if>

  </div><%-- /results-panel --%>
</div>

<script>
  function showSearchLoading() {
    var el = document.getElementById('searchLoading');
    if (el) el.classList.add('is-show');
  }
  document.querySelector('.search-form')?.addEventListener('submit', showSearchLoading);
  document.querySelectorAll('.pagination .page-btn').forEach(function(a) {
    a.addEventListener('click', showSearchLoading);
  });
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
