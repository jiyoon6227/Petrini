<%--
    태그추가 , 인기상품 하드코딩 -> DB반복출력
    커뮤니티 -> 6개 호출 -> 최신 3개를 DB에서 호출하는식으로 변경
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %> <%-- DB salePrice 숫자 → 천단위 콤마 포맷 --%>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="home" />

<%-- ===== HEADER ===== --%>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<main>
    <%-- ===================================================
         HERO BANNER SLIDER
    ===================================================== --%>
    <div class="hero-section inner" id="heroSection">
        <div class="hero-slides" id="heroSlides">
            <%-- DB 배너 없을 때 기본 히어로 배너 --%>
            <div class="hero-slide hero-slide-default active" id="heroFallback">
                <div class="hero-image">
                    <img src="https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=1200&q=80"
                         alt="강아지와 고양이" onerror="this.src='https://placehold.co/1200x360/EAF7F2/2BAB82?text=펫린이'">
                </div>
                <div class="hero-text">
                    <span class="hero-badge">반려동물 통합 케어</span>
                    <h2 class="hero-title">우리 아이의<br>모든 순간을 함께해요</h2>
                    <p class="hero-desc">쇼핑부터 병원 예약, 여가까지<br>펫린이 하나로 간편하게!</p>
                </div>
            </div>
        </div>

        <%-- 슬라이드 좌우 화살표 (DB 배너 2개 이상일 때만 표시) --%>
        <div class="hero-controls" id="heroControls" style="display:none">
            <button type="button" class="slide-nav-btn btn-prev" aria-label="이전 배너">&#10094;</button>
            <button type="button" class="slide-nav-btn btn-next" aria-label="다음 배너">&#10095;</button>
        </div>
    </div>

    <%-- 인기상품 --%>
    <section class="section-wrap">
        <div class="section-head">
            <h2 class="section-title">인기상품</h2>
            <a href="${contextPath}/store" class="section-more">더보기</a>
        </div>
        <div class="home-product-grid">

            <%-- MainSectionService → popularProducts (TB_PRODUCT TOP 8) --%>
            <c:choose>
            <c:when test="${not empty popularProducts}">
                <c:forEach var="product" items="${popularProducts}">
                    <a href="${contextPath}/store/detail?id=${product.productId}" class="home-product-card">
                        <img class="home-product-thumb"
                             src="${not empty product.imageUrl ? contextPath.concat('/upload/').concat(product.imageUrl) : 'https://placehold.co/400x400/EAF7F2/2BAB82?text=상품'}"
                             alt="${product.productName}"
                             onerror="this.src='https://placehold.co/400x400/EAF7F2/2BAB82?text=상품'">
                        <div class="home-product-body">
                            <div class="home-product-name">${product.productName}</div>
                            <div class="home-product-price">
                                <c:if test="${product.discountRate > 0}">
                                    <span class="home-product-rate">${product.discountRate}%</span>
                                </c:if>
                                <fmt:formatNumber value="${product.salePrice}" pattern="#,###"/>원
                            </div>
                        </div>
                    </a>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <p class="section-empty">등록된 인기 상품이 없습니다.</p>
            </c:otherwise>
            </c:choose>
        </div>
    </section>

    <%-- 메인 중간 배너 (MAIN_MID, API 연동) --%>
    <div class="main-mid-banner-wrap" id="mainMidBannerWrap">
        <div class="main-mid-banner" id="mainMidBanner">
             <%-- MAIN_MID 없을 때 기본 배너 --%>
               <a href="${contextPath}/store" class="main-mid-banner-link" id="mainMidBannerFallback">
                   <img src="https://placehold.co/1200x200/EAF7F2/2BAB82?text=PetCare"
                      alt="펫린이 쇼핑 바로가기">
            </a>
        </div>
    </div>


    <%-- 커뮤니티 미리보기 (최신 3건) --%>
    <section class="section-wrap">
        <div class="section-head">
            <h2 class="section-title">커뮤니티</h2>
            <a href="${contextPath}/community" class="section-more">더보기</a>
        </div>
        <div class="community-grid">

            <%-- MainSectionService → communityPreview (TB_POST 최신 3건) --%>
            <c:choose>
            <c:when test="${not empty communityPreview}">
                <c:forEach var="post" items="${communityPreview}">
                    <a href="${contextPath}/community/detail?id=${post.postId}" class="community-item">
                        <div class="community-thumb">
                            <img src="${not empty post.thumbUrl ? contextPath.concat(post.thumbUrl) : 'https://placehold.co/96x96/EAF7F2/2BAB82?text=IMG'}"
                                 alt="커뮤니티"
                                 onerror="this.src='https://placehold.co/96x96/EAF7F2/2BAB82?text=IMG'">
                        </div>
                        <div class="community-content">
                            <p class="community-title">${post.title}</p>
                            <p class="community-desc">${post.bodyPreview}</p>
                            <div class="community-meta">
                                <span class="time">${post.nickname} · ${post.regDateLabel}</span>
                                <span class="comment">
                                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>
                                    </svg>
                                    ${post.commentCount}
                                </span>
                            </div>
                        </div>
                    </a>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <p class="section-empty">등록된 게시글이 없습니다.</p>
            </c:otherwise>
            </c:choose>
        </div>
    </section>

</main>

<%-- ===== FOOTER ===== --%>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />

<script src="${contextPath}/resources/js/main.js"></script>
<script>
    fetch('${contextPath}/api/banners')
    .then(function(result) { return result.json(); })
    .then(function(list) {
        var heroSection = document.getElementById('heroSection');
        var heroControls = document.getElementById('heroControls');
        var heroFallback = document.getElementById('heroFallback');
        var slider = document.getElementById('heroSlides');

        // 노출중 배너 없으면 기본 배너 유지 (슬라이더 컨트롤 숨김)
        if (!list || list.length === 0) {
            if (heroControls) heroControls.style.display = 'none';
            return;
        }

        if (heroFallback) heroFallback.remove();
        if (heroSection) heroSection.style.display = '';

  // 1) 슬라이드 DOM 추가
  for (var i = 0; i < list.length; i++) {
    var banner = list[i];
    var div = document.createElement('div');
    div.className = 'hero-slide' + (i === 0 ? ' active' : '');

    // API imageUrl 절대경로·상대경로 분기 (UploadUrlUtil 연동)
    var imgSrc = banner.imageUrl || '';
    if (imgSrc && imgSrc.indexOf('http') !== 0) {
        var ctx = '${contextPath}';
        if (!(ctx && imgSrc.indexOf(ctx + '/') === 0)) {
            if (imgSrc.indexOf('/upload/') === 0) {
                imgSrc = ctx + imgSrc;
            } else if (imgSrc.indexOf('/') !== 0) {
                imgSrc = ctx + '/upload/' + imgSrc;
            }
        }
    }
    div.innerHTML =
    '<div class="hero-image">' +
    '  <a href="' + (banner.linkUrl || '#') + '">' +
    '    <img src="' + imgSrc + '" alt="' + (banner.title || '') + '"' +
    '         onerror="this.src=\'https://placehold.co/1200x360/EAF7F2/2BAB82?text=PetCare\'">' +
    '  </a>' +
    '</div>';

    slider.appendChild(div);
}

        // 2) 슬라이드 좌우 화살표 (2개 이상일 때만 표시)
        if (list.length > 1 && heroControls) {
            heroControls.style.display = '';
        } else if (heroControls) {
            heroControls.style.display = 'none';
        }
        initHeroSlider();
    })
    .catch(function(err) {
        console.error('메인 배너 로드 실패', err);
        var heroControls = document.getElementById('heroControls');
        if (heroControls) heroControls.style.display = 'none';
    });
</script>

<script>
// 메인 중간 배너 API (MAIN_MID, 없으면 fallback 유지)
(function() {
    var ctx = '${contextPath}';
    fetch(ctx + '/api/banners?position=MAIN_MID')
        .then(function(res) { return res.json(); })
        .then(function(list) {
            var wrap = document.getElementById('mainMidBannerWrap');
            var box  = document.getElementById('mainMidBanner');
            if (!wrap || !box) return;

            // 활성 배너 없으면 기본 placeholder 유지
            if (!list || list.length === 0) {
                return;
            }

            // DB 배너 있으면 fallback 제거
            var fallback = document.getElementById('mainMidBannerFallback');
            if (fallback) fallback.remove();

            // MAIN_MID 슬롯 이미지 렌더 (API imageUrl 그대로 사용)
            for (var i = 0; i < list.length; i++) {
                var b = list[i];
                var imgSrc = b.imageUrl || '';
                if (!imgSrc) continue;

                var a = document.createElement('a');
                a.href = b.linkUrl || '#';
                a.className = 'main-mid-banner-link';
                a.innerHTML = '<img src="' + imgSrc + '" alt="' + (b.title || '').replace(/"/g, '&quot;') + '"' +
                    ' onerror="this.src=\'https://placehold.co/1200x200/EAF7F2/2BAB82?text=AD\'">';
                box.appendChild(a);
            }
        })
        .catch(function(err) {
            console.error('메인 중간 배너 로드 실패', err);
        });
})();
</script>

