/**
 * 사업자 리뷰관리 공통 (병원·숙소·쇼핑)
 * 화면: WEB-INF/views/biz/common/review-manage.jsp
 * 데이터: 컨트롤러가 BizReviewRows로 만든 reviews / deleteRequests JSON
 *
 * BizReview.init({
 *   reviews: [...], deleteRequests: [...],
 *   contextPath: '/petcare',
 *   replyLabel: '병원 답글',      // 답글 앞에 붙는 이름
 *   showThumbnail: false,          // 쇼핑만 true (상품 썸네일·옵션)
 *   showReports: false             // 쇼핑만 true (고객 신고 사유)
 * });
 */
var BizReview = (function () {

  var cfg = {};
  var reviews = [];
  var deleteRequests = [];
  var currentTab = 'all';
  var openReplyId = null;

  // 사용자 입력은 innerHTML에 넣기 전에 반드시 이스케이프
  function escapeHtml(str) {
    return String(str == null ? '' : str)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
  }

  function starsHtml(rating) {
    var n = Math.round(Number(rating) || 0);
    var html = '';
    for (var i = 1; i <= 5; i++) {
      html += '<svg viewBox="0 0 24 24" class="' + (i <= n ? 'on' : 'off') + '"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>';
    }
    return html;
  }

  // 삭제요청 상태 배지 (PENDING / APPROVED / REJECTED / CANCELED)
  function statusBadgeHtml(statusCd) {
    if (statusCd === 'PENDING')  return '<span class="biz-review-reported">삭제요청됨</span>';
    if (statusCd === 'REJECTED') return '<span class="biz-review-rejected">삭제요청 반려됨</span>';
    if (statusCd === 'APPROVED') return '<span class="biz-review-status-done">삭제승인</span>';
    if (statusCd === 'CANCELED') return '<span class="biz-review-status-done">작성자 삭제</span>';
    return '';
  }

  function infoLine(label, value, color) {
    return '<div style="margin-top:8px;font-size:13px;color:' + (color || '#555') + '">' +
             label + ': ' + escapeHtml(value) + '</div>';
  }

  // 이미지가 없거나 못 불러오면 장바구니와 같은 기본 이미지
  var PLACEHOLDER_IMG = 'https://placehold.co/56x56/EAF7F2/2BAB82?text=IMG';

  function thumbnailSrc(path) {
    if (!path) return PLACEHOLDER_IMG;
    return path.indexOf('http') === 0 ? path : cfg.contextPath + '/upload/' + path;
  }

  // 대상(상품명/병원명/숙소명) 줄. 쇼핑만 썸네일·옵션, 병원·숙소는 이미지 칸 자체를 만들지 않음
  function targetRowHtml(item) {
    var thumb = '';
    if (cfg.showThumbnail === true) {
      thumb = '<img class="biz-review-thumb" src="' + escapeHtml(thumbnailSrc(item.thumbnail)) + '" alt=""' +
              ' onerror="this.onerror=null;this.src=\'' + PLACEHOLDER_IMG + '\'">';
    }
    return '<div class="biz-review-product-row">' + thumb +
             '<div class="biz-review-product-info">' +
               '<div class="biz-review-product-name">' + escapeHtml(item.target || '-') + '</div>' +
               (item.option ? '<div class="biz-review-option">옵션: ' + escapeHtml(item.option) + '</div>' : '') +
             '</div>' +
           '</div>';
  }

  // 고객 신고 사유 (쇼핑만, 신고자 없이 날짜·사유)
  function reportBoxHtml(r) {
    var items = (r.reportReasons || []).map(function (rr) {
      return '<li><span style="color:#888">' + escapeHtml(rr.date) + '</span> ' +
             escapeHtml(rr.reason || '(사유 없음)') + '</li>';
    }).join('');
    return '<div class="biz-review-reporters" id="reporters-' + r.id + '" style="display:none">' +
             '<div style="font-weight:600;margin-bottom:4px">신고 사유</div>' +
             '<ul style="margin:0;padding-left:16px">' + items + '</ul>' +
           '</div>';
  }

  /**
   * 카드 하나 (쇼핑 스타일)
   * item: { id, target, thumbnail, option, author, date, rating, content, reply, reportCount, reportReasons }
   * opt:  { statusCd, extraHtml, actions }
   */
  function cardHtml(item, opt) {
    var hasRating = item.rating != null;
    var showReports = cfg.showReports && opt.actions && item.reportCount > 0;

    var replyHtml = '';
    if (opt.actions && openReplyId === item.id) {
      replyHtml =
        '<div class="biz-reply-box">' +
          '<textarea id="replyInput-' + item.id + '" placeholder="답글 내용을 입력해주세요">' + escapeHtml(item.reply || '') + '</textarea>' +
          '<div class="biz-reply-box-actions">' +
            '<button type="button" class="btn-cancel" onclick="BizReview.toggleReply(' + item.id + ')">취소</button>' +
            '<button type="button" class="btn-submit" onclick="BizReview.submitReply(' + item.id + ')">등록</button>' +
          '</div>' +
        '</div>';
    } else if (item.reply) {
      replyHtml =
        '<div class="biz-review-reply">' +
          '<span class="biz-review-reply-label">' + escapeHtml(cfg.replyLabel || '답글') + '</span>' +
          '<div class="biz-review-reply-text">' + escapeHtml(item.reply) + '</div>' +
        '</div>';
    }

    var actionsHtml = '';
    if (opt.actions) {
      actionsHtml =
        '<div class="biz-review-actions">' +
          '<button type="button" class="biz-btn" onclick="BizReview.toggleReply(' + item.id + ')">' + (item.reply ? '답글수정' : '답글쓰기') + '</button>' +
          (opt.statusCd === 'PENDING' ? '' :
            '<button type="button" class="biz-btn" style="color:#B91C1C;border-color:#FECACA" onclick="BizReview.requestDelete(' + item.id + ')">삭제요청</button>') +
        '</div>';
    }

    return '<div class="biz-review-item">' +
      '<div class="biz-review-main">' +
        targetRowHtml(item) +
        '<div class="biz-review-top">' +
          (hasRating ? '<div class="biz-review-stars">' + starsHtml(item.rating) + '<span class="biz-review-score">' + escapeHtml(item.rating) + '</span></div>' : '') +
          statusBadgeHtml(opt.statusCd) +
          (showReports ? '<button type="button" class="biz-review-flagged" onclick="BizReview.toggleReports(' + item.id + ')">신고접수 ' + item.reportCount + '건</button>' : '') +
        '</div>' +
        '<div class="biz-review-meta">' +
          // 승인·작성자 삭제 건은 리뷰가 없어 작성자도 없음 → 이름 칸을 통째로 생략
          (item.author ? '<span class="biz-review-author">' + escapeHtml(item.author) + '</span>' : '') +
          '<span class="biz-review-date">' + escapeHtml(item.date || '') + '</span>' +
        '</div>' +
        (showReports ? reportBoxHtml(item) : '') +
        (item.content != null
          ? '<div class="biz-review-content">' + escapeHtml(item.content) + '</div>'
          : '<div class="biz-review-content" style="color:#aaa">(삭제된 리뷰)</div>') +
        replyHtml +
        (opt.extraHtml || '') +
      '</div>' +
      actionsHtml +
    '</div>';
  }

  // 삭제요청 이력 카드 (승인·작성자 삭제 건은 리뷰가 없어 사유·날짜 위주로 표시)
  function requestCardHtml(dr) {
    var extra = infoLine('요청 사유', dr.requestReason);
    if (dr.statusCd === 'REJECTED' && dr.rejectReason) {
      extra += infoLine('반려 사유', dr.rejectReason, '#B91C1C');
    }
    if (dr.statusCd !== 'PENDING' && dr.processDate) {
      extra += infoLine('처리일', dr.processDate);
    }
    return cardHtml({
      id: dr.reviewId,
      target: dr.target,
      thumbnail: dr.thumbnail,
      author: dr.author,
      date: '요청일 ' + (dr.reqDate || ''),
      rating: dr.rating,
      content: dr.content
    }, { statusCd: dr.statusCd, extraHtml: extra, actions: false });
  }

  // 전체 탭 카드 (지금 남아 있는 리뷰 + 최근 삭제요청 상태)
  function reviewCardHtml(r) {
    var extra = '';
    if (r.deleteReqStatus === 'REJECTED' && r.rejectReason) {
      extra = infoLine('반려 사유', r.rejectReason, '#B91C1C');
    }
    return cardHtml(r, { statusCd: r.deleteReqStatus, extraHtml: extra, actions: true });
  }

  function requestsOf(tab) {
    return deleteRequests.filter(function (dr) {
      if (tab === 'pending')  return dr.statusCd === 'PENDING';
      if (tab === 'approved') return dr.statusCd === 'APPROVED' || dr.statusCd === 'CANCELED';
      if (tab === 'rejected') return dr.statusCd === 'REJECTED';
      return false;
    });
  }

  function sortedReviews() {
    var sort = document.getElementById('sortSelect').value;
    if (sort === 'high') return reviews.slice().sort(function (a, b) { return Number(b.rating) - Number(a.rating); });
    if (sort === 'low')  return reviews.slice().sort(function (a, b) { return Number(a.rating) - Number(b.rating); });
    return reviews.slice().sort(function (a, b) { return String(b.date).localeCompare(String(a.date)); });
  }

  var EMPTY_MSG = {
    all: '등록된 리뷰가 없습니다.',
    pending: '대기 중인 삭제 요청이 없습니다.',
    approved: '삭제 승인 내역이 없습니다.',
    rejected: '삭제 반려 내역이 없습니다.'
  };

  function render() {
    document.getElementById('cntAll').textContent = reviews.length;
    document.getElementById('cntPending').textContent = requestsOf('pending').length;
    document.getElementById('cntApproved').textContent = requestsOf('approved').length;
    document.getElementById('cntRejected').textContent = requestsOf('rejected').length;
    document.getElementById('sortWrap').style.display = (currentTab === 'all') ? '' : 'none';

    var html = (currentTab === 'all')
      ? sortedReviews().map(reviewCardHtml).join('')
      : requestsOf(currentTab).map(requestCardHtml).join('');
    document.getElementById('reviewList').innerHTML =
      html || '<div class="biz-review-empty">' + EMPTY_MSG[currentTab] + '</div>';
  }

  function switchTab(tab) {
    currentTab = tab;
    openReplyId = null;
    document.querySelectorAll('.biz-tab').forEach(function (b) { b.classList.toggle('active', b.dataset.tab === tab); });
    render();
  }

  function toggleReply(id) {
    openReplyId = (openReplyId === id) ? null : id;
    render();
  }

  // "신고접수 N건" 클릭 시 신고 사유 펼치기 (다시 그리지 않고 DOM만 토글)
  function toggleReports(id) {
    var el = document.getElementById('reporters-' + id);
    if (el) el.style.display = (el.style.display === 'none') ? 'block' : 'none';
  }

  function submitReply(id) {
    var text = document.getElementById('replyInput-' + id).value.trim();
    if (!text) { alert('답글 내용을 입력해주세요.'); return; }
    if (!confirm('답글을 저장할까요?')) return;
    document.getElementById('replyFormReviewId').value = id;
    document.getElementById('replyFormText').value = text;
    document.getElementById('replyForm').submit();
  }

  // 삭제요청: 사유 필수, 관리자 승인 후 삭제
  function requestDelete(id) {
    var reason = prompt('삭제 요청 사유를 입력해 주세요. (관리자 승인 후 삭제됩니다)');
    if (reason === null) return;
    reason = String(reason).trim();
    if (!reason) { alert('삭제 요청 사유를 입력해 주세요.'); return; }
    if (!confirm('이 리뷰에 대한 삭제 요청을 접수할까요?')) return;
    document.getElementById('delFormReviewId').value = id;
    document.getElementById('delFormReason').value = reason;
    document.getElementById('deleteReqForm').submit();
  }

  function init(options) {
    cfg = options || {};
    reviews = cfg.reviews || [];
    deleteRequests = cfg.deleteRequests || [];
    render();
  }

  return {
    init: init,
    render: render,
    switchTab: switchTab,
    toggleReply: toggleReply,
    toggleReports: toggleReports,
    submitReply: submitReply,
    requestDelete: requestDelete
  };
})();
