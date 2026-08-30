<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="mypage" />
<c:set var="sec" value="points" />

<%@ include file="/WEB-INF/views/common/header.jsp" %>
<link rel="stylesheet" href="${contextPath}/resources/css/mypage.css">

<div class="mypage-wrap">
<%@ include file="/WEB-INF/views/mypage/sidebar.jsp" %>
<div class="mypage-content">

<%-- ── 포인트/쿠폰 ── --%>
<div class="mp-section active">
    <h2 class="mp-title">포인트 / 쿠폰</h2>
    <p class="mp-desc">포인트 적립·사용 내역과 보유 쿠폰을 관리하세요.</p>
    <%-- 2026/08/01 장우철 — 포인트 실데이터(HEAD) + 쿠폰 개수(yeju usableCouponCount) --%>
    <div class="point-summary">
        <div class="point-summary-item">
            <span class="ps-label">보유 포인트</span>
            <span class="ps-val"><fmt:formatNumber value="${pointBalance}" pattern="#,###"/></span>
            <span class="ps-unit">P</span>
        </div>
        <div class="point-summary-item">
            <span class="ps-label">이번 달 적립</span>
            <span class="ps-val">+<fmt:formatNumber value="${thisMonthEarned}" pattern="#,###"/></span>
            <span class="ps-unit">P</span>
        </div>
        <div class="point-summary-item">
            <span class="ps-label">보유 쿠폰</span>
            <span class="ps-val">${not empty usableCouponCount ? usableCouponCount : couponCount}</span>
            <span class="ps-unit">장</span>
        </div>
    </div>
    <div class="mp-tab-bar">
        <button class="mp-tab on">포인트 내역</button>
        <button class="mp-tab">쿠폰함</button>
    </div>
    <%-- 지윤 26.07.29 수정: 하드코딩 4줄 -> Controller가 넘긴 pointHistory(실데이터) JSTL 렌더링으로 교체 --%>
    <div id="tab-points">
        <table class="mp-table">
            <thead><tr><th>날짜</th><th>내용</th><th>구분</th><th style="text-align:right">포인트</th></tr></thead>
            <tbody>
                <c:choose>
                    <c:when test="${empty pointHistory}">
                        <tr><td colspan="4" style="text-align:center;color:#999;padding:24px 0">포인트 내역이 없습니다.</td></tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="p" items="${pointHistory}">
                            <tr>
                                <td>${p.regDate}</td>
                                <td>${p.content}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${p.pointType == 'EARN'}"><span class="badge-status badge-done">적립</span></c:when>
                                        <c:when test="${p.pointType == 'REFUND'}"><span class="badge-status badge-done">환급</span></c:when>
                                        <c:when test="${p.pointType == 'USE'}"><span class="badge-status badge-cancel">사용</span></c:when>
                                        <c:otherwise><span class="badge-status">${p.pointType}</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <c:choose>
                                    <c:when test="${p.pointType == 'USE'}">
                                        <td style="text-align:right;color:var(--accent);font-weight:700">-<fmt:formatNumber value="${p.pointAmount}" pattern="#,###"/> P</td>
                                    </c:when>
                                    <c:otherwise>
                                        <td style="text-align:right;color:var(--primary-dark);font-weight:700">+<fmt:formatNumber value="${p.pointAmount}" pattern="#,###"/> P</td>
                                    </c:otherwise>
                                </c:choose>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>
    <div id="tab-coupons" style="display:none">
        <c:choose>
            <c:when test="${empty myCoupons}">
                <div style="text-align:center;padding:48px 0;color:var(--text-muted);font-size:14px">
                    보유한 쿠폰이 없습니다.<br>
                    <a href="${contextPath}/coupon" style="color:var(--primary);font-weight:700;text-decoration:underline;margin-top:8px;display:inline-block">쿠폰 받으러 가기</a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="coupon-grid">
                    <c:forEach var="mc" items="${myCoupons}">
                        <div class="coupon-card ${mc.memberCouponStatus eq 'USED' ? 'used' : ''} ${mc.memberCouponStatus eq 'EXPIRED' ? 'used' : ''}">
                            <div class="coupon-left">
                                <div class="c-discount">
                                    <c:choose>
                                        <c:when test="${mc.couponType eq 'FIXED'}">
                                            <fmt:formatNumber value="${mc.discountValue}" type="number"/>원 할인
                                        </c:when>
                                        <c:when test="${mc.couponType eq 'RATE'}">
                                            ${mc.discountValue}% 할인
                                        </c:when>
                                    </c:choose>
                                </div>
                                <div class="c-name">${mc.couponName}</div>
                                <div class="c-expire">
                                    <c:choose>
                                        <c:when test="${mc.memberCouponStatus eq 'UNUSED'}">
                                            만료: ${mc.useEndDate.substring(0,4)}.${mc.useEndDate.substring(4,6)}.${mc.useEndDate.substring(6,8)}
                                        </c:when>
                                        <c:when test="${mc.memberCouponStatus eq 'USED'}">사용완료</c:when>
                                        <c:when test="${mc.memberCouponStatus eq 'EXPIRED'}">기간만료</c:when>
                                    </c:choose>
                                </div>
                            </div>
                            <svg viewBox="0 0 24 24"><path d="M20 12v10H4V12"/><path d="M22 7H2v5h20V7z"/><path d="M12 22V7"/><path d="M12 7H7.5a2.5 2.5 0 010-5C11 2 12 7 12 7z"/><path d="M12 7h4.5a2.5 2.5 0 000-5C13 2 12 7 12 7z"/></svg>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>



<script>
document.querySelectorAll('.mp-tab-bar .mp-tab').forEach(function(tab) {
    tab.addEventListener('click', function() {
        var bar = this.closest('.mp-tab-bar');
        bar.querySelectorAll('.mp-tab').forEach(function(t){ t.classList.remove('on'); });
        this.classList.add('on');
        var idx = Array.from(bar.querySelectorAll('.mp-tab')).indexOf(this);
        var tabs = [document.getElementById('tab-points'), document.getElementById('tab-coupons')];
        tabs.forEach(function(t){ if(t) t.style.display='none'; });
        if(tabs[idx]) tabs[idx].style.display = 'block';
    });
});
</script>

</div><%-- /mypage-content --%>
</div><%-- /mypage-wrap --%>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
