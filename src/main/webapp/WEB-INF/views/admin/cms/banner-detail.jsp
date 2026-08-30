<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
  역할: 관리자 배너 광고 상세
  - 2026-08-06 박유정 — 기간 변경, 광고 올리기/내리기, 승인·대기·반려
  - 2026-08-07 박유정 — 배너 정보 수정 (제목·링크·이미지), 미리보기 URL 분기
--%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="adminPage" value="cms-banner" />
<%@ include file="/WEB-INF/views/admin/common/header.jsp" %>
<%@ include file="/WEB-INF/views/admin/common/sidebar.jsp" %>

<style>
    .banner-detail-breadcrumb{font-size:13px;color:#999;margin-bottom:20px;display:flex;align-items:center;gap:8px}
    .banner-detail-breadcrumb a{color:#999;text-decoration:none}
    .banner-detail-breadcrumb a:hover{color:#3B5BDB}
    .banner-detail-grid{display:grid;grid-template-columns:1fr 340px;gap:20px;align-items:flex-start}
    .banner-preview-card{background:#fff;border:1px solid #E4E6ED;border-radius:12px;overflow:hidden}
    .banner-preview-head{padding:18px 22px;border-bottom:1px solid #E4E6ED}
    .banner-preview-img{width:100%;max-height:280px;object-fit:cover;display:block;background:#F5F5F5}
    .banner-preview-body{padding:22px}
    .banner-info-row{display:flex;gap:12px;padding:10px 0;border-bottom:1px solid #F5F5F5;font-size:13px}
    .banner-info-row:last-child{border-bottom:none}
    .banner-info-label{width:92px;color:#999;flex-shrink:0}
    .banner-info-value{color:#333;word-break:break-all}
    .banner-side-card{background:#fff;border:1px solid #E4E6ED;border-radius:12px;padding:20px;margin-bottom:16px}
    .banner-side-title{font-size:14px;font-weight:800;color:#1A1A2E;margin:0 0 14px;padding-bottom:12px;border-bottom:1px solid #E4E6ED}
    .banner-side-form{display:flex;flex-direction:column;gap:10px}
    .banner-side-form label{font-size:12px;font-weight:600;color:#666}
    .banner-side-form input{width:100%;box-sizing:border-box;border:1px solid #E4E6ED;border-radius:8px;padding:9px 12px;font-size:13px}
    .banner-action-btns{display:flex;flex-direction:column;gap:8px}
    .banner-action-btns form{display:block;width:100%}
    .banner-action-btns .adm-btn{width:100%;box-sizing:border-box;text-align:center}
    @media(max-width:900px){.banner-detail-grid{grid-template-columns:1fr}}
</style>

<main class="adm-main">
    <div class="banner-detail-breadcrumb">
        <a href="${contextPath}/admin/cms/banner">배너 관리</a>
        <span>›</span>
        <span style="color:#1A1A2E;font-weight:600">광고 상세</span>
    </div>

    <c:if test="${not empty msg}">
        <div style="background:#ECFDF5;border:1px solid #A7F3D0;color:#065F46;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-weight:600">${msg}</div>
    </c:if>
    <c:if test="${not empty errorMsg}">
        <div style="background:#FFF1F2;border:1px solid #FECDD3;color:#BE123C;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-weight:600">${errorMsg}</div>
    </c:if>

    <div class="adm-page-head">
        <div class="adm-page-head-left">
            <h1 class="adm-page-title">광고 상세</h1>
            <p class="adm-page-desc">배너 정보를 확인하고 광고 기간 변경·올리기·내리기를 처리하세요.</p>
        </div>
        <div class="adm-page-actions">
            <c:if test="${banner.statusCd eq 'PENDING'}">
                <button type="button" class="adm-btn blue btn-approve" data-id="${banner.bannerId}">승인</button>
                <button type="button" class="adm-btn btn-hold" data-id="${banner.bannerId}">대기</button>
                <button type="button" class="adm-btn red btn-reject" data-id="${banner.bannerId}">반려</button>
            </c:if>
            <c:if test="${banner.statusCd eq 'HOLD'}">
                <button type="button" class="adm-btn blue btn-approve" data-id="${banner.bannerId}">승인</button>
                <button type="button" class="adm-btn red btn-reject" data-id="${banner.bannerId}">반려</button>
            </c:if>
        </div>
    </div>

    <div class="banner-detail-grid">
        <div class="banner-preview-card">
            <div class="banner-preview-head">
                <strong style="font-size:16px">${banner.title}</strong>
            </div>
            <c:choose>
                <c:when test="${not empty banner.imageUrl}">
                    <%-- 2026-08-07 박유정 — 미리보기 이미지 URL (외부 http /upload/ 분기) --%>
                    <c:set var="imgSrc" value="${banner.imageUrl}" />
                    <c:if test="${not fn:startsWith(banner.imageUrl, 'http')}">
                        <c:set var="imgSrc" value="${contextPath}/upload/${banner.imageUrl}" />
                    </c:if>
                    <img class="banner-preview-img" src="${imgSrc}" alt=""
                         onerror="this.src='https://placehold.co/800x280/EAF7F2/2BAB82?text=배너'">
                </c:when>
                <c:otherwise>
                    <div style="padding:80px 20px;text-align:center;color:#999;background:#FAFBFA">이미지 없음</div>
                </c:otherwise>
            </c:choose>
            <div class="banner-preview-body">
                <div class="banner-info-row">
                    <span class="banner-info-label">사업자</span>
                    <span class="banner-info-value">${banner.bizName}</span>
                </div>
                <div class="banner-info-row">
                    <span class="banner-info-label">노출 위치</span>
                    <span class="banner-info-value">
                        <span class="adm-badge">${banner.positionLabel}</span>
                        <span style="color:#666;margin-left:8px;font-size:12px">${banner.displayPageLabel}</span>
                    </span>
                </div>
                <div class="banner-info-row">
                    <span class="banner-info-label">노출 기간</span>
                    <span class="banner-info-value">${banner.startDate} ~ ${banner.endDate}</span>
                </div>
                <div class="banner-info-row">
                    <span class="banner-info-label">링크 URL</span>
                    <span class="banner-info-value">
                        <c:choose>
                            <c:when test="${not empty banner.linkUrl}">
                                <a href="${banner.linkUrl}" target="_blank" style="color:#3B5BDB">${banner.linkUrl}</a>
                            </c:when>
                            <c:otherwise>—</c:otherwise>
                        </c:choose>
                    </span>
                </div>
                <div class="banner-info-row">
                    <span class="banner-info-label">상태</span>
                    <span class="banner-info-value">
                        <%-- 2026-08-07 박유정 — effectiveStatusLabel (기간 반영) --%>
                        <c:choose>
                            <c:when test="${banner.effectiveStatusLabel eq '심사중'}"><span class="adm-badge warning">심사중</span></c:when>
                            <c:when test="${banner.effectiveStatusLabel eq '노출예정'}"><span class="adm-badge warning">노출예정</span></c:when>
                            <c:when test="${banner.effectiveStatusLabel eq '노출중'}"><span class="adm-badge active">노출중</span></c:when>
                            <c:when test="${banner.effectiveStatusLabel eq '노출 예정'}"><span class="adm-badge warning">노출 예정</span></c:when>
                            <c:when test="${banner.effectiveStatusLabel eq '반려'}"><span class="adm-badge danger">반려</span></c:when>
                            <c:when test="${banner.effectiveStatusLabel eq '미노출'}"><span class="adm-badge inactive">미노출</span></c:when>
                            <c:otherwise><span class="adm-badge">${banner.effectiveStatusLabel}</span></c:otherwise>
                        </c:choose>
                    </span>
                </div>
                <c:if test="${not empty banner.displayScheduleNote}">
                    <div class="banner-info-row">
                        <span class="banner-info-label">노출 안내</span>
                        <span class="banner-info-value" style="color:#3B5BDB">${banner.displayScheduleNote}</span>
                    </div>
                </c:if>
                <c:if test="${banner.statusCd eq 'HOLD' and not empty banner.rejectReason}">
                    <div class="banner-info-row">
                        <span class="banner-info-label">대기 사유</span>
                        <span class="banner-info-value" style="color:#3B5BDB">${banner.rejectReason}</span>
                    </div>
                </c:if>
                <c:if test="${banner.statusCd eq 'REJECTED' and not empty banner.rejectReason}">
                    <div class="banner-info-row">
                        <span class="banner-info-label">반려 사유</span>
                        <span class="banner-info-value" style="color:#e74c3c">${banner.rejectReason}</span>
                    </div>
                </c:if>
            </div>
        </div>

        <div>

         <%-- 2026-08-07 박유정 — 배너 정보 수정 (제목·링크·이미지) --%>
            <div class="banner-side-card">
                <h3 class="banner-side-title">배너 정보 수정</h3>
                <form class="banner-side-form" method="post"
                      action="${contextPath}/admin/cms/banner/update"
                      enctype="multipart/form-data">
                    <%-- 2026/08/07 장우철 CSRF --%>
                    <input type="hidden" name="_csrf" value="${_csrf}">
                    <input type="hidden" name="bannerId" value="${banner.bannerId}">
                    <div>
                        <label>배너 제목</label>
                        <input type="text" name="title" value="${banner.title}" required>
                    </div>
                    <div>
                        <label>링크 URL</label>
                        <input type="text" name="linkUrl" value="${banner.linkUrl}"
                               placeholder="비우면 클릭 시 이동 없음">
                    </div>
                    <div>
                        <label>배너 이미지 (변경 시만 선택)</label>
                        <input type="file" name="bannerImage" accept="image/*">
                        <span style="font-size:11px;color:#999">JPG, PNG / PDF 불가</span>
                    </div>
                    <button type="submit" class="adm-btn blue">정보 저장</button>
                </form>
            </div>
            <div class="banner-side-card">
                <h3 class="banner-side-title">광고 기간 재설정</h3>
                <form class="banner-side-form" method="post" action="${contextPath}/admin/cms/banner/period">
                    <%-- 2026/08/07 장우철 CSRF --%>
                    <input type="hidden" name="_csrf" value="${_csrf}">
                    <input type="hidden" name="bannerId" value="${banner.bannerId}">
                    <div>
                        <label>시작일</label>
                        <input type="date" name="startDate" value="${banner.startDate}" required>
                    </div>
                    <div>
                        <label>종료일</label>
                        <input type="date" name="endDate" value="${banner.endDate}" required>
                    </div>
                    <button type="submit" class="adm-btn blue">기간 저장</button>
                </form>
            </div>

            <div class="banner-side-card">
                <h3 class="banner-side-title">광고 관리</h3>
                <div class="banner-action-btns">
                    <c:choose>
                        <c:when test="${banner.statusCd eq 'ACTIVE'}">
                            <form method="post" action="${contextPath}/admin/cms/banner/deactivate"
                                  onsubmit="return confirm('이 광고를 내리시겠습니까?')">
                                <%-- 2026/08/07 장우철 CSRF --%>
                                <input type="hidden" name="_csrf" value="${_csrf}">
                                <input type="hidden" name="bannerId" value="${banner.bannerId}">
                                <button type="submit" class="adm-btn gray">광고 내리기</button>
                            </form>
                        </c:when>
                        <c:when test="${banner.statusCd eq 'EXPIRED'}">
                            <form method="post" action="${contextPath}/admin/cms/banner/activate"
                                  onsubmit="return confirm('이 광고를 다시 올리시겠습니까?')">
                                <%-- 2026/08/07 장우철 CSRF --%>
                                <input type="hidden" name="_csrf" value="${_csrf}">
                                <input type="hidden" name="bannerId" value="${banner.bannerId}">
                                <button type="submit" class="adm-btn green">광고 올리기</button>
                            </form>
                        </c:when>
                    </c:choose>
                    <form method="post" action="${contextPath}/admin/cms/banner/delete"
                          onsubmit="return confirm('배너를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.')">
                        <%-- 2026/08/07 장우철 CSRF --%>
                        <input type="hidden" name="_csrf" value="${_csrf}">
                        <input type="hidden" name="bannerId" value="${banner.bannerId}">
                        <button type="submit" class="adm-btn red">배너 삭제</button>
                    </form>
                    <a href="${contextPath}/admin/cms/banner" class="adm-btn" style="display:block;text-align:center;text-decoration:none">목록으로</a>
                </div>
            </div>
        </div>
    </div>
</main>

<div id="rejectModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.4);z-index:1000;align-items:center;justify-content:center">
    <div style="background:#fff;border-radius:12px;padding:24px;width:400px;max-width:90vw">
        <h3 style="margin:0 0 16px;font-size:16px">배너 반려</h3>
        <textarea id="rejectReason" rows="3" placeholder="반려 사유를 입력하세요"
                  style="width:100%;border:1px solid #E4E6ED;border-radius:8px;padding:10px;font-size:14px;resize:vertical;box-sizing:border-box"></textarea>
        <div style="display:flex;justify-content:flex-end;gap:8px;margin-top:16px">
            <button id="rejectCancel" type="button" class="adm-btn" style="background:#f5f5f5;color:#555">취소</button>
            <button id="rejectConfirm" type="button" class="adm-btn red">반려 확인</button>
        </div>
    </div>
</div>

<div id="holdModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.4);z-index:1000;align-items:center;justify-content:center">
    <div style="background:#fff;border-radius:12px;padding:24px;width:400px;max-width:90vw">
        <h3 style="margin:0 0 16px;font-size:16px">배너 대기 (노출예정)</h3>
        <textarea id="holdReason" rows="3" placeholder="대기 사유를 입력하세요"
                  style="width:100%;border:1px solid #E4E6ED;border-radius:8px;padding:10px;font-size:14px;resize:vertical;box-sizing:border-box"></textarea>
        <div style="display:flex;justify-content:flex-end;gap:8px;margin-top:16px">
            <button id="holdCancel" type="button" class="adm-btn" style="background:#f5f5f5;color:#555">취소</button>
            <button id="holdConfirm" type="button" class="adm-btn blue">대기 확인</button>
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/views/admin/common/footer.jsp" %>

<script>
var currentBannerId = null;

document.querySelectorAll('.btn-approve').forEach(function(btn) {
    btn.addEventListener('click', function() {
        if (!confirm('이 배너를 승인하시겠습니까?')) return;
        var bannerId = this.getAttribute('data-id');
        var xhr = new XMLHttpRequest();
        xhr.open('POST', '${contextPath}/admin/cms/banner/approve');
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        // 2026/08/07 장우철 CSRF
        xhr.setRequestHeader('X-CSRF-TOKEN', document.querySelector('meta[name="_csrf"]').getAttribute('content'));
        xhr.onload = function() {
            var res = xhr.responseText.trim();
            if (xhr.status === 200 && res.indexOf('OK') === 0) {
                var msg = res.indexOf('OK:') === 0 ? res.substring(3) : '배너 승인이 완료되었습니다.';
                alert(msg);
                location.reload();
            } else if (res.indexOf('ERR:') === 0) {
                alert(res.substring(4));
            } else {
                alert('처리 실패 (status: ' + xhr.status + ')');
            }
        };
        xhr.send('bannerId=' + bannerId);
    });
});

document.querySelectorAll('.btn-hold').forEach(function(btn) {
    btn.addEventListener('click', function() {
        currentBannerId = this.getAttribute('data-id');
        document.getElementById('holdReason').value = '';
        document.getElementById('holdModal').style.display = 'flex';
    });
});

document.getElementById('holdCancel').addEventListener('click', function() {
    document.getElementById('holdModal').style.display = 'none';
    currentBannerId = null;
});

document.getElementById('holdConfirm').addEventListener('click', function() {
    var reason = document.getElementById('holdReason').value.trim();
    if (!reason) { alert('대기 사유를 입력하세요.'); return; }
    var xhr = new XMLHttpRequest();
    xhr.open('POST', '${contextPath}/admin/cms/banner/hold');
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    // 2026/08/07 장우철 CSRF
    xhr.setRequestHeader('X-CSRF-TOKEN', document.querySelector('meta[name="_csrf"]').getAttribute('content'));
    xhr.onload = function() {
        var res = xhr.responseText.trim();
        if (res === 'OK') {
            alert('노출예정 상태로 변경되었습니다.');
            location.reload();
        } else if (res.indexOf('ERR:') === 0) {
            alert(res.substring(4));
        } else {
            alert('처리 실패: ' + res);
        }
    };
    xhr.send('bannerId=' + currentBannerId + '&holdReason=' + encodeURIComponent(reason));
});

document.querySelectorAll('.btn-reject').forEach(function(btn) {
    btn.addEventListener('click', function() {
        currentBannerId = this.getAttribute('data-id');
        document.getElementById('rejectReason').value = '';
        document.getElementById('rejectModal').style.display = 'flex';
    });
});

document.getElementById('rejectCancel').addEventListener('click', function() {
    document.getElementById('rejectModal').style.display = 'none';
    currentBannerId = null;
});

document.getElementById('rejectConfirm').addEventListener('click', function() {
    var reason = document.getElementById('rejectReason').value.trim();
    if (!reason) { alert('반려 사유를 입력하세요.'); return; }
    var xhr = new XMLHttpRequest();
    xhr.open('POST', '${contextPath}/admin/cms/banner/reject');
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    // 2026/08/07 장우철 CSRF
    xhr.setRequestHeader('X-CSRF-TOKEN', document.querySelector('meta[name="_csrf"]').getAttribute('content'));
    xhr.onload = function() {
        var res = xhr.responseText.trim();
        if (res === 'OK') {
            alert('반려되었습니다. 사업자에게 알림이 전송됩니다.');
            location.reload();
        } else if (res.indexOf('ERR:') === 0) {
            alert(res.substring(4));
        } else {
            alert('처리 실패: ' + res);
        }
    };
    xhr.send('bannerId=' + currentBannerId + '&rejectReason=' + encodeURIComponent(reason));
});
</script>
<style>
.adm-btn.btn-hold{background:#F59E0B;color:#fff;border:none}
.adm-btn.btn-hold:hover{background:#D97706}
</style>
