<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="반려동물 쇼핑몰" />
<c:set var="bizPage"      value="qna" />

<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_store.jsp" %>

<main class="biz-main">
  <div class="biz-page-head">
    <h1 class="biz-page-title">Q&amp;A 관리</h1>
    <p class="biz-page-desc">상품 문의를 확인하고 답변을 작성하세요.</p>
  </div>

  <c:if test="${not empty msg}"><div class="biz-card" style="padding:14px 20px;margin-bottom:16px;color:#2BAB82;font-weight:700">${msg}</div></c:if>
  <c:if test="${not empty errorMsg}"><div class="biz-card" style="padding:14px 20px;margin-bottom:16px;color:#E24B4A;font-weight:700">${errorMsg}</div></c:if>

  <%-- 지윤 26.07.22 추가: 리뷰관리와 동일한 전체/미답변 탭 (서버사이드 렌더링이라 JS로 행 숨김/카운트 처리) --%>
  <c:set var="unansweredCount" value="0" />
  <c:forEach var="q" items="${qnaList}"><c:if test="${empty q.answer}"><c:set var="unansweredCount" value="${unansweredCount + 1}" /></c:if></c:forEach>

  <div class="biz-card">
    <div style="padding:20px 20px 0">
      <div class="biz-tabs">
        <button type="button" class="biz-tab active" data-tab="all" onclick="qnaSwitchTab('all', this)">전체<span class="biz-tab-count">${fn:length(qnaList)}</span></button>
        <button type="button" class="biz-tab" data-tab="unanswered" onclick="qnaSwitchTab('unanswered', this)">미답변<span class="biz-tab-count">${unansweredCount}</span></button>
      </div>
    </div>

    <c:choose>
      <c:when test="${empty qnaList}">
        <div class="biz-review-empty">등록된 문의가 없습니다.</div>
      </c:when>
      <c:otherwise>
        <div class="biz-review-list">
          <c:forEach var="q" items="${qnaList}">

           <div class="biz-review-item" data-answered="${not empty q.answer}">
              <div class="biz-review-main">
                <%-- 지윤 26.07.22 수정: 리뷰관리와 동일한 상품 썸네일+상품명 상단 블록 (옵션은 Q&A 특성상 없음 - 구매내역과 무관한 일반 문의라 특정 옵션이 없음) --%>
                <div class="biz-review-product-row">
                  <c:choose>
                    <c:when test="${not empty q.thumbnailUrl}"><img class="biz-review-thumb" src="${fn:startsWith(q.thumbnailUrl,'http') ? q.thumbnailUrl : contextPath.concat('/upload/').concat(q.thumbnailUrl)}"></c:when>
                    <c:otherwise><div class="biz-review-thumb biz-review-thumb-empty"></div></c:otherwise>
                  </c:choose>
                  <div class="biz-review-product-info">
                    <div class="biz-review-product-name">${q.productName}</div>
                    <c:if test="${not empty q.optionSize}">
                      <div class="biz-review-option">옵션: <c:if test="${not empty q.optionColor && q.optionColor != '기본'}">${q.optionColor} / </c:if>${q.optionSize}</div>
                    </c:if>
                  </div>
                </div>
                <div class="biz-review-top">
                  <span class="biz-review-author">${q.nickname}</span>
                 <span class="biz-review-date">${q.regDate}</span>
                  <c:if test="${empty q.answer}"><span class="biz-review-reported">미답변</span></c:if>
                </div>
                <div class="biz-review-content">${q.question}</div>

                <%-- 지윤 26.07.22 수정: 답변에도 날짜 표시 (단, 실제 "답변한 시각"을 저장하는 컬럼이 없어서 REG_DATE(질문 등록일)를 그대로 씀 - 나중에 ANSWER_DATE 컬럼 추가하면 정확해짐) --%>
                <c:if test="${not empty q.answer}">
                  <div class="biz-review-reply"><span class="biz-review-reply-label">답변</span><span class="biz-review-reply-date">${q.answerDate}</span><div class="biz-review-reply-text">${q.answer}</div></div>
                </c:if>

                <%-- 지윤 26.07.22 수정: 리뷰관리와 동일하게 기본 접힘, "답변쓰기/답변수정" 눌러야 폼 펼쳐지게 변경 --%>
                <form method="post" action="${contextPath}/biz/store/qna/answer" class="biz-reply-box" id="answer-box-${q.qnaId}" style="display:none">
                  <!--HYJ 26.08.05-->
                  <input type="hidden" name="_csrf" value="${_csrf}">
                  
                  <input type="hidden" name="qnaId" value="${q.qnaId}">
                  <div class="biz-reply-box-label"><svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>${empty q.answer ? '답변 작성' : '답변 수정'}</div>
                  <textarea name="answer" placeholder="답변 내용을 입력해주세요" required>${q.answer}</textarea>
                  <div class="biz-reply-box-actions">
                    <button type="button" class="btn-cancel" onclick="document.getElementById('answer-box-${q.qnaId}').style.display='none'">취소</button>
                    <button type="submit" class="btn-submit">${empty q.answer ? '등록' : '수정'}</button>
                  </div>
                </form>
              </div>
              <div class="biz-review-actions">
                <button class="biz-btn" onclick="var b=document.getElementById('answer-box-${q.qnaId}'); b.style.display = (b.style.display==='none' ? 'block' : 'none')">${empty q.answer ? '답변쓰기' : '답변수정'}</button>
              </div>
            </div>
          </c:forEach>
        </div>
      </c:otherwise>
    </c:choose>
  </div>
</main>

<script>
  //지윤 26.07.22 추가: Q&A 전체/미답변 탭 전환 (서버사이드 렌더링된 행을 data-answered 기준으로 숨김/표시)
  function qnaSwitchTab(tab, btn) {
    document.querySelectorAll('.biz-tab').forEach(function (b) { b.classList.remove('active'); });
    btn.classList.add('active');
    document.querySelectorAll('.biz-review-item').forEach(function (item) {
      var show = (tab === 'all') || (tab === 'unanswered' && item.dataset.answered === 'false');
      item.style.display = show ? '' : 'none';
    });
  }
</script>

<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>