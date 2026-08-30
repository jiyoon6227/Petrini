<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- 지윤 26.07.07 추가: 가격 콤마 표시용 fmt 태그 --%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%-- 지윤 26.07.15 추가: 이미지 URL이 http로 시작하는지 검사용 (외부 URL vs 로컬 업로드 구분) --%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="store" />
<%-- 지윤 26.07.07 수정: URL param.id 그대로 쓰던 것 -> Controller가 넘겨준 product 객체의 productId로 변경 (실데이터 연동) --%>
<c:set var="productId" value="${product.productId}" />

<%@ include file="/WEB-INF/views/common/header.jsp" %>
<style>
.detail-wrap { max-width:var(--inner-width); margin:32px auto 80px; padding:0 20px; }
.breadcrumb { font-size:13px; color:var(--text-muted); margin-bottom:24px; }
.breadcrumb a { color:var(--text-muted); text-decoration:none; } .breadcrumb a:hover { color:var(--primary); }
.breadcrumb span { margin:0 6px; }
.detail-top { display:grid; grid-template-columns:1fr 1fr; gap:40px; margin-bottom:48px; }
/* 이미지 */
.detail-gallery {}
.detail-main-img { width:100%; aspect-ratio:1/1; object-fit:cover; border-radius:var(--radius-md); display:block; margin-bottom:12px; }
.detail-thumbs { display:flex; gap:8px; }
.detail-thumb { width:72px; height:72px; border-radius:var(--radius-sm); object-fit:cover; cursor:pointer; border:2px solid transparent; transition:var(--transition); }
.detail-thumb.active,.detail-thumb:hover { border-color:var(--primary); }
/* 정보 */
.detail-info {}
.detail-brand { font-size:13px; color:var(--text-muted); margin-bottom:6px; }
.detail-name { font-size:22px; font-weight:800; color:var(--text-main); margin-bottom:12px; line-height:1.3; }
.detail-rating { display:flex; align-items:center; gap:8px; margin-bottom:16px; padding-bottom:16px; border-bottom:1px solid var(--border); }
.detail-rating svg { width:14px; height:14px; fill:var(--yellow); }
.detail-rating span { font-size:13px; color:var(--text-muted); }
.detail-price-wrap { margin-bottom:20px; }
.detail-price-rate { font-size:20px; font-weight:800; color:var(--accent); }
.detail-price-sale { font-size:28px; font-weight:800; color:var(--text-main); margin-left:6px; }
.detail-price-origin { font-size:14px; color:var(--text-muted); text-decoration:line-through; margin-top:2px; }
.detail-tags { display:flex; gap:6px; flex-wrap:wrap; margin-bottom:20px; }
.detail-tag { font-size:12px; background:var(--primary-light); color:var(--primary-dark); padding:4px 10px; border-radius:20px; font-weight:600; }
.detail-option { margin-bottom:16px; }
.detail-option label { font-size:13px; font-weight:600; color:var(--text-sub); display:block; margin-bottom:6px; }
.detail-option select,.detail-qty-wrap input { border:1px solid var(--border); border-radius:var(--radius-sm); padding:10px 14px; font-size:14px; color:var(--text-main); outline:none; width:100%; box-sizing:border-box; }
.detail-option select:focus { border-color:var(--primary); }
.detail-qty-wrap { display:flex; border:1px solid var(--border); border-radius:var(--radius-sm); overflow:hidden; }
.detail-qty-wrap button { width:40px; background:#f5f5f5; border:none; font-size:18px; cursor:pointer; color:var(--text-sub); flex-shrink:0; }
.detail-qty-wrap button:hover { background:var(--primary-light); color:var(--primary); }
.detail-qty-wrap input { border:none; border-left:1px solid var(--border); border-right:1px solid var(--border); text-align:center; width:60px; flex:1; }
.detail-total { background:var(--bg-page); border-radius:var(--radius-sm); padding:14px 16px; margin-bottom:20px; display:flex; justify-content:space-between; align-items:center; }
.detail-total span { font-size:13px; color:var(--text-muted); }
.detail-total strong { font-size:20px; font-weight:800; color:var(--primary-dark); }
.detail-btn-row { display:flex; gap:10px; }
.btn-wish-detail { flex:1; padding:14px; border:2px solid var(--primary); border-radius:var(--radius-sm); background:#fff; color:var(--primary); font-size:15px; font-weight:700; cursor:pointer; display:flex; align-items:center; justify-content:center; gap:6px; }
.btn-wish-detail svg { width:18px; height:18px; stroke:currentColor; fill:none; stroke-width:2; }
.btn-cart-detail { flex:2; padding:14px; border:none; border-radius:var(--radius-sm); background:var(--primary); color:#fff; font-size:15px; font-weight:700; cursor:pointer; }
/* 지윤 26.07.08 추가: 바로구매 버튼 스타일 (기존엔 스타일 정의 자체가 없어서 브라우저 기본 버튼으로 보였음) */
.btn-buy-now { flex:1; padding:14px; border:1px solid var(--primary); border-radius:var(--radius-sm); background:#fff; color:var(--primary); font-size:15px; font-weight:700; cursor:pointer; transition:var(--transition); }
.btn-buy-now:hover { background:var(--primary-light); }
.btn-buy-detail { flex:2; padding:14px; border:none; border-radius:var(--radius-sm); background:var(--text-main); color:#fff; font-size:15px; font-weight:700; cursor:pointer; }
/* 탭 */
.detail-tab-bar { display:flex; border-bottom:2px solid var(--border); margin-bottom:28px; }
.detail-tab { padding:12px 24px; font-size:14px; font-weight:600; color:var(--text-muted); border:none; background:none; cursor:pointer; border-bottom:2px solid transparent; margin-bottom:-2px; transition:var(--transition); }
.detail-tab.on { color:var(--primary); border-bottom-color:var(--primary); }
.tab-section { display:none; } .tab-section.on { display:block; }
/* 리뷰 */
.review-summary { display:flex; gap:32px; align-items:center; background:var(--bg-page); border-radius:var(--radius-md); padding:24px; margin-bottom:24px; }
.review-avg { text-align:center; }
.review-avg .big { font-size:48px; font-weight:800; color:var(--text-main); line-height:1; }
.review-avg small { font-size:13px; color:var(--text-muted); }
.review-stars { display:flex; gap:3px; justify-content:center; margin:6px 0; }
.review-stars svg { width:18px; height:18px; fill:var(--yellow); }
.review-bars { flex:1; display:flex; flex-direction:column; gap:6px; }
.review-bar-row { display:flex; align-items:center; gap:10px; font-size:12px; color:var(--text-muted); }
.review-bar-bg { flex:1; height:6px; background:var(--border); border-radius:3px; overflow:hidden; }
.review-bar-fill { height:100%; background:var(--yellow); border-radius:3px; }
.review-card { border:1px solid var(--border); border-radius:var(--radius-md); padding:18px; margin-bottom:14px; overflow:hidden; min-width:0; }
.review-card-head { display:flex; justify-content:space-between; margin-bottom:10px; }
.reviewer { font-size:14px; font-weight:700; color:var(--text-main); }
.review-date { font-size:12px; color:var(--text-muted); }
.review-text { font-size:14px; color:var(--text-sub); line-height:1.6; word-break:break-word; overflow-wrap:anywhere; }
/* 2026/08/12 장우철 — 사장님 답글 긴 문자열 줄바꿈 */
.review-biz-reply { margin-top:10px; padding:12px 14px; background:#EAF7F2; border-left:3px solid #2BAB82; border-radius:8px; max-width:100%; box-sizing:border-box; overflow-wrap:anywhere; word-break:break-word; }
.review-biz-reply-text { margin-top:4px; font-size:14px; color:var(--text-sub); line-height:1.6; white-space:pre-wrap; overflow-wrap:anywhere; word-break:break-word; }
.review-report-btn { margin-top:10px; background:none; border:none; color:var(--text-muted); font-size:12px; text-decoration:underline; cursor:pointer; padding:0; }
.review-report-btn:hover { color:var(--accent); }
</style>

<div class="detail-wrap">
  <div class="breadcrumb">
    <a href="${contextPath}/">홈</a><span>›</span>
    <a href="${contextPath}/store">상품</a><span>›</span>
    <%-- 지윤 26.07.07 수정: 하드코딩된 카테고리명/상품명 -> product 실데이터로 변경 --%>
    <a href="${contextPath}/store">${product.categoryName}</a><span>›</span>
    ${product.productName}
  </div>

  <div class="detail-top">
    <%-- 이미지 갤러리 --%>
    <div class="detail-gallery">

      <%-- 지윤 26.07.07 수정: 메인 상품 고정 이미지 URL -> DB에서 가져온 product.thumbnailUrl로 변경 --%>
     <%-- 지윤 26.07.15 수정: 로컬 업로드 이미지는 /upload/ 접두사 필요, 외부(목업) URL은 그대로 --%>
     <img class="detail-main-img" id="mainImg"
     src="${fn:startsWith(product.thumbnailUrl,'http') ? product.thumbnailUrl : contextPath.concat('/upload/').concat(product.thumbnailUrl)}"
     alt="${product.productName}" onerror="this.src='https://placehold.co/600x600/EAF7F2/2BAB82?text=상품'">

      <%-- 지윤 26.07.07 수정: 썸네일 3개 하드코딩 -> TB_FILE 실데이터로 개수 상관없이 자동 반복
     이미지 없는 상품은 imageList가 빈 리스트라 자동으로 썸네일 줄 자체가 안 보임 --%>
   <div class="detail-thumbs">
    <c:forEach var="img" items="${product.imageList}" varStatus="loop">
    <c:set var="thumbSrc" value="${fn:startsWith(img,'http') ? img : contextPath.concat('/upload/').concat(img)}"/>
    <img class="detail-thumb ${loop.first ? 'active' : ''}" src="${thumbSrc}" alt="${product.productName} ${loop.index+1}" onclick="switchImg(this,'${thumbSrc}')">
    </c:forEach>
    </div>
    </div>

    <%-- 상품 정보 --%>
    <div class="detail-info">
      <%-- 지윤 26.07.07 수정: 브랜드/상품명/평점/가격 하드코딩 -> product 실데이터로 변경
     별 아이콘 5개 고정 -> 1개만 남기고 텍스트로 대체 (진짜 별점 렌더링은 리뷰 단계에서 처리 예정) --%>
    <div class="detail-brand">${product.brandName}</div>
    <div class="detail-name">${product.productName}</div>
    <div class="detail-rating">
      <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
      <span>${product.avgRating}점 (${product.reviewCount}개 리뷰)</span>
    </div>
    <div class="detail-price-wrap">
    <div>
     <c:if test="${product.discountRate > 0}"><span class="detail-price-rate">${product.discountRate}%</span></c:if>
     <span class="detail-price-sale"><fmt:formatNumber value="${product.salePrice}" pattern="#,###"/>원</span>
    </div>
    <c:if test="${product.discountRate > 0}">
    <div class="detail-price-origin">정가 <fmt:formatNumber value="${product.price}" pattern="#,###"/>원</div>
     </c:if>
    </div>

      <%-- 지윤 26.07.21 수정: 하드코딩된 뱃지 4개 -> TB_PRODUCT.TAGS(쉼표 구분)를 split해서 실제 태그로 렌더링. 태그 없으면 영역 자체 숨김 --%>
      <c:if test="${not empty product.tags}">
        <div class="detail-tags">
          <c:forEach var="tag" items="${fn:split(product.tags, ',')}">
            <c:if test="${not empty fn:trim(tag)}">
              <span class="detail-tag">${fn:trim(tag)}</span>
            </c:if>
          </c:forEach>
        </div>
      </c:if>

      <%-- 지윤 26.07.07 수정: 용량 하드코딩 -> TB_PRODUCT_OPTION 실데이터로 변경
     색상이 없거나 '기본'이면 색상 표시 생략, 사이즈만 표시 --%>
<div class="detail-option">
  <label>옵션 선택</label>
  <select id="optionSelect" onchange="onOptionChange()">
    <%-- 지윤 26.07.15 수정: 옵션 있든 없든(단일옵션 포함) 무조건 안내문구부터 먼저 보여주기 --%>
    <option value="" data-stock="0" data-option-id="" disabled selected>옵션을 선택해 주세요</option>
    <c:forEach var="opt" items="${product.optionList}">

      <%-- 지윤 26.07.08 수정: data-option-id 추가 (장바구니 담을 때 어느 옵션인지 알아야 해서) --%>
<%-- 지윤 26.07.15 추가: 재고 0인 옵션은 선택 자체를 막음(disabled) + "품절" 표시 --%>
<option value="${opt.addPrice}" data-stock="${opt.stockQty}" data-option-id="${opt.optionId}" ${opt.stockQty <= 0 ? 'disabled' : ''}>
<c:if test="${not empty opt.optionColor && opt.optionColor != '기본'}">${opt.optionColor} / </c:if>${opt.optionSize}
<c:if test="${opt.addPrice > 0}"> (+<fmt:formatNumber value="${opt.addPrice}" pattern="#,###"/>원)</c:if>
<c:if test="${opt.stockQty <= 0}"> - 품절</c:if>
</option>

    </c:forEach>
    <%-- 지윤 26.07.08 추가: 옵션 없는 상품은 빈 박스로 보이던 것 -> cart.jsp와 동일하게 "단일 옵션" 표시. data-option-id 빈 값 -> 장바구니 담을 때 null 처리됨 --%>
    <c:if test="${empty product.optionList}">
      <option value="0" data-stock="${product.stockQty}" data-option-id="">단일 옵션</option>
    </c:if>
  </select>
</div>

    <div class="detail-option">
  <label>수량</label>
  <div class="detail-qty-wrap">
    <button onclick="changeQty(-1)">−</button>
    <input type="number" id="qty" value="1" min="1">
    <button onclick="changeQty(1)">+</button>
  </div>
  <%-- 지윤 26.07.07 추가: 재고 초과 경고 --%>
  <div id="stockWarning" style="display:none; color:var(--accent); font-size:12px; margin-top:6px;">재고가 부족합니다.</div>
<!-- 지윤 26.07.14 추가: 0개 이하 입력 시 안내문구용 -->
<div id="qtyLimitMsg" style="display:none; color:var(--accent); font-size:12px; margin-top:6px;"></div>
  </div>

  <%-- 지윤 26.07.07 수정: 하드코딩 48,900원 -> 실제 판매가로 변경 --%>
  <div class="detail-total">
  <span>총 결제금액</span>
  <strong id="totalPrice"><fmt:formatNumber value="${product.salePrice}" pattern="#,###"/>원</strong>
  </div>

<div class="detail-btn-row">
<button type="button" class="btn-wish-detail wish-btn" data-wish-id="store:${productId}" aria-label="찜하기">찜</button>
<%-- 지윤 26.07.08 수정: alert만 뜨던 가짜 버튼 -> 실제 TB_CART_ITEM에 저장하는 폼으로 변경 --%>
<form id="cartForm" style="display:contents">
  <input type="hidden" name="productId" value="${product.productId}">
  <input type="hidden" name="optionId" id="cartOptionId">
  <input type="hidden" name="qty" id="cartQty">
  <input type="hidden" name="price" id="cartPrice">
  <button type="button" id="btnAddCart" class="btn-cart-detail">장바구니</button>
</form>
<button type="button" id="btnBuyNow" class="btn-buy-now">바로구매</button>
      </div>
    </div>
  </div>

  <%-- 탭 --%>
  <div class="detail-tab-bar">
    <button class="detail-tab on" onclick="showTab('info',this)">상품 정보</button>
    <button class="detail-tab" onclick="showTab('review',this)">리뷰 (${product.reviewCount})</button>
    <button class="detail-tab" onclick="showTab('qna',this)">Q&A (${product.qnaList.size()})</button>
  </div>

  <%-- 지윤 26.07.12 수정: 하드코딩 이미지/주요특징 -> product.imageList(실제 상품이미지)/product.description(실제 설명) 실데이터로 교체 --%>
  <div class="tab-section on" id="tab-info">
    <c:choose>
      <c:when test="${not empty product.imageList}">
        <c:set var="infoImgSrc" value="${fn:startsWith(product.imageList[0],'http') ? product.imageList[0] : contextPath.concat('/upload/').concat(product.imageList[0])}"/>
        <img src="${infoImgSrc}" style="width:100%;border-radius:var(--radius-md)" alt="상품상세" onerror="this.src='https://placehold.co/900x400/EAF7F2/2BAB82?text=상품상세이미지'">
      </c:when>
      <c:otherwise>
        <img src="https://placehold.co/900x400/EAF7F2/2BAB82?text=상품상세이미지" style="width:100%;border-radius:var(--radius-md)" alt="상품상세">
      </c:otherwise>
    </c:choose>
    <div style="padding:24px;background:var(--bg-page);border-radius:var(--radius-md);margin-top:20px;font-size:14px;color:var(--text-sub);line-height:1.8">
      <strong style="display:block;font-size:16px;color:var(--text-main);margin-bottom:12px">상품 설명</strong>
      <c:choose>
        <c:when test="${not empty product.description}">${product.description}</c:when>
        <c:otherwise>등록된 상품 설명이 없습니다.</c:otherwise>
      </c:choose>
    </div>

    <%-- 사이트 공통 배송/교환/반품 안내 (상품마다 다르지 않은 고정 정책) --%>
    <div style="margin-top:24px;padding:24px;border:1px solid var(--border);border-radius:var(--radius-md);font-size:13px;color:var(--text-sub);line-height:1.8">
      <strong style="display:block;font-size:16px;color:var(--text-main);margin-bottom:14px">배송 및 교환/반품 안내</strong>
      <div style="margin-bottom:14px">
        <strong style="color:var(--text-main)">배송 안내</strong><br>
        · 오후 1시 이전 주문 건에 한해 당일 출고됩니다.<br>
        · 출고일로부터 평균 1~2일 소요됩니다.<br>
        · 5만원 이상 구매 시 무료배송, 미만 시 배송비 3,000원이 부과됩니다.
      </div>
      <div>
        <strong style="color:var(--text-main)">교환/반품 안내</strong><br>
        · 제품 하자가 있을 경우 수령 후 7일 이내 교환/반품이 가능합니다.<br>
        · 제품 포장 훼손 및 사용된 제품은 교환/반품이 불가능합니다.<br>
        · 단순 변심으로 인한 반품은 왕복 배송비가 발생할 수 있습니다.
      </div>
    </div>
  </div>

  <%-- 지윤 26.07.07 수정: 평점/막대그래프/리뷰카드 하드코딩 -> TB_REVIEW 실데이터로 변경 --%>
<div class="tab-section" id="tab-review">
    <div class="review-summary">
      <div class="review-avg">
        <div class="big">${product.avgRating}</div>
        <div class="review-stars">
          <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
        </div>
        <small>${product.reviewCount}개 리뷰</small>
      </div>
      <div class="review-bars">
        <div class="review-bar-row"><span>5점</span><div class="review-bar-bg"><div class="review-bar-fill" style="width:${product.rating5Percent}%"></div></div><span>${product.rating5Percent}%</span></div>
        <div class="review-bar-row"><span>4점</span><div class="review-bar-bg"><div class="review-bar-fill" style="width:${product.rating4Percent}%"></div></div><span>${product.rating4Percent}%</span></div>
        <div class="review-bar-row"><span>3점</span><div class="review-bar-bg"><div class="review-bar-fill" style="width:${product.rating3Percent}%"></div></div><span>${product.rating3Percent}%</span></div>
        <div class="review-bar-row"><span>2점</span><div class="review-bar-bg"><div class="review-bar-fill" style="width:${product.rating2Percent}%"></div></div><span>${product.rating2Percent}%</span></div>
        <div class="review-bar-row"><span>1점</span><div class="review-bar-bg"><div class="review-bar-fill" style="width:${product.rating1Percent}%"></div></div><span>${product.rating1Percent}%</span></div>
      </div>
    </div>
    <c:if test="${empty product.reviewList}">
      <div style="text-align:center;padding:60px 0;color:var(--text-muted)">아직 등록된 리뷰가 없습니다.</div>
    </c:if>

    <div id="reviewList">
    <c:forEach var="rv" items="${product.reviewList}">
      <div class="review-card" data-review-id="${rv.reviewId}">
        <div class="review-card-head">
          <span class="reviewer">${rv.nickname} <c:forEach begin="1" end="${rv.rating}">⭐</c:forEach></span>
          <span style="display:flex; align-items:center; gap:10px;">
            <span class="review-date"><fmt:formatDate value="${rv.regDate}" pattern="yyyy.MM.dd"/></span>
            <%-- 지윤 26.07.21 추가: 본인 리뷰 삭제 --%>
            <c:if test="${not empty sessionScope.memberInfo && sessionScope.memberInfo.memberNo == rv.memberNo}">
              <button type="button" class="btnDeleteReview" data-review-id="${rv.reviewId}" style="border:none; background:none; color:var(--text-muted); font-size:12px; cursor:pointer; text-decoration:underline;">삭제</button>
            </c:if>
          </span>
        </div>
        <c:choose>
          <c:when test="${rv.blinded}">
            <div class="review-text" style="color:var(--text-muted);font-style:italic">삭제 검토 중인 리뷰입니다.</div>
          </c:when>
          <c:otherwise>
            <div class="review-text">${rv.content}</div>
            <%-- 지윤 26.07.23 추가: 리뷰 첨부 이미지 --%>
            <c:if test="${not empty rv.imageUrls}">
              <div style="display:flex; gap:8px; margin-top:10px; flex-wrap:wrap;">
                <c:forEach var="imgUrl" items="${rv.imageUrls}">
                  <img src="${contextPath}/upload/${imgUrl}" style="width:80px; height:80px; object-fit:cover; border-radius:8px; border:1px solid var(--border); cursor:pointer;" onclick="window.open('${contextPath}/upload/${imgUrl}', '_blank')">
                </c:forEach>
              </div>
            </c:if>
            <c:if test="${not empty rv.bizReply}">
              <div class="review-biz-reply">
                <b style="color:#1F8464">사장님 답글</b>
                <div class="review-biz-reply-text"><c:out value="${rv.bizReply}"/></div>
              </div>
            </c:if>
            <%-- 지윤 26.07.21 추가: 리뷰 신고 - 로그인했고 본인 리뷰가 아닐 때만 노출 --%>
            <c:if test="${not empty sessionScope.memberInfo && sessionScope.memberInfo.memberNo != rv.memberNo}">
              <button type="button" class="review-report-btn" onclick="reportReview(${rv.reviewId})">신고</button>
            </c:if>
          </c:otherwise>
        </c:choose>
      </div>
    </c:forEach>
    </div>
    
  </div>

 <%-- 지윤 26.07.10 수정: 문의 등록(AJAX) 기능 추가 --%>
<div class="tab-section" id="tab-qna">
    <div style="display:flex; gap:8px; margin-bottom:20px;">
      <c:if test="${not empty product.optionList}">
        <select id="qnaOptionSelect" style="border:1px solid var(--border); border-radius:var(--radius-sm); padding:10px 12px; font-size:13px; color:var(--text-sub); max-width:160px;">
          <option value="">옵션 선택(선택)</option>
          <c:forEach var="opt" items="${product.optionList}">
            <option value="${opt.optionId}"><c:if test="${not empty opt.optionColor && opt.optionColor != '기본'}">${opt.optionColor} / </c:if>${opt.optionSize}</option>
          </c:forEach>
        </select>
      </c:if>
      <input type="text" id="qnaInput" maxlength="500" placeholder="상품에 대해 궁금한 점을 문의해보세요" style="flex:1; border:1px solid var(--border); border-radius:var(--radius-sm); padding:10px 14px; font-size:14px; outline:none;">
      <button type="button" id="btnAddQna" style="padding:10px 20px; border:1px solid var(--primary); border-radius:var(--radius-sm); background:#fff; color:var(--primary); font-size:14px; font-weight:600; cursor:pointer; white-space:nowrap;">문의하기</button>
    </div>

    <div id="qnaEmptyMsg" style="text-align:center;padding:60px 0;color:var(--text-muted); ${empty product.qnaList ? '' : 'display:none;'}">아직 등록된 문의가 없습니다.</div>
    <div id="qnaList">
    <c:forEach var="qna" items="${product.qnaList}">

    
      <%-- 지윤 26.07.12 수정: data-qna-id 부여, 본인 글 + 답변 미완료 건에만 삭제 버튼 노출 --%>
      <div class="review-card" data-qna-id="${qna.qnaId}">
        <div class="review-card-head">
          <span class="reviewer">Q. ${qna.nickname}</span>
          <span style="display:flex; align-items:center; gap:10px;">
            <span class="review-date">${qna.regDate}</span>
            <c:if test="${not empty sessionScope.memberInfo && sessionScope.memberInfo.memberNo == qna.memberNo && empty qna.answer}">
              <button type="button" class="btnDeleteQna" data-qna-id="${qna.qnaId}" style="border:none; background:none; color:var(--text-muted); font-size:12px; cursor:pointer; text-decoration:underline;">삭제</button>
            </c:if>
          </span>
        </div>
        <div class="review-text">${qna.question}</div>
        <c:if test="${not empty qna.answer}">
          <div style="margin-top:10px; padding:12px; background:var(--bg-page); border-radius:var(--radius-sm); font-size:13px; color:var(--text-sub);">
            <strong style="color:var(--primary-dark);">A.</strong> ${qna.answer}
          </div>
        </c:if>

      <c:if test="${empty qna.answer}">
          <div style="margin-top:10px; font-size:12px; color:var(--text-muted);">답변 대기중입니다.</div>
        </c:if>
      </div>
    </c:forEach>
    </div>
</div>

</div>

<script>
function switchImg(el, src) {
  document.getElementById('mainImg').src = src;
  document.querySelectorAll('.detail-thumb').forEach(t => t.classList.remove('active'));
  el.classList.add('active');
}
// 지윤 26.07.07 수정: 판매가 하드코딩 -> product.salePrice 실데이터로 변경
// 99개 고정 제한 -> 선택된 옵션의 실제 재고(data-stock) 기준으로 변경 
function getSelectedStock() {
  const sel = document.getElementById('optionSelect');
  if (!sel || sel.options.length === 0) return 99;
  return parseInt(sel.options[sel.selectedIndex].dataset.stock) || 0;
}
//지윤 26.07.15 추가: 옵션 안 고른 상태에서 장바구니/바로구매 누르면 막기
function isOptionSelected() {
  const sel = document.getElementById('optionSelect');
  if (!sel || sel.options.length === 0) return true;
  return sel.options[sel.selectedIndex].value !== '';
}
//지윤 26.07.14 추가: 경고문구 초기화 헬퍼
function hideQtyMessages() {
  document.getElementById('stockWarning').style.display = 'none';
  document.getElementById('qtyLimitMsg').style.display = 'none';
}
function changeQty(d) {
  const inp = document.getElementById('qty');
  let v = parseInt(inp.value) + d;
  v = applyQtyLimit(v);
  inp.value = v;
  updateTotal();
}
//지윤 26.07.14 추가: 직접 타이핑 가능하게 바뀌면서, 입력값 검증하는 함수 분리
function validateQty() {
  const inp = document.getElementById('qty');
  let v = parseInt(inp.value);
  if (isNaN(v)) v = 1;
  v = applyQtyLimit(v);
  inp.value = v;
  updateTotal();

}
//지윤 26.07.14 수정: 999 상한 로직 제거, 재고 초과 시 "재고 OO개까지만 구매 가능"으로 안내
function applyQtyLimit(v) {
  hideQtyMessages();
  const stock = getSelectedStock();

  if (v < 1) {
    v = 1;
    document.getElementById('qtyLimitMsg').textContent = '1개 이상부터 구매할 수 있는 상품입니다.';
    document.getElementById('qtyLimitMsg').style.display = 'block';
  } else if (v > stock) {
    v = stock;
    document.getElementById('stockWarning').textContent = '재고 ' + stock + '개까지만 구매할 수 있습니다.';
    document.getElementById('stockWarning').style.display = 'block';
  }
  return v;
}
function onOptionChange() {
  document.getElementById('qty').value = 1;
  hideQtyMessages();
  updateTotal();
}
//지윤 26.07.14 추가: 직접 입력 후 포커스를 벗어나는 순간(blur) 검증 실행
document.getElementById('qty').addEventListener('blur', validateQty);
//지윤 26.07.14 추가: 타이핑하는 즉시 숫자 외 문자(글자, 음수기호, 소수점 등) 제거
document.getElementById('qty').addEventListener('input', function () {
  this.value = this.value.replace(/[^0-9]/g, '');
});
function updateTotal() {
  const sel = document.getElementById('optionSelect');
  const selected = sel && sel.options.length > 0 ? sel.options[sel.selectedIndex] : null;
  //지윤 26.07.15 추가: 옵션 안 고른 상태(안내문구가 선택된 상태)면 0원으로 표시
  if (selected && selected.value === '') {
    document.getElementById('totalPrice').textContent = '0원';
    return;
  }
  const addPrice = selected ? (parseInt(selected.value) || 0) : 0;
  const qty = parseInt(document.getElementById('qty').value);
  const total = (${product.salePrice} + addPrice) * qty;
  document.getElementById('totalPrice').textContent = total.toLocaleString() + '원';
}
//지윤 26.07.07 추가: 페이지 로드 시 총 결제금액 한 번 계산
updateTotal();

function showTab(id, btn) {
  document.querySelectorAll('.tab-section').forEach(s => s.classList.remove('on'));
  document.querySelectorAll('.detail-tab').forEach(b => b.classList.remove('on'));
  document.getElementById('tab-' + id).classList.add('on');
  btn.classList.add('on');
}

//지윤 26.07.21 추가: 리뷰 신고 (AJAX) - 신고 사유는 선택 입력, 이미 신고했으면 안내만
function reportReview(reviewId) {
  if (!confirm('이 리뷰를 신고하시겠습니까?')) return;
  var reason = prompt('신고 사유를 입력해주세요 (선택)') || '';
  //HYJ 26.08.05
  csrfFetch('${contextPath}/store/review/report', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: 'reviewId=' + encodeURIComponent(reviewId) + '&reason=' + encodeURIComponent(reason)
  })
    .then(function (res) { return res.text(); })
    .then(function (result) {
      if (result === 'LOGIN_REQUIRED') {
        if (confirm('로그인이 필요한 서비스입니다. 로그인 페이지로 이동하시겠습니까?')) {
          location.href = '${contextPath}/login';
        }
      } else if (result === 'ALREADY') {
        alert('이미 신고한 리뷰입니다.');
      } else {
        alert('신고가 접수되었습니다.');
      }
    });
}

//지윤 26.07.21 추가: 본인 리뷰 삭제 (평점 요약 갱신을 위해 성공 시 새로고침)
document.getElementById('reviewList').addEventListener('click', function (e) {
  var btn = e.target.closest('.btnDeleteReview');
  if (!btn) return;
  if (!confirm('작성한 리뷰를 삭제하시겠습니까?')) return;
  var reviewId = btn.dataset.reviewId;
  //HYJ 26.08.05
  csrfFetch('${contextPath}/store/review/delete', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: 'reviewId=' + encodeURIComponent(reviewId)
  })
    .then(function (res) { return res.text(); })
    .then(function (result) {
      if (result === 'OK') {
        location.reload();
      } else if (result === 'LOGIN_REQUIRED') {
        alert('로그인이 필요합니다.');
        location.href = '${contextPath}/login';
      } else {
        alert('리뷰 삭제에 실패했습니다.');
      }
    });
});

//지윤 26.07.09 수정: 로그인 안 했으면 AJAX 요청 전에 confirm으로 로그인페이지 이동 여부부터 물어봄
document.getElementById('btnAddCart').addEventListener('click', function () {
  var isLoggedIn = ${not empty sessionScope.memberInfo};
  if (!isLoggedIn) {
    if (confirm('로그인이 필요한 서비스입니다. 로그인 페이지로 이동하시겠습니까?')) {
      location.href = '${contextPath}/login';
    }
    return;
  }
   //지윤 26.07.15 추가: 옵션 안 고르면 담기 막음
  if (!isOptionSelected()) {
    alert('옵션을 선택해주세요.');
    return;
  }
  
  var sel = document.getElementById('optionSelect');
  var optionId = (sel && sel.options.length > 0) ? sel.options[sel.selectedIndex].dataset.optionId : '';
  var addPrice = (sel && sel.options.length > 0) ? (parseInt(sel.value) || 0) : 0;
  var qty = parseInt(document.getElementById('qty').value);
  var price = ${product.salePrice} + addPrice;

  //HYJ 26.08.05
  csrfFetch('${contextPath}/store/cart/add', {
    method: 'POST',
    headers: {'Content-Type':'application/x-www-form-urlencoded'},
    body: 'productId=${product.productId}&optionId=' + optionId + '&qty=' + qty + '&price=' + price
  }).then(function(res){
    if (res.ok) {
      refreshCartCount();
      if (confirm('장바구니에 담았습니다. 장바구니로 이동하시겠습니까?')) {
        location.href = '${contextPath}/store/cart';
      }
    } else {
      alert('장바구니 담기에 실패했습니다.');
    }
  });
});

//지윤 26.07.08 추가: 바로구매 -> 주문서 페이지로 바로 이동 (장바구니 거치지 않음)
document.getElementById('btnBuyNow').addEventListener('click', function () {
 //지윤 26.07.15 추가: 옵션 안 고르면 이동 막음
  if (!isOptionSelected()) {
    alert('옵션을 선택해주세요.');
    return;
  }

  var sel = document.getElementById('optionSelect');
  var optionId = (sel && sel.options.length > 0) ? sel.options[sel.selectedIndex].dataset.optionId : '';
  var qty = parseInt(document.getElementById('qty').value);
  location.href = '${contextPath}/store/order'
    + '?productId=${product.productId}'
    + '&optionId=' + optionId
    + '&qty=' + qty;
});

//지윤 26.07.10 수정: 등록 성공 시 새로고침 없이 화면에 바로 질문 추가
//지윤 26.07.12 수정: 응답이 "OK:qnaId" 형식으로 바뀜에 따라 파싱 로직 추가, 새 카드에도 삭제버튼 부여
document.getElementById('btnAddQna').addEventListener('click', function () {
  var isLoggedIn = ${not empty sessionScope.memberInfo};
  if (!isLoggedIn) {
    if (confirm('로그인이 필요한 서비스입니다. 로그인 페이지로 이동하시겠습니까?')) {
      location.href = '${contextPath}/login';
    }
    return;
  }
  var input = document.getElementById('qnaInput');
  var question = input.value.trim();
  if (question === '') {
    alert('문의 내용을 입력해주세요.');
    return;
  }
  var optionSelectEl = document.getElementById('qnaOptionSelect');
  var qnaOptionId = optionSelectEl ? optionSelectEl.value : '';
  //HYJ 26.08.05
  csrfFetch('${contextPath}/store/qna/add', {
    method: 'POST',
    headers: {'Content-Type':'application/x-www-form-urlencoded'},
    body: 'productId=${product.productId}&question=' + encodeURIComponent(question) + '&optionId=' + encodeURIComponent(qnaOptionId)
  }).then(function(res){ return res.text(); })
    .then(function(result){
      if (result.indexOf('OK:') === 0) {
        var newQnaId = result.substring(3);
        var myNickname = '${sessionScope.memberInfo.nickname}';
        var today = new Date();
        var dateStr = today.getFullYear() + '-' + String(today.getMonth()+1).padStart(2,'0') + '-' + String(today.getDate()).padStart(2,'0');

        document.getElementById('qnaEmptyMsg').style.display = 'none';

        var newCard = document.createElement('div');
        newCard.className = 'review-card';
        newCard.dataset.qnaId = newQnaId;
        newCard.innerHTML =
          '<div class="review-card-head">' +
            '<span class="reviewer">Q. ' + myNickname + '</span>' +
            '<span style="display:flex; align-items:center; gap:10px;">' +
              '<span class="review-date">' + dateStr + '</span>' +
              '<button type="button" class="btnDeleteQna" data-qna-id="' + newQnaId + '" style="border:none; background:none; color:var(--text-muted); font-size:12px; cursor:pointer; text-decoration:underline;">삭제</button>' +
            '</span>' +
          '</div>' +
          '<div class="review-text"></div>' +
          '<div style="margin-top:10px; font-size:12px; color:var(--text-muted);">답변 대기중입니다.</div>';
        newCard.querySelector('.review-text').textContent = question;

        document.getElementById('qnaList').prepend(newCard);
        input.value = '';
      } else if (result === 'LOGIN_REQUIRED') {
        alert('로그인이 필요합니다.');
        location.href = '${contextPath}/login';
      } else {
        alert('문의 등록에 실패했습니다.');
      }
    });
});

//지윤 26.07.12 상품 Q&A 삭제: 기존 글/새로 추가된 글 모두 처리되도록 qnaList에 이벤트 위임
document.getElementById('qnaList').addEventListener('click', function (e) {
  var btn = e.target.closest('.btnDeleteQna');
  if (!btn) return;
  if (!confirm('문의를 삭제하시겠습니까?')) return;
  var qnaId = btn.dataset.qnaId;
  //HYJ 26.08.05
  csrfFetch('${contextPath}/store/qna/delete', {
    method: 'POST',
    headers: {'Content-Type':'application/x-www-form-urlencoded'},
    body: 'qnaId=' + qnaId
  }).then(function(res){ return res.text(); })
    .then(function(result){
      if (result === 'OK') {
        var card = document.querySelector('#qnaList [data-qna-id="' + qnaId + '"]');
        if (card) card.remove();
        if (document.getElementById('qnaList').children.length === 0) {
          document.getElementById('qnaEmptyMsg').style.display = '';
        }
      } else if (result === 'LOGIN_REQUIRED') {
        alert('로그인이 필요합니다.');
        location.href = '${contextPath}/login';
      } else if (result === 'FAILED') {
        alert('답변이 이미 등록된 문의는 삭제할 수 없습니다.');
      } else {
        alert('삭제에 실패했습니다.');
      }
    });
});
</script>


<%@ include file="/WEB-INF/views/common/footer.jsp" %>
