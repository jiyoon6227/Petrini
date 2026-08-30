<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%-- 2026/08/04 장우철 — 쇼핑 상품단위 환불 신청 (1:1문의 폼 유사) --%>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="mypage" />
<c:set var="sec" value="orders" />

<%@ include file="/WEB-INF/views/common/header.jsp" %>
<link rel="stylesheet" href="${contextPath}/resources/css/mypage.css">

<div class="mypage-wrap">
<%@ include file="/WEB-INF/views/mypage/sidebar.jsp" %>
<div class="mypage-content">

  <div class="mp-section active">
    <div class="mp-section-head">
      <h2>환불 신청</h2>
      <p style="font-size:13px;color:var(--text-muted);margin:6px 0 0;">단순변심은 반송 택배비 3,000원을 직접 선불합니다(환불금에서 차감하지 않음). 상품이상은 반송 3,000원을 환불에 더합니다(카드 잔액 한도).</p>
    </div>

    <c:if test="${not empty errorMsg}">
      <div style="background:#FFF1F2;border:1px solid #FECDD3;color:#BE123C;padding:12px 14px;border-radius:8px;margin-bottom:16px;font-size:13px;">
        ${errorMsg}
      </div>
    </c:if>

    <div style="background:#fff;border:1px solid #E2E8E4;border-radius:12px;padding:24px;max-width:640px;">
      <div style="display:flex;gap:14px;align-items:center;margin-bottom:20px;padding-bottom:16px;border-bottom:1px solid #F1F5F4;">
        <%-- 2026/08/18 장우철 — 환불 신청 상품 사진도 /upload 경로 맞춤 --%>
        <c:choose>
          <c:when test="${empty item.thumbnailUrl}">
            <c:set var="refundThumbSrc" value="https://placehold.co/72x72/EAF7F2/2BAB82?text=IMG" />
          </c:when>
          <c:when test="${fn:startsWith(item.thumbnailUrl, 'http')}">
            <c:set var="refundThumbSrc" value="${item.thumbnailUrl}" />
          </c:when>
          <c:when test="${fn:startsWith(item.thumbnailUrl, '/')}">
            <c:set var="refundThumbSrc" value="${contextPath}${item.thumbnailUrl}" />
          </c:when>
          <c:otherwise>
            <c:set var="refundThumbSrc" value="${contextPath}/upload/${item.thumbnailUrl}" />
          </c:otherwise>
        </c:choose>
        <img src="${refundThumbSrc}"
             alt="" style="width:72px;height:72px;object-fit:cover;border-radius:8px;"
             onerror="this.src='https://placehold.co/72x72/EAF7F2/2BAB82?text=IMG'">
        <div>
          <div style="font-weight:800;font-size:15px;">${item.productName}</div>
          <div style="font-size:13px;color:#64748B;margin-top:4px;">
            <c:if test="${not empty item.optionColor && item.optionColor != '기본'}">${item.optionColor}</c:if>
            <c:if test="${not empty item.optionSize}"> / ${item.optionSize}</c:if>
            · 수량 ${item.qty}
          </div>
          <div style="font-weight:700;margin-top:6px;"><fmt:formatNumber value="${item.totalPrice}" pattern="#,###"/>원</div>
        </div>
      </div>

      <form method="post" action="${contextPath}/mypage/orders/refund" enctype="multipart/form-data"
            onsubmit="return validateRefundForm()">
        <%-- 2026/08/07 장우철 CSRF --%>
        <input type="hidden" name="_csrf" value="${_csrf}">
        <input type="hidden" name="orderItemId" value="${item.orderItemId}">

        <label style="display:block;font-size:13px;font-weight:700;margin-bottom:8px;">환불 유형 <span style="color:#E2445C;">*</span></label>
        <div style="display:flex;flex-direction:column;gap:8px;margin-bottom:18px;">
          <label style="display:flex;gap:8px;align-items:center;padding:12px;border:1px solid #E2E8E4;border-radius:8px;cursor:pointer;">
            <input type="radio" name="reasonCd" value="CHANGE_OF_MIND" checked onchange="toggleDefectPhotos()">
            <span>환불 (단순변심)</span>
          </label>
          <label style="display:flex;gap:8px;align-items:center;padding:12px;border:1px solid #E2E8E4;border-radius:8px;cursor:pointer;">
            <input type="radio" name="reasonCd" value="DEFECT" onchange="toggleDefectPhotos()">
            <span>환불 (상품이상)</span>
          </label>
        </div>

        <label style="display:block;font-size:13px;font-weight:700;margin-bottom:8px;">신청 내용 <span style="color:#E2445C;">*</span></label>
        <textarea name="content" id="refundContent" required maxlength="500" rows="6"
                  placeholder="환불 사유를 자세히 적어 주세요."
                  style="width:100%;box-sizing:border-box;border:1px solid #E2E8E4;border-radius:8px;padding:12px;font-size:14px;resize:vertical;"></textarea>

        <div id="defectPhotoBox" style="display:none;margin-top:16px;">
          <label style="display:block;font-size:13px;font-weight:700;margin-bottom:8px;">사진 첨부 <span style="color:#E2445C;">*</span> (상품이상, 최대 5장)</label>
          <input type="file" name="images" id="refundImages" accept="image/*" multiple>
          <p style="font-size:12px;color:#94A3B8;margin-top:6px;">상품 하자·파손 등이 보이도록 촬영해 주세요.</p>
        </div>

        <div id="refundFeeGuide" style="background:#F8FAFC;border-radius:8px;padding:12px 14px;margin:18px 0;font-size:13px;color:#475569;line-height:1.6;">
          · 송장 등록 이후 환불은 상품 수령 후 직접 반송하는 방식입니다. 주문 배송비는 환불되지 않습니다.<br>
          · <span id="refundFeeText">반송 택배비 <strong>3,000원</strong>은 직접 선불합니다. 환불금에서는 차감하지 않으며, 이 상품 실결제만 환불됩니다.</span><br>
          · 사업자 승인 후 반송 → 회수완료 시 환불됩니다. 쿠폰은 주문 상품을 모두 환불할 때만 복구됩니다.
        </div>

        <div style="display:flex;gap:8px;justify-content:flex-end;">
          <a href="${contextPath}/mypage/orders" class="btn-sm" style="text-decoration:none;display:inline-flex;align-items:center;">취소</a>
          <button type="submit" class="btn-sm primary" style="background:#E2445C;border-color:#E2445C;color:#fff;">신청하기</button>
        </div>
      </form>
    </div>
  </div>
</div>
</div>

<script>
function toggleDefectPhotos() {
  var defect = document.querySelector('input[name="reasonCd"][value="DEFECT"]').checked;
  document.getElementById('defectPhotoBox').style.display = defect ? 'block' : 'none';
  var feeText = document.getElementById('refundFeeText');
  if (feeText) {
    feeText.innerHTML = defect
      ? '상품이상은 반송 택배비 <strong>3,000원</strong>을 환불에 더합니다. 직접 선불 반송해 주세요. (카드 실결제 잔액 한도)'
      : '반송 택배비 <strong>3,000원</strong>은 직접 선불합니다. 환불금에서는 차감하지 않으며, 이 상품 실결제만 환불됩니다.';
  }
}
function validateRefundForm() {
  var content = document.getElementById('refundContent').value.trim();
  if (!content) { alert('신청 내용을 입력해 주세요.'); return false; }
  var defect = document.querySelector('input[name="reasonCd"][value="DEFECT"]').checked;
  if (defect) {
    var files = document.getElementById('refundImages').files;
    if (!files || files.length === 0) {
      alert('상품이상 환불은 사진을 1장 이상 첨부해 주세요.');
      return false;
    }
    if (files.length > 5) {
      alert('사진은 최대 5장까지 첨부할 수 있습니다.');
      return false;
    }
  }
  return confirm('환불을 신청하시겠습니까?');
}
</script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
