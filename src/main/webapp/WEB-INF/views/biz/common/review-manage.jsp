<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- 사업자 리뷰관리 공통 화면 (병원·숙소·쇼핑 reviews.jsp에서 include)
     include 전에 c:set 할 값
       reviewBaseUrl  : 답글·삭제요청 POST 경로 (예: /biz/hospital/reviews)
       replyLabel     : 답글 이름 (병원 답글 / 숙소 답글 / 판매자)
       reviewPageDesc : 페이지 설명
       showThumbnail  : 쇼핑만 true (상품 썸네일·옵션)
       showReports    : 쇼핑만 true (고객 신고 사유)
     컨트롤러 model: reviewListJson, deleteRequestListJson (BizReviewRows) --%>
<main class="biz-main">
  <div class="biz-page-head">
    <h1 class="biz-page-title">리뷰 관리</h1>
    <p class="biz-page-desc"><c:out value="${reviewPageDesc}"/></p>
  </div>

  <%-- 답글·삭제요청 처리 결과 --%>
  <c:if test="${not empty msg}">
    <div style="margin-bottom:12px;padding:12px 16px;background:#E8F8F1;color:#1F8464;border-radius:8px;font-size:14px"><c:out value="${msg}"/></div>
  </c:if>
  <c:if test="${not empty errorMsg}">
    <div style="margin-bottom:12px;padding:12px 16px;background:#FEF2F2;color:#B91C1C;border-radius:8px;font-size:14px"><c:out value="${errorMsg}"/></div>
  </c:if>

  <div class="biz-card">
    <div style="padding:20px 20px 0">
      <div class="biz-tabs">
        <button type="button" class="biz-tab active" data-tab="all" onclick="BizReview.switchTab('all')">전체<span class="biz-tab-count" id="cntAll"></span></button>
        <button type="button" class="biz-tab" data-tab="pending" onclick="BizReview.switchTab('pending')">삭제요청<span class="biz-tab-count" id="cntPending"></span></button>
        <button type="button" class="biz-tab" data-tab="approved" onclick="BizReview.switchTab('approved')">삭제승인<span class="biz-tab-count" id="cntApproved"></span></button>
        <button type="button" class="biz-tab" data-tab="rejected" onclick="BizReview.switchTab('rejected')">삭제반려<span class="biz-tab-count" id="cntRejected"></span></button>
        <div class="biz-tabs-right" id="sortWrap">
          <select class="biz-select-sm" id="sortSelect" onchange="BizReview.render()">
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

<%-- 답글 저장 / 삭제요청은 숨김 폼으로 POST --%>
<form id="replyForm" method="post" action="${contextPath}${reviewBaseUrl}/reply" style="display:none">
  <input type="hidden" name="_csrf" value="${_csrf}">
  <input type="hidden" name="reviewId" id="replyFormReviewId">
  <textarea name="bizReply" id="replyFormText"></textarea>
</form>
<form id="deleteReqForm" method="post" action="${contextPath}${reviewBaseUrl}/delete-request" style="display:none">
  <input type="hidden" name="_csrf" value="${_csrf}">
  <input type="hidden" name="reviewId" id="delFormReviewId">
  <input type="hidden" name="requestReason" id="delFormReason">
</form>

<script src="${contextPath}/resources/js/biz-review.js"></script>
<script>
  BizReview.init({
    reviews: ${empty reviewListJson ? '[]' : reviewListJson},
    deleteRequests: ${empty deleteRequestListJson ? '[]' : deleteRequestListJson},
    contextPath: '${contextPath}',
    replyLabel: '${replyLabel}',
    showThumbnail: ${showThumbnail eq true},
    showReports: ${showReports eq true}
  });
</script>
