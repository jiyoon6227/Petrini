<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId"      value="give" />

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
  .ad-wrap{max-width:900px;margin:32px auto 80px;padding:0 20px;display:grid;grid-template-columns:1fr 300px;gap:28px;align-items:flex-start}
  .ad-back{display:inline-flex;align-items:center;gap:6px;font-size:13px;color:var(--text-muted);text-decoration:none;margin-bottom:20px;transition:var(--transition)}
  .ad-back:hover{color:var(--primary)}
  .ad-back svg{width:14px;height:14px;stroke:currentColor;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}
  .ad-main-img{width:100%;aspect-ratio:4/3;object-fit:cover;border-radius:var(--radius-md);display:block;margin-bottom:20px;background:#f5f5f5}
  .ad-dday{display:inline-block;font-size:13px;font-weight:700;padding:4px 12px;border-radius:20px;margin-bottom:10px}
  .add-urgent{background:#FEE2E2;color:#DC2626}
  .add-normal{background:#DCFCE7;color:#16A34A}
  .add-end{background:#E5E7EB;color:#6B7280}
  .ad-name{font-size:22px;font-weight:800;color:var(--text-main);margin-bottom:6px;line-height:1.3}
  .ad-notice{font-size:13px;color:var(--text-muted);margin-bottom:18px}
  .ad-info-grid{display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:20px}
  .ad-info-row{background:var(--bg-page);border-radius:var(--radius-sm);padding:12px 14px}
  .ad-info-row label{font-size:11px;color:var(--text-muted);font-weight:600;display:block;margin-bottom:4px}
  .ad-info-row span{font-size:14px;font-weight:600;color:var(--text-main)}
  .ad-section{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);padding:18px;margin-bottom:16px}
  .ad-section h3{font-size:14px;font-weight:800;color:var(--text-main);margin:0 0 12px}
  .ad-section p{font-size:14px;color:var(--text-sub);line-height:1.8;margin:0}
  /* 사이드 */
  .side-card{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);padding:20px;position:sticky;top:20px;margin-bottom:14px}
  .side-card h3{font-size:15px;font-weight:800;color:var(--text-main);margin:0 0 14px;padding-bottom:11px;border-bottom:1px solid var(--border)}
  .side-row{display:flex;justify-content:space-between;font-size:14px;color:var(--text-sub);margin-bottom:10px}
  .side-row span:last-child{font-weight:600;color:var(--text-main)}
  .btn-shelter{width:100%;padding:12px;border:none;border-radius:var(--radius-sm);background:var(--primary);color:#fff;font-size:15px;font-weight:800;cursor:pointer;margin-top:12px;transition:var(--transition)}
  .btn-shelter:hover{background:var(--primary-dark)}
  .btn-shelter-link{width:100%;padding:11px;border:2px solid var(--primary);border-radius:var(--radius-sm);background:#fff;color:var(--primary);font-size:13px;font-weight:700;cursor:pointer;margin-top:8px}
</style>

<c:choose>
  <c:when test="${apiError or empty animal}">
    <div style="max-width:600px;margin:80px auto;text-align:center;padding:0 20px">
      <p style="font-size:16px;color:#DC2626;font-weight:700">데이터를 불러오는 중 오류가 발생했습니다.</p>
      <a href="${contextPath}/give/animal/list"
         style="display:inline-block;margin-top:14px;padding:10px 24px;background:var(--primary);color:#fff;border-radius:var(--radius-sm);text-decoration:none;font-weight:700">목록으로 돌아가기</a>
    </div>
  </c:when>
  <c:otherwise>
    <div class="ad-wrap">
      <div>
        <a href="${contextPath}/give/animal/list" class="ad-back">
          <svg viewBox="0 0 24 24"><path d="M19 12H5"/><polyline points="12 19 5 12 12 5"/></svg>
          유기동물 목록으로
        </a>

        <%-- 대표 이미지 --%>
        <img class="ad-main-img"
             src="${empty animal.popfile1 ? animal.popfile2 : animal.popfile1}"
             alt="${animal.breedName}"
             onerror="this.src='https://placehold.co/600x450/EAF7F2/2BAB82?text=${animal.species}'">

        <%-- D-day 뱃지 --%>
        <c:choose>
          <c:when test="${animal.dday >= 0 and animal.dday <= 3}">
            <span class="ad-dday add-urgent">D-${animal.dday} 종료임박</span>
          </c:when>
          <c:when test="${animal.dday > 3}">
            <span class="ad-dday add-normal">D-${animal.dday}</span>
          </c:when>
          <c:otherwise>
            <span class="ad-dday add-end">공고 종료</span>
          </c:otherwise>
        </c:choose>

        <div class="ad-name">${animal.breedName} · ${animal.sexLabel}</div>
        <div class="ad-notice">
          공고번호: ${animal.noticeNo} &nbsp;|&nbsp;
          공고기간: ${animal.noticeSdt} ~ ${animal.noticeEdtFormatted} &nbsp;|&nbsp;
          상태: <strong>${animal.processState}</strong>
        </div>

        <div class="ad-info-grid">
          <div class="ad-info-row"><label>품종</label><span>${animal.breedName}</span></div>
          <div class="ad-info-row"><label>성별</label><span>${animal.sexLabel}</span></div>
          <div class="ad-info-row"><label>나이</label><span>${animal.age}</span></div>
          <div class="ad-info-row"><label>체중</label><span>${animal.weight}</span></div>
          <div class="ad-info-row"><label>색상</label><span>${animal.colorCd}</span></div>
          <div class="ad-info-row"><label>중성화</label><span>${animal.neuterLabel}</span></div>
          <div class="ad-info-row"><label>발견 장소</label><span>${animal.happenPlace}</span></div>
          <div class="ad-info-row"><label>발견 일시</label><span>${animal.happenDt}</span></div>
        </div>

        <c:if test="${not empty animal.specialMark}">
          <div class="ad-section">
            <h3>특징</h3>
            <p>${animal.specialMark}</p>
          </div>
        </c:if>

        <div class="ad-section">
          <h3>보호소 정보</h3>
          <p>
            ${animal.careNm}<br>
            <c:if test="${not empty animal.careTel}">전화: ${animal.careTel}<br></c:if>
            <c:if test="${not empty animal.careAddr}">${animal.careAddr}</c:if>
          </p>
        </div>
      </div>

      <%-- 사이드 카드 --%>
      <div>
        <div class="side-card">
          <h3>공고 정보</h3>
          <div class="side-row"><span>상태</span><span style="color:var(--primary);font-weight:800">${animal.processState}</span></div>
          <div class="side-row"><span>공고 종료일</span><span>${animal.noticeEdtFormatted}</span></div>
          <div class="side-row"><span>관할 기관</span><span>${animal.orgNm}</span></div>
          <c:if test="${not empty animal.chargeNm}">
            <div class="side-row"><span>담당자</span><span>${animal.chargeNm}</span></div>
          </c:if>
          <c:if test="${not empty animal.officetel}">
            <div class="side-row"><span>담당자 연락처</span><span>${animal.officetel}</span></div>
          </c:if>
        </div>

        <div class="side-card">
          <h3>보호소 문의</h3>
          <div class="side-row"><span>보호소명</span><span>${animal.careNm}</span></div>
          <c:if test="${not empty animal.careTel}">
            <div class="side-row"><span>전화번호</span>
              <span style="color:var(--primary);font-weight:800">${animal.careTel}</span>
            </div>
          </c:if>
          <p style="font-size:12px;color:var(--text-muted);margin:10px 0 0;line-height:1.6">
            입양 신청은 보호소에 직접 연락해 주세요.<br>
            PetCare는 정보 제공만 하며 입양 절차에 개입하지 않습니다.
          </p>
          <c:if test="${not empty animal.careTel}">
            <button class="btn-shelter"
                    onclick="location.href='tel:${animal.careTel}'">
              보호소에 전화하기
            </button>
          </c:if>
          <a href="https://www.animal.go.kr" target="_blank">
            <button class="btn-shelter-link">동물보호관리시스템에서 보기</button>
          </a>
        </div>
      </div>
    </div>
  </c:otherwise>
</c:choose>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
