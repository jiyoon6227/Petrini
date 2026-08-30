<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
  역할: 관리자 배너 관리 목록
  - 2026-08-06 박유정 — 대분류(메인/숙소/쇼핑/병원) + 중분류 탭(현재광고/광고대기/승인/승인대기/반려)
  - 승인·대기·반려 AJAX, 상세 링크
--%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="adminPage" value="cms-banner" />
<%@ include file="/WEB-INF/views/admin/common/header.jsp" %>
<%@ include file="/WEB-INF/views/admin/common/sidebar.jsp" %>

<style>
    /* 2026-08-06 박유정 — 대분류(세그먼트) / 중분류(밑줄 탭) 필터 UI */
    /* ── 필터 영역 전체 ── */
    .banner-filter-wrap{
        background:#fff;border:1px solid #E4E6ED;border-radius:12px;
        padding:20px 22px 8px;margin-bottom:20px
    }
    .banner-filter-section{margin-bottom:18px}
    .banner-filter-section--status{margin-bottom:4px;padding-top:4px;border-top:1px dashed #E8EAEF}
    .banner-filter-label{
        display:block;font-size:11px;font-weight:800;letter-spacing:.08em;
        text-transform:uppercase;color:#9CA3AF;margin-bottom:10px
    }

    /* ── 대분류: 노출 영역 (세그먼트 카드) ── */
    .banner-category-bar{
        display:grid;grid-template-columns:repeat(4,1fr);gap:6px;
        background:#F3F4F6;border-radius:10px;padding:5px
    }
    .banner-category-btn{
        padding:14px 12px;border:none;border-radius:8px;background:transparent;
        color:#6B7280;font-size:15px;font-weight:700;text-decoration:none;
        display:flex;flex-direction:column;align-items:center;justify-content:center;gap:4px;
        transition:all .15s;text-align:center
    }
    .banner-category-btn:hover{color:#1A1A2E;background:rgba(255,255,255,.55)}
    .banner-category-btn.on{
        background:#1A1A2E;color:#fff;
        box-shadow:0 2px 10px rgba(26,26,46,.18)
    }
    .banner-category-count{
        font-size:11px;font-weight:700;background:rgba(0,0,0,.06);color:inherit;
        border-radius:20px;padding:2px 8px;line-height:1.4
    }
    .banner-category-btn.on .banner-category-count{background:rgba(255,255,255,.18)}

    /* ── 중분류: 광고 상태 (밑줄 탭) ── */
    .banner-status-bar{
        display:flex;flex-wrap:wrap;gap:0;align-items:flex-end;
        border-bottom:2px solid #E4E6ED
    }
    .banner-status-tab{
        padding:10px 18px 12px;font-size:13px;font-weight:600;color:#9CA3AF;
        text-decoration:none;display:inline-flex;align-items:center;gap:6px;
        border-bottom:2px solid transparent;margin-bottom:-2px;transition:all .15s
    }
    .banner-status-tab:hover{color:#3B5BDB}
    .banner-status-tab.on{color:#3B5BDB;border-bottom-color:#3B5BDB;font-weight:700}
    .banner-status-count{
        font-size:11px;font-weight:700;background:#F3F4F6;color:#9CA3AF;
        border-radius:20px;padding:1px 7px;min-width:18px;text-align:center
    }
    .banner-status-tab.on .banner-status-count{background:#EEF2FF;color:#3B5BDB}

    @media(max-width:720px){
        .banner-category-bar{grid-template-columns:repeat(2,1fr)}
    }
</style>

<main class="adm-main">
    <div class="adm-page-head">
        <div class="adm-page-head-left">
            <h1 class="adm-page-title">배너 관리</h1>
            <p class="adm-page-desc">사업자가 신청한 배너를 승인·대기·반려하세요. 승인된 배너는 설정한 기간에 노출됩니다.</p>
        </div>
    </div>

    <div class="banner-filter-wrap">
        <div class="banner-filter-section">
            <span class="banner-filter-label">노출 영역</span>
            <div class="banner-category-bar">
                <a href="${contextPath}/admin/cms/banner?category=main&tab=${currentTab}"
                   class="banner-category-btn ${currentCategory eq 'main' ? 'on' : ''}">
                    메인페이지
                    <span class="banner-category-count">${categoryCounts.main}</span>
                </a>
                <a href="${contextPath}/admin/cms/banner?category=stay&tab=${currentTab}"
                   class="banner-category-btn ${currentCategory eq 'stay' ? 'on' : ''}">
                    숙소
                    <span class="banner-category-count">${categoryCounts.stay}</span>
                </a>
                <a href="${contextPath}/admin/cms/banner?category=store&tab=${currentTab}"
                   class="banner-category-btn ${currentCategory eq 'store' ? 'on' : ''}">
                    쇼핑
                    <span class="banner-category-count">${categoryCounts.store}</span>
                </a>
                <a href="${contextPath}/admin/cms/banner?category=hospital&tab=${currentTab}"
                   class="banner-category-btn ${currentCategory eq 'hospital' ? 'on' : ''}">
                    병원
                    <span class="banner-category-count">${categoryCounts.hospital}</span>
                </a>
            </div>
        </div>

        <div class="banner-filter-section banner-filter-section--status">
            <span class="banner-filter-label">광고 상태</span>
            <div class="banner-status-bar">
                <a href="${contextPath}/admin/cms/banner?category=${currentCategory}&tab=live"
                   class="banner-status-tab ${currentTab eq 'live' ? 'on' : ''}">
                    현재광고 <span class="banner-status-count">${tabCounts.live}</span>
                </a>
                <a href="${contextPath}/admin/cms/banner?category=${currentCategory}&tab=scheduled"
                   class="banner-status-tab ${currentTab eq 'scheduled' ? 'on' : ''}">
                    광고대기 <span class="banner-status-count">${tabCounts.scheduled}</span>
                </a>
                <a href="${contextPath}/admin/cms/banner?category=${currentCategory}&tab=approved"
                   class="banner-status-tab ${currentTab eq 'approved' ? 'on' : ''}">
                    승인 <span class="banner-status-count">${tabCounts.approved}</span>
                </a>
                <a href="${contextPath}/admin/cms/banner?category=${currentCategory}&tab=pending"
                   class="banner-status-tab ${currentTab eq 'pending' ? 'on' : ''}">
                    승인대기 <span class="banner-status-count">${tabCounts.pending}</span>
                </a>
                <a href="${contextPath}/admin/cms/banner?category=${currentCategory}&tab=rejected"
                   class="banner-status-tab ${currentTab eq 'rejected' ? 'on' : ''}">
                    반려 <span class="banner-status-count">${tabCounts.rejected}</span>
                </a>
            </div>
        </div>
    </div>

    <div class="adm-card">
        <div class="adm-card-head">
            <span class="adm-card-head-title">
                <c:choose>
                    <c:when test="${currentCategory eq 'stay'}">숙소 · </c:when>
                    <c:when test="${currentCategory eq 'store'}">쇼핑 · </c:when>
                    <c:when test="${currentCategory eq 'hospital'}">병원 · </c:when>
                    <c:otherwise>메인페이지 · </c:otherwise>
                </c:choose>
                <c:choose>
                    <c:when test="${currentTab eq 'live'}">현재 광고</c:when>
                    <c:when test="${currentTab eq 'scheduled'}">광고 대기 (노출예정)</c:when>
                    <c:when test="${currentTab eq 'approved'}">승인된 광고 (종료·미노출)</c:when>
                    <c:when test="${currentTab eq 'rejected'}">반려된 배너</c:when>
                    <c:otherwise>승인 대기</c:otherwise>
                </c:choose>
            </span>
            <span class="adm-card-head-sub">총 ${bannerList.size()}건</span>
        </div>

        <c:choose>
            <c:when test="${not empty bannerList}">
                <div class="adm-table-wrap">
                    <table class="adm-table">
                        <thead>
                            <tr>
                                <th>미리보기</th>
                                <th>제목</th>
                                <th>사업자</th>
                                <th>노출 위치</th>
                                <th>노출 기간</th>
                                <th>상태</th>
                                <th>관리</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="banner" items="${bannerList}">
                                <tr id="row-${banner.bannerId}">
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty banner.imageUrl}">
                                                <c:set var="imgSrc" value="${banner.imageUrl}" />
                                                <c:if test="${not fn:startsWith(banner.imageUrl, 'http')}">
                                                    <c:set var="imgSrc" value="${contextPath}/upload/${banner.imageUrl}" />
                                                </c:if>
                                                <img src="${imgSrc}" alt=""
                                                     style="width:120px;height:50px;object-fit:cover;border-radius:6px"
                                                     onerror="this.src='https://placehold.co/120x50/EAF7F2/2BAB82?text=배너'">
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color:#999;font-size:12px">이미지 없음</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td><strong>${banner.title}</strong></td>
                                    <td>${banner.bizName}</td>
                                    <td>
                                        <span class="adm-badge">${banner.positionLabel}</span>
                                    </td>
                                    <td>${banner.startDate} ~ ${banner.endDate}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${banner.effectiveStatusLabel eq '심사중'}">
                                                <span class="adm-badge warning">심사중</span>
                                            </c:when>
                                            <c:when test="${banner.effectiveStatusLabel eq '노출예정'}">
                                                <span class="adm-badge warning">노출예정</span>
                                            </c:when>
                                            <c:when test="${banner.effectiveStatusLabel eq '노출중'}">
                                                <span class="adm-badge active">노출중</span>
                                            </c:when>
                                            <c:when test="${banner.effectiveStatusLabel eq '노출 예정'}">
                                                <span class="adm-badge warning">노출 예정</span>
                                            </c:when>
                                            <c:when test="${banner.effectiveStatusLabel eq '반려'}">
                                                <span class="adm-badge danger">반려</span>
                                            </c:when>
                                            <c:when test="${banner.effectiveStatusLabel eq '미노출'}">
                                                <span class="adm-badge inactive">미노출</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="adm-badge">${banner.effectiveStatusLabel}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="adm-table-actions">
                                            <a href="${contextPath}/admin/cms/banner/detail?bannerId=${banner.bannerId}"
                                               class="adm-btn gray">상세</a>
                                            <c:if test="${banner.statusCd eq 'PENDING'}">
                                                <button type="button" class="adm-btn blue btn-approve"
                                                        data-id="${banner.bannerId}">승인</button>
                                                <button type="button" class="adm-btn btn-hold"
                                                        data-id="${banner.bannerId}">대기</button>
                                                <button type="button" class="adm-btn red btn-reject"
                                                        data-id="${banner.bannerId}">반려</button>
                                            </c:if>
                                            <c:if test="${banner.statusCd eq 'HOLD'}">
                                                <button type="button" class="adm-btn blue btn-approve"
                                                        data-id="${banner.bannerId}">승인</button>
                                                <button type="button" class="adm-btn red btn-reject"
                                                        data-id="${banner.bannerId}">반려</button>
                                            </c:if>
                                        </div>
                                        <c:if test="${banner.statusCd eq 'HOLD' and not empty banner.rejectReason}">
                                            <span style="color:#3B5BDB;font-size:12px;display:block;margin-top:6px">대기 사유: ${banner.rejectReason}</span>
                                        </c:if>
                                        <c:if test="${banner.statusCd eq 'REJECTED' and not empty banner.rejectReason}">
                                            <span style="color:#e74c3c;font-size:12px;display:block;margin-top:6px">반려 사유: ${banner.rejectReason}</span>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:when>
            <c:otherwise>
                <div style="padding:60px 20px;text-align:center;color:#999">
                    <c:choose>
                        <c:when test="${currentTab eq 'live'}">현재 진행 중인 광고가 없습니다.</c:when>
                        <c:when test="${currentTab eq 'scheduled'}">노출 예정인 광고가 없습니다.</c:when>
                        <c:when test="${currentTab eq 'approved'}">승인된 종료·미노출 광고가 없습니다.</c:when>
                        <c:when test="${currentTab eq 'rejected'}">반려된 배너가 없습니다.</c:when>
                        <c:otherwise>승인 대기 중인 배너가 없습니다.</c:otherwise>
                    </c:choose>
                </div>
            </c:otherwise>
        </c:choose>
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
        <p style="margin:0 0 12px;font-size:13px;color:#666">사업자에게 대기 사유가 알림으로 전달됩니다.</p>
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
        
        //HYJ 26.08.05
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

    //HYJ 26.08.05
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
