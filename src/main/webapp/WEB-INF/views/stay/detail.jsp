<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="stay" />
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
  .sd-wrap { max-width: var(--inner-width); margin: 32px auto 80px; padding: 0 20px; }
  .sd-hero { display: grid; grid-template-columns: 1fr 320px; gap: 28px; align-items: start; margin-bottom: 22px; }
  .sd-main { min-width: 0; }
  .sd-back { display:inline-flex; align-items:center; gap:6px; font-size:13px; color:var(--text-muted); text-decoration:none; margin-bottom:18px; transition:var(--transition); }
  .sd-back:hover { color: var(--primary); }
  .sd-back svg { width:14px; height:14px; stroke:currentColor; fill:none; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; }
  .sd-gallery { display:grid; grid-template-columns:2fr 1fr 1fr; grid-template-rows:1fr 1fr; gap:6px; border-radius:var(--radius-md); overflow:hidden; height:360px; max-height:360px; }
  .sd-gallery img { width:100%; height:100%; object-fit:cover; display:block; min-height:0; }
  .sd-gallery img:first-child { grid-row: span 2; }
  .sd-gallery--empty { display:flex; align-items:center; justify-content:center; background:var(--bg-page); border:1px dashed var(--border); color:var(--text-muted); font-size:14px; font-weight:600; }
  .sd-badge { display:inline-block; font-size:12px; font-weight:700; padding:4px 12px; border-radius:20px; background:var(--primary-light); color:var(--primary-dark); margin-bottom:10px; }
  .sd-title { font-size:26px; font-weight:800; color:var(--text-main); margin-bottom:10px; line-height:1.3; }
  .sd-loc { display:flex; align-items:center; gap:5px; font-size:14px; color:var(--text-muted); margin-bottom:14px; }
  .sd-loc svg { width:14px; height:14px; stroke:currentColor; fill:none; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; }
  .sd-rating { display:flex; align-items:center; gap:8px; font-size:14px; color:var(--text-main); font-weight:700; margin-bottom:14px; }
  .sd-rating svg { width:15px; height:15px; fill:var(--yellow); }
  .sd-tags { display:flex; gap:7px; flex-wrap:wrap; margin-bottom:20px; }
  .sd-tag { font-size:12px; font-weight:600; padding:5px 12px; border-radius:20px; background:var(--bg-page); border:1px solid var(--border); color:var(--text-sub); }
  .sd-section { background:var(--bg-card); border:1px solid var(--border); border-radius:var(--radius-md); padding:20px; margin-bottom:16px; }
  .sd-section h3 { font-size:15px; font-weight:800; color:var(--text-main); margin:0 0 14px; display:flex; align-items:center; gap:8px; }
  .sd-section h3 svg { width:16px; height:16px; stroke:var(--primary); fill:none; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; }
  .sd-info-grid { display:grid; grid-template-columns:1fr 1fr; gap:10px; }
  .sd-info-row { background:var(--bg-page); border-radius:var(--radius-sm); padding:12px 14px; }
  .sd-info-row label { font-size:11px; color:var(--text-muted); font-weight:600; display:block; margin-bottom:3px; }
  .sd-info-row span { font-size:14px; font-weight:600; color:var(--text-main); }
  .sd-desc { font-size:14px; color:var(--text-sub); line-height:1.8; margin:0; }
  .sd-rule-list { display:flex; flex-direction:column; gap:8px; }
  .sd-rule-item { display:flex; align-items:flex-start; gap:10px; font-size:13px; color:var(--text-sub); }
  .sd-rule-item svg { width:15px; height:15px; flex-shrink:0; margin-top:1px; stroke-linecap:round; stroke-linejoin:round; }
  .sd-rule-item.ok svg { stroke:#16A34A; fill:none; stroke-width:2; }
  .sd-rule-item.no svg { stroke:#DC2626; fill:none; stroke-width:2; }
  .room-card { display:flex; justify-content:space-between; align-items:center; padding:16px; background:var(--bg-page); border-radius:var(--radius-sm); margin-bottom:8px; }
  .room-name { font-size:15px; font-weight:700; color:var(--text-main); }
  .room-meta { font-size:12px; color:var(--text-muted); margin-top:4px; }
  .room-price { font-size:17px; font-weight:800; color:var(--primary-dark); }
  .room-price-label { font-size:11px; color:var(--text-muted); }
  .review-summary { display:flex; gap:28px; align-items:center; background:var(--bg-page); border-radius:var(--radius-sm); padding:20px; margin-bottom:18px; }
  .rv-avg .big { font-size:44px; font-weight:800; color:var(--text-main); line-height:1; }
  .rv-avg small { font-size:13px; color:var(--text-muted); }
  .rv-stars { display:flex; gap:3px; margin:6px 0; }
  .rv-stars svg { width:16px; height:16px; fill:var(--yellow); }
  .rv-bars { flex:1; display:flex; flex-direction:column; gap:5px; }
  .rv-bar-row { display:flex; align-items:center; gap:8px; font-size:12px; color:var(--text-muted); }
  .rv-bar-bg { flex:1; height:5px; background:var(--border); border-radius:3px; overflow:hidden; }
  .rv-bar-fill { height:100%; background:var(--yellow); border-radius:3px; }
  .review-card { border:1px solid var(--border); border-radius:var(--radius-sm); padding:16px; margin-bottom:12px; overflow:hidden; min-width:0; }
  .rv-head { display:flex; justify-content:space-between; align-items:center; margin-bottom:8px; }
  .rv-name { font-size:14px; font-weight:700; color:var(--text-main); }
  .rv-date { font-size:12px; color:var(--text-muted); }
  .rv-text { font-size:14px; color:var(--text-sub); line-height:1.6; word-break:break-word; overflow-wrap:anywhere; }
  /* 2026/08/12 장우철 — 사업자 답글 긴 문자열 줄바꿈 */
  .rv-biz-reply { margin-top:10px; padding:10px 14px; background:var(--bg-page); border-radius:8px; font-size:13px; color:var(--text-sub); max-width:100%; box-sizing:border-box; overflow-wrap:anywhere; word-break:break-word; }
  .rv-biz-reply-label { font-weight:700; color:var(--primary-dark); display:block; margin-bottom:4px; }
  .rv-biz-reply-text { white-space:pre-wrap; line-height:1.6; overflow-wrap:anywhere; word-break:break-word; }
  .reserve-card { background:var(--bg-card); border:1px solid var(--border); border-radius:var(--radius-md); padding:22px; position:sticky; top:20px; }
  .reserve-card h3 { font-size:16px; font-weight:800; color:var(--text-main); margin:0 0 16px; }
  .rc-price { font-size:22px; font-weight:800; color:var(--text-main); margin-bottom:16px; }
  .rc-price span { font-size:13px; font-weight:400; color:var(--text-muted); }
  .rc-divider { height:1px; background:var(--border); margin:14px 0; }
  .btn-reserve-big { width:100%; padding:14px; border:none; border-radius:var(--radius-sm); background:var(--primary); color:#fff; font-size:16px; font-weight:800; cursor:pointer; margin-top:12px; transition:var(--transition); }
  .btn-reserve-big:hover { background:var(--primary-dark); }
  .btn-reserve-big:disabled { background:var(--border); cursor:not-allowed; }
  .rc-notice { font-size:12px; color:var(--text-muted); margin-top:10px; line-height:1.6; }
  .rc-date-group { display:flex; flex-direction:column; gap:5px; margin-bottom:10px; }
  .rc-date-group label { font-size:12px; font-weight:600; color:var(--text-muted); }
  .rc-date-group input { border:1px solid var(--border); border-radius:var(--radius-sm); padding:9px 12px; font-size:13px; color:var(--text-main); width:100%; box-sizing:border-box; outline:none; }
  .rc-date-group input:focus { border-color:var(--primary); }
  .rc-date-row { display:grid; grid-template-columns:1fr 1fr; gap:8px; margin-bottom:14px; }
  .rc-avail-msg { padding:8px 12px; border-radius:6px; font-size:12px; font-weight:600; margin-bottom:10px; }
  .rc-avail-msg.ok { background:#F0FDF4; border:1px solid #BBF7D0; color:#16A34A; }
  .rc-avail-msg.no { background:#FEF2F2; border:1px solid #FECACA; color:#DC2626; }
  .rc-avail-msg.loading { background:var(--bg-page); border:1px solid var(--border); color:var(--text-muted); }
  .room-card.unavailable { opacity:0.5; pointer-events:none; }
  .room-card .room-avail { font-size:11px; font-weight:600; margin-top:3px; }
  .room-card .room-avail.ok { color:#16A34A; }
  .room-card .room-avail.no { color:#DC2626; }
  .room-card.selectable { cursor:pointer; border:2px solid transparent; transition:.2s; }
  .room-card.selectable:hover { border-color:var(--primary); }
  .room-card.selectable.selected { border-color:var(--primary); background:var(--primary-light); }
</style>

<div style="max-width:var(--inner-width);margin:28px auto 0;padding:0 20px">
  <a href="${contextPath}/stay" class="sd-back">
    <svg viewBox="0 0 24 24"><path d="M19 12H5"/><polyline points="12 19 5 12 12 5"/></svg>
    숙소 목록으로
  </a>
</div>

<c:if test="${empty stay}">
  <div style="max-width:var(--inner-width);margin:60px auto;text-align:center;color:var(--text-muted)">
    <p style="font-size:18px;font-weight:700;">숙소 정보를 찾을 수 없습니다.</p>
    <a href="${contextPath}/stay" style="color:var(--primary)">목록으로 돌아가기</a>
  </div>
</c:if>

<c:if test="${not empty stay}">
<div class="sd-wrap">
  <%-- 상단: 사진 + 숙박예약 (한 줄) --%>
  <div class="sd-hero">
    <c:choose>
      <c:when test="${not empty imgList}">
        <div class="sd-gallery">
          <c:forEach var="img" items="${imgList}" begin="0" end="4">
            <img src="${contextPath}/upload/${img.fileUrl}" alt="${stay.name}">
          </c:forEach>
        </div>
      </c:when>
      <c:otherwise>
        <div class="sd-gallery sd-gallery--empty">등록된 숙소 사진이 없습니다</div>
      </c:otherwise>
    </c:choose>

    <%-- 예약 카드 (사진 영역 우측) --%>
    <div class="reserve-card">
      <h3>숙박 예약</h3>

      <div class="rc-date-row">
        <div class="rc-date-group">
          <label>체크인</label>
          <input type="date" id="rcCheckin" onchange="onDateChange()">
        </div>
        <div class="rc-date-group">
          <label>체크아웃</label>
          <input type="date" id="rcCheckout" onchange="onDateChange()">
        </div>
      </div>

      <div id="rcAvailMsg"></div>

      <c:choose>
        <c:when test="${not empty stay.rooms}">
          <c:forEach var="room" items="${stay.rooms}">
            <div class="room-card" id="room-${room.roomId}" style="margin-bottom:10px"
                 data-room-id="${room.roomId}" data-price="${room.pricePerNight}">
              <div>
                <div class="room-name">${room.name}</div>
                <div class="room-meta">수용 ${room.capacity}인 · 반려동물 ${room.petLimit}마리</div>
                <div class="room-avail" id="roomAvail-${room.roomId}"></div>
              </div>
              <div style="text-align:right">
                <div class="room-price"><fmt:formatNumber value="${room.pricePerNight}" pattern="#,###"/>원</div>
                <div class="room-price-label">1박 기준</div>
              </div>
            </div>
          </c:forEach>
        </c:when>
        <c:otherwise>
          <p style="font-size:14px;color:var(--text-muted);margin:0 0 12px">등록된 객실이 없습니다.</p>
        </c:otherwise>
      </c:choose>

      <div class="rc-divider"></div>

      <div id="rcPriceSummary" style="margin-bottom:12px;display:none">
        <div style="display:flex;justify-content:space-between;font-size:13px;color:var(--text-muted);margin-bottom:6px">
          <span id="rcPriceDetail"></span>
        </div>
        <div style="display:flex;justify-content:space-between;font-size:18px;font-weight:800;color:var(--text-main)">
          <span>합계</span>
          <span id="rcTotalPrice" style="color:var(--primary-dark)"></span>
        </div>
      </div>

      <button class="btn-reserve-big" id="btnReserve" disabled
              onclick="goReserve()">날짜와 객실을 선택하세요</button>

      <c:choose>
        <c:when test="${not empty stay.refundPolicy}">
          <div class="rc-notice" style="white-space:pre-line">${stay.refundPolicy}</div>
        </c:when>
        <c:otherwise>
          <div class="rc-notice">입실일 기준 취소수수료가 적용됩니다. (10일 전 전액 환불 ~ 당일 90%)</div>
        </c:otherwise>
      </c:choose>
    </div>
  </div>

  <%-- 하단: 숙소 정보 전체 너비 --%>
  <div class="sd-main">
    <span class="sd-badge">반려동물 동반 숙소</span>
    <div class="sd-title">${stay.name}</div>
    <div class="sd-loc">
      <svg viewBox="0 0 24 24"><path d="M21 10c0 7-9 13-9 13S3 17 3 10a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/></svg>
      ${stay.addr}
    </div>
    <div class="sd-rating">
      <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
      <%-- 2026-07-28 박유정 — TB_STAY.AVG_RATING / REVIEW_CNT (병원 detail.jsp와 동일) --%>
      <c:choose>
        <c:when test="${not empty stay.avgRating}">
          <fmt:formatNumber value="${stay.avgRating}" pattern="0.0"/>
        </c:when>
        <c:otherwise>0.0</c:otherwise>
      </c:choose>
      <span style="font-size:13px;color:var(--text-muted);font-weight:400">
        (<c:out value="${empty stay.reviewCnt ? 0 : stay.reviewCnt}"/>개 리뷰)
      </span>
    </div>
    <%-- 편의시설 태그 --%>
    <c:if test="${not empty stay.facilities}">
      <div class="sd-tags">
        <c:forEach var="fac" items="${fn:split(stay.facilities, ',')}">
          <c:if test="${fac == 'PETYARD'}"><span class="sd-tag">애견 놀이터</span></c:if>
          <c:if test="${fac == 'PETPOOL'}"><span class="sd-tag">애견 수영장</span></c:if>
          <c:if test="${fac == 'PETAMENITY'}"><span class="sd-tag">펫 어메니티 제공</span></c:if>
          <c:if test="${fac == 'AGILITY'}"><span class="sd-tag">어질리티 체험</span></c:if>
          <c:if test="${fac == 'CCTV'}"><span class="sd-tag">CCTV</span></c:if>
          <c:if test="${fac == 'LARGEPET'}"><span class="sd-tag">대형견 가능</span></c:if>
        </c:forEach>
      </div>
    </c:if>

    <%-- 기본 정보 — 전부 DB에서 --%>
    <div class="sd-section">
      <h3><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>기본 정보</h3>
      <div class="sd-info-grid">
        <div class="sd-info-row"><label>주소</label><span>${stay.addr}</span></div>
        <div class="sd-info-row"><label>운영 시간</label><span>체크인 ${stay.checkIn} / 체크아웃 ${stay.checkOut}</span></div>
        <c:if test="${not empty stay.rooms}">
          <div class="sd-info-row"><label>수용 인원</label><span>객실별 최대 ${stay.rooms[0].capacity}인</span></div>
        </c:if>
        <c:if test="${not empty stay.petPolicy}">
          <div class="sd-info-row"><label>반려동물 조건</label><span>${stay.petPolicy}</span></div>
        </c:if>
        <c:if test="${stay.petFee != null && stay.petFee > 0}">
          <div class="sd-info-row"><label>추가 요금</label>
            <span>추가 1마리당 <fmt:formatNumber value="${stay.petFee}" pattern="#,###"/>원 / 박</span>
          </div>
        </c:if>
      </div>
    </div>

    <%-- 공간 소개 --%>
    <c:if test="${not empty stay.description}">
      <div class="sd-section">
        <h3><svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>공간 소개</h3>
        <p class="sd-desc">${stay.description}</p>
      </div>
    </c:if>

    <%-- 객실 정보 --%>
    <c:if test="${not empty stay.rooms}">
      <div class="sd-section">
        <h3><svg viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>객실 정보 (${fn:length(stay.rooms)}개)</h3>
        <c:forEach var="room" items="${stay.rooms}">
          <div class="room-card">
            <div>
              <div class="room-name">${room.name}</div>
              <div class="room-meta">수용 ${room.capacity}인 · 반려동물 ${room.petLimit}마리</div>
            </div>
            <div style="text-align:right">
              <div class="room-price"><fmt:formatNumber value="${room.pricePerNight}" pattern="#,###"/>원</div>
              <div class="room-price-label">1박 기준</div>
            </div>
          </div>
        </c:forEach>
      </div>
    </c:if>

    <%-- 환불 정책 — 2026/08/11 장우철: 플랫폼 고정 문구 --%>
    <c:if test="${not empty stay.refundPolicy}">
      <div class="sd-section">
        <h3><svg viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>환불 / 이용 규칙</h3>
        <p class="sd-desc" style="white-space:pre-line">${stay.refundPolicy}</p>
      </div>
    </c:if>

    <%-- 위치 --%>
    <c:if test="${not empty stay.lat}">
      <div class="sd-section">
        <h3><svg viewBox="0 0 24 24"><path d="M21 10c0 7-9 13-9 13S3 17 3 10a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/></svg>위치</h3>
        <div id="kakao-map" style="width:100%;height:280px;border-radius:12px;overflow:hidden"></div>
        <%@ include file="/WEB-INF/views/common/kakaomap.jsp" %>
      </div>
    </c:if>

    <%-- HYJ 26.07.20 리뷰 (DB 연동) --%>
    <div class="sd-section">
      <h3><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>리뷰 (<c:out value="${empty stay.reviewCnt ? 0 : stay.reviewCnt}"/>)</h3>
      <c:if test="${not empty stay.avgRating and stay.reviewCnt != null and stay.reviewCnt > 0}">
        <div class="review-summary">
          <div class="rv-avg">
            <div class="big"><fmt:formatNumber value="${stay.avgRating}" pattern="0.0"/></div>
            <div class="rv-stars">
              <c:forEach begin="1" end="5"><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg></c:forEach>
            </div>
            <small><c:out value="${stay.reviewCnt}"/>개 리뷰</small>
          </div>
        </div>
      </c:if>
      <c:if test="${empty reviewList}">
        <p style="font-size:14px;color:var(--text-muted);padding:12px 0">아직 등록된 리뷰가 없습니다.</p>
      </c:if>
      <c:forEach var="rv" items="${reviewList}">
        <div class="review-card">
          <div class="rv-head">
            <span class="rv-name">
              <c:out value="${empty rv.nickname ? '회원' : rv.nickname}"/>
              <c:if test="${not empty rv.petName}">
                <span style="color:var(--text-muted);font-size:12px;font-weight:400"> · <c:out value="${rv.petName}"/>
                  <c:if test="${not empty rv.petSpecies}"> (<c:out value="${rv.petSpecies}"/>)</c:if>
                </span>
              </c:if>
            </span>
            <span class="rv-date"><fmt:formatDate value="${rv.regDate}" pattern="yyyy.MM.dd"/></span>
          </div>
          <div style="display:flex;gap:2px;margin-bottom:6px">
            <c:forEach begin="1" end="5" var="s">
              <svg viewBox="0 0 24 24" style="width:14px;height:14px;fill:${s <= rv.rating ? 'var(--yellow)' : 'var(--border)'}"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
            </c:forEach>
          </div>
          <div class="rv-text"><c:out value="${rv.content}"/></div>
          <c:if test="${not empty rv.bizReply}">
            <div class="rv-biz-reply">
              <span class="rv-biz-reply-label">사업자 답변</span>
              <div class="rv-biz-reply-text"><c:out value="${rv.bizReply}"/></div>
            </div>
          </c:if>
        </div>
      </c:forEach>
    </div>
  </div>
</div>
</c:if>

<script>
var stayId = '${stay.stayId}';
var contextPath = '${contextPath}';
var selectedRoomId = null;
var selectedPrice = 0;

(function() {
    var today = new Date().toISOString().split('T')[0];
    document.getElementById('rcCheckin').min = today;
    document.getElementById('rcCheckout').min = today;
})();

function onDateChange() {
    var ci = document.getElementById('rcCheckin').value;
    var co = document.getElementById('rcCheckout').value;

    // 체크인 선택 시 체크아웃 min을 체크인 다음날로
    if (ci) {
        var nextDay = new Date(ci);
        nextDay.setDate(nextDay.getDate() + 1);
        document.getElementById('rcCheckout').min = nextDay.toISOString().split('T')[0];

        // 체크아웃이 체크인보다 이전이면 초기화
        if (co && co <= ci) {
            document.getElementById('rcCheckout').value = '';
            co = '';
        }
    }

    // 선택 초기화
    selectedRoomId = null;
    selectedPrice = 0;
    updatePriceSummary();

    if (!ci || !co) {
        resetRoomCards();
        document.getElementById('rcAvailMsg').innerHTML = '';
        return;
    }

    // 날짜 유효성
    var nights = Math.round((new Date(co) - new Date(ci)) / 86400000);
    if (nights <= 0) {
        document.getElementById('rcAvailMsg').innerHTML =
            '<div class="rc-avail-msg no">체크아웃은 체크인 이후여야 합니다.</div>';
        resetRoomCards();
        return;
    }

    // 각 객실별 가용성 체크
    document.getElementById('rcAvailMsg').innerHTML =
        '<div class="rc-avail-msg loading">예약 가능 여부 확인 중...</div>';

    var roomCards = document.querySelectorAll('.room-card[data-room-id]');
    var checkCount = 0;
    var totalCount = roomCards.length;
    var anyAvailable = false;

    for (var i = 0; i < roomCards.length; i++) {
        (function(card) {
            var roomId = card.dataset.roomId;
            var availDiv = document.getElementById('roomAvail-' + roomId);

            card.classList.remove('selectable', 'selected', 'unavailable');
            card.onclick = null;
            availDiv.textContent = '';

            var xhr = new XMLHttpRequest();
            xhr.open('GET', contextPath + '/stay/checkAvailability'
                + '?roomId=' + roomId
                + '&checkinDate=' + ci
                + '&checkoutDate=' + co);
            xhr.onload = function() {
                var res = JSON.parse(xhr.responseText);
                checkCount++;

                if (res.available) {
                    anyAvailable = true;
                    card.classList.remove('unavailable');
                    card.classList.add('selectable');
                    availDiv.textContent = '예약 가능';
                    availDiv.className = 'room-avail ok';
                    card.onclick = function() { selectRoom(card); };
                } else {
                    card.classList.add('unavailable');
                    card.classList.remove('selectable');
                    availDiv.textContent = '예약 마감';
                    availDiv.className = 'room-avail no';
                }

                // 모든 체크 완료
                if (checkCount === totalCount) {
                    if (anyAvailable) {
                        document.getElementById('rcAvailMsg').innerHTML =
                            '<div class="rc-avail-msg ok">예약 가능한 객실을 선택하세요.</div>';
                    } else {
                        document.getElementById('rcAvailMsg').innerHTML =
                            '<div class="rc-avail-msg no">선택한 날짜에 예약 가능한 객실이 없습니다.</div>';
                    }
                }
            };
            xhr.send();
        })(roomCards[i]);
    }
}

function resetRoomCards() {
    var cards = document.querySelectorAll('.room-card[data-room-id]');
    for (var i = 0; i < cards.length; i++) {
        cards[i].classList.remove('selectable', 'selected', 'unavailable');
        cards[i].onclick = null;
        var availDiv = document.getElementById('roomAvail-' + cards[i].dataset.roomId);
        if (availDiv) { availDiv.textContent = ''; availDiv.className = 'room-avail'; }
    }
    document.getElementById('btnReserve').disabled = true;
    document.getElementById('btnReserve').textContent = '날짜와 객실을 선택하세요';
}

function selectRoom(card) {
    // 기존 선택 해제
    var cards = document.querySelectorAll('.room-card.selectable');
    for (var i = 0; i < cards.length; i++) { cards[i].classList.remove('selected'); }

    card.classList.add('selected');
    selectedRoomId = card.dataset.roomId;
    selectedPrice = Number(card.dataset.price);
    updatePriceSummary();
}

function updatePriceSummary() {
    var ci = document.getElementById('rcCheckin').value;
    var co = document.getElementById('rcCheckout').value;
    var summary = document.getElementById('rcPriceSummary');
    var btn = document.getElementById('btnReserve');

    if (!selectedRoomId || !ci || !co) {
        summary.style.display = 'none';
        btn.disabled = true;
        btn.textContent = '날짜와 객실을 선택하세요';
        return;
    }

    var nights = Math.round((new Date(co) - new Date(ci)) / 86400000);
    var total = selectedPrice * nights;

    document.getElementById('rcPriceDetail').textContent =
        selectedPrice.toLocaleString() + '원 × ' + nights + '박';
    document.getElementById('rcTotalPrice').textContent =
        total.toLocaleString() + '원';
    summary.style.display = 'block';

    btn.disabled = false;
    btn.textContent = total.toLocaleString() + '원 예약하기';
}

function goReserve() {
    var ci = document.getElementById('rcCheckin').value;
    var co = document.getElementById('rcCheckout').value;
    location.href = contextPath + '/stay/reserve?id=' + stayId
        + '&roomId=' + selectedRoomId
        + '&checkinDate=' + ci
        + '&checkoutDate=' + co;
}
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
