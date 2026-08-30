<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
  - HYJ / 2026-07-23
  - 커뮤니티 게시글 수정 화면

  [수정 화면 흐름]
  1. GET /community/edit?id=번호 → CommunityPostController.editForm()
  2. 본인 글 확인 후 ${post} 로 기존 데이터 표시
  3. POST /community/edit → updatePost() → 상세 redirect + successMessage
  4. 실패 → ?error=save / ?error=forbidden
  2026-08-13 박유정 — 기존 사진 X 삭제 + 새 사진 추가 (전체 5장上限)

  [model]
  - post (기존 게시글 데이터), post.photoUrls
--%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="community" />
<%@ include file="/WEB-INF/views/common/header.jsp" %>
<style>
  .write-wrap{max-width:780px;margin:32px auto 80px;padding:0 20px}
  .write-title{font-size:22px;font-weight:800;color:var(--text-main);margin-bottom:24px}
  .write-form-group{display:flex;flex-direction:column;gap:6px;margin-bottom:16px}
  .write-form-group label{font-size:13px;font-weight:700;color:var(--text-sub)}
  .write-form-group select,.write-form-group input{border:1px solid var(--border);border-radius:var(--radius-sm);padding:11px 14px;font-size:14px;color:var(--text-main);outline:none;transition:border-color .2s;font-family:inherit}
  .write-form-group select:focus,.write-form-group input:focus{border-color:var(--primary)}
  .write-editor{border:1px solid var(--border);border-radius:var(--radius-sm);overflow:hidden}
  .write-toolbar{background:var(--bg-page);border-bottom:1px solid var(--border);padding:10px 14px;display:flex;gap:6px;flex-wrap:wrap}
  .toolbar-btn{padding:5px 10px;border:1px solid var(--border);border-radius:4px;background:#fff;font-size:12px;cursor:pointer;font-weight:600;color:var(--text-sub);transition:var(--transition)}
  .toolbar-btn:hover{border-color:var(--primary);color:var(--primary)}
  .write-textarea{width:100%;min-height:300px;border:none;padding:16px;font-size:14px;color:var(--text-main);outline:none;resize:vertical;font-family:inherit;line-height:1.7;box-sizing:border-box}
  .write-btn-row{display:flex;justify-content:flex-end;gap:12px;margin-top:20px}
  .btn-cancel-write{padding:12px 28px;border:1px solid var(--border);border-radius:var(--radius-sm);background:#fff;color:var(--text-sub);font-size:15px;font-weight:700;cursor:pointer}
  .btn-submit-write{padding:12px 32px;border:none;border-radius:var(--radius-sm);background:var(--primary);color:#fff;font-size:15px;font-weight:700;cursor:pointer;transition:var(--transition)}
  .btn-submit-write:hover{background:var(--primary-dark)}
  .write-error{background:#FEE2E2;border:1px solid #FCA5A5;border-radius:var(--radius-sm);padding:14px 16px;margin-bottom:20px;font-size:14px;color:#B91C1C;line-height:1.6}
  .edit-board-badge{display:inline-block;font-size:12px;font-weight:700;background:var(--primary-light);color:var(--primary-dark);padding:3px 10px;border-radius:20px;margin-bottom:10px}
  .write-img-upload{border:2px dashed var(--border);border-radius:var(--radius-sm);padding:24px;text-align:center;cursor:pointer;transition:var(--transition);display:flex;flex-direction:column;align-items:center;gap:8px;color:var(--text-muted)}
  .write-img-upload:hover{border-color:var(--primary);background:var(--primary-light);color:var(--primary-dark)}
  .write-img-upload svg{width:28px;height:28px;stroke:currentColor;fill:none;stroke-width:1.6;stroke-linecap:round;stroke-linejoin:round}
  .edit-photo-list{display:flex;flex-wrap:wrap;gap:12px;margin-bottom:12px}
  .edit-photo-item{position:relative;width:100px;height:100px}
  .edit-photo-item img{width:100%;height:100%;object-fit:cover;border-radius:8px;border:1px solid var(--border);display:block}
  .edit-photo-item.removed{display:none}
  .edit-photo-remove{position:absolute;top:4px;right:4px;width:22px;height:22px;border:none;border-radius:50%;background:rgba(0,0,0,.65);color:#fff;font-size:15px;line-height:1;cursor:pointer;display:flex;align-items:center;justify-content:center;padding:0;transition:background .15s}
  .edit-photo-remove:hover{background:#B91C1C}
  .edit-photo-count{font-size:12px;color:var(--text-muted);margin-bottom:8px}
</style>

<form method="post"
      action="${contextPath}/community/edit"
      enctype="multipart/form-data">
  <!--HYJ 26.08.05-->
  <input type="hidden" name="_csrf" value="${_csrf}">
  
  <input type="hidden" name="postId" value="${post.postId}">
<div class="write-wrap">
  <h1 class="write-title">게시글 수정</h1>

  <c:if test="${param.error eq 'save'}">
    <div class="write-error">수정에 실패했습니다. 잠시 후 다시 시도해 주세요.</div>
  </c:if>
  <c:if test="${param.error eq 'forbidden'}">
    <div class="write-error">본인이 작성한 글만 수정할 수 있습니다.</div>
  </c:if>

  <div class="write-form-group">
    <label>게시판</label>
    <c:choose>
      <c:when test="${post.boardType eq 'TOWN'}"><span class="edit-board-badge">집사생활</span></c:when>
      <c:when test="${post.boardType eq 'SHARE'}"><span class="edit-board-badge">무료나눔</span></c:when>
      <c:when test="${post.boardType eq 'LIFE'}"><span class="edit-board-badge">수의사 상담</span></c:when>
    </c:choose>
  </div>

  <div class="write-form-group">
    <label>제목</label>
    <input type="text" name="title" value="<c:out value='${post.title}'/>" placeholder="제목을 입력하세요" required>
  </div>
  <div class="write-form-group">
    <label>내용</label>
    <div class="write-editor">
      <div class="write-toolbar">
        <button type="button" class="toolbar-btn"><strong>B</strong></button>
        <button type="button" class="toolbar-btn"><em>I</em></button>
        <button type="button" class="toolbar-btn"><u>U</u></button>
        <button type="button" class="toolbar-btn">H1</button>
        <button type="button" class="toolbar-btn">H2</button>
        <button type="button" class="toolbar-btn">목록</button>
        <button type="button" class="toolbar-btn">링크</button>
      </div>
      <textarea class="write-textarea" name="body" placeholder="내용을 입력하세요..." required><c:out value="${post.body}"/></textarea>
    </div>
  </div>
  <div class="write-form-group" id="edit-photo-section">
    <label>이미지 (최대 5장)</label>
    <p class="edit-photo-count" id="edit-photo-count"></p>

    <%-- 2026-08-13 박유정 — 기존 사진: X 클릭 시 삭제 --%>
    <div class="edit-photo-list" id="existing-photo-list">
      <c:forEach var="url" items="${post.photoUrls}">
        <div class="edit-photo-item" data-url="<c:out value='${url}'/>">
          <img src="${contextPath}${url}" alt="첨부 이미지">
          <button type="button" class="edit-photo-remove" title="삭제" aria-label="삭제">&times;</button>
        </div>
      </c:forEach>
    </div>

    <%-- 새로 선택한 이미지 미리보기 --%>
    <div class="edit-photo-list" id="new-photo-preview"></div>

    <label class="write-img-upload" id="photo-upload-btn" style="cursor:pointer">
      <input type="file" id="photo-input" name="photos" accept="image/*" multiple style="display:none">
      <svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
      <span class="upload-label">클릭하여 이미지 추가</span>
      <small>JPG, PNG, GIF</small>
    </label>
  </div>

  <div class="write-btn-row">
    <button type="button" class="btn-cancel-write" onclick="history.back()">취소</button>
    <button type="submit" class="btn-submit-write">수정하기</button>
  </div>
</div>
</form>

<script>
(function () {
  // 2026-08-13 박유정 — 기존 X 삭제 + 새 이미지 미리보기
  var MAX = 5;
  var section = document.getElementById('edit-photo-section');
  if (!section) return;

  var existingList = document.getElementById('existing-photo-list');
  var newPreview = document.getElementById('new-photo-preview');
  var photoInput = document.getElementById('photo-input');
  var uploadBtn = document.getElementById('photo-upload-btn');
  var countEl = document.getElementById('edit-photo-count');
  var selectedNewFiles = [];
  var previewUrls = [];

  function countExisting() {
    return existingList.querySelectorAll('.edit-photo-item:not(.removed)').length;
  }

  function totalCount() {
    return countExisting() + selectedNewFiles.length;
  }

  function updateCount() {
    var total = totalCount();
    countEl.textContent = total > 0 ? total + ' / ' + MAX + '장' : '사진 없음 (최대 ' + MAX + '장)';
    uploadBtn.style.display = total >= MAX ? 'none' : '';
  }

  function syncInputFiles() {
    var dt = new DataTransfer();
    selectedNewFiles.forEach(function (file) {
      dt.items.add(file);
    });
    photoInput.files = dt.files;
  }

  function clearPreviewUrls() {
    previewUrls.forEach(function (url) { URL.revokeObjectURL(url); });
    previewUrls = [];
  }

  function renderNewPreviews() {
    clearPreviewUrls();
    newPreview.innerHTML = '';

    selectedNewFiles.forEach(function (file, index) {
      var item = document.createElement('div');
      item.className = 'edit-photo-item edit-photo-new';

      var img = document.createElement('img');
      var objectUrl = URL.createObjectURL(file);
      previewUrls.push(objectUrl);
      img.src = objectUrl;
      img.alt = file.name;

      var btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'edit-photo-remove';
      btn.title = '삭제';
      btn.setAttribute('aria-label', '삭제');
      btn.innerHTML = '&times;';
      btn.addEventListener('click', function () {
        var idx = Array.prototype.indexOf.call(newPreview.children, item);
        if (idx < 0) return;
        selectedNewFiles.splice(idx, 1);
        syncInputFiles();
        renderNewPreviews();
      });

      item.appendChild(img);
      item.appendChild(btn);
      newPreview.appendChild(item);
    });

    updateCount();
  }

  existingList.addEventListener('click', function (e) {
    var btn = e.target.closest('.edit-photo-remove');
    if (!btn || btn.closest('#new-photo-preview')) return;

    var item = btn.closest('.edit-photo-item');
    if (!item || item.classList.contains('removed')) return;

    var url = item.getAttribute('data-url');
    if (!url) return;

    var hidden = document.createElement('input');
    hidden.type = 'hidden';
    hidden.name = 'removePhotoUrls';
    hidden.value = url;
    section.appendChild(hidden);

    item.classList.add('removed');
    updateCount();
  });

  photoInput.addEventListener('change', function () {
    var allowed = MAX - countExisting();
    if (allowed <= 0) {
      alert('사진은 최대 ' + MAX + '장까지입니다.');
      this.value = '';
      return;
    }

    var incoming = Array.from(this.files || []);
    var skipped = 0;

    incoming.forEach(function (file) {
      if (selectedNewFiles.length >= allowed) {
        skipped++;
        return;
      }
      selectedNewFiles.push(file);
    });

    if (skipped > 0) {
      alert('사진은 최대 ' + MAX + '장까지입니다. (' + allowed + '장만 추가됩니다)');
    }

    // 2026/08/14 장우철 — value='' 를 sync 뒤에 두면 DataTransfer로 넣은 files가 비워져 서버에 사진이 안 감
    this.value = '';
    syncInputFiles();
    renderNewPreviews();
  });

  updateCount();
})();
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
