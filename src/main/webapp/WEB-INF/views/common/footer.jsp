<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<footer class="pc-footer">
    <div class="footer-inner">
        <div class="footer-left">
            <a href="${contextPath}/" class="footer-logo">
                <svg width="26" height="26" viewBox="0 0 32 32" fill="none">
                    <ellipse cx="16" cy="20" rx="9" ry="8" fill="#2BAB82"/>
                    <ellipse cx="8"  cy="12" rx="3.2" ry="3.8" fill="#2BAB82"/>
                    <ellipse cx="13" cy="9.5" rx="3.2" ry="3.8" fill="#2BAB82"/>
                    <ellipse cx="19" cy="9.5" rx="3.2" ry="3.8" fill="#2BAB82"/>
                    <ellipse cx="24" cy="12" rx="3.2" ry="3.8" fill="#2BAB82"/>
                    <path d="M14.5 20.5 C14.5 19 16 18 16 18 C16 18 17.5 19 17.5 20.5 C17.5 22 16 23 16 23 C16 23 14.5 22 14.5 20.5Z" fill="white" opacity="0.85"/>
                </svg>
                <span>펫린이</span>
            </a>
            <p class="footer-copy">© 2024 펫린이. All rights reserved.</p>
        </div>

        <div class="footer-right">
    <div class="footer-team">
        <div class="footer-member">
            <p class="footer-member-name">하예주</p>
            <p><span class="footer-info-label">연락처</span> 010-0000-0000</p>
            <p><span class="footer-info-label">이메일</span> <a class="footer-info-value" href="mailto:yeju@example.com">example@example.com</a></p>
            <p><span class="footer-info-label">주소</span> 대전 서구 대덕대로 182</p>
        </div>
        <div class="footer-member">
            <p class="footer-member-name">박유정</p>
            <p><span class="footer-info-label">연락처</span> 010-0000-0000</p>
            <p><span class="footer-info-label">이메일</span> <a class="footer-info-value" href="mailto:yujeong@example.com">example@example.com</a></p>
            <p><span class="footer-info-label">주소</span> 대전 서구 대덕대로 182</p>
        </div>
        <div class="footer-member">
            <p class="footer-member-name">장우철</p>
            <p><span class="footer-info-label">연락처</span> 010-0000-0000</p>
            <p><span class="footer-info-label">이메일</span> <a class="footer-info-value" href="mailto:woochul@example.com">example@example.com</a></p>
            <p><span class="footer-info-label">주소</span> 대전 서구 대덕대로 182</p>
        </div>
        <div class="footer-member">
            <p class="footer-member-name">곽지윤</p>
            <p><span class="footer-info-label">연락처</span> 010-0000-0000</p>
            <p><span class="footer-info-label">이메일</span> <a class="footer-info-value" href="mailto:jiyoon@example.com">example@example.com</a></p>
            <p><span class="footer-info-label">주소</span> 대전 서구 대덕대로 182</p>
        </div>
    </div>
</div>
    </div>
</footer>
<script>window.__CONTEXT_PATH__ = '${contextPath}';</script>

<%-- 2026-08-05 HYJ — CSRF 토큰 공통 처리 (AJAX fetch 용) --%>
<script>
/**
 * CSRF 토큰을 자동으로 포함하는 fetch 래퍼
 *
 * [사용법]  기존 fetch 호출에서 fetch → csrfFetch 로만 바꾸면 됨
 *
 * 예시:
 *   기존: fetch('/store/cart/add', { method: 'POST', body: ... })
 *   변경: csrfFetch('/store/cart/add', { method: 'POST', body: ... })
 *
 * [동작]
 * 1. <meta name="_csrf"> 에서 토큰 값을 읽음
 * 2. 요청 headers 에 'X-CSRF-TOKEN' 을 자동 추가
 * 3. 원래 fetch 를 호출
 */
window.csrfFetch = function(url, options) {
    options = options || {};
    options.headers = options.headers || {};

    var csrfMeta = document.querySelector('meta[name="_csrf"]');
    if (csrfMeta) {
        options.headers['X-CSRF-TOKEN'] = csrfMeta.getAttribute('content');
    }

    return fetch(url, options);
};

// HYJ 26.08.05 모든 $.ajax POST 요청에 CSRF 토큰 자동 포함
if (typeof $ !== 'undefined' && $.ajaxSetup) {
    $.ajaxSetup({
        beforeSend: function(xhr) {
            var token = $('meta[name="_csrf"]').attr('content');
            if (token) {
                xhr.setRequestHeader('X-CSRF-TOKEN', token);
            }
        }
    });
}
</script>
<script src="${contextPath}/resources/js/search.js?v=20260705"></script>
<script src="${contextPath}/resources/js/wishlist.js?v=20260813"></script>
<%-- 지윤 26.07.08 추가: 헤더 장바구니 뱃지 숫자 실시간 갱신. 모든 페이지 로드마다 호출되고, 담기/삭제 후에도 재호출됨 --%>
<%-- 2026/07/11 장우철 — 헤더 미읽음 알림 배지 (장바구니와 동일 패턴) --%>
<script>
window.refreshCartCount = function () {
  fetch(window.__CONTEXT_PATH__ + '/store/cart/count')
    .then(function(res){ return res.text(); })
    .then(function(count){
      // 2026/07/23 장우철 — 숫자만 반영 (HTML 리다이렉트 응답이 뱃지에 덤프되지 않게)
      // 2026-07-24 박유정 — 헤더 뱃지만 갱신 (.header-utils)
      var n = parseInt(String(count).trim(), 10);
      if (isNaN(n)) return;
      document.querySelectorAll('.header-utils .cart-count').forEach(function(el){
        el.textContent = n > 99 ? '99+' : String(n);
      });
    })
    .catch(function(){ /* 비로그인·정지 회원 등 */ });
};
window.refreshNotiCount = function () {
  fetch(window.__CONTEXT_PATH__ + '/mypage/notifications/count')
    .then(function(res){ return res.text(); })
    .then(function(count){
      if (!/^\d+$/.test(String(count).trim())) return;
      var n = parseInt(count, 10) || 0;
      document.querySelectorAll('.noti-count').forEach(function(el){
        el.textContent = n > 99 ? '99+' : String(n);
        el.style.display = n > 0 ? 'flex' : 'none';
      });
    })
    .catch(function(){ /* 비로그인 등 */ });
};
refreshCartCount();
refreshNotiCount();
</script>
