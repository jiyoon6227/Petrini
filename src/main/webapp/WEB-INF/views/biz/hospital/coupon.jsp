<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
  역할: 사업자 쿠폰 승인신청 화면 (biz/hospital/coupon)

  [화면 흐름]
  1. GET /biz/hospital/coupon → 본인 쿠폰 목록 표시
  2. 신규 신청 모달 → POST /biz/hospital/coupon/apply (PENDING)
  3. PENDING 쿠폰 수정/삭제 가능
  4. 관리자 승인 후 사용자 이벤트/쿠폰 게시판 노출
  2026-08-13 박유정 — validateForm 빈 숫자칸 제거 + Controller @InitBinder (Integer 바인딩 오류 방지)

  [model]
  - couponList, msg, errorMsg
--%>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="contextPath"  value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="동물병원" />
<c:set var="bizPage" value="coupon" />

<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_hospital.jsp" %>

<style>
    /* ── 쿠폰 카드 그리드 ── */
    .cpn-grid { display:grid; grid-template-columns:repeat(auto-fill, minmax(340px, 1fr)); gap:16px; }
    
    .cpn-card {
        background:#fff; border:1px solid #E4E6ED; border-radius:12px;
        overflow:hidden; transition:box-shadow .2s;
    }
    .cpn-card:hover { box-shadow:0 4px 16px rgba(0,0,0,.07); }
    
    .cpn-card-head {
        display:flex; align-items:center; justify-content:space-between;
        padding:16px 20px; border-bottom:1px solid #E4E6ED; background:#FAFBFC;
    }
    .cpn-card-name { font-size:15px; font-weight:700; color:#1A1A2E; }
    .cpn-card-code { font-size:11px; color:#999; margin-top:2px; }
    
    .cpn-badge {
        font-size:11px; font-weight:700; padding:3px 10px; border-radius:20px;
    }
    .cpn-badge.pending  { background:#FEF3C7; color:#D97706; }
    .cpn-badge.approved { background:#DCFCE7; color:#16A34A; }
    .cpn-badge.rejected { background:#FEE2E2; color:#DC2626; }
    .cpn-badge.exhausted { background:#F1F3F7; color:#999; }
    /* 지윤 26.08.07: 조기 마감 상태 */
    .cpn-badge.closed { background:#F1F3F7; color:#666; }
    
    .cpn-card-body {
        display:grid; grid-template-columns:1fr 1fr; border-bottom:1px solid #E4E6ED;
    }
    .cpn-field { padding:12px 18px; border-right:1px solid #E4E6ED; }
    .cpn-field:nth-child(2n) { border-right:none; }
    .cpn-field label { font-size:11px; color:#999; font-weight:600; display:block; margin-bottom:3px; }
    .cpn-field span  { font-size:13px; color:#1A1A2E; font-weight:500; }
    
    .cpn-card-foot {
        display:flex; align-items:center; justify-content:space-between;
        padding:12px 18px; gap:8px;
    }
    .cpn-card-foot .reject-reason {
        font-size:12px; color:#DC2626; flex:1;
    }
    
    /* ── 버튼 ── */
    .cpn-btn {
        border:none; border-radius:6px; padding:7px 16px; font-size:13px;
        font-weight:600; cursor:pointer; font-family:inherit; transition:background .15s;
    }
    .cpn-btn.primary { background:#3B5BDB; color:#fff; }
    .cpn-btn.primary:hover { background:#364FC7; }
    .cpn-btn.gray    { background:#F1F3F7; color:#555; }
    .cpn-btn.gray:hover { background:#E4E6ED; }
    .cpn-btn.red     { background:#FEE2E2; color:#DC2626; }
    .cpn-btn.red:hover { background:#FECACA; }
    
    /* ── 모달 ── */
    .cpn-modal-overlay {
        display:none; position:fixed; inset:0; background:rgba(0,0,0,.45);
        z-index:1000; justify-content:center; align-items:center;
    }
    .cpn-modal-overlay.show { display:flex; }
    .cpn-modal {
        background:#fff; border-radius:16px; width:520px; max-height:90vh;
        overflow-y:auto; box-shadow:0 20px 60px rgba(0,0,0,.2);
    }
    .cpn-modal-head {
        display:flex; align-items:center; justify-content:space-between;
        padding:20px 24px; border-bottom:1px solid #E4E6ED;
    }
    .cpn-modal-head h2 { font-size:18px; font-weight:800; color:#1A1A2E; margin:0; }
    .cpn-modal-close {
        background:none; border:none; font-size:22px; color:#999; cursor:pointer; line-height:1;
    }
    .cpn-modal-body { padding:24px; }
    .cpn-form-group { margin-bottom:18px; }
    .cpn-form-group label {
        display:block; font-size:13px; font-weight:600; color:#555; margin-bottom:6px;
    }
    .cpn-form-group input,
    .cpn-form-group select {
        width:100%; border:1px solid #E4E6ED; border-radius:8px;
        padding:10px 14px; font-size:14px; color:#333; font-family:inherit;
        outline:none; box-sizing:border-box;
    }
    .cpn-form-group input:focus,
    .cpn-form-group select:focus { border-color:#3B5BDB; }
    .cpn-form-row { display:grid; grid-template-columns:1fr 1fr; gap:12px; }
    .cpn-modal-foot {
        display:flex; justify-content:flex-end; gap:8px;
        padding:16px 24px; border-top:1px solid #E4E6ED;
    }
    
    /* ── 예산 프로그레스 ── */
    .cpn-progress-bar {
        background:#F1F3F7; border-radius:4px; height:6px; margin-top:6px; overflow:hidden;
    }
    .cpn-progress-fill {
        height:100%; border-radius:4px; background:#3B5BDB; transition:width .3s;
    }
    
    /* ── 빈 상태 ── */
    .cpn-empty {
        text-align:center; color:#999; padding:60px 0;
    }
    .cpn-empty svg { width:48px; height:48px; stroke:#ccc; margin-bottom:12px; }
</style>

<main class="biz-main hospital-dashboard">
    <div class="dashboard-top">
        <div>
            <h1>쿠폰 승인 신청</h1>
            <p>쿠폰을 등록하고 관리자 승인을 받으면 사용자 이벤트/쿠폰 게시판에 노출됩니다.</p>
        </div>
        <button class="cpn-btn primary" onclick="openApplyModal()" style="height:fit-content">
            + 쿠폰 신청
        </button>
    </div>

    <%-- 알림 메시지 --%>
    <c:if test="${not empty msg}">
        <div style="background:#ECFDF5;border:1px solid #BBF7D0;color:#166534;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:14px">
            ${msg}
        </div>
    </c:if>
    <c:if test="${not empty errorMsg}">
        <div style="background:#FEF2F2;border:1px solid #FECACA;color:#B91C1C;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:14px">
            ${errorMsg}
        </div>
    </c:if>

    <%-- 플로우 안내 --%>
    <div style="display:flex;align-items:center;gap:0;margin-bottom:24px;background:#fff;border:1px solid #E4E6ED;border-radius:12px;overflow:hidden">
        <div style="flex:1;padding:14px 16px;text-align:center;background:#EEF2FF;border-right:1px solid #E4E6ED">
            <div style="font-size:11px;color:#3B5BDB;margin-bottom:3px;font-weight:700">STEP 1 (현재)</div>
            <div style="font-size:13px;font-weight:800;color:#3B5BDB">쿠폰 신청</div>
        </div>
        <div style="color:#C7D2FE;font-size:18px;padding:0 4px">›</div>
        <div style="flex:1;padding:14px 16px;text-align:center;border-right:1px solid #E4E6ED">
            <div style="font-size:11px;color:#999;margin-bottom:3px">STEP 2</div>
            <div style="font-size:13px;font-weight:700;color:#1A1A2E">관리자 승인</div>
        </div>
        <div style="color:#C7D2FE;font-size:18px;padding:0 4px">›</div>
        <div style="flex:1;padding:14px 16px;text-align:center">
            <div style="font-size:11px;color:#999;margin-bottom:3px">STEP 3</div>
            <div style="font-size:13px;font-weight:700;color:#1A1A2E">이벤트/쿠폰 게시판 노출</div>
        </div>
    </div>

    <%-- 쿠폰 목록 --%>
    <c:choose>
        <c:when test="${empty couponList}">
            <div class="cpn-empty">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
                    <rect x="2" y="5" width="20" height="14" rx="2"/><line x1="2" y1="10" x2="22" y2="10"/>
                </svg>
                <p>등록된 쿠폰이 없습니다.<br>상단의 '쿠폰 신청' 버튼으로 쿠폰을 등록해보세요.</p>
            </div>
        </c:when>
        <c:otherwise>
            <div class="cpn-grid">
                <c:forEach var="cpn" items="${couponList}">
                    <div class="cpn-card">
                        <div class="cpn-card-head">
                            <div>
                                <div class="cpn-card-name">${cpn.couponName}</div>
                                <div class="cpn-card-code">${cpn.couponCode}</div>
                            </div>
                            <c:choose>
                                <c:when test="${cpn.approvalStatus eq 'PENDING'}">
                                    <span class="cpn-badge pending">승인 대기</span>
                                </c:when>
                                <%-- 지윤 26.08.07: 사업자가 조기 마감한 쿠폰 --%>
                                <c:when test="${cpn.approvalStatus eq 'APPROVED' && cpn.statusCd eq 'INACTIVE'}">
                                    <span class="cpn-badge closed">조기 마감</span>
                                </c:when>
                                <c:when test="${cpn.approvalStatus eq 'APPROVED' && cpn.statusCd eq 'EXHAUSTED'}">
                                    <span class="cpn-badge exhausted">예산 소진</span>
                                </c:when>
                                <c:when test="${cpn.approvalStatus eq 'APPROVED'}">
                                    <span class="cpn-badge approved">승인 (게시 중)</span>
                                </c:when>
                                <c:when test="${cpn.approvalStatus eq 'REJECTED'}">
                                    <span class="cpn-badge rejected">반려</span>
                                </c:when>
                            </c:choose>
                        </div>
                        <div class="cpn-card-body">
                            <div class="cpn-field">
                                <label>할인 유형</label>
                                <span>
                                    <c:choose>
                                        <c:when test="${cpn.couponType eq 'FIXED'}">정액 할인</c:when>
                                        <c:when test="${cpn.couponType eq 'RATE'}">정률 할인</c:when>
                                    </c:choose>
                                </span>
                            </div>
                            <div class="cpn-field">
                                <label>할인값</label>
                                <span>
                                    <c:choose>
                                        <c:when test="${cpn.couponType eq 'FIXED'}">
                                            <fmt:formatNumber value="${cpn.discountValue}" type="number"/>원
                                        </c:when>
                                        <c:when test="${cpn.couponType eq 'RATE'}">
                                            ${cpn.discountValue}%
                                        </c:when>
                                    </c:choose>
                                </span>
                            </div>
                            <div class="cpn-field">
                                <label>총 예산 / 소진</label>
                                <span>
                                    <fmt:formatNumber value="${cpn.totalBudget}" type="number"/>원
                                    / <fmt:formatNumber value="${cpn.issuedBudget}" type="number"/>원
                                </span>
                                <c:if test="${cpn.totalBudget > 0}">
                                    <div class="cpn-progress-bar">
                                        <div class="cpn-progress-fill"
                                             style="width:${cpn.issuedBudget * 100 / cpn.totalBudget}%"></div>
                                    </div>
                                </c:if>
                            </div>
                            <div class="cpn-field">
                                <label>발급 수량</label>
                                <span>${cpn.issuedQty} / ${cpn.totalQty}장</span>
                            </div>
                            <div class="cpn-field">
                                <label>최소 주문 금액</label>
                                <span><fmt:formatNumber value="${cpn.minOrderAmt}" type="number"/>원</span>
                            </div>
                            <div class="cpn-field">
                                <label>사용 기간</label>
                                <span>
                                    ${cpn.useStartDate.substring(0,4)}.${cpn.useStartDate.substring(4,6)}.${cpn.useStartDate.substring(6,8)}
                                    ~
                                    ${cpn.useEndDate.substring(0,4)}.${cpn.useEndDate.substring(4,6)}.${cpn.useEndDate.substring(6,8)}
                                </span>
                            </div>
                        </div>
                        <div class="cpn-card-foot">
                            <c:if test="${cpn.approvalStatus eq 'REJECTED' && not empty cpn.rejectReason}">
                                <div class="reject-reason">반려 사유: ${cpn.rejectReason}</div>
                            </c:if>
                            <c:if test="${cpn.approvalStatus eq 'PENDING'}">
                                <div></div>
                                <div style="display:flex;gap:6px">
                                    <form method="post" action="${contextPath}/biz/hospital/coupon/delete"
                                          onsubmit="return confirm('삭제하시겠습니까?')">
                                        <%-- HYJ 26.08.05 / 지윤 26.08.07 CSRF --%>
                                        <input type="hidden" name="_csrf" value="${_csrf}">
                                        <input type="hidden" name="couponId" value="${cpn.couponId}">
                                        <button type="submit" class="cpn-btn red">삭제</button>
                                    </form>
                                </div>
                            </c:if>

                            <%-- 지윤 26.08.07: 게시 중인 쿠폰만 조기 마감 가능 --%>
                            <c:if test="${cpn.approvalStatus eq 'APPROVED' && cpn.statusCd eq 'ACTIVE'}">
                                <div></div>
                                <form method="post" action="${contextPath}/biz/hospital/coupon/close"
                                      onsubmit="return confirm('쿠폰을 조기 마감하시겠습니까?\n마감 후 이벤트 화면에서 사라집니다.')">
                                    <%-- 2026/08/07 장우철 · 지윤 26.08.07 CSRF --%>
                                    <input type="hidden" name="_csrf" value="${_csrf}">
                                    <input type="hidden" name="couponId" value="${cpn.couponId}">
                                    <button type="submit" class="cpn-btn red">조기 마감</button>
                                </form>
                            </c:if>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</main>

<%-- 쿠폰 신청 모달 --%>
<div class="cpn-modal-overlay" id="applyModal">
    <div class="cpn-modal">
        <div class="cpn-modal-head">
            <h2>쿠폰 승인 신청</h2>
            <button class="cpn-modal-close" onclick="closeApplyModal()">&times;</button>
        </div>
        <form method="post" action="${contextPath}/biz/hospital/coupon/apply" onsubmit="return validateForm()">
            <%-- HYJ 26.08.05 / 지윤 26.08.07 CSRF --%>
            <input type="hidden" name="_csrf" value="${_csrf}">
            <div class="cpn-modal-body">
            
                <div class="cpn-form-group">
                    <label>쿠폰명 <span style="color:#DC2626">*</span></label>
                    <input type="text" name="couponName" id="couponName" placeholder="예: 여름 할인 쿠폰" required>
                </div>
                <div class="cpn-form-row">
                    <div class="cpn-form-group">
                        <label>할인 유형 <span style="color:#DC2626">*</span></label>
                        <select name="couponType" id="couponType" required onchange="toggleDiscountLabel()">
                            <option value="FIXED">정액 할인 (원)</option>
                            <option value="RATE">정률 할인 (%)</option>
                        </select>
                    </div>
                   <div class="cpn-form-group">
    <label id="discountLabel">할인 금액 (원) <span style="color:#DC2626">*</span></label>
    <input type="number" name="discountValue" id="discountValue"
           placeholder="0" min="1" required oninput="calcTotalBudget()">
</div>
</div>
<div class="cpn-form-row" id="maxDiscountRow" style="display:none">
    <div class="cpn-form-group">
        <label>최대 할인 금액 (원) <span style="color:#DC2626">*</span></label>
        <input type="number" id="maxDiscountAmt"
               placeholder="0" min="1" oninput="calcTotalBudget()">
    </div>
</div>
<div class="cpn-form-row">
    <div class="cpn-form-group">
        <label>총 예산 (원, 자동계산) <span style="color:#DC2626">*</span></label>
        <input type="number" name="totalBudget" id="totalBudget"
       placeholder="0" min="1" required readonly
       style="background:#F3F4F6; cursor:not-allowed;">
    </div>
    <div class="cpn-form-group">
        <label>발급 수량 (장) <span style="color:#DC2626">*</span></label>
        <input type="number" name="totalQty" id="totalQty"
               placeholder="0" min="1" required oninput="calcTotalBudget()">
    </div>
</div>
<div class="cpn-form-group">
    <label>최소 주문 금액 (원)</label>
    <input type="number" name="minOrderAmt" id="minOrderAmt" placeholder="0" min="0">
</div>
                <div class="cpn-form-row">
                    <div class="cpn-form-group">
                        <label>사용 시작일 <span style="color:#DC2626">*</span></label>
                        <input type="date" name="useStartDateInput" id="useStartDateInput" required>
                    </div>
                    <div class="cpn-form-group">
                        <label>사용 종료일 <span style="color:#DC2626">*</span></label>
                        <input type="date" name="useEndDateInput" id="useEndDateInput" required>
                    </div>
                </div>
                <%-- 히든 필드: YYYYMMDD 변환 --%>
                <input type="hidden" name="useStartDate" id="useStartDate">
                <input type="hidden" name="useEndDate"   id="useEndDate">
            </div>
            <div class="cpn-modal-foot">
                <button type="button" class="cpn-btn gray" onclick="closeApplyModal()">취소</button>
                <button type="submit" class="cpn-btn primary">신청하기</button>
            </div>
        </form>
    </div>
</div>

<script>
function openApplyModal() {
    document.getElementById('couponName').value = '';
    document.getElementById('discountValue').value = '';
    document.getElementById('maxDiscountAmt').value = '';
    document.getElementById('totalBudget').value = '';
    document.getElementById('totalQty').value = '';
    document.getElementById('minOrderAmt').value = '';
    document.getElementById('useStartDateInput').value = '';
    document.getElementById('useEndDateInput').value = '';
    document.getElementById('couponType').value = 'FIXED';
    toggleDiscountLabel();
    document.getElementById('applyModal').classList.add('show');
}
function closeApplyModal() {
    document.getElementById('applyModal').classList.remove('show');
}

function toggleDiscountLabel() {
    var type = document.getElementById('couponType').value;
    var label = document.getElementById('discountLabel');
    var input = document.getElementById('discountValue');
    var maxRow = document.getElementById('maxDiscountRow');
    var maxInput = document.getElementById('maxDiscountAmt');
    input.value = ''; // 할인유형 바뀌면 이전 값(정액 5000원 → 정률 5000%로 남는 것) 초기화
    document.getElementById('totalQty').value = ''; // 발급수량도 할인유형 바뀔 때 초기화
    if (type === 'RATE') {
        label.innerHTML = '할인율 (%) <span style="color:#DC2626">*</span>';
        input.placeholder = '0';
        input.max = 100;
        maxRow.style.display = '';
        maxInput.setAttribute('required', 'required');
        maxInput.setAttribute('name', 'maxDiscountAmt');
    } else {
        label.innerHTML = '할인 금액 (원) <span style="color:#DC2626">*</span>';
        input.placeholder = '0';
        input.removeAttribute('max');
        maxRow.style.display = 'none';
        maxInput.removeAttribute('required');
        maxInput.removeAttribute('name');
        maxInput.value = '';
    }
    calcTotalBudget();
}

function calcTotalBudget() {
    var type = document.getElementById('couponType').value;
    var discountValue = parseInt(document.getElementById('discountValue').value) || 0;
    var maxDiscountAmt = parseInt(document.getElementById('maxDiscountAmt').value) || 0;
    var totalQty = parseInt(document.getElementById('totalQty').value) || 0;
    var unitCost = (type === 'RATE') ? maxDiscountAmt : discountValue;
    document.getElementById('totalBudget').value = unitCost * totalQty;
}

function validateForm() {
    var startInput = document.getElementById('useStartDateInput');
    var endInput   = document.getElementById('useEndDateInput');
    if (!startInput.value || !endInput.value) {
        alert('사용 기간을 입력해주세요.');
        return false;
    }
    if (startInput.value > endInput.value) {
        alert('종료일이 시작일보다 빠를 수 없습니다.');
        return false;
    }
    if (document.getElementById('couponType').value === 'RATE'
        && !document.getElementById('maxDiscountAmt').value) {
        alert('최대 할인 금액을 입력해주세요.');
        return false;
    }
    // 2026-08-13 박유정 — 빈 숫자칸 "" 전송 방지 (Integer 바인딩 오류)
    var minOrder = document.getElementById('minOrderAmt');
    if (!minOrder.value) {
        minOrder.removeAttribute('name');
    } else {
        minOrder.setAttribute('name', 'minOrderAmt');
    }
    var maxInput = document.getElementById('maxDiscountAmt');
    if (document.getElementById('couponType').value === 'RATE') {
        maxInput.setAttribute('name', 'maxDiscountAmt');
    } else {
        maxInput.removeAttribute('name');
    }
    calcTotalBudget();
    calcTotalBudget();
    document.getElementById('useStartDate').value = startInput.value.replace(/-/g, '');
    document.getElementById('useEndDate').value   = endInput.value.replace(/-/g, '');
    return true;
}

// 모달 외부 클릭 닫기
document.getElementById('applyModal').addEventListener('click', function(e) {
    if (e.target === this) closeApplyModal();
});

// 숫자칸 타이핑 중 "010"처럼 앞자리 0이 안 지워지는 문제 방지
['discountValue', 'maxDiscountAmt', 'totalQty', 'minOrderAmt'].forEach(function(id) {
    document.getElementById(id).addEventListener('input', function() {
        this.value = this.value.replace(/^0+(?=\d)/, '');
    });
});
</script>

<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>
