<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
  역할: 분실/보호 신고 작성 (give/report/write)

  - 박유정 / 2026-07-06~07

  [등록 화면 흐름]
  1. 로그인 후 이 페이지 진입
  2. 폼 작성 + 사진 최대 5장 (name="photos", multipart/form-data)
  3. POST /give/report/write → Service → TB_POST + TB_FILE + C:/upload/ 저장
--%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId"      value="give" />
<%@ include file="/WEB-INF/views/common/header.jsp" %>
<style>
.rw-wrap{max-width:720px;margin:32px auto 80px;padding:0 20px}
.rw-title{font-size:22px;font-weight:800;color:var(--text-main);margin-bottom:6px}
.rw-desc{font-size:14px;color:var(--text-muted);margin-bottom:28px}
.rw-section{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);padding:22px;margin-bottom:18px}
.rw-section-title{font-size:14px;font-weight:800;color:var(--text-main);margin:0 0 16px;padding-bottom:12px;border-bottom:1px solid var(--border);display:flex;align-items:center;gap:8px}
.rw-section-title svg{width:15px;height:15px;stroke:var(--primary);fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}
.rw-grid{display:grid;grid-template-columns:1fr 1fr;gap:13px}
.rw-group{display:flex;flex-direction:column;gap:5px}
.rw-group.full{grid-column:1/-1}
.rw-group label{font-size:13px;font-weight:600;color:var(--text-sub)}
.rw-group label .req{color:var(--accent);margin-left:2px}
.rw-group input,.rw-group select,.rw-group textarea{border:1px solid var(--border);border-radius:var(--radius-sm);padding:10px 13px;font-size:14px;color:var(--text-main);outline:none;font-family:inherit;width:100%;box-sizing:border-box;transition:border-color .2s}
.rw-group input:focus,.rw-group select:focus,.rw-group textarea:focus{border-color:var(--primary)}
.rw-group textarea{min-height:100px;resize:vertical;line-height:1.6}

/* 특징 태그 */
.feature-tags{display:flex;flex-wrap:wrap;gap:7px;margin-top:8px}
.ftag{padding:6px 14px;border:1px solid var(--border);border-radius:50px;font-size:12px;font-weight:600;color:var(--text-sub);cursor:pointer;transition:var(--transition)}
.ftag:hover,.ftag.on{border-color:var(--primary);background:var(--primary-light);color:var(--primary-dark)}

/* 지도 영역 */
.map-area{border:1px solid var(--border);border-radius:var(--radius-sm);overflow:hidden;background:var(--bg-page);height:200px;display:flex;align-items:center;justify-content:center;color:var(--text-muted);flex-direction:column;gap:10px;cursor:pointer;position:relative}
.map-area img{width:100%;height:100%;object-fit:cover;display:block}
.map-pin-overlay{position:absolute;bottom:12px;left:50%;transform:translateX(-50%);background:rgba(0,0,0,.6);color:#fff;font-size:12px;padding:5px 14px;border-radius:20px}

/* 사진 업로드 */
.photo-upload-grid{display:grid;grid-template-columns:repeat(5,1fr);gap:10px}
.photo-slot{position:relative;aspect-ratio:1/1;border-radius:var(--radius-sm);overflow:hidden;background:var(--bg-page)}
.photo-slot img{width:100%;height:100%;object-fit:cover;display:block}
.photo-slot-remove{position:absolute;top:4px;right:4px;width:22px;height:22px;border:none;border-radius:50%;background:rgba(0,0,0,.55);color:#fff;font-size:14px;line-height:1;cursor:pointer;padding:0}
.photo-slot-remove:hover{background:rgba(220,38,38,.85)}
.photo-add-box{aspect-ratio:1/1;border:2px dashed var(--border);border-radius:var(--radius-sm);display:flex;flex-direction:column;align-items:center;justify-content:center;gap:6px;cursor:pointer;transition:var(--transition);color:#999;font-size:11px;min-height:0;text-align:center;padding:4px}
.photo-add-box:hover{border-color:var(--primary);color:var(--primary);background:var(--primary-light)}
.photo-add-box svg{width:22px;height:22px;stroke:currentColor;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round}
.photo-count{font-size:12px;color:var(--text-muted);margin-top:8px}
.rw-error{background:#FEF2F2;border:1px solid #FECACA;color:#B91C1C;padding:12px 14px;border-radius:var(--radius-sm);font-size:13px;margin-bottom:16px}

.rw-btn-row{display:flex;justify-content:flex-end;gap:10px}
.btn-cancel-rw{padding:12px 24px;border:1px solid var(--border);border-radius:var(--radius-sm);background:#fff;color:var(--text-sub);font-size:14px;font-weight:600;cursor:pointer}
.btn-submit-rw{padding:12px 28px;border:none;border-radius:var(--radius-sm);background:var(--primary);color:#fff;font-size:14px;font-weight:700;cursor:pointer;transition:var(--transition)}
.btn-submit-rw:hover{background:var(--primary-dark)}
</style>

<div class="rw-wrap">
  <h1 class="rw-title">유기동물 발견 신고</h1>
  <p class="rw-desc">발견한 동물의 정보를 등록해 주인을 찾거나 보호소 연계를 도와주세요.</p>

  <c:if test="${param.error eq 'login'}">
    <div class="rw-error">분실·보호 신고는 <strong>로그인한 회원만</strong> 등록할 수 있습니다. <a href="${contextPath}/login?redirect=/give/report/write" style="color:#B91C1C;text-decoration:underline">로그인</a> 또는 <a href="${contextPath}/join" style="color:#B91C1C;text-decoration:underline">회원가입</a> 후 다시 시도해 주세요.</div>
  </c:if>
  <c:if test="${param.error eq 'member'}">
    <div class="rw-error">로그인은 되어 있지만 <strong>DB에 회원 정보가 없습니다.</strong> 테스트 로그인이 아닌, <strong>회원가입으로 만든 계정</strong>으로 로그인했는지 확인해 주세요.</div>
  </c:if>
  <c:if test="${param.error eq 'save'}">
    <div class="rw-error">등록에 실패했습니다. 잠시 후 다시 시도해 주세요.</div>
  </c:if>

  <form method="post" action="${contextPath}/give/report/write" enctype="multipart/form-data" onsubmit="return collectFeatureTags()">
    <!--HYJ 26.08.05-->
    <input type="hidden" name="_csrf" value="${_csrf}">
    
  <input type="hidden" name="reportKind" value="FOUND">
  <input type="hidden" name="featureTags" id="featureTags">
  <%-- 2026-07-29 박유정 — 주소 검색·지도 클릭 시 갱신, POST 시 TB_POST LOST_LAT/LNG 저장 --%>
  <input type="hidden" name="lostLat" id="lostLat" value="37.5665">
  <input type="hidden" name="lostLng" id="lostLng" value="126.9780">
  <!-- 기존 섹션들 (동물정보, 위치, 사진, 연락처) -->

  <%-- 기본 정보 --%>
  <div class="rw-section">
    <div class="rw-section-title">
      <svg viewBox="0 0 24 24"><circle cx="4.5" cy="9.5" r="2"/><circle cx="9" cy="5.5" r="2"/><circle cx="15" cy="5.5" r="2"/><circle cx="19.5" cy="9.5" r="2"/><path d="M12 13c-3.87 0-7 1.79-7 4v1h14v-1c0-2.21-3.13-4-7-4z"/></svg>
      동물 기본 정보
    </div>
    <div class="rw-grid">
      <div class="rw-group">
        <label>동물 종류 <span class="req">*</span></label>
        <select name="lostSpecies" required>
          <option value="">선택하세요</option>
          <option value="DOG">강아지</option>
          <option value="CAT">고양이</option>
          <option value="ETC">기타</option>
        </select>
      </div>
      <div class="rw-group">
        <label>추정 크기</label>
        <select name="animalSize">
          <option value="">선택하세요</option>
          <option value="소형">소형 (5kg 미만)</option>
          <option value="중형">중형 (5~15kg)</option>
          <option value="대형">대형 (15kg 이상)</option>
        </select>
      </div>
      <div class="rw-group">
        <label>털 색상</label>
        <input type="text" name="furColor" placeholder="예) 황갈색, 검은색, 흰색">
      </div>
      <div class="rw-group">
        <label>성별 (추정)</label>
        <select name="gender">
          <option value="UNKNOWN">모름</option>
          <option value="M">수컷</option>
          <option value="F">암컷</option>
        </select>
      </div>
    </div>
    <div class="rw-group" style="margin-top:13px">
      <label>외형 특징 (해당하는 항목 선택)</label>
      <div class="feature-tags">
        <span class="ftag" onclick="this.classList.toggle('on')">목줄 있음</span>
        <span class="ftag" onclick="this.classList.toggle('on')">목줄 없음</span>
        <span class="ftag" onclick="this.classList.toggle('on')">목걸이 있음</span>
        <span class="ftag" onclick="this.classList.toggle('on')">부상 있음</span>
        <span class="ftag" onclick="this.classList.toggle('on')">임신/수유 중</span>
        <span class="ftag" onclick="this.classList.toggle('on')">매우 야위었음</span>
        <span class="ftag" onclick="this.classList.toggle('on')">겁을 많이 먹음</span>
        <span class="ftag" onclick="this.classList.toggle('on')">사람에게 친근함</span>
      </div>
    </div>
  </div>

  <%-- 발견 위치 --%>
  <div class="rw-section">
    <div class="rw-section-title">
      <svg viewBox="0 0 24 24"><path d="M21 10c0 7-9 13-9 13S3 17 3 10a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/></svg>
      발견 위치
    </div>
    <div class="rw-grid" style="margin-bottom:13px">
      <div class="rw-group">
        <label>발견 일시 <span class="req">*</span></label>
        <input type="datetime-local" name="foundAt" required>
      </div>
      <div class="rw-group">
        <label>주소 입력</label>
        <div style="display:flex;gap:8px">
          <input type="text" id="address" name="address" placeholder="주소 직접 입력" style="flex:1">
          <button type="button" id="btnSearchAddr" style="min-width:72px;padding:0 14px;border:1px solid var(--border);border-radius:var(--radius-sm);background:#fff;cursor:pointer">검색</button>
        </div>
      </div>
    </div>
    <%-- 카카오맵 자리 --%>
  <%-- 2026-07-29 박유정 — 발견 위치 카카오맵 (Controller에서 kakaoJsApiKey 전달) --%>
  <div id="kakao-map" style="width:100%;height:220px;border-radius:8px;border:1px solid var(--border)"></div>
  <%@ include file="/WEB-INF/views/common/kakaomap.jsp" %>
  </div>

  <%-- 사진 업로드 --%>
  <div class="rw-section">
    <div class="rw-section-title">
      <svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
      발견 사진 (최대 5장)
    </div>
    <input type="file" id="photoInput" name="photos" accept="image/*" multiple style="display:none">
    <div class="photo-upload-grid" id="photoGrid"></div>
    <p class="photo-count" id="photoCount">0 / 5장</p>
  </div>

  <%-- 상세 설명 & 연락처 --%>
  <div class="rw-section">
    <div class="rw-section-title">
      <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
      상세 설명 및 연락처
    </div>
    <div class="rw-grid">
      <div class="rw-group full">
        <label>상황 설명 <span class="req">*</span></label>
        <textarea name="description" required placeholder="발견 당시 상황, 동물의 상태, 현재 위치 등을 자세히 적어주세요."></textarea>
      </div>
      <div class="rw-group">
        <label>신고자 연락처 <span class="req">*</span></label>
        <input type="tel" name="lostContact" required placeholder="010-0000-0000">
      </div>
      <div class="rw-group">
        <label>현재 임시 보호 여부</label>
        <select name="tempCare">
          <option value="N">아니요 (제보만)</option>
          <option value="Y">예 (임시 보호 중)</option>
        </select>
      </div>
    </div>
  </div>

  <div class="rw-btn-row">
    <button type="button" class="btn-cancel-rw" onclick="history.back()">취소</button>
    <button type="submit" class="btn-submit-rw">신고 등록하기</button>
  </div>
  </form>
</div>

<script>
function collectFeatureTags() {
  var tags = [];
  document.querySelectorAll('.ftag.on').forEach(function(el) {
    tags.push(el.textContent.trim());
  });
  document.getElementById('featureTags').value = tags.join(',');
  return true;
}

// 2026-07-29 박유정 — 다음 주소 검색 → Kakao Geocoder → 지도 중심·마커·lostLat/lostLng hidden 갱신
document.getElementById('btnSearchAddr').addEventListener('click', function () {
  if (typeof daum === 'undefined' || !daum.Postcode) {
    alert('주소 API를 불러오지 못했습니다.');
    return;
  }
  new daum.Postcode({
    oncomplete: function (data) {
      var addr = data.roadAddress || data.jibunAddress;
  document.getElementById('address').value = addr;

  if (!window.kakaoMap) {
  alert('지도를 불러오는 중입니다. 잠시 후 다시 시도해 주세요.');
  return;
  }
  var geocoder = new kakao.maps.services.Geocoder();
  geocoder.addressSearch(addr, function (result, status) {
    if (status !== kakao.maps.services.Status.OK) {
      alert('주소를 지도에서 찾지 못했습니다. 지도를 클릭해 위치를 지정해 주세요.');
      return;
    }
    var lat = parseFloat(result[0].y);
    var lng = parseFloat(result[0].x);
    var pos = new kakao.maps.LatLng(lat, lng);

    window.kakaoMap.setCenter(pos);
    window.kakaoMap.setLevel(3);

    if (!window.reportMarker) {
      window.reportMarker = new kakao.maps.Marker({ position: pos, map: window.kakaoMap });
    } else {
      window.reportMarker.setPosition(pos);
    }

    document.getElementById('lostLat').value = lat;
    document.getElementById('lostLng').value = lng;
  });
}
  }).open();
});

(function () {
  var MAX_PHOTOS = 5;
  var selectedFiles = [];
  var photoInput = document.getElementById('photoInput');
  var photoGrid = document.getElementById('photoGrid');
  var photoCount = document.getElementById('photoCount');

  function syncPhotoInput() {
    var dt = new DataTransfer();
    selectedFiles.forEach(function (file) {
      dt.items.add(file);
    });
    photoInput.files = dt.files;
    photoCount.textContent = selectedFiles.length + ' / ' + MAX_PHOTOS + '장';
  }

  function openPhotoPicker() {
    if (selectedFiles.length >= MAX_PHOTOS) {
      alert('사진은 최대 ' + MAX_PHOTOS + '장까지 등록할 수 있습니다.');
      return;
    }
    photoInput.click();
  }

  function removePhoto(index) {
    selectedFiles.splice(index, 1);
    syncPhotoInput();
    renderPhotoGrid();
  }

  function renderPhotoGrid() {
    photoGrid.innerHTML = '';

    selectedFiles.forEach(function (file, idx) {
      var slot = document.createElement('div');
      slot.className = 'photo-slot';

      var img = document.createElement('img');
      img.alt = '미리보기 ' + (idx + 1);

      var reader = new FileReader();
      reader.onload = function (ev) {
        img.src = ev.target.result;
      };
      reader.readAsDataURL(file);

      var removeBtn = document.createElement('button');
      removeBtn.type = 'button';
      removeBtn.className = 'photo-slot-remove';
      removeBtn.setAttribute('aria-label', '사진 삭제');
      removeBtn.textContent = '\u00d7';
      removeBtn.addEventListener('click', function () {
        removePhoto(idx);
      });

      slot.appendChild(img);
      slot.appendChild(removeBtn);
      photoGrid.appendChild(slot);
    });

    if (selectedFiles.length < MAX_PHOTOS) {
      var addBox = document.createElement('div');
      addBox.className = 'photo-add-box';
      addBox.innerHTML = '<svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg><span>사진 추가</span>';
      addBox.addEventListener('click', openPhotoPicker);
      photoGrid.appendChild(addBox);
    }
  }

  photoInput.addEventListener('change', function (e) {
    var picked = Array.prototype.slice.call(e.target.files || []);
    if (picked.length === 0) return;

    var remain = MAX_PHOTOS - selectedFiles.length;
    if (remain <= 0) {
      alert('사진은 최대 ' + MAX_PHOTOS + '장까지 등록할 수 있습니다.');
      syncPhotoInput();
      return;
    }

    var added = picked.slice(0, remain);
    selectedFiles = selectedFiles.concat(added);

    if (picked.length > remain) {
      alert('사진은 최대 ' + MAX_PHOTOS + '장까지입니다. ' + remain + '장만 추가되었습니다.');
    }

    syncPhotoInput();
    renderPhotoGrid();
  });

  renderPhotoGrid();
})();
</script>

<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
