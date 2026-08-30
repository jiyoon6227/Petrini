<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<c:set var="bizTypeLabel" value="반려동물 숙소" />

<c:set var="bizPage"      value="reviews" />



<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>

<%@ include file="/WEB-INF/views/biz/common/sidebar_stay.jsp" %>



<%-- 7/2, 사업자(병원) 리뷰 관리 UI — 2026/07/14 장우철 DB 목록·답글 저장 연동 --%>

<main class="biz-main">

  <div class="biz-page-head">

    <h1 class="biz-page-title">리뷰 관리</h1>

    <p class="biz-page-desc">리뷰 답글 작성 및 삭제 요청 내역을 확인하세요.</p>

  </div>



  <%-- 2026-07-27 박유정 — 답글·삭제요청 처리 결과 flash --%>
  <c:if test="${not empty msg}">

    <div style="margin-bottom:12px;padding:12px 16px;background:#E8F8F1;color:#1F8464;border-radius:8px;font-size:14px">${msg}</div>

  </c:if>

  <c:if test="${not empty errorMsg}">

    <div style="margin-bottom:12px;padding:12px 16px;background:#FEF2F2;color:#B91C1C;border-radius:8px;font-size:14px">${errorMsg}</div>

  </c:if>



  <div class="biz-card">

    <div style="padding:20px 20px 0">

      <div class="biz-tabs">

        <%-- 2026-07-24 박유정 — 삭제요청 상태별 탭 --%>

        <button type="button" class="biz-tab active" data-tab="pending" onclick="switchTab('pending')">삭제요청<span class="biz-tab-count" id="cntPending"></span></button>

        <button type="button" class="biz-tab" data-tab="approved" onclick="switchTab('approved')">삭제승인<span class="biz-tab-count" id="cntApproved"></span></button>

        <button type="button" class="biz-tab" data-tab="rejected" onclick="switchTab('rejected')">삭제반려<span class="biz-tab-count" id="cntRejected"></span></button>

        <div class="biz-tabs-right" id="sortWrap">

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



<%-- 2026-07-27 박유정 — 답글 저장 POST (BizStayController) --%>
<form id="replyForm" method="post" action="${contextPath}/biz/stay/reviews/reply" style="display:none">
  <!--HYJ 26.08.05-->
  <input type="hidden" name="_csrf" value="${_csrf}">

  <input type="hidden" name="reviewId" id="replyReviewId" value="">

  <input type="hidden" name="bizReply" id="replyBizReply" value="">

</form>



<%-- 2026-07-24 박유정 — 리뷰 삭제 요청 --%>

<form id="deleteRequestForm" method="post" action="${contextPath}/biz/stay/reviews/delete-request" style="display:none">
  <!--HYJ 26.08.05-->
  <input type="hidden" name="_csrf" value="${_csrf}">
  
  <input type="hidden" name="reviewId" id="deleteReviewId" value="">

  <input type="hidden" name="requestReason" id="deleteRequestReason" value="">

</form>



<script>

  // 2026-07-27 박유정 — 컨트롤러 JSON 목록·삭제요청 연동
  var reviews = ${empty reviewListJson ? '[]' : reviewListJson};

  var deleteRequests = ${empty deleteRequestListJson ? '[]' : deleteRequestListJson};

  var currentTab = 'pending';

  var openReplyId = null;

  var contextPath = '${contextPath}';



  function starsHtml(rating) {

    var n = Math.round(Number(rating) || 0);

    var html = '';

    for (var i = 1; i <= 5; i++) {

      html += '<svg viewBox="0 0 24 24" class="' + (i <= n ? 'on' : 'off') + '"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>';

    }

    return html;

  }



  function escapeHtml(str) {

    return String(str == null ? '' : str)

      .replace(/&/g, '&amp;')

      .replace(/</g, '&lt;')

      .replace(/>/g, '&gt;')

      .replace(/"/g, '&quot;');

  }



  function switchTab(tab) {

    currentTab = tab;

    openReplyId = null;

    document.querySelectorAll('.biz-tab').forEach(function (b) { b.classList.toggle('active', b.dataset.tab === tab); });

    document.getElementById('sortWrap').style.display = (tab === 'pending') ? '' : 'none';

    renderList();

  }



  function toggleReply(id) {

    openReplyId = (openReplyId === id) ? null : id;

    renderList();

  }



  function statusBadgeHtml(statusCd) {

    if (statusCd === 'PENDING') return '<span class="biz-review-reported">대기</span>';

    if (statusCd === 'APPROVED') return '<span class="biz-review-status-done">승인(삭제)</span>';

    if (statusCd === 'REJECTED') return '<span class="biz-review-status-rejected">반려</span>';

    return '';

  }



  function filterDeleteRequests(statusCd) {

    return deleteRequests.filter(function (dr) { return dr.statusCd === statusCd; });

  }



  function updateTabCounts() {

    document.getElementById('cntPending').textContent = filterDeleteRequests('PENDING').length;

    document.getElementById('cntApproved').textContent = filterDeleteRequests('APPROVED').length;

    document.getElementById('cntRejected').textContent = filterDeleteRequests('REJECTED').length;

  }



  function sortReviews(list) {

    var sort = document.getElementById('sortSelect').value;

    if (sort === 'high') return list.slice().sort(function (a, b) { return Number(b.rating) - Number(a.rating); });

    if (sort === 'low') return list.slice().sort(function (a, b) { return Number(a.rating) - Number(b.rating); });

    return list.slice().sort(function (a, b) { return String(b.date).localeCompare(String(a.date)); });

  }



  // 2026-07-27 박유정 — 리뷰 카드 HTML (답글 입력·삭제요청 버튼)
  function buildReviewItemHtml(r, options) {

    options = options || {};

    var showActions = options.showActions !== false;

    var replyBoxHtml = '';

    if (openReplyId === r.id) {

      replyBoxHtml =

        '<div class="biz-reply-box">' +

          '<textarea id="replyInput-' + r.id + '" placeholder="답글 내용을 입력해주세요">' + escapeHtml(r.reply || '') + '</textarea>' +

          '<div class="biz-reply-box-actions">' +

            '<button type="button" class="btn-cancel" onclick="toggleReply(' + r.id + ')">취소</button>' +

            '<button type="button" class="btn-submit" onclick="submitReply(' + r.id + ')">등록</button>' +

          '</div>' +

        '</div>';

    }

    var actionsHtml = '';

    if (showActions) {

      actionsHtml =

        '<div class="biz-review-actions">' +

          '<button type="button" class="biz-btn" onclick="toggleReply(' + r.id + ')">' + (r.reply ? '답글수정' : '답글쓰기') + '</button>' +

          '<button type="button" class="biz-btn" style="margin-left:6px;color:#B91C1C;border-color:#FECACA" onclick="submitDeleteRequest(' + r.id + ')">삭제 요청</button>' +

        '</div>';

    }

    return '<div class="biz-review-item">' +

      '<div class="biz-review-main">' +

        '<div class="biz-review-stars">' + starsHtml(r.rating) + '</div>' +

        '<div class="biz-review-top">' +

          '<span class="biz-review-author">' + escapeHtml(r.author) + '</span>' +

          '<span class="biz-review-date">' + escapeHtml(r.dateLabel || r.date || '') + '</span>' +

          (options.statusBadge || '') +

        '</div>' +

        '<div class="biz-review-content">' + escapeHtml(r.content) + '</div>' +

        (r.reply && openReplyId !== r.id ? '<div class="biz-review-reply"><b>숙소 답글</b>' + escapeHtml(r.reply) + '</div>' : '') +

        (options.extraHtml || '') +

        replyBoxHtml +

      '</div>' +

      actionsHtml +

    '</div>';

  }



  // 2026-07-24 박유정 — 삭제요청 탭: 답글·신규 요청 + 대기 내역

  function renderPendingTab(box) {

    var pendingRequests = filterDeleteRequests('PENDING');

    var actionable = sortReviews(reviews.filter(function (r) { return !r.deleteRequestPending; }));

    var html = '';



    if (actionable.length > 0) {

      html += '<div class="biz-review-section-title">리뷰 답글 · 삭제 요청</div>';

      actionable.forEach(function (r) {

        r.dateLabel = r.date;

        html += buildReviewItemHtml(r, { showActions: true });

      });

    }



    if (pendingRequests.length > 0) {

      html += '<div class="biz-review-section-title spaced">삭제 요청 대기</div>';

      pendingRequests.forEach(function (dr) {

        var extra = '<div style="margin-top:8px;font-size:13px;color:#555">요청 사유: ' + escapeHtml(dr.requestReason) + '</div>';

        html += buildReviewItemHtml({

          id: dr.reviewId,

          author: dr.author,

          dateLabel: '요청일 ' + dr.reqDate,

          rating: dr.rating,

          content: dr.content,

          reply: null

        }, {

          showActions: false,

          statusBadge: statusBadgeHtml('PENDING'),

          extraHtml: extra

        });

      });

    }



    if (!html) {

      box.innerHTML = '<div class="biz-review-empty">삭제 요청 대기 건이 없습니다.</div>';

      return;

    }

    box.innerHTML = html;

  }



  // 2026-07-24 박유정 — 삭제승인·삭제반려 탭

  function renderDeleteRequestHistory(box, statusCd, emptyMsg) {

    var list = filterDeleteRequests(statusCd);

    if (list.length === 0) {

      box.innerHTML = '<div class="biz-review-empty">' + emptyMsg + '</div>';

      return;

    }

    var html = '';

    list.forEach(function (dr) {

      var extra = '<div style="margin-top:8px;font-size:13px;color:#555">요청 사유: ' + escapeHtml(dr.requestReason) + '</div>';

      if (statusCd === 'REJECTED' && dr.rejectReason) {

        extra += '<div style="margin-top:8px;font-size:13px;color:#B91C1C">반려 사유: ' + escapeHtml(dr.rejectReason) + '</div>';

      }

      if (statusCd === 'APPROVED' && dr.processDate) {

        extra += '<div style="margin-top:8px;font-size:13px;color:#555">처리일: ' + escapeHtml(dr.processDate) + '</div>';

      }

      html += buildReviewItemHtml({

        id: dr.reviewId,

        author: dr.author,

        dateLabel: '요청일 ' + dr.reqDate,

        rating: dr.rating,

        content: dr.content,

        reply: null

      }, {

        showActions: false,

        statusBadge: statusBadgeHtml(statusCd),

        extraHtml: extra

      });

    });

    box.innerHTML = html;

  }



  // 2026-07-27 박유정 — 탭별 목록 렌더·건수 갱신
  function renderList() {

    updateTabCounts();

    var box = document.getElementById('reviewList');

    box.innerHTML = '';

    if (currentTab === 'pending') {

      renderPendingTab(box);

      return;

    }

    if (currentTab === 'approved') {

      renderDeleteRequestHistory(box, 'APPROVED', '삭제 승인 내역이 없습니다.');

      return;

    }

    if (currentTab === 'rejected') {

      renderDeleteRequestHistory(box, 'REJECTED', '삭제 반려 내역이 없습니다.');

    }

  }



  // 2026-07-24 박유정 — 삭제 요청 사유 입력 후 form submit
  function submitDeleteRequest(id) {

    var reason = prompt('삭제 요청 사유를 입력해 주세요.');

    if (reason === null) return;

    reason = String(reason).trim();

    if (!reason) { alert('삭제 요청 사유를 입력해 주세요.'); return; }

    if (!confirm('이 리뷰에 대한 삭제 요청을 접수할까요?')) return;

    document.getElementById('deleteReviewId').value = id;

    document.getElementById('deleteRequestReason').value = reason;

    document.getElementById('deleteRequestForm').submit();

  }



  // 2026-07-27 박유정 — 답글 hidden form 제출
  function submitReply(id) {

    var text = document.getElementById('replyInput-' + id).value.trim();

    if (!text) { alert('답글 내용을 입력해주세요.'); return; }

    if (!confirm('답글을 저장할까요?')) return;

    document.getElementById('replyReviewId').value = id;

    document.getElementById('replyBizReply').value = text;

    document.getElementById('replyForm').submit();

  }



  renderList();

</script>



<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>

