<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="adminPage" value="cms-faq" />
<%@ include file="/WEB-INF/views/admin/common/header.jsp" %>
<%@ include file="/WEB-INF/views/admin/common/sidebar.jsp" %>
<main class="adm-main">
    <div class="adm-page-head">
        <div class="adm-page-head-left">
            <h1 class="adm-page-title">${isEdit ? 'FAQ 수정' : 'FAQ 등록'}</h1>
            <p class="adm-page-desc">고객센터 FAQ를 등록합니다.</p>
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
                  action="${contextPath}/admin/cms/faq/${isEdit ? 'update' : 'save'}">
                  <input type="hidden" name="_csrf" value="${_csrf}">
                <c:if test="${isEdit}">
                    <input type="hidden" name="faqId" value="${faq.faqId}">
                </c:if>

                <div style="display:flex;flex-direction:column;gap:16px">
                    <div style="display:flex;flex-direction:column;gap:6px">
                        <label style="font-size:13px;font-weight:600">카테고리</label>
                        <select name="categoryCd" required
                                style="border:1px solid #E4E6ED;border-radius:8px;padding:10px 14px;font-size:14px">
                            <option value="SERVICE" ${faq.categoryCd eq 'SERVICE' ? 'selected' : ''}>서비스</option>
                            <option value="ORDER"   ${faq.categoryCd eq 'ORDER'   ? 'selected' : ''}>주문/배송</option>
                            <option value="MEMBER"  ${faq.categoryCd eq 'MEMBER'  ? 'selected' : ''}>회원</option>
                            <option value="RESERVE" ${faq.categoryCd eq 'RESERVE' ? 'selected' : ''}>예약</option>
                        </select>
                    </div>

                    <div style="display:flex;flex-direction:column;gap:6px">
                        <label style="font-size:13px;font-weight:600">질문</label>
                        <input type="text" name="question" required
                               value="<c:out value='${faq.question}'/>"
                               style="border:1px solid #E4E6ED;border-radius:8px;padding:10px 14px;font-size:14px">
                    </div>

                    <div style="display:flex;flex-direction:column;gap:6px">
                        <label style="font-size:13px;font-weight:600">답변</label>
                        <textarea name="answer" required
                                  style="min-height:200px;border:1px solid #E4E6ED;border-radius:8px;padding:14px;font-size:14px;line-height:1.7;font-family:inherit"><c:out value="${faq.answer}"/></textarea>
                    </div>

                    <div style="display:flex;flex-direction:column;gap:6px">
                        <label style="font-size:13px;font-weight:600">정렬 순서</label>
                        <input type="number" name="sortOrder" min="0"
                               value="${empty faq.sortOrder ? 0 : faq.sortOrder}"
                               style="border:1px solid #E4E6ED;border-radius:8px;padding:10px 14px;font-size:14px;width:120px">
                        <small style="color:#999">숫자가 작을수록 위에 표시됩니다.</small>
                    </div>

                    <div style="display:flex;align-items:center;gap:8px;font-size:14px">
                        <input type="checkbox" id="faqVisible" name="visibleYn" value="Y"
                               ${empty faq || faq.visibleYn ne 'N' ? 'checked' : ''}>
                        <label for="faqVisible">노출</label>
                    </div>
                </div>

                <div style="display:flex;justify-content:flex-end;gap:10px;margin-top:24px">
                    <a href="${contextPath}/admin/cms/faq" class="adm-btn gray" style="text-decoration:none">취소</a>
                    <c:if test="${isEdit}">
                        <button type="submit" formaction="${contextPath}/admin/cms/faq/delete"
                                formmethod="post" class="adm-btn"
                                style="background:#FEE2E2;color:#B91C1C;border:1px solid #FECACA"
                                onclick="return confirm('이 FAQ를 삭제할까요?');">삭제</button>
                    </c:if>
                    <button type="submit" class="adm-btn blue">${isEdit ? '수정' : '등록'}</button>
                </div>
            </form>
        </div>
    </div>
</main>
<%@ include file="/WEB-INF/views/admin/common/footer.jsp" %>
