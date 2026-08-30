<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<main class="member-page">
    <div class="member-box">

        <%-- 로고 --%>
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

        <h1 class="member-title">로그인</h1>
        <p class="member-desc">반려동물과의 행복한 일상을<br>PetCare와 함께 시작하세요</p>

        <c:if test="${param.error eq 'empty'}">
            <p class="login-error-msg">아이디와 비밀번호를 입력해 주세요.</p>
        </c:if>
        <c:if test="${param.error eq 'invalid'}">
            <p class="login-error-msg">아이디 또는 비밀번호가 올바르지 않습니다.
                <c:if test="${not empty param.remaining}">(남은 시도: ${param.remaining}회)</c:if>
            </p>
        </c:if>
        <%-- 2026-07-22 박유정 — 탈퇴 회원 로그인 메시지 (정지는 로그인 허용 → 고객센터) --%>
        <c:if test="${param.error eq 'suspended'}">
            <p class="login-error-msg">정지된 계정입니다. 관리자에게 문의해 주세요.</p>
        </c:if>
        <c:if test="${param.error eq 'withdrawn'}">
            <p class="login-error-msg">탈퇴한 계정입니다.</p>
        </c:if>
        <c:if test="${param.error eq 'kakao_cancel'}">
            <p class="login-error-msg">카카오 로그인이 취소되었습니다.</p>
        </c:if>
        <c:if test="${param.error eq 'kakao_token' or param.error eq 'kakao_user'}">
            <p class="login-error-msg">카카오 로그인 중 오류가 발생했습니다. 다시 시도해 주세요.</p>
        </c:if>
        <c:if test="${param.error eq 'kakao_not_member'}">
            <p class="login-error-msg">가입된 회원이 아닙니다. 먼저 회원가입을 진행해 주세요.</p>
        </c:if>
        <c:if test="${param.error eq 'kakao_already_member'}">
            <p class="login-error-msg">이미 가입된 카카오 계정입니다. 카카오 로그인을 이용해 주세요.</p>
        </c:if>
        <!--HYJ 26.08.06 -->
        <c:if test="${param.error eq 'locked'}">
            <p class="login-error-msg">
                로그인 시도 횟수를 초과했습니다. ${param.minutes}분 후 다시 시도해주세요.
            </p>
        </c:if>

        <%-- 소셜 로그인 --%>
        <div class="social-login-group">
            <a href="${contextPath}/oauth/kakao/login" class="social-btn-full kakao">
                <%-- 카카오 아이콘 --%>
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
                    <path d="M12 3C6.48 3 2 6.58 2 11c0 2.83 1.73 5.32 4.35 6.85L5.5 21l4.03-2.12C10.3 19.27 11.14 19.4 12 19.4c5.52 0 10-3.58 10-8.4S17.52 3 12 3z" fill="#3A1D1D"/>
                </svg>
                카카오로 로그인
            </a>
            <a href="${contextPath}/oauth2/authorization/naver" class="social-btn-full naver">
                <%-- 네이버 아이콘 --%>
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
                    <path d="M4 4h5.5l5 8V4H20v16h-5.5l-5-8v8H4z" fill="white"/>
                </svg>
                네이버로 시작하기
            </a>
            <a href="${contextPath}/oauth2/authorization/google" class="social-btn-full google">
                <%-- 구글 아이콘 --%>
                <svg width="20" height="20" viewBox="0 0 24 24">
                    <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/>
                    <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
                    <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z" fill="#FBBC05"/>
                    <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/>
                </svg>
                Google로 시작하기
            </a>
        </div>

        <div class="divider-or">또는 이메일로 로그인</div>

        <%-- 로그인 폼 --%>
        <form class="member-form" action="${contextPath}/login" method="post" id="loginForm">
            <!--HYJ 26.08.05-->
            <input type="hidden" name="_csrf" value="${_csrf}">

            <c:if test="${not empty param.redirect}">
                <input type="hidden" name="redirect" value="${param.redirect}">
            </c:if>
            <div class="form-group">
                <label class="form-label" for="loginId">아이디 (이메일)</label>
                <input type="text" id="loginId" name="loginId"
                       class="form-input" placeholder="이메일을 입력하세요"
                       autocomplete="username">
            </div>

            <div class="form-group">
                <label class="form-label" for="loginPw">비밀번호</label>
                <div class="input-pw-wrap">
                    <input type="password" id="loginPw" name="loginPw"
                           class="form-input" placeholder="비밀번호를 입력하세요"
                           autocomplete="current-password">
                    <button type="button" class="pw-toggle" aria-label="비밀번호 표시/숨기기">
                        <svg class="eye-icon" width="18" height="18" viewBox="0 0 24 24" fill="none"
                             stroke="currentColor" stroke-width="1.8">
                            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                            <circle cx="12" cy="12" r="3"/>
                        </svg>
                    </button>
                </div>
            </div>

            <div class="login-options">
                <label class="checkbox-label">
                    <input type="checkbox" name="rememberMe" id="rememberMe">
                    자동 로그인
                </label>
                <a href="${contextPath}/find/pw" class="find-link">비밀번호를 잊으셨나요?</a>
            </div>

            <button type="submit" class="btn-submit">로그인</button>
        </form>

        <%-- 하단 링크 --%>
        <p class="member-footer-link">
            아직 회원이 아니신가요?
            <a href="${contextPath}/join">회원가입</a>
        </p>
        <p class="member-footer-link" style="margin-top:12px">
            <a href="${contextPath}/admin/login" style="color:#888;font-size:13px">관리자 로그인</a>
        </p>

        <div class="find-links">
            <a href="${contextPath}/find/id">아이디 찾기</a>
            <a href="${contextPath}/find/pw">비밀번호 찾기</a>
        </div>

    </div>
</main>

<script>
    /* 비밀번호 표시/숨기기 */
    document.querySelector('.pw-toggle').addEventListener('click', function () {
        const input = document.getElementById('loginPw');
        const isText = input.type === 'text';
        input.type = isText ? 'password' : 'text';
        this.style.color = isText ? '' : 'var(--primary)';
    });
</script>
