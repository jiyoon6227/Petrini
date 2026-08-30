<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="숙소" />
<c:set var="bizPage" value="info" />

<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_stay.jsp" %>

<style>
	.info-wrap{display:flex;flex-direction:column;gap:20px}
	.info-hero{background:linear-gradient(135deg,#1F8464 0%,#2BAB82 100%);border-radius:12px;padding:28px 32px;color:#fff;display:flex;align-items:center;gap:20px}
	.info-hero-icon{width:60px;height:60px;border-radius:14px;background:rgba(255,255,255,.2);display:flex;align-items:center;justify-content:center;flex-shrink:0}
	.info-hero-icon svg{width:30px;height:30px;stroke:#fff;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round}
	.info-hero h2{font-size:20px;font-weight:800;margin:0 0 6px}
	.info-hero p{font-size:13px;opacity:.85;margin:0;line-height:1.6}
	.info-section{background:#fff;border:1px solid #E4E6ED;border-radius:12px;padding:24px}
	.info-stitle{font-size:14px;font-weight:800;color:#1A1A2E;margin:0 0 18px;padding-bottom:12px;border-bottom:1px solid #E4E6ED;display:flex;align-items:center;gap:8px}
	.info-stitle svg{width:16px;height:16px;stroke:#2BAB82;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;flex-shrink:0}
	.info-grid{display:grid;grid-template-columns:1fr 1fr;gap:14px}
	.info-group{display:flex;flex-direction:column;gap:6px}
	.info-group.full{grid-column:1/-1}
	.info-group label{font-size:13px;font-weight:600;color:#555}
	.info-group input{
		border:1px solid #E4E6ED;border-radius:8px;padding:10px 14px;font-size:14px;color:#1A1A2E;
		outline:none;font-family:inherit;width:100%;box-sizing:border-box;
		background-color:#f5f5f5;cursor:default}
	@media (max-width:640px) {
		.info-hero{flex-direction:column;text-align:center;padding:20px 16px;gap:12px}
		.info-hero-icon{width:48px;height:48px}
		.info-section{padding:18px 16px}
		.info-grid{grid-template-columns:1fr;gap:12px}
	}
</style>

<main class="biz-main">
    <div class="biz-page-head">
        <h1 class="biz-page-title">사업자 정보</h1>
        <p class="biz-page-desc">사업자 등록 시 입력한 기본 정보입니다. 수정이 필요한 경우 관리자에게 문의하세요.</p>
    </div>

    <div class="info-wrap">

        <!-- 히어로 배너 -->
        <div class="info-hero">
            <div class="info-hero-icon">
                <svg viewBox="0 0 24 24">
                    <path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z"/>
                    <path d="M9 22V12h6v10"/>
                </svg>
            </div>
            <div>
                <h2>사업자 정보 확인</h2>
                <p>아래 정보는 사업자 등록 승인 시 등록된 내용입니다.<br>정보 변경은 고객센터 또는 관리자에게 요청해 주세요.</p>
            </div>
        </div>

        <!-- 기본 정보 섹션 -->
        <div class="info-section">
            <div class="info-stitle">
                <svg viewBox="0 0 24 24">
                    <path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z"/>
                </svg>
                기본 정보
            </div>
            <div class="info-grid">
                <div class="info-group">
                    <label>숙소명</label>
                    <input type="text" value="${stay.name}" readonly>
                </div>
                <div class="info-group">
                    <label>전화번호</label>
                    <input type="tel" value="${stay.phone}" readonly>
                </div>
				<div class="info-group full">
					<label>주소 <span class="req">*</span></label>
					<div class="info-input-row">
						<input type="text" name="addr" value="${stay.addr}" readonly>
					</div>
					<input type="text" name="addrDetail" value="${stay.addrDetail}" style="margin-top:8px" readonly>
				</div>
            </div>
        </div>

    </div>
</main>

<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>
