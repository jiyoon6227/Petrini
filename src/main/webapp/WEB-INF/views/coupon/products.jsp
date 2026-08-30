<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>

<%--
  파일명: coupon/products.jsp
  작성자: 지윤
  작성일: 2026.08.06

  설명:
  쇼핑몰 쿠폰을 사용할 수 있는 상품 목록 화면.
  쿠폰을 발급한 사업자의 상품만 출력한다.
--%>

<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="contextPath"
       value="${pageContext.request.contextPath}" />

<c:set var="pageId" value="store" />

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
  /* 지윤 26.08.06: 쿠폰 적용 상품 화면 본문만 흰색 적용 */
.coupon-products {
  max-width: 1200px;
  margin: 0 auto;
  padding: 24px 20px 80px;
  background-color: #ffffff;

  /* 본문 양옆까지 흰색으로 채우기 */
  box-shadow: 0 0 0 100vmax #ffffff;
  clip-path: inset(0 -100vmax);
}

  .cp-breadcrumb {
    margin-bottom: 14px;
    color: #8b938f;
    font-size: 12px;
  }

  .cp-title {
    margin: 0;
    color: #202522;
    font-size: 28px;
    font-weight: 800;
  }

  .cp-subtitle {
    margin: 7px 0 22px;
    color: #7b827f;
    font-size: 14px;
  }

  /* 지윤 26.08.06: 선택한 쿠폰 정보 영역 */
  .cp-summary {
    display: flex;
    align-items: center;
    gap: 18px;
    margin-bottom: 22px;
    padding: 18px 22px;
    border: 1px solid #bfe8da;
    border-radius: 10px;
    background: #f4fbf8;
  }

  /* 지윤 26.08.06: 쿠폰 티켓 모양 */
.cp-summary-icon {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 52px;
  height: 32px;
  overflow: hidden;
  border-radius: 3px;
  background: #20a879;
  color: #ffffff;
  font-size: 19px;
  font-weight: 800;
  flex-shrink: 0;
}

.cp-summary-icon::before,
.cp-summary-icon::after {
  content: "";
  position: absolute;
  top: 50%;
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: #f4fbf8;
  transform: translateY(-50%);
}

.cp-summary-icon::before {
  left: -5px;
}

.cp-summary-icon::after {
  right: -5px;
}

  .cp-summary-info {
    flex: 1;
  }

  .cp-summary-name {
    margin-bottom: 4px;
    color: #15966e;
    font-size: 17px;
    font-weight: 800;
  }

  .cp-summary-condition,
  .cp-summary-date {
    color: #686f6c;
    font-size: 13px;
  }

  .cp-summary-status {
    padding: 8px 15px;
    border-radius: 6px;
    background: #20a879;
    color: #fff;
    font-size: 13px;
    font-weight: 700;
  }

  /* 지윤 26.08.06: 쿠폰 적용 상품 검색창 */
.cp-product-search {
  display: flex;
  width: 420px;
  height: 42px;
  margin: 0 0 20px;
}

.cp-product-search input {
  flex: 1;
  min-width: 0;
  padding: 0 15px;
  border: 1px solid #dfe5e2;
  border-right: none;
  border-radius: 8px 0 0 8px;
  outline: none;
  color: #222;
  font-size: 13px;
}

.cp-product-search input::placeholder {
  color: #9ca3a0;
}

.cp-product-search input:focus {
  border-color: #20a879;
}

.cp-product-search button {
  width: 52px;
  border: none;
  border-radius: 0 8px 8px 0;
  background: #20a879;
  color: #ffffff;
  font-size: 18px;
  cursor: pointer;
}

.cp-product-search button:hover {
  background: #178d66;
}

  /* 상품 개수 및 정렬 */
  .cp-toolbar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 14px;
  }

  .cp-count {
    font-size: 15px;
    font-weight: 700;
  }

  .cp-count strong {
    color: #169d73;
  }

  .cp-sort {
    display: flex;
    gap: 18px;
  }

  .cp-sort a {
    color: #555;
    font-size: 13px;
    text-decoration: none;
  }

  .cp-sort a.active {
    color: #169d73;
    font-weight: 800;
  }

  /* 지윤 26.08.06: 쿠폰 적용 상품 4열 배치 */
  .cp-product-grid {
    display: grid;
    grid-template-columns: repeat(4, minmax(0, 1fr));
    gap: 18px;
  }

  .cp-product-card {
    display: block;
    overflow: hidden;
    border: 1px solid #e5e9e7;
    border-radius: 10px;
    background: #fff;
    color: inherit;
    text-decoration: none;
    transition: 0.2s;
  }

  .cp-product-card:hover {
    transform: translateY(-3px);
    box-shadow: 0 8px 24px rgba(30, 70, 55, 0.10);
  }

  /* 지윤 26.08.06: 상품 카드를 가로로 넓어 보이도록 이미지 높이 조정 */
.cp-product-image {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 165px;
  overflow: hidden;
  background: #ffffff;
}

  .cp-product-image img {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

  .cp-no-image {
    color: #abb2ae;
    font-size: 13px;
  }

  .cp-product-body {
    padding: 14px;
  }

  .cp-product-brand {
    margin-bottom: 5px;
    color: #969d99;
    font-size: 12px;
  }

  /* 지윤 26.08.06: 상품명 글씨 진하게 표시 */
  /* 지윤 26.08.06: 상품명과 별점 간격 축소 */
.cp-product-name {
  min-height: 21px;
  overflow: hidden;
  color: #111111;
  font-size: 15px;
  font-weight: 700;
  line-height: 1.4;
}

  /* 지윤 26.08.06: 상품명과 별점 사이 간격 축소 */
.cp-product-rating {
  margin: 2px 0 7px;
  color: #7e8581;
  font-size: 12px;
}

  .cp-rating-star {
    color: #16a477;
  }

  .cp-original-price {
    margin-right: 7px;
    color: #aaa;
    font-size: 12px;
    text-decoration: line-through;
  }

  /* 지윤 26.08.06: 판매가격 주황색 표시 */
  .cp-sale-price {
  color: #f97316;
  font-size: 17px;
  font-weight: 800;
}

  /* 지윤 26.08.06: 가격과 쿠폰 적용 배지를 한 줄로 배치 */
  .cp-product-price {
  display: flex;
  align-items: center;
  gap: 7px;
  min-height: 25px;
}

 /* 지윤 26.08.06: 쿠폰 적용 배지를 가격 오른쪽에 표시 */
.cp-apply-badge {
  display: inline-block;
  margin-left: auto;
  padding: 4px 9px;
  border-radius: 5px;
  background: #def5ec;
  color: #15966e;
  font-size: 11px;
  font-weight: 800;
  white-space: nowrap;
}

  .cp-empty {
    grid-column: 1 / -1;
    padding: 80px 0;
    color: #888;
    text-align: center;
  }

  /* 태블릿·모바일에서는 상품 2열 표시 */
  @media (max-width: 900px) {
    .cp-product-grid {
      grid-template-columns: repeat(2, 1fr);
    }

    .cp-summary-date {
      display: none;
    }
  }
</style>

<main class="coupon-products">

  <div class="cp-breadcrumb">
    홈 &gt; 쿠폰함 &gt; 쿠폰 적용 상품
  </div>

  <h1 class="cp-title">쿠폰 적용 상품</h1>

  <p class="cp-subtitle">
    이 쿠폰을 사용할 수 있는 상품이에요.
  </p>

  <%-- 지윤 26.08.06: 선택한 쿠폰 정보 출력 --%>
  <section class="cp-summary">

    <div class="cp-summary-icon">%</div>

    <div class="cp-summary-info">

      <div class="cp-summary-name">
        ${coupon.couponName}
      </div>

      <div class="cp-summary-condition">
        <c:if test="${coupon.minOrderAmt > 0}">
          <fmt:formatNumber
              value="${coupon.minOrderAmt}"
              type="number"/>원 이상 구매 시
        </c:if>

        <c:if test="${not empty coupon.bizName}">
          · ${coupon.bizName}
        </c:if>
      </div>

    </div>

    <c:if test="${not empty coupon.useEndDate
                  && fn:length(coupon.useEndDate) >= 8}">
      <div class="cp-summary-date">
        ${fn:substring(coupon.useEndDate, 0, 4)}.
        ${fn:substring(coupon.useEndDate, 4, 6)}.
        ${fn:substring(coupon.useEndDate, 6, 8)}까지
      </div>
    </c:if>

    <span class="cp-summary-status">적용 가능</span>

  </section>

<%-- 지윤 26.08.06: 현재 쿠폰 적용 상품 내 검색 --%>
<form class="cp-product-search"
      method="get"
      action="${contextPath}/coupon/products">

  <input type="hidden"
         name="couponId"
         value="${coupon.couponId}">

  <input type="hidden"
         name="sort"
         value="${selectedSort}">

  <input type="text"
         name="keyword"
         value="${selectedKeyword}"
         placeholder="적용 상품을 검색해보세요"
         autocomplete="off">

  <button type="submit" aria-label="상품 검색">
    &#128269;
  </button>

</form>

<div class="cp-toolbar">

    <div class="cp-count">
      적용 상품
      <strong>${productList.size()}개</strong>
    </div>

    <%-- 지윤 26.08.06: 적용 상품 정렬 --%>
    <nav class="cp-sort">

      <a class="${selectedSort eq 'popular' ? 'active' : ''}"
   href="${contextPath}/coupon/products?couponId=${coupon.couponId}&sort=popular&keyword=${selectedKeyword}">
  인기순
</a>

<a class="${selectedSort eq 'priceAsc' ? 'active' : ''}"
   href="${contextPath}/coupon/products?couponId=${coupon.couponId}&sort=priceAsc&keyword=${selectedKeyword}">
  낮은 가격순
</a>

<a class="${selectedSort eq 'priceDesc' ? 'active' : ''}"
   href="${contextPath}/coupon/products?couponId=${coupon.couponId}&sort=priceDesc&keyword=${selectedKeyword}">
  높은 가격순
</a>

    </nav>

  </div>

  <section class="cp-product-grid">

    <c:choose>

      <%-- 적용 가능한 상품이 없는 경우 --%>
      <c:when test="${empty productList}">
        <div class="cp-empty">
          현재 적용 가능한 상품이 없습니다.
        </div>
      </c:when>

      <%-- 쿠폰 적용 상품 목록 --%>
      <c:otherwise>

        <c:forEach var="p" items="${productList}">

          <%-- 지윤 26.08.06: 기존 상품 상세 페이지로 이동 --%>
          <a class="cp-product-card"
             href="${contextPath}/store/detail?id=${p.productId}">

            <div class="cp-product-image">

              <c:choose>

                <c:when test="${not empty p.thumbnailUrl}">

                  <c:choose>
                    <c:when test="${fn:startsWith(p.thumbnailUrl, 'http')}">
                      <c:set var="thumbnailSrc"
                             value="${p.thumbnailUrl}" />
                    </c:when>

                    <c:otherwise>
                      <c:set var="thumbnailSrc"
                             value="${contextPath}/upload/${p.thumbnailUrl}" />
                    </c:otherwise>
                  </c:choose>

                  <img src="${thumbnailSrc}"
                       alt="${p.productName}">

                </c:when>

                <c:otherwise>
                  <span class="cp-no-image">
                    이미지 준비 중
                  </span>
                </c:otherwise>

              </c:choose>

            </div>

            <div class="cp-product-body">

              <div class="cp-product-brand">
                ${p.brandName}
              </div>

              <div class="cp-product-name">
                ${p.productName}
              </div>

              <div class="cp-product-rating">
                <span class="cp-rating-star">★</span>
                ${p.avgRating} (${p.reviewCount})
              </div>

             <%-- 지윤 26.08.06: 가격과 쿠폰 적용 배지를 한 줄로 표시 --%>
             <div class="cp-product-price">

               <c:if test="${p.price > p.salePrice}">
               <span class="cp-original-price">
               <fmt:formatNumber
                       value="${p.price}"
                       type="number"/>원
                 </span>
                 </c:if>

                 <span class="cp-sale-price">
                   <fmt:formatNumber
                       value="${p.salePrice}"
                       type="number"/>원
                 </span>

                 <span class="cp-apply-badge">
                   쿠폰 적용
                 </span>

</div>

            </div>

          </a>

        </c:forEach>

      </c:otherwise>

    </c:choose>

  </section>

</main>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>