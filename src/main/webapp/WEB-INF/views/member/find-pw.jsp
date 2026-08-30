<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<main class="member-page">
    <div class="member-box">

        <a href="${contextPath}/" class="member-logo">
            <svg width="30" height="30" viewBox="0 0 32 32" fill="none">
                <ellipse cx="16" cy="20" rx="9" ry="8" fill="#2BAB82"/>
                <ellipse cx="8"  cy="12" rx="3.2" ry="3.8" fill="#2BAB82"/>
                <ellipse cx="13" cy="9.5" rx="3.2" ry="3.8" fill="#2BAB82"/>
                <ellipse cx="19" cy="9.5" rx="3.2" ry="3.8" fill="#2BAB82"/>
                <ellipse cx="24" cy="12" rx="3.2" ry="3.8" fill="#2BAB82"/>
                <path d="M14.5 20.5 C14.5 19 16 18 16 18 C16 18 17.5 19 17.5 20.5 C17.5 22 16 23 16 23 C16 23 14.5 22 14.5 20.5Z" fill="white" opacity="0.85"/>
            </svg>
            <span class="member-logo-text">PetCare</span>
        </a>

        <h1 class="member-title">비밀번호 찾기</h1>
        <p class="member-desc">가입한 이메일로<br>임시 비밀번호를 발송해 드립니다</p>

        <form class="member-form" id="findPwForm" onsubmit="return false;">
            <div class="form-group">
                <label class="form-label" for="findPwEmail">아이디 (이메일)</label>
                <input type="email" id="findPwEmail" class="form-input" placeholder="example@email.com">
            </div>
            <div class="form-group">
                <label class="form-label" for="findPwName">이름</label>
                <input type="text" id="findPwName" class="form-input" placeholder="이름을 입력하세요">
            </div>
            <button type="button" class="btn-submit" id="btnFindPw">임시 비밀번호 발송</button>
        </form>

        <%-- 성공 결과 --%>
        <div id="findPwResult" style="display:none;margin-top:20px;padding:18px;background:var(--primary-light);border-radius:var(--radius-sm);text-align:center">
            <p style="font-size:14px;color:var(--text-sub);line-height:1.7">
                입력하신 이메일로 임시 비밀번호를 발송했습니다.<br>
                로그인 후 반드시 비밀번호를 변경해 주세요.
            </p>
            <a href="${contextPath}/login" style="display:inline-block;margin-top:12px;padding:10px 28px;background:var(--primary);color:#fff;border-radius:var(--radius-sm);font-size:14px;font-weight:700;text-decoration:none">로그인하러 가기</a>
        </div>

        <%-- 실패 결과 --%>
        <div id="findPwError" style="display:none;margin-top:20px;padding:18px;background:#FEF2F2;border:1px solid #FECACA;border-radius:var(--radius-sm);text-align:center">
            <p style="font-size:14px;color:#B91C1C" id="findPwErrorMsg"></p>
        </div>

        <p class="member-footer-link">
            <a href="${contextPath}/login">로그인</a>
            &nbsp;|&nbsp;
            <a href="${contextPath}/find/id">아이디 찾기</a>
            &nbsp;|&nbsp;
            <a href="${contextPath}/join">회원가입</a>
        </p>
    </div>
</main>

<script>
document.getElementById('btnFindPw').addEventListener('click', function () {
    var email = document.getElementById('findPwEmail').value.trim();
    var name  = document.getElementById('findPwName').value.trim();
    var btn   = this;

    document.getElementById('findPwResult').style.display = 'none';
    document.getElementById('findPwError').style.display = 'none';

    if (!email) { alert('이메일을 입력해 주세요.'); document.getElementById('findPwEmail').focus(); return; }
    if (!name)  { alert('이름을 입력해 주세요.'); document.getElementById('findPwName').focus(); return; }

    btn.disabled = true;
    btn.textContent = '발송 중...';

    var fd = new FormData();
    fd.append('email', email);
    fd.append('memberName', name);

    csrfFetch('${contextPath}/find/pw', { method: 'POST', body: fd })
        .then(function(res) { return res.json(); })
        .then(function(data) {
            btn.disabled = false;
            btn.textContent = '임시 비밀번호 발송';
            if (data.ok) {
                document.getElementById('findPwResult').style.display = 'block';
            } else {
                document.getElementById('findPwErrorMsg').textContent = data.msg;
                document.getElementById('findPwError').style.display = 'block';
            }
        })
        .catch(function() {
            btn.disabled = false;
            btn.textContent = '임시 비밀번호 발송';
            alert('비밀번호 찾기 중 오류가 발생했습니다.');
        });
});
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
