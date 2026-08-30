<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="adminPage" value="cms-notice" />
<%@ include file="/WEB-INF/views/admin/common/header.jsp" %>
<%@ include file="/WEB-INF/views/admin/common/sidebar.jsp" %>
<main class="adm-main">
    <div class="adm-page-head">
        <div class="adm-page-head-left">
            <h1 class="adm-page-title">${isEdit ? '공지 수정' : '공지 등록'}</h1>
            <p class="adm-page-desc">고객센터에 노출될 공지사항을 작성합니다.</p>
        </div>
    </div>
    <div class="adm-card">
        <div class="adm-card-body" style="padding:24px">
            <c:if test="${not empty errorMsg}">
                <div style="background:#FEF2F2;border:1px solid #FECACA;color:#B91C1C;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:14px">
                    <c:out value="${errorMsg}"/>
                </div>
            </c:if>

            <form method="post"
                  action="${contextPath}/admin/cms/notice/${isEdit ? 'update' : 'save'}">
                <input type="hidden" name="_csrf" value="${_csrf}">
                <c:if test="${isEdit}">
                    <input type="hidden" name="noticeId" value="${notice.noticeId}">
                </c:if>

                <div style="display:flex;flex-direction:column;gap:16px">
                    <div style="display:flex;flex-direction:column;gap:6px">
                        <label style="font-size:13px;font-weight:600">유형</label>
                        <select name="noticeTypeCd"
                                style="border:1px solid #E4E6ED;border-radius:8px;padding:10px 14px;font-size:14px">
                            <option value="NOTICE" ${notice.noticeTypeCd eq 'NOTICE' || empty notice ? 'selected' : ''}>공지</option>
                            <option value="INFO"   ${notice.noticeTypeCd eq 'INFO' ? 'selected' : ''}>안내</option>
                        </select>
                    </div>

                    <div style="display:flex;flex-direction:column;gap:6px">
                        <label style="font-size:13px;font-weight:600">제목</label>
                        <input type="text" name="title" required
                               value="<c:out value='${notice.title}'/>"
                               style="border:1px solid #E4E6ED;border-radius:8px;padding:10px 14px;font-size:14px">
                    </div>

                    <div style="display:flex;flex-direction:column;gap:6px">
                        <label style="font-size:13px;font-weight:600">작성자</label>
                        <%-- 2026-08-11 박유정 — 등록 시 기본값 펫린이 운영팀 --%>
                        <c:set var="writerNameVal" value="${empty notice || empty notice.writerName ? '펫린이 운영팀' : notice.writerName}"/>
                        <input type="text" name="writerName"
                               value="<c:out value='${writerNameVal}'/>"
                               style="border:1px solid #E4E6ED;border-radius:8px;padding:10px 14px;font-size:14px">
                    </div>

                    <div style="display:flex;align-items:center;gap:16px;font-size:14px;flex-wrap:wrap">
                        <label style="display:flex;align-items:center;gap:8px">
                            <input type="checkbox" id="pinNotice" name="pinYn" value="Y"
                                   ${fn:trim(notice.pinYn) eq 'Y' ? 'checked' : ''}>
                            상단 고정
                        </label>
                        <label style="display:flex;align-items:center;gap:8px">
                            <input type="checkbox" id="noticeVisible" name="visibleYn" value="Y"
                                   ${empty notice || fn:trim(notice.visibleYn) ne 'N' ? 'checked' : ''}>
                            노출
                        </label>
                    </div>

                    <div style="display:flex;flex-direction:column;gap:6px">
                        <label style="font-size:13px;font-weight:600">내용</label>
                        <textarea name="body" required
                                  style="min-height:280px;border:1px solid #E4E6ED;border-radius:8px;padding:14px;font-size:14px;line-height:1.7;font-family:inherit"><c:out value="${notice.body}"/></textarea>
                    </div>
                </div>

                <div style="display:flex;justify-content:flex-end;gap:10px;margin-top:24px">
                    <a href="${contextPath}/admin/cms/notice" class="adm-btn gray" style="text-decoration:none">취소</a>
                    <c:if test="${isEdit}">
                        <button type="submit" formaction="${contextPath}/admin/cms/notice/delete"
                                formmethod="post" class="adm-btn"
                                style="background:#FEE2E2;color:#B91C1C;border:1px solid #FECACA"
                                onclick="return confirm('이 공지를 삭제할까요?');">삭제</button>
                    </c:if>
                    <button type="submit" class="adm-btn blue">${isEdit ? '수정' : '등록'}</button>
                </div>
            </form>
        </div>
    </div>
</main>
<%@ include file="/WEB-INF/views/admin/common/footer.jsp" %>
