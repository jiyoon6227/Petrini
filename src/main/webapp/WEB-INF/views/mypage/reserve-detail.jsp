<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="mypage" />
<c:set var="sec" value="reserve" />

<%@ include file="/WEB-INF/views/common/header.jsp" %>
<link rel="stylesheet" href="${contextPath}/resources/css/mypage.css">

<style>
  .rd-card{background:#fff;border:1px solid #E2E8E4;border-radius:12px;padding:24px;margin-bottom:16px}
  .rd-row{display:flex;justify-content:space-between;gap:16px;padding:12px 0;border-bottom:1px solid #F5F6F4;font-size:14px}
  .rd-row:last-child{border-bottom:none}
  .rd-row span:first-child{color:#888;flex-shrink:0;min-width:90px}
  .rd-row span:last-child{color:#1A1A2E;font-weight:600;text-align:right}
  .rd-reason{background:#FEF2F2;border-radius:8px;padding:14px 16px;margin-top:8px;font-size:13px;color:#991B1B;line-height:1.6}
  /* 2026/07/13 장우철 — 리뷰 작성 폼 */
  .rd-review{background:#F8FFFC;border:1px solid #C6EDE0;border-radius:12px;padding:20px;margin-bottom:16px}
  .rd-review h3{font-size:16px;font-weight:800;margin:0 0 12px;color:#1A1A2E}
  .rd-stars{display:flex;gap:8px;margin-bottom:12px;flex-wrap:wrap}
  .rd-stars label{cursor:pointer;font-size:14px;color:#555}
  .rd-stars input{margin-right:4px}
  .rd-review textarea{width:100%;min-height:90px;border:1px solid #E2E8E4;border-radius:8px;padding:10px 12px;font-size:14px;resize:vertical;box-sizing:border-box}
  .rd-review .btn-review{margin-top:12px;background:#2BAB82;color:#fff;border:none;border-radius:8px;padding:10px 18px;font-weight:700;cursor:pointer}
  /* 2026/07/31 장우철 — 숙소 유저 취소 */
  .rd-cancel{background:#FFF8F8;border:1px solid #FECACA;border-radius:12px;padding:20px;margin-bottom:16px}
  .rd-cancel h3{font-size:16px;font-weight:800;margin:0 0 8px;color:#1A1A2E}
  .rd-cancel .fee-row{display:flex;justify-content:space-between;font-size:14px;padding:6px 0;color:#444}
  .rd-cancel .fee-row strong{color:#B91C1C}
  .rd-cancel textarea{width:100%;min-height:80px;border:1px solid #E2E8E4;border-radius:8px;padding:10px 12px;font-size:14px;resize:vertical;box-sizing:border-box;margin-top:10px}
  .rd-cancel .btn-cancel-stay{margin-top:12px;background:#DC2626;color:#fff;border:none;border-radius:8px;padding:10px 18px;font-weight:700;cursor:pointer}
</style>

<div class="mypage-wrap">
<%@ include file="/WEB-INF/views/mypage/sidebar.jsp" %>
<div class="mypage-content">

<%-- 2026/07/11 장우철 — 마이페이지 예약 상세 (2차) --%>
<div class="mp-section active">
  <h2 class="mp-title">
    <c:choose>
      <c:when test="${reservation.resvType eq 'TALENT'}">재능나눔 신청 상세</c:when>
      <c:otherwise>예약 상세</c:otherwise>
    </c:choose>
  </h2>
  <p class="mp-desc">
    <c:choose>
      <c:when test="${reservation.resvType eq 'TALENT'}">신청번호</c:when>
      <c:otherwise>예약번호</c:otherwise>
    </c:choose>
    <strong><c:out value="${reservation.resvNo}"/></strong>
  </p>

  <c:if test="${not empty msg}">
    <p style="color:#166534;font-size:14px;margin-bottom:12px"><c:out value="${msg}"/></p>
  </c:if>
  <c:if test="${not empty errorMsg}">
    <p style="color:#B91C1C;font-size:14px;margin-bottom:12px"><c:out value="${errorMsg}"/></p>
  </c:if>

  <c:choose>
    <%-- 2026-08-10 박유정 — 재능나눔 참여 신청 상세 (예약내역 통합) --%>
    <c:when test="${reservation.resvType eq 'TALENT'}">
      <div class="rd-card">
        <div class="rd-row">
          <span>상태</span>
          <span>
            <c:choose>
              <c:when test="${reservation.statusCd eq 'PENDING'}"><span class="badge-status badge-wait">확인대기</span></c:when>
              <c:when test="${reservation.statusCd eq 'CONFIRMED'}"><span class="badge-status badge-ready">확인완료</span></c:when>
              <c:when test="${reservation.statusCd eq 'CANCELLED'}"><span class="badge-status badge-cancel">취소</span></c:when>
              <c:otherwise><c:out value="${reservation.statusCd}"/></c:otherwise>
            </c:choose>
          </span>
        </div>
        <div class="rd-row"><span>재능나눔</span><span><c:out value="${reservation.talentTitle}"/></span></div>
        <div class="rd-row"><span>제공 사업자</span><span><c:out value="${not empty reservation.bizName ? reservation.bizName : '-'}"/></span></div>
        <div class="rd-row"><span>장소</span><span><c:out value="${not empty reservation.hospitalAddr ? reservation.hospitalAddr : '-'}"/></span></div>
        <div class="rd-row"><span>진행 일정</span><span><c:out value="${not empty reservation.talentSchedule ? reservation.talentSchedule : '-'}"/></span></div>
        <c:if test="${not empty reservation.endTime}">
          <div class="rd-row"><span>소요 시간</span><span><c:out value="${reservation.endTime}"/></span></div>
        </c:if>
        <div class="rd-row"><span>신청일</span><span><fmt:formatDate value="${reservation.regDate}" pattern="yyyy-MM-dd HH:mm"/></span></div>
        <div class="rd-row"><span>신청 메시지</span><span><c:out value="${not empty reservation.requestMemo ? reservation.requestMemo : '-'}"/></span></div>
        <c:if test="${not empty reservation.symptoms}">
          <div class="rd-row" style="display:block;border-bottom:none;padding-bottom:0">
            <span style="display:block;margin-bottom:6px">서비스 설명</span>
            <div style="text-align:left;font-weight:400;line-height:1.6;white-space:pre-line;color:#444"><c:out value="${reservation.symptoms}"/></div>
          </div>
        </c:if>
      </div>

      <c:if test="${reservation.cancelable eq true}">
        <div class="rd-cancel">
          <h3>신청 취소</h3>
          <p style="font-size:13px;color:#666;margin:0 0 12px;line-height:1.5">
            병원 확인 전(PENDING)인 경우에만 취소할 수 있습니다.
          </p>
          <form method="post" action="${contextPath}/mypage/reserve/talent-cancel"
                onsubmit="return confirm('재능나눔 신청을 취소하시겠습니까?');">
            <input type="hidden" name="_csrf" value="${_csrf}">
            <input type="hidden" name="resvId" value="${reservation.resvId}">
            <button type="submit" class="btn-cancel-stay">신청 취소하기</button>
          </form>
        </div>
      </c:if>

      <a class="btn-sm" style="display:inline-block;margin-right:8px;text-decoration:none"
         href="${contextPath}/give/talent/detail?id=${reservation.targetId}">재능나눔 글 보기</a>
      <button type="button" class="btn-sm" onclick="location.href='${contextPath}/mypage/reserve'">← 목록으로</button>
    </c:when>
    <c:otherwise>
  <div class="rd-card">
    <div class="rd-row">
      <span>상태</span>
      <span>
        <c:choose>
          <c:when test="${reservation.statusCd eq 'PENDING'}"><span class="badge-status badge-wait">예약신청</span></c:when>
          <c:when test="${reservation.statusCd eq 'CONFIRMED'}"><span class="badge-status badge-ready">예약확정</span></c:when>
          <%-- 2026/08/06 장우철 — 운영 상태만 표시 (환불 신청/거절은 아래 환불 영역) --%>
          <c:when test="${reservation.statusCd eq 'CHECKIN'}">
            <span class="badge-status badge-ready">체크인</span>
          </c:when>
          <c:when test="${reservation.statusCd eq 'CHECKOUT'}"><span class="badge-status badge-ready">체크아웃</span></c:when>
          <c:when test="${reservation.statusCd eq 'DONE'}">
            <span class="badge-status badge-done">
              <c:choose>
                <c:when test="${reservation.resvType eq 'STAY'}">이용완료</c:when>
                <c:when test="${reservation.resvType eq 'HOSPITAL'}">진료완료</c:when>
                <c:otherwise>완료</c:otherwise>
              </c:choose>
            </span>
          </c:when>
          <c:otherwise><span class="badge-status badge-cancel">취소</span></c:otherwise>
        </c:choose>
      </span>
    </div>
    <div class="rd-row">
      <span>
        <c:if test="${reservation.resvType eq 'STAY'}">숙소</c:if>
        <c:if test="${reservation.resvType eq 'HOSPITAL'}">병원</c:if>
      </span>
      <span><c:out value="${not empty reservation.hospitalName ? reservation.hospitalName : '-'}"/></span>
    </div>
    <div class="rd-row">
      <span>주소</span>
      <span><c:out value="${not empty reservation.hospitalAddr ? reservation.hospitalAddr : '-'}"/></span>
    </div>
    <div class="rd-row">
      <span>예약일시</span>
      <span>
        <!--HYJ 26.07.28 사업장에 따라 처리-->
        <fmt:formatDate value="${reservation.resvDate}" pattern="yyyy-MM-dd"/>
        <c:if test="${not empty reservation.resvTime}"> ${reservation.resvTime}</c:if>
        <c:if test="${not empty reservation.endTime}"> ~ ${reservation.endTime}</c:if>
      </span>
    </div>
    <c:if test="${reservation.resvType eq 'HOSPITAL'}">
      <div class="rd-row">
        <span>담당 의사</span>
        <span><c:out value="${not empty reservation.doctorName ? reservation.doctorName : '-'}"/></span>
      </div>
      <div class="rd-row">
        <span>진료 유형</span>
        <span><c:out value="${not empty reservation.treatTypeName ? reservation.treatTypeName : '-'}"/></span>
      </div>
    </c:if>
    <div class="rd-row">
      <span>반려동물</span>
      <span>
        <c:out value="${reservation.petName}"/>
        <c:if test="${not empty reservation.petSpecies}"> (<c:out value="${reservation.petSpecies}"/>
          <c:if test="${not empty reservation.petBreed}"> / <c:out value="${reservation.petBreed}"/></c:if>)</c:if>
        <c:if test="${reservation.resvType eq 'STAY' and reservation.petCnt != null and reservation.petCnt > 1}">
          · 총 ${reservation.petCnt}마리
        </c:if>
      </span>
    </div>
    <div class="rd-row">
      <c:if test="${reservation.resvType eq 'HOSPITAL'}">
        <span>증상</span>
        <span><c:out value="${not empty reservation.symptoms ? reservation.symptoms : '-'}"/></span>
      </c:if>
    </div>
    <div class="rd-row">
      <span>요청사항</span>
      <span><c:out value="${not empty reservation.requestMemo ? reservation.requestMemo : '-'}"/></span>
    </div>
    <c:if test="${reservation.statusCd eq 'CANCEL' or reservation.statusCd eq 'REJECTED'}">
      <div class="rd-row" style="display:block;border-bottom:none;padding-bottom:0">
        <span style="display:block;margin-bottom:6px">취소 사유</span>
        <div class="rd-reason">
          <c:out value="${not empty reservation.rejectReason ? reservation.rejectReason : '사유가 등록되지 않았습니다.'}"/>
        </div>
      </div>
      <c:if test="${reservation.resvType eq 'STAY'}">
        <c:if test="${not empty reservation.cancelFeeAmt}">
          <div class="rd-row">
            <span>취소수수료</span>
            <span><fmt:formatNumber value="${reservation.cancelFeeAmt}" pattern="#,###"/>원</span>
          </div>
        </c:if>
        <c:if test="${not empty reservation.refundAmt}">
          <div class="rd-row">
            <span>환불금액</span>
            <span><fmt:formatNumber value="${reservation.refundAmt}" pattern="#,###"/>원</span>
          </div>
        </c:if>
      </c:if>
    </c:if>
  </div>

  <%-- 2026/08/01 장우철 — PENDING(결제 미완료) 숙소 예약 재결제 --%>
  <c:if test="${reservation.resvType eq 'STAY' and reservation.statusCd eq 'PENDING'}">
    <div class="rd-cancel" style="background:#FFF8EE;border-color:#F5C26B">
      <h3 style="margin:0 0 8px">결제 대기</h3>
      <p style="font-size:13px;color:#666;margin:0 0 12px;line-height:1.5">
        예약은 신청되었지만 결제가 완료되지 않았습니다. 아래에서 결제를 이어가 주세요.
        (미결제 예약은 일정 시간 후 자동 취소될 수 있습니다.)
      </p>
      <a class="btn-cancel-stay" style="display:inline-block;text-decoration:none;background:#FD8B00;text-align:center"
         href="${contextPath}/stay/payment?resvId=${reservation.resvId}">결제하러 가기</a>
    </div>
  </c:if>

  <%-- 2026/07/31 장우철 — 숙소 CONFIRMED + 체크인 전 유저 취소 (1-4·1-6) --%>
  <c:if test="${reservation.resvType eq 'STAY' and reservation.cancelable eq true}">
    <div class="rd-cancel">
      <h3>예약 취소</h3>
      <p style="font-size:13px;color:#666;margin:0 0 10px;line-height:1.5">
        체크인 전 취소 시 입실일 기준으로 취소수수료가 적용됩니다.
        (<c:out value="${reservation.cancelFeeTierLabel}"/> · 체크인까지 ${reservation.daysUntilCheckin}일)
      </p>
      <div class="fee-row"><span>실결제금액</span><span><fmt:formatNumber value="${reservation.payAmount}" pattern="#,###"/>원</span></div>
      <c:if test="${not empty reservation.couponDiscount and reservation.couponDiscount > 0}">
        <div class="fee-row"><span>쿠폰할인</span><span><fmt:formatNumber value="${reservation.couponDiscount}" pattern="#,###"/>원 (복구)</span></div>
      </c:if>
      <c:if test="${not empty reservation.pointUsed and reservation.pointUsed > 0}">
        <div class="fee-row"><span>사용포인트</span><span><fmt:formatNumber value="${reservation.pointUsed}" pattern="#,###"/>P (복구)</span></div>
      </c:if>
      <div class="fee-row">
        <span>취소수수료 (${reservation.cancelFeeRatePercent}%)</span>
        <strong><fmt:formatNumber value="${reservation.cancelFeeAmt}" pattern="#,###"/>원</strong>
      </div>
      <div class="fee-row"><span>예상 카드환불액</span><span><fmt:formatNumber value="${reservation.refundAmt}" pattern="#,###"/>원</span></div>
      <form method="post" action="${contextPath}/mypage/reserve/stay-cancel"
            onsubmit="return confirm('예약을 취소하시겠습니까? 취소수수료가 적용됩니다.');">
        <!--HYJ 26.08.05-->
        <input type="hidden" name="_csrf" value="${_csrf}">
        
        <input type="hidden" name="resvId" value="${reservation.resvId}">
        <textarea name="cancelReason" maxlength="500" placeholder="취소 사유를 입력해 주세요." required></textarea>
        <button type="submit" class="btn-cancel-stay">예약 취소하기</button>
      </form>
    </div>
  </c:if>

  <%-- 2026/08/06 장우철 — 숙소 환불: 상세 전용 (B: APPROVED/REJECTED, 예약 운영상태 유지) --%>
  <c:if test="${reservation.resvType eq 'STAY'
      and (reservation.statusCd eq 'CHECKIN'
        or reservation.stayRefundStatus eq 'PENDING'
        or reservation.stayRefundStatus eq 'APPROVED'
        or reservation.stayRefundStatus eq 'REJECTED')}">
    <div class="rd-cancel" style="background:#F8FAFF;border-color:#C7D2FE">
      <h3 style="margin:0 0 8px">환불 신청</h3>
      <c:choose>
        <c:when test="${reservation.stayRefundStatus eq 'PENDING'}">
          <p style="font-size:13px;color:#666;margin:0 0 12px;line-height:1.5">
            환불 신청이 접수되어 관리자 검토 중입니다.
          </p>
          <span class="btn-cancel-stay" style="display:inline-block;background:#9CA3AF;cursor:default;opacity:.85">환불 신청중</span>
        </c:when>
        <c:when test="${reservation.stayRefundStatus eq 'APPROVED'}">
          <p style="font-size:13px;color:#166534;margin:0 0 12px;line-height:1.5">
            환불이 승인되어 결제금이 전액 환불됩니다.
            예약 기간 동안 해당 숙소 이용은 그대로 가능합니다(보상 숙박).
          </p>
          <c:if test="${not empty reservation.stayRefundAnswer}">
            <div class="rd-reason" style="margin-bottom:12px;background:#ECFDF5;color:#166534">
              <strong style="display:block;margin-bottom:4px;font-size:12px">안내</strong>
              <c:out value="${reservation.stayRefundAnswer}"/>
            </div>
          </c:if>
          <c:if test="${not empty reservation.refundAmt}">
            <div class="fee-row" style="margin-bottom:12px">
              <span>환불금액</span>
              <strong style="color:#166534"><fmt:formatNumber value="${reservation.refundAmt}" pattern="#,###"/>원</strong>
            </div>
          </c:if>
          <span class="btn-cancel-stay" style="display:inline-block;background:#16A34A;cursor:default;opacity:.9">환불 승인 · 이용 유지</span>
        </c:when>
        <c:when test="${reservation.stayRefundStatus eq 'REJECTED'}">
          <p style="font-size:13px;color:#B91C1C;margin:0 0 12px;line-height:1.5">
            환불이 거절되었습니다. 재신청할 수 없습니다.
          </p>
          <c:if test="${not empty reservation.stayRefundAnswer}">
            <div class="rd-reason" style="margin-bottom:12px">
              <strong style="display:block;margin-bottom:4px;font-size:12px">거절 사유</strong>
              <c:out value="${reservation.stayRefundAnswer}"/>
            </div>
          </c:if>
          <span class="btn-cancel-stay" style="display:inline-block;background:#9CA3AF;cursor:default;opacity:.85">환불 거절 · 재신청 불가</span>
        </c:when>
        <c:otherwise>
          <p style="font-size:13px;color:#666;margin:0 0 12px;line-height:1.5">
            체크인 이후 환불은 관리자 1:1 문의로 접수됩니다.
          </p>
          <a class="btn-cancel-stay" style="display:inline-block;text-decoration:none;background:#3B5BDB"
             href="${contextPath}/member/cs/inquiry/write?resvId=${reservation.resvId}&amp;type=stay_refund">환불 신청하기</a>
        </c:otherwise>
      </c:choose>
    </div>
  </c:if>

  <%-- 2026/07/13 장우철 — 완료 안내 / HYJ 26.07.20 숙소 분기 추가 --%>
  <c:if test="${reservation.statusCd eq 'DONE'}">
    <p style="font-size:14px;color:#1F8464;background:#E8F8F1;border-radius:8px;padding:12px 14px;margin-bottom:16px;line-height:1.5">
      <c:choose>
        <c:when test="${reservation.resvType eq 'STAY'}">
          숙박이 완료되었습니다.
          <c:if test="${reservation.reviewedYn ne 'Y'}">아래에서 리뷰를 작성해 주세요.</c:if>
          <c:if test="${reservation.reviewedYn eq 'Y'}">작성하신 리뷰는 숙소 상세에 반영됩니다.</c:if>
        </c:when>
        <c:otherwise>
          진료가 완료되었습니다. 병원·반려동물 정보를 확인하고
          <c:if test="${reservation.reviewedYn ne 'Y'}">아래에서 리뷰를 작성해 주세요.</c:if>
          <c:if test="${reservation.reviewedYn eq 'Y'}">작성하신 리뷰는 병원 상세에 반영됩니다.</c:if>
        </c:otherwise>
      </c:choose>
    </p>
  </c:if>

  <c:if test="${reservation.resvType eq 'HOSPITAL' and reservation.statusCd eq 'DONE' and reservation.reviewedYn ne 'Y'}">
    <div class="rd-review">
      <h3>병원 리뷰 작성</h3>
      <p style="font-size:13px;color:#666;margin:0 0 12px">진료받으신 병원에 별점과 후기를 남겨 주세요.</p>
      <form method="post" action="${contextPath}/mypage/reserve/review">
        <!--HYJ 26.08.05-->
        <input type="hidden" name="_csrf" value="${_csrf}">
        
        <input type="hidden" name="resvId" value="${reservation.resvId}">
        <div class="rd-stars">
          <label><input type="radio" name="rating" value="5" checked> ★5</label>
          <label><input type="radio" name="rating" value="4"> ★4</label>
          <label><input type="radio" name="rating" value="3"> ★3</label>
          <label><input type="radio" name="rating" value="2"> ★2</label>
          <label><input type="radio" name="rating" value="1"> ★1</label>
        </div>
        <textarea name="content" maxlength="2000" placeholder="진료 경험, 친절도, 시설 등을 자유롭게 작성해 주세요." required></textarea>
        <button type="submit" class="btn-review">리뷰 등록</button>
      </form>
    </div>
  </c:if>
  <c:if test="${reservation.resvType eq 'HOSPITAL' and reservation.statusCd eq 'DONE' and reservation.reviewedYn eq 'Y'}">
    <p style="font-size:14px;color:#166534;margin-bottom:16px">이 예약에 대한 리뷰를 작성하셨습니다.</p>
  </c:if>

  <%-- HYJ 26.07.20 — 숙박완료 + 미작성 시 숙소 리뷰·별점 작성 --%>
  <c:if test="${reservation.resvType eq 'STAY' and reservation.statusCd eq 'DONE' and reservation.reviewedYn ne 'Y'}">
    <div class="rd-review">
      <h3>숙소 리뷰 작성</h3>
      <p style="font-size:13px;color:#666;margin:0 0 6px">숙박하신 숙소에 별점과 후기를 남겨 주세요.</p>
      <c:if test="${not empty reservation.totalAmount and reservation.totalAmount > 0}">
        <p style="font-size:13px;color:#2BAB82;font-weight:700;margin:0 0 12px">
          🎉 리뷰 작성 시 결제 금액의 3% (<fmt:formatNumber value="${reservation.totalAmount * 0.03}" pattern="#,###" maxFractionDigits="0"/>P) 적립!
        </p>
      </c:if>
      <form method="post" action="${contextPath}/mypage/reserve/stay-review"
            onsubmit="var b=this.querySelector('.btn-review'); if(b.disabled)return false; b.disabled=true; b.textContent='등록 중...'; return true;">
        <!--HYJ 26.08.05-->
        <input type="hidden" name="_csrf" value="${_csrf}">
        
        <input type="hidden" name="resvId" value="${reservation.resvId}">
        <div class="rd-stars">
          <label><input type="radio" name="rating" value="5" checked> ★5</label>
          <label><input type="radio" name="rating" value="4"> ★4</label>
          <label><input type="radio" name="rating" value="3"> ★3</label>
          <label><input type="radio" name="rating" value="2"> ★2</label>
          <label><input type="radio" name="rating" value="1"> ★1</label>
        </div>
        <textarea name="content" maxlength="2000" placeholder="숙소 청결도, 반려동물 케어, 시설 등을 자유롭게 작성해 주세요." required></textarea>
        <button type="submit" class="btn-review">리뷰 등록</button>
      </form>
    </div>
  </c:if>
  <c:if test="${reservation.resvType eq 'STAY' and reservation.statusCd eq 'DONE' and reservation.reviewedYn eq 'Y'}">
    <%-- 2026-07-28 박유정 — 숙소 리뷰 포인트 적립 완료 안내 --%>
    <p style="font-size:14px;color:#166534;margin-bottom:16px">이 예약에 대한 리뷰를 작성하셨습니다. (포인트 적립 완료)</p>
  </c:if>

  <button type="button" class="btn-sm" onclick="location.href='${contextPath}/mypage/reserve'">← 목록으로</button>
    </c:otherwise>
  </c:choose>
</div>

</div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
