<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="숙소" />
<c:set var="bizPage" value="profile" />

<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_stay.jsp" %>

<style>
  .pf-wrap{display:flex;flex-direction:column;gap:20px}
  .pf-section{background:#fff;border:1px solid #E4E6ED;border-radius:12px;padding:24px}
  .pf-stitle{font-size:14px;font-weight:800;color:#1A1A2E;margin:0 0 18px;padding-bottom:12px;border-bottom:1px solid #E4E6ED;display:flex;align-items:center;gap:8px}
  .pf-stitle svg{width:16px;height:16px;stroke:#2BAB82;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;flex-shrink:0}
  .pf-grid{display:grid;grid-template-columns:1fr 1fr;gap:14px}
  .pf-group{display:flex;flex-direction:column;gap:6px}
  .pf-group.full{grid-column:1/-1}
  .pf-group label{font-size:13px;font-weight:600;color:#555}
  .pf-group label .req{color:#FF6B6B;margin-left:2px}
  .pf-group input,.pf-group select,.pf-group textarea{
    border:1px solid #E4E6ED;border-radius:8px;padding:10px 14px;font-size:14px;color:#1A1A2E;
    outline:none;font-family:inherit;width:100%;box-sizing:border-box;transition:border-color .2s}
  .pf-group input:focus,.pf-group select:focus,.pf-group textarea:focus{border-color:#2BAB82}
  .pf-group textarea{resize:vertical;min-height:100px;line-height:1.6}
  /* 편의시설 태그 */
  .tag-checks{display:flex;gap:8px;flex-wrap:wrap}
  .tag-check{display:flex;align-items:center;gap:6px;padding:8px 16px;border:1.5px solid #E4E6ED;border-radius:8px;font-size:13px;font-weight:600;color:#555;cursor:pointer;transition:all .2s;user-select:none}
  .tag-check:has(input:checked){background:#F0FAF6;border-color:#2BAB82;color:#1F8464}
  .tag-check input{display:none}
  /* 이미지 */
  .img-area{display:grid;grid-template-columns:repeat(4,1fr);gap:12px}
  .img-box{aspect-ratio:4/3;border:2px dashed #E4E6ED;border-radius:10px;display:flex;flex-direction:column;align-items:center;justify-content:center;cursor:pointer;position:relative;overflow:hidden;color:#999;transition:all .15s}
  .img-box:hover{border-color:#2BAB82;color:#1F8464;background:#F0FAF6}
  .img-box svg{width:24px;height:24px;stroke:currentColor;fill:none;stroke-width:1.5;margin-bottom:4px}
  .img-box small{font-size:11px;color:inherit}
  .img-box.has-img{border:2px solid #E4E6ED}
  .img-box.has-img.main::after{content:'대표';position:absolute;top:8px;left:8px;background:#2BAB82;color:#fff;font-size:10px;font-weight:700;padding:2px 8px;border-radius:20px}
  .img-preview{width:100%;height:100%;object-fit:cover;border-radius:8px}
  .img-box input[type="file"]{display:none}
  .btn-img-del{position:absolute;top:6px;right:6px;width:24px;height:24px;border:none;border-radius:50%;background:rgba(0,0,0,.55);color:#fff;font-size:14px;font-weight:700;cursor:pointer;display:flex;align-items:center;justify-content:center;z-index:1}
  .btn-img-del:hover{background:rgba(220,38,38,.85)}
  .img-box.deleted{opacity:.3;pointer-events:none}
  /* 버튼 */
  .pf-btn-row{display:flex;justify-content:flex-end;gap:10px;margin-top:4px}
  .btn-cancel{padding:11px 24px;border:1px solid #E4E6ED;border-radius:8px;background:#fff;color:#555;font-size:14px;font-weight:600;cursor:pointer}
  .btn-submit{padding:11px 28px;border:none;border-radius:8px;background:#2BAB82;color:#fff;font-size:14px;font-weight:700;cursor:pointer;transition:background .15s}
  .btn-submit:hover{background:#1F8464}
  /* 토스트 */
  .pf-toast{position:fixed;bottom:-60px;left:50%;transform:translateX(-50%);background:#1A1A2E;color:#fff;padding:12px 24px;border-radius:10px;font-size:14px;font-weight:600;display:flex;align-items:center;gap:8px;transition:bottom .35s;z-index:999}
  .pf-toast.on{bottom:32px}
  .pf-toast svg{width:18px;height:18px;stroke:#2BAB82;fill:none;stroke-width:2.5}
  @media(max-width:768px){
    .pf-grid{grid-template-columns:1fr}
    .img-area{grid-template-columns:repeat(2,1fr)}
    .pf-btn-row{flex-direction:column}
    .btn-cancel,.btn-submit{width:100%;text-align:center}
  }
</style>

<main class="biz-main">
  <div class="biz-page-head">
    <h1 class="biz-page-title">숙소 운영정보</h1>
    <p class="biz-page-desc">고객에게 노출되는 숙소 정보를 관리합니다.</p>
  </div>

  <form name="stayProfileForm" method="post"
        action="${contextPath}/biz/stay/profile" enctype="multipart/form-data">
    <!--HYJ 26.08.05-->
    <input type="hidden" name="_csrf" value="${_csrf}">
    
  <div class="pf-wrap">

    <!-- ─── 1. 입퇴실 시간 ─── -->
    <div class="pf-section">
      <div class="pf-stitle">
        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
        입퇴실 시간
      </div>
      <div class="pf-grid">
        <div class="pf-group">
          <label>체크인 <span class="req">*</span></label>
          <select name="checkIn">
            <c:forEach var="h" items="${'13:00,14:00,15:00,16:00,17:00'.split(',')}">
              <option value="${h}" ${stay.checkIn == h || (empty stay.checkIn && h == '15:00') ? 'selected' : ''}>${h}</option>
            </c:forEach>
          </select>
        </div>
        <div class="pf-group">
          <label>체크아웃 <span class="req">*</span></label>
          <select name="checkOut">
            <c:forEach var="h" items="${'09:00,10:00,11:00,12:00'.split(',')}">
              <option value="${h}" ${stay.checkOut == h || (empty stay.checkOut && h == '11:00') ? 'selected' : ''}>${h}</option>
            </c:forEach>
          </select>
        </div>
      </div>
    </div>

    <!-- ─── 2. 숙소 소개 ─── -->
    <div class="pf-section">
      <div class="pf-stitle">
        <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
        숙소 소개
      </div>
      <div class="pf-group full">
        <label>소개글</label>
        <textarea name="description" placeholder="숙소를 소개하는 문구를 입력하세요.">${stay.description}</textarea>
      </div>
    </div>

    <!-- ─── 3. 반려동물 정책 ─── -->
    <div class="pf-section">
      <div class="pf-stitle">
        <svg viewBox="0 0 24 24"><circle cx="11" cy="4" r="2"/><circle cx="18" cy="8" r="2"/><circle cx="20" cy="16" r="2"/><circle cx="4" cy="8" r="2"/><path d="M12 10c-1.5 2-3 3.5-3 5a3 3 0 006 0c0-1.5-1.5-3-3-5z"/></svg>
        반려동물 정책
      </div>
      <div class="pf-grid">
        <div class="pf-group full">
          <label>반려동물 이용 정책</label>
          <textarea name="petPolicy" placeholder="입실 가능 반려동물 크기, 종류, 동반 조건 등을 입력하세요.">${stay.petPolicy}</textarea>
        </div>
        <div class="pf-group full">
          <label>반려동물 추가 비용 (원 / 추가 1마리·1박)</label>
          <input type="number" name="petFee" min="0" step="1000" value="${stay.petFee != null ? stay.petFee : 0}"
                 placeholder="0이면 추가비 없음. 예: 10000">
          <p style="margin:6px 0 0;font-size:12px;color:#64748B;line-height:1.5">
            1마리는 객실요금만, 2마리부터 (마리수−1) × 금액 × 박수가 추가됩니다. 숫자만 입력하세요.
          </p>
        </div>
      </div>
    </div>

    <!-- ─── 4. 환불 정책 ─── -->
    <div class="pf-section">
      <div class="pf-stitle">
        <svg viewBox="0 0 24 24"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 000 7h5a3.5 3.5 0 010 7H6"/></svg>
        환불 정책
      </div>
      <div class="pf-group full">
        <label>환불 규정 <span style="font-weight:500;color:#64748B">(플랫폼 고정 · 수정 불가)</span></label>
        <%-- 2026/08/11 장우철 — StayCancelFeeCalculator 고정 문구, name 없음 → POST 무시 --%>
        <div style="border:1px solid var(--border,#E2E8E4);border-radius:8px;padding:14px 16px;background:#F8FAFC;font-size:13px;line-height:1.7;color:#334155;white-space:pre-line"><c:out value="${stay.refundPolicy}"/></div>
      </div>
    </div>

    <!-- ─── 5. 편의시설 ─── -->
    <div class="pf-section">
      <div class="pf-stitle">
        <svg viewBox="0 0 24 24"><polyline points="9 11 12 14 22 4"/><path d="M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11"/></svg>
        편의시설
      </div>
      <div class="tag-checks">
        <label class="tag-check"><input type="checkbox" name="facilities" value="PETYARD"      ${fn:contains(stay.facilities,'PETYARD') ? 'checked':''}>애견 놀이터</label>
        <label class="tag-check"><input type="checkbox" name="facilities" value="PETPOOL"   ${fn:contains(stay.facilities,'PETPOOL') ? 'checked':''}>애견 수영장</label>
        <label class="tag-check"><input type="checkbox" name="facilities" value="PETAMENITY"    ${fn:contains(stay.facilities,'PETAMENITY') ? 'checked':''}>펫 어메니티 제공</label>
        <label class="tag-check"><input type="checkbox" name="facilities" value="AGILITY"      ${fn:contains(stay.facilities,'AGILITY') ? 'checked':''}>어질리티체험</label>
        <label class="tag-check"><input type="checkbox" name="facilities" value="LARGEPET"      ${fn:contains(stay.facilities,'LARGEPET') ? 'checked':''}>대형견 가능</label>
      </div>
    </div>

    <!-- ─── 6. 숙소 이미지 ─── -->
    <div class="pf-section">
      <div class="pf-stitle">
        <svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
        숙소 이미지
      </div>
      <p style="font-size:13px;color:#999;margin:0 0 14px">첫 번째 이미지가 대표 이미지로 사용됩니다. (최대 4장)</p>

      <div id="deleteFileArea"></div>

      <div class="img-area">
        <%-- 기존 이미지 --%>
        <c:forEach var="img" items="${imgList}" varStatus="st">
          <div class="img-box has-img ${st.index == 0 ? 'main' : ''}" id="existing-${img.fileId}">
            <img class="img-preview" src="${contextPath}/upload/${img.fileUrl}">
            <button type="button" class="btn-img-del"
                onclick="event.stopPropagation(); markDelete(${img.fileId}, this)">&times;</button>
          </div>
        </c:forEach>
        <%-- 빈 슬롯 --%>
        <c:forEach begin="1" end="${4 - fn:length(imgList)}">
          <div class="img-box" onclick="this.querySelector('input').click()">
            <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            <small>추가</small>
            <input type="file" name="imgList" accept=".jpg,.jpeg,.png" onchange="previewImg(this)">
          </div>
        </c:forEach>
      </div>
    </div>

    <!-- 하단 버튼 -->
    <div class="pf-btn-row">
      <button type="button" class="btn-cancel" onclick="location.href='${contextPath}/biz/stay'">취소</button>
      <button type="submit" class="btn-submit">저장하기</button>
    </div>

  </div>
  </form>
</main>

<%-- 저장 완료 토스트 --%>
<c:if test="${not empty msg}">
  <div class="pf-toast" id="saveToast">
    <svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>
    ${msg}
  </div>
  <script>
    window.addEventListener('DOMContentLoaded', function() {
      var t = document.getElementById('saveToast');
      if (t) { t.classList.add('on'); setTimeout(function(){ t.classList.remove('on'); }, 2500); }
    });
  </script>
</c:if>

<script>
  /* 새 이미지 미리보기 */
  function previewImg(input) {
    if (!input.files || !input.files[0]) return;
    var reader = new FileReader();
    reader.onload = function(e) {
      var box = input.closest('.img-box');
      box.classList.add('has-img');
      var svg   = box.querySelector('svg');
      var small = box.querySelector('small');
      if (svg)   svg.style.display   = 'none';
      if (small) small.style.display = 'none';
      // 기존 미리보기 제거
      var old = box.querySelector('.img-preview');
      if (old) old.remove();
      // 새 미리보기
      var img = document.createElement('img');
      img.src = e.target.result;
      img.className = 'img-preview';
      box.appendChild(img);
      // 삭제 버튼
      if (!box.querySelector('.btn-img-del')) {
        var del = document.createElement('button');
        del.type = 'button';
        del.className = 'btn-img-del';
        del.innerHTML = '&times;';
        del.onclick = function(ev) { ev.stopPropagation(); resetUploadBox(box); };
        box.appendChild(del);
      }
    };
    reader.readAsDataURL(input.files[0]);
  }

  /* 기존 이미지 삭제 마킹 */
  function markDelete(fileId, btn) {
    var box = btn.closest('.img-box');
    box.classList.add('deleted');
    var h = document.createElement('input');
    h.type  = 'hidden';
    h.name  = 'deleteFileIds';
    h.value = fileId;
    document.getElementById('deleteFileArea').appendChild(h);
  }

  /* 새 이미지 업로드 취소 */
  function resetUploadBox(box) {
    box.classList.remove('has-img');
    var p = box.querySelector('.img-preview');  if (p) p.remove();
    var d = box.querySelector('.btn-img-del');  if (d) d.remove();
    var f = box.querySelector('input[type="file"]'); if (f) f.value = '';
    var svg   = box.querySelector('svg');   if (svg)   svg.style.display = '';
    var small = box.querySelector('small'); if (small) small.style.display = '';
  }
</script>

<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>
