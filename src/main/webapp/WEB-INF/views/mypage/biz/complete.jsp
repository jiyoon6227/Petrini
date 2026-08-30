<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="mypage" />
<%@ include file="/WEB-INF/views/common/header.jsp" %>
<style>
  .complete-wrap{max-width:560px;margin:60px auto 80px;padding:0 20px;text-align:center}
  .complete-icon{width:80px;height:80px;border-radius:50%;background:#EAF7F2;display:flex;align-items:center;justify-content:center;margin:0 auto 24px}
  .complete-icon svg{width:40px;height:40px;stroke:#2BAB82;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}
  .complete-title{font-size:24px;font-weight:800;color:var(--text-main);margin-bottom:8px}
  .complete-desc{font-size:15px;color:var(--text-muted);margin-bottom:32px;line-height:1.6}
  .complete-card{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);padding:24px;text-align:left;margin-bottom:24px}
  .complete-card h3{font-size:14px;font-weight:700;color:var(--text-main);margin:0 0 16px;padding-bottom:12px;border-bottom:1px solid var(--border)}
  .complete-row{display:flex;justify-content:space-between;font-size:14px;margin-bottom:10px}
  .complete-row:last-child{margin-bottom:0}
  .complete-row span:first-child{color:var(--text-muted)}
  .complete-row span:last-child{color:var(--text-main);font-weight:600}
  .complete-notice{background:#F0FDF4;border:1px solid #BBF7D0;border-radius:var(--radius-sm);padding:16px 18px;font-size:13px;color:#166534;line-height:1.7;text-align:left;margin-bottom:24px}
  .complete-notice strong{color:#15803D}
  .complete-steps{display:flex;gap:0;margin-bottom:24px;position:relative}
  .complete-step{flex:1;text-align:center;position:relative}
  .complete-step-dot{width:32px;height:32px;border-radius:50%;border:2px solid var(--border);background:#fff;display:flex;align-items:center;justify-content:center;margin:0 auto 8px;font-size:12px;font-weight:700;color:var(--text-muted);position:relative;z-index:1}
  .complete-step.done .complete-step-dot{background:#2BAB82;border-color:#2BAB82;color:#fff}
  .complete-step.current .complete-step-dot{background:#FEF3C7;border-color:#F59E0B;color:#92400E}
  .complete-step-label{font-size:11px;color:var(--text-muted)}
  .complete-step.done .complete-step-label{color:#2BAB82;font-weight:600}
  .complete-step.current .complete-step-label{color:#92400E;font-weight:600}
  .complete-step-line{position:absolute;top:16px;left:50%;right:-50%;height:2px;background:var(--border);z-index:0}
  .complete-step.done .complete-step-line{background:#2BAB82}
  .complete-step:last-child .complete-step-line{display:none}
  .complete-btns{display:flex;gap:12px}
  .btn-complete-sub{flex:1;padding:13px;border:2px solid #2BAB82;border-radius:var(--radius-sm);background:#fff;color:#2BAB82;font-size:15px;font-weight:700;cursor:pointer}
  .btn-complete-main{flex:1;padding:13px;border:none;border-radius:var(--radius-sm);background:#2BAB82;color:#fff;font-size:15px;font-weight:700;cursor:pointer}
</style>

<div class="complete-wrap">

  <%-- 아이콘 --%>
  <div class="complete-icon">
    <svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>
  </div>

  <div class="complete-title">사업자 등록 신청이 완료되었습니다!</div>
  <div class="complete-desc">
    관리자 심사 후 영업일 <strong>3~5일 이내</strong>에<br>
    등록하신 이메일로 결과를 안내해 드립니다.
  </div>

  <%-- 진행 단계 --%>
  <div class="complete-steps">
    <div class="complete-step done">
      <div class="complete-step-line"></div>
      <div class="complete-step-dot">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor"
             stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
          <polyline points="20 6 9 17 4 12"/>
        </svg>
      </div>
      <div class="complete-step-label">신청서 작성</div>
    </div>
    <div class="complete-step done">
      <div class="complete-step-line"></div>
      <div class="complete-step-dot">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor"
             stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
          <polyline points="20 6 9 17 4 12"/>
        </svg>
      </div>
      <div class="complete-step-label">서류 제출</div>
    </div>
    <div class="complete-step current">
      <div class="complete-step-line"></div>
      <div class="complete-step-dot">3</div>
      <div class="complete-step-label">관리자 심사중</div>
    </div>
    <div class="complete-step">
      <div class="complete-step-line"></div>
      <div class="complete-step-dot">4</div>
      <div class="complete-step-label">승인 완료</div>
    </div>
  </div>

  <%-- 신청 정보 카드 --%>
  <div class="complete-card">
    <h3>신청 정보</h3>
    <div class="complete-row">
      <span>상호명</span>
      <span>${not empty biz.bizName ? biz.bizName : bizName}</span>
    </div>
    <div class="complete-row">
      <span>업종</span>
      <span>
        <c:set var="bt" value="${not empty biz.bizType ? biz.bizType : bizType}" />
        <c:choose>
          <c:when test="${bt == 'HOSPITAL'}">동물병원</c:when>
          <c:when test="${bt == 'GROOMING'}">반려동물 미용</c:when>
          <c:when test="${bt == 'STAY'}">펫 호텔·유치원</c:when>
          <c:when test="${bt == 'STORE'}">반려동물 용품점</c:when>
          <c:when test="${bt == 'STUDIO'}">스튜디오</c:when>
          <c:otherwise>${bt}</c:otherwise>
        </c:choose>
      </span>
    </div>
    <div class="complete-row">
      <span>사업자등록번호</span>
      <span>${not empty biz.bizRegNo ? biz.bizRegNo : bizRegNo}</span>
    </div>
    <div class="complete-row">
      <span>처리 상태</span>
      <span style="color:#F59E0B;font-weight:700">심사중</span>
    </div>
  </div>

  <%-- 안내 문구 --%>
  <div class="complete-notice">
    <strong>안내사항</strong><br>
    · 심사 결과는 가입 시 등록한 이메일과 알림함으로 발송됩니다.<br>
    · 서류 보완이 필요한 경우 별도 안내드립니다.<br>
    · 승인 후 사업자 전용 관리 페이지를 이용하실 수 있습니다.<br>
    · 문의사항은 고객센터(1588-1234)로 연락해 주세요.
  </div>

  <%-- 버튼 --%>
  <div class="complete-btns">
    <button class="btn-complete-sub"
            onclick="location.href='${contextPath}/mypage'">마이페이지</button>
    <button class="btn-complete-main"
            onclick="location.href='${contextPath}/'">홈으로</button>
  </div>

</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
