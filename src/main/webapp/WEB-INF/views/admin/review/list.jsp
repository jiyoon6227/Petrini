<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="adminPage"   value="review-list" />
<%@ include file="/WEB-INF/views/admin/common/header.jsp" %>
<%@ include file="/WEB-INF/views/admin/common/sidebar.jsp" %>

<style>
    .rv-tab-bar { display:flex; align-items:flex-end; border-bottom:2px solid #E4E6ED; margin-bottom:20px; }
    .rv-tab { padding:10px 22px; font-size:14px; font-weight:600; color:#999; border-bottom:2px solid transparent; margin-bottom:-2px; }
    .rv-tab:link, .rv-tab:visited { color:#999; text-decoration:none; }
    .rv-tab:hover { color:#3B5BDB; }
    .rv-tab.on { color:#3B5BDB; border-bottom-color:#3B5BDB; font-weight:700; }
    .rv-tab-count { background:#EEF2FF; color:#3B5BDB; font-size:11px; padding:1px 7px; border-radius:20px; margin-left:4px; }
    .rv-ellipsis { overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
    .rv-report-toggle { background:#FEF2F2; color:#B91C1C; border:1px solid #FECACA; border-radius:12px; padding:2px 10px; font-size:12px; cursor:pointer; }
    .rv-report-row td { background:#FAFAFB; }
    .rv-report-list { margin:0; padding:0; list-style:none; font-size:13px; }
    .rv-report-list li { padding:6px 0; border-bottom:1px dashed #E4E6ED; display:flex; gap:12px; }
    .rv-report-list li:last-child { border-bottom:none; }
    .rv-report-meta { color:#888; white-space:nowrap; }
</style>

<main class="adm-main">
    <div class="adm-page-head">
        <div class="adm-page-head-left">
            <h1 class="adm-page-title">리뷰 삭제 요청·신고</h1>
            <p class="adm-page-desc">사업자의 리뷰 삭제 요청과 고객의 리뷰 신고를 확인하고 처리하세요.</p>
        </div>
    </div>

    <c:if test="${not empty successMsg}">
        <div style="background:#ECFDF5;border:1px solid #BBF7D0;color:#166534;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:14px">${successMsg}</div>
    </c:if>
    <c:if test="${not empty errorMsg}">
        <div style="background:#FEF2F2;border:1px solid #FECACA;color:#B91C1C;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:14px">${errorMsg}</div>
    </c:if>

    <div class="rv-tab-bar">
        <a href="${contextPath}/admin/review/list?tab=request&statusCd=PENDING" class="rv-tab ${tab eq 'request' ? 'on' : ''}">
            사업자 삭제요청<span class="rv-tab-count">${pendingRequestCount}</span>
        </a>
        <a href="${contextPath}/admin/review/list?tab=report&statusCd=PENDING" class="rv-tab ${tab eq 'report' ? 'on' : ''}">
            고객 신고<span class="rv-tab-count">${pendingReportCount}</span>
        </a>
    </div>

    <div class="adm-card">
        <div class="adm-card-head">
            <span class="adm-card-head-title">${tab eq 'report' ? '고객 신고 목록' : '삭제 요청 목록'}</span>
            <span class="adm-card-head-sub">총 ${totalCount}건</span>
        </div>
        <div class="adm-card-body" style="padding-bottom:0">
            <%-- GET 검색 (tab, keyword, statusCd) --%>
            <form method="get" action="${contextPath}/admin/review/list" class="adm-filter-bar">
                <input type="hidden" name="tab" value="${tab}">
                <input type="text" name="keyword" class="adm-filter-input"
                       placeholder="${tab eq 'report' ? '상품·병원·숙소명, 사업자명, 작성자·신고자, 사유 검색' : '병원·숙소·상품명, 사업자명, 작성자, 사유 검색'}"
                       value="${fn:escapeXml(keyword)}">
                <select name="statusCd" class="adm-filter-select">
                    <option value="ALL" ${statusCd eq 'ALL' ? 'selected' : ''}>상태 전체</option>
                    <option value="PENDING" ${statusCd eq 'PENDING' ? 'selected' : ''}>대기</option>
                    <c:choose>
                        <c:when test="${tab eq 'report'}">
                            <option value="DELETED" ${statusCd eq 'DELETED' ? 'selected' : ''}>리뷰 삭제</option>
                            <option value="REJECTED" ${statusCd eq 'REJECTED' ? 'selected' : ''}>반려</option>
                            <option value="CLOSED" ${statusCd eq 'CLOSED' ? 'selected' : ''}>작성자 삭제</option>
                        </c:when>
                        <c:otherwise>
                            <option value="APPROVED" ${statusCd eq 'APPROVED' ? 'selected' : ''}>승인</option>
                            <option value="REJECTED" ${statusCd eq 'REJECTED' ? 'selected' : ''}>반려</option>
                            <option value="CANCELED" ${statusCd eq 'CANCELED' ? 'selected' : ''}>작성자 삭제</option>
                        </c:otherwise>
                    </c:choose>
                </select>
                <button type="submit" class="adm-filter-btn primary">
                    <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                    검색
                </button>
            </form>
        </div>
        <div class="adm-table-wrap">
            <c:choose>
            <%-- ===================== 고객 신고 탭 ===================== --%>
            <c:when test="${tab eq 'report'}">
            <table class="adm-table">
                <thead>
                    <tr>
                        <th>번호</th><th>유형</th><th>대상</th><th>사업자</th><th>리뷰 작성자</th>
                        <th>리뷰</th><th>신고자</th><th>신고 사유</th><th>상태</th><th>신고일</th><th>처리</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty list}">
                            <tr>
                                <td colspan="11" style="text-align:center;color:#999;padding:40px 0">
                                    고객 신고가 없습니다.
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="item" items="${list}">
                                <tr>
                                    <td>${item.reportId}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${item.reviewType eq 'STAY'}">숙소</c:when>
                                            <c:when test="${item.reviewType eq 'HOSPITAL'}">병원</c:when>
                                            <c:when test="${item.reviewType eq 'PRODUCT'}">쇼핑</c:when>
                                            <c:otherwise>-</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td><c:out value="${empty item.targetName ? '-' : item.targetName}"/></td>
                                    <td><c:out value="${item.bizName}"/></td>
                                    <td><c:out value="${empty item.reviewerNickname ? '-' : item.reviewerNickname}"/></td>
                                    <td class="rv-ellipsis" style="max-width:180px"
                                        title="${fn:escapeXml(item.reviewContent)}">
                                        <c:choose>
                                            <c:when test="${not empty item.reviewContent}"><c:out value="${item.reviewContent}"/></c:when>
                                            <c:otherwise><span style="color:#999">(삭제된 리뷰)</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td><c:out value="${item.reporterNickname}"/></td>
                                    <td class="rv-ellipsis" style="max-width:180px"
                                        title="${fn:escapeXml(item.reason)}"><c:out value="${item.reason}"/></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${item.statusCd eq 'PENDING'}"><span class="adm-badge wait">대기</span></c:when>
                                            <c:when test="${item.statusCd eq 'DELETED'}"><span class="adm-badge active">리뷰 삭제</span></c:when>
                                            <c:when test="${item.statusCd eq 'REJECTED'}"><span class="adm-badge cancel">반려</span></c:when>
                                            <c:when test="${item.statusCd eq 'CLOSED'}"><span class="adm-badge inactive">작성자 삭제</span></c:when>
                                        </c:choose>
                                    </td>
                                    <td><fmt:formatDate value="${item.regDate}" pattern="yyyy.M.d"/></td>
                                    <td style="white-space:nowrap">
                                        <c:choose>
                                            <c:when test="${item.statusCd eq 'PENDING'}">
                                                <%-- 리뷰 삭제 --%>
                                                <form method="post" action="${contextPath}/admin/review/report/delete"
                                                      class="js-admin-approve-form" data-confirm="신고된 리뷰를 삭제하시겠습니까?"
                                                      style="display:inline;margin:0">
                                                    <input type="hidden" name="_csrf" value="${_csrf}">
                                                    <input type="hidden" name="reportId" value="${item.reportId}">
                                                    <button type="submit" class="adm-btn red">리뷰 삭제</button>
                                                </form>
                                                <%-- 신고 반려 (사유 입력 필수) --%>
                                                <form method="post" action="${contextPath}/admin/review/report/reject"
                                                      style="display:inline-flex;gap:6px;margin-left:6px;align-items:center"
                                                      onsubmit="return confirm('신고를 반려하시겠습니까?')">
                                                    <input type="hidden" name="_csrf" value="${_csrf}">
                                                    <input type="hidden" name="reportId" value="${item.reportId}">
                                                    <input type="text" name="rejectReason" class="adm-filter-input"
                                                           placeholder="반려 사유" required style="width:160px">
                                                    <button type="submit" class="adm-btn gray">반려</button>
                                                </form>
                                            </c:when>
                                            <c:when test="${item.statusCd eq 'REJECTED' && not empty item.rejectReason}">
                                                <span style="font-size:12px;color:#666" title="${fn:escapeXml(item.rejectReason)}">
                                                    반려: <c:out value="${item.rejectReason}"/>
                                                </span>
                                            </c:when>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
            </c:when>

            <%-- ===================== 사업자 삭제요청 탭 ===================== --%>
            <c:otherwise>
            <table class="adm-table">
                <thead>
                    <tr>
                        <th>번호</th><th>유형</th><th>대상</th><th>사업자</th><th>작성자</th>
                        <th>평점</th><th>리뷰</th><th>삭제사유</th><th>고객 신고</th><th>상태</th><th>요청일</th><th>처리</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty list}">
                            <tr>
                                <td colspan="12" style="text-align:center;color:#999;padding:40px 0">
                                    삭제 요청이 없습니다.
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="item" items="${list}">
                                <tr>
                                    <td>${item.requestId}</td>
                                    <%-- 병원·숙소·쇼핑 유형 --%>
                                    <td>
                                        <c:choose>
                                            <c:when test="${item.reviewType eq 'STAY'}">숙소</c:when>
                                            <c:when test="${item.reviewType eq 'PRODUCT'}">쇼핑</c:when>
                                            <c:otherwise>병원</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td><c:out value="${item.hospitalName}"/></td>
                                    <td><c:out value="${item.bizName}"/></td>
                                    <td><c:out value="${item.reviewerNickname}"/></td>
                                    <td>${item.reviewRating}</td>
                                    <td class="rv-ellipsis" style="max-width:180px"
                                        title="${not empty item.reviewContent ? fn:escapeXml(item.reviewContent) : '삭제된 리뷰'}">
                                        <c:choose>
                                            <c:when test="${not empty item.reviewContent}"><c:out value="${item.reviewContent}"/></c:when>
                                            <c:when test="${item.statusCd eq 'APPROVED' || item.statusCd eq 'CANCELED'}"><span style="color:#999">(삭제된 리뷰)</span></c:when>
                                            <c:otherwise>-</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="rv-ellipsis" style="max-width:160px"
                                        title="${fn:escapeXml(item.requestReason)}"><c:out value="${item.requestReason}"/></td>
                                    <%-- 이 리뷰에 걸린 고객 신고 (클릭하면 아래 줄에 펼침) --%>
                                    <td>
                                        <c:choose>
                                            <c:when test="${item.reportCount > 0}">
                                                <button type="button" class="rv-report-toggle"
                                                        onclick="toggleReportRow(${item.requestId})">신고 ${item.reportCount}건</button>
                                            </c:when>
                                            <c:otherwise><span style="color:#bbb">-</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${item.statusCd eq 'PENDING'}">
                                                <span class="adm-badge wait">대기</span>
                                            </c:when>
                                            <c:when test="${item.statusCd eq 'APPROVED'}">
                                                <span class="adm-badge active">승인</span>
                                            </c:when>
                                            <c:when test="${item.statusCd eq 'REJECTED'}">
                                                <span class="adm-badge cancel">반려</span>
                                            </c:when>
                                            <c:when test="${item.statusCd eq 'CANCELED'}">
                                                <span class="adm-badge inactive">작성자 삭제</span>
                                            </c:when>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:if test="${not empty item.reqDate}">
                                            <fmt:formatDate value="${item.reqDate}" pattern="yyyy.M.d"/>
                                        </c:if>
                                    </td>
                                    <td style="white-space:nowrap">
                                        <c:choose>
                                            <c:when test="${item.statusCd eq 'PENDING'}">
                                                <%-- 승인(리뷰 삭제) --%>
                                                <form method="post" action="${contextPath}/admin/review/approve"
                                                      class="js-admin-approve-form" data-confirm="리뷰를 삭제(승인)하시겠습니까?"
                                                      style="display:inline;margin:0">
                                                    <input type="hidden" name="_csrf" value="${_csrf}">
                                                    <input type="hidden" name="requestId" value="${item.requestId}">
                                                    <button type="submit" class="adm-btn red">승인(삭제)</button>
                                                </form>
                                                <%-- 반려 (사유 입력 필수) --%>
                                                <form method="post" action="${contextPath}/admin/review/reject"
                                                      style="display:inline-flex;gap:6px;margin-left:6px;align-items:center"
                                                      onsubmit="return confirm('반려하시겠습니까?')">
                                                    <input type="hidden" name="_csrf" value="${_csrf}">
                                                    <input type="hidden" name="requestId" value="${item.requestId}">
                                                    <input type="text" name="rejectReason" class="adm-filter-input"
                                                           placeholder="반려 사유" required style="width:160px">
                                                    <button type="submit" class="adm-btn gray">반려</button>
                                                </form>
                                            </c:when>
                                            <c:when test="${item.statusCd eq 'REJECTED' && not empty item.rejectReason}">
                                                <span style="font-size:12px;color:#666" title="${fn:escapeXml(item.rejectReason)}">
                                                    반려: <c:out value="${item.rejectReason}"/>
                                                </span>
                                            </c:when>
                                        </c:choose>
                                    </td>
                                </tr>
                                <c:if test="${item.reportCount > 0}">
                                    <tr class="rv-report-row" id="reportRow-${item.requestId}" style="display:none">
                                        <td colspan="12">
                                            <ul class="rv-report-list">
                                                <c:forEach var="rp" items="${item.reports}">
                                                    <li>
                                                        <span class="rv-report-meta"><fmt:formatDate value="${rp.regDate}" pattern="yyyy.M.d"/></span>
                                                        <span class="rv-report-meta"><c:out value="${rp.reporterNickname}"/></span>
                                                        <span style="flex:1"><c:out value="${rp.reason}"/></span>
                                                        <span class="rv-report-meta">
                                                            <c:choose>
                                                                <c:when test="${rp.statusCd eq 'PENDING'}">대기</c:when>
                                                                <c:when test="${rp.statusCd eq 'REJECTED'}">반려</c:when>
                                                                <c:otherwise>${rp.statusCd}</c:otherwise>
                                                            </c:choose>
                                                        </span>
                                                    </li>
                                                </c:forEach>
                                            </ul>
                                        </td>
                                    </tr>
                                </c:if>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
            </c:otherwise>
            </c:choose>
        </div>
        <div style="padding:16px 20px;border-top:1px solid #E4E6ED;display:flex;justify-content:center">
            <div class="adm-pagination" style="margin:0">
                <c:if test="${page > 1}">
                    <a href="${contextPath}/admin/review/list?tab=${tab}&keyword=${fn:escapeXml(keyword)}&statusCd=${statusCd}&page=${page - 1}"
                       class="adm-page-btn">
                        <svg viewBox="0 0 24 24"><polyline points="15 18 9 12 15 6"/></svg>
                    </a>
                </c:if>
                <span class="adm-page-btn active">${page}</span>
                <c:if test="${page * 10 < totalCount}">
                    <a href="${contextPath}/admin/review/list?tab=${tab}&keyword=${fn:escapeXml(keyword)}&statusCd=${statusCd}&page=${page + 1}"
                       class="adm-page-btn">
                        <svg viewBox="0 0 24 24"><polyline points="9 18 15 12 9 6"/></svg>
                    </a>
                </c:if>
            </div>
        </div>
    </div>
</main>

<%-- 승인·삭제 fetch(AJAX)·20초 타임아웃(락 대기 방지) --%>
<script>
function toggleReportRow(requestId) {
  var row = document.getElementById('reportRow-' + requestId);
  if (row) row.style.display = (row.style.display === 'none') ? '' : 'none';
}

(function () {
  function bindAjaxForm(selector, timeoutMsg) {
    document.querySelectorAll(selector).forEach(function (form) {
      form.addEventListener('submit', function (e) {
        e.preventDefault();
        if (!confirm(form.dataset.confirm || '처리하시겠습니까?')) return;
        var btn = form.querySelector('button[type="submit"]');
        if (btn && btn.disabled) return;
        if (btn) {
          btn.disabled = true;
          btn.dataset.label = btn.textContent;
          btn.textContent = '처리 중...';
        }
        var ctrl = new AbortController();
        var timer = setTimeout(function () { ctrl.abort(); }, 20000);
        csrfFetch(form.action, {
          method: 'POST',
          body: new URLSearchParams(new FormData(form)),
          credentials: 'same-origin',
          redirect: 'manual',
          signal: ctrl.signal,
          headers: { 'X-Requested-With': 'XMLHttpRequest' }
        }).then(function (res) {
          clearTimeout(timer);
          if (res.status === 0 || (res.status >= 300 && res.status < 400)) {
            var loc = res.headers.get('Location');
            window.location.href = loc || '${contextPath}/admin/review/list?tab=${tab}';
            return;
          }
          if (res.ok) {
            window.location.reload();
            return;
          }
          return res.text().then(function (t) {
            throw new Error(t && t.length < 200 ? t : ('HTTP ' + res.status));
          });
        }).catch(function (err) {
          clearTimeout(timer);
          var msg = err.name === 'AbortError' ? timeoutMsg : (err.message || '알 수 없는 오류');
          alert('처리 실패: ' + msg);
          if (btn) {
            btn.disabled = false;
            btn.textContent = btn.dataset.label || '처리';
          }
        });
      });
    });
  }
  bindAjaxForm('.js-admin-approve-form',
      '요청 시간이 초과되었습니다. DB 락·서버 상태를 확인해 주세요.');
})();
</script>

<%@ include file="/WEB-INF/views/admin/common/footer.jsp" %>
