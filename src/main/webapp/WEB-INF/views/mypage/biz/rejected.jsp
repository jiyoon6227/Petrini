<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="mypage" />
<%@ include file="/WEB-INF/views/common/header.jsp" %>
<style>
  .complete-wrap{max-width:560px;margin:60px auto 80px;padding:0 20px;text-align:center}
  .reject-icon{width:80px;height:80px;border-radius:50%;background:#FEF2F2;display:flex;align-items:center;justify-content:center;margin:0 auto 24px}
  .reject-icon svg{width:40px;height:40px;stroke:#DC2626;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}
  .complete-title{font-size:24px;font-weight:800;color:var(--text-main);margin-bottom:8px}
  .complete-desc{font-size:15px;color:var(--text-muted);margin-bottom:32px;line-height:1.6}
  .complete-card{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);padding:24px;text-align:left;margin-bottom:24px}
  .complete-card h3{font-size:14px;font-weight:700;color:var(--text-main);margin:0 0 16px;padding-bottom:12px;border-bottom:1px solid var(--border)}
  .complete-row{display:flex;justify-content:space-between;font-size:14px;margin-bottom:10px;gap:12px}
  .complete-row:last-child{margin-bottom:0}
  .complete-row span:first-child{color:var(--text-muted);flex-shrink:0}
  .complete-row span:last-child{color:var(--text-main);font-weight:600;text-align:right;word-break:break-all}
  .reject-reason-box{background:#FEF2F2;border:1px solid #FECACA;border-radius:var(--radius-sm);padding:16px 18px;font-size:14px;color:#991B1B;line-height:1.7;text-align:left;margin-bottom:24px;white-space:pre-wrap}
  .complete-btns{display:flex;gap:12px}
  .btn-complete-sub{flex:1;padding:13px;border:2px solid #2BAB82;border-radius:var(--radius-sm);background:#fff;color:#2BAB82;font-size:15px;font-weight:700;cursor:pointer}
  .btn-complete-main{flex:1;padding:13px;border:none;border-radius:var(--radius-sm);background:#2BAB82;color:#fff;font-size:15px;font-weight:700;cursor:pointer}
</style>

<div class="complete-wrap">

  <div class="reject-icon">
    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
  </div>

  <div class="complete-title">사업자 등록 신청이 반려되었습니다</div>
  <div class="complete-desc">
    아래 반려 사유를 확인하신 후<br>
    내용을 보완하여 <strong>다시 신청</strong>해 주세요.
  </div>

  <div class="complete-card">
    <h3>신청 정보</h3>
    <div class="complete-row"><span>상호명</span><span>${apply.bizName}</span></div>
    <div class="complete-row"><span>업종</span><span>${apply.bizType}</span></div>
    <div class="complete-row"><span>사업자등록번호</span><span>${apply.bizRegNo}</span></div>
    <div class="complete-row"><span>처리 상태</span><span style="color:#DC2626;font-weight:700">반려</span></div>
  </div>

  <div class="reject-reason-box">
    <strong>관리자 반려 사유</strong><br><br>
    <c:choose>
      <c:when test="${not empty apply.rejectReason}">${apply.rejectReason}</c:when>
      <c:otherwise>반려 사유가 등록되지 않았습니다. 고객센터로 문의해 주세요.</c:otherwise>
    </c:choose>
  </div>

  <div class="complete-btns">
    <button class="btn-complete-sub" type="button" onclick="location.href='${contextPath}/mypage'">마이페이지</button>
    <button class="btn-complete-main" type="button" onclick="location.href='${contextPath}/mypage/biz/apply?reapply=Y'">다시 신청하기</button>
  </div>

</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
