<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="bizPage" value="banner" />
<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_hospital.jsp" %>

<main class="biz-main">
    <div class="biz-page-head">
        <div>
            <h1 class="biz-page-title">배너 신청</h1>
            <p class="biz-page-desc">배너 정보를 입력하고, 노출할 위치를 선택하세요.</p>
        </div>
    </div>

    <div class="biz-card">
        <div class="biz-card-body" style="padding:24px">
            <form action="${contextPath}/biz/hospital/banner" method="post" enctype="multipart/form-data" id="bannerForm">
                <!--HYJ 26.08.05-->
                <input type="hidden" name="_csrf" value="${_csrf}">
                
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px 20px">

                    <%-- 배너 제목 --%>
                    <div style="grid-column:1/-1;display:flex;flex-direction:column;gap:6px">
                        <label style="font-size:13px;font-weight:600">배너 제목 <span style="color:#e74c3c">*</span></label>
                        <input type="text" name="title" required placeholder="예) 여름 맞이 특가 이벤트"
                               style="border:1px solid #E4E6ED;border-radius:8px;padding:10px 14px;font-size:14px">
                    </div>

                    <%-- 노출 위치 선택 --%>
                    <div style="grid-column:1/-1;display:flex;flex-direction:column;gap:6px">
                        <label style="font-size:13px;font-weight:600">노출 위치 <span style="color:#e74c3c">*</span></label>
                        <select name="positionCd" required
                                style="border:1px solid #E4E6ED;border-radius:8px;padding:10px 14px;font-size:14px;background:#fff">
                            <option value="">위치를 선택하세요</option>
                            <option value="MAIN_HERO">메인 히어로 - 1200 × 360px (메인페이지 상단 슬라이드)</option>
                            <option value="MAIN_MID">메인 중간 - 1200 × 200px (메인페이지 섹션 사이)</option>
                            <option value="STORE">쇼핑 - 728 x 100px(쇼핑 목록 상단)</option> <%-- 2026-08-06 박유정 쇼핑몰→쇼핑 --%>
                            <option value="HOSPITAL">병원 - 730 x 100px(병원 목록 상단)</option>
                            <option value="STAY">숙소 - 730 x 100px(숙소 목록 상단)</option>
                        </select>
                        <span style="font-size:12px;color:#999">선택한 위치에 배너가 노출됩니다. 관리자 승인 후 적용되며, 위치별 최대 5개까지 신청·노출됩니다.</span>
                    </div>

                    <%-- 노출 기간 --%>
                    <div style="display:flex;flex-direction:column;gap:6px">
                        <label style="font-size:13px;font-weight:600">시작일 <span style="color:#e74c3c">*</span></label>
                        <input type="date" name="startDate" required
                               style="border:1px solid #E4E6ED;border-radius:8px;padding:10px 14px;font-size:14px">
                    </div>
                    <div style="display:flex;flex-direction:column;gap:6px">
                        <label style="font-size:13px;font-weight:600">종료일 <span style="color:#e74c3c">*</span></label>
                        <input type="date" name="endDate" required
                               style="border:1px solid #E4E6ED;border-radius:8px;padding:10px 14px;font-size:14px">
                    </div>

                    <%-- 링크 URL --%>
                    <div style="grid-column:1/-1;display:flex;flex-direction:column;gap:6px">
                        <label style="font-size:13px;font-weight:600">링크 URL</label>
                        <input type="text" name="linkUrl" placeholder="클릭 시 이동할 주소 (예: /stay, https://...)"
                               style="border:1px solid #E4E6ED;border-radius:8px;padding:10px 14px;font-size:14px">
                        <span style="font-size:12px;color:#999">비워두면 클릭해도 이동하지 않습니다.</span>
                    </div>

                    <%-- 배너 이미지 --%>
                    <div style="grid-column:1/-1;display:flex;flex-direction:column;gap:6px">
                        <label style="font-size:13px;font-weight:600">배너 이미지 <span style="color:#e74c3c">*</span></label>
                        <input type="file" name="bannerImage" accept="image/*" required id="bannerImageInput"
                               style="font-size:13px">
                        <span id="sizeGuide" style="font-size:12px;color:#999">권장 크기: 960 x 400px / JPG, PNG (최대 5MB)</span>
                        <div id="imagePreview" style="margin-top:8px;display:none">
                            <img id="previewImg" src="" alt="미리보기"
                                 style="max-width:100%;max-height:200px;border-radius:8px;border:1px solid #E4E6ED">
                        </div>
                    </div>
                </div>

                <div style="display:flex;justify-content:flex-end;gap:10px;margin-top:24px">
                    <a href="${contextPath}/biz/hospital/banner"
                       style="padding:10px 20px;border:1px solid #E4E6ED;border-radius:8px;text-decoration:none;color:#555;font-size:14px">취소</a>
                    <button type="submit"
                            style="padding:10px 24px;background:#2BAB82;color:#fff;border:none;border-radius:8px;font-size:14px;cursor:pointer">신청하기</button>
                </div>
            </form>
        </div>
    </div>
</main>
<jsp:include page="/WEB-INF/views/biz/common/footer.jsp" />

<script>
// 기본 노출 기간: 오늘 ~ 30일 후
(function() {
    var startInput = document.querySelector('input[name="startDate"]');
    var endInput = document.querySelector('input[name="endDate"]');
    if (!startInput || !endInput) return;
    var today = new Date();
    var end = new Date(today);
    end.setDate(end.getDate() + 30);
    function fmt(d) {
        var m = String(d.getMonth() + 1).padStart(2, '0');
        var day = String(d.getDate()).padStart(2, '0');
        return d.getFullYear() + '-' + m + '-' + day;
    }
    if (!startInput.value) startInput.value = fmt(today);
    if (!endInput.value) endInput.value = fmt(end);
})();

// 이미지 미리보기
document.getElementById('bannerImageInput').addEventListener('change', function() {
    var file = this.files[0];
    if (file) {
        var reader = new FileReader();
        reader.onload = function(e) {
            document.getElementById('previewImg').src = e.target.result;
            document.getElementById('imagePreview').style.display = 'block';
        };
        reader.readAsDataURL(file);
    } else {
        document.getElementById('imagePreview').style.display = 'none';
    }
});

// 위치별 이미지 권장 크기 안내
document.querySelector('select[name="positionCd"]').addEventListener('change', function() {
    var guide = document.getElementById('sizeGuide');
    var sizes = {
        'MAIN_HERO': '1200 x 360px',
        'MAIN_MID':  '120 x 200px',
        'STORE':     '730 x 100px',
        'HOSPITAL':  '730 x 100px',
        'STAY':      '730 x 100px',
    };
    var size = sizes[this.value] || '960 x 400px';
    guide.textContent = '권장 크기: ' + size + ' / JPG, PNG (최대 5MB)';
});

// 날짜 유효성
document.getElementById('bannerForm').addEventListener('submit', function(e) {
    var start = document.querySelector('input[name="startDate"]').value;
    var end = document.querySelector('input[name="endDate"]').value;
    var today = new Date();
    var todayStr = today.getFullYear() + '-' +
        String(today.getMonth() + 1).padStart(2, '0') + '-' +
        String(today.getDate()).padStart(2, '0');
    if (start && end && end < start) {
        e.preventDefault();
        alert('종료일은 시작일 이후여야 합니다.');
        return;
    }
    if (end && end < todayStr) {
        e.preventDefault();
        alert('종료일이 지났습니다. 기간을 수정한 후 신청해 주세요.');
    }
});
</script>
