<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="mypage" />
<c:set var="sec" value="edit" />

<%@ include file="/WEB-INF/views/common/header.jsp" %>
<link rel="stylesheet" href="${contextPath}/resources/css/mypage.css">

<div class="mypage-wrap">
<%@ include file="/WEB-INF/views/mypage/sidebar.jsp" %>
<div class="mypage-content">

<%-- ── 회원정보 수정 ── --%>
<%-- 2026/08/06 장우철 — yeju(정보·비번 AJAX) + 유정(프로필 사진) merge 합본 --%>
<div class="mp-section active">
    <h2 class="mp-title">회원정보 수정</h2>
    <c:if test="${not empty msg}">
    <div style="margin-bottom:12px;padding:12px 16px;background:#E8F8F1;color:#1F8464;border-radius:8px;font-size:14px">${msg}</div>
    </c:if>
    <c:if test="${not empty errorMsg}">
    <div style="margin-bottom:12px;padding:12px 16px;background:#FEF2F2;color:#B91C1C;border-radius:8px;font-size:14px">${errorMsg}</div>
    </c:if>
    <p class="mp-desc">개인정보를 수정하고 저장하세요.</p>

    <%-- 2026-08-04 박유정 — 프로필 사진 (별도 POST /mypage/edit/profile-image) --%>
    <form id="profileImageForm"
          method="post"
          action="${contextPath}/mypage/edit/profile-image"
          enctype="multipart/form-data">
        <input type="hidden" name="_csrf" value="${_csrf}">
        <div class="edit-section">
            <div class="edit-section-title">
                <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                프로필 사진
            </div>
            <div class="edit-avatar-row">
                <img id="profilePreview" class="edit-avatar-img"
                     src="${not empty profile.profileImgUrl ? contextPath.concat(profile.profileImgUrl) : 'https://placehold.co/80x80/EAF7F2/2BAB82?text=ME'}"
                     alt="프로필"
                     onerror="this.src='https://placehold.co/80x80/EAF7F2/2BAB82?text=ME'">
                <div class="edit-avatar-btns">
                    <input type="file" name="profileImage" id="profileImageInput"
                           accept="image/*" style="display:none">
                    <button type="button" class="btn-sm"
                            onclick="document.getElementById('profileImageInput').click()">사진 선택</button>
                    <button type="submit" class="btn-sm" id="btnSaveProfileImage">사진 저장</button>
                </div>
            </div>
        </div>
    </form>

    <%-- 비밀번호 변경 --%>
    <div class="edit-section">
        <div class="edit-section-title">
            <svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
            비밀번호 변경
        </div>
        <div class="edit-grid">
            <div class="edit-group full">
                <label>현재 비밀번호 <span class="req">*</span></label>
                <div class="edit-pw-wrap">
                    <input type="password" id="currentPassword" placeholder="현재 비밀번호를 입력하세요" autocomplete="off">
                    <button class="edit-pw-eye" type="button"><svg viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg></button>
                </div>
            </div>
            <div class="edit-group">
                <label>새 비밀번호</label>
                <div class="edit-pw-wrap">
                    <input type="password" id="newPassword" placeholder="영문+숫자+특수문자 8자 이상" autocomplete="new-password">
                    <button class="edit-pw-eye" type="button"><svg viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg></button>
                </div>
                <div class="pw-strength"><span></span><span></span><span></span><span></span></div>
            </div>
            <div class="edit-group">
                <label>새 비밀번호 확인</label>
                <div class="edit-pw-wrap">
                    <input type="password" id="confirmPassword" placeholder="비밀번호를 다시 입력하세요" autocomplete="new-password">
                    <button class="edit-pw-eye" type="button"><svg viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg></button>
                </div>
            </div>
            <div class="edit-group full" style="text-align:right;">
                <button type="button" class="btn-sm" id="btnChangePw">비밀번호 변경</button>
                <span id="pwMsg" style="margin-left:10px; font-size:13px;"></span>
            </div>
        </div>
    </div>
    <%-- 기본 정보 --%>
    <div class="edit-section">
        <div class="edit-section-title">
            <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
            기본 정보
        </div>
        <div class="edit-grid">
            <div class="edit-group">
                <label>이름</label>
                <input type="text" value="${profile.memberName}" readonly>
            </div>
            <div class="edit-group">
                <label>아이디</label>
                <input type="text" value="${profile.memberId}" readonly>
            </div>
            <div class="edit-group">
                <label>이메일</label>
                <input type="email" value="${profile.email}" readonly>
            </div>
            <div class="edit-group">
                <label>닉네임 <span class="req">*</span></label>
                <input type="text" id="nickname" name="nickname" value="${profile.nickname}">
            </div>
            <div class="edit-group">
                <label>전화번호 <span class="req">*</span></label>
                <div class="edit-input-row">
                    <input type="tel" id="phone" name="phone" value="${profile.phone}">
                    <button class="btn-verify" type="button">인증</button>
                </div>
            </div>
            <div class="edit-group">
                <label>생년월일</label>
                <input type="date" readonly value="${profile.birthDate}">
            </div>
            <div class="edit-group">
                <label>성별</label>
                <input type="text" readonly
                       value="<c:choose><c:when test="${profile.gender eq 'M'}">남성</c:when><c:when test="${profile.gender eq 'F'}">여성</c:when><c:otherwise>선택 안함</c:otherwise></c:choose>">
            </div>
            <div class="edit-group full">
                <label>주소</label>
                <div class="edit-input-row">
                    <input type="text" value="${profile.zipcode}" id="zipcode" name="zipcode" style="max-width:120px">
                    <button class="btn-verify" type="button" id="btnSearchAddr">주소 검색</button>
                </div>
                <input type="text" value="${profile.addr1}" id="addr1" name="addr1" style="margin-top:8px">
                <input type="text" value="${profile.addr2}" id="addr2" name="addr2" style="margin-top:8px" placeholder="상세주소">
            </div>
        </div>
    </div>

    <%-- 2026/07/27 장우철 — 카드등록 (토스 빌링 + Ajax) --%>
    <div class="edit-section" id="editCardSection">
        <div class="edit-section-title">
            <svg viewBox="0 0 24 24"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
            결제 카드
        </div>
        <div id="editCardEmpty" class="edit-card-box">
            <p class="edit-card-desc">등록된 카드가 없습니다. 간편결제를 위해 카드를 등록해 주세요.</p>
            <button type="button" class="btn-verify" id="btnEditCardRegister">카드 등록하기</button>
        </div>
        <%-- 2026/08/11 장우철 — 등록 카드 여러 장 전부 --%>
        <div id="editCardRegistered" class="edit-card-list-wrap" style="display:none;">
            <div id="editCardList" class="edit-card-list"></div>
            <div class="edit-card-actions" style="margin-top:12px;">
                <button type="button" class="btn-sm" id="btnEditCardChange">카드 추가</button>
            </div>
        </div>
    </div>

    <div class="edit-submit-area">
        <button type="button" class="btn-primary" id="btnSaveProfile" style="padding:13px 52px; font-size:15px;">저장하기</button>
    </div>

    <%-- HYJ 26.07.29 회원 탈퇴 --%>
    <div style="text-align:center; margin-top:48px; padding-top:24px; border-top:1px solid #eee;">
        <a href="${contextPath}/mypage/withdraw"
           style="color:#999; font-size:13px; text-decoration:underline;">회원 탈퇴</a>
    </div>
</div>



</div><%-- /mypage-content --%>
</div><%-- /mypage-wrap --%>

<%-- 2026-08-04 박유정 — 사진 선택 즉시 미리보기 --%>
<script>
(function () {
  var input = document.getElementById('profileImageInput');
  var preview = document.getElementById('profilePreview');
  if (!input || !preview) return;
  input.addEventListener('change', function () {
    var file = input.files[0];
    if (!file) return;
    if (!file.type.startsWith('image/')) {
      alert('이미지 파일만 선택할 수 있습니다.');
      input.value = '';
      return;
    }
    var reader = new FileReader();
    reader.onload = function (e) {
      preview.src = e.target.result;
    };
    reader.readAsDataURL(file);
  });
})();
</script>

<%-- HYJ 26.08.06 주소찾기 --%>
<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<%-- 2026/07/27 장우철 — 토스 빌링 SDK + 카드등록 Ajax --%>
<script src="https://js.tosspayments.com/v2/standard"></script>
<script src="${contextPath}/resources/js/billing-card.js"></script>
<script>
/* 2026/07/27 장우철 — 회원정보 카드등록 (목록 Ajax + requestBillingAuth) */
/* 2026/08/11 장우철 — 등록 카드 전부 표시 */
(function () {
  var empty = document.getElementById('editCardEmpty');
  var registered = document.getElementById('editCardRegistered');
  var listEl = document.getElementById('editCardList');

  function showEmpty() {
    empty.style.display = 'block';
    registered.style.display = 'none';
    if (listEl) listEl.innerHTML = '';
  }

  function renderCards(cards) {
    if (!listEl) return;
    listEl.innerHTML = '';
    cards.forEach(function (c) {
      var row = document.createElement('div');
      row.className = 'edit-card-box registered';
      row.innerHTML =
        '<div class="edit-card-info">' +
          '<span class="edit-card-badge">등록됨</span>' +
          '<strong></strong>' +
          '<span class="edit-card-sub">토스 빌링키로 등록된 카드입니다.</span>' +
        '</div>' +
        '<div class="edit-card-actions">' +
          '<button type="button" class="btn-sm danger btn-card-remove">등록 해제</button>' +
        '</div>';
      row.querySelector('strong').textContent = c.label || '등록된 카드';
      row.querySelector('.btn-card-remove').addEventListener('click', async function () {
        if (!confirm('등록된 카드를 해제할까요?')) return;
        var res = await PetcareBilling.deleteCard(c.billingCardId, false);
        if (res.ok) refreshCards();
        else alert(res.message || '삭제에 실패했습니다.');
      });
      listEl.appendChild(row);
    });
    empty.style.display = 'none';
    registered.style.display = 'block';
  }

  async function refreshCards() {
    try {
      var data = await PetcareBilling.loadCards();
      if (!data.ok || !data.cards || data.cards.length === 0) {
        showEmpty();
        return;
      }
      renderCards(data.cards);
    } catch (e) {
      console.error(e);
    }
  }

  function openToss() {
    PetcareBilling.openRegister('/mypage/edit').catch(function (e) {
      console.error(e);
      alert('카드 등록 창을 열지 못했습니다.');
    });
  }

  document.getElementById('btnEditCardRegister').addEventListener('click', openToss);
  document.getElementById('btnEditCardChange').addEventListener('click', openToss);

  PetcareBilling.notifyFromQuery();
  refreshCards();
})();

/* HYJ 26.08.06 주소 찾기 (카카오 주소 API 연동) */
$("#btnSearchAddr").click(function(){
    new daum.Postcode({
        oncomplete:function(data){
            var addr = "";
            var extraAddr = "";
            if(data.userSelectedType === 'R'){
                addr = data.roadAddress;
                if(data.bname !== ''){
                    extraAddr += data.bname;
                }
                if(data.buildingName !== ''){
                    extraAddr += (extraAddr ? ", " : "") + data.buildingName;
                }
                if(extraAddr !== ''){
                    extraAddr = " (" + extraAddr + ")";
                }
            } else {
                addr = data.jibunAddress;
            }
            $("input[name='zipcode']").val(data.zonecode);
            $("input[name='addr1']").val(addr + extraAddr);
            $("input[name='addr2']").val("");
            $("input[name='addr2']").focus();
        }
    }).open();
});

/* ── HYJ 26.08.06 회원정보 저장 (닉네임·전화번호·주소) ── */
$("#btnSaveProfile").click(function(){
    var nickname = $.trim($("#nickname").val());
    var phone    = $.trim($("#phone").val());
    var zipcode  = $.trim($("#zipcode").val());
    var addr1    = $.trim($("#addr1").val());
    var addr2    = $.trim($("#addr2").val());

    if (nickname.length === 0) {
        alert("닉네임을 입력해 주세요.");
        $("#nickname").focus();
        return;
    }
    if (phone.length === 0) {
        alert("전화번호를 입력해 주세요.");
        $("#phone").focus();
        return;
    }

    var fd = new FormData();
    fd.append("nickname", nickname);
    fd.append("phone", phone);
    fd.append("zipcode", zipcode);
    fd.append("addr1", addr1);
    fd.append("addr2", addr2);

    csrfFetch('${contextPath}/mypage/edit', { method: 'POST', body: fd })
        .then(function(res){ return res.json(); })
        .then(function(data){
            if (data.ok) {
                alert(data.msg);
                location.reload();
            } else {
                alert(data.msg);
            }
        })
        .catch(function(e){
            console.error(e);
            alert("저장 중 오류가 발생했습니다.");
        });
});

/* ── HYJ 26.08.06 비밀번호 변경 ── */
$("#btnChangePw").click(function(){
    var cur     = $.trim($("#currentPassword").val());
    var newPw   = $.trim($("#newPassword").val());
    var confirm = $.trim($("#confirmPassword").val());
    var msgEl   = $("#pwMsg");

    msgEl.text("").css("color", "");

    if (cur.length === 0) {
        alert("현재 비밀번호를 입력하세요.");
        $("#currentPassword").focus();
        return;
    }
    if (newPw.length === 0) {
        alert("새 비밀번호를 입력하세요.");
        $("#newPassword").focus();
        return;
    }
    if (newPw !== confirm) {
        msgEl.text("새 비밀번호가 일치하지 않습니다.").css("color", "var(--error)");
        $("#confirmPassword").focus();
        return;
    }

    var fd = new FormData();
    fd.append("currentPassword", cur);
    fd.append("newPassword", newPw);
    fd.append("confirmPassword", confirm);

    csrfFetch('${contextPath}/mypage/change-password', { method: 'POST', body: fd })
        .then(function(res){ return res.json(); })
        .then(function(data){
            if (data.ok) {
                msgEl.text(data.msg).css("color", "var(--primary)");
                $("#currentPassword").val("");
                $("#newPassword").val("");
                $("#confirmPassword").val("");
            } else {
                msgEl.text(data.msg).css("color", "var(--error)");
            }
        })
        .catch(function(e){
            console.error(e);
            alert("비밀번호 변경 중 오류가 발생했습니다.");
        });
});

/* ── HYJ 26.08.06 비밀번호 보기/숨기기 토글 ── */
$(".edit-pw-eye").click(function(){
    var input = $(this).siblings("input");
    if (input.attr("type") === "password") {
        input.attr("type", "text");
    } else {
        input.attr("type", "password");
    }
});
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
