<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="mypage" />
<c:set var="sec" value="orders" />

<%@ include file="/WEB-INF/views/common/header.jsp" %>
<link rel="stylesheet" href="${contextPath}/resources/css/mypage.css">

<div class="mypage-wrap">
<%@ include file="/WEB-INF/views/mypage/sidebar.jsp" %>
<div class="mypage-content">

<%-- 지윤 26.07.20 수정: 하드코딩된 주문카드 3개 -> 실데이터 연동
     Controller: MypageOrderController.orders()
     Service: MypageOrderService.getOrderList()
     화면 레이아웃(카드 구조, CSS 클래스)은 원본 그대로 유지, 데이터 표시 로직만 실데이터로 교체 --%>
<div class="mp-section active">
    <h2 class="mp-title">주문내역</h2>
    <p class="mp-desc">최근 6개월 주문 내역입니다.</p>

    <%-- 지윤 26.07.20 수정: onclick="필터버튼 active 클래스만 토글" (실제 필터링 안 됨, 장식만 있던 버튼)
         -> <a href="?statusCd=..."> 실제 GET 요청으로 서버에서 필터링 --%>
    <div class="order-filter">
        <a href="${contextPath}/mypage/orders" class="filter-btn ${empty selectedStatusCd ? 'on' : ''}">전체</a>
        <a href="${contextPath}/mypage/orders?statusCd=READY" class="filter-btn ${selectedStatusCd == 'READY' ? 'on' : ''}">배송준비</a>
        <a href="${contextPath}/mypage/orders?statusCd=SHIPPING" class="filter-btn ${selectedStatusCd == 'SHIPPING' ? 'on' : ''}">배송중</a>
        <a href="${contextPath}/mypage/orders?statusCd=DONE" class="filter-btn ${selectedStatusCd == 'DONE' ? 'on' : ''}">배송완료</a>
        <a href="${contextPath}/mypage/orders?statusCd=CANCEL" class="filter-btn ${selectedStatusCd == 'CANCEL' ? 'on' : ''}">취소/환불</a>
    </div>

    <%-- 지윤 26.07.20 수정: 주문 카드 1/2/3 하드코딩 -> <c:forEach>로 ${orderList} 실데이터 반복 렌더링 --%>
    <c:choose>
        <c:when test="${empty orderList}">
            <p class="mp-empty" style="padding:40px 0;text-align:center;color:var(--text-muted)">주문 내역이 없습니다.</p>
        </c:when>
        <c:otherwise>
            <%-- 지윤 26.07.30 수정: 사업자별로 쪼개진 여러 TB_ORDER가 같은 결제(orderGroupId)면 카드 하나로 묶어서 보여줌.
                 카드 안에서는 사업자(주문)별로 order-subgroup으로 다시 나눠, 상태뱃지/상세보기/액션버튼은 그 사업자 주문 기준 그대로 유지 --%>
            <c:forEach var="o" items="${orderList}" varStatus="ovs">
                <c:if test="${ovs.first || o.orderGroupId != orderList[ovs.index-1].orderGroupId}">
                <div class="order-card">
                    <div class="order-card-head">
                        <span>${o.orderDate} 주문 <strong>#${o.orderNo}</strong></span>
                        <%-- 지윤 26.07.30 수정: 사업자별로 쪼개져도 유저 입장에선 "결제 1건"이라, 주문번호/상세보기는 카드당 하나만 표시.
                             어느 사업자 주문의 orderId를 넘겨도 상세페이지에서 같은 결제그룹 전체를 묶어서 보여줌 --%>
                        <a href="${contextPath}/mypage/orders/detail?orderId=${o.orderId}" style="font-size:13px;color:var(--text-muted);text-decoration:none">주문상세보기 &gt;</a>
                    </div>
                </c:if>

                    <div class="order-subgroup">
                    <div class="order-subhead">
                        <span><c:out value="${o.bizName}"/></span>
                        <div style="display:flex;align-items:center;gap:10px">
                            <%-- 2026/08/13 장우철 — #7 환불완료/부분환불 뱃지 --%>
                            <%@ include file="/WEB-INF/views/mypage/orders-status-badge.jsp" %>
                        </div>
                    </div>

                    <%-- 지윤 26.07.20 수정: <div class="order-item"> 각 상품 블록을 <c:forEach>로 ${o.itemList} 반복 렌더링
                         지윤 26.07.20 수정: 교환/반품·리뷰작성·재구매를 카드 하단(주문 단위) -> 이 상품 줄 안(상품 단위)으로 이동.
                         한 주문에 상품이 여러 개면 상품마다 리뷰/재구매 대상이 다르기 때문 --%>
                    <c:forEach var="it" items="${o.itemList}">
                        <div class="order-item">
                            <%-- 지윤 26.07.20 수정: unsplash 고정 이미지 URL -> 실제 상품 썸네일 (로컬업로드/외부URL 둘 다 지원하는 store 모듈 공통 패턴) --%>
                            <%-- 2026/08/18 장우철 — FILE_URL이 /upload/ 포함이어도 경로가 겹치지 않게 --%>
                            <c:choose>
                                <c:when test="${not empty it.thumbnailUrl}">
                                    <c:choose>
                                      <c:when test="${fn:startsWith(it.thumbnailUrl, 'http')}">
                                        <c:set var="orderThumbSrc" value="${it.thumbnailUrl}" />
                                      </c:when>
                                      <c:when test="${fn:startsWith(it.thumbnailUrl, '/')}">
                                        <c:set var="orderThumbSrc" value="${contextPath}${it.thumbnailUrl}" />
                                      </c:when>
                                      <c:otherwise>
                                        <c:set var="orderThumbSrc" value="${contextPath}/upload/${it.thumbnailUrl}" />
                                      </c:otherwise>
                                    </c:choose>
                                    <img class="order-thumb"
                                         src="${orderThumbSrc}"
                                         alt="${it.productName}"
                                         onerror="this.src='https://placehold.co/72x72/EAF7F2/2BAB82?text=IMG'">
                                </c:when>
                                <c:otherwise>
                                    <img class="order-thumb" src="https://placehold.co/72x72/EAF7F2/2BAB82?text=IMG" alt="${it.productName}">
                                </c:otherwise>
                            </c:choose>
                            <div class="order-info">
                                <div class="name">${it.productName}</div>
                                <%-- 지윤 26.07.20 수정: "수량 1개 · 옵션: 기본" 고정 문구 -> 실제 수량 + 옵션(기본이면 생략, products.jsp와 동일 컨벤션) --%>
                                <div class="meta">
                                    수량 ${it.qty}개
                                    <c:if test="${not empty it.optionSize}">
                                        · 옵션: <c:if test="${not empty it.optionColor && it.optionColor != '기본'}">${it.optionColor} / </c:if>${it.optionSize}
                                    </c:if>
                                </div>
                            </div>
                            <div class="order-price" style="${o.orderStatus == 'CANCEL' ? 'text-decoration:line-through;color:var(--text-muted)' : ''}">
                                <fmt:formatNumber value="${it.totalPrice}" pattern="#,###"/>원
                            </div>
                        </div>
                       <div class="order-item-actions" style="display:flex;justify-content:flex-end;gap:8px;padding:0 0 14px">
                       <%-- 지윤 26.07.29 수정: 카드 하단(order-card-foot)에 있던 배송조회 버튼을 교환/반품·재구매랑 같은 줄로 이동 --%>
                       <c:if test="${o.orderStatus == 'SHIPPING' || o.orderStatus == 'DONE'}">
                       <button class="btn-sm" onclick="trackDelivery(${o.orderId}, '${o.courierCode}', '${o.trackingNo}')">배송조회</button>
                        </c:if>
                       <%-- 2026/08/04 장우철 — 상품단위: 미확정 + 송장 이후만 환불 (주문 전체 확정과 무관) --%>
                       <c:if test="${(o.orderStatus == 'SHIPPING' || o.orderStatus == 'DONE') && empty it.confirmedAt}">
                         <c:choose>
                           <c:when test="${it.returnStatusCd == 'REQUESTED'}">
                             <button class="btn-sm" disabled>환불신청중</button>
                           </c:when>
                           <c:when test="${it.returnStatusCd == 'RETURNING'}">
                             <button class="btn-sm" disabled>환불진행중</button>
                           </c:when>
                           <c:when test="${it.returnStatusCd == 'DONE'}">
                             <button class="btn-sm" disabled>환불완료</button>
                           </c:when>
                           <c:otherwise>
                             <button class="btn-sm danger"
                                     onclick="location.href='${contextPath}/mypage/orders/refund?orderItemId=${it.orderItemId}'">환불</button>
                           </c:otherwise>
                         </c:choose>
                       </c:if>
                       <c:if test="${o.orderStatus == 'DONE'}">
                                <%-- 2026/08/13 장우철 — 리뷰는 해당 상품 구매확정 후에만 (환불신청/진행/완료는 확정 불가) --%>
                                <c:if test="${not empty it.confirmedAt}">
                                <c:choose>
                                    <c:when test="${it.reviewed}">
                                        <button class="btn-sm" disabled>리뷰완료</button>
                                    </c:when>
                                    <c:otherwise>
                                        <button class="btn-sm" onclick="openReviewModal(${it.orderItemId}, '${fn:escapeXml(it.productName)}', '${fn:escapeXml(it.thumbnailUrl)}', '${fn:escapeXml(it.optionColor)}', '${fn:escapeXml(it.optionSize)}')">리뷰작성</button>
                                    </c:otherwise>
                                </c:choose>
                                </c:if>
                                <button class="btn-sm" onclick="location.href='${contextPath}/store/detail?id=${it.productId}'">재구매</button>
                            </c:if>
                        </div>
                    </c:forEach>

                   <%-- 지윤 26.07.20 수정: "배송조회"/"환불내역"은 상품별이 아니라 주문(배송) 전체에 대한 액션이라 카드 하단에 유지.
                         "교환/반품"/"리뷰작성"/"재구매"는 위 상품 줄 안으로 옮김 --%>
                    <c:if test="${o.orderStatus == 'SHIPPING' || o.orderStatus == 'CANCEL' || o.orderStatus == 'DONE'}">
                        <div class="order-card-foot">
                        <%-- 지윤 26.07.29 수정: 배송조회 버튼은 order-item-actions(상품 줄)로 이동함, 여기선 제거 --%>
                            <c:if test="${o.orderStatus == 'CANCEL'}">
                                <button class="btn-sm" onclick="alert('환불내역 기능은 준비 중입니다.')">환불내역</button>
                            </c:if>
                            <%-- 지윤 26.07.23 추가: 구매확정 버튼 --%>
                            <%-- 2026/08/04 장우철 — 부분 확정: 환불중 아닌 미확정 상품이 있으면 확정 가능 --%>
                            <c:if test="${o.orderStatus == 'DONE'}">
                                <c:set var="hasConfirmable" value="false" />
                                <c:set var="hasConfirmed" value="false" />
                                <c:forEach var="it2" items="${o.itemList}">
                                  <c:if test="${not empty it2.confirmedAt}">
                                    <c:set var="hasConfirmed" value="true" />
                                  </c:if>
                                  <c:if test="${empty it2.confirmedAt
                                      && it2.returnStatusCd != 'REQUESTED'
                                      && it2.returnStatusCd != 'RETURNING'
                                      && it2.returnStatusCd != 'DONE'}">
                                    <c:set var="hasConfirmable" value="true" />
                                  </c:if>
                                </c:forEach>
                                <c:choose>
                                    <c:when test="${hasConfirmable}">
                                        <form method="post" action="${contextPath}/mypage/orders/confirm" style="display:inline" onsubmit="return confirm('구매확정 하시겠습니까?\n환불 진행 중인 상품은 제외되고, 나머지 상품 금액 기준으로 적립됩니다.')">
                                            <!--HYJ 26.08.05-->
                                            <input type="hidden" name="_csrf" value="${_csrf}">
                                            
                                            <input type="hidden" name="orderId" value="${o.orderId}">
                                            <button type="submit" class="btn-confirm-purchase">🎁 구매확정하고 적립받기</button>
                                        </form>
                                    </c:when>
                                    <c:when test="${hasConfirmed || o.confirmYn == 'Y'}">
                                        <span class="confirm-done-badge">✓ 구매확정 완료</span>
                                    </c:when>
                                </c:choose>
                            </c:if>
                        </div>
                    </c:if>
                    </div>

                <c:if test="${ovs.last || o.orderGroupId != orderList[ovs.index+1].orderGroupId}">
                </div>
                </c:if>
            </c:forEach>
        </c:otherwise>
    </c:choose>
</div>

<%-- 지윤 26.07.20 수정: 모달 내용이 빈약하다는 피드백 반영 - 상품 썸네일/옵션 표시, 별점 라벨, 글자수 카운터, 사진첨부(최대 5장) 추가
     hidden form + JS로 값 복사하던 방식 -> 모달 자체를 multipart/form-data form으로 바꿔서 그대로 submit --%>
<div id="reviewModalBg" class="review-modal-bg" style="display:none">
  <form id="reviewForm" class="review-modal" method="post" action="${contextPath}/mypage/orders/review"
        enctype="multipart/form-data" onsubmit="return validateReviewForm()">
    <!--HYJ 26.08.05-->
    <input type="hidden" name="_csrf" value="${_csrf}">
    
    <button type="button" class="review-modal-close" onclick="closeReviewModal()">✕</button>
    <h3>⭐ 리뷰 작성</h3>

    <input type="hidden" name="orderItemId" id="reviewFormOrderItemId">

    <div class="review-modal-product-row">
      <img id="reviewModalThumb" src="" alt="" onerror="this.src='https://placehold.co/56x56/EAF7F2/2BAB82?text=IMG'">
      <div>
        <p id="reviewModalProductName" class="review-modal-product-name"></p>
        <p id="reviewModalOption" class="review-modal-option"></p>
      </div>
    </div>

    <div class="review-modal-stars" id="reviewModalStars">
      <span data-v="1">★</span><span data-v="2">★</span><span data-v="3">★</span><span data-v="4">★</span><span data-v="5">★</span>
    </div>
    <p id="reviewModalRatingLabel" class="review-modal-rating-label">별점을 선택해주세요</p>
    <input type="hidden" name="rating" id="reviewFormRating">

    <textarea name="content" id="reviewModalContent" maxlength="500"
          placeholder="상품은 어떠셨나요? 다른 분들에게 도움이 되는 후기를 남겨주세요."
          oninput="onReviewContentInput(this)"></textarea>
<div class="review-modal-counter"><span id="reviewCharCount">0</span>/500 <small style="color:var(--text-muted)">(50자 이상 작성 시 500P, 사진 첨부 시 1000P 적립)</small></div>
<%-- 지윤 26.07.28 추가: 10자 미만일 때만 뜨는 실시간 경고 문구 --%>
<div id="reviewMinLengthWarn" style="display:none; color:#E24B4A; font-size:12px; margin-top:4px;">최소 10자 이상 입력해 주세요.</div>

    <div class="review-modal-photo-section">
      <p class="review-modal-photo-label">사진 첨부 <span>(선택, 최대 5장)</span></p>
      <label class="review-modal-photo-add">
        <input type="file" name="images" id="reviewPhotoInput" accept="image/*" multiple onchange="handlePhotoSelect(this)">
        <span class="review-modal-photo-plus">+</span>
        <span id="reviewPhotoHint">사진 선택</span>
      </label>
      <div class="review-modal-photo-preview" id="reviewPhotoPreview"></div>
    </div>

    <div class="review-modal-actions">
      <button type="button" class="btn-sm" onclick="closeReviewModal()">취소</button>
      <button type="submit" class="btn-sm primary">등록</button>
    </div>
  </form>
</div>

<%-- 지윤 26.07.29 추가: 배송조회 결과 모달 (사업자센터 배송관리와 동일한 방식, 화면만 구매자용으로 간단하게) --%>
<div id="trackModalBg" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.45); z-index:999; align-items:center; justify-content:center;">
  <div style="background:#fff; border-radius:16px; padding:24px; max-width:480px; width:90%; max-height:80vh; overflow-y:auto;">
    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:16px;">
      <strong style="font-size:16px;">실시간 배송조회</strong>
      <button type="button" onclick="closeTrackModal()" style="border:none; background:none; font-size:20px; cursor:pointer; color:#999;">&times;</button>
    </div>
    <div id="trackModalBody"></div>
  </div>
</div>

<script>
  //지윤 26.07.29 추가: 배송조회 fetch 호출에 필요한 contextPath JS 변수 선언 (누락되어 있었음)
  var contextPath = '${contextPath}';

  //지윤 26.07.20 수정: 모달이 곧 form이라 hidden form 복사 로직 삭제, submit 직전 검증만 남김
  var reviewRating = 0;

  function openReviewModal(orderItemId, productName, thumbnailUrl, optionColor, optionSize) {
    document.getElementById('reviewFormOrderItemId').value = orderItemId;
    document.getElementById('reviewModalProductName').textContent = productName;

    var optText = '';
    if (optionSize && optionSize !== 'undefined' && optionSize !== '') {
      optText = '옵션: ' + ((optionColor && optionColor !== '기본' && optionColor !== 'undefined') ? optionColor + ' / ' : '') + optionSize;
    }
    document.getElementById('reviewModalOption').textContent = optText;

    var thumb = document.getElementById('reviewModalThumb');
    var src = '';
    if (thumbnailUrl && thumbnailUrl !== 'undefined' && thumbnailUrl !== '') {
      if (thumbnailUrl.indexOf('http://') === 0 || thumbnailUrl.indexOf('https://') === 0) src = thumbnailUrl;
      else if (thumbnailUrl.charAt(0) === '/') src = contextPath + thumbnailUrl;
      else src = contextPath + '/upload/' + thumbnailUrl;
    }
    thumb.src = src || 'https://placehold.co/56x56/EAF7F2/2BAB82?text=IMG';

    document.getElementById('reviewModalContent').value = '';
    document.getElementById('reviewCharCount').textContent = '0';
    document.getElementById('reviewMinLengthWarn').style.display = 'none';
    document.getElementById('reviewPhotoInput').value = '';
    document.getElementById('reviewPhotoPreview').innerHTML = '';
    document.getElementById('reviewPhotoHint').textContent = '사진 선택';
    setStars(0);
    document.getElementById('reviewModalBg').style.display = 'flex';
  }

  function closeReviewModal() {
    document.getElementById('reviewModalBg').style.display = 'none';
  }

  var ratingLabels = ['별점을 선택해주세요', '아쉬워요', '별로예요', '보통이에요', '좋아요', '최고예요!'];

  function setStars(v) {
    reviewRating = v;
    document.getElementById('reviewFormRating').value = v;
    document.getElementById('reviewModalRatingLabel').textContent = ratingLabels[v];
    document.querySelectorAll('#reviewModalStars span').forEach(function (s) {
      s.classList.toggle('on', Number(s.dataset.v) <= v);
    });
  }

  document.querySelectorAll('#reviewModalStars span').forEach(function (s) {
    s.addEventListener('click', function () { setStars(Number(s.dataset.v)); });
  });

  //지윤 26.07.20 추가: 사진 선택 시 썸네일 미리보기 (최대 5장, 넘으면 경고만 하고 그대로 진행)
  function handlePhotoSelect(input) {
    var files = Array.from(input.files || []);
    if (files.length > 5) { alert('사진은 최대 5장까지 첨부할 수 있어요.'); }
    document.getElementById('reviewPhotoHint').textContent = files.length + '장 선택됨';

    var preview = document.getElementById('reviewPhotoPreview');
    preview.innerHTML = '';
    files.slice(0, 5).forEach(function (file) {
      var reader = new FileReader();
      reader.onload = function (e) {
        var img = document.createElement('img');
        img.src = e.target.result;
        preview.appendChild(img);
      };
      reader.readAsDataURL(file);
    });
  }

  function onReviewContentInput(el) {
    document.getElementById('reviewCharCount').textContent = el.value.length;
    //지윤 26.07.28 추가: 10자 미만일 때만 실시간으로 빨간 경고문구 표시
    document.getElementById('reviewMinLengthWarn').style.display = (el.value.trim().length < 10) ? 'block' : 'none';
  }

  function validateReviewForm() {
    if (reviewRating === 0) { alert('별점을 선택해주세요.'); return false; }
    var content = document.getElementById('reviewModalContent').value.trim();
    if (!content) { alert('리뷰 내용을 입력해주세요.'); return false; }
    //지윤 26.07.28 수정: 10자 미만이면 제출 자체를 막음 (이미 입력창 아래 빨간 문구로 안내되고 있어서 별도 alert 없음)
    if (content.length < 10) { return false; }
    //지윤 26.07.28 추가: 10~49자면 포인트 미지급 대상임을 confirm 팝업으로 안내, 확인해야만 제출 진행
    if (content.length < 50) {
      return confirm('50자 미만이라 포인트 지급 대상이 아닙니다.\n이대로 진행하시겠습니까?');
    }
    return true;
  }

  //지윤 26.07.29 추가: 마이페이지 배송조회 - 사업자센터 delivery.jsp와 동일한 패턴 (levelLabel 매핑, 조회결과 표시)
  var levelLabel = { 1: '배송준비중', 2: '집화완료', 3: '배송중', 4: '지점도착', 5: '배송출발', 6: '배송완료' };

  function trackDelivery(orderId, courierCode, trackingNo) {
    document.getElementById('trackModalBody').innerHTML = '<p style="text-align:center;color:#999;padding:20px 0">조회 중...</p>';
    document.getElementById('trackModalBg').style.display = 'flex';

    fetch(contextPath + '/mypage/orders/track?orderId=' + orderId + '&courierCode=' + encodeURIComponent(courierCode) + '&trackingNo=' + encodeURIComponent(trackingNo))
      .then(function (res) { return res.json(); })
      .then(function (data) {
        var box = document.getElementById('trackModalBody');
        if (!data || data.status === false || data.result === 'N') {
          box.innerHTML = '<p style="color:#E24B4A">배송 정보를 조회할 수 없습니다. (' + (data && data.msg ? data.msg : '알 수 없는 운송장번호') + ')</p>';
          return;
        }

        var html = '<p style="font-weight:700;font-size:15px;margin-bottom:12px">현재 상태: ' + (levelLabel[data.level] || data.level) + '</p>';
        if (data.trackingDetails && data.trackingDetails.length > 0) {
          html += '<table style="width:100%;border-collapse:collapse;font-size:13px"><thead><tr style="border-bottom:1px solid #E4E6ED"><th style="text-align:left;padding:8px 4px">시각</th><th style="text-align:left;padding:8px 4px">위치</th><th style="text-align:left;padding:8px 4px">처리내용</th></tr></thead><tbody>';
          data.trackingDetails.forEach(function (d) {
            html += '<tr style="border-bottom:1px solid #F0F2F0"><td style="padding:8px 4px">' + (d.timeString || '-') + '</td><td style="padding:8px 4px">' + (d.where || '-') + '</td><td style="padding:8px 4px">' + (d.kind || '-') + '</td></tr>';
          });
          html += '</tbody></table>';
        } else {
          html += '<p style="color:#999">아직 상세 배송 이력이 없습니다. 택배사가 상품을 인수하면 표시됩니다.</p>';
        }
        box.innerHTML = html;
      })
      .catch(function () {
        document.getElementById('trackModalBody').innerHTML = '<p style="color:#E24B4A">조회 중 오류가 발생했습니다.</p>';
      });
  }

  function closeTrackModal() {
    document.getElementById('trackModalBg').style.display = 'none';
  }
</script>

<%-- 지윤 26.07.20 삭제: <script> 안에 있던 filter-btn 클릭 시 active 클래스만 토글하던 JS -
     이제 필터 버튼 자체가 실제 <a href="?statusCd=..."> 링크라서 페이지 이동만으로 처리, JS 불필요해짐 --%>

</div><%-- /mypage-content --%>
</div><%-- /mypage-wrap --%>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>