<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- 지윤 26.07.06 추가: 가격에 콤마(#,###) 찍으려고 fmt 태그 사용 필요해서 taglib 추가 --%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%-- 지윤 26.07.15 추가: 이미지 URL이 http로 시작하는지 검사용 (외부 URL vs 로컬 업로드 구분) --%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="store" />
<%@ include file="/WEB-INF/views/common/header.jsp" %>
<style>
.store-wrap { max-width:var(--inner-width); margin:32px auto 80px; padding:0 20px; display:flex; gap:28px; align-items:flex-start; }
/* 사이드바 */
.store-sidebar { width:220px; flex-shrink:0; }
.store-sidebar-card { background:var(--bg-card); border:1px solid var(--border); border-radius:var(--radius-md); padding:20px; margin-bottom:16px; }
.store-sidebar-title { font-size:14px; font-weight:800; color:var(--text-main); margin:0 0 14px; }
.store-cat-list { list-style:none; padding:0; margin:0; display:flex; flex-direction:column; gap:2px; }
.store-cat-list li a { display:flex; justify-content:space-between; padding:8px 10px; border-radius:var(--radius-sm); font-size:13px; color:var(--text-sub); text-decoration:none; transition:var(--transition); }
.store-cat-list li a:hover { background:var(--primary-light); color:var(--primary-dark); }
.store-cat-list li a.active { background:var(--primary-light); color:var(--primary-dark); font-weight:700; }
.store-cat-list .cat-count { font-size:12px; color:var(--text-muted); }
.store-cat-list li label { padding:8px 10px; border-radius:var(--radius-sm); transition:var(--transition); }
.store-cat-list li label:hover { background:var(--primary-light); }
/* 지윤 26.07.30 추가: 브랜드 li가 모달(div)로 옮겨지면 ul의 list-style:none 상속이 끊겨서 점(•)이 다시 생김 -> li 자체에 직접 지정 */
.brand-item { list-style:none; }
.price-range { display:flex; flex-direction:column; gap:8px; }
.price-range input[type=range] { width:100%; accent-color:var(--primary); }
.price-range-vals { display:flex; justify-content:space-between; font-size:12px; color:var(--text-muted); }
/* 상품 영역 */
.store-content { flex:1; min-width:0; }
.store-toolbar { display:flex; justify-content:space-between; align-items:center; margin-bottom:18px; }
.store-result-count { font-size:14px; color:var(--text-sub); }
.store-result-count strong { color:var(--text-main); font-weight:700; }
.store-sort { display:flex; gap:8px; }
.sort-btn { padding:6px 14px; border:1px solid var(--border); border-radius:50px; font-size:13px; color:var(--text-sub); background:#fff; cursor:pointer; transition:var(--transition); }
.sort-btn:hover,.sort-btn.on { border-color:var(--primary); color:var(--primary); background:var(--primary-light); font-weight:600; }
/* 상품 그리드 */
.product-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:20px; margin-bottom:32px; }
.product-card { background:var(--bg-card); border:1px solid var(--border); border-radius:var(--radius-md); overflow:hidden; transition:var(--transition); cursor:pointer; }
.product-card:hover { box-shadow:var(--shadow-md); transform:translateY(-3px); }
.product-thumb-wrap { position:relative; }
.product-thumb { width:100%; aspect-ratio:1/1; object-fit:cover; display:block; }
.product-badge { position:absolute; top:10px; left:10px; background:var(--accent); color:#fff; font-size:11px; font-weight:700; padding:3px 8px; border-radius:20px; }
.product-wish { position:absolute; top:10px; right:10px; width:32px; height:32px; border-radius:50%; background:rgba(255,255,255,.9); border:none; cursor:pointer; display:flex; align-items:center; justify-content:center; }
.product-wish svg { width:16px; height:16px; stroke:var(--accent); fill:none; stroke-width:1.8; }
.product-body { padding:14px; }
.product-brand { font-size:11px; color:var(--text-muted); margin-bottom:4px; }
.product-name { font-size:14px; font-weight:600; color:var(--text-main); margin-bottom:8px; line-height:1.4; display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden; }
.product-rating { display:flex; align-items:center; gap:4px; margin-bottom:8px; }
.product-rating svg { width:13px; height:13px; fill:var(--yellow); stroke:none; }
.product-rating span { font-size:12px; color:var(--text-muted); }
.product-price { display:flex; align-items:baseline; gap:6px; }
.price-sale { font-size:16px; font-weight:800; color:var(--text-main); }
.price-rate { font-size:14px; font-weight:700; color:var(--accent); }
.price-origin { font-size:12px; color:var(--text-muted); text-decoration:line-through; }
.product-footer { padding:0 14px 14px; }
.btn-cart { width:100%; padding:9px; border:none; border-radius:var(--radius-sm); background:var(--primary); color:#fff; font-size:13px; font-weight:700; cursor:pointer; transition:var(--transition); }
.btn-cart:hover { background:var(--primary-dark); }
/* 페이지네이션 */
.pagination { display:flex; justify-content:center; gap:5px; }
.page-btn { width:36px; height:36px; border-radius:var(--radius-sm); border:1px solid var(--border); background:#fff; font-size:13px; color:var(--text-sub); cursor:pointer; display:flex; align-items:center; justify-content:center; transition:var(--transition); }
.page-btn:hover { border-color:var(--primary); color:var(--primary); }
.page-btn.active { background:var(--primary); border-color:var(--primary); color:#fff; font-weight:700; }
.page-btn svg { width:14px; height:14px; stroke:currentColor; fill:none; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; }
/* 지윤 26.07.06 검색창 스타일 추가 */
.store-search-box { display:flex; gap:8px; margin-bottom:16px; }
.store-search-box input[type=text] { flex:1; padding:9px 14px; border:1px solid var(--border); border-radius:var(--radius-sm); font-size:14px; }
.store-search-box button { padding:9px 20px; border:none; border-radius:var(--radius-sm); background:var(--primary); color:#fff; font-size:13px; font-weight:700; cursor:pointer; }
.species-tabs { display:flex; gap:6px; margin-bottom:14px; }
.species-tab { flex:1; text-align:center; padding:8px 0; border:1px solid var(--border); border-radius:var(--radius-sm); font-size:13px; color:var(--text-sub); text-decoration:none; }
.species-tab.active { background:var(--primary); border-color:var(--primary); color:#fff; font-weight:700; }
.age-filter { display:flex; gap:6px; margin-bottom:14px; }
.age-chip { padding:6px 14px; border:1px solid var(--border); border-radius:20px; font-size:12px; color:var(--text-sub); text-decoration:none; }
.age-chip.active { border-color:var(--primary); background:var(--primary-light); color:var(--primary-dark); font-weight:700; }
/* 2026-08-06 박유정 — 쇼핑 목록 히어로 (stay-hero 패턴) */
.store-hero {
    background: linear-gradient(135deg, #1A1A2E 0%, #2D5E4F 60%, #2BAB82 100%);
    padding: 48px 0;
    color: #fff;
    text-align: center;
}
.store-hero-inner {
    max-width: var(--inner-width);
    margin: 0 auto;
    padding: 0 20px;
}
.store-hero h1 { font-size: 32px; font-weight: 800; margin: 0 0 10px; }
.store-hero p  { font-size: 15px; opacity: .8; margin: 0; }
</style>

<div class="store-hero"> 
  <div class="store-hero-inner">
    <h1>반려동물 쇼핑몰</h1>
    <p>사료, 간식, 용품까지 — 우리 아이에게 필요한 모든 것</p>
  </div>
</div>

<%@ include file="/WEB-INF/views/common/ad-banner.jsp" %>

<div class="store-wrap">
  <%-- 사이드바 --%>
  <aside class="store-sidebar">
    <%-- 지윤 26.07.06 카테고리 트리 적용: 강아지/고양이 탭 추가 --%>
    <div class="species-tabs">
      <c:forEach var="sp" items="${categoryTree}">
        <c:if test="${sp.depth == 2}">
          <c:url var="spUrl" value="/store">
            <c:param name="species" value="${sp.categoryId}"/>
          </c:url>
          <a href="${spUrl}" class="species-tab ${selectedSpecies == sp.categoryId ? 'active' : ''}">${sp.categoryName}</a>
        </c:if>
      </c:forEach>
    </div>
    <div class="store-sidebar-card">
      <div class="store-sidebar-title">카테고리</div>
      <ul class="store-cat-list">
        <c:url var="allCatUrl" value="/store">
          <c:param name="species" value="${selectedSpecies}"/>
        </c:url>
        <li><a href="${allCatUrl}" class="${empty selectedCategory ? 'active' : ''}">전체</a></li>
        <c:forEach var="cat" items="${categoryTree}">
          <c:if test="${cat.parentId == selectedSpecies && cat.depth == 3}">
            <c:url var="catUrl" value="/store">
              <c:param name="species" value="${selectedSpecies}"/>
              <c:param name="category" value="${cat.categoryId}"/>
            </c:url>
            <li><a href="${catUrl}" class="${selectedCategory == cat.categoryId ? 'active' : ''}">${cat.categoryName}</a></li>
          </c:if>
        </c:forEach>
      </ul>
    </div>
    <%-- 지윤 26.07.12 수정: 가격대 슬라이더 -> maxPrice 파라미터로 실제 필터링 (최소값은 0 고정, 슬라이더 놓을 때 기존 필터 유지한 채 이동) --%>
    <div class="store-sidebar-card">
      <div class="store-sidebar-title">가격대</div>
      <div class="price-range">
        <input type="range" id="priceRangeInput" min="0" max="150000" step="5000"
               value="${empty selectedMaxPrice ? 150000 : selectedMaxPrice}">
        <div class="price-range-vals"><span>0원</span><span id="priceRangeLabel">
          <c:choose>
            <c:when test="${empty selectedMaxPrice || selectedMaxPrice >= 150000}">전체</c:when>
            <c:otherwise><fmt:formatNumber value="${selectedMaxPrice}" pattern="#,###"/>원 이하</c:otherwise>
          </c:choose>
        </span></div>
      </div>
    </div>
    <%-- After: 체크박스 다중선택 + 상위 5개만 노출 + 더보기 + 전체보기 모달 --%>
    <%-- 지윤 26.07.30 수정: 단일선택 링크 -> 체크박스 다중선택. 상위 5개 노출, 나머지는 더보기/전체보기 --%>
    <div class="store-sidebar-card">
      <div class="store-sidebar-title" style="display:flex;justify-content:space-between;align-items:center;">
        브랜드
        <c:if test="${fn:length(brandList) > 5}">
          <button type="button" onclick="openBrandModal()" style="font-size:12px;color:var(--text-muted);background:none;border:none;text-decoration:underline;cursor:pointer;">전체보기 &gt;</button>
        </c:if>
      </div>

      <%-- 필터 기준 폼. 체크박스 바뀌면 이 폼 그대로 제출됨 (다른 필터값은 hidden으로 유지) --%>
      <form id="brandForm" method="get" action="${contextPath}/store">
        <input type="hidden" name="species" value="${selectedSpecies}">
        <c:if test="${not empty selectedCategory}"><input type="hidden" name="category" value="${selectedCategory}"></c:if>
        <c:if test="${not empty selectedAge}"><input type="hidden" name="age" value="${selectedAge}"></c:if>
        <c:if test="${not empty selectedKeyword}"><input type="hidden" name="keyword" value="${selectedKeyword}"></c:if>
        <c:if test="${not empty selectedMaxPrice}"><input type="hidden" name="maxPrice" value="${selectedMaxPrice}"></c:if>
        <input type="hidden" name="sort" value="${selectedSort}">

        <ul class="store-cat-list" id="brandListAll">
          <c:forEach var="b" items="${brandList}" varStatus="vs">
            <li class="brand-item${vs.index >= 5 ? ' brand-extra' : ''}" style="${vs.index >= 5 ? 'display:none;' : ''}">
              
              <%-- 지윤 26.07.30 수정: 모달 안에서 체크할 땐 즉시제출 안 되게 분기, 재고숫자 표시 제거 --%>
              <label style="display:flex;align-items:center;gap:6px;cursor:pointer;">
                <input type="checkbox" name="brand" value="${b.brandName}"
                       ${not empty selectedBrand and selectedBrand.contains(b.brandName) ? 'checked' : ''}
                       onchange="if (!this.closest('#brandModalGrid')) { document.getElementById('brandForm').submit(); }">
                ${b.brandName}
              </label>

            </li>
          </c:forEach>
        </ul>
      </form>

      <c:if test="${fn:length(brandList) > 5}">
        <button type="button" id="brandMoreBtn" onclick="toggleBrandMore()" style="font-size:12px;color:var(--text-muted);background:none;border:none;cursor:pointer;margin-top:6px;">더보기 ⌄</button>
      </c:if>
    </div>

    <%-- 지윤 26.07.30 추가: 브랜드 전체보기 모달 (그리드로 한눈에 보기, sidebar 체크박스를 그대로 옮겨서 재사용 -> 상태 동기화 문제 없음) --%>
    <div id="brandModalBg" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,0.4);z-index:1000;align-items:center;justify-content:center;">
      <div style="background:#fff;border-radius:12px;padding:24px;width:640px;max-height:80vh;overflow-y:auto;">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:16px;">
          <strong style="font-size:16px;">브랜드 전체</strong>
          <button type="button" onclick="cancelBrandModal()" style="background:none;border:none;font-size:18px;cursor:pointer;">&times;</button>
        </div>
        <div id="brandModalGrid" style="display:grid;grid-template-columns:repeat(3,1fr);gap:10px 16px;"></div>
        <div style="display:flex;justify-content:space-between;align-items:center;margin-top:20px;padding-top:14px;border-top:1px solid var(--border,#eee);">
          <button type="button" onclick="clearBrandAll()" style="font-size:13px;color:var(--text-muted);background:none;border:none;text-decoration:underline;cursor:pointer;">선택한 필터 전체 삭제</button>
          <button type="button" onclick="applyBrandModal()" style="background:var(--primary,#2BAB82);color:#fff;border:none;border-radius:8px;padding:10px 24px;font-weight:700;cursor:pointer;">적용하기</button>
        </div>
      </div>
    </div>

  </aside>

  <%-- 상품 목록 --%>
  <div class="store-content">
    <%-- 지윤 26.07.06 수정: species 파라미터 누락으로 고양이 탭에서 검색시 강아지로 초기화되던 버그 수정 --%>
<form method="get" action="${contextPath}/store" class="store-search-box">
  <input type="hidden" name="species" value="${selectedSpecies}">
  <c:if test="${not empty selectedCategory}">
    <input type="hidden" name="category" value="${selectedCategory}">
  </c:if>
  <c:if test="${not empty selectedAge}">
    <input type="hidden" name="age" value="${selectedAge}">
  </c:if>
  <input type="text" name="keyword" value="${selectedKeyword}" placeholder="상품명 또는 브랜드로 검색">
  <button type="submit">검색</button>
</form>

    <%-- 지윤 26.07.06 나이 필터: 선택된 카테고리에 나이 하위카테고리 있을 때만 표시 --%>
    <c:set var="hasAgeOptions" value="false"/>
    <c:forEach var="cat" items="${categoryTree}">
      <c:if test="${not empty selectedCategory && cat.parentId == selectedCategory}">
        <c:set var="hasAgeOptions" value="true"/>
      </c:if>
    </c:forEach>
    <c:if test="${hasAgeOptions}">
      <div class="age-filter">
        <c:url var="ageAllUrl" value="/store">
          <c:param name="species" value="${selectedSpecies}"/>
          <c:param name="category" value="${selectedCategory}"/>
        </c:url>
        <a href="${ageAllUrl}" class="age-chip ${empty selectedAge ? 'active' : ''}">전체</a>
        <c:forEach var="cat" items="${categoryTree}">
          <c:if test="${cat.parentId == selectedCategory}">
            <c:url var="ageUrl" value="/store">
              <c:param name="species" value="${selectedSpecies}"/>
              <c:param name="category" value="${selectedCategory}"/>
              <c:param name="age" value="${cat.categoryId}"/>
            </c:url>
            <a href="${ageUrl}" class="age-chip ${selectedAge == cat.categoryId ? 'active' : ''}">${cat.categoryName}</a>
          </c:if>
        </c:forEach>
      </div>
    </c:if>
    <div class="store-toolbar">

      <%--<div class="store-result-count">총 <strong>248</strong>개 상품</div>
      26.07.06 지윤. 하드코딩된 숫자 -> productList.size()로 실제 조회된 상품 개수 자동 표시하도록 변경 --%>
      <div class="store-result-count">총 <strong>${totalCount}</strong>개 상품</div>
      <%-- 지윤 26.07.06 정렬 기능 추가: 버튼 -> 링크로 변경, 카테고리/검색어 유지한 채 정렬만 바뀌게 처리 --%>
<%--<c:url var="sortBaseUrl" value="/store">
  <c:if test="${not empty selectedCategory}"><c:param name="category" value="${selectedCategory}"/></c:if>
  <c:if test="${not empty selectedKeyword}"><c:param name="keyword" value="${selectedKeyword}"/></c:if>
</c:url>--%>
<%-- After: selectedBrand가 이제 List라서 c:forEach로 여러 개를 각각 brand 파라미터로 추가 --%>
<c:url var="sortBaseUrl" value="/store">
  <c:param name="species" value="${selectedSpecies}"/>
  <c:if test="${not empty selectedCategory}"><c:param name="category" value="${selectedCategory}"/></c:if>
  <c:if test="${not empty selectedAge}"><c:param name="age" value="${selectedAge}"/></c:if>
  <c:if test="${not empty selectedKeyword}"><c:param name="keyword" value="${selectedKeyword}"/></c:if>
  <%-- 지윤 26.07.12 추가: 정렬 바뀌어도 가격/브랜드 필터 유지 --%>
  <c:if test="${not empty selectedMaxPrice}"><c:param name="maxPrice" value="${selectedMaxPrice}"/></c:if>
  <%-- 지윤 26.07.30 수정: selectedBrand String -> List, 여러 개 각각 param으로 추가 --%>
  <c:forEach var="sb" items="${selectedBrand}"><c:param name="brand" value="${sb}"/></c:forEach>
</c:url>

<%--<div class="store-sort">
  <a href="${sortBaseUrl}${empty selectedCategory && empty selectedKeyword ? '?' : '&'}sort=popular" class="sort-btn ${selectedSort == 'popular' ? 'on' : ''}">인기순</a>
  <a href="${sortBaseUrl}${empty selectedCategory && empty selectedKeyword ? '?' : '&'}sort=latest" class="sort-btn ${selectedSort == 'latest' ? 'on' : ''}">최신순</a>
  <a href="${sortBaseUrl}${empty selectedCategory && empty selectedKeyword ? '?' : '&'}sort=priceAsc" class="sort-btn ${selectedSort == 'priceAsc' ? 'on' : ''}">낮은가격</a>
  <a href="${sortBaseUrl}${empty selectedCategory && empty selectedKeyword ? '?' : '&'}sort=priceDesc" class="sort-btn ${selectedSort == 'priceDesc' ? 'on' : ''}">높은가격</a>
</div>--%>
<%-- 지윤 26.07.06 수정: sortBaseUrl에 species가 항상 포함되어 이미 완성된 URL(?species=5...)로 나옴
     기존 '?'/'&' 조건 분기를 두면 물음표가 두 번 붙어서 URL이 깨짐 -> 무조건 '&'로 고정 --%>
<div class="store-sort">
  <a href="${sortBaseUrl}&sort=popular" class="sort-btn ${selectedSort == 'popular' ? 'on' : ''}">인기순</a>
  <a href="${sortBaseUrl}&sort=latest" class="sort-btn ${selectedSort == 'latest' ? 'on' : ''}">최신순</a>
  <a href="${sortBaseUrl}&sort=priceAsc" class="sort-btn ${selectedSort == 'priceAsc' ? 'on' : ''}">낮은가격</a>
  <a href="${sortBaseUrl}&sort=priceDesc" class="sort-btn ${selectedSort == 'priceDesc' ? 'on' : ''}">높은가격</a>
</div>
</div>

   
   <%-- 지윤 26.07.06: 하드코딩 카드 6개 -> productList 실데이터 forEach로 교체 (USER-03) --%>
<div class="product-grid">
  <c:forEach var="p" items="${productList}">
    <div class="product-card" onclick="location.href='${contextPath}/store/detail?id=${p.productId}'">
    
      <div class="product-thumb-wrap">
        <%-- 지윤 26.07.15 수정: 로컬 업로드 이미지는 /upload/ 접두사 필요, 외부(목업) URL은 그대로 --%>
        <c:set var="thumbSrc" value="${fn:startsWith(p.thumbnailUrl,'http') ? p.thumbnailUrl : contextPath.concat('/upload/').concat(p.thumbnailUrl)}"/>
        <img class="product-thumb" src="${thumbSrc}" alt="${p.productName}" onerror="this.src='https://placehold.co/400x400/EAF7F2/2BAB82?text=상품'">
        
        <%-- 지윤 26.07.06: 원래 있던 BEST/NEW/SALE 뱃지는 DB에 근거 데이터가 없어서, 할인율 있을 때만 SALE 뱃지 표시하도록 단순화 --%>
        <c:if test="${p.discountRate > 0}"><span class="product-badge">SALE</span></c:if>
        <button type="button" class="product-wish wish-btn" data-wish-id="store:${p.productId}" aria-label="찜하기"><svg viewBox="0 0 24 24"><path d="M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78L12 21.23l8.84-8.84a5.5 5.5 0 000-7.78z"/></svg></button>
      </div>
      <div class="product-body">
        <div class="product-brand">${p.brandName}</div>
        <div class="product-name">${p.productName}</div>
        <div class="product-rating">
          <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
          <%-- 지윤 26.07.06: TB_REVIEW 더미데이터가 아직 없어서 지금은 항상 0.0 (0)으로 뜸. 리뷰 기능 붙이면 자동으로 채워짐 --%>
          <span>${p.avgRating} (${p.reviewCount})</span>
        </div>
        <div class="product-price">
          <%-- 지윤 26.07.06: 할인율 있으면 정가+할인율 같이 표시, 없으면 판매가만 표시 --%>
          <c:if test="${p.discountRate > 0}">
            <span class="price-rate">${p.discountRate}%</span>
            <span class="price-sale"><fmt:formatNumber value="${p.salePrice}" pattern="#,###"/>원</span>
            <span class="price-origin"><fmt:formatNumber value="${p.price}" pattern="#,###"/>원</span>
          </c:if>
          <c:if test="${p.discountRate == 0}">
            <span class="price-sale"><fmt:formatNumber value="${p.salePrice}" pattern="#,###"/>원</span>
          </c:if>
        </div>
      </div>
      <%--<div class="product-footer"><button class="btn-cart" data-product-id="${p.productId}" data-price="${p.salePrice}">장바구니 담기</button></div> 상품목록에서 장바구니담기 제거 옵션걸려서 애매함--%>
    </div>
  </c:forEach>
</div>

    
<c:url var="pageBaseUrl" value="/store">
  <c:param name="species" value="${selectedSpecies}"/>
  <c:if test="${not empty selectedCategory}"><c:param name="category" value="${selectedCategory}"/></c:if>
  <c:if test="${not empty selectedAge}"><c:param name="age" value="${selectedAge}"/></c:if>
  <c:if test="${not empty selectedKeyword}"><c:param name="keyword" value="${selectedKeyword}"/></c:if>
  <c:if test="${not empty selectedSort}"><c:param name="sort" value="${selectedSort}"/></c:if>
  <%-- 지윤 26.07.12 추가: 페이지 이동해도 가격/브랜드 필터 유지 --%>
  <c:if test="${not empty selectedMaxPrice}"><c:param name="maxPrice" value="${selectedMaxPrice}"/></c:if>
  <%-- 지윤 26.07.30 수정: selectedBrand String -> List --%>
  <c:forEach var="sb" items="${selectedBrand}"><c:param name="brand" value="${sb}"/></c:forEach>
</c:url>

<%--<c:set var="pageSep" value="${empty selectedCategory && empty selectedKeyword && empty selectedSort ? '?' : '&'}"/>--%>
<%-- 지윤 26.07.06 수정: pageBaseUrl도 species가 항상 포함되어 이미 완성된 URL로 나옴 -> 무조건 '&'로 고정 --%>
<c:set var="pageSep" value="&"/>

<div class="pagination">
  <c:if test="${currentPage > 1}">
    <a class="page-btn" href="${pageBaseUrl}${pageSep}page=${currentPage - 1}"><svg viewBox="0 0 24 24"><polyline points="15 18 9 12 15 6"/></svg></a>
  </c:if>
  <c:forEach var="p" begin="1" end="${totalPages}">
    <a class="page-btn ${p == currentPage ? 'active' : ''}" href="${pageBaseUrl}${pageSep}page=${p}">${p}</a>
  </c:forEach>
  <c:if test="${currentPage < totalPages}">
    <a class="page-btn" href="${pageBaseUrl}${pageSep}page=${currentPage + 1}"><svg viewBox="0 0 24 24"><polyline points="9 18 15 12 9 6"/></svg></a>
  </c:if>
</div>
</div>
</div>
<script>

document.querySelectorAll('.sort-btn').forEach(b => b.addEventListener('click', function(){
  document.querySelectorAll('.sort-btn').forEach(x => x.classList.remove('on'));
  this.classList.add('on');
}));

//지윤 26.07.12 가격대 슬라이더: 드래그 중엔 라벨만 갱신, 손 뗄 때(change) 기존 필터 유지한 채 maxPrice로 이동
var priceRangeInput = document.getElementById('priceRangeInput');
var priceRangeLabel = document.getElementById('priceRangeLabel');
if (priceRangeInput) {
  priceRangeInput.addEventListener('input', function () {
    var v = parseInt(priceRangeInput.value);
    priceRangeLabel.textContent = (v >= 150000) ? '전체' : v.toLocaleString() + '원 이하';
  });
  priceRangeInput.addEventListener('change', function () {
    var v = parseInt(priceRangeInput.value);
    var params = new URLSearchParams();
    params.set('species', '${selectedSpecies}');
    <c:if test="${not empty selectedCategory}">params.set('category', '${selectedCategory}');</c:if>
    <c:if test="${not empty selectedAge}">params.set('age', '${selectedAge}');</c:if>
    <c:if test="${not empty selectedKeyword}">params.set('keyword', '${selectedKeyword}');</c:if>
    <c:if test="${not empty selectedSort}">params.set('sort', '${selectedSort}');</c:if>
    <c:forEach var="sb" items="${selectedBrand}">params.append('brand', '${sb}');</c:forEach>
    if (v < 150000) { params.set('maxPrice', v); }
    location.href = '${contextPath}/store?' + params.toString();
  });
}

//지윤 26.07.30 추가: 브랜드 더보기 (사이드바 안에서 6번째부터 펼치기/접기)
function toggleBrandMore() {
  var extras = document.querySelectorAll('#brandListAll .brand-extra');
  var btn = document.getElementById('brandMoreBtn');
  var showing = extras.length > 0 && extras[0].style.display !== 'none';
  extras.forEach(function (li) { li.style.display = showing ? 'none' : ''; });
  btn.textContent = showing ? '더보기 ⌄' : '접기 ⌃';
}

//지윤 26.07.30 수정: 모달 열 때 체크 상태를 스냅샷으로 저장 -> X로 닫으면 이걸로 복구
var brandCheckedSnapshot = [];
function openBrandModal() {
  var items = document.querySelectorAll('#brandListAll .brand-item');
  var grid = document.getElementById('brandModalGrid');
  brandCheckedSnapshot = Array.from(document.querySelectorAll('#brandForm input[name=brand]')).map(function (cb) { return cb.checked; });
  items.forEach(function (li) {
    li.style.display = '';
    grid.appendChild(li);
  });
  document.getElementById('brandModalBg').style.display = 'flex';
}

//지윤 26.07.30 추가: X(취소)로 닫을 때 스냅샷으로 체크 상태 되돌림
function cancelBrandModal() {
  var checkboxes = document.querySelectorAll('#brandModalGrid input[name=brand]');
  checkboxes.forEach(function (cb, idx) { cb.checked = brandCheckedSnapshot[idx]; });
  closeBrandModal();
}

//모달 닫을 때 원래 사이드바 자리로 되돌림 (5개까지만 보이게 다시 정리)
function closeBrandModal() {
  var grid = document.getElementById('brandModalGrid');
  var sidebarList = document.getElementById('brandListAll');
  var items = Array.from(grid.children);
  items.forEach(function (li, idx) {
    if (idx >= 5) { li.style.display = 'none'; }
    sidebarList.appendChild(li);
  });
  document.getElementById('brandModalBg').style.display = 'none';
  var btn = document.getElementById('brandMoreBtn');
  if (btn) btn.textContent = '더보기 ⌄';
}

function applyBrandModal() {
  closeBrandModal();
  document.getElementById('brandForm').submit();
}

function clearBrandAll() {
  document.querySelectorAll('#brandModalGrid input[type=checkbox]').forEach(function (cb) { cb.checked = false; });
}
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
