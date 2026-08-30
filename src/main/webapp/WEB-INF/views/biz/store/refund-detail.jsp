<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%-- 2026/08/04 장우철 — 사업자 환불신청 상세 (승인/거절/회수완료) --%>
<%-- 2026/08/11 장우철 — 결제수단 표시·상세 UI 정리·환불 확인문구(빌링/토스위젯) --%>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="반려동물 쇼핑몰" />
<c:set var="bizPage" value="refunds" />
<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_store.jsp" %>

<%-- 결제수단 라벨 (빌링 / 토스위젯 / 포인트) — 환불 API도 동일 기준 --%>
<c:set var="payMethodCd" value="${empty refund.payMethod ? '' : fn:toUpperCase(refund.payMethod)}" />
<c:choose>
  <c:when test="${payMethodCd == 'BILLING'}">
    <c:set var="payMethodLabel" value="등록카드(빌링)" />
    <c:set var="refundChannelLabel" value="등록카드(빌링) 결제 취소" />
  </c:when>
  <c:when test="${payMethodCd == 'TOSS' || payMethodCd == 'CARD' || payMethodCd == 'NORMAL'}">
    <c:set var="payMethodLabel" value="토스 결제(위젯)" />
    <c:set var="refundChannelLabel" value="토스 결제 취소" />
  </c:when>
  <c:when test="${payMethodCd == 'POINT' || payMethodCd == 'ZERO'}">
    <c:set var="payMethodLabel" value="포인트/쿠폰(실결제 없음)" />
    <c:set var="refundChannelLabel" value="실결제 없음(포인트·쿠폰 복구만)" />
  </c:when>
  <c:when test="${not empty payMethodCd}">
    <c:set var="payMethodLabel" value="${payMethodCd}" />
    <c:set var="refundChannelLabel" value="결제 취소" />
  </c:when>
  <c:otherwise>
    <c:set var="payMethodLabel" value="미확인" />
    <c:set var="refundChannelLabel" value="결제 취소(수단 자동판별)" />
  </c:otherwise>
</c:choose>

<c:set var="bizPaysFee" value="${refund.returnReasonCd == 'DEFECT' or refund.returnFeePayer == 'BIZ'}" />
<c:set var="userFeeAmt" value="${empty refund.userReturnFee ? 0 : refund.userReturnFee}" />
<c:set var="reimburseAmt" value="${empty refund.returnShipReimburse ? 0 : refund.returnShipReimburse}" />
<c:set var="itemCouponAmt" value="${empty refund.itemCouponAmount ? 0 : refund.itemCouponAmount}" />
<c:set var="itemPointAmt" value="${empty refund.itemPointAmount ? 0 : refund.itemPointAmount}" />
<c:set var="itemPayAmt" value="${empty refund.itemPayAmount ? 0 : refund.itemPayAmount}" />
<c:set var="cardRefundAmt" value="${empty refund.expectCardRefund ? 0 : refund.expectCardRefund}" />
<c:set var="orderCouponAmt" value="${empty refund.orderCouponAmount ? 0 : refund.orderCouponAmount}" />
<c:set var="orderPointAmt" value="${empty refund.pointUsed ? 0 : refund.pointUsed}" />
<c:set var="paidRefundAmt" value="${empty refund.paidRefundAmt ? 0 : refund.paidRefundAmt}" />

<style>
  .rf-wrap{width:100%;max-width:1100px}
  .rf-card{margin-bottom:16px}
  .rf-grid{display:grid;grid-template-columns:1fr 1fr;gap:28px;padding:20px 24px}
  .rf-grid h4{font-size:14px;font-weight:800;color:#1A1A2E;margin:0 0 12px;padding-bottom:8px;border-bottom:2px solid #1A1A2E}
  .rf-row{display:flex;justify-content:space-between;gap:16px;min-height:32px;padding:7px 2px;border-bottom:1px solid #F0F2F0;font-size:13px}
  .rf-row > span:first-child{color:#8A8FA3;flex-shrink:0}
  .rf-row > span:last-child{color:#1A1A2E;font-weight:600;text-align:right;word-break:break-word}
  .rf-badge{display:inline-flex;align-items:center;padding:3px 10px;border-radius:999px;font-size:12px;font-weight:700}
  .rf-badge.billing{background:#EEF2FF;color:#4338CA}
  .rf-badge.toss{background:#ECFDF5;color:#047857}
  .rf-badge.point{background:#F3F4F6;color:#6B7280}
  .rf-badge.unknown{background:#FFF7ED;color:#C2410C}
  .rf-reason{white-space:pre-wrap;background:#F8FAFC;border-radius:10px;padding:14px;font-size:14px;line-height:1.55;color:#334155}
  .rf-photos{margin-top:14px;display:flex;gap:10px;flex-wrap:wrap}
  .rf-photos img{width:104px;height:104px;object-fit:cover;border-radius:10px;border:1px solid #E2E8E4;display:block}
  .rf-guide{background:#F8FAFC;border-radius:10px;padding:14px 16px;font-size:13px;color:#475569;line-height:1.65;margin-bottom:16px}
  .rf-actions{display:flex;gap:10px;flex-wrap:wrap;align-items:flex-start}
  .rf-reject input{min-width:240px;padding:9px 12px;border:1px solid #E2E8E4;border-radius:8px;font-size:13px}
  @media (max-width:860px){.rf-grid{grid-template-columns:1fr}}
</style>

<main class="biz-main">
  <div class="rf-wrap">
    <div class="biz-page-head">
      <h1 class="biz-page-title">환불 신청 상세</h1>
      <p class="biz-page-desc">
        <c:set var="listStatus" value="REQUESTED" />
        <c:if test="${refund.returnStatusCd == 'RETURNING'}"><c:set var="listStatus" value="RETURNING" /></c:if>
        <c:if test="${refund.returnStatusCd == 'DONE'}"><c:set var="listStatus" value="DONE" /></c:if>
        <c:if test="${refund.returnStatusCd == 'REJECTED'}"><c:set var="listStatus" value="REJECTED" /></c:if>
        <a href="${contextPath}/biz/store/refunds?statusCd=${listStatus}" style="color:#64748B;">← 목록</a>
      </p>
    </div>

    <c:if test="${not empty msg}">
      <div style="margin-bottom:12px;padding:12px 16px;background:#E8F8F1;color:#1F8464;border-radius:8px;font-size:14px">${msg}</div>
    </c:if>
    <c:if test="${not empty errorMsg}">
      <div style="margin-bottom:12px;padding:12px 16px;background:#FEF2F2;color:#B91C1C;border-radius:8px;font-size:14px">${errorMsg}</div>
    </c:if>

    <div class="biz-card rf-card">
      <div class="biz-card-head">
        <span>환불 요약</span>
        <c:choose>
          <c:when test="${refund.returnStatusCd == 'REQUESTED'}"><span class="bs-badge bs-wait">신청대기</span></c:when>
          <c:when test="${refund.returnStatusCd == 'RETURNING'}"><span class="bs-badge bs-prep">환불진행</span></c:when>
          <c:when test="${refund.returnStatusCd == 'DONE'}"><span class="bs-badge bs-done">환불완료</span></c:when>
          <c:when test="${refund.returnStatusCd == 'REJECTED'}"><span class="bs-badge bs-cancel">거절</span></c:when>
        </c:choose>
      </div>
      <div class="rf-grid">
        <div>
          <h4>주문 · 결제</h4>
          <div class="rf-row"><span>주문번호</span><span><c:out value="${refund.orderNo}"/></span></div>
          <div class="rf-row"><span>주문상태</span>
            <span>
              <c:choose>
                <c:when test="${refund.orderStatus == 'PAID'}">결제완료</c:when>
                <c:when test="${refund.orderStatus == 'READY'}">배송준비</c:when>
                <c:when test="${refund.orderStatus == 'SHIPPING'}">배송중</c:when>
                <c:when test="${refund.orderStatus == 'DONE'}">배송완료</c:when>
                <c:when test="${refund.orderStatus == 'CANCEL'}">취소완료</c:when>
                <c:otherwise><c:out value="${refund.orderStatus}"/></c:otherwise>
              </c:choose>
            </span>
          </div>
          <div class="rf-row"><span>주문일</span><span><fmt:formatDate value="${refund.orderDate}" pattern="yyyy.MM.dd HH:mm"/></span></div>
          <div class="rf-row"><span>결제수단</span>
            <span>
              <c:choose>
                <c:when test="${payMethodCd == 'BILLING'}"><span class="rf-badge billing">${payMethodLabel}</span></c:when>
                <c:when test="${payMethodCd == 'TOSS' || payMethodCd == 'CARD' || payMethodCd == 'NORMAL'}"><span class="rf-badge toss">${payMethodLabel}</span></c:when>
                <c:when test="${payMethodCd == 'POINT' || payMethodCd == 'ZERO'}"><span class="rf-badge point">${payMethodLabel}</span></c:when>
                <c:otherwise><span class="rf-badge unknown">${payMethodLabel}</span></c:otherwise>
              </c:choose>
            </span>
          </div>
          <div class="rf-row"><span>주문 상품합</span><span><fmt:formatNumber value="${refund.orderProductTotal}" pattern="#,###"/>원</span></div>
          <div class="rf-row"><span>주문 쿠폰</span>
            <span>
              <c:if test="${orderCouponAmt > 0}">-</c:if><fmt:formatNumber value="${orderCouponAmt}" pattern="#,###"/>원
              <c:if test="${not empty refund.couponName}"><span style="font-weight:500;color:#888"> (<c:out value="${refund.couponName}"/>)</span></c:if>
            </span>
          </div>
          <div class="rf-row"><span>주문 포인트</span><span><c:if test="${orderPointAmt > 0}">-</c:if><fmt:formatNumber value="${orderPointAmt}" pattern="#,###"/>P</span></div>
          <div class="rf-row"><span>주문 배송비</span>
            <span>
              <fmt:formatNumber value="${refund.deliveryFee}" pattern="#,###"/>원
              <span style="font-weight:500;color:#888"> (환불 안 함)</span>
            </span>
          </div>
          <div class="rf-row"><span>주문 실결제</span><span><fmt:formatNumber value="${refund.payAmount}" pattern="#,###"/>원</span></div>
          <c:if test="${paidRefundAmt > 0}">
            <div class="rf-row"><span>이미 카드환불</span><span><fmt:formatNumber value="${paidRefundAmt}" pattern="#,###"/>원</span></div>
          </c:if>
        </div>
        <div>
          <h4>구매자 · 배송</h4>
          <div class="rf-row"><span>구매자</span><span><c:out value="${refund.buyerName}"/></span></div>
          <div class="rf-row"><span>연락처</span><span><c:out value="${refund.buyerPhone}"/></span></div>
          <div class="rf-row"><span>출고송장</span>
            <span>
              <c:choose>
                <c:when test="${empty refund.trackingNo}">-</c:when>
                <c:otherwise><c:out value="${refund.courierName}"/> <c:out value="${refund.trackingNo}"/></c:otherwise>
              </c:choose>
            </span>
          </div>
          <div class="rf-row"><span>환불 신청일</span><span><fmt:formatDate value="${refund.returnRequestedAt}" pattern="yyyy.MM.dd HH:mm"/></span></div>
        </div>
      </div>
    </div>

    <div class="biz-card rf-card">
      <div class="biz-card-head"><span>상품 · 환불액</span></div>
      <div class="rf-grid">
        <div>
          <h4>상품</h4>
          <div class="rf-row"><span>상품명</span><span><c:out value="${refund.productName}"/></span></div>
          <div class="rf-row"><span>옵션</span>
            <span>
              <c:if test="${not empty refund.optionColor}"><c:out value="${refund.optionColor}"/></c:if>
              <c:if test="${not empty refund.optionSize}"> / <c:out value="${refund.optionSize}"/></c:if>
              · ${refund.qty}개
            </span>
          </div>
          <div class="rf-row"><span>유형</span>
            <span>
              <c:choose>
                <c:when test="${refund.returnReasonCd == 'DEFECT'}">상품이상</c:when>
                <c:otherwise>단순변심</c:otherwise>
              </c:choose>
            </span>
          </div>
        </div>
        <div>
          <h4>금액 (이 상품 몫)</h4>
          <div class="rf-row"><span>상품금액</span><span><fmt:formatNumber value="${refund.totalPrice}" pattern="#,###"/>원</span></div>
          <div class="rf-row"><span>쿠폰 사용</span><span><c:if test="${itemCouponAmt > 0}">-</c:if><fmt:formatNumber value="${itemCouponAmt}" pattern="#,###"/>원</span></div>
          <div class="rf-row"><span>포인트 사용</span><span><c:if test="${itemPointAmt > 0}">-</c:if><fmt:formatNumber value="${itemPointAmt}" pattern="#,###"/>P</span></div>
          <div class="rf-row"><span>이 상품 실결제</span><span><fmt:formatNumber value="${itemPayAmt}" pattern="#,###"/>원</span></div>
          <div class="rf-row"><span>반송택배비</span>
            <span>
              <c:choose>
                <c:when test="${bizPaysFee}">
                  <fmt:formatNumber value="${reimburseAmt}" pattern="#,###"/>원
                  <span style="font-weight:500;color:#888"> (사업자 환급)</span>
                </c:when>
                <c:otherwise>
                  <fmt:formatNumber value="${userFeeAmt}" pattern="#,###"/>원
                  <span style="font-weight:500;color:#888"> (유저 선불, 미차감)</span>
                </c:otherwise>
              </c:choose>
            </span>
          </div>
          <c:if test="${refund.lastItemRefund and not empty refund.memberCouponId}">
            <div class="rf-row"><span>쿠폰 복구</span><span>이 건 완료 시 복구</span></div>
          </c:if>
          <div class="rf-row"><span>예상 카드환불</span>
            <span style="color:#E2445C;font-weight:800">
              <c:choose>
                <c:when test="${not empty refund.refundAmount and refund.returnStatusCd == 'DONE'}">
                  <fmt:formatNumber value="${refund.refundAmount}" pattern="#,###"/>원
                </c:when>
                <c:otherwise>
                  <fmt:formatNumber value="${cardRefundAmt}" pattern="#,###"/>원
                  <c:if test="${cardRefundAmt lt (itemPayAmt + reimburseAmt)}">
                    <span style="font-weight:500;color:#888"> (카드 잔액 한도)</span>
                  </c:if>
                </c:otherwise>
              </c:choose>
            </span>
          </div>
        </div>
      </div>
      <div style="padding:0 24px 20px">
        <div style="font-size:12px;color:#94A3B8;margin-bottom:6px;">신청 내용</div>
        <div class="rf-reason"><c:out value="${refund.claimReason}"/></div>
        <c:if test="${not empty refund.photoUrls}">
          <div class="rf-photos">
            <c:forEach var="url" items="${refund.photoUrls}">
              <c:choose>
                <c:when test="${fn:startsWith(url, 'http://') || fn:startsWith(url, 'https://')}">
                  <c:set var="photoSrc" value="${url}" />
                </c:when>
                <c:when test="${fn:startsWith(url, '/upload/')}">
                  <c:set var="photoSrc" value="${contextPath}${url}" />
                </c:when>
                <c:when test="${fn:startsWith(url, 'upload/')}">
                  <c:set var="photoSrc" value="${contextPath}/${url}" />
                </c:when>
                <c:otherwise>
                  <c:set var="photoSrc" value="${contextPath}/upload/${url}" />
                </c:otherwise>
              </c:choose>
              <a href="${photoSrc}" target="_blank" rel="noopener">
                <img src="${photoSrc}" alt="증빙">
              </a>
            </c:forEach>
          </div>
        </c:if>
        <c:if test="${not empty refund.returnRejectReason}">
          <div style="margin-top:12px;color:#BE123C;font-size:13px;">거절 사유: <c:out value="${refund.returnRejectReason}"/></div>
        </c:if>
      </div>
    </div>

    <div class="biz-card rf-card">
      <div class="biz-card-head"><span>처리</span></div>
      <div style="padding:16px 24px 22px">
        <div class="rf-guide">
          반려하면 주문은 그대로 진행됩니다. 승인 → 환불진행 → 반송 수령 후 <strong>회수완료</strong> 시 카드 실결제가 취소됩니다.<br>
          주문 배송비는 환불하지 않습니다. 쿠폰·포인트는 상품금액 비율로만 나눕니다.<br>
          이 상품 실결제 = 상품금액 − (주문 쿠폰·포인트를 상품금액 비율로 나눈 몫).<br>
          단순변심: 이 상품 실결제만 카드환불 (반송비는 유저 선불, 환불금 미차감).<br>
          상품이상: 이 상품 실결제 + 반송 3,000원. 카드 잔액(실결제 − 이미환불)을 넘을 수 없습니다.<br>
          포인트는 이 상품 몫만큼 복구되고, 쿠폰은 주문 상품이 모두 환불될 때만 복구됩니다.<br>
          이 주문의 결제수단: <strong>${payMethodLabel}</strong>
          <c:if test="${payMethodCd == 'BILLING' || payMethodCd == 'TOSS' || payMethodCd == 'CARD'}">
            → 회수완료 시 <strong>${refundChannelLabel}</strong>로 환불합니다. (둘 다 토스페이먼츠 API, 시크릿만 다름)
          </c:if>
        </div>

        <c:if test="${refund.returnStatusCd == 'REQUESTED'}">
          <div class="rf-actions">
            <form method="post" action="${contextPath}/biz/store/refunds/approve"
                  onsubmit="return confirm('승인하여 환불진행으로 바꿀까요?');">
              <input type="hidden" name="_csrf" value="${_csrf}">
              <input type="hidden" name="orderItemId" value="${refund.orderItemId}">
              <button type="submit" class="biz-btn primary">승인 (환불진행)</button>
            </form>
            <form method="post" action="${contextPath}/biz/store/refunds/reject"
                  class="rf-reject" onsubmit="return confirm('거절할까요? 주문은 그대로 진행됩니다.');"
                  style="display:flex;gap:8px;align-items:center;flex-wrap:wrap;">
              <input type="hidden" name="_csrf" value="${_csrf}">
              <input type="hidden" name="orderItemId" value="${refund.orderItemId}">
              <input type="text" name="rejectReason" required placeholder="거절 사유" maxlength="500">
              <button type="submit" class="biz-btn" style="background:#E2445C;color:#fff;border-color:#E2445C;">거절</button>
            </form>
          </div>
        </c:if>

        <c:if test="${refund.returnStatusCd == 'RETURNING'}">
          <form method="post" action="${contextPath}/biz/store/refunds/complete"
                onsubmit="return confirm('회수완료 후 ${refundChannelLabel}을(를) 진행할까요?\n결제수단: ${payMethodLabel}\n예상 카드환불: ${cardRefundAmt}원');">
            <input type="hidden" name="_csrf" value="${_csrf}">
            <input type="hidden" name="orderItemId" value="${refund.orderItemId}">
            <button type="submit" class="biz-btn primary">회수완료 (환불 실행)</button>
          </form>
        </c:if>

        <c:if test="${refund.returnStatusCd == 'DONE'}">
          <span class="bs-badge bs-done">환불 완료</span>
          <span style="margin-left:8px;font-size:13px;color:#64748B"><fmt:formatDate value="${refund.returnDoneAt}" pattern="yyyy.MM.dd HH:mm"/></span>
        </c:if>
        <c:if test="${refund.returnStatusCd == 'REJECTED'}">
          <span class="bs-badge bs-cancel">거절됨</span>
        </c:if>
      </div>
    </div>
  </div>
</main>

<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>
