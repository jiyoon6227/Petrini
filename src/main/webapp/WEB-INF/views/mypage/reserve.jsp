<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="mypage" />
<c:set var="sec" value="reserve" />

<%@ include file="/WEB-INF/views/common/header.jsp" %>
<link rel="stylesheet" href="${contextPath}/resources/css/mypage.css">

<div class="mypage-wrap">
<%@ include file="/WEB-INF/views/mypage/sidebar.jsp" %>
<div class="mypage-content">

<div class="mp-section active">
    <h2 class="mp-title">예약내역</h2>
    <p class="mp-desc">병원·숙소 예약과 재능나눔 참여 신청을 확인할 수 있습니다.</p>

    <c:if test="${param.error eq 'notfound'}">
      <p style="color:#B91C1C;font-size:14px;margin-bottom:12px">예약을 찾을 수 없습니다.</p>
    </c:if>
    <c:if test="${not empty msg}">
      <p style="color:#166534;font-size:14px;margin-bottom:12px"><c:out value="${msg}"/></p>
    </c:if>

    <%-- 2026/07/21 장우철 — 좌측 상태 필터 + 우측 유형(전체/병원/숙소) 드롭다운 --%>
    <%-- 2026-08-10 박유정 — 재능나눔 유형·카드 표시 추가 --%>
    <c:set var="curType" value="${empty typeFilter ? 'all' : typeFilter}" />
    <c:set var="curStatus" value="${empty statusFilter ? 'all' : statusFilter}" />
    <div class="order-filter-bar">
      <div class="order-filter">
        <a class="filter-btn ${curStatus eq 'all' ? 'on' : ''}"
           href="${contextPath}/mypage/reserve?type=${curType}&status=all">전체</a>
        <a class="filter-btn ${curStatus eq 'pending' ? 'on' : ''}"
           href="${contextPath}/mypage/reserve?type=${curType}&status=pending">예약신청</a>
        <a class="filter-btn ${curStatus eq 'confirmed' ? 'on' : ''}"
           href="${contextPath}/mypage/reserve?type=${curType}&status=confirmed">확정</a>
        <a class="filter-btn ${curStatus eq 'done' ? 'on' : ''}"
           href="${contextPath}/mypage/reserve?type=${curType}&status=done">완료</a>
        <a class="filter-btn ${curStatus eq 'cancel' ? 'on' : ''}"
           href="${contextPath}/mypage/reserve?type=${curType}&status=cancel">취소</a>
      </div>
      <div class="reserve-type-filter">
        <label for="typeFilterSelect" class="reserve-type-label">예약 유형</label>
        <select id="typeFilterSelect" class="reserve-type-select"
                onchange="location.href='${contextPath}/mypage/reserve?type=' + this.value + '&status=${curStatus}'">
          <option value="all" ${curType eq 'all' ? 'selected' : ''}>전체</option>
          <option value="hospital" ${curType eq 'hospital' ? 'selected' : ''}>병원</option>
          <option value="stay" ${curType eq 'stay' ? 'selected' : ''}>숙소</option>
          <option value="talent" ${curType eq 'talent' ? 'selected' : ''}>재능나눔</option>
        </select>
      </div>
    </div>

    <c:if test="${empty reservationList}">
      <div style="text-align:center;padding:48px 0;color:#999;font-size:14px">예약 내역이 없습니다.</div>
    </c:if>

    <c:forEach var="r" items="${reservationList}">
      <c:url var="detailUrl" value="/mypage/reserve/detail">
        <c:param name="resvId" value="${r.resvId}"/>
        <c:if test="${r.resvType eq 'TALENT'}">
          <c:param name="resvType" value="TALENT"/>
        </c:if>
      </c:url>
      <a href="${contextPath}${detailUrl}"
         class="resv-card" style="text-decoration:none;color:inherit;display:flex;cursor:pointer">

        <%-- 2026/08/18 장우철 — 숙소·병원도 TB_FILE 썸네일 표시 (재능 THUMB_URL은 /upload/ 포함) --%>
        <c:choose>
          <c:when test="${r.resvType eq 'TALENT'}"><c:set var="thumbFallback" value="https://placehold.co/88x88/EAF7F2/2BAB82?text=재능"/></c:when>
          <c:when test="${r.resvType eq 'STAY'}"><c:set var="thumbFallback" value="https://placehold.co/88x88/E0F2FE/0284C7?text=숙소"/></c:when>
          <c:otherwise><c:set var="thumbFallback" value="https://placehold.co/88x88/EAF7F2/2BAB82?text=병원"/></c:otherwise>
        </c:choose>
        <c:choose>
          <c:when test="${empty r.thumbUrl}">
            <img class="resv-thumb" src="${thumbFallback}" alt="">
          </c:when>
          <c:when test="${fn:startsWith(r.thumbUrl, 'http://') or fn:startsWith(r.thumbUrl, 'https://')}">
            <img class="resv-thumb" src="${r.thumbUrl}" alt="" onerror="this.src='${thumbFallback}'">
          </c:when>
          <c:when test="${fn:startsWith(r.thumbUrl, '/')}">
            <img class="resv-thumb" src="${contextPath}${r.thumbUrl}" alt="" onerror="this.src='${thumbFallback}'">
          </c:when>
          <c:otherwise>
            <img class="resv-thumb" src="${contextPath}/upload/${r.thumbUrl}" alt="" onerror="this.src='${thumbFallback}'">
          </c:otherwise>
        </c:choose>

        <div class="resv-info">
            <%-- 카테고리 --%>
            <c:choose>
              <c:when test="${r.resvType eq 'TALENT'}"><span class="category">재능나눔</span></c:when>
              <c:when test="${r.resvType eq 'STAY'}"><span class="category">펫 숙소</span></c:when>
              <c:otherwise><span class="category">동물병원</span></c:otherwise>
            </c:choose>

            <%-- 장소명 / 제목 --%>
            <div class="rname">
              <c:if test="${r.resvType eq 'TALENT'}">
                <c:out value="${not empty r.talentTitle ? r.talentTitle : '-'}"/>
              </c:if>
              <c:if test="${r.resvType eq 'STAY' and not empty r.roomName}"> <c:out value="${r.stayName}"/> — <c:out value="${r.roomName}"/></c:if>
              <c:if test="${r.resvType eq 'HOSPITAL' and not empty r.hospitalName}"><c:out value="${r.hospitalName}"/></c:if>
            </div>

            <%-- 일정 --%>
            <div class="rmeta">
              <c:choose>
                <c:when test="${r.resvType eq 'TALENT'}">
                  <span>제공: <c:out value="${not empty r.bizName ? r.bizName : '-'}"/></span>
                  <c:if test="${not empty r.talentSchedule}">
                    <span>일정: <c:out value="${r.talentSchedule}"/></span>
                  </c:if>
                  <c:if test="${not empty r.hospitalAddr}">
                    <span><c:out value="${r.hospitalAddr}"/></span>
                  </c:if>
                  <span>신청일: <fmt:formatDate value="${r.regDate}" pattern="yyyy.MM.dd"/></span>
                </c:when>
                <c:when test="${r.resvType eq 'STAY'}">
                  <span>
                    <fmt:formatDate value="${r.checkinDate}" pattern="yyyy.MM.dd"/>
                    ~ <fmt:formatDate value="${r.checkoutDate}" pattern="MM.dd"/>
                    · ${r.nightCnt}박
                  </span>
                  <c:if test="${not empty r.totalAmount}">
                    <span><fmt:formatNumber value="${r.totalAmount}" pattern="#,###"/>원</span>
                  </c:if>
                </c:when>
                <c:otherwise>
                  <span>
                    <fmt:formatDate value="${r.resvDate}" pattern="yyyy년 M월 d일"/>
                    <c:if test="${not empty r.resvTime}"> ${r.resvTime}</c:if>
                    <c:if test="${not empty r.endTime}">~${r.endTime}</c:if>
                  </span>
                  <c:if test="${r.resvType eq 'HOSPITAL' and (not empty r.doctorName or not empty r.treatTypeName)}">
                    <span>
                      <c:if test="${not empty r.doctorName}">담당: <c:out value="${r.doctorName}"/></c:if>
                      <c:if test="${not empty r.treatTypeName}"> · <c:out value="${r.treatTypeName}"/></c:if>
                    </span>
                  </c:if>
                </c:otherwise>
              </c:choose>
              <c:if test="${r.resvType ne 'TALENT' and not empty r.hospitalAddr}">
                <span><c:out value="${r.hospitalAddr}"/></span>
              </c:if>
              <c:if test="${r.resvType ne 'TALENT' and not empty r.petName}">
              <span>반려동물: <c:out value="${r.petName}"/>
                <c:if test="${not empty r.petSpecies}"> (<c:out value="${r.petSpecies}"/>)</c:if>
              </span>
              </c:if>
            </div>
        </div>

        <%-- 상태 배지 --%>
        <div class="resv-right">
          <c:choose>
            <c:when test="${r.resvType eq 'TALENT' and r.statusCd eq 'PENDING'}">
              <span class="badge-status badge-wait">확인대기</span>
            </c:when>
            <c:when test="${r.resvType eq 'TALENT' and r.statusCd eq 'CONFIRMED'}">
              <span class="badge-status badge-ready">확인완료</span>
            </c:when>
            <c:when test="${r.resvType eq 'TALENT' and r.statusCd eq 'CANCELLED'}">
              <span class="badge-status badge-cancel">취소</span>
            </c:when>
            <c:when test="${r.statusCd eq 'PENDING'}">
              <span class="badge-status badge-wait">예약신청</span>
            </c:when>
            <c:when test="${r.statusCd eq 'CONFIRMED'}">
              <span class="badge-status badge-ready">예약확정</span>
            </c:when>
            <%-- 2026/08/06 장우철 — 숙박 운영 상태만 표시 (환불은 상세에서 확인) --%>
            <c:when test="${r.statusCd eq 'CHECKIN'}">
              <span class="badge-status badge-ready">체크인</span>
            </c:when>
            <c:when test="${r.statusCd eq 'CHECKOUT'}">
              <span class="badge-status badge-ready">체크아웃</span>
            </c:when>
            <c:when test="${r.statusCd eq 'DONE'}">
              <span class="badge-status badge-done">이용완료</span>
              <%-- 2026/07/13 장우철 — DONE + 미작성 시 리뷰 안내 --%>
              <c:if test="${r.reviewedYn ne 'Y'}">
                <span class="btn-sm" style="pointer-events:none;margin-top:6px;background:#2BAB82;color:#fff">리뷰 작성</span>
              </c:if>
              <c:if test="${r.reviewedYn eq 'Y'}">
                <span style="font-size:12px;color:#888;margin-top:6px">리뷰 완료</span>
              </c:if>
            </c:when>
            <c:otherwise>
              <span class="badge-status badge-cancel">취소</span>
            </c:otherwise>
          </c:choose>
          <span class="btn-sm" style="pointer-events:none">상세보기</span>
        </div>
      </a>
    </c:forEach>
</div>

</div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
