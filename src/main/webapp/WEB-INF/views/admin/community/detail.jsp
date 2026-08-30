<%--
  - 박유정 / 2026-07-15
  - GET /admin/community/detail?id= → ${post}
  - POST 숨김·삭제·복구 (상태별 버튼 분기)
  - 2026/08/06 장우철 — 신고 건수·내역확인 모달·신고 기각 연동
  - 2026/08/07 장우철 — 댓글·대댓글 읽기 전용 표시
--%>


<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="adminPage"   value="community-list" />
<%@ include file="/WEB-INF/views/admin/common/header.jsp" %>
<%@ include file="/WEB-INF/views/admin/common/sidebar.jsp" %>

<%-- 2026-07-15 박유정 — 상세 레이아웃·처리 버튼 너비 통일 --%>
<style>
    .comm-detail-breadcrumb{font-size:13px;color:#999;margin-bottom:20px;display:flex;align-items:center;gap:8px}
    .comm-detail-breadcrumb a{color:#999;text-decoration:none}
    .comm-detail-breadcrumb a:hover{color:#3B5BDB}
    .comm-detail-grid{display:grid;grid-template-columns:1fr 320px;gap:20px;align-items:flex-start}
    .comm-detail-main{display:flex;flex-direction:column;min-width:0}
    .comm-post-card{background:#fff;border:1px solid #E4E6ED;border-radius:12px;overflow:hidden}
    .comm-post-head{padding:22px 24px;border-bottom:1px solid #E4E6ED}
    .comm-post-board{font-size:11px;font-weight:700;padding:3px 10px;border-radius:20px;background:#EEF2FF;color:#3B5BDB;display:inline-block;margin-bottom:10px}
    .comm-post-title{font-size:20px;font-weight:800;color:#1A1A2E;margin:0 0 12px;line-height:1.4}
    .comm-post-meta{display:flex;flex-wrap:wrap;gap:16px;font-size:13px;color:#999}
    .comm-post-meta strong{color:#555}
    .comm-post-body{padding:24px;font-size:15px;color:#444;line-height:1.85}
    .comm-post-img{width:100%;max-height:360px;object-fit:cover;border-radius:8px;margin-bottom:20px}
    .comm-side-card{background:#fff;border:1px solid #E4E6ED;border-radius:12px;padding:20px;margin-bottom:16px}
    .comm-side-title{font-size:14px;font-weight:800;color:#1A1A2E;margin:0 0 14px;padding-bottom:12px;border-bottom:1px solid #E4E6ED}
    .comm-report-item{display:flex;justify-content:space-between;align-items:center;padding:10px 0;border-bottom:1px solid #F5F5F5;font-size:13px}
    .comm-report-item:last-child{border-bottom:none}
    .comm-action-btns{display:flex;flex-direction:column;gap:8px}
    .comm-action-btns form{display:block;width:100%}
    .comm-action-btns .adm-btn,
    .comm-action-btns a.adm-btn{width:100%;box-sizing:border-box;text-align:center}
    .adm-page-actions{display:flex;gap:8px;align-items:center;flex-shrink:0}
    .adm-page-actions form{display:inline;margin:0}
    .adm-page-actions .adm-btn{min-width:80px;padding:9px 20px}
    .report-modal-bg{display:none;position:fixed;inset:0;background:rgba(0,0,0,.45);z-index:1000;align-items:center;justify-content:center;padding:20px}
    .report-modal-bg.open{display:flex}
    .report-modal{background:#fff;border-radius:14px;width:100%;max-width:560px;max-height:80vh;overflow:auto;box-shadow:0 12px 40px rgba(0,0,0,.15)}
    .report-modal-head{display:flex;justify-content:space-between;align-items:center;padding:16px 20px;border-bottom:1px solid #E4E6ED;position:sticky;top:0;background:#fff}
    .report-modal-head h3{margin:0;font-size:16px;font-weight:800}
    .report-modal-close{background:none;border:none;font-size:22px;cursor:pointer;color:#888}
    .report-modal-body{padding:8px 20px 20px}
    .report-modal-row{padding:14px 0;border-bottom:1px solid #F0F0F0}
    .report-modal-row:last-child{border-bottom:none}
    .report-modal-reason{font-weight:700;color:#1A1A2E;font-size:14px;margin-bottom:6px}
    .report-modal-meta{font-size:12px;color:#888;line-height:1.5}
    /* 2026/08/07 장우철 — 관리자 상세 댓글 영역 */
    .comm-comments-card{background:#fff;border:1px solid #E4E6ED;border-radius:12px;overflow:hidden;margin-top:16px}
    .comm-comments-head{padding:16px 20px;border-bottom:1px solid #E4E6ED;display:flex;align-items:center;justify-content:space-between}
    .comm-comments-head h3{margin:0;font-size:15px;font-weight:800;color:#1A1A2E}
    .comm-comments-head span{font-size:13px;color:#888}
    .comm-cmt-list{padding:8px 20px 16px}
    .comm-cmt-item{padding:14px 0;border-bottom:1px solid #F3F4F6}
    .comm-cmt-item:last-child{border-bottom:none}
    .comm-cmt-meta{display:flex;flex-wrap:wrap;gap:8px;align-items:center;font-size:12px;color:#888;margin-bottom:6px}
    .comm-cmt-meta strong{font-size:13px;color:#1A1A2E}
    .comm-cmt-body{font-size:14px;color:#444;line-height:1.65;white-space:pre-wrap;word-break:break-word}
    .comm-cmt-body.deleted{color:#999;font-style:italic}
    .comm-cmt-replies{margin:10px 0 0 18px;padding-left:14px;border-left:3px solid #EEF2FF}
    .comm-cmt-empty{padding:28px 20px;text-align:center;font-size:13px;color:#999}
    @media(max-width:900px){.comm-detail-grid{grid-template-columns:1fr}}
</style>

<main class="adm-main">
    <div class="comm-detail-breadcrumb">
        <a href="${contextPath}/admin/community/list">커뮤니티 관리</a>
        <span>›</span>
        <span style="color:#1A1A2E;font-weight:600">게시글 상세</span>
    </div>

    <div class="adm-page-head">
        <div class="adm-page-head-left">
            <h1 class="adm-page-title">게시글 상세</h1>
            <p class="adm-page-desc">게시글·신고 내역을 확인하고 처리할 수 있습니다.</p>
        </div>
        <%-- 2026-07-15 박유정 — 상단 처리 버튼 (상태별 분기) --%>
        <div class="adm-page-actions">
            <c:choose>
                <c:when test="${post.statusCd eq 'HIDDEN'}">
                    <form method="post" action="${contextPath}/admin/community/restore"
                          onsubmit="return confirm('다시 게시하시겠습니까?')">
                        <input type="hidden" name="_csrf" value="${_csrf}">
                        <input type="hidden" name="postId" value="${post.postId}">
                        <button type="submit" class="adm-btn green">복구</button>
                    </form>
                    <form method="post" action="${contextPath}/admin/community/delete"
                          onsubmit="return confirm('삭제하시겠습니까?')">
                        <input type="hidden" name="_csrf" value="${_csrf}">
                        <input type="hidden" name="postId" value="${post.postId}">
                        <input type="hidden" name="memberNo" value="${post.memberNo}">
                        <button type="submit" class="adm-btn red">삭제</button>
                    </form>
                </c:when>
                <c:when test="${post.statusCd eq 'DELETED'}">
                    <form method="post" action="${contextPath}/admin/community/restore"
                          onsubmit="return confirm('다시 게시하시겠습니까?')">
                        <input type="hidden" name="_csrf" value="${_csrf}">
                        <input type="hidden" name="postId" value="${post.postId}">
                        <button type="submit" class="adm-btn green">복구</button>
                    </form>
                </c:when>
                <c:otherwise>
                    <form method="post" action="${contextPath}/admin/community/hide"
                          onsubmit="return confirm('숨김 처리하시겠습니까?')">
                        <input type="hidden" name="_csrf" value="${_csrf}">
                        <input type="hidden" name="postId" value="${post.postId}">
                        <button type="submit" class="adm-btn gray">숨김</button>
                    </form>
                    <form method="post" action="${contextPath}/admin/community/delete"
                          onsubmit="return confirm('삭제하시겠습니까?')">
                        <input type="hidden" name="_csrf" value="${_csrf}">
                        <input type="hidden" name="postId" value="${post.postId}">
                        <input type="hidden" name="memberNo" value="${post.memberNo}">
                        <button type="submit" class="adm-btn red">삭제</button>
                    </form>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <c:if test="${not empty successMsg}">
        <div style="background:#ECFDF5;border:1px solid #BBF7D0;color:#166534;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:14px">${successMsg}</div>
    </c:if>
    <c:if test="${not empty errorMsg}">
        <div style="background:#FEF2F2;border:1px solid #FECACA;color:#B91C1C;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:14px">${errorMsg}</div>
    </c:if>

    <div class="comm-detail-grid">
        <div class="comm-detail-main">
        <div class="comm-post-card">
            <div class="comm-post-head">
                <span class="comm-post-board">
                    <c:choose>
                        <c:when test="${post.boardType eq 'TOWN'}">집사생활</c:when>
                        <c:when test="${post.boardType eq 'SHARE'}">무료나눔</c:when>
                        <c:when test="${post.boardType eq 'LIFE'}">수의사 상담</c:when>
                    </c:choose>
                </span>
                <%-- 2026/08/06 장우철 — 신고 대기 / 신고 기각 뱃지 --%>
                <c:choose>
                    <c:when test="${post.pendingReportCount != null && post.pendingReportCount > 0}">
                        <span class="adm-badge wait" style="margin-left:8px">신고 대기</span>
                    </c:when>
                    <c:when test="${post.dismissedReportCount != null && post.dismissedReportCount > 0}">
                        <span class="adm-badge" style="margin-left:8px;background:#F1F3F7;color:#666">신고 기각</span>
                    </c:when>
                </c:choose>
                <h2 class="comm-post-title"><c:out value="${post.title}"/></h2>
                <div class="comm-post-meta">
                    <span>작성자 <strong><c:out value="${post.authorName}"/></strong></span>
                    <span>작성일 ${post.regDate.year}.${post.regDate.monthValue}.${post.regDate.dayOfMonth}</span>
                    <span>조회 ${post.viewCount}</span>
                    <span>댓글 ${post.commentCount != null ? post.commentCount : 0}</span>
                    <span style="color:#DC2626;font-weight:700">신고 ${post.reportCount != null ? post.reportCount : 0}건</span>
                </div>
            </div>
            <div class="comm-post-body">
                <c:forEach var="url" items="${post.photoUrls}">
                    <img src="${url}" class="comm-post-img" alt=""
                         onerror="this.style.display='none'">
                </c:forEach>
                <p style="white-space:pre-wrap"><c:out value="${post.body}"/></p>
            </div>
        </div>

        <%-- 2026/08/07 장우철 — 게시글 아래 댓글·대댓글 (읽기 전용) --%>
        <div class="comm-comments-card">
            <div class="comm-comments-head">
                <h3>댓글</h3>
                <span>${post.commentCount != null ? post.commentCount : 0}개</span>
            </div>
            <c:choose>
                <c:when test="${empty comments}">
                    <div class="comm-cmt-empty">등록된 댓글이 없습니다.</div>
                </c:when>
                <c:otherwise>
                    <div class="comm-cmt-list">
                        <c:forEach var="cmt" items="${comments}">
                            <div class="comm-cmt-item">
                                <div class="comm-cmt-meta">
                                    <strong>
                                        <c:choose>
                                            <c:when test="${cmt.isDeleted eq 'Y'}">삭제된 댓글</c:when>
                                            <c:otherwise><c:out value="${not empty cmt.nickname ? cmt.nickname : '익명'}"/></c:otherwise>
                                        </c:choose>
                                    </strong>
                                    <span>
                                        <c:choose>
                                            <c:when test="${not empty cmt.regDate}">
                                                ${cmt.regDate.year}.${cmt.regDate.monthValue}.${cmt.regDate.dayOfMonth}
                                            </c:when>
                                            <c:otherwise>-</c:otherwise>
                                        </c:choose>
                                    </span>
                                    <c:if test="${not empty cmt.memberNo}">
                                        <span>회원#${cmt.memberNo}</span>
                                    </c:if>
                                </div>
                                <c:choose>
                                    <c:when test="${cmt.isDeleted eq 'Y'}">
                                        <div class="comm-cmt-body deleted">삭제된 댓글입니다.</div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="comm-cmt-body"><c:out value="${cmt.body}"/></div>
                                    </c:otherwise>
                                </c:choose>
                                <c:if test="${not empty cmt.replies}">
                                    <div class="comm-cmt-replies">
                                        <c:forEach var="reply" items="${cmt.replies}">
                                            <div class="comm-cmt-item">
                                                <div class="comm-cmt-meta">
                                                    <strong>
                                                        <c:choose>
                                                            <c:when test="${reply.isDeleted eq 'Y'}">삭제된 답글</c:when>
                                                            <c:otherwise><c:out value="${not empty reply.nickname ? reply.nickname : '익명'}"/></c:otherwise>
                                                        </c:choose>
                                                    </strong>
                                                    <span>답글</span>
                                                    <span>
                                                        <c:choose>
                                                            <c:when test="${not empty reply.regDate}">
                                                                ${reply.regDate.year}.${reply.regDate.monthValue}.${reply.regDate.dayOfMonth}
                                                            </c:when>
                                                            <c:otherwise>-</c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                    <c:if test="${not empty reply.memberNo}">
                                                        <span>회원#${reply.memberNo}</span>
                                                    </c:if>
                                                </div>
                                                <c:choose>
                                                    <c:when test="${reply.isDeleted eq 'Y'}">
                                                        <div class="comm-cmt-body deleted">삭제된 답글입니다.</div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div class="comm-cmt-body"><c:out value="${reply.body}"/></div>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </c:if>
                            </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
        </div>

        <div>
            <div class="comm-side-card">
                <h3 class="comm-side-title">작성자 정보</h3>
                <div class="comm-report-item"><span>이름</span><strong><c:out value="${post.authorMemberName}"/></strong></div>
                <div class="comm-report-item"><span>닉네임</span><strong><c:out value="${post.authorName}"/></strong></div>
                <div class="comm-report-item"><span>이메일</span><strong><c:out value="${post.authorEmail}"/></strong></div>
            </div>

            <%-- 2026/08/06 장우철 — 신고 내역 요약 + 내역확인 모달 --%>
            <div class="comm-side-card">
                <h3 class="comm-side-title">신고 내역</h3>
                <div class="comm-report-item">
                    <span>전체</span>
                    <strong style="color:#DC2626">${post.reportCount != null ? post.reportCount : 0}건</strong>
                </div>
                <div class="comm-report-item">
                    <span>대기</span>
                    <strong>${post.pendingReportCount != null ? post.pendingReportCount : 0}건</strong>
                </div>
                <div class="comm-report-item">
                    <span>기각</span>
                    <strong>${post.dismissedReportCount != null ? post.dismissedReportCount : 0}건</strong>
                </div>
                <button type="button" class="adm-btn blue" style="width:100%;margin-top:12px;box-sizing:border-box"
                        onclick="openReportModal()">내역확인</button>
            </div>

            <div class="comm-side-card">
                <h3 class="comm-side-title">처리</h3>
                <div class="comm-action-btns">
                    <c:if test="${post.pendingReportCount != null && post.pendingReportCount > 0}">
                        <form method="post" action="${contextPath}/admin/community/dismiss-reports"
                              onsubmit="return confirm('대기 중인 신고를 모두 기각할까요? (게시글은 유지됩니다)')">
                            <input type="hidden" name="_csrf" value="${_csrf}">
                            <input type="hidden" name="postId" value="${post.postId}">
                            <button type="submit" class="adm-btn green">신고 기각</button>
                        </form>
                    </c:if>
                    <c:choose>
                        <c:when test="${post.statusCd eq 'HIDDEN'}">
                            <form method="post" action="${contextPath}/admin/community/restore"
                                  onsubmit="return confirm('다시 게시하시겠습니까?')">
                                <input type="hidden" name="_csrf" value="${_csrf}">
                                <input type="hidden" name="postId" value="${post.postId}">
                                <button type="submit" class="adm-btn green">복구</button>
                            </form>
                            <form method="post" action="${contextPath}/admin/community/delete"
                                  onsubmit="return confirm('삭제하시겠습니까?')">
                                <input type="hidden" name="_csrf" value="${_csrf}">
                                <input type="hidden" name="postId" value="${post.postId}">
                                <input type="hidden" name="memberNo" value="${post.memberNo}">
                                <button type="submit" class="adm-btn red">삭제</button>
                            </form>
                        </c:when>
                        <c:when test="${post.statusCd eq 'DELETED'}">
                            <form method="post" action="${contextPath}/admin/community/restore"
                                  onsubmit="return confirm('다시 게시하시겠습니까?')">
                                <input type="hidden" name="_csrf" value="${_csrf}">
                                <input type="hidden" name="postId" value="${post.postId}">
                                <button type="submit" class="adm-btn green">복구</button>
                            </form>
                        </c:when>
                        <c:otherwise>
                            <form method="post" action="${contextPath}/admin/community/hide"
                                  onsubmit="return confirm('숨김 처리하시겠습니까?')">
                                <input type="hidden" name="_csrf" value="${_csrf}">
                                <input type="hidden" name="postId" value="${post.postId}">
                                <button type="submit" class="adm-btn gray">숨김 처리</button>
                            </form>
                            <form method="post" action="${contextPath}/admin/community/delete"
                                  onsubmit="return confirm('삭제하시겠습니까?')">
                                <input type="hidden" name="_csrf" value="${_csrf}">
                                <input type="hidden" name="postId" value="${post.postId}">
                                <input type="hidden" name="memberNo" value="${post.memberNo}">
                                <button type="submit" class="adm-btn red">삭제</button>
                            </form>
                        </c:otherwise>
                    </c:choose>
                    <a href="${contextPath}/admin/community/list" class="adm-btn gray"
                       style="text-align:center;padding:9px;text-decoration:none">목록으로</a>
                </div>
            </div>
        </div>
    </div>
</main>

<%-- 2026/08/06 장우철 — 신고 내역 모달 --%>
<div class="report-modal-bg" id="reportModalBg" onclick="if(event.target===this) closeReportModal()">
  <div class="report-modal" role="dialog" aria-labelledby="reportModalTitle">
    <div class="report-modal-head">
      <h3 id="reportModalTitle">신고 내역</h3>
      <button type="button" class="report-modal-close" onclick="closeReportModal()" aria-label="닫기">×</button>
    </div>
    <div class="report-modal-body">
      <c:choose>
        <c:when test="${empty reportList}">
          <p style="font-size:13px;color:#999;padding:20px 0;text-align:center">신고 내역이 없습니다.</p>
        </c:when>
        <c:otherwise>
          <c:forEach var="r" items="${reportList}">
            <div class="report-modal-row">
              <div class="report-modal-reason">
                <c:set var="reasonRaw" value="${r.reasonCd}" />
                <c:set var="reasonCode" value="${fn:contains(reasonRaw, ':') ? fn:substringBefore(reasonRaw, ':') : reasonRaw}" />
                <c:set var="reasonDetail" value="${fn:contains(reasonRaw, ':') ? fn:substringAfter(reasonRaw, ':') : ''}" />
                <c:choose>
                  <c:when test="${fn:startsWith(reasonCode, 'SPAM')}">스팸/광고</c:when>
                  <c:when test="${fn:startsWith(reasonCode, 'ABUSE')}">욕설/비방</c:when>
                  <c:when test="${fn:startsWith(reasonCode, 'ETC')}">기타</c:when>
                  <c:otherwise><c:out value="${reasonCode}"/></c:otherwise>
                </c:choose>
                <c:if test="${not empty reasonDetail}">
                  <span style="font-weight:500;color:#666"> — <c:out value="${fn:trim(reasonDetail)}"/></span>
                </c:if>
              </div>
              <div class="report-modal-meta">
                신고자: <c:out value="${not empty r.reporterNickname ? r.reporterNickname : '알 수 없음'}"/>
                ·
                <c:choose>
                  <c:when test="${r.statusCd eq 'PENDING'}">대기</c:when>
                  <c:when test="${r.statusCd eq 'DISMISSED'}">기각</c:when>
                  <c:otherwise><c:out value="${r.statusCd}"/></c:otherwise>
                </c:choose>
                <c:if test="${not empty r.regDate}">
                  · ${r.regDate.year}.${r.regDate.monthValue}.${r.regDate.dayOfMonth}
                </c:if>
              </div>
            </div>
          </c:forEach>
        </c:otherwise>
      </c:choose>
    </div>
  </div>
</div>

<script>
  function openReportModal() {
    document.getElementById('reportModalBg').classList.add('open');
  }
  function closeReportModal() {
    document.getElementById('reportModalBg').classList.remove('open');
  }
</script>

<%@ include file="/WEB-INF/views/admin/common/footer.jsp" %>
