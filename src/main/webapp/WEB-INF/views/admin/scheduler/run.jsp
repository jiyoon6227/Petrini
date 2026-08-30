<%--
  역할: 관리자 스케줄러 수동 실행 (QA)
  2026/08/12 장우철 — ADMIN + csrfFetch
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>스케줄러 실행 — PetCare</title>
  <meta name="_csrf" content="${_csrf}">
  <style>
    body { font-family: 'Noto Sans KR', sans-serif; margin: 0; padding: 24px; background: #f5f6f8; color: #1a1a2e; }
    h1 { margin: 0 0 8px; font-size: 22px; }
    .sub { color: #666; font-size: 13px; margin-bottom: 20px; line-height: 1.6; }
    .top-links { margin-bottom: 20px; font-size: 13px; }
    .top-links a { margin-right: 12px; color: #3B5BDB; }
    .item {
      background: #fff; border: 1px solid #e4e6ed; border-radius: 10px;
      padding: 16px 18px; margin-bottom: 12px; display: flex; gap: 16px; align-items: flex-start;
    }
    .item-body { flex: 1; }
    .item-title { font-weight: 800; font-size: 15px; margin-bottom: 6px; }
    .item-desc { font-size: 13px; color: #555; line-height: 1.55; margin-bottom: 4px; }
    .item-cron { font-size: 12px; color: #888; }
    .btn {
      border: none; background: #3B5BDB; color: #fff; font-weight: 700;
      padding: 10px 14px; border-radius: 8px; cursor: pointer; white-space: nowrap;
    }
    .btn:disabled { opacity: .6; cursor: not-allowed; }
    .note {
      background: #fffbeb; border: 1px solid #fde68a; border-radius: 8px;
      padding: 12px 14px; font-size: 13px; color: #92400e; line-height: 1.55; margin-bottom: 16px;
    }
  </style>
</head>
<body>
  <div class="top-links">
    <a href="${contextPath}/">메인</a>
    <a href="${contextPath}/admin">관리자페이지</a>
  </div>

  <h1>스케줄러 수동 실행</h1>
  <p class="sub">
    시드 SQL로 조건 맞춘 뒤 버튼으로 @Scheduled 메서드를 직접 호출합니다.<br>
    정산 월정산·15일 지급은 <a href="${contextPath}/admin/settlement">정산관리</a> 버튼 사용 (중복 제외).
  </p>

  <div class="note">
    배송상태 자동동기화(<code>DeliveryAutoSyncScheduler</code>)는 @Component가 꺼져 있어 이 페이지에 없습니다.
    API 100건/월 제한 — 테스트 시에만 코드에서 @Component 활성화.
  </div>

  <div class="item">
    <div class="item-body">
      <div class="item-title">1. 숙소 이용완료 (CHECKOUT → DONE)</div>
      <div class="item-desc">체크아웃일이 오늘보다 이전인 <code>CHECKOUT</code> 예약을 <code>DONE</code>으로 바꿉니다.</div>
      <div class="item-cron">자동: 매 1분 · <code>StayReservationScheduler.autoCompleteStayReservations()</code></div>
    </div>
    <button type="button" class="btn" onclick="runJob('stay-done', this)">실행</button>
  </div>

  <div class="item">
    <div class="item-body">
      <div class="item-title">2. 숙소 PENDING 자동취소</div>
      <div class="item-desc">결제 없이 15분 이상 지난 <code>PENDING</code> 예약을 <code>CANCEL</code> 처리합니다.</div>
      <div class="item-cron">자동: 5분마다 · <code>StayReservationScheduler.cancelExpiredPendingReservations()</code></div>
    </div>
    <button type="button" class="btn" onclick="runJob('stay-pending-cancel', this)">실행</button>
  </div>

  <div class="item">
    <div class="item-body">
      <div class="item-title">3. 쇼핑 자동 구매확정</div>
      <div class="item-desc">배송완료 후 7일 지나도 미확정인 주문을 구매확정 + 포인트 적립합니다.</div>
      <div class="item-cron">자동: 매일 03:00 · <code>AutoConfirmPurchaseScheduler.autoConfirmPurchase()</code></div>
    </div>
    <button type="button" class="btn" onclick="runJob('store-auto-confirm', this)">실행</button>
  </div>

  <div class="item">
    <div class="item-body">
      <div class="item-title">4. 배너 기간만료</div>
      <div class="item-desc"><code>END_DATE</code>가 지난 노출중 배너를 만료(EXPIRED) 처리합니다.</div>
      <div class="item-cron">자동: 매일 00:00 · <code>BannerExpiryScheduler.expirePastEndDateBanners()</code></div>
    </div>
    <button type="button" class="btn" onclick="runJob('banner-expire', this)">실행</button>
  </div>

  <div class="item">
    <div class="item-body">
      <div class="item-title">5. 회원 정지 만료 해제</div>
      <div class="item-desc">기간 정지 만료일이 지난 회원을 <code>NORMAL</code>로 복구합니다.</div>
      <div class="item-cron">자동: 매일 00:00 · <code>MemberSuspendScheduler.releaseExpiredSuspensions()</code></div>
    </div>
    <button type="button" class="btn" onclick="runJob('member-suspend-release', this)">실행</button>
  </div>

  <div class="item">
    <div class="item-body">
      <div class="item-title">6. 탈퇴 회원 purge</div>
      <div class="item-desc">탈퇴 후 유예기간이 지난 회원의 개인정보를 익명화·삭제합니다.</div>
      <div class="item-cron">자동: 매일 00:00 · <code>WithdrawPurgeScheduler.purgeExpiredWithdrawnMembers()</code></div>
    </div>
    <button type="button" class="btn" onclick="runJob('withdraw-purge', this)">실행</button>
  </div>

  <div class="item">
    <div class="item-body">
      <div class="item-title">7. LIFE 게시글 purge</div>
      <div class="item-desc">soft 삭제(DELETED) 후 7일 지난 LIFE 게시글·댓글·파일을 물리 삭제합니다.</div>
      <div class="item-cron">자동: 매일 03:00 · <code>CommunityPostPurgeScheduler.purgeExpiredPosts()</code></div>
    </div>
    <button type="button" class="btn" onclick="runJob('community-purge', this)">실행</button>
  </div>

  <div class="item">
    <div class="item-body">
      <div class="item-title">8. 병원 예약 홀드 정리</div>
      <div class="item-desc">만료 시각이 지난 <code>TB_HOSPITAL_RESV_HOLD</code> 행을 삭제합니다.</div>
      <div class="item-cron">자동: 5분마다 · <code>HospitalResvHoldCleanupScheduler.purgeExpiredHolds()</code></div>
    </div>
    <button type="button" class="btn" onclick="runJob('hospital-hold-cleanup', this)">실행</button>
  </div>

<script>
  var CTX = '${contextPath}';
  window.csrfFetch = function(url, options) {
    options = options || {};
    options.headers = options.headers || {};
    var csrfMeta = document.querySelector('meta[name="_csrf"]');
    if (csrfMeta) {
      options.headers['X-CSRF-TOKEN'] = csrfMeta.getAttribute('content');
    }
    return fetch(url, options);
  };

  function runJob(jobKey, btn) {
    if (!confirm('[' + jobKey + '] 스케줄러를 지금 실행할까요?')) return;
    btn.disabled = true;
    csrfFetch(CTX + '/admin/scheduler/run/' + encodeURIComponent(jobKey), {
      method: 'POST',
      headers: { 'Accept': 'application/json' }
    })
      .then(function (r) { return r.json(); })
      .then(function (data) {
        alert(data.message || (data.ok ? '완료' : '실패'));
      })
      .catch(function () { alert('요청 중 오류'); })
      .finally(function () { btn.disabled = false; });
  }
</script>
</body>
</html>
