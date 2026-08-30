<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="contextPath"  value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="동물병원" />
<c:set var="bizPage"      value="records" />

<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_hospital.jsp" %>

<style>
    /* ── 진료기록 목록 전용 ── */
    .rec-search-bar {
        display: flex;
        gap: 10px;
        margin-bottom: 20px;
        align-items: center;
        flex-wrap: wrap;
    }
    .rec-search-input {
        flex: 1; min-width: 200px;
        border: 1px solid #E2E8E4;
        border-radius: 8px;
        padding: 9px 14px;
        font-size: 14px;
        color: #1A1A2E;
        outline: none;
        transition: border-color .2s;
    }
    .rec-search-input:focus { border-color: #2BAB82; }
    .rec-search-select {
        border: 1px solid #E2E8E4;
        border-radius: 8px;
        padding: 9px 14px;
        font-size: 14px;
        color: #555;
        background: #fff;
        outline: none;
        cursor: pointer;
    }
    .rec-search-btn {
        padding: 9px 20px;
        background: #2BAB82;
        color: #fff;
        border: none;
        border-radius: 8px;
        font-size: 14px;
        font-weight: 600;
        cursor: pointer;
        display: flex; align-items: center; gap: 6px;
        transition: background .2s;
    }
    .rec-search-btn:hover { background: #1F8464; }
    .rec-search-btn svg {
        width: 15px; height: 15px;
        stroke: #fff; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .rec-write-btn {
        padding: 9px 20px;
        background: #fff;
        color: #2BAB82;
        border: 1px solid #2BAB82;
        border-radius: 8px;
        font-size: 14px;
        font-weight: 600;
        cursor: pointer;
        display: flex; align-items: center; gap: 6px;
        text-decoration: none;
        transition: all .2s;
    }
    .rec-write-btn:hover { background: #2BAB82; color: #fff; }
    .rec-write-btn svg {
        width: 15px; height: 15px;
        stroke: currentColor; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }

    /* 진료 유형 뱃지 */
    .rec-type {
        display: inline-block;
        padding: 3px 10px;
        border-radius: 20px;
        font-size: 12px; font-weight: 600;
    }
    .rec-check   { background: #E0F2FE; color: #0284C7; }
    .rec-treat   { background: #DCFCE7; color: #16A34A; }
    .rec-vaccine { background: #F3E8FF; color: #9333EA; }
    .rec-surgery { background: #FEE2E2; color: #DC2626; }

    /* 진료기록 카드 */
    .rec-card {
        background: #fff;
        border: 1px solid #E2E8E4;
        border-radius: 12px;
        margin-bottom: 14px;
        overflow: hidden;
        transition: box-shadow .2s;
    }
    .rec-card:hover { box-shadow: 0 4px 16px rgba(0,0,0,.08); }
    .rec-card-head {
        display: flex;
        align-items: center;
        gap: 16px;
        padding: 14px 20px;
        border-bottom: 1px solid #E2E8E4;
        background: #FAFBFA;
    }
    .rec-pet-thumb {
        width: 44px; height: 44px;
        border-radius: 50%;
        object-fit: cover;
        flex-shrink: 0;
    }
    .rec-pet-info .pet-name { font-size: 15px; font-weight: 700; color: #1A1A2E; }
    .rec-pet-info .pet-meta { font-size: 12px; color: #999; margin-top: 2px; }
    .rec-head-right { margin-left: auto; display: flex; align-items: center; gap: 10px; }
    .rec-date { font-size: 13px; color: #999; }

    .rec-card-body {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 0;
        padding: 0;
    }
    .rec-field {
        padding: 14px 20px;
        border-right: 1px solid #E2E8E4;
    }
    .rec-field:last-child { border-right: none; }
    .rec-field label { font-size: 11px; color: #999; font-weight: 600; display: block; margin-bottom: 4px; }
    .rec-field span  { font-size: 14px; color: #1A1A2E; }

    .rec-card-foot {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 10px 20px;
        border-top: 1px solid #E2E8E4;
        font-size: 12px;
        color: #999;
    }
    .rec-foot-vet { display: flex; align-items: center; gap: 5px; }
    .rec-foot-vet svg {
        width: 13px; height: 13px;
        stroke: #999; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .rec-action-btns { display: flex; gap: 8px; }

    /* 페이지네이션 */
    .rec-pagination {
        display: flex;
        justify-content: center;
        gap: 6px;
        margin-top: 24px;
    }
    .rec-page-btn {
        width: 34px; height: 34px;
        border-radius: 8px;
        border: 1px solid #E2E8E4;
        background: #fff;
        font-size: 13px;
        color: #555;
        cursor: pointer;
        display: flex; align-items: center; justify-content: center;
        transition: all .15s;
    }
    .rec-page-btn:hover  { border-color: #2BAB82; color: #2BAB82; }
    .rec-page-btn.active { background: #2BAB82; border-color: #2BAB82; color: #fff; font-weight: 700; }
    .rec-page-btn svg {
        width: 14px; height: 14px;
        stroke: currentColor; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }

    /* ── 진료기록 작성/수정 모달 ── */
    .rm-modal-bg {
        display: none; position: fixed; inset: 0;
        background: rgba(0,0,0,.5); z-index: 1000;
        align-items: center; justify-content: center;
        padding: 20px;
    }
    .rm-modal-bg.open { display: flex; }
    .rm-modal {
        background: #fff; border-radius: 16px;
        width: 100%; max-width: 640px; max-height: 90vh;
        overflow-y: auto; box-shadow: 0 20px 60px rgba(0,0,0,.2);
        animation: rmSlideUp .25s ease;
    }
    @keyframes rmSlideUp { from { transform: translateY(30px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
    .rm-header {
        display: flex; justify-content: space-between; align-items: center;
        padding: 20px 24px 16px; border-bottom: 1px solid #E2E8E4;
        position: sticky; top: 0; background: #fff; z-index: 1;
    }
    .rm-header h3 { font-size: 18px; font-weight: 800; color: #1A1A2E; margin: 0; }
    .rm-close {
        width: 32px; height: 32px; border: none; background: #F0F4F8;
        border-radius: 50%; cursor: pointer; display: flex; align-items: center; justify-content: center;
        font-size: 18px; line-height: 1; color: #999; transition: all .2s;
    }
    .rm-close:hover { background: #E2E8E4; }
    .rm-body { padding: 22px 24px; }

    /* 환자 정보 (수정 시 표시) */
    .rm-patient-card {
        display: flex; align-items: center; gap: 14px;
        background: #FAFBFA; border: 1px solid #E2E8E4; border-radius: 10px;
        padding: 14px 16px; margin-bottom: 20px;
    }
    .rm-patient-thumb { width: 52px; height: 52px; border-radius: 50%; object-fit: cover; flex-shrink: 0; border: 2px solid #E2E8E4; }
    .rm-patient-name { font-size: 15px; font-weight: 700; color: #1A1A2E; }
    .rm-patient-meta { font-size: 12.5px; color: #999; margin-top: 3px; }
    .rm-patient-badge { margin-left: auto; font-size: 11px; font-weight: 700; padding: 4px 12px; border-radius: 20px; background: #EAF7F2; color: #1F8464; white-space: nowrap; }

    /* 환자 검색 (신규 작성 시 표시) */
    .rm-patient-search { display: flex; gap: 8px; margin-bottom: 20px; flex-direction: column; }
    .rm-patient-search input,
    .rm-patient-search select {
        flex: 1; border: 1px solid #E2E8E4; border-radius: 8px;
        padding: 10px 14px; font-size: 14px; outline: none; transition: border-color .2s;
        box-sizing: border-box; width: 100%; font-family: inherit; background: #fff;
    }
    .rm-patient-search input:focus,
    .rm-patient-search select:focus { border-color: #2BAB82; }

    .rm-section-label {
        font-size: 13px; font-weight: 700; color: #2BAB82;
        margin: 4px 0 12px; padding-top: 14px; border-top: 1px solid #F0F4F8;
    }
    .rm-section-label:first-of-type { padding-top: 0; border-top: none; }

    .rm-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 4px; }
    .rm-group { display: flex; flex-direction: column; gap: 5px; }
    .rm-group.full { grid-column: 1 / -1; }
    .rm-group label { font-size: 13px; font-weight: 600; color: #555; }
    .rm-group label .req { color: #FF6B6B; margin-left: 2px; }
    .rm-group input, .rm-group select, .rm-group textarea {
        border: 1px solid #E2E8E4; border-radius: 8px;
        padding: 9px 13px; font-size: 14px; color: #1A1A2E;
        outline: none; font-family: inherit; width: 100%; box-sizing: border-box;
        transition: border-color .2s;
    }
    .rm-group input:focus, .rm-group select:focus, .rm-group textarea:focus { border-color: #2BAB82; }
    .rm-group textarea { min-height: 64px; resize: vertical; line-height: 1.6; }
    .rm-input-unit { display: flex; align-items: center; gap: 8px; }
    .rm-input-unit input { flex: 1; }
    .rm-input-unit span { font-size: 13px; color: #555; white-space: nowrap; flex-shrink: 0; }
    .rm-hint { font-size: 11px; color: #aaa; margin-top: 2px; }

    .rm-type-group { display: flex; gap: 8px; flex-wrap: wrap; }
    .rm-type-item { display: none; }
    .rm-type-label {
        padding: 7px 16px; border: 1px solid #E2E8E4; border-radius: 50px;
        font-size: 13px; font-weight: 600; color: #555; cursor: pointer; transition: all .15s;
    }
    .rm-type-item:checked + .rm-type-label { background: #EAF7F2; border-color: #2BAB82; color: #1F8464; }

    .rm-footer {
        display: flex; gap: 10px; padding: 16px 24px;
        border-top: 1px solid #E2E8E4; position: sticky; bottom: 0; background: #fff;
    }
    .btn-rm-cancel { flex: 1; padding: 12px; border: 1px solid #E2E8E4; border-radius: 8px; background: #fff; color: #555; font-size: 14px; font-weight: 700; cursor: pointer; transition: all .15s; }
    .btn-rm-cancel:hover { border-color: #2BAB82; color: #2BAB82; }
    .btn-rm-save {
        flex: 2; padding: 12px; border: none; border-radius: 8px;
        background: #2BAB82; color: #fff; font-size: 14px; font-weight: 800; cursor: pointer;
        display: flex; align-items: center; justify-content: center; gap: 8px; transition: background .15s;
    }
    .btn-rm-save:hover { background: #1F8464; }
    .btn-rm-save svg { width: 16px; height: 16px; stroke: #fff; fill: none; stroke-width: 2.2; stroke-linecap: round; stroke-linejoin: round; }

    @media (max-width: 600px) {
        .rm-grid { grid-template-columns: 1fr; }
    }
</style>

<main class="biz-main">
    <div class="biz-page-head">
        <h1 class="biz-page-title">진료기록 관리</h1>
        <p class="biz-page-desc">내원 환자의 진료기록을 조회하고 관리하세요.</p>
    </div>

    <%-- 2026/07/13 장우철 — 검색·기간 필터 서버 조회 --%>
    <c:if test="${not empty msg}">
      <div style="margin-bottom:12px;padding:12px 16px;background:#E8F8F1;color:#1F8464;border-radius:8px;font-size:14px">${msg}</div>
    </c:if>
    <c:if test="${not empty errorMsg}">
      <div style="margin-bottom:12px;padding:12px 16px;background:#FEF2F2;color:#B91C1C;border-radius:8px;font-size:14px">${errorMsg}</div>
    </c:if>

    <form class="rec-search-bar" method="get" action="${contextPath}/biz/hospital/records">
        <input type="text" class="rec-search-input" name="keyword" value="${keyword}"
               placeholder="보호자명 또는 반려동물명으로 검색">
        <select class="rec-search-select" name="period">
            <option value="">기간 전체</option>
            <option value="1"  ${period == 1  ? 'selected' : ''}>최근 1개월</option>
            <option value="3"  ${period == 3  ? 'selected' : ''}>최근 3개월</option>
            <option value="6"  ${period == 6  ? 'selected' : ''}>최근 6개월</option>
            <option value="12" ${period == 12 ? 'selected' : ''}>최근 1년</option>
        </select>
        <button type="submit" class="rec-search-btn">
            <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
            조회
        </button>
        <%-- 2026/07/13 장우철 — 작성 버튼 복구 (확정·미기록 예약 선택 후 저장) --%>
        <button type="button" class="rec-write-btn" onclick="openRecordModal(null)">
            <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            진료기록 작성
        </button>
    </form>

    <c:if test="${empty recordList}">
      <p style="text-align:center; color:#aaa; padding:40px 0; font-size:14px;">
        등록된 진료기록이 없습니다. [진료기록 작성]으로 예약확정 건을 완료·저장할 수 있습니다.
      </p>
    </c:if>

    <c:forEach var="rec" items="${recordList}">
    <div class="rec-card">
        <div class="rec-card-head">
            <img class="rec-pet-thumb"
                 src="https://placehold.co/44x44/EAF7F2/2BAB82?text=PET"
                 alt="${rec.petName}">
            <div class="rec-pet-info">
                <div class="pet-name"><c:out value="${rec.petName}"/></div>
                <div class="pet-meta">
                  <c:out value="${rec.petBreed}"/>
                  <c:if test="${not empty rec.petSpecies}"> / <c:out value="${rec.petSpecies}"/></c:if>
                  <c:if test="${not empty rec.petAge}"> · <c:out value="${rec.petAge}"/>세</c:if>
                  · 보호자: <c:out value="${rec.memberName}"/>
                </div>
            </div>
            <div class="rec-head-right">
                <span class="rec-date"><fmt:formatDate value="${rec.visitDate}" pattern="yyyy.MM.dd"/></span>
                <%-- 2026-07-28 박유정 — MEMO 파싱된 진료 유형 표시 --%>
                <span class="rec-type rec-treat"><c:out value="${empty rec.treatType ? '진료기록' : rec.treatType}"/></span>
            </div>
        </div>
        <div class="rec-card-body">
            <div class="rec-field"><label>주증상</label><span><c:out value="${rec.symptoms}"/></span></div>
            <div class="rec-field"><label>진단명</label><span><c:out value="${rec.diagnosis}"/></span></div>
            <div class="rec-field"><label>처방</label><span><c:out value="${empty rec.prescription ? '-' : rec.prescription}"/></span></div>
            <div class="rec-field"><label>메모</label><span><c:out value="${empty rec.memo ? '-' : rec.memo}"/></span></div>
        </div>
        <div class="rec-card-foot">
            <span class="rec-foot-vet">
                <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                <c:out value="${empty rec.vetName ? '담당 수의사 미입력' : rec.vetName}"/>
            </span>
            <div class="rec-action-btns">
                <%-- 2026-07-28 박유정 — 상세보기: 파싱된 유형·신체계측 data-* 전달 --%>
                <button type="button" class="biz-btn"
                        data-name="<c:out value='${rec.petName}'/>"
                        data-meta="<c:out value='${rec.petBreed}'/> · 보호자: <c:out value='${rec.memberName}'/>"
                        data-date="<fmt:formatDate value='${rec.visitDate}' pattern='yyyy.MM.dd'/>"
                        data-type="<c:out value='${rec.treatType}'/>"
                        data-symptom="<c:out value='${rec.symptoms}'/>"
                        data-diagnosis="<c:out value='${rec.diagnosis}'/>"
                        data-exam="<c:out value='${rec.examItems}'/>"
                        data-prescription="<c:out value='${rec.prescription}'/>"
                        data-weight="<c:out value='${rec.weight}'/>"
                        data-temp="<c:out value='${rec.temperature}'/>"
                        data-heart-rate="<c:out value='${rec.heartRate}'/>"
                        data-breath="<c:out value='${rec.breathRate}'/>"
                        data-memo="<c:out value='${rec.memo}'/>"
                        data-next-visit="<c:out value='${rec.nextVisit}'/>"
                        data-vet="<c:out value='${rec.vetName}'/>"
                        onclick="openRecordFromBtn(this)">상세보기</button>
            </div>
        </div>
    </div>
    </c:forEach>

</main>

<%-- ── 진료기록 작성/상세 모달 (2026/07/13 장우철 — 저장 연동) ── --%>
<div class="rm-modal-bg" id="recordModalBg" onclick="if(event.target===this) closeRecordModal()">
  <div class="rm-modal">
    <div class="rm-header">
      <h3 id="rm-title">진료기록 작성</h3>
      <button type="button" class="rm-close" onclick="closeRecordModal()">×</button>
    </div>
    <form id="recordWriteForm" method="post" action="${contextPath}/biz/hospital/records/complete">
      <!--HYJ 26.08.05-->
      <input type="hidden" name="_csrf" value="${_csrf}">
      
      <input type="hidden" name="redirect" value="records">
      <input type="hidden" name="resvId" id="rm-resv-id" value="">
      <input type="hidden" name="treatType" id="rm-treat-type" value="진료">
      <div class="rm-body">

        <div class="rm-patient-card" id="rm-patient-card" style="display:none">
          <img class="rm-patient-thumb" id="rm-patient-thumb" src="" alt="환자">
          <div>
            <div class="rm-patient-name" id="rm-patient-name"></div>
            <div class="rm-patient-meta" id="rm-patient-meta"></div>
          </div>
          <span class="rm-patient-badge" id="rm-patient-badge"></span>
        </div>

        <%-- 신규: 확정·미기록 예약 선택 --%>
        <div class="rm-patient-search" id="rm-patient-search">
          <label style="font-size:13px;font-weight:600;color:#555">대상 예약 <span class="req" style="color:#FF6B6B">*</span></label>
          <select id="rm-resv-select" onchange="onWritableResvChange()">
            <option value="">예약확정 · 기록 미작성 건을 선택하세요</option>
            <c:forEach var="wr" items="${writableReserves}">
              <option value="${wr.resvId}"
                      data-member="<c:out value='${wr.memberName}'/>"
                      data-pet="<c:out value='${wr.petName}'/>"
                      data-breed="<c:out value='${wr.petBreed}'/>"
                      data-species="<c:out value='${wr.petSpecies}'/>"
                      data-date="<fmt:formatDate value='${wr.resvDate}' pattern='yyyy-MM-dd'/>"
                      data-time="<c:out value='${wr.resvTime}'/>"
                      data-symptoms="<c:out value='${wr.symptoms}'/>">
                <c:out value="${wr.petName}"/> / <c:out value="${wr.memberName}"/>
                · <fmt:formatDate value="${wr.resvDate}" pattern="MM/dd"/>
                <c:if test="${not empty wr.resvTime}"> ${wr.resvTime}</c:if>
                (<c:out value="${wr.resvNo}"/>)
              </option>
            </c:forEach>
          </select>
          <div id="rm-resv-hint" style="font-size:12px;color:#999;display:none"></div>
        </div>

        <div class="rm-section-label">진료 정보</div>
        <div class="rm-grid">
          <div class="rm-group full">
            <label>진료 유형 <span class="req">*</span></label>
            <div class="rm-type-group">
              <input type="radio" name="rmRecType" id="rm-type-check" class="rm-type-item" value="정기검진" onchange="syncTreatType()">
              <label for="rm-type-check" class="rm-type-label">정기검진</label>
              <input type="radio" name="rmRecType" id="rm-type-treat" class="rm-type-item" value="진료" checked onchange="syncTreatType()">
              <label for="rm-type-treat" class="rm-type-label">진료</label>
              <input type="radio" name="rmRecType" id="rm-type-vaccine" class="rm-type-item" value="예방접종" onchange="syncTreatType()">
              <label for="rm-type-vaccine" class="rm-type-label">예방접종</label>
              <input type="radio" name="rmRecType" id="rm-type-surgery" class="rm-type-item" value="수술" onchange="syncTreatType()">
              <label for="rm-type-surgery" class="rm-type-label">수술</label>
            </div>
          </div>
          <div class="rm-group full">
            <label>주증상 <span class="req">*</span></label>
            <input type="text" name="symptoms" id="rm-symptom" placeholder="예) 피부 트러블, 긁음 반복">
          </div>
          <div class="rm-group">
            <label>진단명 <span class="req">*</span></label>
            <input type="text" name="diagnosis" id="rm-diagnosis" placeholder="예) 알레르기성 피부염">
          </div>
          <div class="rm-group">
            <label>검사 항목</label>
            <input type="text" name="examItems" id="rm-exam" placeholder="예) 혈액검사, 심장사상충">
          </div>
          <div class="rm-group full">
            <label>처방 내용</label>
            <textarea name="prescription" id="rm-prescription" placeholder="처방한 약물명, 용량, 투약 기간 등을 입력하세요."></textarea>
          </div>
        </div>

        <div class="rm-section-label">신체 계측</div>
        <div class="rm-grid">
          <div class="rm-group">
            <label>체중</label>
            <div class="rm-input-unit"><input type="number" name="weight" id="rm-weight" placeholder="0.0" step="0.1"><span>kg</span></div>
          </div>
          <div class="rm-group">
            <label>체온</label>
            <div class="rm-input-unit"><input type="number" name="temperature" id="rm-temp" placeholder="0.0" step="0.1"><span>℃</span></div>
            <span class="rm-hint">정상 범위: 개 37.5~39.2℃ / 고양이 38.1~39.2℃</span>
          </div>
          <div class="rm-group">
            <label>심박수</label>
            <div class="rm-input-unit"><input type="number" name="heartRate" id="rm-heart" placeholder="0"><span>bpm</span></div>
          </div>
          <div class="rm-group">
            <label>호흡수</label>
            <div class="rm-input-unit"><input type="number" name="breathRate" id="rm-breath" placeholder="0"><span>회/분</span></div>
          </div>
        </div>

        <div class="rm-section-label">추가 정보</div>
        <div class="rm-grid">
          <div class="rm-group full">
            <label>수의사 메모</label>
            <textarea name="memo" id="rm-memo" placeholder="보호자에게 전달할 주의사항, 재방문 권장 이유, 관리 방법 등을 입력하세요."></textarea>
          </div>
          <div class="rm-group">
            <label>다음 방문 권장일</label>
            <input type="date" name="nextVisit" id="rm-next-visit">
            <span class="rm-hint">기록에 함께 저장됩니다.</span>
          </div>
          <div class="rm-group">
            <label>담당 수의사</label>
            <input type="text" name="vetName" id="rm-vet" placeholder="예) 김철수 수의사" list="rm-vet-list">
            <datalist id="rm-vet-list">
              <option value="김철수 수의사">
              <option value="이영희 수의사">
            </datalist>
          </div>
        </div>

      </div>
      <div class="rm-footer" id="rm-footer-write">
        <button type="button" class="btn-rm-cancel" onclick="closeRecordModal()">취소</button>
        <button type="button" class="btn-rm-save" onclick="saveRecord()">
          <svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>
          저장 · 진료완료
        </button>
      </div>
      <div class="rm-footer" id="rm-footer-view" style="display:none">
        <button type="button" class="btn-rm-cancel" style="flex:1" onclick="closeRecordModal()">닫기</button>
      </div>
    </form>
  </div>
</div>

<script>
    // 2026/07/13 장우철 — DB 카드 data-* 로 상세 모달 오픈
    // 2026-07-28 박유정 — 유형·신체계측·다음방문 필드 분리 전달 (MEMO 통째 표시 오류 수정)
    function openRecordFromBtn(btn) {
        openRecordModal({
            name: btn.dataset.name || '',
            meta: btn.dataset.meta || '',
            date: btn.dataset.date || '',
            type: btn.dataset.type || '진료',
            symptom: btn.dataset.symptom || '',
            diagnosis: btn.dataset.diagnosis || '',
            exam: btn.dataset.exam || '',
            prescription: btn.dataset.prescription || '',
            weight: btn.dataset.weight || '',
            temp: btn.dataset.temp || '',
            heartRate: btn.dataset.heartRate || '',
            breath: btn.dataset.breath || '',
            memo: btn.dataset.memo || '',
            nextVisit: btn.dataset.nextVisit || '',
            vet: btn.dataset.vet || ''
        });
    }

    function selRecType(v) {
        const map = {'정기검진':'rm-type-check','진료':'rm-type-treat','예방접종':'rm-type-vaccine','수술':'rm-type-surgery'};
        const id = map[v] || 'rm-type-treat';
        document.getElementById(id).checked = true;
        syncTreatType();
    }

    function syncTreatType() {
        var checked = document.querySelector('input[name="rmRecType"]:checked');
        document.getElementById('rm-treat-type').value = checked ? checked.value : '진료';
    }

    function resetRecordForm() {
        document.getElementById('recordWriteForm').reset();
        document.getElementById('rm-resv-id').value = '';
        document.getElementById('rm-treat-type').value = '진료';
        document.getElementById('rm-type-treat').checked = true;
        document.getElementById('rm-resv-hint').style.display = 'none';
        setRecordFieldsReadonly(false);
    }

    function setRecordFieldsReadonly(ro) {
        ['rm-symptom','rm-diagnosis','rm-exam','rm-prescription','rm-weight','rm-temp','rm-heart','rm-breath','rm-memo','rm-next-visit','rm-vet'].forEach(function(id) {
            var el = document.getElementById(id);
            if (el) el.readOnly = !!ro;
        });
        document.querySelectorAll('input[name="rmRecType"]').forEach(function(r) { r.disabled = !!ro; });
    }

    function onWritableResvChange() {
        var sel = document.getElementById('rm-resv-select');
        var opt = sel.options[sel.selectedIndex];
        document.getElementById('rm-resv-id').value = sel.value || '';
        var hint = document.getElementById('rm-resv-hint');
        if (!sel.value) {
            hint.style.display = 'none';
            return;
        }
        var meta = (opt.dataset.pet || '') + ' · 보호자 ' + (opt.dataset.member || '')
            + ' · ' + (opt.dataset.date || '') + ' ' + (opt.dataset.time || '');
        hint.textContent = meta;
        hint.style.display = 'block';
        if (opt.dataset.symptoms) {
            document.getElementById('rm-symptom').value = opt.dataset.symptoms;
        }
    }

    function openRecordModal(data) {
        const isEdit = !!data;
        document.getElementById('rm-title').textContent = isEdit ? '진료기록 상세보기' : '진료기록 작성';
        document.getElementById('rm-patient-card').style.display = isEdit ? 'flex' : 'none';
        document.getElementById('rm-patient-search').style.display = isEdit ? 'none' : 'flex';
        document.getElementById('rm-footer-write').style.display = isEdit ? 'none' : 'flex';
        document.getElementById('rm-footer-view').style.display = isEdit ? 'flex' : 'none';

        if (!isEdit) {
            resetRecordForm();
            <c:if test="${empty writableReserves}">
            alert('작성 가능한 예약확정 건이 없습니다. 예약관리에서 먼저 예약을 확정해 주세요.');
            return;
            </c:if>
        } else {
            document.getElementById('rm-patient-thumb').src = data.thumb || 'https://placehold.co/44x44/EAF7F2/2BAB82?text=PET';
            document.getElementById('rm-patient-name').textContent = data.name || '';
            document.getElementById('rm-patient-meta').textContent = data.meta || '';
            document.getElementById('rm-patient-badge').textContent = (data.date || '') + ' 작성';
            document.getElementById('rm-symptom').value = data.symptom || '';
            document.getElementById('rm-diagnosis').value = data.diagnosis || '';
            document.getElementById('rm-exam').value = data.exam || '';
            document.getElementById('rm-prescription').value = data.prescription || '';
            document.getElementById('rm-weight').value = data.weight || '';
            document.getElementById('rm-temp').value = data.temp || '';
            document.getElementById('rm-heart').value = data.heartRate || '';
            document.getElementById('rm-breath').value = data.breath || '';
            document.getElementById('rm-memo').value = data.memo || '';
            document.getElementById('rm-next-visit').value = data.nextVisit || '';
            document.getElementById('rm-vet').value = data.vet || '';
            selRecType(data.type || '진료');
            setRecordFieldsReadonly(true);
        }

        document.getElementById('recordModalBg').classList.add('open');
        document.body.style.overflow = 'hidden';
    }

    function closeRecordModal() {
        document.getElementById('recordModalBg').classList.remove('open');
        document.body.style.overflow = '';
        setRecordFieldsReadonly(false);
    }

    // 2026/07/13 장우철 — 작성 모달 → complete API (진료완료 + TB_MEDICAL_RECORD)
    function saveRecord() {
        var resvId = document.getElementById('rm-resv-id').value;
        if (!resvId) { alert('대상 예약을 선택해 주세요.'); return; }
        var symptoms = document.getElementById('rm-symptom').value.trim();
        var diagnosis = document.getElementById('rm-diagnosis').value.trim();
        if (!symptoms) { alert('주증상을 입력해 주세요.'); return; }
        if (!diagnosis) { alert('진단명을 입력해 주세요.'); return; }
        syncTreatType();
        if (!confirm('진료완료로 처리하고 기록을 저장할까요?')) return;
        document.getElementById('recordWriteForm').submit();
    }
</script>

<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>
