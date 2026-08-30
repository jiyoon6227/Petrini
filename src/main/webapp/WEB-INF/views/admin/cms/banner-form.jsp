<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="adminPage" value="cms-banner" />
<c:set var="isEdit" value="${param.mode eq 'edit'}" />
<%@ include file="/WEB-INF/views/admin/common/header.jsp" %>
<%@ include file="/WEB-INF/views/admin/common/sidebar.jsp" %>
<main class="adm-main">
    <div class="adm-page-head">
        <div class="adm-page-head-left">
            <h1 class="adm-page-title">${isEdit ? '배너 수정' : '배너 등록'}</h1>
            <p class="adm-page-desc">메인 화면에 노출할 배너를 설정합니다.</p>
        </div>
    </div>
    <div class="adm-card">
        <div class="adm-card-body" style="padding:24px">
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px 20px">
                <div style="grid-column:1/-1;display:flex;flex-direction:column;gap:6px">
                    <label style="font-size:13px;font-weight:600">배너 제목</label>
                    <input type="text" value="${isEdit ? '여름맞이 반려동물 케어 특가' : ''}" style="border:1px solid #E4E6ED;border-radius:8px;padding:10px 14px;font-size:14px">
                </div>
                <div style="display:flex;flex-direction:column;gap:6px">
                    <label style="font-size:13px;font-weight:600">노출 순서</label>
                    <input type="number" value="${isEdit ? '1' : ''}" style="border:1px solid #E4E6ED;border-radius:8px;padding:10px 14px;font-size:14px">
                </div>
                <div style="display:flex;flex-direction:column;gap:6px">
                    <label style="font-size:13px;font-weight:600">노출 여부</label>
                    <select style="border:1px solid #E4E6ED;border-radius:8px;padding:10px 14px;font-size:14px">
                        <option selected>노출</option>
                        <option>숨김</option>
                    </select>
                </div>
                <div style="display:flex;flex-direction:column;gap:6px">
                    <label style="font-size:13px;font-weight:600">시작일</label>
                    <input type="date" value="2025-06-01" style="border:1px solid #E4E6ED;border-radius:8px;padding:10px 14px;font-size:14px">
                </div>
                <div style="display:flex;flex-direction:column;gap:6px">
                    <label style="font-size:13px;font-weight:600">종료일</label>
                    <input type="date" value="2025-08-31" style="border:1px solid #E4E6ED;border-radius:8px;padding:10px 14px;font-size:14px">
                </div>
                <div style="grid-column:1/-1;display:flex;flex-direction:column;gap:6px">
                    <label style="font-size:13px;font-weight:600">링크 URL</label>
                    <input type="text" value="${isEdit ? '/store' : ''}" placeholder="/store" style="border:1px solid #E4E6ED;border-radius:8px;padding:10px 14px;font-size:14px">
                </div>
                <div style="grid-column:1/-1;display:flex;flex-direction:column;gap:6px">
                    <label style="font-size:13px;font-weight:600">배너 이미지</label>
                    <input type="file" accept="image/*" style="font-size:13px">
                </div>
            </div>
            <div style="display:flex;justify-content:flex-end;gap:10px;margin-top:24px">
                <a href="${contextPath}/admin/cms/banner" class="adm-btn gray" style="text-decoration:none">취소</a>
                <button type="button" class="adm-btn blue" onclick="alert('저장되었습니다.');location.href='${contextPath}/admin/cms/banner'">${isEdit ? '수정' : '등록'}</button>
            </div>
        </div>
    </div>
</main>
<%@ include file="/WEB-INF/views/admin/common/footer.jsp" %>
