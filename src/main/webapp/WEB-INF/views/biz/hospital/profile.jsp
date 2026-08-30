<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="동물병원" />
<%-- 2026/07/15 장우철 — 병원정보 페이지 active는 profile (info=사업자정보) --%>
<c:set var="bizPage" value="profile" />

<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_hospital.jsp" %>

<style>
	/* 전체 래퍼 — 섹션 사이 간격 20px */
	.info-wrap{display:flex;flex-direction:column;gap:20px}
	
	/* ── 상단 히어로 배너 ── */
	.info-hero{background:linear-gradient(135deg,#1F8464 0%,#2BAB82 100%);border-radius:12px;padding:28px 32px;color:#fff;display:flex;align-items:center;gap:20px}
	.info-hero-icon{width:60px;height:60px;border-radius:14px;background:rgba(255,255,255,.2);display:flex;align-items:center;justify-content:center;flex-shrink:0}
	.info-hero-icon svg{width:30px;height:30px;stroke:#fff;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round}
	.info-hero h2{font-size:20px;font-weight:800;margin:0 0 6px}
	.info-hero p{font-size:13px;opacity:.85;margin:0;line-height:1.6}
	
	/* ── 흰색 섹션 카드 ── */
	.info-section{background:#fff;border:1px solid #E4E6ED;border-radius:12px;padding:24px}
	
	/* 섹션 제목 — 하단 구분선 포함 */
	.info-stitle{font-size:14px;font-weight:800;color:#1A1A2E;margin:0 0 18px;padding-bottom:12px;border-bottom:1px solid #E4E6ED;display:flex;align-items:center;gap:8px}
	.info-stitle svg{width:16px;height:16px;stroke:#2BAB82;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;flex-shrink:0}
	
	/* ── 폼 그리드 (2열) ── */
	.info-grid{display:grid;grid-template-columns:1fr 1fr;gap:14px}
	.info-group{display:flex;flex-direction:column;gap:6px}
	.info-group.full{grid-column:1/-1}                     /* 한 줄 전체 차지 */
	.info-group label{font-size:13px;font-weight:600;color:#555}
	.info-group label .req{color:#FF6B6B;margin-left:2px}  /* 필수 표시 빨간색 */
	
	/* 입력 필드 공통 */
	.info-group input,.info-group select,.info-group textarea{
		border:1px solid #E4E6ED;border-radius:8px;padding:10px 14px;font-size:14px;color:#1A1A2E;
		outline:none;font-family:inherit;width:100%;box-sizing:border-box;transition:border-color .2s}
	.info-group input:focus,.info-group select:focus,.info-group textarea:focus{border-color:#2BAB82}
	.info-group textarea{resize:vertical;min-height:100px;line-height:1.6}

	/* 주소 검색 행 */
	.info-input-row{display:flex;gap:8px}
	.info-input-row input{flex:1}
	.btn-addr{padding:10px 16px;border:none;border-radius:8px;background:#2BAB82;color:#fff;font-size:13px;font-weight:700;cursor:pointer;white-space:nowrap;transition:background .15s}
	.btn-addr:hover{background:#1F8464}
	
	/* ═══════════════════════════════════
	운영시간 테이블
	═══════════════════════════════════ */
	.hours-table{width:100%;border-collapse:collapse}
	.hours-table th{font-size:12px;font-weight:700;color:#999;text-align:left;padding:8px;border-bottom:1px solid #E4E6ED}
	.hours-table td{padding:8px;border-bottom:1px solid #E4E6ED;vertical-align:middle}
	.hours-table tr:last-child td{border-bottom:none}
	.hours-day{font-size:14px;font-weight:700;color:#1A1A2E;min-width:50px}
	
	/* 시간 입력 한 쌍 (시작 ~ 종료) */
	.hours-time{display:flex;align-items:center;gap:6px}
	.hours-time input[type="time"]{
		border:1px solid #E4E6ED;border-radius:8px;padding:7px 10px;font-size:13px;color:#1A1A2E;
		font-family:inherit;outline:none;transition:border-color .2s}
	.hours-time input[type="time"]:focus{border-color:#2BAB82}
	.hours-time span{font-size:13px;color:#999}
	
	/* "전체 적용" 안내 바 */
	.hours-copy-bar{display:flex;align-items:center;gap:10px;margin-bottom:14px;padding:10px 14px;background:#F0FAF6;border:1px solid #B6E8D4;border-radius:8px;font-size:13px;color:#1F8464}
	.hours-copy-bar svg{width:14px;height:14px;stroke:#2BAB82;fill:none;stroke-width:2;flex-shrink:0}
	.btn-copy-all{padding:5px 14px;border:1px solid #2BAB82;border-radius:6px;background:#fff;color:#1F8464;font-size:12px;font-weight:700;cursor:pointer;transition:all .15s}
	.btn-copy-all:hover{background:#2BAB82;color:#fff}
	
	/* 토글 스위치 (영업 ON/OFF) */
	.tog{position:relative;display:inline-block;width:38px;height:22px;flex-shrink:0}
	.tog input{opacity:0;width:0;height:0}
	.tog-sl{position:absolute;cursor:pointer;inset:0;background:#ccc;border-radius:22px;transition:.2s}
	.tog-sl:before{content:"";position:absolute;width:16px;height:16px;left:3px;bottom:3px;background:#fff;border-radius:50%;transition:.2s}
	.tog input:checked+.tog-sl{background:#2BAB82}
	.tog input:checked+.tog-sl:before{transform:translateX(16px)}
	
	/* 토글 OFF → 해당 행 흐리게 + 입력 비활성화 */
	.row-off .hours-day{opacity:.35}
	.row-off .hours-time input{opacity:.35;pointer-events:none}
	
	/* ═══════════════════════════════════
	병원 특성 태그
	═══════════════════════════════════ */
	.tag-checks{display:flex;gap:8px;flex-wrap:wrap}
	.tag-check{display:flex;align-items:center;gap:6px;padding:8px 16px;border:1.5px solid #E4E6ED;border-radius:8px;font-size:13px;font-weight:600;color:#555;cursor:pointer;transition:all .2s}
	.tag-check:has(input:checked){background:#F0FAF6;border-color:#2BAB82;color:#1F8464}
	.tag-check input{display:none}
	.tag-check svg{width:16px;height:16px;stroke:currentColor;fill:none;stroke-width:2;flex-shrink:0}
	
	/* ═══════════════════════════════════
	이미지 업로드
	═══════════════════════════════════ */
	.img-upload-area{display:grid;grid-template-columns:repeat(4,1fr);gap:12px}
	.img-upload-box{aspect-ratio:1;border:2px dashed #E4E6ED;border-radius:10px;display:flex;flex-direction:column;align-items:center;justify-content:center;cursor:pointer;transition:all .15s;position:relative;overflow:hidden;color:#999}
	.img-upload-box:hover{border-color:#2BAB82;color:#1F8464;background:#F0FAF6}
	.img-upload-box svg{width:24px;height:24px;stroke:currentColor;fill:none;stroke-width:1.5;margin-bottom:4px}
	.img-upload-box small{font-size:11px;color:inherit}
	.img-upload-box.main{border-color:#2BAB82;background:#F0FAF6;color:#1F8464}
	.img-upload-box.main::after{content:'대표';position:absolute;top:8px;left:8px;background:#2BAB82;color:#fff;font-size:10px;font-weight:700;padding:2px 8px;border-radius:20px}
	.img-preview{width:100%;height:100%;object-fit:cover;border-radius:8px}
	.img-upload-box input[type="file"]{display:none}
	
	/* 이미지 삭제 버튼 (우측 상단 동그란 ✕) */
	.btn-img-del{position:absolute;top:6px;right:6px;width:24px;height:24px;border:none;border-radius:50%;background:rgba(0,0,0,.55);color:#fff;font-size:14px;font-weight:700;cursor:pointer;display:flex;align-items:center;justify-content:center;z-index:1}
	.btn-img-del:hover{background:rgba(220,38,38,.85)}
	
	/* 삭제 마킹된 기존 이미지 — 흐리게 + 클릭 불가 */
	.img-upload-box.deleted{opacity:.3;pointer-events:none}
	
	/* ═══════════════════════════════════
	하단 버튼
	═══════════════════════════════════ */
	.info-btn-row{display:flex;justify-content:flex-end;gap:10px;margin-top:4px}
	.btn-info-cancel{padding:11px 24px;border:1px solid #E4E6ED;border-radius:8px;background:#fff;color:#555;font-size:14px;font-weight:600;cursor:pointer}
	.btn-info-submit{padding:11px 28px;border:none;border-radius:8px;background:#2BAB82;color:#fff;font-size:14px;font-weight:700;cursor:pointer;transition:background .15s}
	.btn-info-submit:hover{background:#1F8464}
	
	/* ═══════════════════════════════════
	반응형 — 960px 이하에서 운영시간 카드 전환
	═══════════════════════════════════ */
	@media (max-width:960px) {
		.info-hero{padding:22px 20px;gap:16px}
		.info-hero-icon{width:50px;height:50px;border-radius:12px}
		.info-hero-icon svg{width:24px;height:24px}
		.info-hero h2{font-size:18px}
		.img-upload-area{grid-template-columns:repeat(3,1fr)}
	
		.hours-table thead{display:none}
		.hours-table,.hours-table tbody,.hours-table tr,.hours-table td{display:block;width:100%}
		.hours-table tr{background:#FAFAFA;border:1px solid #E4E6ED;border-radius:10px;padding:14px 16px;margin-bottom:10px}
		.hours-table td{border-bottom:none;padding:0}
		.hours-table td:nth-child(1),.hours-table td:nth-child(2){display:inline-block;width:auto}
		.hours-table td:nth-child(1){margin-right:10px}
		.hours-table td:nth-child(2){vertical-align:middle}
		.hours-table td:nth-child(3)::before,.hours-table td:nth-child(4)::before{display:block;font-size:11px;font-weight:700;color:#999;margin:10px 0 4px}
		.hours-table td:nth-child(3)::before{content:'진료시간'}
		.hours-table td:nth-child(4)::before{content:'점심시간'}
		.hours-time{flex-wrap:nowrap}
		.hours-time input[type="time"]{flex:1;min-width:0;max-width:none;width:0}
		.hours-copy-bar{flex-wrap:wrap;font-size:12px;gap:8px}
		.row-off{opacity:.4}
		.row-off .hours-day{opacity:1}
		.row-off .hours-time input{opacity:1}
	}
	@media (max-width:640px) {
		.info-hero{flex-direction:column;text-align:center;padding:20px 16px;gap:12px}
		.info-hero-icon{width:48px;height:48px}
		.info-section{padding:18px 16px}
		.info-grid{grid-template-columns:1fr;gap:12px}
		.hours-copy-bar svg{display:none}
		.img-upload-area{grid-template-columns:repeat(2,1fr)}
		.info-btn-row{flex-direction:column}
		.btn-info-cancel,.btn-info-submit{width:100%;text-align:center}
	}
</style>

<!-- ===================================
     HTML 본문 시작
     =================================== -->
<main class="biz-main">
  <div class="biz-page-head">
    <h1 class="biz-page-title">업체 정보 등록/수정</h1>
    <p class="biz-page-desc">고객에게 노출되는 병원 정보를 관리합니다.</p>
  </div>

  <div class="info-wrap">
    <!-- 히어로 배너 -->
    <div class="info-hero">
      <div class="info-hero-icon">
        <svg viewBox="0 0 24 24">
					<path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z"/>
					<line x1="9" y1="22" x2="9" y2="12"/>
					<line x1="15" y1="22" x2="15" y2="12"/>
				</svg>
      </div>
      <div>
        <h2>병원 정보 관리</h2>
        <p>등록된 정보는 고객 검색 결과와 상세 페이지에 바로 반영됩니다.<br>정확한 정보 입력이 예약률 향상에 도움이 됩니다.</p>
      </div>
    </div>

    <!-- ===================================
      폼 시작
      - method="post" : 저장 요청
      - enctype="multipart/form-data" : 파일 업로드 필수
      =================================== -->
    <form name="hospitalInfoForm" method="post" action="${contextPath}/biz/hospital/profile" enctype="multipart/form-data">
		<!--HYJ 26.08.05-->
		<input type="hidden" name="_csrf" value="${_csrf}">
		
      <!--
          hoursJson 히든 필드
          - 페이지 로딩 시 : DB에서 가져온 JSON 문자열이 들어있음
          - 저장하기 클릭 시 : JS가 요일별 input에서 JSON을 조립해서 여기에 넣음
          - Controller에서 : vo.setHoursJson()으로 자동 바인딩
      -->
      <input type="hidden" name="hoursJson" id="hoursJsonInput" value='${hospital.hoursJson}'>

      <!-- 2026-07-10 장우철 — 기본 정보(이름/전화/주소)
           이유: 유저 목록은 LAT 있을 때만 '상세보기' 노출. 주소 저장 시 지오코딩으로 LAT 세팅 -->
      <%-- <div class="info-section">
        <div class="info-stitle">
          <svg viewBox="0 0 24 24">
            <path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z"/>
          </svg>
          기본 정보
        </div>
        <div class="info-grid">
          <div class="info-group">
            <label>병원명 <span class="req">*</span></label>
            <input type="text" name="name" value="${hospital.name}" required>
          </div>
          <div class="info-group">
            <label>전화번호 <span class="req">*</span></label>
            <input type="tel" name="phone" value="${hospital.phone}" required>
          </div>
          <div class="info-group full">
            <label>주소 <span class="req">*</span></label>
            <div class="info-input-row">
              <input type="text" name="addr" id="addrInput" value="${hospital.addr}" readonly required placeholder="주소 검색 버튼을 눌러 주세요">
              <button type="button" class="btn-addr" onclick="searchAddr()">주소 검색</button>
            </div>
            <input type="text" name="addrDetail" value="${hospital.addrDetail}" style="margin-top:8px" placeholder="상세 주소 (동/호수 등)">
          </div>
        </div>
      </div> --%>

      <div class="info-section">
        <div class="info-grid">
          <div class="info-group full">
            <label>병원 소개</label>
            <textarea name="description" placeholder="병원을 소개하는 문구를 입력하세요.">${hospital.description}</textarea>
          </div>
        </div>
      </div>
      <!-- ─────────── 1. 운영 시간 ───────────
            - 요일별로 토글(ON/OFF) + 시간 입력
            - 토글 OFF = 휴무
            - 저장 시 JS가 JSON으로 변환 → hoursJson 히든필드에 넣음
          ─────────────────────────────────── -->
      <div class="info-section">
          <div class="info-stitle">
            <svg viewBox="0 0 24 24">
              <circle cx="12" cy="12" r="10"/>
              <polyline points="12 6 12 12 16 14"/>
            </svg>
            운영 시간
          </div>

          <!-- 전체 적용 버튼 -->
          <div class="hours-copy-bar">
            <svg viewBox="0 0 24 24">
              <rect x="9" y="9" width="13" height="13" rx="2"/>
              <path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1"/>
            </svg>
            월요일 시간을 전체 요일에 일괄 적용
            <button type="button" class="btn-copy-all" onclick="copyMonToAll()">전체 적용</button>
          </div>

          <table class="hours-table">
            <thead>
              <tr>
                <th>요일</th>
                <th>영업</th>
                <th>진료시간</th>
                <th>점심시간</th>
              </tr>
            </thead>
            <tbody>
              <tr id="row-월">
                <td class="hours-day">월</td>
                <td>
                  <label class="tog">
                    <input type="checkbox" id="use-월" checked onchange="toggleDay('월',this)">
                    <span class="tog-sl"></span>
                  </label>
                </td>
                <td>
                  <div class="hours-time">
                    <input type="time" id="open-월" value="09:00">
                    <span>~</span>
                    <input type="time" id="close-월" value="18:00">
                  </div>
                </td>
                <td>
                  <div class="hours-time">
                    <input type="time" id="lunchS-월" value="12:00">
                    <span>~</span>
                    <input type="time" id="lunchE-월" value="13:00">
                  </div>
                </td>
              </tr>
              <tr id="row-화">
                <td class="hours-day">화</td>
                <td>
                  <label class="tog">
									  <input type="checkbox" id="use-화" checked onchange="toggleDay('화',this)">
									  <span class="tog-sl"></span>
								  </label>
							  </td>
                <td>
								  <div class="hours-time">
									  <input type="time" id="open-화" value="09:00">
									  <span>~</span>
									  <input type="time" id="close-화" value="18:00">
								  </div>
							  </td>
                <td>
								  <div class="hours-time">
									  <input type="time" id="lunchS-화" value="12:00">
									  <span>~</span>
									  <input type="time" id="lunchE-화" value="13:00">
								  </div>
							  </td>
              </tr>
              <tr id="row-수">
                <td class="hours-day">수</td>
                <td>
                  <label class="tog">
                    <input type="checkbox" id="use-수" checked onchange="toggleDay('수',this)">
                    <span class="tog-sl"></span>
                  </label>
                </td>
                <td>
                  <div class="hours-time">
									  <input type="time" id="open-수" value="09:00">
									  <span>~</span>
									  <input type="time" id="close-수" value="18:00">
								  </div>
							  </td>
                <td>
								  <div class="hours-time">
								  	<input type="time" id="lunchS-수" value="12:00">
								  	<span>~</span>
								  	<input type="time" id="lunchE-수" value="13:00">
								  </div>
							  </td>
              </tr>
              <tr id="row-목">
                <td class="hours-day">목</td>
                <td>
								  <label class="tog">
								  	<input type="checkbox" id="use-목" checked onchange="toggleDay('목',this)">
								  	<span class="tog-sl"></span>
								  </label>
							  </td>
                <td>
								  <div class="hours-time">
								  	<input type="time" id="open-목" value="09:00">
								  	<span>~</span>
								  	<input type="time" id="close-목" value="18:00">
								  </div>
							  </td>
                <td>
								  <div class="hours-time">
								  	<input type="time" id="lunchS-목" value="12:00">
								  	<span>~</span>
								  	<input type="time" id="lunchE-목" value="13:00">
								  </div>
							  </td>
              </tr>
              <tr id="row-금">
                <td class="hours-day">금</td>
                <td>
								  <label class="tog">
								  	<input type="checkbox" id="use-금" checked onchange="toggleDay('금',this)">
								  	<span class="tog-sl"></span>
								  </label>
							  </td>
                <td>
							  	<div class="hours-time">
							  		<input type="time" id="open-금" value="09:00">
							  		<span>~</span>
							  		<input type="time" id="close-금" value="18:00">
							  	</div>
							  </td>
                <td>
							  	<div class="hours-time">
							  		<input type="time" id="lunchS-금" value="12:00">
							  		<span>~</span>
							  		<input type="time" id="lunchE-금" value="13:00">
							  	</div>
							  </td>
              </tr>
              <tr id="row-토">
                <td class="hours-day">토</td>
                <td>
								  <label class="tog">
								  	<input type="checkbox" id="use-토" checked onchange="toggleDay('토',this)">
								  	<span class="tog-sl"></span>
								  </label>
							  </td>
                <td>
								  <div class="hours-time">
								  	<input type="time" id="open-토" value="09:00">
								  	<span>~</span>
								  	<input type="time" id="close-토" value="14:00">
								  </div>
							  </td>
                <td>
								  <div class="hours-time">
								  	<input type="time" id="lunchS-토" value="">
								  	<span>~</span>
								  	<input type="time" id="lunchE-토" value="">
								  </div>
							  </td>
              </tr>
              <tr id="row-일" class="row-off">
                <td class="hours-day">일</td>
                <td>
								  <label class="tog">
								  	<input type="checkbox" id="use-일" onchange="toggleDay('일',this)">
								  	<span class="tog-sl"></span>
								  </label>
							  </td>
                <td>
								  <div class="hours-time">
								  	<input type="time" id="open-일" value="">
								  	<span>~</span>
								  	<input type="time" id="close-일" value="">
								  </div>
							  </td>
                <td>
								  <div class="hours-time">
								  	<input type="time" id="lunchS-일" value="">
								  	<span>~</span>
								  	<input type="time" id="lunchE-일" value="">
								  </div>
							  </td>
              </tr>
              <tr id="row-공휴일" class="row-off">
                <td class="hours-day">공휴일</td>
                <td>
								  <label class="tog">
								  	<input type="checkbox" id="use-공휴일" onchange="toggleDay('공휴일',this)">
								  	<span class="tog-sl"></span>
								  </label>
							  </td>
                <td>
								  <div class="hours-time">
								  	<input type="time" id="open-공휴일" value="">
								  	<span>~</span>
								  	<input type="time" id="close-공휴일" value="">
								  </div>
							  </td>
                <td>
								  <div class="hours-time">
								  	<input type="time" id="lunchS-공휴일" value="">
								  	<span>~</span>
								  	<input type="time" id="lunchE-공휴일" value="">
								  </div>
							  </td>
              </tr>
            </tbody>
          </table>
      </div>


      <!-- ─────────── 3. 병원 특성 ───────────
            - name="tags"인 체크박스 → Controller에서 String[]로 받음
            - Controller가 String.join(",", tagsArr) → vo.setTagList()
            - fn:contains로 DB 값과 비교 → checked 복원
            ─────────────────────────────────── -->
      <div class="info-section">
          <div class="info-stitle">
            <svg viewBox="0 0 24 24">
						  <polyline points="20 6 9 17 4 12"/>
					  </svg>
            병원 특성
          </div>
          <p style="font-size:13px;color:#999;margin:0 0 14px">해당하는 항목을 모두 선택하세요.</p>
          <div class="tag-checks">
            <label class="tag-check">
              <input type="checkbox" name="tagList" value="24H" ${fn:contains(hospital.tagList, '24H') ? 'checked' : ''}>
              <svg viewBox="0 0 24 24">
							  <circle cx="12" cy="12" r="10"/>
							  <polyline points="12 6 12 12 16 14"/>
						  </svg>
              24시간 진료
            </label>
            <label class="tag-check">
              <input type="checkbox" name="tagList" value="HOSPITEL" ${fn:contains(hospital.tagList, 'HOSPITEL') ? 'checked' : ''}>
                <svg viewBox="0 0 24 24">
							    <path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z"/>
						    </svg>
                호스피텔 가능
            </label>
            <label class="tag-check">
              <input type="checkbox" name="tagList" value="INPATIENT" ${fn:contains(hospital.tagList, 'INPATIENT') ? 'checked' : ''}>
              <svg viewBox="0 0 24 24">
							  <rect x="3" y="3" width="18" height="18" rx="2"/>
							  <line x1="12" y1="8" x2="12" y2="16"/>
							  <line x1="8" y1="12" x2="16" y2="12"/>
						  </svg>
              입원 진료
            </label>
            <label class="tag-check">
              <input type="checkbox" name="tagList" value="EMERGENCY" ${fn:contains(hospital.tagList, 'EMERGENCY') ? 'checked' : ''}>
              <svg viewBox="0 0 24 24">
							  <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/>
						  </svg>
              응급 진료
            </label>
            <label class="tag-check">
              <input type="checkbox" name="tagList" value="PARKING" ${fn:contains(hospital.tagList, 'PARKING') ? 'checked' : ''}>
						  <svg viewBox="0 0 24 24">
						  	<rect x="3" y="3" width="18" height="18" rx="2"/>
						  	<path d="M9 17V7h4a4 4 0 010 8H9"/>
						  </svg>
              주차 가능
            </label>
          </div>
      </div>

      <!-- ─────────── 3-2. 진료 대상 ───────────
            - 병원 특성과 동일하게 name="tagList" → 같은 TAG_LIST 컬럼에 저장
            - hospital/list 검색 필터(진료 대상)에서 사용
            ─────────────────────────────────── -->
      <div class="info-section">
          <div class="info-stitle">
            <svg viewBox="0 0 24 24">
              <circle cx="4.5" cy="9.5" r="2"/>
              <circle cx="9" cy="5.5" r="2"/>
              <circle cx="15" cy="5.5" r="2"/>
              <circle cx="19.5" cy="9.5" r="2"/>
            </svg>
            진료 대상
          </div>
          <p style="font-size:13px;color:#999;margin:0 0 14px">진료 가능한 동물을 선택하세요. 고객 검색 필터에 반영됩니다.</p>
          <div class="tag-checks">
            <label class="tag-check">
              <input type="checkbox" name="tagList" value="DOG" ${fn:contains(hospital.tagList, 'DOG') ? 'checked' : ''}>
              <svg viewBox="0 0 24 24">
                <path d="M10 5.172C10 3.782 8.884 2.5 7.5 2.5c-1.5 0-2.5 1.282-2.5 2.672C5 7.5 8 10 12 13c4-3 7-5.5 7-7.828C19 3.782 17.884 2.5 16.5 2.5c-1.384 0-2.5 1.282-2.5 2.672"/>
                <path d="M4 15v5a2 2 0 002 2h12a2 2 0 002-2v-5"/>
              </svg>
              강아지
            </label>
            <label class="tag-check">
              <input type="checkbox" name="tagList" value="CAT" ${fn:contains(hospital.tagList, 'CAT') ? 'checked' : ''}>
              <svg viewBox="0 0 24 24">
                <path d="M12 5c-1.5-2-4-3-6-3l1 7"/>
                <path d="M12 5c1.5-2 4-3 6-3l-1 7"/>
                <circle cx="12" cy="14" r="7"/>
              </svg>
              고양이
            </label>
            <label class="tag-check">
              <input type="checkbox" name="tagList" value="EXOTIC" ${fn:contains(hospital.tagList, 'EXOTIC') ? 'checked' : ''}>
              <svg viewBox="0 0 24 24">
                <circle cx="4.5" cy="9.5" r="2"/>
                <circle cx="9" cy="5.5" r="2"/>
                <circle cx="15" cy="5.5" r="2"/>
                <circle cx="19.5" cy="9.5" r="2"/>
              </svg>
              특수동물
            </label>
          </div>
      </div>

      <div class="info-section">
          <div class="info-stitle">
            <svg viewBox="0 0 24 24">
						  <rect x="3" y="3" width="18" height="18" rx="2"/>
						  <circle cx="8.5" cy="8.5" r="1.5"/>
						  <polyline points="21 15 16 10 5 21"/>
					  </svg>
            병원 이미지
          </div>
          <p style="font-size:13px;color:#999;margin:0 0 14px">
              첫 번째 이미지가 대표 이미지로 사용됩니다. (최대 4장)
          </p>

          <!-- 삭제할 파일 ID를 담는 영역 (JS가 동적으로 hidden input 추가) -->
          <div id="deleteFileArea"></div>

          <div class="img-upload-area">
            <!-- ── A. 기존 이미지 (DB에서 가져온 것) ── -->
            <c:forEach var="img" items="${imgList}" varStatus="st">
              <div class="img-upload-box ${st.index == 0 ? 'main' : ''}" id="existing-${img.fileId}">
                <!-- 이미 저장된 이미지 표시 -->
                <img class="img-preview" src="${contextPath}/upload/${img.fileUrl}">
                <!-- ✕ 버튼: 클릭하면 markDelete() 호출 -->
                <button type="button" class="btn-img-del" onclick="event.stopPropagation(); markDelete(${img.fileId}, this)">&times;</button>
              </div>
            </c:forEach>

            <!-- ── B. 빈 업로드 슬롯 (최대 4장 - 기존 이미지 수) ── -->
            <c:forEach begin="1" end="${4 - fn:length(imgList)}">
              <div class="img-upload-box" onclick="this.querySelector('input').click()">
                <svg viewBox="0 0 24 24">
                  <line x1="12" y1="5" x2="12" y2="19"/>
                  <line x1="5" y1="12" x2="19" y2="12"/>
                </svg>
                <small>추가</small>
                <!-- name="imgList" → Controller의 MultipartFile[] imgList -->
                <input type="file" name="imgList" accept=".jpg,.jpeg,.png" onchange="previewImg(this)">
              </div>
            </c:forEach>
          </div>
      </div>

      <!-- ─────────── 저장 / 취소 버튼 ─────────── -->
      <div class="info-btn-row">
            <button type="button" class="btn-info-cancel" onclick="location.href='${contextPath}/biz/hospital'">취소</button>
            <button type="submit" class="btn-info-submit">저장하기</button>
      </div>
    </form>
  </div>
</main>


<!-- ===================================
     JavaScript
     - 주소 검색 API
     - 운영시간 JSON 처리
     - 이미지 미리보기 / 삭제
     =================================== -->
<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<script>
	/* ===================================
	   요일 목록 (전역 상수)
	   - JS 전체에서 이 배열을 순회하며 요일별 처리
	   =================================== */
	var DAYS = ['월','화','수','목','금','토','일','공휴일'];

	/* 다음 주소 검색 → addr 입력 후 저장 시 서버에서 LAT/LNG 변환 */
	function searchAddr() {
		new daum.Postcode({
			oncomplete: function(data) {
				var addr = data.userSelectedType === 'R' ? data.roadAddress : data.jibunAddress;
				document.getElementById('addrInput').value = addr;
				var detail = document.querySelector('input[name="addrDetail"]');
				if (detail) detail.focus();
			}
		}).open();
	}


	/* ===================================
	   [1] 페이지 로딩 시: DB의 hoursJson → 화면에 채우기

	   DB 예시: {"월":{"open":"09:00","close":"18:00","lunchStart":"12:00","lunchEnd":"13:00"}, ...}
	   - JSON에 있는 요일 → 토글 ON + 시간 채우기
	   - JSON에 없는 요일 → 토글 OFF + 시간 비우기 (= 휴무)
	   =================================== */
	document.addEventListener('DOMContentLoaded', function() {

	    // 히든필드에서 JSON 문자열 가져오기
	    var jsonText = document.getElementById('hoursJsonInput').value;

	    // 값이 없으면 (신규 등록) 기본값 그대로 두고 종료
	    if (!jsonText || jsonText === '' || jsonText === 'null') {
	        return;
	    }

	    // JSON 문자열 → 자바스크립트 객체로 변환
	    var hoursData;
	    try {
	        hoursData = JSON.parse(jsonText);
	    } catch (e) {
	        return; // 파싱 실패 시 기본값 유지
	    }

	    // 8개 요일을 하나씩 순회
	    for (var i = 0; i < DAYS.length; i++) {
	        var day = DAYS[i];         // 예: "월"
	        var dayInfo = hoursData[day];  // 예: {open:"09:00", close:"18:00", ...} 또는 undefined

	        // 각 input 요소 가져오기
	        var useCheckbox = document.getElementById('use-' + day);
	        var openInput   = document.getElementById('open-' + day);
	        var closeInput  = document.getElementById('close-' + day);
	        var lunchSInput = document.getElementById('lunchS-' + day);
	        var lunchEInput = document.getElementById('lunchE-' + day);

	        if (!dayInfo) {
	            // JSON에 이 요일이 없음 → 휴무 처리
	            useCheckbox.checked = false;
	            toggleDay(day, useCheckbox);  // 행 흐리게
	            openInput.value   = '';
	            closeInput.value  = '';
	            lunchSInput.value = '';
	            lunchEInput.value = '';
	        } else {
	            // JSON에 이 요일이 있음 → 시간 채우기
	            useCheckbox.checked = true;
	            toggleDay(day, useCheckbox);  // 행 활성화
	            openInput.value   = dayInfo.open       || '';
	            closeInput.value  = dayInfo.close      || '';
	            lunchSInput.value = dayInfo.lunchStart  || '';
	            lunchEInput.value = dayInfo.lunchEnd    || '';
	        }
	    }
	});


	/* ===================================
	   [2] 저장 버튼 클릭 시: 화면의 시간 → JSON으로 조립 → 히든필드에 넣기

	   결과 예시:
	   {
	     "월": {"open":"09:00","close":"18:00","lunchStart":"12:00","lunchEnd":"13:00"},
	     "토": {"open":"09:00","close":"14:00","lunchStart":"","lunchEnd":""}
	   }
	   → 토글 OFF인 요일(일, 공휴일)은 JSON에 안 들어감 = 휴무
	   =================================== */
	document.querySelector('form[name="hospitalInfoForm"]').addEventListener('submit', function() {

	    var result = {};  // 빈 객체에 요일별로 추가

	    for (var i = 0; i < DAYS.length; i++) {
	        var day = DAYS[i];

	        // 토글이 꺼져있으면 이 요일은 건너뜀 (= 휴무)
	        var isOn = document.getElementById('use-' + day).checked;
	        if (!isOn) {
	            continue;
	        }

	        // 시작·종료 시간이 비어있으면 건너뜀
	        var openVal  = document.getElementById('open-' + day).value;
	        var closeVal = document.getElementById('close-' + day).value;
	        if (!openVal || !closeVal) {
	            continue;
	        }

	        // 이 요일의 시간 정보를 객체로 만들어 추가
	        result[day] = {
	            open:       openVal,
	            close:      closeVal,
	            lunchStart: document.getElementById('lunchS-' + day).value,
	            lunchEnd:   document.getElementById('lunchE-' + day).value
	        };
	    }

	    // 객체 → JSON 문자열로 변환 → 히든필드에 세팅
	    document.getElementById('hoursJsonInput').value = JSON.stringify(result);
	    // 이후 폼이 submit되면서 Controller로 전송됨
	});


	/* ===================================
	   [3] 요일 토글 ON/OFF

	   - 체크 해제 → 해당 행에 'row-off' 클래스 추가 → CSS가 흐리게 + 입력 비활성화
	   - 체크 선택 → 'row-off' 제거 → 정상 표시
	   =================================== */
	function toggleDay(day, checkbox) {
	    var row = document.getElementById('row-' + day);
	    if (checkbox.checked) {
	        row.classList.remove('row-off');
	    } else {
	        row.classList.add('row-off');
	    }
	}


	/* ===================================
	   [4] 월요일 시간을 나머지 요일에 복사

	   월요일의 4개 input값(시작, 종료, 점심시작, 점심종료)을
	   화~공휴일에 그대로 넣고, 토글도 월요일과 같게 맞춤
	   =================================== */
	function copyMonToAll() {
	    // 월요일 값 읽기
	    var monOpen   = document.getElementById('open-월').value;
	    var monClose  = document.getElementById('close-월').value;
	    var monLunchS = document.getElementById('lunchS-월').value;
	    var monLunchE = document.getElementById('lunchE-월').value;
	    var monIsOn   = document.getElementById('use-월').checked;

	    // i=1부터 (화요일부터) 순회
	    for (var i = 1; i < DAYS.length; i++) {
	        var day = DAYS[i];
	        document.getElementById('open-'   + day).value = monOpen;
	        document.getElementById('close-'  + day).value = monClose;
	        document.getElementById('lunchS-' + day).value = monLunchS;
	        document.getElementById('lunchE-' + day).value = monLunchE;
	        document.getElementById('use-' + day).checked  = monIsOn;
	        toggleDay(day, document.getElementById('use-' + day));
	    }
	}

	/* ===================================
	   [6] 새 이미지 미리보기

	   파일 선택 → FileReader로 읽기 → img 태그 생성 → 미리보기 표시
	   + 삭제(취소) 버튼도 함께 추가
	   =================================== */
	function previewImg(input) {
	    // 파일이 선택 안 됐으면 무시
	    if (!input.files || !input.files[0]) return;

	    var reader = new FileReader();

	    reader.onload = function(e) {
	        var box = input.closest('.img-upload-box');

	        // 기존 + 아이콘, "추가" 텍스트 숨기기
	        var svg   = box.querySelector('svg');
	        var small = box.querySelector('small');
	        if (svg)   svg.style.display   = 'none';
	        if (small) small.style.display = 'none';

	        // 이전 미리보기가 있으면 제거
	        var oldPreview = box.querySelector('.img-preview');
	        if (oldPreview) oldPreview.remove();

	        // 새 미리보기 이미지 추가
	        var img = document.createElement('img');
	        img.src = e.target.result;    // FileReader가 읽은 base64 데이터
	        img.className = 'img-preview';
	        box.appendChild(img);

	        // 삭제(취소) 버튼 추가 — 클릭하면 원래 빈 상태로 복원
	        if (!box.querySelector('.btn-img-del')) {
	            var delBtn = document.createElement('button');
	            delBtn.type = 'button';
	            delBtn.className = 'btn-img-del';
	            delBtn.innerHTML = '&times;';
	            delBtn.onclick = function(e) {
	                e.stopPropagation();   // 부모 div의 onclick 실행 방지
	                resetUploadBox(box);
	            };
	            box.appendChild(delBtn);
	        }
	    };

	    reader.readAsDataURL(input.files[0]);
	}


	/* ===================================
	   [7] 기존 이미지 삭제 표시

	   실제로 지우는 건 아니고, "삭제할 파일 ID"를 hidden input에 기록만 함
	   → 폼 submit 시 Controller가 deleteFileIds로 받아서 DB+물리파일 삭제
	   =================================== */
	function markDelete(fileId, btn) {
	    // 이미지 박스를 흐리게 + 클릭 불가 처리
	    var box = btn.closest('.img-upload-box');
	    box.classList.add('deleted');

	    // hidden input 생성 → deleteFileArea에 추가
	    var hiddenInput = document.createElement('input');
	    hiddenInput.type  = 'hidden';
	    hiddenInput.name  = 'deleteFileIds';   // Controller의 Long[] deleteFileIds와 매칭
	    hiddenInput.value = fileId;
	    document.getElementById('deleteFileArea').appendChild(hiddenInput);
	}


	/* ===================================
	   [8] 새 이미지 업로드 취소 (빈 슬롯으로 복원)

	   미리보기, 삭제버튼 제거 → file input 초기화 → + 아이콘 다시 표시
	   =================================== */
	function resetUploadBox(box) {
	    // 미리보기 이미지 제거
	    var preview = box.querySelector('.img-preview');
	    if (preview) preview.remove();

	    // 삭제 버튼 제거
	    var delBtn = box.querySelector('.btn-img-del');
	    if (delBtn) delBtn.remove();

	    // file input 초기화 (선택한 파일 해제)
	    var fileInput = box.querySelector('input[type="file"]');
	    if (fileInput) fileInput.value = '';

	    // + 아이콘과 "추가" 텍스트 다시 보이기
	    var svg   = box.querySelector('svg');
	    var small = box.querySelector('small');
	    if (svg)   svg.style.display = '';
	    if (small) small.style.display = '';
	}
</script>

<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>
