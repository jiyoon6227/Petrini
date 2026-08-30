<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
  역할: 분실/보호 신고 상세 (give/report/detail)

  - 박유정 / 2026-07-06~07

  [상세 화면 흐름]
  1. GET /give/report/detail?id=번호
  2. report(TB_POST) + report.photoUrls(TB_FILE) 표시
  4. POST /give/report/status → 상태 변경
  5. comments(TB_POST_COMMENT) 표시 + POST /give/report/comment (parentId → 대댓글)
  6. POST /give/report/comment/delete — 본인 댓글 삭제
  7. POST /give/report/comment/update — 본인 댓글 수정

  - 박유정 / 2026-07-29 — 발견 위치 카카오맵 (TB_POST LOST_LAT/LNG, kakaomap.jsp)
--%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId"      value="give" />
<%@ include file="/WEB-INF/views/common/header.jsp" %>
<style>
  .rd-wrap{max-width:var(--inner-width);margin:32px auto 80px;padding:0 20px;display:grid;grid-template-columns:1fr 320px;gap:28px;align-items:flex-start}
  .rd-back{display:inline-flex;align-items:center;gap:6px;font-size:13px;color:var(--text-muted);text-decoration:none;margin-bottom:18px;transition:var(--transition)}
  .rd-back:hover{color:var(--primary)}
  .rd-back svg{width:14px;height:14px;stroke:currentColor;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}
  .rd-photos{display:grid;grid-template-columns:2fr 1fr;gap:6px;border-radius:var(--radius-md);overflow:hidden;margin-bottom:20px}
  .rd-photos img{width:100%;object-fit:cover;display:block}
  .rd-photos img:first-child{height:260px;grid-row:span 2}
  .rd-photos img:not(:first-child){height:127px}
  .rd-status-row{display:flex;align-items:center;gap:10px;margin-bottom:10px}
  .rd-status{font-size:13px;font-weight:700;padding:4px 14px;border-radius:20px}
  .rds-finding{background:#FFF8E1;color:#F59E0B}
  .rds-rescued{background:#DCFCE7;color:#16A34A}
  .rd-title{font-size:22px;font-weight:800;color:var(--text-main);margin-bottom:14px;line-height:1.3}
  .rd-tags{display:flex;gap:7px;flex-wrap:wrap;margin-bottom:16px}
  .rd-tag{font-size:12px;font-weight:700;padding:4px 12px;border-radius:20px;background:var(--primary-light);color:var(--primary-dark)}
  .rd-info-grid{display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:20px}
  .rd-info-row{background:var(--bg-page);border-radius:var(--radius-sm);padding:12px 14px}
  .rd-info-row label{font-size:11px;color:var(--text-muted);font-weight:600;display:block;margin-bottom:3px}
  .rd-info-row span{font-size:14px;font-weight:600;color:var(--text-main)}
  .rd-section{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);padding:18px;margin-bottom:16px}
  .rd-section h3{font-size:14px;font-weight:800;color:var(--text-main);margin:0 0 12px}
  .rd-desc{font-size:14px;color:var(--text-sub);line-height:1.8;margin:0;border-left:3px solid var(--primary);padding-left:14px;white-space:pre-line}
  .rd-map{border-radius:var(--radius-sm);overflow:hidden;height:180px}
  /* 2026-07-29 박유정 — 상세 발견 위치 카카오맵 영역 */
  #kakao-map{width:100%;height:180px}
  .comment-input-wrap{display:flex;gap:10px;margin-bottom:18px}
  .comment-avatar{width:36px;height:36px;border-radius:50%;object-fit:cover;flex-shrink:0;background:var(--primary-light)}
  .comment-flex{flex:1}
  .comment-input{width:100%;border:1px solid var(--border);border-radius:var(--radius-sm);padding:10px 13px;font-size:14px;color:var(--text-main);outline:none;font-family:inherit;resize:none;min-height:70px;line-height:1.6;box-sizing:border-box}
  .comment-input:focus{border-color:var(--primary)}
  .comment-submit-row{display:flex;justify-content:flex-end;margin-top:8px}
  .comment-submit-row button{padding:7px 18px;border:none;border-radius:var(--radius-sm);background:var(--primary);color:#fff;font-size:13px;font-weight:700;cursor:pointer}
  .comment-item{display:flex;gap:12px;margin-bottom:18px}
  .comment-body-box{flex:1}
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
  .comment-error{font-size:12px;color:#B91C1C;margin-bottom:10px}
  
  /* 사이드 카드 */
  .rd-side-card{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);padding:20px;position:sticky;top:20px;margin-bottom:16px}
  .rd-side-card h3{font-size:14px;font-weight:800;color:var(--text-main);margin:0 0 14px;padding-bottom:12px;border-bottom:1px solid var(--border)}
  .side-row{display:flex;justify-content:space-between;font-size:13px;color:var(--text-sub);margin-bottom:10px}
  .side-row:last-child{margin-bottom:0}
  .side-row span:last-child{font-weight:700;color:var(--text-main)}
  .btn-status-change{width:100%;padding:11px;border:none;border-radius:var(--radius-sm);background:var(--primary);color:#fff;font-size:14px;font-weight:700;cursor:pointer;margin-top:14px;transition:var(--transition)}
  .btn-status-change:hover{background:var(--primary-dark)}
</style>

<div class="rd-wrap">
  <div>
    <a href="${contextPath}/give?tab=report" class="rd-back">
      <svg viewBox="0 0 24 24"><path d="M19 12H5"/><polyline points="12 19 5 12 12 5"/></svg>
      발견 신고 목록으로
    </a>
    <div class="rd-photos">
      <%-- TB_FILE에서 조회한 사진 URL (report.photoUrls) --%>
      <c:choose>
        <c:when test="${not empty report.photoUrls}">
          <c:forEach var="url" items="${report.photoUrls}">
            <img src="${contextPath}${url}" alt="발견사진" onerror="this.src='https://placehold.co/600x260/EAF7F2/2BAB82?text=발견사진'">
          </c:forEach>
        </c:when>
        <c:otherwise>
          <img src="https://placehold.co/600x260/EAF7F2/2BAB82?text=발견사진" alt="발견사진 없음">
        </c:otherwise>
      </c:choose>
    </div>

    <div class="rd-status-row">
      <c:choose>
        <c:when test="${fn:contains(report.tags, 'OWNER_FOUND')}">
          <span class="rd-status rds-rescued">주인 찾음</span>
        </c:when>
        <c:when test="${fn:contains(report.tags, 'RESCUED')}">
          <span class="rd-status rds-rescued">구조 완료</span>
        </c:when>
        <c:otherwise>
          <span class="rd-status rds-finding">찾는 중</span>
        </c:otherwise>
      </c:choose>
      <span style="font-size:12px;color:var(--text-muted)">신고번호: #${report.postId}</span>
    </div>
    <div class="rd-title">${report.title}</div>
   <div class="rd-tags">
   <c:if test="${report.lostSpecies eq 'DOG'}">
    <span class="rd-tag">강아지</span>
   </c:if>
   <c:if test="${report.lostSpecies eq 'CAT'}">
    <span class="rd-tag">고양이</span>
   </c:if>
   <c:if test="${report.lostSpecies eq 'ETC'}">
    <span class="rd-tag">기타</span>
   </c:if>

      <c:if test="${not empty report.animalSize}">
        <span class="rd-tag">${report.animalSize}</span>
      </c:if>
      <c:if test="${not empty report.furColor}">
        <span class="rd-tag">${report.furColor}</span>
      </c:if>
      <c:if test="${report.gender eq 'M'}">
        <span class="rd-tag">수컷</span>
      </c:if>
      <c:if test="${report.gender eq 'F'}">
        <span class="rd-tag">암컷</span>
      </c:if>
      <c:if test="${report.gender eq 'UNKNOWN'}">
        <span class="rd-tag">성별 모름</span>
      </c:if>
      <c:if test="${not empty report.featureTags}">
        <c:forEach var="ft" items="${fn:split(report.featureTags, ',')}">
          <c:if test="${not empty ft}">
            <span class="rd-tag">${ft}</span>
          </c:if>
        </c:forEach>
      </c:if>

    <c:if test="${fn:contains(report.tags, 'TEMP_CARE')}">
    <span class="rd-tag">임시보호 중</span>
  </c:if>
</div>

    <div class="rd-info-grid">
      <div class="rd-info-row"><label>발견 장소</label><span>${report.region}</span></div>
      <div class="rd-info-row"><label>연락처</label><span>${report.lostContact}</span></div>
    </div>

    <div class="rd-section">
      <h3>상세 설명</h3>
      <p class="rd-desc">${report.body}</p>
    </div>

    <div class="rd-section">
      <h3>발견 위치</h3>
      <%-- 2026-07-29 박유정 — 저장된 LOST_LAT/LNG 카카오맵 마커 --%>
      <div class="rd-map">
        <div id="kakao-map"></div>
        <%@ include file="/WEB-INF/views/common/kakaomap.jsp" %>
      </div>
    </div>

    <div class="rd-section">
      <h3>댓글 (${empty commentCount ? 0 : commentCount})</h3>

      <c:if test="${param.error eq 'empty'}">
        <p class="comment-error">댓글 내용을 입력해 주세요.</p>
      </c:if>
      <c:if test="${param.error eq 'comment'}">
        <p class="comment-error">댓글 처리에 실패했습니다.</p>
      </c:if>
      <c:if test="${param.error eq 'commentForbidden'}">
        <p class="comment-error">본인 댓글만 수정·삭제할 수 있습니다.</p>
      </c:if>
      <c:if test="${param.error eq 'member'}">
        <p class="comment-error">회원 정보를 확인할 수 없습니다. 다시 로그인해 주세요.</p>
      </c:if>
      <c:if test="${param.error eq 'seq'}">
        <p class="comment-error">댓글 시퀀스(SEQ_TB_POST_COMMENT)가 DB에 없습니다.</p>
      </c:if>

      <form method="post" action="${contextPath}/give/report/comment">
        <!--HYJ 26.08.05-->
        <input type="hidden" name="_csrf" value="${_csrf}">
        
        <input type="hidden" name="postId" value="${report.postId}">
        <div class="comment-input-wrap">
          <%-- 2026/08/06 장우철 — 로그인 회원 프로필 아바타 --%>
          <img class="comment-avatar"
               src="${not empty memberInfo.profileImgUrl ? contextPath.concat(memberInfo.profileImgUrl) : 'https://placehold.co/36x36/EAF7F2/2BAB82?text=ME'}"
               alt="me"
               onerror="this.src='https://placehold.co/36x36/EAF7F2/2BAB82?text=ME'">
          <div class="comment-flex">
            <textarea class="comment-input" name="body" placeholder="제보, 목격 정보, 응원 댓글을 남겨주세요." required></textarea>
            <div class="comment-submit-row"><button type="submit">등록</button></div>
          </div>
        </div>
      </form>

      <c:forEach var="cmt" items="${comments}">
        <div class="comment-item">
          <%-- 2026/08/06 장우철 — 댓글 작성자 프로필 아바타 --%>
          <img class="comment-avatar"
               src="${not empty cmt.profileImgUrl ? contextPath.concat(cmt.profileImgUrl) : 'https://placehold.co/36x36/EAF7F2/2BAB82?text=U'}"
               alt="댓글러"
               onerror="this.src='https://placehold.co/36x36/EAF7F2/2BAB82?text=U'">
          <div class="comment-body-box">
            <div class="comment-head">
              <span class="comment-name">
                <c:choose>
                  <c:when test="${cmt.isDeleted eq 'Y'}">삭제된 댓글</c:when>
                  <c:otherwise>${cmt.nickname}</c:otherwise>
                </c:choose>
              </span>
              <div class="comment-head-meta">
                <span class="comment-date">
                  <c:choose>
                    <c:when test="${not empty cmt.regDate}">
                      ${cmt.regDate.year}.${cmt.regDate.monthValue}.${cmt.regDate.dayOfMonth}
                    </c:when>
                    <c:otherwise>-</c:otherwise>
                  </c:choose>
                </span>
                <%-- 2026/08/03 장우철 — 삭제된 댓글은 수정/삭제 숨김 --%>
                <c:if test="${cmt.isDeleted ne 'Y' && loginMemberNo != null && loginMemberNo == cmt.memberNo}">
                  <span class="comment-meta-sep">·</span>
                  <button type="button" class="comment-edit-btn"
                          onclick="toggleEditForm(${cmt.commentId})">수정</button>
                  <span class="comment-meta-sep">·</span>
                  <form method="post" action="${contextPath}/give/report/comment/delete" style="display:inline;margin:0;padding:0">
                    <!--HYJ 26.08.05-->
                    <input type="hidden" name="_csrf" value="${_csrf}">
                    
                    <input type="hidden" name="commentId" value="${cmt.commentId}">
                    <input type="hidden" name="postId" value="${report.postId}">
                    <button type="submit" class="comment-delete-btn"
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
                  <form method="post" action="${contextPath}/give/report/comment/update">
                  <!--HYJ 26.08.05-->
                <input type="hidden" name="_csrf" value="${_csrf}">
                    <input type="hidden" name="commentId" value="${cmt.commentId}">
                    <input type="hidden" name="postId" value="${report.postId}">
                    <textarea class="comment-input reply-input" name="body" required><c:out value="${cmt.body}"/></textarea>
                    <div class="comment-submit-row">
                      <button type="button" class="reply-btn" onclick="toggleEditForm(${cmt.commentId})">취소</button>
                      <button type="submit">저장</button>
                    </div>
                  </form>
                </div>
              </c:otherwise>
            </c:choose>
            <div class="comment-actions">
              <button type="button" class="reply-btn" onclick="toggleReplyForm(${cmt.commentId})">↳ 답글</button>
            </div>
            <div id="replyForm-${cmt.commentId}" class="reply-form">
              <form method="post" action="${contextPath}/give/report/comment">
                <!--HYJ 26.08.05-->
                <input type="hidden" name="_csrf" value="${_csrf}">
                
                <input type="hidden" name="postId" value="${report.postId}">
                <input type="hidden" name="parentId" value="${cmt.commentId}">
                <textarea class="comment-input reply-input" name="body" placeholder="답글을 입력하세요..." required></textarea>
                <div class="comment-submit-row"><button type="submit">등록</button></div>
              </form>
            </div>
          </div>
        </div>

        <c:forEach var="reply" items="${cmt.replies}">
          <div class="comment-item reply-item">
            <%-- 2026/08/06 장우철 — 답글 작성자 프로필 아바타 --%>
            <img class="comment-avatar"
                 src="${not empty reply.profileImgUrl ? contextPath.concat(reply.profileImgUrl) : 'https://placehold.co/36x36/EAF7F2/2BAB82?text=R'}"
                 alt="답글러"
                 onerror="this.src='https://placehold.co/36x36/EAF7F2/2BAB82?text=R'">
            <div class="comment-body-box">
              <div class="comment-head">
                <span class="comment-name">
                  <c:choose>
                    <c:when test="${reply.isDeleted eq 'Y'}">삭제된 댓글</c:when>
                    <c:otherwise>${reply.nickname}</c:otherwise>
                  </c:choose>
                </span>
                <div class="comment-head-meta">
                  <span class="comment-date">
                    <c:choose>
                      <c:when test="${not empty reply.regDate}">
                        ${reply.regDate.year}.${reply.regDate.monthValue}.${reply.regDate.dayOfMonth}
                      </c:when>
                      <c:otherwise>-</c:otherwise>
                    </c:choose>
                  </span>
                  <c:if test="${reply.isDeleted ne 'Y' && loginMemberNo != null && loginMemberNo == reply.memberNo}">
                    <span class="comment-meta-sep">·</span>
                    <button type="button" class="comment-edit-btn"
                            onclick="toggleEditForm(${reply.commentId})">수정</button>
                    <span class="comment-meta-sep">·</span>
                    <form method="post" action="${contextPath}/give/report/comment/delete" style="display:inline;margin:0;padding:0">
                      <!--HYJ 26.08.05-->
                      <input type="hidden" name="_csrf" value="${_csrf}">
                      
                      <input type="hidden" name="commentId" value="${reply.commentId}">
                      <input type="hidden" name="postId" value="${report.postId}">
                      <button type="submit" class="comment-delete-btn"
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
                    <form method="post" action="${contextPath}/give/report/comment/update">
                    <!--HYJ 26.08.05-->
                <input type="hidden" name="_csrf" value="${_csrf}">
                      <input type="hidden" name="commentId" value="${reply.commentId}">
                      <input type="hidden" name="postId" value="${report.postId}">
                      <textarea class="comment-input reply-input" name="body" required><c:out value="${reply.body}"/></textarea>
                      <div class="comment-submit-row">
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
        <p style="font-size:13px;color:var(--text-muted);text-align:center;padding:12px 0">아직 댓글이 없습니다.</p>
      </c:if>
    </div>
  </div>

  <div>
    <div class="rd-side-card">
      <h3>신고 현황</h3>
      <div class="side-row">
        <span>상태</span>
        <c:choose>
          <c:when test="${fn:contains(report.tags, 'OWNER_FOUND')}">
            <span style="color:#16A34A;font-weight:800">주인 찾음</span>
          </c:when>
          <c:when test="${fn:contains(report.tags, 'RESCUED')}">
            <span style="color:#16A34A;font-weight:800">구조 완료</span>
          </c:when>
          <c:otherwise>
            <span style="color:#F59E0B;font-weight:800">찾는 중</span>
          </c:otherwise>
        </c:choose>
      </div>
      <div class="side-row">
        <span>신고일</span>
        <span>
          <c:choose>
            <c:when test="${not empty report.regDate}">
              ${report.regDate.year}.${report.regDate.monthValue}.${report.regDate.dayOfMonth}
            </c:when>
            <c:otherwise>-</c:otherwise>
          </c:choose>
        </span>
      </div>
      <div class="side-row"><span>댓글</span><span>${empty commentCount ? 0 : commentCount}</span></div>
            <c:if test="${param.error eq 'forbidden'}">
        <p style="font-size:12px;color:#B91C1C;margin-bottom:10px">작성자만 상태를 변경할 수 있습니다.</p>
      </c:if>
      <c:if test="${param.error eq 'status'}">
        <p style="font-size:12px;color:#B91C1C;margin-bottom:10px">상태 변경에 실패했습니다.</p>
      </c:if>

      <c:if test="${loginMemberNo != null && loginMemberNo == report.memberNo}">
      <form method="post" action="${contextPath}/give/report/status">
        <!--HYJ 26.08.05-->
        <input type="hidden" name="_csrf" value="${_csrf}">
        
        <input type="hidden" name="postId" value="${report.postId}">

        <select name="findingStatus"
                style="width:100%;border:1px solid var(--border);border-radius:var(--radius-sm);padding:9px 12px;font-size:14px;color:var(--text-main);outline:none;margin-top:12px">
          <option value="FINDING"
            ${fn:contains(report.tags, 'FINDING') && !fn:contains(report.tags, 'RESCUED') && !fn:contains(report.tags, 'OWNER_FOUND') ? 'selected' : ''}>
            찾는 중
          </option>
          <option value="RESCUED"
            ${fn:contains(report.tags, 'RESCUED') ? 'selected' : ''}>
            구조 완료
          </option>
          <option value="OWNER_FOUND"
            ${fn:contains(report.tags, 'OWNER_FOUND') ? 'selected' : ''}>
            주인 찾음
          </option>
        </select>

        <button type="submit" class="btn-status-change">상태 변경</button>
      </form>
      </c:if>
    </div>
  </div>
</div>

<script>
  const isLoggedIn = ${isLoggedIn == true};

  function toggleReplyForm(commentId) {
    if (!isLoggedIn) {
      alert('로그인 후 답글을 작성할 수 있습니다.');
      location.href = '${contextPath}/login?redirect=/give/report/detail?id=${report.postId}';
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
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
