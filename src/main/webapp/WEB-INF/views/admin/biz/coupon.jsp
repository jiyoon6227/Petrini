<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
  역할: 관리자 쿠폰 승인 관리 (/admin/biz/coupon/list)

  [model]
  - list, tab, status, tabCounts, successMsg, errorMsg
  1. GET ?tab=review&status=PENDING|REJECTED
  2. GET ?tab=published (게시중 ACTIVE)
  3. GET ?tab=exhausted (예산·수량 소진 EXHAUSTED)
  2026-08-13 박유정 — 3탭 분리 (승인대기 / 게시중 / 소진)
--%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="adminPage" value="coupon-list" />
<%@ include file="/WEB-INF/views/admin/common/header.jsp" %>
<%@ include file="/WEB-INF/views/admin/common/sidebar.jsp" %>

<style>
    /* ── 탭 ── */
    .cpn-tab-bar {
        display:flex; gap:0; align-items:flex-end;
        border-bottom:2px solid #E4E6ED; margin-bottom:20px;
    }
    .cpn-tab {
        padding:10px 22px; font-size:14px; font-weight:600;
        color:#999; background:none; cursor:pointer;
        border:none; border-bottom:2px solid transparent;
        margin-bottom:-2px; transition:all .15s;
        text-decoration:none; display:inline-flex; align-items:center;
        box-sizing:border-box;
    }
    .cpn-tab:link, .cpn-tab:visited { color:#999; text-decoration:none; }
    .cpn-tab:hover { color:#3B5BDB; }
    .cpn-tab.on { color:#3B5BDB; border-bottom-color:#3B5BDB; font-weight:700; }

    /* ── 쿠폰 카드 ── */
    .cpn-card {
        background:#fff; border:1px solid #E4E6ED;
        border-radius:12px; overflow:hidden;
        margin-bottom:16px; transition:box-shadow .2s;
    }
    .cpn-card:hover { box-shadow:0 4px 16px rgba(0,0,0,.07); }
    .cpn-head {
        display:flex; align-items:center; gap:14px;
        padding:16px 20px; border-bottom:1px solid #E4E6ED; background:#FAFBFC;
    }
    .cpn-icon {
        width:44px; height:44px; border-radius:10px; background:#EEF2FF;
        display:flex; align-items:center; justify-content:center; flex-shrink:0;
    }
    .cpn-icon svg { width:22px; height:22px; fill:none; stroke:#3B5BDB; stroke-width:1.8; stroke-linecap:round; stroke-linejoin:round; }
    .cpn-biz-name { font-size:15px; font-weight:800; color:#1A1A2E; }
    .cpn-biz-sub  { font-size:12px; color:#999; margin-top:2px; }
    .cpn-date     { margin-left:auto; font-size:12px; color:#999; flex-shrink:0; }

    .cpn-body {
        display:grid; grid-template-columns:repeat(4, 1fr);
        border-bottom:1px solid #E4E6ED;
    }
    .cpn-field { padding:14px 18px; border-right:1px solid #E4E6ED; }
    .cpn-field:last-child { border-right:none; }
    .cpn-field label { font-size:11px; color:#999; font-weight:600; display:block; margin-bottom:4px; }
    .cpn-field span  { font-size:13px; color:#1A1A2E; font-weight:500; }

    .cpn-foot {
        display:flex; justify-content:space-between; align-items:center;
        padding:12px 18px;
    }
    .cpn-reject-wrap { display:flex; gap:8px; align-items:center; }
    .cpn-reject-input {
        border:1px solid #E4E6ED; border-radius:6px;
        padding:7px 12px; font-size:13px; color:#333;
        outline:none; width:260px; display:block; font-family:inherit;
    }
    .cpn-reject-input:focus { border-color:#3B5BDB; }

    /* ── 예산 프로그레스 ── */
    .cpn-progress-bar {
        background:#F1F3F7; border-radius:4px; height:5px; margin-top:4px; overflow:hidden;
    }
    .cpn-progress-fill {
        height:100%; border-radius:4px; background:#3B5BDB; transition:width .3s;
    }
</style>

<main class="adm-main">
    <div class="adm-page-head">
        <div class="adm-page-head-left">
            <h1 class="adm-page-title">쿠폰 승인 관리</h1>
            <p class="adm-page-desc">사업자가 신청한 쿠폰을 검토하고 승인하면 사용자 이벤트/쿠폰 게시판에 게시됩니다.</p>
        </div>
    </div>

    <%-- 알림 메시지 --%>
    <c:if test="${not empty successMsg}">
        <div style="background:#ECFDF5;border:1px solid #BBF7D0;color:#166534;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:14px">
            ${successMsg}
        </div>
    </c:if>
    <c:if test="${not empty errorMsg}">
        <div style="background:#FEF2F2;border:1px solid #FECACA;color:#B91C1C;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:14px">
            ${errorMsg}
        </div>
    </c:if>

    <%-- 2026-08-13 박유정 — 관리자승인 / 승인(게시중) / 예산소진 --%>
    <div class="cpn-tab-bar">
        <a href="${contextPath}/admin/biz/coupon/list?tab=review&status=PENDING"
           class="cpn-tab ${tab eq 'review' ? 'on' : ''}">
            관리자 승인
            <span style="background:#EEF2FF;color:#3B5BDB;font-size:11px;padding:1px 7px;border-radius:20px;margin-left:4px">
                ${tabCounts.PENDING}
            </span>
        </a>
        <a href="${contextPath}/admin/biz/coupon/list?tab=published"
           class="cpn-tab ${tab eq 'published' ? 'on' : ''}">
            승인 (게시 중)
            <span style="background:#DCFCE7;color:#16A34A;font-size:11px;padding:1px 7px;border-radius:20px;margin-left:4px">
                ${tabCounts.PUBLISHED}
            </span>
        </a>
        <a href="${contextPath}/admin/biz/coupon/list?tab=exhausted"
           class="cpn-tab ${tab eq 'exhausted' ? 'on' : ''}">
            예산 소진
            <span style="background:#F1F3F7;color:#999;font-size:11px;padding:1px 7px;border-radius:20px;margin-left:4px">
                ${tabCounts.EXHAUSTED}
            </span>
        </a>
    </div>

    <%-- 관리자 승인: 승인대기 / 반려 서브탭 --%>
    <c:if test="${tab eq 'review'}">
        <div class="cpn-tab-bar" style="margin-top:-8px">
            <a href="${contextPath}/admin/biz/coupon/list?tab=review&status=PENDING"
               class="cpn-tab ${status eq 'PENDING' ? 'on' : ''}">
                승인 대기
                <span style="background:#EEF2FF;color:#3B5BDB;font-size:11px;padding:1px 7px;border-radius:20px;margin-left:4px">
                    ${tabCounts.PENDING}
                </span>
            </a>
            <a href="${contextPath}/admin/biz/coupon/list?tab=review&status=REJECTED"
               class="cpn-tab ${status eq 'REJECTED' ? 'on' : ''}">
                반려
                <span style="background:#F1F3F7;color:#999;font-size:11px;padding:1px 7px;border-radius:20px;margin-left:4px">
                    ${tabCounts.REJECTED}
                </span>
            </a>
        </div>
    </c:if>

    <%-- ========== 승인 대기 (PENDING) ========== --%>
    <c:if test="${tab eq 'review' and status eq 'PENDING'}">
        <c:choose>
            <c:when test="${empty list}">
                <p style="text-align:center;color:#999;padding:48px 0">승인 대기 중인 쿠폰이 없습니다.</p>
            </c:when>
            <c:otherwise>
                <c:forEach var="cpn" items="${list}">
                    <div class="cpn-card">
                        <div class="cpn-head">
                            <div class="cpn-icon">
                                <svg viewBox="0 0 24 24">
                                    <rect x="2" y="5" width="20" height="14" rx="2"/>
                                    <line x1="2" y1="10" x2="22" y2="10"/>
                                </svg>
                            </div>
                            <div>
                                <div class="cpn-biz-name">${cpn.couponName}</div>
                                <div class="cpn-biz-sub">${cpn.bizName} · ${cpn.couponCode}</div>
                            </div>
                            <span class="adm-badge wait" style="margin-left:12px">승인 대기</span>
                            <span class="cpn-date">
                                신청일: ${cpn.regDate.substring(0,4)}.${cpn.regDate.substring(4,6)}.${cpn.regDate.substring(6,8)}
                            </span>
                        </div>
                        <div class="cpn-body">
                            <div class="cpn-field">
                                <label>할인 유형</label>
                                <span>
                                    <c:choose>
                                        <c:when test="${cpn.couponType eq 'FIXED'}">정액 할인</c:when>
                                        <c:when test="${cpn.couponType eq 'RATE'}">정률 할인</c:when>
                                    </c:choose>
                                </span>
                            </div>
                            <div class="cpn-field">
                                <label>할인값</label>
                                <span>
                                    <c:choose>
                                        <c:when test="${cpn.couponType eq 'FIXED'}">
                                            <fmt:formatNumber value="${cpn.discountValue}" type="number"/>원
                                        </c:when>
                                        <c:when test="${cpn.couponType eq 'RATE'}">
                                            ${cpn.discountValue}%
                                        </c:when>
                                    </c:choose>
                                </span>
                            </div>
                            <div class="cpn-field">
                                <label>총 예산</label>
                                <span><fmt:formatNumber value="${cpn.totalBudget}" type="number"/>원</span>
                            </div>
                            <div class="cpn-field">
                                <label>발급 수량</label>
                                <span>${cpn.totalQty}장</span>
                            </div>
                        </div>
                        <div class="cpn-body" style="grid-template-columns:repeat(3, 1fr)">
                            <div class="cpn-field">
                                <label>최소 주문 금액</label>
                                <span><fmt:formatNumber value="${cpn.minOrderAmt}" type="number"/>원</span>
                            </div>
                            <div class="cpn-field">
                                <label>사용 기간</label>
                                <span>
                                    ${cpn.useStartDate.substring(0,4)}.${cpn.useStartDate.substring(4,6)}.${cpn.useStartDate.substring(6,8)}
                                    ~
                                    ${cpn.useEndDate.substring(0,4)}.${cpn.useEndDate.substring(4,6)}.${cpn.useEndDate.substring(6,8)}
                                </span>
                            </div>
                            <div class="cpn-field">
                                <label>장당 비용 (사업자 부담)</label>
                                <span>
                                    <c:choose>
                                        <c:when test="${cpn.couponType eq 'FIXED'}">
                                            <fmt:formatNumber value="${cpn.discountValue}" type="number"/>원 × ${cpn.totalQty}장
                                        </c:when>
                                        <c:otherwise>최대 ${cpn.discountValue}%</c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                        </div>
                        <div class="cpn-foot">
                            <div style="font-size:13px;color:#555">
                                사업자: ${cpn.bizName}
                            </div>
                            <div class="cpn-reject-wrap">
                                <form method="post" action="${contextPath}/admin/biz/coupon/reject"
                                      style="display:flex;gap:8px;align-items:center"
                                      onsubmit="return confirm('반려하시겠습니까?')">
                                    <!--HYJ 26.08.05-->
                                    <input type="hidden" name="_csrf" value="${_csrf}">

                                    <input type="hidden" name="couponId" value="${cpn.couponId}">
                                    <input type="text" name="rejectReason" class="cpn-reject-input"
                                           placeholder="반려 사유 입력" required>
                                    <button type="submit" class="adm-btn gray">반려</button>
                                </form>
                                <form method="post" action="${contextPath}/admin/biz/coupon/approve"
                                      style="display:inline"
                                      onsubmit="return confirm('승인하시겠습니까?\n이벤트/쿠폰 게시판에 노출됩니다.')">
                                    <!--HYJ 26.08.05-->
                                    <input type="hidden" name="_csrf" value="${_csrf}">

                                    <input type="hidden" name="couponId" value="${cpn.couponId}">
                                    <button type="submit" class="adm-btn green">승인</button>
                                </form>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </c:if>

    <%-- ========== 승인 (게시 중) ========== --%>
    <c:if test="${tab eq 'published'}">
        <c:choose>
            <c:when test="${empty list}">
                <p style="text-align:center;color:#999;padding:48px 0">게시 중인 쿠폰이 없습니다.</p>
            </c:when>
            <c:otherwise>
                <table class="adm-table">
                    <thead>
                        <tr>
                            <th>쿠폰명</th>
                            <th>사업자</th>
                            <th>할인</th>
                            <th>예산 소진</th>
                            <th>발급 현황</th>
                            <th>사용 기간</th>
                            <th>상태</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="cpn" items="${list}">
                            <tr>
                                <td>
                                    <div style="font-weight:600">${cpn.couponName}</div>
                                    <div style="font-size:11px;color:#999">${cpn.couponCode}</div>
                                </td>
                                <td>${cpn.bizName}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${cpn.couponType eq 'FIXED'}">
                                            <fmt:formatNumber value="${cpn.discountValue}" type="number"/>원
                                        </c:when>
                                        <c:when test="${cpn.couponType eq 'RATE'}">
                                            ${cpn.discountValue}%
                                        </c:when>
                                    </c:choose>
                                </td>
                                <td>
                                    <fmt:formatNumber value="${cpn.issuedBudget}" type="number"/>
                                    / <fmt:formatNumber value="${cpn.totalBudget}" type="number"/>원
                                    <c:if test="${cpn.totalBudget > 0}">
                                        <div class="cpn-progress-bar">
                                            <div class="cpn-progress-fill"
                                                 style="width:${cpn.issuedBudget * 100 / cpn.totalBudget}%"></div>
                                        </div>
                                    </c:if>
                                </td>
                                <td>${cpn.issuedQty} / ${cpn.totalQty}장</td>
                                <td>
                                    ${cpn.useStartDate.substring(0,4)}.${cpn.useStartDate.substring(4,6)}.${cpn.useStartDate.substring(6,8)}
                                    ~
                                    ${cpn.useEndDate.substring(0,4)}.${cpn.useEndDate.substring(4,6)}.${cpn.useEndDate.substring(6,8)}
                                </td>
                                <td>
                                    <span class="adm-badge active">게시 중</span>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>
    </c:if>

    <%-- ========== 예산 소진 (EXHAUSTED) ========== --%>
    <c:if test="${tab eq 'exhausted'}">
        <c:choose>
            <c:when test="${empty list}">
                <p style="text-align:center;color:#999;padding:48px 0">예산·수량이 소진된 쿠폰이 없습니다.</p>
            </c:when>
            <c:otherwise>
                <table class="adm-table">
                    <thead>
                        <tr>
                            <th>쿠폰명</th>
                            <th>사업자</th>
                            <th>할인</th>
                            <th>예산 소진</th>
                            <th>발급 현황</th>
                            <th>사용 기간</th>
                            <th>상태</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="cpn" items="${list}">
                            <tr>
                                <td>
                                    <div style="font-weight:600">${cpn.couponName}</div>
                                    <div style="font-size:11px;color:#999">${cpn.couponCode}</div>
                                </td>
                                <td>${cpn.bizName}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${cpn.couponType eq 'FIXED'}">
                                            <fmt:formatNumber value="${cpn.discountValue}" type="number"/>원
                                        </c:when>
                                        <c:when test="${cpn.couponType eq 'RATE'}">
                                            ${cpn.discountValue}%
                                        </c:when>
                                    </c:choose>
                                </td>
                                <td>
                                    <fmt:formatNumber value="${cpn.issuedBudget}" type="number"/>
                                    / <fmt:formatNumber value="${cpn.totalBudget}" type="number"/>원
                                    <c:if test="${cpn.totalBudget > 0}">
                                        <div class="cpn-progress-bar">
                                            <div class="cpn-progress-fill"
                                                 style="width:100%"></div>
                                        </div>
                                    </c:if>
                                </td>
                                <td>${cpn.issuedQty} / ${cpn.totalQty}장</td>
                                <td>
                                    ${cpn.useStartDate.substring(0,4)}.${cpn.useStartDate.substring(4,6)}.${cpn.useStartDate.substring(6,8)}
                                    ~
                                    ${cpn.useEndDate.substring(0,4)}.${cpn.useEndDate.substring(4,6)}.${cpn.useEndDate.substring(6,8)}
                                </td>
                                <td>
                                    <span class="adm-badge" style="background:#F1F3F7;color:#999">예산 소진</span>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>
    </c:if>

    <%-- ========== 반려 (REJECTED) ========== --%>
    <c:if test="${tab eq 'review' and status eq 'REJECTED'}">
        <c:choose>
            <c:when test="${empty list}">
                <p style="text-align:center;color:#999;padding:48px 0">반려된 쿠폰이 없습니다.</p>
            </c:when>
            <c:otherwise>
                <table class="adm-table">
                    <thead>
                        <tr>
                            <th>쿠폰명</th>
                            <th>사업자</th>
                            <th>할인</th>
                            <th>총 예산</th>
                            <th>반려 사유</th>
                            <th>신청일</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="cpn" items="${list}">
                            <tr>
                                <td>${cpn.couponName}</td>
                                <td>${cpn.bizName}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${cpn.couponType eq 'FIXED'}">
                                            <fmt:formatNumber value="${cpn.discountValue}" type="number"/>원
                                        </c:when>
                                        <c:when test="${cpn.couponType eq 'RATE'}">
                                            ${cpn.discountValue}%
                                        </c:when>
                                    </c:choose>
                                </td>
                                <td><fmt:formatNumber value="${cpn.totalBudget}" type="number"/>원</td>
                                <td style="color:#DC2626">${cpn.rejectReason}</td>
                                <td>
                                    ${cpn.regDate.substring(0,4)}.${cpn.regDate.substring(4,6)}.${cpn.regDate.substring(6,8)}
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>
    </c:if>
</main>

<%@ include file="/WEB-INF/views/admin/common/footer.jsp" %>
