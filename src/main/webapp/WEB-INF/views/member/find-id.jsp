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

        <h1 class="member-title">아이디 찾기</h1>
        <p class="member-desc">가입 시 등록한 정보로<br>아이디를 확인할 수 있습니다</p>

        <form class="member-form" id="findIdForm" onsubmit="return false;">
            <div class="form-group">
                <label class="form-label" for="findName">이름</label>
                <input type="text" id="findName" class="form-input" placeholder="이름을 입력하세요">
            </div>
            <div class="form-group">
                <label class="form-label" for="findPhone">휴대폰 번호</label>
                <input type="tel" id="findPhone" class="form-input" placeholder="010-0000-0000"
                       oninput="this.value=this.value.replace(/[^0-9]/g,'').replace(/(\d{3})(\d{4})(\d{4})/,'$1-$2-$3')">
            </div>
            <button type="button" class="btn-submit" id="btnFindId">아이디 찾기</button>
        </form>

        <%-- 성공 결과 --%>
        <div id="findIdResult" style="display:none;margin-top:20px;padding:18px;background:var(--primary-light);border-radius:var(--radius-sm);text-align:center">
            <p style="font-size:13px;color:var(--text-sub);margin-bottom:8px">회원님의 아이디는</p>
            <p style="font-size:18px;font-weight:800;color:var(--primary-dark);margin-bottom:4px" id="foundEmail"></p>
            <p style="font-size:12px;color:var(--text-muted)">입니다.</p>
        </div>

        <%-- 실패 결과 --%>
        <div id="findIdError" style="display:none;margin-top:20px;padding:18px;background:#FEF2F2;border:1px solid #FECACA;border-radius:var(--radius-sm);text-align:center">
            <p style="font-size:14px;color:#B91C1C" id="findIdErrorMsg"></p>
        </div>

        <p class="member-footer-link">
            <a href="${contextPath}/login">로그인</a>
            &nbsp;|&nbsp;
            <a href="${contextPath}/find/pw">비밀번호 찾기</a>
            &nbsp;|&nbsp;
            <a href="${contextPath}/join">회원가입</a>
        </p>
    </div>
</main>

<script>
document.getElementById('btnFindId').addEventListener('click', function () {
    var name  = document.getElementById('findName').value.trim();
    var phone = document.getElementById('findPhone').value.trim();

    document.getElementById('findIdResult').style.display = 'none';
    document.getElementById('findIdError').style.display = 'none';

    if (!name) { alert('이름을 입력해 주세요.'); document.getElementById('findName').focus(); return; }
    if (!phone) { alert('휴대폰 번호를 입력해 주세요.'); document.getElementById('findPhone').focus(); return; }

    var fd = new FormData();
    fd.append('memberName', name);
    fd.append('phone', phone);

    csrfFetch('${contextPath}/find/id', { method: 'POST', body: fd })
        .then(function(res) { return res.json(); })
        .then(function(data) {
            if (data.ok) {
                document.getElementById('foundEmail').textContent = data.data;
                document.getElementById('findIdResult').style.display = 'block';
            } else {
                document.getElementById('findIdErrorMsg').textContent = data.msg;
                document.getElementById('findIdError').style.display = 'block';
            }
        })
        .catch(function() {
            alert('아이디 찾기 중 오류가 발생했습니다.');
        });
});
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
