<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="동물병원" />
<c:set var="bizPage" value="info" />

<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_hospital.jsp" %>

<style>
	/* ===================================
	info 페이지 스타일
	talent.jsp와 동일한 색상 체계 사용
	=================================== */
	
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
	
	/* 주소 입력 행 (우편번호 + 버튼) */
	.info-input-row{display:flex;gap:8px}
	.info-input-row input{flex:1}
	.btn-addr{padding:10px 16px;border:none;border-radius:8px;background:#2BAB82;color:#fff;font-size:13px;font-weight:700;cursor:pointer;white-space:nowrap;transition:background .15s}
	.btn-addr:hover{background:#1F8464}
	
	input[readonly] {background-color: #f5f5f5;cursor: default;}
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

		<!-- ─────────── 1. 기본 정보 ─────────── -->
		<div class="info-section">
			<div class="info-stitle">
				<svg viewBox="0 0 24 24">
					<path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z"/>
				</svg>
				기본 정보
			</div>
			<div class="info-grid">
				<!-- name="name" → HospitalVO.name에 자동 바인딩 -->
				<div class="info-group">
					<label>병원명 <span class="req">*</span></label>
					<input type="text" name="name" value="${hospital.name}" readonly>
				</div>
				<div class="info-group">
					<label>전화번호 <span class="req">*</span></label>
					<input type="tel" name="phone" value="${hospital.phone}" readonly>
				</div>

				<!-- 주소: readonly 필드 + 상세주소 직접 입력 -->
				<div class="info-group full">
					<label>주소 <span class="req">*</span></label>
					<div class="info-input-row">
						<input type="text" name="addr" value="${hospital.addr}" readonly>
					</div>
					<input type="text" name="addrDetail" value="${hospital.addrDetail}" style="margin-top:8px" readonly>
				</div>
			</div>
		</div>
    </div>
</main>

<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>
