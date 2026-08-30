/**
 * 2026/07/27 장우철 — 토스 빌링 카드등록 공통 JS (Ajax)
 *
 * 사용
 * - join.jsp / mypage/edit.jsp / admin header.jsp
 * - PetcareBilling.openRegister(returnPath)  → prepare Ajax → requestBillingAuth
 * - PetcareBilling.loadCards()               → list Ajax
 * - PetcareBilling.deleteCard(id|pending)    → delete Ajax
 *
 * 공부 포인트
 * 1) /billing/card/prepare 로 clientKey·customerKey·successUrl 받기
 * 2) TossPayments(clientKey).payment({customerKey}).requestBillingAuth({method:'CARD',...})
 * 3) 토스가 successUrl 로 리다이렉트 → 서버가 빌링키 발급 (JS가 직접 secret 호출 금지)
 */
(function (global) {
  'use strict';

  function ctx() {
    return global.__CONTEXT_PATH__ || '';
  }

  function qs(params) {
    return Object.keys(params)
      .map(function (k) {
        return encodeURIComponent(k) + '=' + encodeURIComponent(params[k]);
      })
      .join('&');
  }

  async function getJson(url) {
    var res = await fetch(url, { credentials: 'same-origin' });
    return res.json();
  }

  //HYJ 26.08.05
  async function postForm(url, data) {
    var headers = { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' };
    var csrfMeta = document.querySelector('meta[name="_csrf"]');
    if (csrfMeta) {
      headers['X-CSRF-TOKEN'] = csrfMeta.getAttribute('content');
    }
    var res = await fetch(url, {
      method: 'POST',
      credentials: 'same-origin',
      headers: headers,
      body: qs(data)
    });
    return res.json();
}

  /**
   * 카드등록 창 열기
   * @param {string} returnPath 예: '/mypage/edit', '/join', '/admin'
   */
  async function openRegister(returnPath) {
    var data = await getJson(ctx() + '/billing/card/prepare?' + qs({ returnPath: returnPath }));
    if (!data.ok) {
      if (data.loginRequired) {
        alert('로그인이 필요합니다.');
        location.href = ctx() + '/login';
        return;
      }
      alert(data.message || '카드 등록 준비에 실패했습니다.');
      return;
    }

    if (typeof TossPayments !== 'function') {
      alert('토스 SDK를 불러오지 못했습니다. 페이지를 새로고침 후 다시 시도해 주세요.');
      return;
    }

    // 토스 v2 SDK — 결제위젯 키가 아닌 빌링(API개별) clientKey 사용
    var tossPayments = TossPayments(data.clientKey);
    var payment = tossPayments.payment({ customerKey: data.customerKey });

    await payment.requestBillingAuth({
      method: 'CARD',
      successUrl: data.successUrl,
      failUrl: data.failUrl
    });
  }

  /** 활성 카드 목록 Ajax */
  async function loadCards() {
    return getJson(ctx() + '/billing/card/list');
  }

  /**
   * 카드 삭제 Ajax
   * @param {number|null} billingCardId DB PK (pending 이면 null)
   * @param {boolean} pending 가입 중 세션 카드인지
   */
  async function deleteCard(billingCardId, pending) {
    var payload = { pending: pending ? 'true' : 'false' };
    if (billingCardId != null) {
      payload.billingCardId = billingCardId;
    }
    return postForm(ctx() + '/billing/card/delete', payload);
  }

  /** URL ?card=ok|fail 알림 후 쿼리 제거 */
  function notifyFromQuery() {
    var params = new URLSearchParams(location.search);
    var card = params.get('card');
    if (!card) return;
    if (card === 'ok') {
      alert('카드가 등록되었습니다.');
    } else if (card === 'fail') {
      alert(params.get('msg') || '카드 등록에 실패했습니다.');
    }
    params.delete('card');
    params.delete('msg');
    var next = location.pathname + (params.toString() ? ('?' + params.toString()) : '') + location.hash;
    history.replaceState(null, '', next);
  }

  global.PetcareBilling = {
    openRegister: openRegister,
    loadCards: loadCards,
    deleteCard: deleteCard,
    notifyFromQuery: notifyFromQuery
  };
})(window);
