<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- 사업자센터 전용 푸터 --%>
</div><%-- /biz-body --%>
</div><%-- /biz-page --%>
</body>

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

</html>
