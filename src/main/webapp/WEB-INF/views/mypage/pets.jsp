<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="mypage" />
<c:set var="sec" value="pets" />

<%@ include file="/WEB-INF/views/common/header.jsp" %>
<link rel="stylesheet" href="${contextPath}/resources/css/mypage.css">

<div class="mypage-wrap">
<%@ include file="/WEB-INF/views/mypage/sidebar.jsp" %>
<div class="mypage-content">

<%-- 2026/07/11 장우철 — 반려동물 목록 DB 연동 (더미 카드 제거) --%>
<div class="mp-section active">
    <div class="pets-header">
        <div>
            <h2 class="mp-title" style="margin-bottom:4px">반려동물 관리</h2>
            <p class="mp-desc" style="margin-bottom:0">등록된 반려동물을 관리하고 새로 추가하세요.</p>
        </div>
    </div>
    <div class="pets-grid">
        <c:forEach var="p" items="${petList}">
            <div class="pet-card">
                <div class="pet-thumb-wrap">
                    <c:choose>
                        <c:when test="${not empty p.photoUrl}">
                            <%-- 2026/08/11 장우철 — /upload/... · 상대경로 · 외부 URL 분기 --%>
                            <c:choose>
                                <c:when test="${fn:startsWith(p.photoUrl, 'http')}">
                                    <c:set var="petThumbSrc" value="${p.photoUrl}" />
                                </c:when>
                                <c:when test="${fn:startsWith(p.photoUrl, '/')}">
                                    <c:set var="petThumbSrc" value="${contextPath}${p.photoUrl}" />
                                </c:when>
                                <c:otherwise>
                                    <c:set var="petThumbSrc" value="${contextPath}/upload/${p.photoUrl}" />
                                </c:otherwise>
                            </c:choose>
                            <img class="pet-thumb" src="${petThumbSrc}" alt="<c:out value='${p.petName}'/>"
                                 onerror="this.src='https://placehold.co/300x225/EAF7F2/2BAB82?text=반려동물'">
                        </c:when>
                        <c:otherwise>
                            <img class="pet-thumb"
                                 src="https://placehold.co/300x225/EAF7F2/2BAB82?text=${fn:escapeXml(p.petName)}"
                                 alt="<c:out value='${p.petName}'/>">
                        </c:otherwise>
                    </c:choose>
                    <span class="pet-species-badge">
                        <c:choose>
                            <c:when test="${p.species eq 'DOG'}">강아지</c:when>
                            <c:when test="${p.species eq 'CAT'}">고양이</c:when>
                            <c:otherwise>기타</c:otherwise>
                        </c:choose>
                    </span>
                </div>
                <div class="pet-body">
                    <div class="p-name">
                        <c:out value="${p.petName}"/>
                        <c:if test="${p.isRepresent eq 'Y'}"><span style="font-size:12px;color:var(--primary);font-weight:700"> · 대표</span></c:if>
                    </div>
                    <div class="p-meta">
                        <c:out value="${p.breed}"/>
                        ·
                        <c:choose>
                            <c:when test="${p.gender eq 'M'}">수컷</c:when>
                            <c:when test="${p.gender eq 'F'}">암컷</c:when>
                            <c:otherwise>-</c:otherwise>
                        </c:choose>
                        <br>
                        <c:choose>
                            <c:when test="${not empty p.birthDate}">
                                생년월일: ${p.birthDate}
                                <c:if test="${not empty p.age}"> (${p.age}살)</c:if>
                            </c:when>
                            <c:when test="${not empty p.age}">나이: ${p.age}살</c:when>
                            <c:otherwise>생년월일: -</c:otherwise>
                        </c:choose>
                        <br>
                        체중:
                        <c:choose>
                            <c:when test="${not empty p.weight}"><fmt:formatNumber value="${p.weight}" pattern="#0.#"/>kg</c:when>
                            <c:otherwise>-</c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <div class="pet-footer">
                    <button type="button" class="btn-sm" onclick="openPetModal(${p.petId})">수정</button>
                    <button type="button" class="btn-sm danger" onclick="deletePet(${p.petId}, '<c:out value="${p.petName}"/>')">삭제</button>
                </div>
            </div>
        </c:forEach>

        <a href="#" class="pet-add-card" onclick="openPetModal(null);return false;">
            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="16"/><line x1="8" y1="12" x2="16" y2="12"/></svg>
            <span>반려동물 추가하기</span>
        </a>
    </div>
</div>

</div><%-- /mypage-content --%>
</div><%-- /mypage-wrap --%>

<%-- ── 반려동물 등록/수정 모달 ── --%>
<style>
  .pet-modal-bg {
      display: none; position: fixed; inset: 0;
      background: rgba(0,0,0,.5); z-index: 1000;
      align-items: center; justify-content: center;
  }
  .pet-modal-bg.open { display: flex; }
  .pet-modal {
      background: #fff; border-radius: 16px;
      width: 100%; max-width: 520px; max-height: 90vh;
      overflow-y: auto; box-shadow: 0 20px 60px rgba(0,0,0,.2);
      animation: slideUp .25s ease;
  }
  @keyframes slideUp { from { transform: translateY(30px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
  .pm-header {
      display: flex; justify-content: space-between; align-items: center;
      padding: 20px 22px 16px; border-bottom: 1px solid var(--border);
      position: sticky; top: 0; background: #fff; z-index: 1;
  }
  .pm-header h3 { font-size: 18px; font-weight: 800; color: var(--text-main); margin: 0; }
  .pm-close {
      width: 32px; height: 32px; border: none; background: var(--bg-page);
      border-radius: 50%; cursor: pointer; display: flex; align-items: center; justify-content: center;
      font-size: 18px; color: var(--text-muted); transition: var(--transition);
  }
  .pm-close:hover { background: var(--border); }
  .pm-body { padding: 22px; }

  .pm-photo-wrap { display: flex; flex-direction: column; align-items: center; gap: 10px; margin-bottom: 22px; }
  .pm-photo-circle {
      width: 100px; height: 100px; border-radius: 50%;
      border: 3px dashed var(--border); background: var(--bg-page);
      display: flex; align-items: center; justify-content: center;
      cursor: pointer; overflow: hidden; position: relative; transition: var(--transition);
  }
  .pm-photo-circle:hover { border-color: var(--primary); background: var(--primary-light); }
  .pm-photo-circle img { width: 100%; height: 100%; object-fit: cover; display: none; position: absolute; inset: 0; }
  .pm-photo-circle.has-img img { display: block; }
  .pm-photo-circle.has-img svg { display: none; }
  .pm-photo-circle svg { width: 28px; height: 28px; stroke: var(--text-muted); fill: none; stroke-width: 1.6; stroke-linecap: round; stroke-linejoin: round; }
  .pm-photo-hint { font-size: 12px; color: var(--text-muted); }

  .pm-form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
  .pm-group { display: flex; flex-direction: column; gap: 5px; }
  .pm-group.full { grid-column: 1 / -1; }
  .pm-group label { font-size: 13px; font-weight: 600; color: var(--text-sub); }
  .pm-group label .req { color: var(--accent); margin-left: 2px; }
  .pm-group input, .pm-group select {
      border: 1px solid var(--border); border-radius: var(--radius-sm);
      padding: 10px 13px; font-size: 14px; color: var(--text-main);
      outline: none; font-family: inherit; width: 100%; box-sizing: border-box;
      transition: border-color .2s;
  }
  .pm-group input:focus, .pm-group select:focus { border-color: var(--primary); }
  .pm-group .pm-hint { font-size: 11px; color: var(--text-muted); margin-top: 3px; }

  .pm-neuter-row { display: flex; align-items: center; gap: 12px; }
  .pm-neuter-btn {
      flex: 1; padding: 10px; border: 1px solid var(--border); border-radius: var(--radius-sm);
      background: #fff; color: var(--text-muted); font-size: 14px; font-weight: 600;
      cursor: pointer; transition: var(--transition); display: flex; align-items: center; justify-content: center; gap: 6px;
  }
  .pm-neuter-btn svg { width: 14px; height: 14px; stroke: currentColor; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
  .pm-neuter-btn.on { border-color: var(--primary); background: var(--primary-light); color: var(--primary-dark); }

  .pm-trait-wrap { display: flex; flex-wrap: wrap; gap: 6px; }
  .pm-trait {
      padding: 6px 13px; border: 1px solid var(--border); border-radius: 50px;
      font-size: 12px; color: var(--text-sub); cursor: pointer; transition: var(--transition); background: #fff;
  }
  .pm-trait:hover, .pm-trait.on { border-color: var(--primary); background: var(--primary-light); color: var(--primary-dark); font-weight: 600; }

  .pm-footer {
      display: flex; gap: 10px; padding: 16px 22px;
      border-top: 1px solid var(--border);
      position: sticky; bottom: 0; background: #fff;
  }
  .btn-pm-cancel { flex: 1; padding: 12px; border: 1px solid var(--border); border-radius: var(--radius-sm); background: #fff; color: var(--text-sub); font-size: 14px; font-weight: 700; cursor: pointer; }
  .btn-pm-save   { flex: 2; padding: 12px; border: none; border-radius: var(--radius-sm); background: var(--primary); color: #fff; font-size: 14px; font-weight: 800; cursor: pointer; transition: var(--transition); }
  .btn-pm-save:hover { background: var(--primary-dark); }
  .btn-pm-save:disabled { opacity: .6; cursor: not-allowed; }
</style>

<div class="pet-modal-bg" id="petModalBg" onclick="if(event.target===this) closeModal()">
  <div class="pet-modal">
    <div class="pm-header">
      <h3 id="pm-title">반려동물 등록</h3>
      <button type="button" class="pm-close" onclick="closeModal()">×</button>
    </div>
    <div class="pm-body">
      <div class="pm-photo-wrap">
        <%-- 2026/08/11 장우철 — 대표사진 클릭 업로드 (추후 연동 제거) --%>
        <div class="pm-photo-circle" id="pm-photo-circle" onclick="document.getElementById('pm-photo').click()">
          <img id="pm-preview" src="" alt="미리보기">
          <svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
        </div>
        <input type="file" id="pm-photo" name="petPhoto" accept="image/jpeg,image/png,image/webp,image/gif" style="display:none">
        <span class="pm-photo-hint">클릭하여 사진 등록 (선택 · JPG/PNG 최대 5MB)</span>
      </div>

      <input type="hidden" id="pm-petId" value="">

      <div class="pm-form-grid">
        <div class="pm-group full">
          <label>이름 <span class="req">*</span></label>
          <input type="text" id="pm-name" placeholder="예) 몽이" maxlength="30">
        </div>
        <div class="pm-group">
          <label>종류 <span class="req">*</span></label>
          <select id="pm-kind" onchange="updateBreed()">
            <option value="">선택하세요</option>
            <option value="dog">강아지</option>
            <option value="cat">고양이</option>
            <option value="etc">기타</option>
          </select>
        </div>
        <div class="pm-group">
          <label>품종 <span class="req">*</span></label>
          <select id="pm-breed">
            <option value="">종류를 먼저 선택하세요</option>
          </select>
        </div>
        <div class="pm-group">
          <label>성별 <span class="req">*</span></label>
          <select id="pm-gender">
            <option value="">선택</option>
            <option value="M">수컷</option>
            <option value="F">암컷</option>
          </select>
        </div>
        <div class="pm-group">
          <label>생년월일</label>
          <input type="date" id="pm-birth">
          <span class="pm-hint">입력 시 나이가 자동 계산됩니다.</span>
        </div>
        <div class="pm-group">
          <label>체중 (kg)</label>
          <input type="number" id="pm-weight" placeholder="예) 3.5" step="0.1" min="0" max="200">
        </div>

        <%-- 2026-07-28 박유정 — TB_PET FUR_COLOR/NEUTER_YN/TRAITS/MEMO 폼 연동 --%>
        <div class="pm-group">
          <label>털 색상</label>
          <input type="text" id="pm-color" placeholder="예) 황갈색, 검은색" maxlength="50">
        </div>
        <div class="pm-group full">
          <label>중성화 여부</label>
          <input type="hidden" id="pm-neuter" value="U">
          <div class="pm-neuter-row">
            <button type="button" class="pm-neuter-btn" id="neuter-Y" onclick="selNeuter('Y')">
              <svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg> 완료
            </button>
            <button type="button" class="pm-neuter-btn" id="neuter-N" onclick="selNeuter('N')">
              <svg viewBox="0 0 24 24"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg> 미완료
            </button>
            <button type="button" class="pm-neuter-btn on" id="neuter-U" onclick="selNeuter('U')">
              <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg> 모름
            </button>
          </div>
        </div>
        <div class="pm-group full">
          <label>성격 / 특징</label>
          <div class="pm-trait-wrap" id="pm-trait-wrap">
            <span class="pm-trait" data-value="활발해요" onclick="toggleTrait(this)">활발해요</span>
            <span class="pm-trait" data-value="얌전해요" onclick="toggleTrait(this)">얌전해요</span>
            <span class="pm-trait" data-value="낯가림 있어요" onclick="toggleTrait(this)">낯가림 있어요</span>
            <span class="pm-trait" data-value="사람 좋아해요" onclick="toggleTrait(this)">사람 좋아해요</span>
          </div>
        </div>
        <div class="pm-group full">
          <label>메모</label>
          <input type="text" id="pm-memo" placeholder="특이사항, 알레르기 등" maxlength="500">
        </div>
      </div>
    </div>
    <div class="pm-footer">
      <button type="button" class="btn-pm-cancel" onclick="closeModal()">취소</button>
      <button type="button" class="btn-pm-save" id="pm-save-btn" onclick="savePet()">저장하기</button>
    </div>
  </div>
</div>
<%-- 2026-08-13 박유정 — 회원가입·마이페이지 공통 품종 목록 --%>
<script src="${contextPath}/resources/js/pet-breeds.js"></script>
<script>
const CTX = '${contextPath}';

const PET_LIST = ${empty petListJson ? '[]' : petListJson};
const PET_MAP = {};
PET_LIST.forEach(function (p) { PET_MAP[p.petId] = p; });

// 2026/08/11 장우철 — PHOTO_URL → 브라우저 src
function toPetPhotoSrc(url) {
    if (!url) return '';
    if (url.indexOf('http') === 0) return url;
    if (url.charAt(0) === '/') return CTX + url;
    return CTX + '/upload/' + url;
}

function clearPetPhotoPreview() {
    var input = document.getElementById('pm-photo');
    var preview = document.getElementById('pm-preview');
    var circle = document.getElementById('pm-photo-circle');
    if (input) input.value = '';
    if (preview) {
        preview.removeAttribute('src');
        preview.src = '';
    }
    if (circle) circle.classList.remove('has-img');
}

function setPetPhotoPreview(src) {
    var preview = document.getElementById('pm-preview');
    var circle = document.getElementById('pm-photo-circle');
    if (!preview || !circle) return;
    if (!src) {
        clearPetPhotoPreview();
        return;
    }
    preview.src = src;
    circle.classList.add('has-img');
}

document.getElementById('pm-photo').addEventListener('change', function () {
    var file = this.files && this.files[0];
    if (!file) return;
    if (!file.type || file.type.indexOf('image/') !== 0) {
        alert('이미지 파일만 선택할 수 있습니다.');
        this.value = '';
        return;
    }
    if (file.size > 5 * 1024 * 1024) {
        alert('사진은 최대 5MB까지 업로드할 수 있습니다.');
        this.value = '';
        return;
    }
    var reader = new FileReader();
    reader.onload = function (e) {
        setPetPhotoPreview(e.target.result);
    };
    reader.readAsDataURL(file);
});

function speciesToKind(species) {
    if (species === 'DOG') return 'dog';
    if (species === 'CAT') return 'cat';
    return 'etc';
}

// 2026-08-13 박유정 — 공통 pet-breeds.js 호출 (마이페이지 모달)
function updateBreed(selected) {
    updatePetBreedSelect('pm-kind', null, 'pm-breed', selected || null);
}

// 2026-07-28 박유정 — 중성화 선택 + hidden(pm-neuter) 동기화
function selNeuter(v) {
    ['Y','N','U'].forEach(function(k) {
        document.getElementById('neuter-' + k).classList.remove('on');
    });
    document.getElementById('neuter-' + v).classList.add('on');
    document.getElementById('pm-neuter').value = v;
}

// 2026-07-28 박유정 — 성격/특징 태그 토글
function toggleTrait(el) {
    el.classList.toggle('on');
}

// 2026-07-28 박유정 — 선택된 성격/특징 → 쉼표 문자열
function getSelectedTraits() {
    var tags = document.querySelectorAll('#pm-trait-wrap .pm-trait.on');
    var list = [];
    tags.forEach(function(el) {
        list.push(el.getAttribute('data-value'));
    });
    return list.join(',');
}

// 2026-07-28 박유정 — 성격/특징 태그 초기화 후 선택 반영
function setTraitSelection(traitsStr) {
    document.querySelectorAll('#pm-trait-wrap .pm-trait').forEach(function(el) {
        el.classList.remove('on');
    });
    if (!traitsStr) return;
    var selected = traitsStr.split(',');
    document.querySelectorAll('#pm-trait-wrap .pm-trait').forEach(function(el) {
        var val = el.getAttribute('data-value');
        if (selected.indexOf(val) >= 0) {
            el.classList.add('on');
        }
    });
}

// 2026-07-28 박유정 — 신규 등록 시 폼 초기화
function resetExtraFields() {
    document.getElementById('pm-color').value = '';
    document.getElementById('pm-memo').value = '';
    selNeuter('U');
    setTraitSelection('');
}

function openPetModal(petId) {
    const petData = petId != null ? PET_MAP[petId] : null;
    document.getElementById('pm-title').textContent = petData ? '반려동물 수정' : '반려동물 등록';
    document.getElementById('pm-petId').value = petData ? petData.petId : '';
    document.getElementById('pm-name').value = petData ? (petData.petName || '') : '';
    document.getElementById('pm-gender').value = petData ? (petData.gender || '') : '';
    document.getElementById('pm-birth').value = petData && petData.birthDate ? String(petData.birthDate).substring(0, 10) : '';
    document.getElementById('pm-weight').value = petData && petData.weight != null ? petData.weight : '';

    // 2026/08/11 장우철 — 기존 대표사진 미리보기 / 신규는 초기화
    clearPetPhotoPreview();
    if (petData && petData.photoUrl) {
        setPetPhotoPreview(toPetPhotoSrc(petData.photoUrl));
    }

    if (petData) {
        const kind = speciesToKind(petData.species);
        document.getElementById('pm-kind').value = kind;
        updateBreed(petData.breed || '');
        // 2026-07-28 박유정 — 추가 필드 불러오기
        document.getElementById('pm-color').value = petData.furColor || '';
        document.getElementById('pm-memo').value = petData.memo || '';
        selNeuter(petData.neuterYn || 'U');
        setTraitSelection(petData.traits || '');
    } else {
        document.getElementById('pm-kind').value = '';
        document.getElementById('pm-breed').innerHTML = '<option value="">종류를 먼저 선택하세요</option>';
        resetExtraFields();
    }

    document.getElementById('petModalBg').classList.add('open');
    document.body.style.overflow = 'hidden';
}

function closeModal() {
    document.getElementById('petModalBg').classList.remove('open');
    document.body.style.overflow = '';
}

async function savePet() {
    const name = document.getElementById('pm-name').value.trim();
    const kind = document.getElementById('pm-kind').value;
    const breed = document.getElementById('pm-breed').value;
    const gender = document.getElementById('pm-gender').value;
    if (!name) { alert('이름을 입력해 주세요.'); return; }
    if (!kind) { alert('종류를 선택해 주세요.'); return; }
    if (!breed) { alert('품종을 선택해 주세요.'); return; }
    if (!gender) { alert('성별을 선택해 주세요.'); return; }

    const fd = new FormData();
    const petId = document.getElementById('pm-petId').value;
    if (petId) fd.append('petId', petId);
    fd.append('petName', name);
    fd.append('kind', kind);
    fd.append('breed', breed);
    fd.append('gender', gender);
    const birth = document.getElementById('pm-birth').value;
    if (birth) fd.append('birthDate', birth);
    const weight = document.getElementById('pm-weight').value;
    if (weight) fd.append('weight', weight);

    // 2026-07-28 박유정 — 털색상·중성화·성격/특징·메모 저장
    const color = document.getElementById('pm-color').value.trim();
    if (color) fd.append('furColor', color);

    const neuter = document.getElementById('pm-neuter').value || 'U';
    fd.append('neuterYn', neuter);

    const traits = getSelectedTraits();
    if (traits) fd.append('traits', traits);

    const memo = document.getElementById('pm-memo').value.trim();
    if (memo) fd.append('memo', memo);

    // 2026/08/11 장우철 — 선택한 대표사진 전송
    const photoInput = document.getElementById('pm-photo');
    if (photoInput && photoInput.files && photoInput.files[0]) {
        fd.append('petPhoto', photoInput.files[0]);
    }

    const btn = document.getElementById('pm-save-btn');
    btn.disabled = true;
    try {
        //HYJ 26.08.05
        const res = await csrfFetch(CTX + '/mypage/pets/save', { method: 'POST', body: fd });
        const data = await res.json();
        if (!data.success) {
            alert(data.message || '저장에 실패했습니다.');
            return;
        }
        closeModal();
        location.reload();
    } catch (e) {
        alert('저장 중 오류가 발생했습니다.');
    } finally {
        btn.disabled = false;
    }
}

async function deletePet(petId, petName) {
    if (!confirm('"' + petName + '" 정보를 삭제할까요?')) return;
    const fd = new FormData();
    fd.append('petId', petId);
    try {
        //HYJ 26.08.05
        const res = await csrfFetch(CTX + '/mypage/pets/delete', { method: 'POST', body: fd });
        const data = await res.json();
        if (!data.success) {
            alert(data.message || '삭제에 실패했습니다.');
            return;
        }
        location.reload();
    } catch (e) {
        alert('삭제 중 오류가 발생했습니다.');
    }
}
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
