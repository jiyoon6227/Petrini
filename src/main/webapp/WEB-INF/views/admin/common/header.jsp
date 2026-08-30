<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- 관리자 전용 헤더 — adminPage 변수로 사이드바 active 제어 --%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PetCare 관리자</title>
    <link rel="icon" href="${contextPath}/favicon.ico" sizes="any">
    <link rel="icon" href="${contextPath}/favicon.svg" type="image/svg+xml">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${contextPath}/resources/css/admin.css">
    
    <%-- 2026-08-05 HYJ — CSRF 토큰: AJAX 에서 이 meta 태그를 읽어서 header 에 포함 --%>
    <meta name="_csrf" content="${_csrf}">    
</head>
<body>
<div class="adm-page">

<header class="adm-header">
    <a href="${contextPath}/admin" class="adm-logo">
        <svg width="24" height="24" viewBox="0 0 32 32" fill="none">
            <ellipse cx="16" cy="20" rx="9" ry="8" fill="#2BAB82"/>
            <ellipse cx="8"  cy="12" rx="3.2" ry="3.8" fill="#2BAB82"/>
            <ellipse cx="13" cy="9.5" rx="3.2" ry="3.8" fill="#2BAB82"/>
            <ellipse cx="19" cy="9.5" rx="3.2" ry="3.8" fill="#2BAB82"/>
            <ellipse cx="24" cy="12" rx="3.2" ry="3.8" fill="#2BAB82"/>
        </svg>
        <span>PetCare</span>
        <span class="adm-tag">ADMIN</span>
    </a>
    <div class="adm-header-divider"></div>
    <span class="adm-header-title">관리자 센터</span>
    <div class="adm-header-right">
        <a href="${contextPath}/admin/biz/list?status=PENDING">
            <svg viewBox="0 0 24 24"><path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 01-3.46 0"/></svg>
            사업자 승인 대기
            <%-- 2026/07/11 장우철 — PENDING 실건수 (더미 3 제거, 사이드바 배지와 동일) --%>
            <c:if test="${pendingBizApproveCount > 0}">
              <span class="adm-noti-badge">${pendingBizApproveCount}</span>
            </c:if>
        </a>
        <%-- 2026/07/27 장우철 — 관리자 카드등록 (토스 빌링 모달) --%>
        <button type="button" class="adm-header-card-btn" id="btnAdminCardReg" title="정산용 카드 등록">
            <svg viewBox="0 0 24 24"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
            카드 등록
        </button>
        <div class="adm-header-divider"></div>
        <a href="${contextPath}/">
            <svg viewBox="0 0 24 24"><path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
            사이트로 이동
        </a>
        <a href="${contextPath}/member/logout">
            <svg viewBox="0 0 24 24"><path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
            로그아웃
        </a>
    </div>
</header>

<%-- 2026/07/27 장우철 — 관리자 카드등록 모달 (토스 빌링) --%>
<div class="adm-card-modal-overlay" id="adminCardModal" style="display:none;" aria-hidden="true">
    <div class="adm-card-modal" role="dialog" aria-labelledby="adminCardModalTitle">
        <div class="adm-card-modal-head">
            <h3 id="adminCardModalTitle">정산용 카드 등록</h3>
            <button type="button" class="adm-card-modal-close" id="btnAdminCardModalClose" aria-label="닫기">&times;</button>
        </div>
        <div class="adm-card-modal-body">
            <p class="adm-card-modal-desc">정산 시 결제창 없이 사용할 관리자 카드를 등록합니다. 카드 입력은 토스 등록 화면에서 진행됩니다.</p>
            <div id="adminCardEmpty">
                <button type="button" class="adm-card-modal-btn" id="btnAdminCardDoRegister">카드 등록하기</button>
            </div>
            <div id="adminCardRegistered" style="display:none;" class="adm-card-registered-box">
                <div class="adm-card-badge">등록됨</div>
                <strong id="adminCardLabel">-</strong>
                <div class="adm-card-actions">
                    <button type="button" class="adm-card-modal-btn ghost" id="btnAdminCardChange">카드 추가</button>
                    <button type="button" class="adm-card-modal-btn ghost danger" id="btnAdminCardRemove">등록 해제</button>
                </div>
            </div>
        </div>
    </div>
</div>
<script>window.__CONTEXT_PATH__ = '${contextPath}';</script>
<script src="https://js.tosspayments.com/v2/standard"></script>
<script src="${contextPath}/resources/js/billing-card.js"></script>
<script>
/* 2026/07/27 장우철 — 관리자 카드등록 (Ajax 목록 + 토스 requestBillingAuth) */
(function () {
  var modal = document.getElementById('adminCardModal');
  var empty = document.getElementById('adminCardEmpty');
  var registered = document.getElementById('adminCardRegistered');
  var labelEl = document.getElementById('adminCardLabel');
  var currentCardId = null;

  function openModal() {
    modal.style.display = 'flex';
    modal.setAttribute('aria-hidden', 'false');
    refreshCards();
  }
  function closeModal() {
    modal.style.display = 'none';
    modal.setAttribute('aria-hidden', 'true');
  }
  function showRegistered(label, cardId) {
    currentCardId = cardId;
    labelEl.textContent = label || '등록된 카드';
    empty.style.display = 'none';
    registered.style.display = 'block';
  }
  function showEmpty() {
    currentCardId = null;
    empty.style.display = 'block';
    registered.style.display = 'none';
  }

  async function refreshCards() {
    try {
      var data = await PetcareBilling.loadCards();
      if (!data.ok || !data.cards || data.cards.length === 0) {
        showEmpty();
        return;
      }
      var c = data.cards[0];
      showRegistered(c.label, c.billingCardId);
    } catch (e) {
      console.error(e);
    }
  }

  function adminReturnPath() {
    var path = location.pathname || '/admin';
    var cp = window.__CONTEXT_PATH__ || '';
    if (cp && path.indexOf(cp) === 0) path = path.substring(cp.length) || '/admin';
    if (path.indexOf('/admin') !== 0) path = '/admin';
    return path;
  }

  function openToss() {
    PetcareBilling.openRegister(adminReturnPath()).catch(function (e) {
      console.error(e);
      alert('카드 등록 창을 열지 못했습니다.');
    });
  }

  document.getElementById('btnAdminCardReg').addEventListener('click', openModal);
  document.getElementById('btnAdminCardModalClose').addEventListener('click', closeModal);
  modal.addEventListener('click', function (e) {
    if (e.target === modal) closeModal();
  });
  document.getElementById('btnAdminCardDoRegister').addEventListener('click', openToss);
  document.getElementById('btnAdminCardChange').addEventListener('click', openToss);
  document.getElementById('btnAdminCardRemove').addEventListener('click', async function () {
    if (!confirm('등록된 카드를 해제할까요?')) return;
    if (currentCardId == null) { showEmpty(); return; }
    var res = await PetcareBilling.deleteCard(currentCardId, false);
    if (res.ok) refreshCards();
    else alert(res.message || '삭제에 실패했습니다.');
  });

  PetcareBilling.notifyFromQuery();
})();
</script>

<div class="adm-body">
