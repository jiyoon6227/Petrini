<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="반려동물 숙소" />
<c:set var="bizPage"      value="settlement" />

<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_stay.jsp" %>

<%--
  2026/07/30 장우철 — 숙소 정산 내역
  - 2-1 상단 요약 / 2-2 목록 / 2-4 상세(아코디언 + AJAX ITEM)
  - 4-1/4-2 중간정산 요청 버튼·폼 + REQUEST 저장
--%>
<style>
  .settle-summary{display:grid;grid-template-columns:repeat(3,1fr);gap:14px;margin-bottom:16px}
  .settle-summary-card{background:#fff;border:1px solid var(--biz-border);border-radius:12px;padding:16px 18px}
  .settle-summary-card .label{font-size:12px;color:#888;margin-bottom:6px}
  .settle-summary-card .val{font-size:22px;font-weight:800;color:#1A1A2E}
  .settle-summary-card .val span{font-size:13px;font-weight:600;color:#888;margin-left:2px}
  .settle-summary-card.fee .val{color:#E24B4A}

  .settle-filter{display:flex;flex-wrap:wrap;align-items:center;gap:10px;padding:18px 20px}
  .settle-filter select{border:1px solid var(--biz-border);border-radius:8px;padding:8px 10px;font-size:13px;color:#333}
  .settle-filter .btn-settle-account{margin-left:auto}

  .settle-page-head{display:flex;align-items:flex-start;justify-content:space-between;gap:16px;flex-wrap:wrap}
  .settle-page-head .biz-page-desc{margin:0}

  .settle-table-head{display:flex;align-items:center;justify-content:space-between;padding:0 20px}
  .settle-type-tag{display:inline-block;margin-left:6px;font-size:11px;color:#666;border:1px solid #ddd;border-radius:999px;padding:1px 8px}
  .settle-toggle{
    width:32px;height:32px;border:1px solid var(--biz-border);border-radius:8px;background:#fff;
    cursor:pointer;font-weight:800;color:#555;
  }
  .settle-detail-row{display:none;background:#FAFBFC}
  .settle-detail-row.open{display:table-row}
  .settle-detail-wrap{padding:14px 16px 18px}
  .settle-detail-table{width:100%;border-collapse:collapse;font-size:13px;background:#fff}
  .settle-detail-table th{
    text-align:left;padding:8px 10px;background:#F8FAFC;border-bottom:1px solid #E4E6ED;color:#666;font-weight:700;
  }
  .settle-detail-table td{padding:8px 10px;border-bottom:1px solid #F0F0F0;color:#1A1A2E}
  .settle-detail-empty{color:#999;padding:12px 0;text-align:center}

  /* 4-1 중간정산 요청 모달 */
  .adhoc-modal-bg{display:none;position:fixed;inset:0;background:rgba(0,0,0,.45);z-index:1000;align-items:center;justify-content:center;padding:20px}
  .adhoc-modal-bg.open{display:flex}
  .adhoc-modal{background:#fff;border-radius:14px;width:100%;max-width:560px;max-height:90vh;overflow:auto;box-shadow:0 12px 40px rgba(0,0,0,.15)}
  .adhoc-modal-head{display:flex;justify-content:space-between;align-items:center;padding:18px 20px;border-bottom:1px solid #E2E8E4;position:sticky;top:0;background:#fff;z-index:1}
  .adhoc-modal-head h3{margin:0;font-size:17px;font-weight:800;color:#1A1A2E}
  .adhoc-modal-close{background:none;border:none;font-size:24px;cursor:pointer;color:#888;line-height:1}
  .adhoc-modal-body{padding:20px;display:flex;flex-direction:column;gap:14px}
  .adhoc-modal-foot{display:flex;gap:10px;padding:16px 20px;border-top:1px solid #E2E8E4;position:sticky;bottom:0;background:#fff}
  .adhoc-modal-foot .biz-btn{flex:1;text-align:center;padding:11px}
  .adhoc-modal-foot .biz-btn-primary{flex:2;text-align:center;padding:11px;border:none;border-radius:8px}
  .adhoc-note{font-size:12px;color:#666;line-height:1.55;background:#F8FAFC;border:1px dashed #D0D5DD;border-radius:8px;padding:10px 12px}
  .adhoc-note code{font-size:11px;background:#EEF2FF;color:#3730A3;padding:1px 5px;border-radius:4px}
  .adhoc-row{display:flex;flex-direction:column;gap:6px}
  .adhoc-row label{font-size:13px;font-weight:700;color:#333}
  .adhoc-row label .req{color:#E24B4A;margin-left:2px}
  .adhoc-hint{font-size:11px;color:#888;font-weight:500;line-height:1.4}
  .adhoc-row input[type="date"],
  .adhoc-row select,
  .adhoc-row textarea{
    border:1px solid var(--biz-border);border-radius:8px;padding:9px 11px;font-size:13px;color:#333;width:100%;box-sizing:border-box;
  }
  .adhoc-row textarea{min-height:72px;resize:vertical}
  .adhoc-row-2{display:grid;grid-template-columns:1fr 1fr;gap:12px}
  .adhoc-scope{display:flex;gap:14px;flex-wrap:wrap;font-size:13px}
  .adhoc-scope label{font-weight:600;display:flex;align-items:center;gap:6px;cursor:pointer}
  @media (max-width:600px){.adhoc-row-2{grid-template-columns:1fr}}
</style>

<main class="biz-main">
  <div class="biz-page-head settle-page-head">
    <div>
      <h1 class="biz-page-title">정산 내역</h1>
      <p class="biz-page-desc">월정산·중간정산 매출 및 지급 내역을 확인하세요. 행의 ▶ 로 예약 상세를 볼 수 있습니다.</p>
    </div>
    <%-- 4-1: 중간정산 요청 진입 버튼 (페이지 헤드 우측) --%>
    <button type="button" class="biz-btn-primary" id="btnOpenAdhoc" onclick="openAdhocModal()">중간정산 요청</button>
  </div>

  <div class="settle-summary">
    <div class="settle-summary-card">
      <div class="label">정산 예정액 (미지급)</div>
      <div class="val"><fmt:formatNumber value="${summary.pendingAmount}" pattern="#,###"/><span>원</span></div>
    </div>
    <div class="settle-summary-card">
      <div class="label">정산 완료액 (이번 달 입금)</div>
      <div class="val"><fmt:formatNumber value="${summary.paidAmount}" pattern="#,###"/><span>원</span></div>
    </div>
    <div class="settle-summary-card fee">
      <div class="label">누적 플랫폼 수수료</div>
      <div class="val"><fmt:formatNumber value="${summary.totalFeeAmount}" pattern="#,###"/><span>원</span></div>
    </div>
  </div>

  <div class="biz-card" style="margin-bottom:16px">
    <form class="settle-filter" method="get" action="${contextPath}/biz/stay/settlement">
      <span style="font-size:13px;color:#666">정산기간</span>
      <select name="month" onchange="this.form.submit()">
        <option value="all" <c:if test="${filterMonth eq 'all'}">selected</c:if>>전체</option>
        <c:forEach var="m" items="${settleMonths}">
          <option value="${m}" <c:if test="${filterMonth eq m}">selected</c:if>>${m}</option>
        </c:forEach>
      </select>
      <span style="font-size:13px;color:#666;margin-left:10px">정산상태</span>
      <select name="status" onchange="this.form.submit()">
        <option value="all" <c:if test="${filterStatus eq 'all'}">selected</c:if>>전체</option>
        <option value="pending" <c:if test="${filterStatus eq 'pending'}">selected</c:if>>지급대기</option>
        <option value="done" <c:if test="${filterStatus eq 'done'}">selected</c:if>>지급완료</option>
      </select>
      <%-- 2026/08/06 장우철 — 필터 줄 오른쪽 정산계좌 버튼 (숙소·쇼핑 공통) --%>
      <button type="button" class="biz-btn btn-settle-account" onclick="openSettleAccountModal()">정산계좌</button>
    </form>
  </div>

  <div class="biz-card">
    <div class="settle-table-head">
      <div class="biz-card-head" style="padding:20px 0 12px">
        <span>정산 내역</span>
        <small>총 <c:out value="${settlements.size()}"/>건</small>
      </div>
    </div>
    <table class="biz-table">
      <thead>
        <tr>
          <th style="width:48px"></th>
          <th>정산기간</th>
          <th>확정 매출</th>
          <th>플랫폼 수수료</th>
          <th>정산금액</th>
          <th>정산상태</th>
          <th>지급일</th>
        </tr>
      </thead>
      <tbody>
        <c:choose>
          <c:when test="${empty settlements}">
            <tr>
              <td colspan="7" style="text-align:center;color:#999;padding:24px 0">해당하는 정산 내역이 없습니다.</td>
            </tr>
          </c:when>
          <c:otherwise>
            <c:forEach var="s" items="${settlements}">
              <tr>
                <td>
                  <button type="button" class="settle-toggle"
                          data-settle-id="${s.settleId}"
                          onclick="toggleSettleDetail(this)"
                          aria-label="상세 보기">▶</button>
                </td>
                <td>
                  <c:choose>
                    <c:when test="${not empty s.periodStart and not empty s.periodEnd}">
                      <fmt:formatDate value="${s.periodStart}" pattern="yyyy-MM-dd"/>
                      ~
                      <fmt:formatDate value="${s.periodEnd}" pattern="yyyy-MM-dd"/>
                    </c:when>
                    <c:otherwise>
                      <c:out value="${s.settleMonth}"/>
                    </c:otherwise>
                  </c:choose>
                  <c:if test="${s.requestType eq 'ADHOC'}">
                    <span class="settle-type-tag">중간정산</span>
                  </c:if>
                  <c:if test="${s.requestType eq 'REGULAR' or empty s.requestType}">
                    <span class="settle-type-tag">월정산</span>
                  </c:if>
                </td>
                <td><fmt:formatNumber value="${s.totalSales}" pattern="#,###"/>원</td>
                <td>-<fmt:formatNumber value="${s.totalFee}" pattern="#,###"/>원</td>
                <td><b><fmt:formatNumber value="${s.settleAmount}" pattern="#,###"/>원</b></td>
                <td>
                  <c:choose>
                    <c:when test="${s.payStatus eq 'DONE'}">
                      <span class="bs-badge bs-done">지급완료</span>
                    </c:when>
                    <c:otherwise>
                      <span class="bs-badge bs-wait">지급대기</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <c:choose>
                    <c:when test="${not empty s.payDate}">
                      <fmt:formatDate value="${s.payDate}" pattern="yyyy-MM-dd"/>
                    </c:when>
                    <c:otherwise>-</c:otherwise>
                  </c:choose>
                </td>
              </tr>
              <tr class="settle-detail-row" id="detail-${s.settleId}">
                <td colspan="7">
                  <div class="settle-detail-wrap" data-loaded="N">
                    <div class="settle-detail-empty">불러오는 중...</div>
                  </div>
                </td>
              </tr>
            </c:forEach>
          </c:otherwise>
        </c:choose>
      </tbody>
    </table>
  </div>
</main>

<%-- 2026/08/06 장우철 — 정산계좌 조회/변경 모달 (숙소) --%>
<div class="adhoc-modal-bg" id="settleAccountModalBg" onclick="if(event.target===this) closeSettleAccountModal()">
  <div class="adhoc-modal" role="dialog" aria-labelledby="settleAccountModalTitle">
    <div class="adhoc-modal-head">
      <h3 id="settleAccountModalTitle">정산 계좌</h3>
      <button type="button" class="adhoc-modal-close" onclick="closeSettleAccountModal()" aria-label="닫기">×</button>
    </div>
    <div class="adhoc-modal-body">
      <div class="adhoc-note">
        현재 등록된 정산 계좌를 확인하고, 변경 시 <b>계좌 인증</b> 후 저장하세요.<br>
        인증은 사업자 신청과 동일한 금결원(mock/실연동) API를 사용합니다.
      </div>
      <div class="adhoc-row">
        <label>은행<span class="req">*</span></label>
        <select id="saBankName">
          <option value="">은행 선택</option>
          <option value="004" data-name="국민">국민</option>
          <option value="088" data-name="신한">신한</option>
          <option value="020" data-name="우리">우리</option>
          <option value="081" data-name="하나">하나</option>
          <option value="011" data-name="농협">농협</option>
          <option value="090" data-name="카카오뱅크">카카오뱅크</option>
          <option value="092" data-name="토스뱅크">토스뱅크</option>
        </select>
      </div>
      <div class="adhoc-row">
        <label>예금주<span class="req">*</span></label>
        <input type="text" id="saAccountHolder" placeholder="대표자명 또는 법인명"
               style="border:1px solid var(--biz-border);border-radius:8px;padding:9px 11px;font-size:13px;width:100%;box-sizing:border-box">
      </div>
      <div class="adhoc-row">
        <label>계좌번호<span class="req">*</span></label>
        <div style="display:flex;gap:8px">
          <input type="text" id="saBankAccount" placeholder="숫자만 입력" maxlength="20"
                 style="flex:1;border:1px solid var(--biz-border);border-radius:8px;padding:9px 11px;font-size:13px">
          <button type="button" class="biz-btn" id="btnSaVerify" onclick="verifySettleAccount()">계좌 인증</button>
        </div>
        <p id="saVerifyResult" class="adhoc-hint" style="margin:4px 0 0"></p>
      </div>
      <input type="hidden" id="saSettleBank" value="">
      <input type="hidden" id="saSettleBankCode" value="">
      <input type="hidden" id="saSettleAccount" value="">
      <input type="hidden" id="saSettleHolder" value="">
      <input type="hidden" id="saSettleVerifyYn" value="">
      <input type="hidden" id="saBizRegNo" value="<c:out value='${settleAccountInfo.bizRegNo}'/>">
    </div>
    <div class="adhoc-modal-foot">
      <button type="button" class="biz-btn" onclick="closeSettleAccountModal()">닫기</button>
      <button type="button" class="biz-btn-primary" id="btnSaSave" onclick="saveSettleAccount()">저장</button>
    </div>
  </div>
</div>

<%-- ===== 4-1 중간정산 요청 모달 ===== --%>
<div class="adhoc-modal-bg" id="adhocModalBg" onclick="if(event.target===this) closeAdhocModal()">
  <div class="adhoc-modal" role="dialog" aria-labelledby="adhocModalTitle">
    <div class="adhoc-modal-head">
      <h3 id="adhocModalTitle">중간정산 요청</h3>
      <button type="button" class="adhoc-modal-close" onclick="closeAdhocModal()" aria-label="닫기">×</button>
    </div>
    <div class="adhoc-modal-body">
      <div class="adhoc-note">
        중간정산 요청 시 <code>TB_SETTLEMENT_REQUEST</code> 에 저장됩니다 (STATUS=<code>REQUESTED</code>).<br>
        시작일은 <b>컷오프가 속한 달의 1일</b>로 고정됩니다. 관리자 승인 후 정산 마스터가 생성됩니다.
      </div>

      <div class="adhoc-row">
        <label>정산 범위<span class="req">*</span></label>
        <div class="adhoc-hint">DB: <code>REQUEST_SCOPE</code> = ALL(전 객실) / ROOM(특정 객실)</div>
        <div class="adhoc-scope">
          <label><input type="radio" name="adhocScope" value="ALL" checked onchange="toggleAdhocRoom()"> 숙소 전체 (ALL)</label>
          <label><input type="radio" name="adhocScope" value="ROOM" onchange="toggleAdhocRoom()"> 특정 객실 (ROOM)</label>
        </div>
      </div>

      <div class="adhoc-row" id="adhocRoomRow" style="display:none">
        <label>객실 선택<span class="req">*</span></label>
        <div class="adhoc-hint">DB: <code>ROOM_ID</code> · ROOM일 때만 필수</div>
        <select id="adhocRoomId">
          <option value="">객실을 선택하세요</option>
          <c:choose>
            <c:when test="${empty roomList}">
              <option value="" disabled>등록된 객실이 없습니다</option>
            </c:when>
            <c:otherwise>
              <c:forEach var="r" items="${roomList}">
                <option value="${r.roomId}"><c:out value="${r.name}"/> (roomId=${r.roomId})</option>
              </c:forEach>
            </c:otherwise>
          </c:choose>
        </select>
      </div>

      <div class="adhoc-row-2">
        <div class="adhoc-row">
          <label>대상 시작일 (고정)</label>
          <div class="adhoc-hint">DB: <code>TARGET_START</code> · 매월 1일 고정 · 서버에서도 재계산</div>
          <input type="date" id="adhocStart" readonly style="background:#F8FAFC;color:#555">
        </div>
        <div class="adhoc-row">
          <label>대상 종료일(컷오프)<span class="req">*</span></label>
          <div class="adhoc-hint">DB: <code>TARGET_END</code> · 이 날까지 체크아웃·미정산만</div>
          <input type="date" id="adhocEnd" onchange="syncAdhocStart()">
        </div>
      </div>

      <div class="adhoc-row">
        <label>요청 메모</label>
        <div class="adhoc-hint">DB: <code>REQUEST_MEMO</code> · 선택</div>
        <textarea id="adhocMemo" placeholder="예: 8월 중순까지 먼저 정산 부탁드립니다."></textarea>
      </div>

      <div class="adhoc-note">
        · 지급 예정: 요청일 + 2일 (관리자 승인·지급 후)<br>
        · 집계: 기간 내 <b>체크아웃 + 미정산</b> 예약만 · 이미 정산된 ITEM 제외<br>
        · 서버 자동: <code>BIZ_NO</code>, <code>STATUS_CD=REQUESTED</code>, <code>REQUESTED_AT</code>
      </div>
    </div>
    <div class="adhoc-modal-foot">
      <button type="button" class="biz-btn" onclick="closeAdhocModal()">취소</button>
      <button type="button" class="biz-btn-primary" id="btnAdhocSubmit" onclick="submitAdhocRequest()">요청하기</button>
    </div>
  </div>
</div>

<script>
  var CTX = '${contextPath}';
  var settleAccountVerified = false;
  var initialSettle = {
    bankCode: '<c:out value="${settleAccountInfo.settleBankCode}"/>',
    bankName: '<c:out value="${settleAccountInfo.settleBank}"/>',
    account: '<c:out value="${settleAccountInfo.settleAccount}"/>',
    holder: '<c:out value="${settleAccountInfo.settleHolder}"/>',
    verifyYn: '<c:out value="${settleAccountInfo.settleVerifyYn}"/>'
  };

  function clearSettleAccountVerify() {
    settleAccountVerified = false;
    document.getElementById('saSettleBank').value = '';
    document.getElementById('saSettleBankCode').value = '';
    document.getElementById('saSettleAccount').value = '';
    document.getElementById('saSettleHolder').value = '';
    document.getElementById('saSettleVerifyYn').value = '';
    document.getElementById('saVerifyResult').textContent = '';
  }

  function openSettleAccountModal() {
    clearSettleAccountVerify();
    var bankSel = document.getElementById('saBankName');
    bankSel.value = initialSettle.bankCode || '';
    document.getElementById('saAccountHolder').value = initialSettle.holder || '';
    document.getElementById('saBankAccount').value = initialSettle.account || '';
    if (initialSettle.verifyYn === 'Y' && initialSettle.account) {
      document.getElementById('saVerifyResult').style.color = '#2BAB82';
      document.getElementById('saVerifyResult').textContent =
        '등록된 계좌: ' + (initialSettle.bankName || '') + ' / ' + (initialSettle.holder || '') + ' (변경 시 재인증 필요)';
    }
    document.getElementById('settleAccountModalBg').classList.add('open');
  }

  function closeSettleAccountModal() {
    document.getElementById('settleAccountModalBg').classList.remove('open');
  }

  function verifySettleAccount() {
    var bankSel = document.getElementById('saBankName');
    var selected = bankSel.options[bankSel.selectedIndex];
    var bankCode = selected.value;
    var bankName = selected.getAttribute('data-name') || selected.textContent;
    var holder = document.getElementById('saAccountHolder').value.trim();
    var acct = document.getElementById('saBankAccount').value.replace(/[^0-9]/g, '');
    var bizRegNo = document.getElementById('saBizRegNo').value || '';

    if (!bankCode) { alert('은행을 선택하세요.'); return; }
    if (!holder) { alert('예금주를 입력하세요.'); return; }
    if (acct.length < 8) { alert('계좌번호를 입력하세요.'); return; }

    var btn = document.getElementById('btnSaVerify');
    btn.disabled = true;
    btn.textContent = '인증중...';

    var fd = new URLSearchParams();
    fd.set('bankCodeStd', bankCode);
    fd.set('bankName', bankName);
    fd.set('accountNum', acct);
    fd.set('accountHolder', holder);
    fd.set('bizRegNo', bizRegNo);

    csrfFetch(CTX + '/mypage/biz/account/verify', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'Accept': 'application/json' },
      body: fd.toString()
    })
      .then(function (r) { return r.json(); })
      .then(function (res) {
        if (res && res.success) {
          settleAccountVerified = true;
          document.getElementById('saBankAccount').value = res.accountNum || acct;
          document.getElementById('saSettleBank').value = res.bankName || bankName;
          document.getElementById('saSettleBankCode').value = res.bankCodeStd || bankCode;
          document.getElementById('saSettleAccount').value = res.accountNum || acct;
          document.getElementById('saSettleHolder').value = res.accountHolderName || holder;
          document.getElementById('saSettleVerifyYn').value = 'Y';
          document.getElementById('saVerifyResult').style.color = '#2BAB82';
          document.getElementById('saVerifyResult').textContent =
            '계좌 인증 완료 · ' + (res.bankName || bankName) + ' / ' + (res.accountHolderName || holder)
            + (res.mock ? ' (더미)' : '');
        } else {
          clearSettleAccountVerify();
          document.getElementById('saVerifyResult').style.color = '#E24B4A';
          document.getElementById('saVerifyResult').textContent =
            (res && res.message) ? res.message : '계좌 인증에 실패했습니다.';
        }
      })
      .catch(function () {
        clearSettleAccountVerify();
        document.getElementById('saVerifyResult').style.color = '#E24B4A';
        document.getElementById('saVerifyResult').textContent = '계좌 인증 요청 중 오류가 발생했습니다.';
      })
      .finally(function () {
        btn.disabled = false;
        btn.textContent = '계좌 인증';
      });
  }

  function saveSettleAccount() {
    if (!settleAccountVerified || document.getElementById('saSettleVerifyYn').value !== 'Y') {
      alert('계좌 인증을 완료한 뒤 저장해 주세요.');
      return;
    }
    var fd = new URLSearchParams();
    fd.set('settleBank', document.getElementById('saSettleBank').value);
    fd.set('settleBankCode', document.getElementById('saSettleBankCode').value);
    fd.set('settleAccount', document.getElementById('saSettleAccount').value);
    fd.set('settleHolder', document.getElementById('saSettleHolder').value);
    fd.set('settleVerifyYn', 'Y');

    var btn = document.getElementById('btnSaSave');
    btn.disabled = true;
    csrfFetch(CTX + '/biz/stay/settlement/account', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'Accept': 'application/json' },
      body: fd.toString()
    })
      .then(function (r) { return r.json(); })
      .then(function (data) {
        alert(data.message || (data.ok ? '저장 완료' : '저장 실패'));
        if (data.ok) location.reload();
      })
      .catch(function () { alert('저장 중 오류가 발생했습니다.'); })
      .finally(function () { btn.disabled = false; });
  }

  document.getElementById('saBankName').addEventListener('change', clearSettleAccountVerify);
  document.getElementById('saAccountHolder').addEventListener('input', clearSettleAccountVerify);
  document.getElementById('saBankAccount').addEventListener('input', clearSettleAccountVerify);

  /* ----- 4-2 중간정산 요청 ----- */
  function firstDayOfMonthStr(yyyyMmDd) {
    if (!yyyyMmDd || yyyyMmDd.length < 7) return '';
    return yyyyMmDd.substring(0, 7) + '-01';
  }
  function todayStr() {
    var d = new Date();
    var m = String(d.getMonth() + 1).padStart(2, '0');
    var day = String(d.getDate()).padStart(2, '0');
    return d.getFullYear() + '-' + m + '-' + day;
  }
  function syncAdhocStart() {
    var end = document.getElementById('adhocEnd').value;
    document.getElementById('adhocStart').value = firstDayOfMonthStr(end);
  }
  function openAdhocModal() {
    var endEl = document.getElementById('adhocEnd');
    if (!endEl.value) endEl.value = todayStr();
    syncAdhocStart();
    document.getElementById('adhocModalBg').classList.add('open');
  }
  function closeAdhocModal() {
    document.getElementById('adhocModalBg').classList.remove('open');
  }
  function toggleAdhocRoom() {
    var scope = document.querySelector('input[name="adhocScope"]:checked');
    var row = document.getElementById('adhocRoomRow');
    row.style.display = (scope && scope.value === 'ROOM') ? '' : 'none';
  }
  function submitAdhocRequest() {
    var scopeEl = document.querySelector('input[name="adhocScope"]:checked');
    var scope = scopeEl ? scopeEl.value : '';
    var roomId = document.getElementById('adhocRoomId').value;
    var end = document.getElementById('adhocEnd').value;
    var memo = document.getElementById('adhocMemo').value;
    syncAdhocStart();
    var start = document.getElementById('adhocStart').value;

    if (!end) {
      alert('대상 종료일(컷오프)을 입력하세요.');
      return;
    }
    if (scope === 'ROOM' && !roomId) {
      alert('특정 객실 범위일 때 객실을 선택하세요.');
      return;
    }

    if (!confirm('중간정산을 요청할까요?\n기간: ' + start + ' ~ ' + end
        + (scope === 'ROOM' ? '\n객실: #' + roomId : '\n범위: 숙소 전체'))) {
      return;
    }

    var btn = document.getElementById('btnAdhocSubmit');
    btn.disabled = true;
    csrfFetch(CTX + '/biz/stay/settlement/request', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
      body: JSON.stringify({
        requestScope: scope,
        roomId: scope === 'ROOM' ? Number(roomId) : null,
        targetEnd: end,
        requestMemo: memo
      })
    })
      .then(function (r) { return r.json(); })
      .then(function (data) {
        alert(data.message || (data.ok ? '요청 완료' : '요청 실패'));
        if (data.ok) {
          closeAdhocModal();
          location.reload();
        }
      })
      .catch(function () { alert('요청 중 오류가 발생했습니다.'); })
      .finally(function () { btn.disabled = false; });
  }

    function fmtWon(n) {
    if (n == null || n === '') return '0원';
    return Number(n).toLocaleString('ko-KR') + '원';
  }

  function fmtDate(v) {
    if (!v) return '-';
    // JSON 날짜: "2026-07-01" 또는 epoch ms
    if (typeof v === 'number') {
      var d = new Date(v);
      var y = d.getFullYear();
      var m = String(d.getMonth() + 1).padStart(2, '0');
      var day = String(d.getDate()).padStart(2, '0');
      return y + '-' + m + '-' + day;
    }
    return String(v).substring(0, 10);
  }

  function toggleSettleDetail(btn) {
    var settleId = btn.getAttribute('data-settle-id');
    var detailRow = document.getElementById('detail-' + settleId);
    if (!detailRow) return;

    var open = detailRow.classList.contains('open');
    if (open) {
      detailRow.classList.remove('open');
      btn.textContent = '▶';
      return;
    }

    detailRow.classList.add('open');
    btn.textContent = '▼';

    var wrap = detailRow.querySelector('.settle-detail-wrap');
    if (wrap.getAttribute('data-loaded') === 'Y') return;

    fetch(CTX + '/biz/stay/settlement/items?settleId=' + encodeURIComponent(settleId), {
      headers: { 'Accept': 'application/json' }
    })
      .then(function (res) { return res.json(); })
      .then(function (data) {
        if (!data.ok) {
          wrap.innerHTML = '<div class="settle-detail-empty">' + (data.message || '조회 실패') + '</div>';
          wrap.setAttribute('data-loaded', 'Y');
          return;
        }
        var items = data.items || [];
        if (items.length === 0) {
          wrap.innerHTML = '<div class="settle-detail-empty">포함된 예약 상세가 없습니다.</div>';
          wrap.setAttribute('data-loaded', 'Y');
          return;
        }

        var html = '<table class="settle-detail-table"><thead><tr>'
          + '<th>구분</th><th>예약번호</th><th>객실</th><th>체크인</th><th>체크아웃</th>'
          + '<th>금액</th><th>수수료</th><th>정산금</th><th>상태</th>'
          + '</tr></thead><tbody>';

        items.forEach(function (it) {
          var typeLabel = (it.itemType === 'CANCEL_FEE') ? '위약금' : '숙박';
          html += '<tr>'
            + '<td>' + typeLabel + '</td>'
            + '<td>' + (it.resvNo || it.resvId || '-') + '</td>'
            + '<td>' + (it.roomName || it.roomId || '-') + '</td>'
            + '<td>' + fmtDate(it.checkinDate) + '</td>'
            + '<td>' + fmtDate(it.checkoutDate) + '</td>'
            + '<td>' + fmtWon(it.resvAmount) + '</td>'
            + '<td>-' + fmtWon(it.feeAmount) + '</td>'
            + '<td><b>' + fmtWon(it.settleAmount) + '</b></td>'
            + '<td>' + (it.statusCd || '-') + '</td>'
            + '</tr>';
        });
        html += '</tbody></table>';
        wrap.innerHTML = html;
        wrap.setAttribute('data-loaded', 'Y');
      })
      .catch(function () {
        wrap.innerHTML = '<div class="settle-detail-empty">상세 조회 중 오류가 발생했습니다.</div>';
      });
  }
</script>

<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>
