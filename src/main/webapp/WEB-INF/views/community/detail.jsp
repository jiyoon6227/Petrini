<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
  - 박유정 / 2026-07-09~10
  - 커뮤니티 게시글 상세

  [상세 화면 흐름]
  1. GET /community/detail?id=번호 → CommunityPostController.detail()
  2. ${post} 표시 + 조회수 진입 시 +1
  3. 좋아요 Ajax → POST /community/like/toggle
  4. 댓글 목록 ${comments} + POST /community/comment (parentId → 대댓글)
  5. POST /community/comment/delete — 본인 댓글 삭제
  6. POST /community/comment/update — 본인 댓글 수정
  7. POST /community/report — 게시글 신고
  8. LIFE + ANSWERED → vet-answer 답변 박스 표시 (2026-07-10 STEP 4)

  [model]
  - post, comments, commentCount, liked, isLoggedIn, successMessage(flash)
--%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="community" />
<%@ include file="/WEB-INF/views/common/header.jsp" %>
<style>
  .cdetail-wrap{max-width:780px;margin:32px auto 80px;padding:0 20px}
  .cdetail-success{background:#DCFCE7;border:1px solid #86EFAC;border-radius:var(--radius-sm);padding:14px 16px;margin-bottom:20px;font-size:14px;color:#166534}
  .cdetail-category{font-size:12px;font-weight:700;background:var(--primary-light);color:var(--primary-dark);padding:3px 10px;border-radius:20px;display:inline-block;margin-bottom:10px}
  .cdetail-title{font-size:24px;font-weight:800;color:var(--text-main);margin-bottom:14px;line-height:1.3}
  .cdetail-meta{display:flex;align-items:center;gap:14px;font-size:13px;color:var(--text-muted);margin-bottom:20px;padding-bottom:20px;border-bottom:1px solid var(--border)}
  .cdetail-meta svg{width:14px;height:14px;stroke:currentColor;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round}
  .cdetail-img{width:100%;border-radius:var(--radius-md);margin-bottom:20px;max-height:500px;object-fit:cover}
  .cdetail-content{font-size:15px;color:var(--text-sub);line-height:1.8;margin-bottom:28px;white-space:pre-line}
  .cdetail-actions{display:flex;align-items:center;gap:12px;padding:16px 0;border-top:1px solid var(--border);border-bottom:1px solid var(--border);margin-bottom:28px}
  .action-btn{display:flex;align-items:center;gap:6px;padding:8px 18px;border:1px solid var(--border);border-radius:50px;background:#fff;font-size:14px;font-weight:600;color:var(--text-sub);cursor:pointer;transition:var(--transition)}
  .action-btn:hover{border-color:var(--primary);color:var(--primary)}
  .action-btn.liked{border-color:var(--accent);color:var(--accent);background:#FFF5F5}
  .action-btn svg{width:15px;height:15px;stroke:currentColor;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round}
  .action-btn.liked svg{fill:var(--accent);stroke:none}
  .cdetail-back{display:inline-flex;align-items:center;gap:6px;font-size:13px;color:var(--text-muted);text-decoration:none;margin-bottom:18px}
  .cdetail-back:hover{color:var(--primary)}
  .comment-title{font-size:16px;font-weight:800;color:var(--text-main);margin-bottom:16px}
  .comment-write{display:flex;gap:10px;margin-bottom:24px}
  .comment-avatar{width:36px;height:36px;border-radius:50%;object-fit:cover;flex-shrink:0;background:var(--primary-light)}
  .comment-input-wrap{flex:1}
  .comment-input{width:100%;border:1px solid var(--border);border-radius:var(--radius-sm);padding:10px 14px;font-size:14px;outline:none;font-family:inherit;box-sizing:border-box;resize:none;min-height:80px;line-height:1.6}
  .comment-input:focus{border-color:var(--primary)}
  .comment-submit{margin-top:8px;display:flex;justify-content:flex-end}
  .comment-submit button{padding:8px 20px;border:none;border-radius:var(--radius-sm);background:var(--primary);color:#fff;font-size:13px;font-weight:700;cursor:pointer}
  .comment-item{display:flex;gap:12px;margin-bottom:18px}
  .comment-body{flex:1}
  .comment-head{display:flex;align-items:center;justify-content:space-between;margin-bottom:6px;gap:12px}
  .comment-head-meta{display:flex;align-items:center;gap:8px;flex-shrink:0;margin-left:auto}
  .comment-meta-sep{color:var(--text-muted);font-size:12px;line-height:1}
  .comment-name{font-size:14px;font-weight:700;color:var(--text-main);min-width:0}
  .comment-date{font-size:12px;color:var(--text-muted);white-space:nowrap}
  .comment-delete-btn{font-size:12px;font-weight:700;color:#DC2626;background:none;border:none;cursor:pointer;padding:0;line-height:1;white-space:nowrap}
  .comment-delete-btn:hover{text-decoration:underline}
  .comment-edit-btn{font-size:12px;font-weight:700;color:var(--primary-dark);background:none;border:none;cursor:pointer;padding:0;line-height:1;white-space:nowrap}
  .comment-edit-btn:hover{text-decoration:underline}
  .comment-text{font-size:14px;color:var(--text-sub);line-height:1.6;white-space:pre-line}
  .comment-actions{display:flex;align-items:center;gap:10px;margin-top:10px;flex-wrap:wrap}
  .reply-btn{font-size:13px;font-weight:600;color:var(--primary-dark);background:var(--primary-light);border:none;border-radius:4px;cursor:pointer;padding:5px 12px;line-height:1.4}
  .reply-btn:hover{background:var(--primary);color:#fff}
  .reply-form{display:none;margin-top:10px}
  .reply-form.open{display:block}
  .reply-item{margin-left:48px;padding-left:12px;border-left:2px solid var(--border)}
  .reply-input{min-height:60px}
  .edit-form{display:none;margin-top:10px}
  .edit-form.open{display:block}
  .comment-error{font-size:13px;color:#B91C1C;margin-bottom:12px}
  .cdetail-success-msg{font-size:13px;color:#166534;background:#DCFCE7;border:1px solid #86EFAC;border-radius:var(--radius-sm);padding:10px 14px;margin-bottom:12px}
  .report-modal-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,.45);z-index:1000;align-items:center;justify-content:center;padding:20px}
  .report-modal-overlay.open{display:flex}
  .report-modal{background:#fff;border-radius:var(--radius-md);width:100%;max-width:420px;padding:22px;box-shadow:var(--shadow-md)}
  .report-modal h3{margin:0 0 14px;font-size:17px;font-weight:800;color:var(--text-main)}
  .report-modal label{display:block;font-size:13px;font-weight:600;color:var(--text-main);margin-bottom:6px}
  .report-modal select,.report-modal textarea{width:100%;border:1px solid var(--border);border-radius:var(--radius-sm);padding:10px 12px;font-size:14px;font-family:inherit;box-sizing:border-box}
  .report-modal textarea{min-height:80px;resize:vertical;margin-top:10px}
  .report-modal-actions{display:flex;justify-content:flex-end;gap:8px;margin-top:16px}
  .report-modal-actions button{padding:8px 16px;border-radius:var(--radius-sm);font-size:13px;font-weight:700;cursor:pointer;border:none}
  .report-btn-cancel{background:var(--bg-page);color:var(--text-sub)}
  .report-btn-submit{background:#DC2626;color:#fff}
  .action-btn.report-action{border-color:#FECACA;color:#DC2626}
  .action-btn.report-action:hover{background:#FEF2F2;border-color:#DC2626}
  .vet-answer{background:#EFF6FF;border:1px solid #BFDBFE;border-radius:var(--radius-sm);padding:14px 16px;margin-bottom:20px}
  .vet-answer-head{display:flex;align-items:center;gap:6px;font-size:12px;font-weight:700;color:#1D4ED8;margin-bottom:6px}
  .vet-answer-head svg{width:14px;height:14px;stroke:#1D4ED8;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}
  .vet-answer-date{color:#93C5FD;font-weight:400;margin-left:auto}
  .vet-answer-text{font-size:13px;color:#1E40AF;line-height:1.7;white-space:pre-line}
  .cdetail-life-badge{font-size:11px;font-weight:700;padding:2px 8px;border-radius:20px;margin-left:8px}
  .cdetail-life-badge.waiting{background:#FEE2E2;color:#DC2626}
  .cdetail-life-badge.answered{background:#DCFCE7;color:#16A34A}
  .cdetail-author-actions{display:flex;gap:8px;margin-bottom:20px}
  .cdetail-edit-btn,.cdetail-delete-btn{padding:7px 18px;border-radius:var(--radius-sm);font-size:13px;font-weight:700;cursor:pointer;border:1px solid var(--border);transition:var(--transition)}
  .cdetail-edit-btn{background:#fff;color:var(--primary-dark)}
  .cdetail-edit-btn:hover{border-color:var(--primary);background:var(--primary-light)}
  .cdetail-delete-btn{background:#fff;color:#DC2626;border-color:#FECACA}
  .cdetail-delete-btn:hover{background:#FEF2F2;border-color:#DC2626}
</style>
<div class="cdetail-wrap">
  <a href="${contextPath}/community?boardType=${post.boardType}" class="cdetail-back">← 목록으로</a>

  <c:if test="${not empty successMessage}">
    <div class="cdetail-success">${successMessage}</div>
  </c:if>

  <c:choose>
    <c:when test="${post.boardType eq 'TOWN'}">
      <span class="cdetail-category">집사생활</span>
    </c:when>
    <c:when test="${post.boardType eq 'SHARE'}">
      <span class="cdetail-category">무료나눔</span>
    </c:when>
    <c:when test="${post.boardType eq 'LIFE'}">
      <span class="cdetail-category">수의사 상담</span>
      <c:choose>
        <c:when test="${fn:contains(post.tags, 'ANSWERED')}">
          <span class="cdetail-life-badge answered">답변완료</span>
        </c:when>
        <c:otherwise>
          <span class="cdetail-life-badge waiting">답변대기</span>
        </c:otherwise>
      </c:choose>
    </c:when>
  </c:choose>

  <h1 class="cdetail-title"><c:out value="${post.title}"/></h1>
  <div class="cdetail-meta">
    <span>${post.regDate}</span>
    <span style="display:flex;align-items:center;gap:4px">
      <svg viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
      <span id="viewCountText">${post.viewCount}</span>
    </span>
    <span style="display:flex;align-items:center;gap:4px">
      <svg viewBox="0 0 24 24"><path d="M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78L12 21.23l8.84-8.84a5.5 5.5 0 000-7.78z"/></svg>
      <span id="likeCountMeta">${post.likeCnt}</span>
    </span>
  </div>

  <%-- 2026-07-23 HYJ — 본인 글일 때 수정/삭제 버튼 --%>
  <%-- <c:if test="${loginMemberNo != null && loginMemberNo == post.memberNo}"> --%>
  <%-- 2026-07-28 HYJ — 관리자 권한 수정/삭제 버튼 --%>
  <c:if test="${(loginMemberNo != null && loginMemberNo == post.memberNo) || loginMemberRole eq 'ADMIN'}">
    <div class="cdetail-author-actions">
      <a href="${contextPath}/community/edit?id=${post.postId}" class="cdetail-edit-btn">수정</a>
      <form method="post" action="${contextPath}/community/delete" style="display:inline;margin:0;padding:0">
        <!--HYJ 26.08.05-->
        <input type="hidden" name="_csrf" value="${_csrf}">
        
        <input type="hidden" name="postId" value="${post.postId}">
        <button type="submit" class="cdetail-delete-btn"
                onclick="return confirm('게시글을 삭제하시겠습니까?\n삭제하면 복구할 수 없습니다.')">삭제</button>
      </form>
    </div>
  </c:if>

  <c:if test="${param.error eq 'forbidden'}">
    <div class="cdetail-success" style="background:#FEE2E2;border-color:#FCA5A5;color:#B91C1C">본인이 작성한 글만 수정·삭제할 수 있습니다.</div>
  </c:if>
  <c:if test="${param.error eq 'delete'}">
    <div class="cdetail-success" style="background:#FEE2E2;border-color:#FCA5A5;color:#B91C1C">삭제에 실패했습니다. 잠시 후 다시 시도해 주세요.</div>
  </c:if>

  <c:forEach var="url" items="${post.photoUrls}">
    <img class="cdetail-img" src="${contextPath}${url}" alt="게시글 이미지"
         onerror="this.src='https://placehold.co/780x400/EAF7F2/2BAB82?text=게시글이미지'">
  </c:forEach>

  <div class="cdetail-content"><c:out value="${post.body}"/></div>

  <%-- 2026-07-10 박유정 STEP 4 — LIFE 답변완료 시 수의사 답변 박스 --%>
  <c:if test="${post.boardType eq 'LIFE' && fn:contains(post.tags, 'ANSWERED') && not empty comments}">
    <div class="vet-answer">
      <div class="vet-answer-head">
        <svg viewBox="0 0 24 24"><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></svg>
        수의사 답변 · <c:out value="${not empty comments[0].nickname ? comments[0].nickname : '익명'}"/>
        <span class="vet-answer-date">
          <c:if test="${not empty comments[0].regDate}">
            ${comments[0].regDate.year}.${comments[0].regDate.monthValue}.${comments[0].regDate.dayOfMonth}
          </c:if>
        </span>
      </div>
      <div class="vet-answer-text"><c:out value="${comments[0].body}"/></div>
    </div>
  </c:if>

  <div class="cdetail-actions">
    <button type="button"
            id="likeBtn"
            class="action-btn ${liked ? 'liked' : ''}"
            onclick="toggleCommunityLike(${post.postId})">
      <svg viewBox="0 0 24 24"><path d="M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78L12 21.23l8.84-8.84a5.5 5.5 0 000-7.78z"/></svg>
      좋아요 <span id="likeCountBtn">${post.likeCnt}</span>
    </button>
    <button type="button" class="action-btn report-action" onclick="openReportModal()">신고</button>
  </div>

  <c:if test="${param.reported eq '1'}">
    <p class="cdetail-success-msg">신고가 접수되었습니다. 관리자 검토 후 처리됩니다.</p>
  </c:if>

  <div class="comment-title">댓글 ${empty commentCount ? 0 : commentCount}개</div>

  <c:if test="${param.error eq 'empty'}">
    <p class="comment-error">댓글 내용을 입력해 주세요.</p>
  </c:if>
  <c:if test="${param.error eq 'comment'}">
    <p class="comment-error">댓글 처리에 실패했습니다.</p>
  </c:if>
  <c:if test="${param.error eq 'forbidden'}">
    <p class="comment-error">본인 댓글만 수정·삭제할 수 있습니다.</p>
  </c:if>
  <c:if test="${param.error eq 'report'}">
    <p class="comment-error">신고 처리에 실패했습니다.</p>
  </c:if>
  <c:if test="${param.error eq 'reportReason'}">
    <p class="comment-error">신고 사유를 선택해 주세요.</p>
  </c:if>
  <c:if test="${param.error eq 'selfReport'}">
    <p class="comment-error">본인 게시글은 신고할 수 없습니다.</p>
  </c:if>
  <c:if test="${param.error eq 'duplicateReport'}">
    <p class="comment-error">이미 신고 접수된 게시글입니다.</p>
  </c:if>
  <c:if test="${param.error eq 'reportSeq'}">
    <p class="comment-error">신고 시퀀스(SEQ_TB_POST_REPORT)가 DB에 없습니다.</p>
  </c:if>
  <c:if test="${param.error eq 'member'}">
    <p class="comment-error">회원 정보를 확인할 수 없습니다. <strong>회원가입 계정으로 로그인</strong>했는지 확인해 주세요.</p>
  </c:if>
  <c:if test="${param.error eq 'seq'}">
    <p class="comment-error">댓글 시퀀스(SEQ_TB_POST_COMMENT)가 DB에 없습니다. DBA 또는 팀원에게 시퀀스 생성을 요청해 주세요.</p>
  </c:if>
  <%-- 2026/07/11 장우철 — LIFE 댓글 권한 거부 안내 --%>
  <c:if test="${param.error eq 'lifeComment'}">
    <p class="comment-error">수의사 상담 글에는 병원 사업자만 답변할 수 있고, 질문자는 답글(추가 질문)만 작성할 수 있습니다.</p>
  </c:if>

  <%-- 2026/07/11 장우철 — LIFE: 최상위 댓글은 병원 사업자만 (canWriteTopComment) --%>
  <c:choose>
    <c:when test="${canWriteTopComment}">
      <form method="post" action="${contextPath}/community/comment">
        <!--HYJ 26.08.05-->
        <input type="hidden" name="_csrf" value="${_csrf}">
        
        <input type="hidden" name="postId" value="${post.postId}">
        <div class="comment-write">
          <%-- 2026/08/06 장우철 — 로그인 회원 프로필 아바타 --%>
          <img class="comment-avatar"
               src="${not empty memberInfo.profileImgUrl ? contextPath.concat(memberInfo.profileImgUrl) : 'https://placehold.co/36x36/EAF7F2/2BAB82?text=ME'}"
               alt="내 아바타"
               onerror="this.src='https://placehold.co/36x36/EAF7F2/2BAB82?text=ME'">
          <div class="comment-input-wrap">
            <textarea class="comment-input" name="body"
              placeholder="${post.boardType eq 'LIFE' ? '수의사 답변을 입력하세요...' : '댓글을 입력하세요...'}"
              required></textarea>
            <div class="comment-submit"><button type="submit">등록</button></div>
          </div>
        </div>
      </form>
    </c:when>
    <c:when test="${post.boardType eq 'LIFE' && isLoggedIn && !canWriteTopComment}">
      <p style="font-size:13px;color:var(--text-muted);margin-bottom:16px">
        수의사 상담 답변은 병원 사업자만 작성할 수 있습니다.
        <c:if test="${canWriteReply}"> 추가 질문은 아래 답글로 남겨 주세요.</c:if>
      </p>
    </c:when>
  </c:choose>

  <c:forEach var="cmt" items="${comments}">
    <div class="comment-item">
      <%-- 2026/08/06 장우철 — 댓글 작성자 프로필 아바타 --%>
      <img class="comment-avatar"
           src="${not empty cmt.profileImgUrl ? contextPath.concat(cmt.profileImgUrl) : 'https://placehold.co/36x36/EAF7F2/2BAB82?text=U'}"
           alt="댓글러"
           onerror="this.src='https://placehold.co/36x36/EAF7F2/2BAB82?text=U'">
      <div class="comment-body">
        <div class="comment-head" style="display:flex;align-items:center;justify-content:space-between;gap:12px">
          <span class="comment-name">
            <c:choose>
              <c:when test="${cmt.isDeleted eq 'Y'}">삭제된 댓글</c:when>
              <c:otherwise>${cmt.nickname}</c:otherwise>
            </c:choose>
          </span>
          <div class="comment-head-meta" style="display:flex;align-items:center;gap:8px;margin-left:auto">
            <span class="comment-date">
              <c:choose>
                <c:when test="${not empty cmt.regDate}">
                  ${cmt.regDate.year}.${cmt.regDate.monthValue}.${cmt.regDate.dayOfMonth}
                </c:when>
                <c:otherwise>-</c:otherwise>
              </c:choose>
            </span>
            <%-- 2026/08/03 장우철 — 삭제된 댓글은 수정/삭제 숨김 --%>
            <c:if test="${cmt.isDeleted ne 'Y' && ((loginMemberNo != null && loginMemberNo == cmt.memberNo) || loginMemberRole eq 'ADMIN')}">
              <span class="comment-meta-sep" style="color:#999">·</span>
              <button type="button" class="comment-edit-btn"
                      onclick="toggleEditForm(${cmt.commentId})">수정</button>
              <span class="comment-meta-sep" style="color:#999">·</span>
              <form method="post" action="${contextPath}/community/comment/delete" style="display:inline;margin:0;padding:0">
                <!--HYJ 26.08.05-->
                <input type="hidden" name="_csrf" value="${_csrf}">
                
                <input type="hidden" name="commentId" value="${cmt.commentId}">
                <input type="hidden" name="postId" value="${post.postId}">
                <button type="submit" class="comment-delete-btn"
                        style="font-size:12px;font-weight:700;color:#DC2626;background:none;border:none;cursor:pointer;padding:0"
                        onclick="return confirm('댓글을 삭제할까요?')">삭제</button>
              </form>
            </c:if>
          </div>
        </div>
        <c:choose>
          <c:when test="${cmt.isDeleted eq 'Y'}">
            <div class="comment-text" style="color:var(--text-muted)">삭제된 댓글입니다.</div>
          </c:when>
          <c:otherwise>
            <div class="comment-text" id="commentText-${cmt.commentId}"><c:out value="${cmt.body}"/></div>
            <div id="editForm-${cmt.commentId}" class="edit-form">
              <form method="post" action="${contextPath}/community/comment/update">
              <!--HYJ 26.08.05-->
            <input type="hidden" name="_csrf" value="${_csrf}">
                <input type="hidden" name="commentId" value="${cmt.commentId}">
                <input type="hidden" name="postId" value="${post.postId}">
                <textarea class="comment-input reply-input" name="body" required><c:out value="${cmt.body}"/></textarea>
                <div class="comment-submit">
                  <button type="button" class="reply-btn" onclick="toggleEditForm(${cmt.commentId})">취소</button>
                  <button type="submit">저장</button>
                </div>
              </form>
            </div>
          </c:otherwise>
        </c:choose>
        <div class="comment-actions">
          <%-- 2026/07/11 장우철 — LIFE: 답글은 병원 사업자 또는 질문자만 (canWriteReply) --%>
          <c:if test="${canWriteReply}">
            <button type="button" class="reply-btn" onclick="toggleReplyForm(${cmt.commentId})">↳ 답글</button>
          </c:if>
        </div>
        <c:if test="${canWriteReply}">
        <div id="replyForm-${cmt.commentId}" class="reply-form">
          <form method="post" action="${contextPath}/community/comment">
            <!--HYJ 26.08.05-->
            <input type="hidden" name="_csrf" value="${_csrf}">
            
            <input type="hidden" name="postId" value="${post.postId}">
            <input type="hidden" name="parentId" value="${cmt.commentId}">
            <textarea class="comment-input reply-input" name="body"
              placeholder="${post.boardType eq 'LIFE' ? '추가 질문을 입력하세요...' : '답글을 입력하세요...'}"
              required></textarea>
            <div class="comment-submit"><button type="submit">등록</button></div>
          </form>
        </div>
        </c:if>
      </div>
    </div>

    <c:forEach var="reply" items="${cmt.replies}">
      <div class="comment-item reply-item">
        <%-- 2026/08/06 장우철 — 답글 작성자 프로필 아바타 --%>
        <img class="comment-avatar"
             src="${not empty reply.profileImgUrl ? contextPath.concat(reply.profileImgUrl) : 'https://placehold.co/36x36/EAF7F2/2BAB82?text=R'}"
             alt="답글러"
             onerror="this.src='https://placehold.co/36x36/EAF7F2/2BAB82?text=R'">
        <div class="comment-body">
          <div class="comment-head" style="display:flex;align-items:center;justify-content:space-between;gap:12px">
            <span class="comment-name">
              <c:choose>
                <c:when test="${reply.isDeleted eq 'Y'}">삭제된 댓글</c:when>
                <c:otherwise>${reply.nickname}</c:otherwise>
              </c:choose>
            </span>
            <div class="comment-head-meta" style="display:flex;align-items:center;gap:8px;margin-left:auto">
              <span class="comment-date">
                <c:choose>
                  <c:when test="${not empty reply.regDate}">
                    ${reply.regDate.year}.${reply.regDate.monthValue}.${reply.regDate.dayOfMonth}
                  </c:when>
                  <c:otherwise>-</c:otherwise>
                </c:choose>
              </span>
              <c:if test="${reply.isDeleted ne 'Y' && ((loginMemberNo != null && loginMemberNo == reply.memberNo) || loginMemberRole eq 'ADMIN')}">
                <span class="comment-meta-sep" style="color:#999">·</span>
                <button type="button" class="comment-edit-btn"
                        onclick="toggleEditForm(${reply.commentId})">수정</button>
                <span class="comment-meta-sep" style="color:#999">·</span>
                <form method="post" action="${contextPath}/community/comment/delete" style="display:inline;margin:0;padding:0">
                  <!--HYJ 26.08.05-->
                  <input type="hidden" name="_csrf" value="${_csrf}">
                  
                  <input type="hidden" name="commentId" value="${reply.commentId}">
                  <input type="hidden" name="postId" value="${post.postId}">
                  <button type="submit" class="comment-delete-btn"
                          style="font-size:12px;font-weight:700;color:#DC2626;background:none;border:none;cursor:pointer;padding:0"
                          onclick="return confirm('댓글을 삭제할까요?')">삭제</button>
                </form>
              </c:if>
            </div>
          </div>
          <c:choose>
            <c:when test="${reply.isDeleted eq 'Y'}">
              <div class="comment-text" style="color:var(--text-muted)">삭제된 댓글입니다.</div>
            </c:when>
            <c:otherwise>
              <div class="comment-text" id="commentText-${reply.commentId}"><c:out value="${reply.body}"/></div>
              <div id="editForm-${reply.commentId}" class="edit-form">
                <form method="post" action="${contextPath}/community/comment/update">
                <!--HYJ 26.08.05-->
            <input type="hidden" name="_csrf" value="${_csrf}">
                  <input type="hidden" name="commentId" value="${reply.commentId}">
                  <input type="hidden" name="postId" value="${post.postId}">
                  <textarea class="comment-input reply-input" name="body" required><c:out value="${reply.body}"/></textarea>
                  <div class="comment-submit">
                    <button type="button" class="reply-btn" onclick="toggleEditForm(${reply.commentId})">취소</button>
                    <button type="submit">저장</button>
                  </div>
                </form>
              </div>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </c:forEach>
  </c:forEach>

  <c:if test="${empty comments}">
    <p style="text-align:center;color:var(--text-muted);padding:20px 0;font-size:14px">아직 댓글이 없습니다.</p>
  </c:if>
</div>

<div id="reportModal" class="report-modal-overlay" onclick="if(event.target===this) closeReportModal()">
  <div class="report-modal" role="dialog" aria-labelledby="reportModalTitle">
    <h3 id="reportModalTitle">게시글 신고</h3>
    <form method="post" action="${contextPath}/community/report">
      <!--HYJ 26.08.05-->
      <input type="hidden" name="_csrf" value="${_csrf}">

      <input type="hidden" name="postId" value="${post.postId}">
      <label for="reasonCd">신고 사유</label>
      <select id="reasonCd" name="reasonCd" required>
        <option value="">사유를 선택하세요</option>
        <option value="SPAM">스팸/광고</option>
        <option value="ABUSE">욕설/비방</option>
        <option value="ETC">기타</option>
      </select>
      <textarea name="reasonDetail" placeholder="상세 사유를 입력하세요 (선택)"></textarea>
      <div class="report-modal-actions">
        <button type="button" class="report-btn-cancel" onclick="closeReportModal()">취소</button>
        <button type="submit" class="report-btn-submit" onclick="return confirm('이 게시글을 신고하시겠습니까?')">신고하기</button>
      </div>
    </form>
  </div>
</div>

<script>
  const isLoggedIn = ${isLoggedIn == true};
  // 2026/07/11 장우철 — LIFE 답글 권한 (서버 canWriteReply 와 동일)
  const canWriteReply = ${canWriteReply == true};

  function toggleReplyForm(commentId) {
    if (!isLoggedIn) {
      alert('로그인 후 답글을 작성할 수 있습니다.');
      location.href = '${contextPath}/login?redirect=/community/detail?id=${post.postId}';
      return;
    }
    if (!canWriteReply) {
      alert('수의사 상담 글에는 병원 사업자 또는 질문자만 답글을 작성할 수 있습니다.');
      return;
    }
    var form = document.getElementById('replyForm-' + commentId);
    if (!form) {
      return;
    }
    document.querySelectorAll('.reply-form.open').forEach(function(el) {
      if (el !== form) {
        el.classList.remove('open');
      }
    });
    form.classList.toggle('open');
  }

  function toggleEditForm(commentId) {
    var form = document.getElementById('editForm-' + commentId);
    var text = document.getElementById('commentText-' + commentId);
    if (!form) {
      return;
    }
    document.querySelectorAll('.edit-form.open').forEach(function(el) {
      if (el !== form) {
        el.classList.remove('open');
      }
    });
    var willOpen = !form.classList.contains('open');
    form.classList.toggle('open');
    if (text) {
      text.style.display = willOpen ? 'none' : '';
    }
  }

  function openReportModal() {
    if (!isLoggedIn) {
      alert('로그인 후 신고할 수 있습니다.');
      location.href = '${contextPath}/login?redirect=/community/detail?id=${post.postId}';
      return;
    }
    document.getElementById('reportModal').classList.add('open');
  }

  function closeReportModal() {
    document.getElementById('reportModal').classList.remove('open');
  }

  function toggleCommunityLike(postId) {
    if (!isLoggedIn) {
      alert('로그인 후 좋아요를 누를 수 있습니다.');
      location.href = '${contextPath}/login?redirect=/community/detail?id=' + postId;
      return;
    }
    
    //HYJ 26.08.05
    csrfFetch('${contextPath}/community/like/toggle', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: 'postId=' + postId
    })
    .then(function(res) {
      if (res.status === 401) {
        alert('로그인이 필요합니다.');
        return null;
      }
      if (!res.ok) {
        return res.text().then(function(body) {
          throw new Error(body || 'like toggle failed');
        });
      }
      return res.json();
    })
    .then(function(data) {
      if (!data) {
        return;
      }
      var btn = document.getElementById('likeBtn');
      var likeCountBtn = document.getElementById('likeCountBtn');
      var likeCountMeta = document.getElementById('likeCountMeta');
      var liked = data.liked === true || data.isLiked === true;
      if (liked) {
        btn.classList.add('liked');
      } else {
        btn.classList.remove('liked');
      }
      var count = data.likeCnt != null ? data.likeCnt : data.like_cnt;
      likeCountBtn.textContent = count;
      likeCountMeta.textContent = count;
    })
    .catch(function(err) {
      var msg = '좋아요 처리에 실패했습니다.';
      if (err && err.message === 'MEMBER_NOT_FOUND') {
        msg = 'DB에 회원 정보가 없습니다. 회원가입 계정으로 로그인해 주세요.';
      } else if (err && err.message === 'LOGIN_REQUIRED') {
        msg = '로그인이 필요합니다.';
      }
      alert(msg);
    });
  }
</script>
<%@ include file="/WEB-INF/views/common/footer.jsp" %>
