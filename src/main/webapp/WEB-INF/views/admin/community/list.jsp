<%--
  - 박유정 / 2026-07-15
  - GET /admin/community/list → ${list}, ${totalCount}
  - POST 숨김·삭제·복구 (상태별 버튼 분기)
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="adminPage"   value="community-list" />
<%@ include file="/WEB-INF/views/admin/common/header.jsp" %>
<%@ include file="/WEB-INF/views/admin/common/sidebar.jsp" %>

<main class="adm-main">
    <div class="adm-page-head">
        <div class="adm-page-head-left">
            <h1 class="adm-page-title">커뮤니티 관리</h1>
            <p class="adm-page-desc">게시글을 모니터링하고 신고 게시글을 처리하세요.</p>
        </div>
    </div>

    <c:if test="${not empty successMsg}">
        <%-- 2026-07-15 박유정 — 처리 결과 flash (숨김/삭제/복구 redirect) --%>
        <div style="background:#ECFDF5;border:1px solid #BBF7D0;color:#166534;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:14px">${successMsg}</div>
    </c:if>
    <c:if test="${not empty errorMsg}">
        <div style="background:#FEF2F2;border:1px solid #FECACA;color:#B91C1C;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:14px">${errorMsg}</div>
    </c:if>

    <div class="adm-card">
        <div class="adm-card-head">
            <span class="adm-card-head-title">게시글 목록</span>
            <span class="adm-card-head-sub">총 ${totalCount}건</span>
        </div>
        <div class="adm-card-body" style="padding-bottom:0">
            <%-- 2026-07-15 박유정 — GET 검색 (keyword, boardType, statusCd) --%>
            <form method="get" action="${contextPath}/admin/community/list" class="adm-filter-bar">
                <input type="text" name="keyword" class="adm-filter-input"
                       placeholder="제목, 작성자로 검색" value="${keyword}">
                <select name="boardType" class="adm-filter-select">
                    <option value="" ${boardType eq '' ? 'selected' : ''}>게시판 전체</option>
                    <option value="TOWN" ${boardType eq 'TOWN' ? 'selected' : ''}>집사생활</option>
                    <option value="SHARE" ${boardType eq 'SHARE' ? 'selected' : ''}>무료나눔</option>
                    <option value="LIFE" ${boardType eq 'LIFE' ? 'selected' : ''}>수의사 상담</option>
                </select>
                <select name="statusCd" class="adm-filter-select">
                    <option value="" ${statusCd eq '' ? 'selected' : ''}>상태 전체</option>
                    <option value="ACTIVE" ${statusCd eq 'ACTIVE' ? 'selected' : ''}>정상</option>
                    <option value="HIDDEN" ${statusCd eq 'HIDDEN' ? 'selected' : ''}>숨김</option>
                    <option value="DELETED" ${statusCd eq 'DELETED' ? 'selected' : ''}>삭제</option>
                </select>
                <button type="submit" class="adm-filter-btn primary">
                    <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                    검색
                </button>
            </form>
        </div>
        <div class="adm-table-wrap">
            <table class="adm-table">
                <thead>
                    <tr><th>번호</th><th>게시판</th><th>제목</th><th>작성자</th><th>조회</th><th>신고</th><th>상태</th><th>작성일</th><th>처리</th></tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty list}">
                            <tr>
                                <td colspan="9" style="text-align:center;color:#999;padding:40px 0">
                                    게시글이 없습니다.
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="item" items="${list}">
                                <tr>
                                    <td>${item.postId}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${item.boardType eq 'TOWN'}">집사생활</c:when>
                                            <c:when test="${item.boardType eq 'SHARE'}">무료나눔</c:when>
                                            <c:when test="${item.boardType eq 'LIFE'}">수의사 상담</c:when>
                                            <c:otherwise>${item.boardType}</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td><strong>${item.title}</strong></td>
                                    <td>${item.authorName}</td>
                                    <td>${item.viewCount}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${item.reportCount != null && item.reportCount > 0}">
                                                <span style="color:#DC2626;font-weight:700">${item.reportCount}건</span>
                                            </c:when>
                                            <c:otherwise>0건</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <%-- 2026/08/06 장우철 — 신고 대기 > 신고 기각 > 게시글 상태 --%>
                                        <c:choose>
                                            <c:when test="${item.pendingReportCount != null && item.pendingReportCount > 0}">
                                                <span class="adm-badge wait">신고 대기</span>
                                            </c:when>
                                            <c:when test="${item.dismissedReportCount != null && item.dismissedReportCount > 0}">
                                                <span class="adm-badge" style="background:#F1F3F7;color:#666">신고 기각</span>
                                            </c:when>
                                            <c:when test="${item.statusCd eq 'HIDDEN'}">
                                                <span class="adm-badge cancel">숨김</span>
                                            </c:when>
                                            <c:when test="${item.statusCd eq 'DELETED'}">
                                                <span class="adm-badge cancel">삭제</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="adm-badge active">정상</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:if test="${not empty item.regDate}">
                                            ${item.regDate.year}.${item.regDate.monthValue}.${item.regDate.dayOfMonth}
                                        </c:if>
                                    </td>
                                    <td style="white-space:nowrap">
                                        <a href="${contextPath}/admin/community/detail?id=${item.postId}" class="adm-btn blue">보기</a>
                                        <%-- 2026-07-15 박유정 — 상태별 처리: ACTIVE=숨김+삭제, HIDDEN=복구+삭제, DELETED=복구 --%>
                                        <c:choose>
                                            <c:when test="${item.statusCd eq 'HIDDEN'}">
                                                <form method="post" action="${contextPath}/admin/community/restore"
                                                      style="display:inline;margin:0"
                                                      onsubmit="return confirm('다시 게시하시겠습니까?')">
                                                    <!--HYJ 26.08.05-->
                                                    <input type="hidden" name="_csrf" value="${_csrf}">  
                                                    
                                                    <input type="hidden" name="postId" value="${item.postId}">
                                                    <button type="submit" class="adm-btn green" style="margin-left:4px">복구</button>
                                                </form>
                                                <form method="post" action="${contextPath}/admin/community/delete"
                                                      style="display:inline;margin:0"
                                                      onsubmit="return confirm('삭제하시겠습니까?')">
                                                    <!--HYJ 26.08.05-->
                                                    <input type="hidden" name="_csrf" value="${_csrf}">  
                                                    
                                                    <input type="hidden" name="postId" value="${item.postId}">
                                                    <input type="hidden" name="memberNo" value="${item.memberNo}">
                                                    <button type="submit" class="adm-btn red" style="margin-left:4px">삭제</button>
                                                </form>
                                            </c:when>
                                            <c:when test="${item.statusCd eq 'DELETED'}">
                                                <form method="post" action="${contextPath}/admin/community/restore"
                                                      style="display:inline;margin:0"
                                                      onsubmit="return confirm('다시 게시하시겠습니까?')">
                                                    <!--HYJ 26.08.05-->
                                                    <input type="hidden" name="_csrf" value="${_csrf}">  
                                                    
                                                    <input type="hidden" name="postId" value="${item.postId}">
                                                    <button type="submit" class="adm-btn green" style="margin-left:4px">복구</button>
                                                </form>
                                            </c:when>
                                            <c:otherwise>
                                                <form method="post" action="${contextPath}/admin/community/hide"
                                                      style="display:inline;margin:0"
                                                      onsubmit="return confirm('숨김 처리하시겠습니까?')">
                                                    <!--HYJ 26.08.05-->
                                                    <input type="hidden" name="_csrf" value="${_csrf}">  
                                                    
                                                    <input type="hidden" name="postId" value="${item.postId}">
                                                    <button type="submit" class="adm-btn gray" style="margin-left:4px">숨김</button>
                                                </form>
                                                <form method="post" action="${contextPath}/admin/community/delete"
                                                      style="display:inline;margin:0"
                                                      onsubmit="return confirm('삭제하시겠습니까?')">
                                                    <!--HYJ 26.08.05-->
                                                    <input type="hidden" name="_csrf" value="${_csrf}">  
                                                    
                                                    <input type="hidden" name="postId" value="${item.postId}">
                                                    <input type="hidden" name="memberNo" value="${item.memberNo}">
                                                    <button type="submit" class="adm-btn red" style="margin-left:4px">삭제</button>
                                                </form>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
        <div style="padding:16px 20px;border-top:1px solid #E4E6ED;display:flex;justify-content:center">
            <div class="adm-pagination" style="margin:0">
                <c:if test="${page > 1}">
                    <a href="${contextPath}/admin/community/list?keyword=${keyword}&boardType=${boardType}&statusCd=${statusCd}&page=${page - 1}"
                       class="adm-page-btn">
                        <svg viewBox="0 0 24 24"><polyline points="15 18 9 12 15 6"/></svg>
                    </a>
                </c:if>
                <span class="adm-page-btn active">${page}</span>
                <c:if test="${page * 10 < totalCount}">
                    <a href="${contextPath}/admin/community/list?keyword=${keyword}&boardType=${boardType}&statusCd=${statusCd}&page=${page + 1}"
                       class="adm-page-btn">
                        <svg viewBox="0 0 24 24"><polyline points="9 18 15 12 9 6"/></svg>
                    </a>
                </c:if>
            </div>
        </div>
    </div>
</main>

<%@ include file="/WEB-INF/views/admin/common/footer.jsp" %>
