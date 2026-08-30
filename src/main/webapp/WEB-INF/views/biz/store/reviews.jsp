<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="반려동물 쇼핑몰" />
<c:set var="bizPage"      value="reviews" />

<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_store.jsp" %>

<%-- 7/3, 사업자(쇼핑몰) 리뷰 관리 UI 구성 — 병원 reviews.jsp와 동일 구조로 재작성 --%>
<%-- 지윤 26.07.20 수정: 목업 -> 실데이터 연동. "신고관리" 탭을 "삭제요청" 탭으로 변경 (신고관리는 제외하기로 결정, 대신 사업자 삭제요청/관리자 승인 플로우로 대체) --%>
<main class="biz-main">
  <div class="biz-page-head">
    <h1 class="biz-page-title">리뷰 관리</h1>
    <p class="biz-page-desc">상품 리뷰를 확인하고 답글을 작성하세요.</p>
  </div>

  <div class="biz-card">
    <div style="padding:20px 20px 0">
      <div class="biz-tabs">
        <button type="button" class="biz-tab active" data-tab="all" onclick="switchTab('all')">전체<span class="biz-tab-count" id="cntAll"></span></button>
        <button type="button" class="biz-tab" data-tab="reported" onclick="switchTab('reported')">삭제요청<span class="biz-tab-count" id="cntReported"></span></button>
        <div class="biz-tabs-right">
          <select class="biz-select-sm" id="sortSelect" onchange="renderList()">
            <option value="latest">최신순</option>
            <option value="high">평점 높은순</option>
            <option value="low">평점 낮은순</option>
          </select>
        </div>
      </div>
    </div>

    <div class="biz-review-list" id="reviewList"></div>
  </div>
</main>

<div class="biz-toast" id="saveToast">
  <svg viewBox="0 0 24 24" fill="none" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
  답글이 등록되었습니다.
</div>

<%-- 지윤 26.07.20 추가: 답글/삭제요청은 실제 서버로 POST해야 해서 숨김 폼 2개로 처리 (fetch/AJAX 대신 그냥 submit) --%>
<form id="replyForm" method="post" action="${contextPath}/biz/store/reviews/reply" style="display:none">
  <!--HYJ 26.08.05-->
  <input type="hidden" name="_csrf" value="${_csrf}">
  
  <input type="hidden" name="reviewId" id="replyFormReviewId">
  <textarea name="bizReply" id="replyFormText"></textarea>
</form>
<form id="deleteReqForm" method="post" action="${contextPath}/biz/store/reviews/delete-request" style="display:none">
  <!--HYJ 26.08.05-->
  <input type="hidden" name="_csrf" value="${_csrf}">

  <input type="hidden" name="reviewId" id="delFormReviewId">
  <input type="hidden" name="reason" id="delFormReason">
</form>

<script>
  //지윤 26.07.22 추가: 썸네일 경로 조합용 (detail.jsp와 동일 패턴)
  var contextPath = '${contextPath}';
  //지윤 26.07.20 수정: 목업 배열 -> 컨트롤러가 내려주는 실데이터 JSON 그대로 사용
  var reviews = ${empty reviewListJson ? '[]' : reviewListJson};

  var currentTab = 'all';
  var openReplyId = null;

  function starsHtml(rating) {
    var html = '';
    for (var i = 1; i <= 5; i++) {
      html += '<svg viewBox="0 0 24 24" class="' + (i <= rating ? 'on' : 'off') + '"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>';
    }
    return html;
  }

  function switchTab(tab) {
    currentTab = tab;
    openReplyId = null;
    document.querySelectorAll('.biz-tab').forEach(function (b) { b.classList.toggle('active', b.dataset.tab === tab); });
    renderList();
  }

 function toggleReply(id) {
    openReplyId = (openReplyId === id) ? null : id;
    renderList();
  }

  //지윤 26.07.22 추가: "신고접수 N건" 뱃지 클릭 시에만 신고자 목록 보여주기 (renderList 다시 안 타므로 DOM에서 바로 토글)
  function toggleReporters(id) {
    var el = document.getElementById('reporters-' + id);
    if (el) el.style.display = (el.style.display === 'none') ? 'block' : 'none';
  }

  //지윤 26.07.20 수정: 신고(r.reported) 기준 -> 삭제요청(r.deleteRequested) 기준으로 필터 변경
  function renderList() {
    var list = reviews.filter(function (r) { return currentTab === 'all' || r.deleteRequested; });

    var sort = document.getElementById('sortSelect').value;
    if (sort === 'high') list = list.slice().sort(function (a, b) { return b.rating - a.rating; });
    else if (sort === 'low') list = list.slice().sort(function (a, b) { return a.rating - b.rating; });
    else list = list.slice().sort(function (a, b) { return b.date.localeCompare(a.date); });

    document.getElementById('cntAll').textContent = reviews.length;
    document.getElementById('cntReported').textContent = reviews.filter(function (r) { return r.deleteRequested; }).length;

    var box = document.getElementById('reviewList');
    box.innerHTML = '';

    if (list.length === 0) {
      box.innerHTML = '<div class="biz-review-empty">표시할 리뷰가 없습니다.</div>';
      return;
    }

    list.forEach(function (r) {
      var item = document.createElement('div');
      item.className = 'biz-review-item';

      var replyBoxHtml = '';
      if (openReplyId === r.id) {
        replyBoxHtml =
          '<div class="biz-reply-box">' +
            '<div class="biz-reply-box-label"><svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>답글 작성</div>' +
            '<textarea id="replyInput-' + r.id + '" placeholder="답글 내용을 입력해주세요">' + (r.reply || '') + '</textarea>' +
            '<div class="biz-reply-box-actions">' +
              '<button class="btn-cancel" onclick="toggleReply(' + r.id + ')">취소</button>' +
              '<button class="btn-submit" onclick="submitReply(' + r.id + ')">등록</button>' +
            '</div>' +
          '</div>';
      }

      //지윤 26.07.22 수정: 네이버 리뷰 스타일 참고해서 카드 레이아웃 재구성 - 썸네일+상품정보 상단 블록, 답글은 회색 박스로 정리
    item.innerHTML =
        '<div class="biz-review-main">' +
          '<div class="biz-review-product-row">' +
    (r.thumbnail ? '<img class="biz-review-thumb" src="' + (r.thumbnail.indexOf('http') === 0 ? r.thumbnail : contextPath + '/upload/' + r.thumbnail) + '">' : '<div class="biz-review-thumb biz-review-thumb-empty"></div>') +
            '<div class="biz-review-product-info">' +
              '<div class="biz-review-product-name">' + r.product + '</div>' +
              (r.option ? '<div class="biz-review-option">옵션: ' + r.option + '</div>' : '') +
            '</div>' +
          '</div>' +
          '<div class="biz-review-top">' +
            '<div class="biz-review-stars">' + starsHtml(r.rating) + '<span class="biz-review-score">' + r.rating + '</span></div>' +
            (r.deleteRequested ? '<span class="biz-review-reported">삭제요청됨</span>' : '') +
            (r.deleteRejected ? '<span class="biz-review-rejected">삭제요청 반려됨</span>' : '') +
            (r.reportCount > 0 ? '<button type="button" class="biz-review-flagged" onclick="toggleReporters(' + r.id + ')">신고접수 ' + r.reportCount + '건</button>' : '') +
          '</div>' +
          '<div class="biz-review-meta"><span class="biz-review-author">' + r.author + '</span><span class="biz-review-date">' + r.date + '</span></div>' +
          (r.reportCount > 0 ? '<div class="biz-review-reporters" id="reporters-' + r.id + '" style="display:none">신고자: ' + (r.reporterNames || '-') + '</div>' : '') +
          '<div class="biz-review-content">' + r.content + '</div>' +
          (r.reply && openReplyId !== r.id ? '<div class="biz-review-reply"><span class="biz-review-reply-label">판매자</span><span class="biz-review-reply-date">' + r.date + '</span><div class="biz-review-reply-text">' + r.reply + '</div></div>' : '') +
          replyBoxHtml +
        '</div>' +
        '<div class="biz-review-actions">' +
          '<button class="biz-btn" onclick="toggleReply(' + r.id + ')">' + (r.reply ? '답글수정' : '답글쓰기') + '</button>' +
          (r.deleteRequested ? '' : '<button class="biz-btn" onclick="requestDelete(' + r.id + ')">삭제요청</button>') +
        '</div>';

      box.appendChild(item);
    });
  }

  //지윤 26.07.20 수정: 클라이언트에서 배열만 바꾸던 것 -> 실제 서버(TB_REVIEW.BIZ_REPLY) 저장하도록 폼 submit으로 변경
  function submitReply(id) {
    var text = document.getElementById('replyInput-' + id).value.trim();
    if (!text) { alert('답글 내용을 입력해주세요.'); return; }
    document.getElementById('replyFormReviewId').value = id;
    document.getElementById('replyFormText').value = text;
    document.getElementById('replyForm').submit();
  }

  //지윤 26.07.20 추가: 삭제요청 - 즉시 삭제 X, 서버에 사유와 함께 등록만 함 (TB_REVIEW_REPORT, 관리자 승인 후 실제 삭제됨)
  function requestDelete(id) {
    var reason = prompt('삭제 사유를 입력해주세요 (관리자 승인 후 삭제됩니다)');
    if (reason === null) return;
    document.getElementById('delFormReviewId').value = id;
    document.getElementById('delFormReason').value = reason;
    document.getElementById('deleteReqForm').submit();
  }

  renderList();
</script>

<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>