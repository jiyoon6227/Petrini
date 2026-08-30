<%--
  - 박유정 / 2026-07-24
  - GET  /admin/review/list   삭제 요청 목록
  - POST /admin/review/approve 승인(리뷰 삭제)
  - POST /admin/review/reject  반려(사유 입력 + 사업자 알림)
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="adminPage"   value="review-list" />
<%@ include file="/WEB-INF/views/admin/common/header.jsp" %>
<%@ include file="/WEB-INF/views/admin/common/sidebar.jsp" %>

<main class="adm-main">
    <div class="adm-page-head">
        <div class="adm-page-head-left">
            <h1 class="adm-page-title">사업자 리뷰 삭제 요청</h1>
            <p class="adm-page-desc">병원·숙소·쇼핑 사업자의 리뷰 삭제 요청을 확인하고 처리하세요.</p>
        </div>
    </div>

    <c:if test="${not empty successMsg}">
        <div style="background:#ECFDF5;border:1px solid #BBF7D0;color:#166534;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:14px">${successMsg}</div>
    </c:if>
    <c:if test="${not empty errorMsg}">
        <div style="background:#FEF2F2;border:1px solid #FECACA;color:#B91C1C;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:14px">${errorMsg}</div>
    </c:if>

    <div class="adm-card">
        <div class="adm-card-head">
            <span class="adm-card-head-title">삭제 요청 목록</span>
            <span class="adm-card-head-sub">총 ${totalCount}건</span>
        </div>
        <div class="adm-card-body" style="padding-bottom:0">
            <%-- 2026-07-24 박유정 — GET 검색 (keyword, statusCd) --%>
            <form method="get" action="${contextPath}/admin/review/list" class="adm-filter-bar">
                <input type="text" name="keyword" class="adm-filter-input"
                       placeholder="병원·숙소·상품명, 사업자명, 작성자, 사유 검색" value="${keyword}">
                <select name="statusCd" class="adm-filter-select">
                    <option value="ALL" ${statusCd eq 'ALL' ? 'selected' : ''}>상태 전체</option>
                    <option value="PENDING" ${statusCd eq 'PENDING' ? 'selected' : ''}>대기</option>
                    <option value="APPROVED" ${statusCd eq 'APPROVED' ? 'selected' : ''}>승인</option>
                    <option value="REJECTED" ${statusCd eq 'REJECTED' ? 'selected' : ''}>반려</option>
                </select>
                <button type="submit" class="adm-filter-btn primary">
                    <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                    검색
                </button>
            </form>
        </div>
        <div class="adm-table-wrap">
            <table class="adm-table">
                <thead>
                    <tr>
                        <th>번호</th><th>유형</th><th>대상</th><th>사업자</th><th>작성자</th>
                        <th>평점</th><th>리뷰</th><th>삭제사유</th><th>상태</th><th>요청일</th><th>처리</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty list}">
                            <tr>
                                <td colspan="11" style="text-align:center;color:#999;padding:40px 0">
                                    삭제 요청이 없습니다.
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="item" items="${list}">
                                <tr>
                                    <td>${item.requestId}</td>
                                    <%-- 2026/08/11 장우철 — 병원·숙소·쇼핑 유형 --%>
                                    <td>
                                        <c:choose>
                                            <c:when test="${item.reviewType eq 'STAY'}">숙소</c:when>
                                            <c:when test="${item.reviewType eq 'PRODUCT'}">쇼핑</c:when>
                                            <c:otherwise>병원</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>${item.hospitalName}</td>
                                    <td>${item.bizName}</td>
                                    <td>${item.reviewerNickname}</td>
                                    <td>${item.reviewRating}</td>
                                    <td style="max-width:180px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap"
                                        title="${not empty item.reviewContent ? item.reviewContent : '삭제된 리뷰'}">
                                        <c:choose>
                                            <c:when test="${not empty item.reviewContent}">${item.reviewContent}</c:when>
                                            <c:when test="${item.statusCd eq 'APPROVED'}"><span style="color:#999">(삭제된 리뷰)</span></c:when>
                                            <c:otherwise>-</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="max-width:160px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap"
                                        title="${item.requestReason}">${item.requestReason}</td>
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
                                                <%-- 2026-07-24 박유정 — 승인(리뷰 삭제) --%>
                                                <form method="post" action="${contextPath}/admin/review/approve"
                                                      class="js-admin-approve-form"
                                                      style="display:inline;margin:0">
                                                    <!--HYJ 26.08.05-->
                                                    <input type="hidden" name="_csrf" value="${_csrf}">
                                                    <input type="hidden" name="requestId" value="${item.requestId}">
                                                    <input type="hidden" name="sourceCd" value="${item.sourceCd}">
                                                    <button type="submit" class="adm-btn red">승인(삭제)</button>
                                                </form>
                                                <%-- 2026-07-24 박유정 — 반려 (사유 입력 필수) --%>
                                                <form method="post" action="${contextPath}/admin/review/reject"
                                                      style="display:inline-flex;gap:6px;margin-left:6px;align-items:center"
                                                      onsubmit="return confirm('반려하시겠습니까?')">
                                                    <!--HYJ 26.08.05-->
                                                    <input type="hidden" name="_csrf" value="${_csrf}">
                                                    <input type="hidden" name="requestId" value="${item.requestId}">
                                                    <input type="hidden" name="sourceCd" value="${item.sourceCd}">
                                                    <input type="text" name="rejectReason" class="adm-filter-input"
                                                           placeholder="반려 사유" required style="width:160px">
                                                    <button type="submit" class="adm-btn gray">반려</button>
                                                </form>
                                            </c:when>
                                            <c:when test="${item.statusCd eq 'REJECTED' && not empty item.rejectReason}">
                                                <span style="font-size:12px;color:#666" title="${item.rejectReason}">
                                                    반려: ${item.rejectReason}
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
        </div>
        <div style="padding:16px 20px;border-top:1px solid #E4E6ED;display:flex;justify-content:center">
            <div class="adm-pagination" style="margin:0">
                <c:if test="${page > 1}">
                    <a href="${contextPath}/admin/review/list?keyword=${keyword}&statusCd=${statusCd}&page=${page - 1}"
                       class="adm-page-btn">
                        <svg viewBox="0 0 24 24"><polyline points="15 18 9 12 15 6"/></svg>
                    </a>
                </c:if>
                <span class="adm-page-btn active">${page}</span>
                <c:if test="${page * 10 < totalCount}">
                    <a href="${contextPath}/admin/review/list?keyword=${keyword}&statusCd=${statusCd}&page=${page + 1}"
                       class="adm-page-btn">
                        <svg viewBox="0 0 24 24"><polyline points="9 18 15 12 9 6"/></svg>
                    </a>
                </c:if>
            </div>
        </div>
    </div>
</main>

<%-- 2026-07-28 박유정 — 승인 fetch(AJAX)·20초 타임아웃(락 대기 방지) --%>
<script>
(function () {
  function bindAjaxForm(selector, timeoutMsg) {
    document.querySelectorAll(selector).forEach(function (form) {
      form.addEventListener('submit', function (e) {
        e.preventDefault();
        if (!confirm('리뷰를 삭제(승인)하시겠습니까?')) return;
        var btn = form.querySelector('button[type="submit"]');
        if (btn && btn.disabled) return;
        if (btn) {
          btn.disabled = true;
          btn.dataset.label = btn.textContent;
          btn.textContent = '처리 중...';
        }
        var ctrl = new AbortController();
        var timer = setTimeout(function () { ctrl.abort(); }, 20000);
        //HYJ 26.08.05
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
            window.location.href = loc || '${contextPath}/admin/review/list';
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
            btn.textContent = btn.dataset.label || '승인(삭제)';
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
