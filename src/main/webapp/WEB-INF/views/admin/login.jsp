<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PetCare 관리자 로그인</title>
    <link rel="icon" href="${contextPath}/favicon.ico" sizes="any">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        * { box-sizing: border-box; }
        body {
            margin: 0;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(145deg, #1E2130 0%, #2a3050 100%);
            font-family: 'Noto Sans KR', sans-serif;
            padding: 20px;
        }
        .adm-login-box {
            width: 100%;
            max-width: 420px;
            background: #fff;
            border-radius: 16px;
            padding: 40px 36px 32px;
            box-shadow: 0 20px 60px rgba(0,0,0,.35);
        }
        .adm-login-logo {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            margin-bottom: 28px;
            text-decoration: none;
        }
        .adm-login-logo span {
            font-size: 20px;
            font-weight: 800;
            color: #1A1A2E;
        }
        .adm-login-tag {
            font-size: 10px;
            font-weight: 700;
            background: #E74C3C;
            color: #fff;
            padding: 3px 8px;
            border-radius: 4px;
        }
        .adm-login-title {
            font-size: 22px;
            font-weight: 800;
            color: #1A1A2E;
            text-align: center;
            margin: 0 0 8px;
        }
        .adm-login-desc {
            font-size: 14px;
            color: #888;
            text-align: center;
            margin: 0 0 28px;
            line-height: 1.6;
        }
        .adm-login-error {
            background: #FEF2F2;
            color: #DC2626;
            font-size: 13px;
            padding: 10px 14px;
            border-radius: 8px;
            margin-bottom: 16px;
            text-align: center;
        }
        .adm-login-field {
            margin-bottom: 16px;
        }
        .adm-login-field label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: #555;
            margin-bottom: 6px;
        }
        .adm-login-field input {
            width: 100%;
            border: 1px solid #E4E6ED;
            border-radius: 8px;
            padding: 12px 14px;
            font-size: 14px;
            outline: none;
            font-family: inherit;
        }
        .adm-login-field input:focus {
            border-color: #3B5BDB;
            box-shadow: 0 0 0 3px rgba(59,91,219,.12);
        }
        .adm-login-submit {
            width: 100%;
            margin-top: 8px;
            padding: 13px;
            border: none;
            border-radius: 8px;
            background: #3B5BDB;
            color: #fff;
            font-size: 15px;
            font-weight: 700;
            cursor: pointer;
            font-family: inherit;
        }
        .adm-login-submit:hover { background: #2F4AC7; }
        .adm-login-foot {
            margin-top: 22px;
            text-align: center;
            font-size: 13px;
            color: #999;
        }
        .adm-login-foot a {
            color: #3B5BDB;
            text-decoration: none;
            font-weight: 600;
        }
        .adm-login-foot a:hover { text-decoration: underline; }
        .adm-login-hint {
            margin-top: 18px;
            padding: 12px 14px;
            background: #F8F9FF;
            border-radius: 8px;
            font-size: 12px;
            color: #666;
            line-height: 1.6;
        }
        .adm-login-hint strong { color: #3B5BDB; }
    </style>
</head>
<body>
    <div class="adm-login-box">
        <a href="${contextPath}/" class="adm-login-logo">
            <svg width="32" height="32" viewBox="0 0 32 32" fill="none">
                <ellipse cx="16" cy="20" rx="9" ry="8" fill="#2BAB82"/>
                <ellipse cx="8"  cy="12" rx="3.2" ry="3.8" fill="#2BAB82"/>
                <ellipse cx="13" cy="9.5" rx="3.2" ry="3.8" fill="#2BAB82"/>
                <ellipse cx="19" cy="9.5" rx="3.2" ry="3.8" fill="#2BAB82"/>
                <ellipse cx="24" cy="12" rx="3.2" ry="3.8" fill="#2BAB82"/>
            </svg>
            <span>PetCare</span>
            <span class="adm-login-tag">ADMIN</span>
        </a>

        <h1 class="adm-login-title">관리자 로그인</h1>
        <p class="adm-login-desc">관리자 센터에 접속하려면<br>관리자 계정으로 로그인하세요.</p>

        <c:if test="${param.error eq 'empty'}">
            <div class="adm-login-error">아이디와 비밀번호를 입력해 주세요.</div>
        </c:if>
        <c:if test="${param.error eq 'invalid'}">
            <div class="adm-login-error">관리자 계정이 아니거나 로그인 정보가 올바르지 않습니다.</div>
        </c:if>

        <form action="${contextPath}/admin/login" method="post">
            <!--HYJ 26.08.05-->
            <input type="hidden" name="_csrf" value="${_csrf}">
            
            <div class="adm-login-field">
                <label for="loginId">관리자 아이디</label>
                <input type="text" id="loginId" name="loginId" placeholder="admin" autocomplete="username">
            </div>
            <div class="adm-login-field">
                <label for="loginPw">비밀번호</label>
                <input type="password" id="loginPw" name="loginPw" placeholder="비밀번호" autocomplete="current-password">
            </div>
            <button type="submit" class="adm-login-submit">관리자 로그인</button>
        </form>

        <div class="adm-login-hint">
            테스트 계정: <strong>admin</strong> / 비밀번호 아무 값<br>
            (DB 연동 전 프로토타입용)
        </div>

        <p class="adm-login-foot">
            <a href="${contextPath}/">← 일반 회원 사이트로 이동</a>
        </p>
    </div>
</body>
</html>
