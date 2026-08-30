<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="mypage" />
<c:set var="sec" value="edit" />

<%@ include file="/WEB-INF/views/common/header.jsp" %>
<link rel="stylesheet" href="${contextPath}/resources/css/mypage.css">

<div class="mypage-wrap">
<%@ include file="/WEB-INF/views/mypage/sidebar.jsp" %>
<div class="mypage-content">

<div class="mp-section active">
    <h2 class="mp-title">회원 탈퇴</h2>
    <p class="mp-desc">탈퇴 후에는 계정 복구가 불가능합니다.</p>

    <div class="edit-section" style="max-width:480px; margin:32px auto;">

        <%-- 안내 문구 --%>
        <div style="background:#FFF5F5; border:1px solid #FEB2B2; border-radius:10px; padding:20px; margin-bottom:24px;">
            <p style="color:#C53030; font-size:14px; margin:0; line-height:1.7;">
                <strong>탈퇴 시 유의사항</strong><br>
                • 회원 정보, 주문내역, 포인트가 모두 삭제됩니다.<br>
                • 동일한 이메일로 재가입이 제한될 수 있습니다.<br>
                • 이 작업은 되돌릴 수 없습니다.
            </p>
        </div>

        <%-- 비밀번호 입력 --%>
        <div style="margin-bottom:24px;">
            <label style="display:block; font-size:14px; font-weight:600; margin-bottom:8px; color:#333;">
                비밀번호 확인 <span style="color:#E53E3E;">*</span>
            </label>
            <input type="password" id="withdrawPwd"
                   placeholder="현재 비밀번호를 입력하세요"
                   style="width:100%; padding:12px 14px; border:1px solid #ddd; border-radius:8px; font-size:14px; box-sizing:border-box;">
            <p id="errPwd" style="display:none; color:#E53E3E; font-size:13px; margin-top:6px;"></p>
        </div>

        <%-- 최종 확인 — "탈퇴합니다" 직접 입력 --%>
        <div style="margin-bottom:24px;">
            <label style="display:block; font-size:14px; font-weight:600; margin-bottom:8px; color:#333;">
                최종 확인 <span style="color:#E53E3E;">*</span>
            </label>
            <p style="font-size:13px; color:#666; margin-bottom:8px;">
                탈퇴를 확인하려면 아래에 <strong style="color:#E53E3E;">탈퇴합니다</strong>를 입력해 주세요.
            </p>
            <input type="text" id="withdrawConfirm"
                   placeholder="탈퇴합니다"
                   autocomplete="off"
                   style="width:100%; padding:12px 14px; border:1px solid #ddd; border-radius:8px; font-size:14px; box-sizing:border-box;">
            <p id="errConfirm" style="display:none; color:#E53E3E; font-size:13px; margin-top:6px;"></p>
        </div>

        <%-- 버튼 --%>
        <div style="display:flex; gap:12px;">
            <a href="${contextPath}/mypage/edit"
               style="flex:1; display:block; text-align:center; padding:13px; border:1px solid #ddd; border-radius:8px; color:#666; text-decoration:none; font-size:15px;">
                돌아가기
            </a>
            <button type="button" id="btnWithdraw"
                    style="flex:1; padding:13px; border:none; border-radius:8px; background:#E53E3E; color:#fff; font-size:15px; font-weight:600; cursor:pointer;">
                탈퇴하기
            </button>
        </div>
    </div>
</div>

</div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>

<script>
(function () {
    var ctx = '${contextPath}';

    document.getElementById('btnWithdraw').addEventListener('click', function () {
        var pwd = document.getElementById('withdrawPwd').value.trim();
        var confirm = document.getElementById('withdrawConfirm').value.trim();
        var errPwd = document.getElementById('errPwd');
        var errConfirm = document.getElementById('errConfirm');
        var valid = true;

        // 에러 초기화
        errPwd.style.display = 'none';
        errConfirm.style.display = 'none';

        // 비밀번호 확인
        if (!pwd) {
            errPwd.textContent = '비밀번호를 입력해 주세요.';
            errPwd.style.display = '';
            valid = false;
        }

        // "탈퇴합니다" 입력 확인
        if (confirm !== '탈퇴합니다') {
            errConfirm.textContent = '"탈퇴합니다"를 정확히 입력해 주세요.';
            errConfirm.style.display = '';
            valid = false;
        }

        if (!valid) return;

        // 탈퇴 요청
        var fd = new FormData();
        fd.append('password', pwd);
        //HYJ 26.08.05
        csrfFetch(ctx + '/mypage/withdraw', { method: 'POST', body: fd })
            .then(function (res) { return res.text(); })
            .then(function (data) {
                if (data === 'OK') {
                    alert('회원 탈퇴가 완료되었습니다.');
                    location.href = ctx + '/';
                } else {
                    var msg = data.replace('ERROR:', '');
                    errPwd.textContent = msg;
                    errPwd.style.display = '';
                }
            })
            .catch(function () {
                errPwd.textContent = '탈퇴 처리 중 오류가 발생했습니다.';
                errPwd.style.display = '';
            });
    });

    // 입력 시 에러 메시지 숨기기
    document.getElementById('withdrawPwd').addEventListener('input', function () {
        document.getElementById('errPwd').style.display = 'none';
    });
    document.getElementById('withdrawConfirm').addEventListener('input', function () {
        document.getElementById('errConfirm').style.display = 'none';
    });
})();
</script>
