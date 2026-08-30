<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="반려동물 쇼핑몰" />
<c:set var="bizPage"      value="products" />

<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_store.jsp" %>

<%-- 지윤 26.07.15 수정: 하드코딩(JS mock 배열) -> 실데이터 연동. 등록/수정은 모달로 처리, 옵션별 재고 지원 --%>
<style>
  .biz-modal-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,.4);z-index:9999;align-items:center;justify-content:center}
  .biz-modal-overlay.on{display:flex}
  .biz-modal{background:#fff;border-radius:12px;padding:24px 24px 16px;max-height:88vh;overflow-y:auto}
  
  #prodForm .biz-form-fields > .biz-form-row{margin-bottom:18px}
  #prodForm .biz-form-row label{display:block;margin-bottom:6px;font-size:13px;font-weight:600;color:#333}
  #prodForm .biz-form-row input,
  #prodForm .biz-form-row select,
  #prodForm .biz-form-row textarea{width:100%;box-sizing:border-box}
  .opt-row{background:#FAFBFA}
  .opt-row > div{row-gap:14px}

  .prod-filter{display:flex;flex-wrap:wrap;align-items:center;gap:10px;padding:18px 20px}
  .prod-filter select,.prod-filter input{border:1px solid var(--biz-border);border-radius:8px;padding:8px 10px;font-size:13px;color:#333}
  .prod-filter input[type="text"]{width:220px}
  .prod-filter .btn-search{background:var(--biz-primary);color:#fff;border:none;border-radius:8px;padding:9px 18px;font-size:13px;font-weight:700;cursor:pointer}
  .prod-filter .btn-reset{background:#fff;border:1px solid var(--biz-border);border-radius:8px;padding:9px 16px;font-size:13px;font-weight:600;color:#555;cursor:pointer}
  .prod-table-head{display:flex;align-items:center;justify-content:space-between;padding:0 20px}
  .prod-table-head .right{display:flex;align-items:center;gap:8px}
  .prod-sort{border:1px solid var(--biz-border);border-radius:8px;padding:7px 10px;font-size:12px;color:#555}
  .prod-thumb{width:52px;height:52px;border-radius:6px;object-fit:cover;display:block;background:#F5F6F4}
  .prod-cat{display:inline-block;font-size:11px;color:#666;background:#F0F2EE;border-radius:20px;padding:2px 10px;margin-bottom:3px}
  .prod-price .orig{display:block;font-size:11px;color:#bbb;text-decoration:line-through}
  .prod-price .sale{font-weight:700;color:#1A1A2E}
  .prod-price .discount{color:#E24B4A;font-size:11px;font-weight:700;margin-right:4px}
  .prod-pagination{display:flex;align-items:center;justify-content:center;gap:6px;padding:16px 0 20px}
  .prod-pagination button{width:28px;height:28px;border:1px solid var(--biz-border);background:#fff;border-radius:6px;cursor:pointer;font-size:12px;color:#555}
  .prod-pagination button.active{background:var(--biz-primary);border-color:var(--biz-primary);color:#fff;font-weight:700}
  .prod-pagination button:disabled{opacity:.4;cursor:default}
  .prod-form-actions{display:flex;justify-content:center;gap:10px;margin-top:22px}
  .prod-form-actions .biz-btn-primary{min-width:180px}
  .prod-price-row{display:flex;gap:16px}
  .prod-price-row .biz-form-row{flex:1}
</style>

<main class="biz-main">
  <div class="biz-page-head">
    <h1 class="biz-page-title">상품 관리</h1>
    <p class="biz-page-desc">판매할 상품을 등록·수정하세요.</p>
  </div>

  <div class="biz-card" style="margin-bottom:16px">
    <form class="prod-filter" method="get" action="${contextPath}/biz/store/products">
      <select name="fField" disabled>
        <option value="name">상품명</option>
      </select>
      <input type="text" name="keyword" value="${selectedKeyword}" placeholder="상품명을 입력하세요.">
      <span style="font-size:13px;color:#666;margin-left:6px">카테고리</span>
      <%-- 2026/08/06 장우철: 필터는 카테고리명 1개씩(강아지/사료/시니어). 등록 모달용 categoryList와 분리 --%>
      <select name="categoryName">
        <option value="">전체</option>
        <c:forEach var="catName" items="${filterCategoryNames}">
          <option value="<c:out value='${catName}'/>" ${selectedCategoryName == catName ? 'selected' : ''}><c:out value="${catName}"/></option>
        </c:forEach>
      </select>
      <span style="font-size:13px;color:#666;margin-left:6px">상태</span>
      <select name="statusCd">
        <option value="">전체</option>
        <option value="NORMAL"  ${selectedStatusCd == 'NORMAL'  ? 'selected' : ''}>판매중</option>
        <option value="SOLDOUT" ${selectedStatusCd == 'SOLDOUT' ? 'selected' : ''}>품절</option>
        <option value="WAITING" ${selectedStatusCd == 'WAITING' ? 'selected' : ''}>입고대기</option>
        <option value="STOPPED" ${selectedStatusCd == 'STOPPED' ? 'selected' : ''}>판매중지</option>
      </select>
      <button type="submit" class="btn-search">검색</button>
      <button type="button" class="btn-reset" onclick="location.href='${contextPath}/biz/store/products'">초기화</button>
    </form>
  </div>

  <div class="biz-card" style="margin-bottom:16px">
    <div class="prod-table-head">
      <div class="biz-card-head" style="padding:20px 0 12px"><span>상품목록</span><small>총 <c:out value="${totalCount}"/>개</small></div>
      <div class="right">
        <button type="button" class="biz-btn-primary" onclick="openRegisterModal()">+ 상품등록</button>
      </div>
    </div>
    <table class="biz-table">
      <thead><tr><th>상품이미지</th><th>상품명</th><th>카테고리</th><th>옵션</th><th>판매가</th><th>재고</th><th>등록일</th><th>상태</th><th>관리</th></tr></thead>
<tbody>
<c:choose>
  <c:when test="${empty productList}">
    <tr><td colspan="9" style="text-align:center;color:#999;padding:24px 0">등록된 상품이 없습니다.</td></tr>
  </c:when>
          <c:otherwise>
            <c:forEach var="p" items="${productList}">
              <c:set var="rows" value="${empty p.optionList ? null : p.optionList}"/>
              <c:forEach var="opt" items="${rows}" varStatus="os">
                <tr>
                  <td>
                    <c:choose>
                      <c:when test="${not empty p.thumbnailUrl}">
                        <img class="prod-thumb" src="${contextPath}/upload/${p.thumbnailUrl}" alt="${p.productName}">
                      </c:when>
                      <c:otherwise>
                        <img class="prod-thumb" src="https://placehold.co/100x100/EAF7F2/2BAB82?text=No+Image" alt="${p.productName}">
                      </c:otherwise>
                    </c:choose>
                  </td>
                  <td>${p.productName}</td>
                  <td>${p.categoryName}</td>
                  <td><c:if test="${not empty opt.optionColor && opt.optionColor != '기본'}">${opt.optionColor} / </c:if>${opt.optionSize}</td>
                  
                  <%-- 지윤 26.07.15 수정: 옵션별 최종가 = 판매가 + 해당 옵션 추가금액 --%>
                  <c:set var="finalPrice" value="${p.salePrice + opt.addPrice}"/>
                  <td>
                    <div class="prod-price">
                      <c:choose>
                        <c:when test="${p.discountRate > 0}">
                          <span class="orig"><fmt:formatNumber value="${p.price + opt.addPrice}" pattern="#,###"/>원</span>
                          <span class="discount">${p.discountRate}%</span><span class="sale"><fmt:formatNumber value="${finalPrice}" pattern="#,###"/>원</span>
                        </c:when>
                        <c:otherwise>
                          <span class="sale"><fmt:formatNumber value="${finalPrice}" pattern="#,###"/>원</span>
                        </c:otherwise>
                      </c:choose>
                      <c:if test="${opt.addPrice > 0}"><small style="color:#888">(+<fmt:formatNumber value="${opt.addPrice}" pattern="#,###"/>)</small></c:if>
                    </div>
                  </td>

                  <td>${opt.stockQty}개<c:if test="${opt.stockQty == 0}"> (품절)</c:if></td>
                  <td>${p.regDate}</td>
                  <td>
                    <c:choose>
                      <c:when test="${p.statusCd == 'NORMAL'}"><span class="bs-badge bs-done">판매중</span></c:when>
                      <c:when test="${p.statusCd == 'SOLDOUT'}"><span class="bs-badge bs-cancel">품절</span></c:when>
                      <c:when test="${p.statusCd == 'WAITING'}"><span class="bs-badge bs-wait">입고대기</span></c:when>
                      <c:when test="${p.statusCd == 'STOPPED'}"><span class="bs-badge bs-empty">판매중지</span></c:when>
                      <c:otherwise><span class="bs-badge bs-empty">${p.statusCd}</span></c:otherwise>
                    </c:choose>
                  </td>
                  <td><button class="biz-btn" onclick="openEditModal(${p.productId})">수정</button></td>
                </tr>
              </c:forEach>
            </c:forEach>
          </c:otherwise>
        </c:choose>
      </tbody>
    </table>

    <%-- 2026/08/06 장우철: 필터 없을 때 pageBaseUrl에 ?가 없어 &page= 가 깨지던 문제 수정 (? / & 분기) --%>
    <%-- 2026/08/06 장우철: 카테고리 필터 파라미터 categoryId → categoryName --%>
    <c:url var="pageBaseUrl" value="/biz/store/products">
      <c:if test="${not empty selectedKeyword}"><c:param name="keyword" value="${selectedKeyword}"/></c:if>
      <c:if test="${not empty selectedCategoryName}"><c:param name="categoryName" value="${selectedCategoryName}"/></c:if>
      <c:if test="${not empty selectedStatusCd}"><c:param name="statusCd" value="${selectedStatusCd}"/></c:if>
    </c:url>
    <c:set var="pageSep" value="${fn:contains(pageBaseUrl, '?') ? '&' : '?'}"/>
    <div class="prod-pagination">
      <c:if test="${currentPage > 1}">
        <a href="${pageBaseUrl}${pageSep}page=${currentPage - 1}"><button>&lt;</button></a>
      </c:if>
      <c:forEach begin="1" end="${totalPages}" var="i">
        <a href="${pageBaseUrl}${pageSep}page=${i}"><button class="${i == currentPage ? 'active' : ''}">${i}</button></a>
      </c:forEach>
      <c:if test="${currentPage < totalPages}">
        <a href="${pageBaseUrl}${pageSep}page=${currentPage + 1}"><button>&gt;</button></a>
      </c:if>
    </div>
  </div>
</main>

<div class="biz-modal-overlay" id="prodModalOverlay">
  <div class="biz-modal" style="max-width:640px;width:92%">
    <div class="biz-card-head"><span id="modalTitle">상품등록</span></div>
    <form id="prodForm" enctype="multipart/form-data" style="padding:20px 0;max-height:70vh;overflow-y:auto">
      <div class="biz-form-fields">
        <div class="biz-form-row">
          <label>상품명<span class="req">*</span></label>
          <input type="text" name="productName" id="pName" required>
        </div>

        <div class="biz-form-row">
          <label>카테고리<span class="req">*</span></label>
          <div style="display:flex;gap:8px">
            <select id="pSpecies" style="flex:1"><option value="">동물 선택</option></select>
            <select id="pType" style="flex:1"><option value="">타입 선택</option></select>
            <select name="categoryId" id="pCategory" required style="flex:1"><option value="">나이대 선택</option></select>
          </div>
        </div>

        <div class="biz-form-row">
          <label>브랜드명</label>
          <input type="text" name="brandName" id="pBrand" placeholder="선택 입력">
        </div>
        <div class="prod-price-row">
          <div class="biz-form-row">
            <label>정가<span class="req">*</span></label>
            <input type="number" name="price" id="pPrice" required>
          </div>
          <div class="biz-form-row">
            <label>판매가(할인가)<span class="req">*</span></label>
            <input type="number" name="salePrice" id="pSalePrice" required>
          </div>
        </div>
        <div class="biz-form-row">
          <label>상태<span class="req">*</span></label>
          <select name="statusCd" id="pStatus" required>
            <option value="NORMAL">판매중</option>
            <option value="SOLDOUT">품절</option>
            <option value="WAITING">입고대기</option>
            <option value="STOPPED">판매중지</option>
          </select>
          <small id="soldoutHint" style="display:none;color:#E24B4A">옵션 재고 합계가 0이라 품절로 고정됩니다.</small>
        </div>
        
        <div class="biz-form-row">
          <label>옵션(색상/사이즈)<span class="req">*</span></label>
          <div id="optionRows"></div>
          <button type="button" class="biz-btn-ghost" onclick="addOptionRow()">+ 옵션추가</button>
        </div>
        <div class="biz-form-row">
          <label>특징 태그 <span style="color:#888;font-weight:400;font-size:12px">(쉼표로 구분, 상품 상세페이지에 뱃지로 표시됨)</span></label>
          <input type="text" name="tags" id="pTags" placeholder="예: 무료배송,중형견 적합,글루텐 프리">
        </div>
        <div class="biz-form-row">
          <label>상품설명</label>
          <textarea name="description" id="pDesc"></textarea>
        </div>

        <div class="biz-form-row">
          <label>상품이미지</label>
          <div style="display:flex;gap:10px;align-items:center">
            <input type="text" id="pImgName" placeholder="선택된 파일이 없습니다" readonly style="flex:1;background:#FAFBFA">
            <button type="button" class="biz-btn-ghost" style="white-space:nowrap" onclick="document.getElementById('pImgFile').click()">이미지 찾기</button>
            <input type="file" name="image" id="pImgFile" accept="image/*" style="display:none">
          </div>
          <div class="biz-form-image-box" id="imgPreviewBox" style="width:160px;height:160px;margin-top:10px;display:none">
            <img id="imgPreview" src="" alt="상품 이미지 미리보기">
          </div>
        </div>
      </div>
      <div class="prod-form-actions">
        <button type="button" class="biz-btn-ghost" onclick="closeModal()">취소</button>
        <button type="button" class="biz-btn-primary" id="submitBtn" onclick="submitProduct()">상품등록신청</button>
      </div>
    </form>
  </div>
</div>

<script>
  var contextPath = '${contextPath}';
  var editingId = null;

  //지윤 26.07.15 추가: 동물→타입→나이대 연동 드롭다운용 카테고리 전체 데이터 (2~4단계)
  var categoryTree = [
    <c:forEach var="cat" items="${categoryList}" varStatus="vs">
    {categoryId:${cat.categoryId}, parentId:${cat.parentId}, categoryName:'${cat.categoryName}', depth:${cat.depth}}<c:if test="${!vs.last}">,</c:if>
    </c:forEach>
  ];

  //지윤 26.07.15 추가: categoryId로 카테고리 트리에서 노드 하나 찾기
  function getCatNode(id) {
    return categoryTree.find(function(c){ return c.categoryId == id; });
  }

  //지윤 26.07.15 추가: select 박스에 옵션 리스트 채우는 공통 함수
  function fillSelect(sel, list, placeholder) {
    sel.innerHTML = '<option value="">' + placeholder + '</option>' +
      list.map(function(c){ return '<option value="' + c.categoryId + '">' + c.categoryName + '</option>'; }).join('');
  }

  //지윤 26.07.15 추가: 타입(사료/간식/용품) 선택 시 나이대 채우기.
  //나이대(4단계)가 없는 타입(용품 등)은 나이대 없이 타입 자체를 최종 카테고리로 확정 + 드롭다운 잠금
  function onTypeChange(typeId, presetAgeId) {
    var pCategory = document.getElementById('pCategory');
    var ageOptions = categoryTree.filter(function(c){ return c.depth == 4 && c.parentId == typeId; });
    if (ageOptions.length > 0) {
      fillSelect(pCategory, ageOptions, '나이대 선택');
      pCategory.disabled = false;
      if (presetAgeId) pCategory.value = presetAgeId;
    } else if (typeId) {
      var typeNode = getCatNode(typeId);
      pCategory.innerHTML = '<option value="' + typeId + '">해당없음(' + typeNode.categoryName + ')</option>';
      pCategory.value = typeId;
      pCategory.disabled = true;
    } else {
      fillSelect(pCategory, [], '나이대 선택');
    }
  }

  //지윤 26.07.15 추가: 상품등록 모달 열 때 카테고리 3단 드롭다운 초기화(전부 빈 값)
  function initCategorySelects() {
    fillSelect(document.getElementById('pSpecies'), categoryTree.filter(function(c){ return c.depth == 2; }), '동물 선택');
    fillSelect(document.getElementById('pType'), [], '타입 선택');
    fillSelect(document.getElementById('pCategory'), [], '나이대 선택');
    document.getElementById('pCategory').disabled = false;
  }

  //지윤 26.07.15 추가: 상품수정 모달 열 때 저장된 categoryId 하나로 동물/타입/나이대 3단을 역으로 채움
  //categoryId가 4단계(나이대)든 3단계(용품처럼 나이대 없는 타입)든 둘 다 처리
  function setCategorySelection(categoryId) {
    var leaf = getCatNode(categoryId);
    if (!leaf) { initCategorySelects(); return; }

    var typeId, speciesId, presetAgeId;
    if (leaf.depth == 4) {
      typeId = leaf.parentId;
      speciesId = getCatNode(typeId).parentId;
      presetAgeId = leaf.categoryId;
    } else {
      typeId = leaf.categoryId;
      speciesId = leaf.parentId;
      presetAgeId = null;
    }

    fillSelect(document.getElementById('pSpecies'), categoryTree.filter(function(c){ return c.depth == 2; }), '동물 선택');
    document.getElementById('pSpecies').value = speciesId;
    fillSelect(document.getElementById('pType'), categoryTree.filter(function(c){ return c.depth == 3 && c.parentId == speciesId; }), '타입 선택');
    document.getElementById('pType').value = typeId;
    onTypeChange(typeId, presetAgeId);
  }

  //지윤 26.07.15 추가: 동물 바뀌면 타입 목록 다시 채우고, 나이대는 초기화
  document.getElementById('pSpecies').addEventListener('change', function() {
    var speciesId = Number(this.value);
    fillSelect(document.getElementById('pType'), categoryTree.filter(function(c){ return c.depth == 3 && c.parentId == speciesId; }), '타입 선택');
    fillSelect(document.getElementById('pCategory'), [], '나이대 선택');
    document.getElementById('pCategory').disabled = false;
  });
  //지윤 26.07.15 추가: 타입 바뀌면 나이대 목록 다시 채움 (또는 용품처럼 나이대 없으면 잠금 처리)
  document.getElementById('pType').addEventListener('change', function() {
    onTypeChange(Number(this.value), null);
  });


  //지윤 26.07.15 수정: 한 줄 나열 -> 라벨 붙은 4칸 그리드로 변경, 삭제 버튼 제거
  //지윤 26.07.24 수정: optionId 파라미터 추가 (기존 옵션이면 값 있음, 새로 추가한 행이면 빈 값 -> 서버에서 이걸로 UPDATE/INSERT 구분)
  function optRowHtml(color, size, addPrice, stockQty, optionId) {
    // 2026/08/13 장우철 — 신규 옵션은 optionId 필드를 안 보냄(빈 값이 Long 변환 실패). 추가금액 기본 0
    var idInput = (optionId != null && optionId !== '')
      ? '<input type="hidden" name="optionId" value="' + optionId + '">'
      : '';
    return '<div class="opt-row" style="border:1px solid var(--biz-border);border-radius:8px;padding:14px;margin-bottom:10px">' +
      idInput +
      '<div style="display:grid;grid-template-columns:1fr 1fr;gap:16px 20px">' +
        '<div><label style="font-size:12px;color:#666;display:block;margin-bottom:4px">색상(선택)</label>' +
          '<input type="text" name="optionColor" placeholder="예: 블랙" style="width:100%" value="' + (color || '') + '"></div>' +
        '<div><label style="font-size:12px;color:#666;display:block;margin-bottom:4px">사이즈/용량<span class="req">*</span></label>' +
          '<input type="text" name="optionSize" placeholder="예: M, 4kg" style="width:100%" required value="' + (size || '') + '"></div>' +
        '<div><label style="font-size:12px;color:#666;display:block;margin-bottom:4px">추가금액</label>' +
          '<input type="number" name="addPrice" placeholder="0" min="0" style="width:100%" value="' + (addPrice != null && addPrice !== '' ? addPrice : '0') + '"></div>' +
        '<div><label style="font-size:12px;color:#666;display:block;margin-bottom:4px">재고<span class="req">*</span></label>' +
          '<input type="number" name="stockQty" placeholder="수량" style="width:100%" required value="' + (stockQty != null ? stockQty : '') + '" oninput="onStockChange()"></div>' +
      '</div>' +
    '</div>';
  }

  function addOptionRow(color, size, addPrice, stockQty, optionId) {
    var wrap = document.createElement('div');
    wrap.innerHTML = optRowHtml(color, size, addPrice, stockQty, optionId);
    document.getElementById('optionRows').appendChild(wrap.firstChild);
  }

  function onStockChange() {
    var stocks = document.querySelectorAll('input[name="stockQty"]');
    var total = 0;
    stocks.forEach(function (s) { total += Number(s.value) || 0; });
    var statusSel = document.getElementById('pStatus');
    var hint = document.getElementById('soldoutHint');
    if (total === 0) {
      statusSel.value = 'SOLDOUT';
      statusSel.disabled = true;
      hint.style.display = 'inline';
    } else {
      statusSel.disabled = false;
      hint.style.display = 'none';
      if (statusSel.value === 'SOLDOUT') statusSel.value = 'NORMAL';
    }
  }

  function openRegisterModal() {
    editingId = null;
    document.getElementById('prodForm').reset();
    document.getElementById('optionRows').innerHTML = '';
    //지윤 26.07.15 추가: 등록 모달 열 때 카테고리 3단 드롭다운 초기화
    initCategorySelects();
    addOptionRow();
    document.getElementById('imgPreviewBox').style.display = 'none';
    document.getElementById('pImgName').value = '';
    document.getElementById('pStatus').disabled = false;
    document.getElementById('modalTitle').textContent = '상품등록';
    document.getElementById('submitBtn').textContent = '상품등록신청';
    document.getElementById('prodModalOverlay').classList.add('on');
  }

  function openEditModal(id) {
    fetch(contextPath + '/biz/store/products/' + id)
      .then(function (res) { return res.json(); })
      .then(function (p) {
        editingId = id;
        document.getElementById('prodForm').reset();
        document.getElementById('pName').value = p.productName;
        setCategorySelection(p.categoryId);
        document.getElementById('pBrand').value = p.brandName || '';
        document.getElementById('pPrice').value = p.price;
        document.getElementById('pSalePrice').value = p.salePrice;
        document.getElementById('pDesc').value = p.description || '';
        document.getElementById('pTags').value = p.tags || '';
        document.getElementById('pStatus').value = p.statusCd;

        document.getElementById('optionRows').innerHTML = '';
        if (p.optionList && p.optionList.length > 0) {
          p.optionList.forEach(function (opt) {
            addOptionRow(opt.optionColor === '기본' ? '' : opt.optionColor, opt.optionSize, opt.addPrice, opt.stockQty, opt.optionId);
          });
        } else {
          addOptionRow();
        }
        onStockChange();

        document.getElementById('imgPreviewBox').style.display = p.thumbnailUrl ? 'block' : 'none';
        if (p.thumbnailUrl) document.getElementById('imgPreview').src = contextPath + '/upload/' + p.thumbnailUrl;
        document.getElementById('pImgName').value = p.thumbnailUrl ? '기존 이미지 사용중' : '';

        document.getElementById('modalTitle').textContent = '상품수정';
        document.getElementById('submitBtn').textContent = '수정완료';
        document.getElementById('prodModalOverlay').classList.add('on');
      });
  }

  function closeModal() {
    document.getElementById('prodModalOverlay').classList.remove('on');
  }

  document.getElementById('pImgFile').addEventListener('change', function (e) {
    var file = e.target.files[0];
    if (!file) return;
    document.getElementById('pImgName').value = file.name;
    var reader = new FileReader();
    reader.onload = function (ev) {
      document.getElementById('imgPreview').src = ev.target.result;
      document.getElementById('imgPreviewBox').style.display = 'block';
    };
    reader.readAsDataURL(file);
  });

 //용품 상품등록안되는거 해결 26/7/30지윤
 function submitProduct() {
    var form = document.getElementById('prodForm');
    if (!form.checkValidity()) { form.reportValidity(); return; }
    //지윤 26.07.16 추가: disabled된 상태 드롭다운은 폼에 안 실려서 제출 직전 잠깐 풀어줌
    document.getElementById('pStatus').disabled = false;
    //지윤 26.07.30 추가: pCategory도 disabled 상태면 categoryId가 통째로 안 실려서 서버에서 "파라미터 없음" 에러 남 -> 똑같이 풀어줌
    document.getElementById('pCategory').disabled = false;
    var formData = new FormData(form);
    var url = contextPath + '/biz/store/products' + (editingId ? '/' + editingId : '');
    //HYJ 26.08.05
    csrfFetch(url, { method: 'POST', body: formData })
      .then(function () { location.href = contextPath + '/biz/store/products'; });
  }
</script>

<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>
