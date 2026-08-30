  <%--
  역할: 관리자 정산 관리 UI
  - 2026/07/24 장우철 — STORE 탭 더미
  - 2026/07/30 장우철 — STAY 탭 3-2~3-5 + 중간요청 4-3~4-4
  - 2026/08/05 장우철 — STORE 탭 S11 실데이터
  - 2026/08/05 장우철 — S12 월정산·15일더미지급·FAIL 수동입금 UI
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="adminPage" value="settlement" />
<%@ include file="/WEB-INF/views/admin/common/header.jsp" %>
<%@ include file="/WEB-INF/views/admin/common/sidebar.jsp" %>

<style>
.settle-tabs { display:flex; gap:8px; margin-bottom:16px; }
.settle-tab {
  padding:10px 18px; border-radius:8px; border:1px solid #E4E6ED; background:#fff;
  font-size:14px; font-weight:700; color:#555; text-decoration:none;
}
.settle-tab.active { background:#3B5BDB; color:#fff; border-color:#3B5BDB; }
.settle-toolbar { display:flex; flex-wrap:wrap; gap:10px; align-items:center; margin-bottom:14px; }
.settle-note { font-size:13px; color:#666; margin:0 0 14px; line-height:1.5; }
.settle-table { width:100%; border-collapse:collapse; font-size:14px; }
.settle-table th {
  text-align:left; padding:12px 10px; background:#F8FAFC; border-bottom:1px solid #E4E6ED;
  color:#666; font-weight:700; font-size:12px;
}
.settle-table td { padding:12px 10px; border-bottom:1px solid #F0F0F0; color:#1A1A2E; vertical-align:middle; }
.settle-badge {
  display:inline-block; padding:3px 8px; border-radius:999px; font-size:12px; font-weight:700;
}
.settle-badge.wait { background:#FFF7ED; color:#C2410C; }
.settle-badge.done { background:#ECFDF5; color:#166534; }
.settle-badge.fail { background:#FEF2F2; color:#B91C1C; }
.settle-fail-note {
  grid-column:1 / -1; padding:10px 12px; border-radius:8px;
  background:#FEF2F2; border:1px solid #FECACA; color:#991B1B; font-size:13px; line-height:1.5;
}
.settle-batch-bar {
  display:flex; flex-wrap:wrap; gap:8px; align-items:center;
  margin-bottom:14px; padding:12px 14px; background:#F8FAFC; border:1px solid #E4E6ED; border-radius:10px;
}
.settle-batch-bar input[type=month] {
  padding:8px 10px; border-radius:8px; border:1px solid #E4E6ED; font-size:13px;
}
.settle-btn {
  border:none; border-radius:8px; padding:8px 12px; font-size:13px; font-weight:700; cursor:pointer;
}
.settle-btn.primary { background:#3B5BDB; color:#fff; }
.settle-btn.primary:disabled { background:#C7D2FE; cursor:not-allowed; }
.settle-btn.ghost { background:#F3F4F6; color:#374151; }
.settle-toggle {
  width:32px; height:32px; border:1px solid #E4E6ED; border-radius:8px; background:#fff;
  cursor:pointer; font-weight:800; color:#555;
}
.settle-detail { display:none; background:#FAFBFC; border-bottom:1px solid #E4E6ED; }
.settle-detail.open { display:table-row; }
.settle-detail-inner {
  padding:14px 16px 18px; display:grid; grid-template-columns:repeat(3,minmax(0,1fr)); gap:10px 18px;
}
.settle-detail-item label { display:block; font-size:12px; color:#999; margin-bottom:4px; }
.settle-detail-item span { font-size:14px; font-weight:700; color:#1A1A2E; word-break:break-all; }
.settle-item-table { width:100%; border-collapse:collapse; font-size:13px; margin-top:12px; background:#fff; grid-column:1 / -1; }
.settle-item-table th { padding:8px; background:#F8FAFC; border-bottom:1px solid #E4E6ED; text-align:left; }
.settle-item-table td { padding:8px; border-bottom:1px solid #F0F0F0; }
.settle-type-tag { display:inline-block; margin-left:6px; font-size:11px; border:1px solid #ddd; border-radius:999px; padding:1px 8px; color:#666; }
@media (max-width:900px) {
  .settle-detail-inner { grid-template-columns:1fr; }
}
</style>

<main class="adm-main">
  <div class="adm-page-head">
    <div class="adm-page-head-left">
      <h1 class="adm-page-title">정산 관리</h1>
      <p class="adm-page-desc">쇼핑·숙소 정산 · 중간요청 · 월정산/15일 더미지급 · FAIL은 계좌확인 후 수동입금</p>
    </div>
  </div>

  <%-- 2026/08/05 장우철 — S12 배치 수동 실행 (스케줄: 1일 월정산 / 15일 자동지급) --%>
  <div class="settle-batch-bar">
    <strong style="font-size:13px">정기 배치</strong>
    <label style="font-size:12px;color:#666">정산월
      <input type="month" id="batchSettleMonth" value="2026-07">
    </label>
    <button type="button" class="settle-btn ghost" id="btnMonthlyCreate">월정산 생성</button>
    <button type="button" class="settle-btn primary" id="btnAutoPay">WAIT 더미지급</button>
    <span style="font-size:12px;color:#999">스케줄: 매월 1일 02:00 전월생성 · 15일 03:00 자동지급</span>
  </div>

  <div class="settle-tabs">
    <a class="settle-tab ${tab eq 'STORE' ? 'active' : ''}" href="${contextPath}/admin/settlement?tab=STORE">펫샵(쇼핑)</a>
    <a class="settle-tab ${tab eq 'STAY' ? 'active' : ''}" href="${contextPath}/admin/settlement?tab=STAY">숙소</a>
  </div>

  <c:choose>
  <c:when test="${tab eq 'STAY'}">
    <%-- 4-3 중간정산 요청 승인/거절 --%>
    <div class="settle-toolbar" style="margin-bottom:8px">
      <strong style="font-size:14px">중간정산 요청</strong>
      <span style="font-size:12px;color:#999">대기 <c:out value="${stayRequestPendingCount}"/>건</span>
      <form method="get" action="${contextPath}/admin/settlement" style="display:flex;gap:8px;align-items:center;margin-left:auto">
        <input type="hidden" name="tab" value="STAY"/>
        <input type="hidden" name="status" value="${filterStatus}"/>
        <select name="reqStatus" onchange="this.form.submit()" style="padding:8px 10px;border-radius:8px;border:1px solid #E4E6ED">
          <option value="requested" <c:if test="${filterReqStatus eq 'requested'}">selected</c:if>>요청대기</option>
          <option value="approved" <c:if test="${filterReqStatus eq 'approved'}">selected</c:if>>요청승인</option>
          <option value="rejected" <c:if test="${filterReqStatus eq 'rejected'}">selected</c:if>>요청거절</option>
          <option value="all" <c:if test="${filterReqStatus eq 'all'}">selected</c:if>>전체</option>
        </select>
      </form>
    </div>
    <div class="adm-card" style="padding:0;overflow:hidden;margin-bottom:18px">
      <table class="settle-table">
        <thead>
          <tr>
            <th>사업장명</th>
            <th>범위</th>
            <th>대상기간</th>
            <th>메모</th>
            <th>요청일</th>
            <th>상태</th>
            <th style="width:180px">처리</th>
          </tr>
        </thead>
        <tbody id="stayRequestBody">
          <c:choose>
            <c:when test="${empty stayRequests}">
              <tr><td colspan="7" style="text-align:center;color:#999;padding:20px 0">중간정산 요청이 없습니다.</td></tr>
            </c:when>
            <c:otherwise>
              <c:forEach var="r" items="${stayRequests}">
                <tr data-request-id="${r.requestId}">
                  <td><c:out value="${r.bizName}"/></td>
                  <td>
                    <c:choose>
                      <c:when test="${r.requestScope eq 'ROOM'}">객실 <c:out value="${r.roomName}"/> (#${r.roomId})</c:when>
                      <c:otherwise>전체</c:otherwise>
                    </c:choose>
                  </td>
                  <td>
                    <fmt:formatDate value="${r.targetStart}" pattern="yyyy-MM-dd"/>
                    ~
                    <fmt:formatDate value="${r.targetEnd}" pattern="yyyy-MM-dd"/>
                  </td>
                  <td style="max-width:180px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap" title="<c:out value='${r.requestMemo}'/>">
                    <c:out value="${empty r.requestMemo ? '-' : r.requestMemo}"/>
                  </td>
                  <td><fmt:formatDate value="${r.requestedAt}" pattern="yyyy-MM-dd"/></td>
                  <td>
                    <c:choose>
                      <c:when test="${r.statusCd eq 'APPROVED'}"><span class="settle-badge done">요청승인</span></c:when>
                      <c:when test="${r.statusCd eq 'REJECTED'}"><span class="settle-badge wait">요청거절</span></c:when>
                      <c:otherwise><span class="settle-badge wait">요청대기</span></c:otherwise>
                    </c:choose>
                  </td>
                  <td style="display:flex;gap:6px;flex-wrap:wrap">
                    <c:if test="${r.statusCd eq 'REQUESTED'}">
                      <button type="button" class="settle-btn primary stay-req-approve" data-id="${r.requestId}" data-name="<c:out value='${r.bizName}'/>">승인</button>
                      <button type="button" class="settle-btn ghost stay-req-reject" data-id="${r.requestId}" data-name="<c:out value='${r.bizName}'/>">거절</button>
                    </c:if>
                    <c:if test="${r.statusCd eq 'REJECTED' and not empty r.rejectReason}">
                      <span style="font-size:12px;color:#999" title="<c:out value='${r.rejectReason}'/>">사유있음</span>
                    </c:if>
                  </td>
                </tr>
              </c:forEach>
            </c:otherwise>
          </c:choose>
        </tbody>
      </table>
    </div>

    <p class="settle-note">
      · 중간요청: 승인 시 부분 정산 마스터 생성(ADHOC) · 거절 시 사유 저장<br>
      · 월정산: REGULAR · 사업자당 월 1건 · 이미 중간정산된 건은 ITEM 제외<br>
      · FAIL: 상세에서 계좌 확인 → 직접 입금 후 「수동입금완료」 (자동지급 대상 아님)
    </p>

    <div class="settle-toolbar">
      <label style="font-size:13px;display:flex;align-items:center;gap:6px">
        <input type="checkbox" id="stayCheckAll"> 전체선택
      </label>
      <button type="button" class="settle-btn primary" id="btnStayBulkPay">선택 정산</button>
      <form method="get" action="${contextPath}/admin/settlement" style="display:flex;gap:8px;align-items:center;margin-left:auto">
        <input type="hidden" name="tab" value="STAY"/>
        <select name="status" onchange="this.form.submit()" style="padding:8px 10px;border-radius:8px;border:1px solid #E4E6ED">
          <option value="all" <c:if test="${filterStatus eq 'all'}">selected</c:if>>전체</option>
          <option value="wait" <c:if test="${filterStatus eq 'wait'}">selected</c:if>>지급대기</option>
          <option value="fail" <c:if test="${filterStatus eq 'fail'}">selected</c:if>>지급실패</option>
          <option value="done" <c:if test="${filterStatus eq 'done'}">selected</c:if>>지급완료</option>
        </select>
      </form>
      <span style="font-size:12px;color:#999">연결:
        <c:choose>
          <c:when test="${adminSettlementReady}">OK</c:when>
          <c:otherwise>FAIL</c:otherwise>
        </c:choose>
        · 마스터 <c:out value="${staySettlementCount}"/>건
      </span>
    </div>

    <div class="adm-card" style="padding:0;overflow:hidden">
      <table class="settle-table">
        <thead>
          <tr>
            <th style="width:40px"></th>
            <th>사업장명</th>
            <th>정산기간</th>
            <th>정산금</th>
            <th>상태</th>
            <th style="width:200px">정산</th>
          </tr>
        </thead>
        <tbody id="staySettleBody">
          <c:choose>
            <c:when test="${empty staySettlements}">
              <tr>
                <td colspan="6" style="text-align:center;color:#999;padding:28px 0">숙소 정산 데이터가 없습니다. (더미 INSERT 후 확인)</td>
              </tr>
            </c:when>
            <c:otherwise>
              <c:forEach var="s" items="${staySettlements}">
                <tr class="settle-row-main" data-id="${s.settleId}">
                  <td>
                    <c:choose>
                      <c:when test="${empty s.payStatus or s.payStatus eq 'WAIT'}">
                        <input type="checkbox" class="stay-row-check" data-id="${s.settleId}">
                      </c:when>
                      <c:otherwise>
                        <input type="checkbox" disabled>
                      </c:otherwise>
                    </c:choose>
                  </td>
                  <td>
                    <c:out value="${s.bizName}"/>
                    <c:if test="${s.requestType eq 'ADHOC'}"><span class="settle-type-tag">중간</span></c:if>
                  </td>
                  <td>
                    <c:choose>
                      <c:when test="${not empty s.periodStart and not empty s.periodEnd}">
                        <fmt:formatDate value="${s.periodStart}" pattern="yyyy-MM-dd"/>
                        ~
                        <fmt:formatDate value="${s.periodEnd}" pattern="yyyy-MM-dd"/>
                      </c:when>
                      <c:otherwise><c:out value="${s.settleMonth}"/></c:otherwise>
                    </c:choose>
                  </td>
                  <td><fmt:formatNumber value="${s.settleAmount}" pattern="#,###"/>원</td>
                  <td>
                    <c:choose>
                      <c:when test="${s.payStatus eq 'DONE'}">
                        <span class="settle-badge done">지급완료</span>
                      </c:when>
                      <c:when test="${s.payStatus eq 'FAIL'}">
                        <span class="settle-badge fail">지급실패</span>
                      </c:when>
                      <c:otherwise>
                        <span class="settle-badge wait">지급대기</span>
                      </c:otherwise>
                    </c:choose>
                  </td>
                  <td style="display:flex;gap:6px;align-items:center;flex-wrap:wrap">
                    <c:choose>
                      <c:when test="${s.payStatus eq 'DONE'}">
                        <button type="button" class="settle-btn primary" disabled>정산</button>
                      </c:when>
                      <c:when test="${s.payStatus eq 'FAIL'}">
                        <button type="button" class="settle-btn primary stay-pay-btn"
                                data-id="${s.settleId}"
                                data-name="<c:out value='${s.bizName}'/>"
                                data-amount="${s.settleAmount}"
                                data-manual="Y">수동입금완료</button>
                      </c:when>
                      <c:otherwise>
                        <button type="button" class="settle-btn primary stay-pay-btn"
                                data-id="${s.settleId}"
                                data-name="<c:out value='${s.bizName}'/>"
                                data-amount="${s.settleAmount}">정산</button>
                        <button type="button" class="settle-btn ghost stay-fail-btn"
                                data-id="${s.settleId}"
                                data-name="<c:out value='${s.bizName}'/>">실패표시</button>
                      </c:otherwise>
                    </c:choose>
                    <button type="button" class="settle-toggle" data-toggle="${s.settleId}" aria-label="상세">▾</button>
                  </td>
                </tr>
                <tr class="settle-detail" id="stay-detail-${s.settleId}">
                  <td colspan="6">
                    <div class="settle-detail-inner" data-loaded="N"
                         data-bank="<c:out value='${s.settleBank}'/>"
                         data-account="<c:out value='${s.settleAccount}'/>"
                         data-holder="<c:out value='${s.settleHolder}'/>"
                         data-sales="${s.totalSales}"
                         data-fee="${s.totalFee}"
                         data-amount="${s.settleAmount}"
                         data-biz="<c:out value='${s.bizName}'/>">
                      <c:if test="${s.payStatus eq 'FAIL'}">
                        <div class="settle-fail-note">
                          지급실패 — 아래 계좌로 직접 입금한 뒤 「수동입금완료」를 눌러 주세요.<br>
                          <b><c:out value="${s.settleBank}"/> <c:out value="${s.settleAccount}"/> / <c:out value="${s.settleHolder}"/></b>
                        </div>
                      </c:if>
                      <div class="settle-detail-item"><label>사업장명</label><span><c:out value="${s.bizName}"/></span></div>
                      <div class="settle-detail-item"><label>입금계좌</label><span><c:out value="${s.settleBank}"/> <c:out value="${s.settleAccount}"/></span></div>
                      <div class="settle-detail-item"><label>예금주</label><span><c:out value="${s.settleHolder}"/></span></div>
                      <div class="settle-detail-item"><label>총매출</label><span><fmt:formatNumber value="${s.totalSales}" pattern="#,###"/>원</span></div>
                      <div class="settle-detail-item"><label>수수료</label><span><fmt:formatNumber value="${s.totalFee}" pattern="#,###"/>원</span></div>
                      <div class="settle-detail-item"><label>정산금</label><span><fmt:formatNumber value="${s.settleAmount}" pattern="#,###"/>원</span></div>
                      <div class="settle-item-box" style="grid-column:1/-1;color:#999;font-size:13px">예약 상세는 ▾ 열 때 불러옵니다.</div>
                    </div>
                  </td>
                </tr>
              </c:forEach>
            </c:otherwise>
          </c:choose>
        </tbody>
      </table>
    </div>
  </c:when>
  <c:otherwise>
    <%-- 2026/08/05 장우철 — STORE 탭 실데이터 (S11) --%>
    <div class="settle-toolbar" style="margin-bottom:8px">
      <strong style="font-size:14px">중간정산 요청</strong>
      <span style="font-size:12px;color:#999">대기 <c:out value="${storeRequestPendingCount}"/>건</span>
      <form method="get" action="${contextPath}/admin/settlement" style="display:flex;gap:8px;align-items:center;margin-left:auto">
        <input type="hidden" name="tab" value="STORE"/>
        <input type="hidden" name="status" value="${filterStatus}"/>
        <select name="reqStatus" onchange="this.form.submit()" style="padding:8px 10px;border-radius:8px;border:1px solid #E4E6ED">
          <option value="requested" <c:if test="${filterReqStatus eq 'requested'}">selected</c:if>>요청대기</option>
          <option value="approved" <c:if test="${filterReqStatus eq 'approved'}">selected</c:if>>요청승인</option>
          <option value="rejected" <c:if test="${filterReqStatus eq 'rejected'}">selected</c:if>>요청거절</option>
          <option value="all" <c:if test="${filterReqStatus eq 'all'}">selected</c:if>>전체</option>
        </select>
      </form>
    </div>
    <div class="adm-card" style="padding:0;overflow:hidden;margin-bottom:18px">
      <table class="settle-table">
        <thead>
          <tr>
            <th>사업장명</th>
            <th>범위</th>
            <th>대상기간</th>
            <th>메모</th>
            <th>요청일</th>
            <th>상태</th>
            <th style="width:180px">처리</th>
          </tr>
        </thead>
        <tbody id="storeRequestBody">
          <c:choose>
            <c:when test="${empty storeRequests}">
              <tr><td colspan="7" style="text-align:center;color:#999;padding:20px 0">중간정산 요청이 없습니다.</td></tr>
            </c:when>
            <c:otherwise>
              <c:forEach var="r" items="${storeRequests}">
                <tr data-request-id="${r.requestId}">
                  <td><c:out value="${r.bizName}"/></td>
                  <td>
                    <c:choose>
                      <c:when test="${r.requestScope eq 'PRODUCT'}">상품 <c:out value="${r.productName}"/> (#${r.productId})</c:when>
                      <c:otherwise>전체</c:otherwise>
                    </c:choose>
                  </td>
                  <td>
                    <fmt:formatDate value="${r.targetStart}" pattern="yyyy-MM-dd"/>
                    ~
                    <fmt:formatDate value="${r.targetEnd}" pattern="yyyy-MM-dd"/>
                  </td>
                  <td style="max-width:180px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap" title="<c:out value='${r.requestMemo}'/>">
                    <c:out value="${empty r.requestMemo ? '-' : r.requestMemo}"/>
                  </td>
                  <td><fmt:formatDate value="${r.requestedAt}" pattern="yyyy-MM-dd"/></td>
                  <td>
                    <c:choose>
                      <c:when test="${r.statusCd eq 'APPROVED'}"><span class="settle-badge done">요청승인</span></c:when>
                      <c:when test="${r.statusCd eq 'REJECTED'}"><span class="settle-badge wait">요청거절</span></c:when>
                      <c:otherwise><span class="settle-badge wait">요청대기</span></c:otherwise>
                    </c:choose>
                  </td>
                  <td style="display:flex;gap:6px;flex-wrap:wrap">
                    <c:if test="${r.statusCd eq 'REQUESTED'}">
                      <button type="button" class="settle-btn primary store-req-approve" data-id="${r.requestId}" data-name="<c:out value='${r.bizName}'/>">승인</button>
                      <button type="button" class="settle-btn ghost store-req-reject" data-id="${r.requestId}" data-name="<c:out value='${r.bizName}'/>">거절</button>
                    </c:if>
                    <c:if test="${r.statusCd eq 'REJECTED' and not empty r.rejectReason}">
                      <span style="font-size:12px;color:#999" title="<c:out value='${r.rejectReason}'/>">사유있음</span>
                    </c:if>
                  </td>
                </tr>
              </c:forEach>
            </c:otherwise>
          </c:choose>
        </tbody>
      </table>
    </div>

    <p class="settle-note">
      · 중간요청: 승인 시 부분 정산 마스터 생성(ADHOC) · 거절 시 사유 저장<br>
      · 월정산: REGULAR · 사업자당 월 1건 · 이미 중간정산된 주문상품은 ITEM 제외<br>
      · FAIL: 상세에서 계좌 확인 → 직접 입금 후 「수동입금완료」
    </p>

    <div class="settle-toolbar">
      <label style="font-size:13px;display:flex;align-items:center;gap:6px">
        <input type="checkbox" id="storeCheckAll"> 전체선택
      </label>
      <button type="button" class="settle-btn primary" id="btnStoreBulkPay">선택 정산</button>
      <form method="get" action="${contextPath}/admin/settlement" style="display:flex;gap:8px;align-items:center;margin-left:auto">
        <input type="hidden" name="tab" value="STORE"/>
        <select name="status" onchange="this.form.submit()" style="padding:8px 10px;border-radius:8px;border:1px solid #E4E6ED">
          <option value="all" <c:if test="${filterStatus eq 'all'}">selected</c:if>>전체</option>
          <option value="wait" <c:if test="${filterStatus eq 'wait'}">selected</c:if>>지급대기</option>
          <option value="fail" <c:if test="${filterStatus eq 'fail'}">selected</c:if>>지급실패</option>
          <option value="done" <c:if test="${filterStatus eq 'done'}">selected</c:if>>지급완료</option>
        </select>
      </form>
      <span style="font-size:12px;color:#999">연결:
        <c:choose>
          <c:when test="${adminSettlementReady}">OK</c:when>
          <c:otherwise>FAIL</c:otherwise>
        </c:choose>
        · 마스터 <c:out value="${storeSettlementCount}"/>건
      </span>
    </div>

    <div class="adm-card" style="padding:0;overflow:hidden">
      <table class="settle-table">
        <thead>
          <tr>
            <th style="width:40px"></th>
            <th>사업장명</th>
            <th>정산기간</th>
            <th>정산금</th>
            <th>상태</th>
            <th style="width:200px">정산</th>
          </tr>
        </thead>
        <tbody id="storeSettleBody">
          <c:choose>
            <c:when test="${empty storeSettlements}">
              <tr>
                <td colspan="6" style="text-align:center;color:#999;padding:28px 0">쇼핑 정산 데이터가 없습니다. (중간요청 승인 후 확인)</td>
              </tr>
            </c:when>
            <c:otherwise>
              <c:forEach var="s" items="${storeSettlements}">
                <tr class="settle-row-main" data-id="${s.settleId}">
                  <td>
                    <c:choose>
                      <c:when test="${empty s.payStatus or s.payStatus eq 'WAIT'}">
                        <input type="checkbox" class="store-row-check" data-id="${s.settleId}">
                      </c:when>
                      <c:otherwise>
                        <input type="checkbox" disabled>
                      </c:otherwise>
                    </c:choose>
                  </td>
                  <td>
                    <c:out value="${s.bizName}"/>
                    <c:if test="${s.requestType eq 'ADHOC'}"><span class="settle-type-tag">중간</span></c:if>
                  </td>
                  <td>
                    <c:choose>
                      <c:when test="${not empty s.periodStart and not empty s.periodEnd}">
                        <fmt:formatDate value="${s.periodStart}" pattern="yyyy-MM-dd"/>
                        ~
                        <fmt:formatDate value="${s.periodEnd}" pattern="yyyy-MM-dd"/>
                      </c:when>
                      <c:otherwise><c:out value="${s.settleMonth}"/></c:otherwise>
                    </c:choose>
                  </td>
                  <td><fmt:formatNumber value="${s.settleAmount}" pattern="#,###"/>원</td>
                  <td>
                    <c:choose>
                      <c:when test="${s.payStatus eq 'DONE'}">
                        <span class="settle-badge done">지급완료</span>
                      </c:when>
                      <c:when test="${s.payStatus eq 'FAIL'}">
                        <span class="settle-badge fail">지급실패</span>
                      </c:when>
                      <c:otherwise>
                        <span class="settle-badge wait">지급대기</span>
                      </c:otherwise>
                    </c:choose>
                  </td>
                  <td style="display:flex;gap:6px;align-items:center;flex-wrap:wrap">
                    <c:choose>
                      <c:when test="${s.payStatus eq 'DONE'}">
                        <button type="button" class="settle-btn primary" disabled>정산</button>
                      </c:when>
                      <c:when test="${s.payStatus eq 'FAIL'}">
                        <button type="button" class="settle-btn primary store-pay-btn"
                                data-id="${s.settleId}"
                                data-name="<c:out value='${s.bizName}'/>"
                                data-amount="${s.settleAmount}"
                                data-manual="Y">수동입금완료</button>
                      </c:when>
                      <c:otherwise>
                        <button type="button" class="settle-btn primary store-pay-btn"
                                data-id="${s.settleId}"
                                data-name="<c:out value='${s.bizName}'/>"
                                data-amount="${s.settleAmount}">정산</button>
                        <button type="button" class="settle-btn ghost store-fail-btn"
                                data-id="${s.settleId}"
                                data-name="<c:out value='${s.bizName}'/>">실패표시</button>
                      </c:otherwise>
                    </c:choose>
                    <button type="button" class="settle-toggle" data-toggle-store="${s.settleId}" aria-label="상세">▾</button>
                  </td>
                </tr>
                <tr class="settle-detail" id="store-detail-${s.settleId}">
                  <td colspan="6">
                    <div class="settle-detail-inner" data-loaded="N">
                      <c:if test="${s.payStatus eq 'FAIL'}">
                        <div class="settle-fail-note">
                          지급실패 — 아래 계좌로 직접 입금한 뒤 「수동입금완료」를 눌러 주세요.<br>
                          <b><c:out value="${s.settleBank}"/> <c:out value="${s.settleAccount}"/> / <c:out value="${s.settleHolder}"/></b>
                        </div>
                      </c:if>
                      <div class="settle-detail-item"><label>사업장명</label><span><c:out value="${s.bizName}"/></span></div>
                      <div class="settle-detail-item"><label>입금계좌</label><span><c:out value="${s.settleBank}"/> <c:out value="${s.settleAccount}"/></span></div>
                      <div class="settle-detail-item"><label>예금주</label><span><c:out value="${s.settleHolder}"/></span></div>
                      <div class="settle-detail-item"><label>총매출</label><span><fmt:formatNumber value="${s.totalSales}" pattern="#,###"/>원</span></div>
                      <div class="settle-detail-item"><label>수수료</label><span><fmt:formatNumber value="${s.totalFee}" pattern="#,###"/>원</span></div>
                      <div class="settle-detail-item"><label>정산금</label><span><fmt:formatNumber value="${s.settleAmount}" pattern="#,###"/>원</span></div>
                      <div class="settle-item-box" style="grid-column:1/-1;color:#999;font-size:13px">주문상품 상세는 ▾ 열 때 불러옵니다.</div>
                    </div>
                  </td>
                </tr>
              </c:forEach>
            </c:otherwise>
          </c:choose>
        </tbody>
      </table>
    </div>
  </c:otherwise>
  </c:choose>
</main>

<script>
(function () {
  var CTX = '${contextPath}';
  var tab = '${tab}';

  function fmt(n) {
    if (n == null || n === '') return '0원';
    return Number(n).toLocaleString('ko-KR') + '원';
  }
  function fmtDate(v) {
    if (!v) return '-';
    if (typeof v === 'number') {
      var d = new Date(v);
      return d.getFullYear() + '-' + String(d.getMonth()+1).padStart(2,'0') + '-' + String(d.getDate()).padStart(2,'0');
    }
    return String(v).substring(0, 10);
  }

  // 2026/08/05 장우철 — S12 배치 수동 실행
  var btnMonthly = document.getElementById('btnMonthlyCreate');
  if (btnMonthly) {
    btnMonthly.addEventListener('click', function () {
      var monthEl = document.getElementById('batchSettleMonth');
      var month = monthEl && monthEl.value ? monthEl.value : '';
      if (!confirm('월정산(REGULAR)을 생성할까요?\n대상월: ' + (month || '전월') + '\n숙소·쇼핑 승인 사업자 전체')) return;
      // 2026/08/07 장우철 CSRF
      csrfFetch(CTX + '/admin/settlement/batch/monthly-create', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
        body: JSON.stringify({ settleMonth: month || null })
      })
        .then(function (r) { return r.json(); })
        .then(function (data) {
          alert(data.message || (data.ok ? '완료' : '실패'));
          if (data.ok) location.reload();
        })
        .catch(function () { alert('월정산 생성 중 오류'); });
    });
  }
  var btnAutoPay = document.getElementById('btnAutoPay');
  if (btnAutoPay) {
    btnAutoPay.addEventListener('click', function () {
      if (!confirm('WAIT 상태 정산을 전부 더미 지급할까요?\n(FAIL은 제외 · 숙소+쇼핑)')) return;
      // 2026/08/07 장우철 CSRF
      csrfFetch(CTX + '/admin/settlement/batch/auto-pay', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' }
      })
        .then(function (r) { return r.json(); })
        .then(function (data) {
          alert(data.message || (data.ok ? '완료' : '실패'));
          if (data.ok) location.reload();
        })
        .catch(function () { alert('자동지급 중 오류'); });
    });
  }

  // ===== STAY 탭 실데이터 (3-2~3-5 / 4-3~4-4) =====
  // 중간정산 요청 승인/거절
  document.getElementById('stayRequestBody') && document.getElementById('stayRequestBody').addEventListener('click', function (e) {
    var approveBtn = e.target.closest('.stay-req-approve');
    if (approveBtn) {
      var id = Number(approveBtn.getAttribute('data-id'));
      var name = approveBtn.getAttribute('data-name') || '';
      if (!confirm('[' + name + '] 중간정산 요청을 승인할까요?\n승인 시 미정산 예약으로 정산 마스터가 생성됩니다.')) return;
      //HYJ 26.08.05
      csrfFetch(CTX + '/admin/settlement/stay/request/approve', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
        body: JSON.stringify({ requestId: id })
      })
        .then(function (r) { return r.json(); })
        .then(function (data) {
          alert(data.message || (data.ok ? '승인 완료' : '실패'));
          if (data.ok) location.reload();
        })
        .catch(function () { alert('승인 처리 중 오류'); });
      return;
    }
    var rejectBtn = e.target.closest('.stay-req-reject');
    if (rejectBtn) {
      var rid = Number(rejectBtn.getAttribute('data-id'));
      var rname = rejectBtn.getAttribute('data-name') || '';
      var reason = prompt('[' + rname + '] 거절 사유를 입력하세요.');
      if (reason == null) return;
      if (!String(reason).trim()) { alert('거절 사유가 필요합니다.'); return; }
      //HYJ 26.08.05
      csrfFetch(CTX + '/admin/settlement/stay/request/reject', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
        body: JSON.stringify({ requestId: rid, rejectReason: String(reason).trim() })
      })
        .then(function (r) { return r.json(); })
        .then(function (data) {
          alert(data.message || (data.ok ? '거절 완료' : '실패'));
          if (data.ok) location.reload();
        })
        .catch(function () { alert('거절 처리 중 오류'); });
    }
  });

  if (tab === 'STAY') {
    var body = document.getElementById('staySettleBody');
    if (!body) return;

    body.addEventListener('click', function (e) {
      var toggle = e.target.closest('[data-toggle]');
      if (toggle) {
        var id = toggle.getAttribute('data-toggle');
        var detail = document.getElementById('stay-detail-' + id);
        if (!detail) return;
        detail.classList.toggle('open');
        toggle.textContent = detail.classList.contains('open') ? '▴' : '▾';
        if (detail.classList.contains('open')) {
          loadStayItems(id, detail.querySelector('.settle-detail-inner'));
        }
        return;
      }

      var payBtn = e.target.closest('.stay-pay-btn');
      if (payBtn) {
        var settleId = Number(payBtn.getAttribute('data-id'));
        var name = payBtn.getAttribute('data-name') || '';
        var amount = payBtn.getAttribute('data-amount');
        var manual = payBtn.getAttribute('data-manual') === 'Y';
        var msg = manual
          ? '계좌 입금 확인 후 수동입금완료 처리할까요?\n[' + name + '] ' + fmt(amount)
          : '정말 정산(더미 지급) 하시겠습니까?\n[' + name + '] ' + fmt(amount);
        if (!confirm(msg)) return;
        //HYJ 26.08.05
        csrfFetch(CTX + '/admin/settlement/stay/pay', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
          body: JSON.stringify({ settleId: settleId })
        })
          .then(function (r) { return r.json(); })
          .then(function (data) {
            alert(data.message || (data.ok ? '완료' : '실패'));
            if (data.ok) location.reload();
          })
          .catch(function () { alert('정산 요청 중 오류가 발생했습니다.'); });
        return;
      }
      var failBtn = e.target.closest('.stay-fail-btn');
      if (failBtn) {
        var fid = Number(failBtn.getAttribute('data-id'));
        var fname = failBtn.getAttribute('data-name') || '';
        if (!confirm('[' + fname + '] 지급실패(FAIL)로 표시할까요?\n상세에서 계좌 확인 후 수동입금하세요.')) return;
        // 2026/08/07 장우철 CSRF
        csrfFetch(CTX + '/admin/settlement/stay/mark-fail', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
          body: JSON.stringify({ settleId: fid })
        })
          .then(function (r) { return r.json(); })
          .then(function (data) {
            alert(data.message || (data.ok ? '완료' : '실패'));
            if (data.ok) location.reload();
          })
          .catch(function () { alert('FAIL 표시 중 오류'); });
      }
    });

    function loadStayItems(settleId, wrap) {
      if (!wrap || wrap.getAttribute('data-loaded') === 'Y') return;
      var box = wrap.querySelector('.settle-item-box');
      if (box) box.textContent = '예약 상세 불러오는 중...';
      fetch(CTX + '/admin/settlement/stay/items?settleId=' + encodeURIComponent(settleId), {
        headers: { 'Accept': 'application/json' }
      })
        .then(function (r) { return r.json(); })
        .then(function (data) {
          wrap.setAttribute('data-loaded', 'Y');
          if (!data.ok) {
            if (box) box.textContent = data.message || '조회 실패';
            return;
          }
          var items = data.items || [];
          if (!items.length) {
            if (box) box.textContent = '포함된 예약 상세가 없습니다.';
            return;
          }
          var html = '<table class="settle-item-table"><thead><tr>'
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
              + '<td>' + fmt(it.resvAmount) + '</td>'
              + '<td>-' + fmt(it.feeAmount) + '</td>'
              + '<td><b>' + fmt(it.settleAmount) + '</b></td>'
              + '<td>' + (it.statusCd || '-') + '</td>'
              + '</tr>';
          });
          html += '</tbody></table>';
          if (box) box.outerHTML = html;
        })
        .catch(function () {
          if (box) box.textContent = '상세 조회 중 오류';
        });
    }

    var checkAll = document.getElementById('stayCheckAll');
    if (checkAll) {
      checkAll.addEventListener('change', function () {
        var on = this.checked;
        document.querySelectorAll('.stay-row-check').forEach(function (el) { el.checked = on; });
      });
    }

    var bulkBtn = document.getElementById('btnStayBulkPay');
    if (bulkBtn) {
      bulkBtn.addEventListener('click', function () {
        var ids = [];
        document.querySelectorAll('.stay-row-check:checked').forEach(function (el) {
          ids.push(Number(el.getAttribute('data-id')));
        });
        if (!ids.length) {
          alert('정산할 건을 선택하세요. (대기 상태만 선택 가능)');
          return;
        }
        if (!confirm('선택한 ' + ids.length + '건을 정말 정산(더미 지급) 하시겠습니까?')) return;
        //HYJ 26.08.05
        csrfFetch(CTX + '/admin/settlement/stay/pay-bulk', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
          body: JSON.stringify({ settleIds: ids })
        })
          .then(function (r) { return r.json(); })
          .then(function (data) {
            alert(data.message || (data.ok ? '완료' : '실패'));
            if (data.ok) location.reload();
          })
          .catch(function () { alert('일괄 정산 중 오류가 발생했습니다.'); });
      });
    }
    return;
  }

  // ===== STORE 탭 실데이터 (S11) =====
  if (tab !== 'STORE') return;

  document.getElementById('storeRequestBody') && document.getElementById('storeRequestBody').addEventListener('click', function (e) {
    var approveBtn = e.target.closest('.store-req-approve');
    if (approveBtn) {
      var id = Number(approveBtn.getAttribute('data-id'));
      var name = approveBtn.getAttribute('data-name') || '';
      if (!confirm('[' + name + '] 중간정산 요청을 승인할까요?\n승인 시 미정산 주문상품으로 정산 마스터가 생성됩니다.')) return;
      // 2026/08/07 장우철 CSRF
      csrfFetch(CTX + '/admin/settlement/store/request/approve', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
        body: JSON.stringify({ requestId: id })
      })
        .then(function (r) { return r.json(); })
        .then(function (data) {
          alert(data.message || (data.ok ? '승인 완료' : '실패'));
          if (data.ok) location.reload();
        })
        .catch(function () { alert('승인 처리 중 오류'); });
      return;
    }
    var rejectBtn = e.target.closest('.store-req-reject');
    if (rejectBtn) {
      var rid = Number(rejectBtn.getAttribute('data-id'));
      var rname = rejectBtn.getAttribute('data-name') || '';
      var reason = prompt('[' + rname + '] 거절 사유를 입력하세요.');
      if (reason == null) return;
      if (!String(reason).trim()) { alert('거절 사유가 필요합니다.'); return; }
      // 2026/08/07 장우철 CSRF
      csrfFetch(CTX + '/admin/settlement/store/request/reject', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
        body: JSON.stringify({ requestId: rid, rejectReason: String(reason).trim() })
      })
        .then(function (r) { return r.json(); })
        .then(function (data) {
          alert(data.message || (data.ok ? '거절 완료' : '실패'));
          if (data.ok) location.reload();
        })
        .catch(function () { alert('거절 처리 중 오류'); });
    }
  });

  var storeBody = document.getElementById('storeSettleBody');
  if (!storeBody) return;

  storeBody.addEventListener('click', function (e) {
    var toggle = e.target.closest('[data-toggle-store]');
    if (toggle) {
      var id = toggle.getAttribute('data-toggle-store');
      var detail = document.getElementById('store-detail-' + id);
      if (!detail) return;
      detail.classList.toggle('open');
      toggle.textContent = detail.classList.contains('open') ? '▴' : '▾';
      if (detail.classList.contains('open')) {
        loadStoreItems(id, detail.querySelector('.settle-detail-inner'));
      }
      return;
    }

    var payBtn = e.target.closest('.store-pay-btn');
    if (payBtn) {
      var settleId = Number(payBtn.getAttribute('data-id'));
      var name = payBtn.getAttribute('data-name') || '';
      var amount = payBtn.getAttribute('data-amount');
      var manual = payBtn.getAttribute('data-manual') === 'Y';
      var msg = manual
        ? '계좌 입금 확인 후 수동입금완료 처리할까요?\n[' + name + '] ' + fmt(amount)
        : '정말 정산(더미 지급) 하시겠습니까?\n[' + name + '] ' + fmt(amount);
      if (!confirm(msg)) return;
      // 2026/08/07 장우철 CSRF
      csrfFetch(CTX + '/admin/settlement/store/pay', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
        body: JSON.stringify({ settleId: settleId })
      })
        .then(function (r) { return r.json(); })
        .then(function (data) {
          alert(data.message || (data.ok ? '완료' : '실패'));
          if (data.ok) location.reload();
        })
        .catch(function () { alert('정산 요청 중 오류가 발생했습니다.'); });
      return;
    }
    var failBtn = e.target.closest('.store-fail-btn');
    if (failBtn) {
      var fid = Number(failBtn.getAttribute('data-id'));
      var fname = failBtn.getAttribute('data-name') || '';
      if (!confirm('[' + fname + '] 지급실패(FAIL)로 표시할까요?\n상세에서 계좌 확인 후 수동입금하세요.')) return;
      // 2026/08/07 장우철 CSRF
      csrfFetch(CTX + '/admin/settlement/store/mark-fail', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
        body: JSON.stringify({ settleId: fid })
      })
        .then(function (r) { return r.json(); })
        .then(function (data) {
          alert(data.message || (data.ok ? '완료' : '실패'));
          if (data.ok) location.reload();
        })
        .catch(function () { alert('FAIL 표시 중 오류'); });
    }
  });

  function loadStoreItems(settleId, wrap) {
    if (!wrap || wrap.getAttribute('data-loaded') === 'Y') return;
    var box = wrap.querySelector('.settle-item-box');
    if (box) box.textContent = '주문상품 상세 불러오는 중...';
    fetch(CTX + '/admin/settlement/store/items?settleId=' + encodeURIComponent(settleId), {
      headers: { 'Accept': 'application/json' }
    })
      .then(function (r) { return r.json(); })
      .then(function (data) {
        wrap.setAttribute('data-loaded', 'Y');
        if (!data.ok) {
          if (box) box.textContent = data.message || '조회 실패';
          return;
        }
        var items = data.items || [];
        if (!items.length) {
          if (box) box.textContent = '포함된 주문상품 상세가 없습니다.';
          return;
        }
        var html = '<table class="settle-item-table"><thead><tr>'
          + '<th>주문번호</th><th>상품</th><th>구매확정</th>'
          + '<th>상품매출</th><th>택배비</th><th>수수료</th><th>정산금</th>'
          + '</tr></thead><tbody>';
        items.forEach(function (it) {
          html += '<tr>'
            + '<td>' + (it.orderNo || it.orderId || '-') + '</td>'
            + '<td>' + (it.productName || it.productId || '-') + '</td>'
            + '<td>' + fmtDate(it.confirmedAt) + '</td>'
            + '<td>' + fmt(it.itemSalesAmount) + '</td>'
            + '<td>' + fmt(it.deliveryFeeAmount) + '</td>'
            + '<td>-' + fmt(it.feeAmount) + '</td>'
            + '<td><b>' + fmt(it.settleAmount) + '</b></td>'
            + '</tr>';
        });
        html += '</tbody></table>';
        if (box) box.innerHTML = html;
      })
      .catch(function () {
        if (box) box.textContent = '상세 조회 중 오류';
      });
  }

  var storeCheckAll = document.getElementById('storeCheckAll');
  if (storeCheckAll) {
    storeCheckAll.addEventListener('change', function () {
      var on = this.checked;
      document.querySelectorAll('.store-row-check:not(:disabled)').forEach(function (el) {
        el.checked = on;
      });
    });
  }

  var btnStoreBulk = document.getElementById('btnStoreBulkPay');
  if (btnStoreBulk) {
    btnStoreBulk.addEventListener('click', function () {
      var ids = [];
      document.querySelectorAll('.store-row-check:checked').forEach(function (el) {
        ids.push(Number(el.getAttribute('data-id')));
      });
      if (!ids.length) {
        alert('정산할 건을 선택하세요.');
        return;
      }
      if (!confirm('선택한 ' + ids.length + '건을 더미 지급 완료할까요?')) return;
      // 2026/08/07 장우철 CSRF
      csrfFetch(CTX + '/admin/settlement/store/pay-bulk', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
        body: JSON.stringify({ settleIds: ids })
      })
        .then(function (r) { return r.json(); })
        .then(function (data) {
          alert(data.message || (data.ok ? '완료' : '실패'));
          if (data.ok) location.reload();
        })
        .catch(function () { alert('일괄 정산 중 오류가 발생했습니다.'); });
    });
  }
})();
</script>

<%@ include file="/WEB-INF/views/admin/common/footer.jsp" %>
