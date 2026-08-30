<%-- community/list.jsp — 커뮤니티 게시판 목록 --%>
<%--
  - 박유정 / 2026-07-08~10
  - STEP 3: 목록 DB 연동 (작성자·페이징·검색·총 개수)
  - STEP 4: LIFE ANSWERED 시 vet-answer 답변 미리보기 (2026-07-10)

  [목록 화면 흐름]
  1. GET /community?boardType=... → CommunityPostController.list()
  2. Service → TB_POST 조회 + thumbUrl(첫 사진)
  3. 아래 <c:forEach items="${list}"> 로 카드 표시
  4. 탭 클릭은 index.jsp 의 <a href> 로 URL 이동 (JS 필터 X)

  [탭 ↔ boardType]
  - 전체 /community
  - 집사생활 ?boardType=TOWN
  - 무료나눔 ?boardType=SHARE
  - 수의사 상담 ?boardType=LIFE
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="community" />
<%@ include file="/WEB-INF/views/community/index.jsp" %>
  <%-- ── 일반 게시판 영역 ─────────────────────────────── --%>
  <div id="normalBoard" style="${boardType eq 'LIFE' ? 'display:none' : ''}">
    <c:if test="${not empty successMessage}">
      <div style="background:#DCFCE7;border:1px solid #86EFAC;border-radius:var(--radius-sm);padding:14px 16px;margin-bottom:18px;font-size:14px;color:#166534">
        ${successMessage}
      </div>
    </c:if>
    <c:if test="${param.error eq 'server'}">
      <div style="background:#FEE2E2;border:1px solid #FCA5A5;border-radius:var(--radius-sm);padding:14px 16px;margin-bottom:18px;font-size:14px;color:#B91C1C">
        일시적인 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.
      </div>
    </c:if>
    <div class="comm-toolbar">
      <span style="font-size:14px;color:var(--text-sub)">총 <strong style="color:var(--text-main)">${totalCount}</strong>개 게시글</span>
      <form class="comm-search" method="get" action="${contextPath}/community">
        <input type="hidden" name="boardType" value="${boardType}">
        <input type="text" name="keyword" value="${keyword}" placeholder="게시글 검색...">
        <button type="submit">검색</button>
      </form>
    </div>

    <%-- DB 글 목록 (Controller 가 넘긴 ${list}) --%>
    <c:forEach var="item" items="${list}">
      <div class="comm-card" onclick="location.href='${contextPath}/community/detail?id=${item.postId}'">
        <img class="comm-thumb"
             src="${not empty item.thumbUrl ? contextPath.concat(item.thumbUrl) : 'https://placehold.co/96x96/EAF7F2/2BAB82?text=IMG'}"
             alt="썸네일"
             onerror="this.src='https://placehold.co/96x96/EAF7F2/2BAB82?text=IMG'">
        <div class="comm-body">
          <div>
            <c:choose>
              <c:when test="${item.boardType eq 'TOWN'}">
                <span class="comm-category cat-town">집사생활</span>
              </c:when>
              <c:when test="${item.boardType eq 'SHARE'}">
                <span class="comm-category cat-share">무료나눔</span>
              </c:when>
              <c:when test="${item.boardType eq 'LIFE'}">
                <span class="comm-category cat-life">수의사 상담</span>
              </c:when>
            </c:choose>
            <div class="comm-title">${item.title}</div>
            <div class="comm-preview">${item.body}</div>
          </div>
          <div class="comm-meta">
            <span class="comm-meta-item">${not empty item.authorName ? item.authorName : '익명'}</span>
            <span class="comm-meta-item">${item.regDate}</span>
            <span class="comm-meta-item">조회 ${item.viewCount}</span>
            <span class="comm-meta-item">♥ ${item.likeCnt}</span>
          </div>
        </div>
      </div>
    </c:forEach>

<c:if test="${empty list}">
  <p style="text-align:center;color:var(--text-muted);padding:40px 0">
    <c:choose>
      <c:when test="${not empty keyword}">
        '<c:out value="${keyword}"/>' 검색 결과가 없습니다.
      </c:when>
      <c:otherwise>
        등록된 게시글이 없습니다.
      </c:otherwise>
    </c:choose>
  </p>
</c:if>

  <c:if test="${totalPages > 1}">
    <div style="display:flex;justify-content:center;margin-top:24px;gap:5px;align-items:center">
      <c:if test="${page > 1}">
        <c:url var="prevPageUrl" value="/community">
          <c:param name="boardType" value="${boardType}" />
          <c:param name="keyword" value="${keyword}" />
          <c:param name="page" value="${page - 1}" />
        </c:url>
        <a href="${contextPath}${prevPageUrl}"
           style="width:36px;height:36px;border:1px solid var(--border);border-radius:var(--radius-sm);background:#fff;display:flex;align-items:center;justify-content:center;text-decoration:none;color:var(--text-sub)">‹</a>
      </c:if>
      <c:forEach begin="1" end="${totalPages}" var="p">
        <c:choose>
          <c:when test="${p eq page}">
            <span style="width:36px;height:36px;border:1px solid var(--primary);border-radius:var(--radius-sm);background:var(--primary);color:#fff;font-weight:700;display:flex;align-items:center;justify-content:center">${p}</span>
          </c:when>
          <c:otherwise>
            <c:url var="pageUrl" value="/community">
              <c:param name="boardType" value="${boardType}" />
              <c:param name="keyword" value="${keyword}" />
              <c:param name="page" value="${p}" />
            </c:url>
            <a href="${contextPath}${pageUrl}"
               style="width:36px;height:36px;border:1px solid var(--border);border-radius:var(--radius-sm);background:#fff;display:flex;align-items:center;justify-content:center;text-decoration:none;color:var(--text-sub)">${p}</a>
          </c:otherwise>
        </c:choose>
      </c:forEach>
      <c:if test="${page < totalPages}">
        <c:url var="nextPageUrl" value="/community">
          <c:param name="boardType" value="${boardType}" />
          <c:param name="keyword" value="${keyword}" />
          <c:param name="page" value="${page + 1}" />
        </c:url>
        <a href="${contextPath}${nextPageUrl}"
           style="width:36px;height:36px;border:1px solid var(--border);border-radius:var(--radius-sm);background:#fff;display:flex;align-items:center;justify-content:center;text-decoration:none;color:var(--text-sub)">›</a>
      </c:if>
    </div>
  </c:if>
  </div><%-- end #normalBoard --%>

  <%-- ── 수의사 상담 탭 영역 ──────────────────────────── --%>
  <div id="vetBoard" style="${boardType eq 'LIFE' ? '' : 'display:none'}">
    <c:if test="${not empty successMessage}">
      <div style="background:#DCFCE7;border:1px solid #86EFAC;border-radius:var(--radius-sm);padding:14px 16px;margin-bottom:18px;font-size:14px;color:#166534">
        ${successMessage}
      </div>
    </c:if>
    <c:if test="${param.error eq 'member'}">
      <div style="background:#FEE2E2;border:1px solid #FCA5A5;border-radius:var(--radius-sm);padding:14px 16px;margin-bottom:18px;font-size:14px;color:#B91C1C">
        로그인은 되어 있지만 DB에 회원 정보가 없습니다. 회원가입 계정으로 다시 로그인해 주세요.
      </div>
    </c:if>
    <c:if test="${param.error eq 'save'}">
      <div style="background:#FEE2E2;border:1px solid #FCA5A5;border-radius:var(--radius-sm);padding:14px 16px;margin-bottom:18px;font-size:14px;color:#B91C1C">
        상담 등록에 실패했습니다. 잠시 후 다시 시도해 주세요.
      </div>
    </c:if>
    <%-- 안내 배너 --%>
    <div class="vet-banner">
      <div class="vet-banner-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></svg>
      </div>
      <div>
        <div class="vet-banner-title">펫케어 수의사 상담</div>
        <div class="vet-banner-desc">등록된 수의사 선생님이 직접 답변해드립니다. 평균 답변 시간 <strong>4시간</strong> 이내</div>
      </div>
      <button class="btn-vet-ask" onclick="toggleAskForm()">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
        상담 글쓰기
      </button>
    </div>

    <%-- 상담 글쓰기 폼 (토글) — POST /community/write --%>
    <div class="vet-ask-form" id="askForm" style="display:none">
      <form method="post"
            action="${contextPath}/community/write"
            enctype="multipart/form-data"
            onsubmit="return confirm('상담 글을 등록하시겠습니까?')">
        <!--HYJ 26.08.05-->
        <input type="hidden" name="_csrf" value="${_csrf}">
        
        <input type="hidden" name="boardType" value="LIFE">
        <div class="vet-ask-title">상담 내용 작성</div>
        <div class="vet-form-row">
          <label>반려동물 종류 <span class="req">*</span></label>
          <div style="display:flex;gap:8px;flex-wrap:wrap">
            <label class="vet-radio-label"><input type="radio" name="petType" value="DOG" checked required> 강아지</label>
            <label class="vet-radio-label"><input type="radio" name="petType" value="CAT"> 고양이</label>
            <label class="vet-radio-label"><input type="radio" name="petType" value="ETC"> 기타</label>
          </div>
        </div>
        <div class="vet-form-grid">
          <div class="vet-form-row">
            <label>품종 <span class="req">*</span></label>
            <select class="vet-select" id="vet-breed" name="breed" required>
              <option value="">종류를 먼저 선택하세요</option>
            </select>
          </div>
          <div class="vet-form-row">
            <label>나이</label>
            <input type="text" class="vet-input" name="petAge" placeholder="예) 2세, 생후 6개월">
          </div>
        </div>
        <div class="vet-form-row">
          <label>상담 제목 <span class="req">*</span></label>
          <input type="text" class="vet-input" name="title" placeholder="상담하실 내용을 간략하게 적어주세요" required>
        </div>
        <div class="vet-form-row">
          <label>증상 및 상담 내용 <span class="req">*</span></label>
          <textarea class="vet-textarea" name="body" placeholder="언제부터 증상이 시작됐는지, 어떤 행동을 보이는지 최대한 자세히 적어주세요.&#10;&#10;예) 3일 전부터 밥을 잘 안 먹고, 물은 평소보다 많이 마셔요. 구토는 없지만 기운이 없어 보여요." required></textarea>
        </div>
        <div class="vet-form-row">
          <label>관련 사진 첨부 <span style="font-size:12px;color:var(--text-muted);font-weight:400">(선택, 최대 3장)</span></label>
          <label class="vet-upload-box" style="cursor:pointer">
            <input type="file" name="photos" accept="image/*" multiple style="display:none"
                   onchange="var n=this.files.length;this.closest('.vet-form-row').querySelector('.vet-upload-label').textContent=n?n+'장 선택됨':'클릭하여 사진 업로드'">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
            <span class="vet-upload-label">클릭하여 사진 업로드</span>
          </label>
        </div>
        <div style="display:flex;gap:10px;justify-content:flex-end">
          <button type="button" class="vet-btn-cancel" onclick="toggleAskForm()">취소</button>
          <button type="submit" class="vet-btn-submit">등록하기</button>
        </div>
      </form>
    </div>

    <%-- 필터 --%>
    <div class="comm-toolbar" style="margin-bottom:16px">
      <span style="font-size:14px;color:var(--text-sub)">총 <strong style="color:var(--text-main)">${totalCount}</strong>개 상담</span>
      <form class="comm-search" method="get" action="${contextPath}/community" style="display:flex;gap:8px">
        <input type="hidden" name="boardType" value="LIFE">
        <select class="vet-select" name="petSpecies" onchange="this.form.submit()">
          <option value="" ${empty petSpecies ? 'selected' : ''}>전체 동물</option>
          <option value="DOG" ${petSpecies eq 'DOG' ? 'selected' : ''}>강아지</option>
          <option value="CAT" ${petSpecies eq 'CAT' ? 'selected' : ''}>고양이</option>
          <option value="ETC" ${petSpecies eq 'ETC' ? 'selected' : ''}>기타</option>
        </select>
        <select class="vet-select" name="vetStatus" onchange="this.form.submit()">
          <option value="" ${empty vetStatus ? 'selected' : ''}>전체 상태</option>
          <option value="ANSWERED" ${vetStatus eq 'ANSWERED' ? 'selected' : ''}>답변 완료</option>
          <option value="WAITING" ${vetStatus eq 'WAITING' ? 'selected' : ''}>답변 대기</option>
        </select>
        <input type="text" name="keyword" value="${keyword}" placeholder="증상, 키워드 검색...">
        <button type="submit">검색</button>
      </form>
    </div>

    <%-- 상담 카드 목록 (DB) --%>
    <c:forEach var="item" items="${list}">
      <div class="vet-card" onclick="location.href='${contextPath}/community/detail?id=${item.postId}'" style="cursor:pointer">
        <div class="vet-card-head">
          <div class="vet-card-badges">
            <c:choose>
              <c:when test="${item.lostSpecies eq 'DOG'}">
                <span class="vet-badge dog">강아지</span>
              </c:when>
              <c:when test="${item.lostSpecies eq 'CAT'}">
                <span class="vet-badge cat">고양이</span>
              </c:when>
              <c:when test="${not empty item.lostSpecies}">
                <span class="vet-badge">기타</span>
              </c:when>
            </c:choose>
            <c:choose>
              <c:when test="${fn:contains(item.tags, 'ANSWERED')}">
                <span class="vet-badge answered">답변완료</span>
              </c:when>
              <c:otherwise>
                <span class="vet-badge waiting">답변대기</span>
              </c:otherwise>
            </c:choose>
          </div>
          <span class="vet-card-date">${item.regDate}</span>
        </div>
        <div class="vet-card-title"><c:out value="${item.title}"/></div>
        <div class="vet-card-preview"><c:out value="${item.body}"/></div>
        <%-- 2026-07-10 박유정 STEP 4 — 답변완료 카드 답변 미리보기 --%>
        <c:if test="${fn:contains(item.tags, 'ANSWERED') && not empty item.answerBody}">
          <div class="vet-answer" onclick="event.stopPropagation()">
            <div class="vet-answer-head">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></svg>
              수의사 답변 · <c:out value="${not empty item.answerAuthor ? item.answerAuthor : '익명'}"/>
              <span class="vet-answer-date">
                <c:if test="${not empty item.answerDate}">
                  ${item.answerDate.year}.${item.answerDate.monthValue}.${item.answerDate.dayOfMonth}
                </c:if>
              </span>
            </div>
            <div class="vet-answer-text"><c:out value="${item.answerBody}"/></div>
          </div>
        </c:if>
        <div class="vet-card-meta" style="margin-top:12px">
          <span class="vet-meta-item">
            <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
            ${not empty item.authorName ? item.authorName : '익명'}
          </span>
          <span class="vet-meta-item">
            <svg viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
            ${item.viewCount}
          </span>
          <span class="vet-meta-item like">
            <svg viewBox="0 0 24 24"><path d="M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78L12 21.23l8.84-8.84a5.5 5.5 0 000-7.78z"/></svg>
            ${item.likeCnt}
          </span>
        </div>
      </div>
    </c:forEach>

    <c:if test="${empty list}">
      <p style="text-align:center;color:var(--text-muted);padding:40px 0">
        <c:choose>
          <c:when test="${not empty keyword}">
            '<c:out value="${keyword}"/>' 검색 결과가 없습니다.
          </c:when>
          <c:otherwise>
            등록된 상담이 없습니다.
          </c:otherwise>
        </c:choose>
      </p>
    </c:if>

    <c:if test="${totalPages > 1}">
      <div style="display:flex;justify-content:center;margin-top:24px;gap:5px;align-items:center">
        <c:if test="${page > 1}">
          <c:url var="vetPrevPageUrl" value="/community">
            <c:param name="boardType" value="LIFE" />
            <c:param name="keyword" value="${keyword}" />
            <c:param name="petSpecies" value="${petSpecies}" />
            <c:param name="vetStatus" value="${vetStatus}" />
            <c:param name="page" value="${page - 1}" />
          </c:url>
          <a href="${contextPath}${vetPrevPageUrl}"
             style="width:36px;height:36px;border:1px solid var(--border);border-radius:var(--radius-sm);background:#fff;display:flex;align-items:center;justify-content:center;text-decoration:none;color:var(--text-sub)">‹</a>
        </c:if>
        <c:forEach begin="1" end="${totalPages}" var="p">
          <c:choose>
            <c:when test="${p eq page}">
              <span style="width:36px;height:36px;border:1px solid var(--primary);border-radius:var(--radius-sm);background:var(--primary);color:#fff;font-weight:700;display:flex;align-items:center;justify-content:center">${p}</span>
            </c:when>
            <c:otherwise>
              <c:url var="vetPageUrl" value="/community">
                <c:param name="boardType" value="LIFE" />
                <c:param name="keyword" value="${keyword}" />
                <c:param name="petSpecies" value="${petSpecies}" />
                <c:param name="vetStatus" value="${vetStatus}" />
                <c:param name="page" value="${p}" />
              </c:url>
              <a href="${contextPath}${vetPageUrl}"
                 style="width:36px;height:36px;border:1px solid var(--border);border-radius:var(--radius-sm);background:#fff;display:flex;align-items:center;justify-content:center;text-decoration:none;color:var(--text-sub)">${p}</a>
            </c:otherwise>
          </c:choose>
        </c:forEach>
        <c:if test="${page < totalPages}">
          <c:url var="vetNextPageUrl" value="/community">
            <c:param name="boardType" value="LIFE" />
            <c:param name="keyword" value="${keyword}" />
            <c:param name="petSpecies" value="${petSpecies}" />
            <c:param name="vetStatus" value="${vetStatus}" />
            <c:param name="page" value="${page + 1}" />
          </c:url>
          <a href="${contextPath}${vetNextPageUrl}"
             style="width:36px;height:36px;border:1px solid var(--border);border-radius:var(--radius-sm);background:#fff;display:flex;align-items:center;justify-content:center;text-decoration:none;color:var(--text-sub)">›</a>
        </c:if>
      </div>
    </c:if>
  </div><%-- end #vetBoard --%>
  </div><%-- end .comm-content --%>
</div><%-- end .comm-wrap --%>
<script src="${contextPath}/resources/js/pet-breeds.js"></script>
<script>
function selTab(btn, type) {
  document.querySelectorAll('.comm-tab').forEach(function(t) {
    if (t.tagName === 'BUTTON') t.classList.remove('on');
  });
  btn.classList.add('on');

  var isVet = (type === 'vet');
  document.getElementById('normalBoard').style.display = isVet ? 'none' : 'block';
  document.getElementById('vetBoard').style.display   = isVet ? 'block' : 'none';
  if (!isVet) document.getElementById('askForm').style.display = 'none';

  if (isVet) return;

  // 전체 / 집사생활 / 무료나눔 — 카드 필터 (DB 연동 전 UI용)
  document.querySelectorAll('#normalBoard .comm-card').forEach(function(card) {
    var bt = card.getAttribute('data-board-type');
    var show = false;
    if (type === 'all')   show = true;
    if (type === 'life')  show = (bt === 'LIFE');
    if (type === 'share') show = (bt === 'SHARE');
    card.style.display = show ? 'flex' : 'none';
  });
}
function toggleAskForm() {
  var f = document.getElementById('askForm');
  f.style.display = f.style.display === 'none' ? 'block' : 'none';
  if (f.style.display === 'block') f.scrollIntoView({behavior:'smooth', block:'start'});
}

// 2026/08/18 장우철 — LIFE(수의사상담) 품종 select 동적 렌더링
(function initVetBreedSelect() {
  var breedSel = document.getElementById('vet-breed');
  if (!breedSel) return;

  function sync() {
    var checked = document.querySelector('input[name="petType"]:checked');
    if (!checked) {
      breedSel.innerHTML = '<option value="">종류를 먼저 선택하세요</option>';
      return;
    }
    // pet-breeds.js는 dog/cat/etc 키를 사용
    updatePetBreedSelect(null, (checked.value || '').toLowerCase(), 'vet-breed', null);
  }

  document.querySelectorAll('input[name="petType"]').forEach(function (el) {
    el.addEventListener('change', sync);
  });

  // 초기값 반영(DOG 기본 체크)
  sync();
})();
</script>
<%@ include file="/WEB-INF/views/common/footer.jsp" %>
