<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="cs" />
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
.cs-inquiry-write-wrap {
    max-width: 760px;
    margin: 36px auto 80px;
    padding: 0 20px;
}
.cs-inquiry-back {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    font-size: 14px;
    color: var(--text-muted);
    text-decoration: none;
    margin-bottom: 20px;
}
.cs-inquiry-back:hover { color: var(--primary); }
.cs-inquiry-back svg {
    width: 16px;
    height: 16px;
    stroke: currentColor;
    fill: none;
    stroke-width: 2;
    stroke-linecap: round;
    stroke-linejoin: round;
}
.cs-inquiry-write-card {
    background: var(--bg-card);
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    padding: 28px 24px;
}
.cs-inquiry-write-title {
    font-size: 22px;
    font-weight: 800;
    color: var(--text-main);
    margin: 0 0 24px;
}
.cs-form-group {
    display: flex;
    flex-direction: column;
    gap: 8px;
    margin-bottom: 18px;
}
.cs-form-group label {
    font-size: 13px;
    font-weight: 700;
    color: var(--text-sub);
}
.cs-form-group select,
.cs-form-group input,
.cs-form-group textarea {
    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
    padding: 12px 14px;
    font-size: 14px;
    color: var(--text-main);
    outline: none;
    font-family: inherit;
    box-sizing: border-box;
}
.cs-form-group select:focus,
.cs-form-group input:focus,
.cs-form-group textarea:focus {
    border-color: var(--primary);
}
.cs-form-group textarea {
    min-height: 220px;
    resize: vertical;
    line-height: 1.7;
}
.cs-form-error {
    margin-bottom: 16px;
    padding: 12px 14px;
    border-radius: var(--radius-sm);
    background: #fef2f2;
    border: 1px solid #fecaca;
    color: #b91c1c;
    font-size: 13px;
}
.cs-form-actions {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
    margin-top: 8px;
}
.btn-inquiry-cancel {
    padding: 12px 22px;
    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
    background: #fff;
    color: var(--text-sub);
    font-size: 14px;
    font-weight: 700;
    text-decoration: none;
}
.btn-inquiry-submit {
    padding: 12px 24px;
    border: none;
    border-radius: var(--radius-sm);
    background: var(--primary);
    color: #fff;
    font-size: 14px;
    font-weight: 700;
    cursor: pointer;
}
.btn-inquiry-submit:hover { background: var(--primary-dark); }
</style>

<div class="cs-inquiry-write-wrap">
    <a href="${contextPath}/member/cs/inquiry" class="cs-inquiry-back">
        <svg viewBox="0 0 24 24"><path d="M19 12H5"/><polyline points="12 19 5 12 12 5"/></svg>
        문의 목록
    </a>

    <div class="cs-inquiry-write-card">
        <h1 class="cs-inquiry-write-title">
          <c:choose>
            <c:when test="${stayRefund}">숙소 환불 신청</c:when>
            <c:otherwise>1:1 문의 작성</c:otherwise>
          </c:choose>
        </h1>

        <c:if test="${not empty errorMsg}">
            <p class="cs-form-error"><c:out value="${errorMsg}"/></p>
        </c:if>
        <c:if test="${param.error eq 'empty'}">
            <p class="cs-form-error">문의 유형, 제목, 내용을 모두 입력해 주세요.</p>
        </c:if>
        <c:if test="${param.error eq 'fail'}">
            <p class="cs-form-error">신청에 실패했습니다. 예약 상태·중복 신청 여부를 확인해 주세요.</p>
        </c:if>

        <form action="${contextPath}/member/cs/inquiry/write" method="post">
            <!--HYJ 26.08.05-->
            <input type="hidden" name="_csrf" value="${_csrf}">
            
            <c:if test="${stayRefund}">
              <input type="hidden" name="type" value="stay_refund">
              <input type="hidden" name="resvId" value="${resvId}">
              <input type="hidden" name="category" value="예약">
              <p style="font-size:13px;color:#666;margin:0 0 16px;line-height:1.5">
                예약번호 <strong><c:out value="${reservation.resvNo}"/></strong>
                · 관리자 검토 후 환불 승인/거절이 진행됩니다.
              </p>
            </c:if>

            <c:if test="${!stayRefund}">
            <p style="font-size:13px;color:var(--text-muted);margin:0 0 16px;line-height:1.6;padding:12px 14px;background:#F8FAFC;border:1px solid var(--border);border-radius:var(--radius-sm)">
                주문·배송, 결제·환불 문의는 <a href="${contextPath}/member/cs" style="color:var(--primary);font-weight:700;text-decoration:none">고객센터 FAQ</a>를 먼저 확인해 주세요.<br>
                숙소 환불 신청은 예약 상세 화면에서 별도로 접수됩니다.
            </p>
            <div class="cs-form-group">
                <label for="category">문의 유형</label>
                <select id="category" name="category" required>
                    <option value="">유형을 선택하세요</option>
                    <option value="회원">회원 (계정·정지 등)</option>
                    <option value="예약">예약</option>
                    <option value="기타">기타</option>
                </select>
            </div>
            </c:if>

            <div class="cs-form-group">
                <label for="title">제목</label>
                <input type="text" id="title" name="title" placeholder="제목을 입력하세요" required maxlength="100"
                       value="<c:if test='${stayRefund}'>숙소 환불신청 #<c:out value='${reservation.resvNo}'/></c:if>">
            </div>

            <div class="cs-form-group">
                <label for="content">내용</label>
                <textarea id="content" name="content" placeholder="문의 내용을 자세히 입력해 주세요." required><c:if test="${stayRefund}">숙소 이용 중 환불을 신청합니다.&#10;사유: </c:if></textarea>
            </div>

            <div class="cs-form-actions">
                <a href="${contextPath}/member/cs/inquiry" class="btn-inquiry-cancel">취소</a>
                <button type="submit" class="btn-inquiry-submit">
                  <c:choose>
                    <c:when test="${stayRefund}">환불 신청하기</c:when>
                    <c:otherwise>등록하기</c:otherwise>
                  </c:choose>
                </button>
            </div>
        </form>
    </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
