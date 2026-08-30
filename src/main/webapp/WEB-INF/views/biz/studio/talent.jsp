<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath"  value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="애완동물 사진관" />
<c:set var="bizPage"      value="talent" />
<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_studio.jsp" %>
<main class="biz-main">
    <div class="biz-page-head">
        <h1 class="biz-page-title">재능나눔 신청</h1>
    </div>
    
<style>
.talent-hero-studio{background:linear-gradient(135deg,#7E22CE 0%,#9333EA 100%);border-radius:12px;padding:26px 30px;color:#fff;display:flex;align-items:center;gap:18px;margin-bottom:20px}
.th-icon{width:56px;height:56px;border-radius:12px;background:rgba(255,255,255,.2);display:flex;align-items:center;justify-content:center;flex-shrink:0}
.th-icon svg{width:28px;height:28px;stroke:#fff;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round}
.talent-hero-studio h2{font-size:19px;font-weight:800;margin:0 0 5px}
.talent-hero-studio p{font-size:13px;opacity:.85;margin:0;line-height:1.6}
.bt-section{background:#fff;border:1px solid var(--biz-border);border-radius:12px;padding:22px;margin-bottom:18px}
.bt-stitle{font-size:14px;font-weight:800;color:#1A1A2E;margin:0 0 16px;padding-bottom:11px;border-bottom:1px solid var(--biz-border);display:flex;align-items:center;gap:8px}
.bt-stitle svg{width:15px;height:15px;stroke:var(--biz-primary);fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}
.bt-grid{display:grid;grid-template-columns:1fr 1fr;gap:13px}
.bt-group{display:flex;flex-direction:column;gap:5px}
.bt-group.full{grid-column:1/-1}
.bt-group label{font-size:13px;font-weight:600;color:#555}
.bt-group label .req{color:#FF6B6B;margin-left:2px}
.bt-group input,.bt-group select,.bt-group textarea{border:1px solid var(--biz-border);border-radius:8px;padding:9px 13px;font-size:14px;color:#1A1A2E;outline:none;font-family:inherit;width:100%;box-sizing:border-box;transition:border-color .2s}
.bt-group input:focus,.bt-group select:focus,.bt-group textarea:focus{border-color:var(--biz-primary)}
.bt-group textarea{min-height:100px;resize:vertical;line-height:1.6}
.example-box{background:#FAF5FF;border:1px solid #E9D5FF;border-radius:8px;padding:14px;margin-bottom:0}
.example-box h4{font-size:13px;font-weight:700;color:#7E22CE;margin:0 0 10px}
.ex-item{display:flex;align-items:center;gap:7px;font-size:13px;color:#555;margin-bottom:6px}
.ex-item svg{width:13px;height:13px;stroke:#9333EA;fill:none;stroke-width:2.5;stroke-linecap:round;stroke-linejoin:round;flex-shrink:0}
.bt-btn-row{display:flex;justify-content:flex-end;gap:10px;margin-top:4px}
.btn-cancel-t{padding:10px 22px;border:1px solid var(--biz-border);border-radius:8px;background:#fff;color:#555;font-size:14px;font-weight:600;cursor:pointer}
.btn-submit-t{padding:10px 26px;border:none;border-radius:8px;background:var(--biz-primary);color:#fff;font-size:14px;font-weight:700;cursor:pointer;transition:background .15s}
.btn-submit-t:hover{background:var(--biz-primary-dark)}
.img-upload-box{border:2px dashed var(--biz-border);border-radius:8px;padding:20px;text-align:center;cursor:pointer;display:flex;flex-direction:column;align-items:center;gap:7px;color:#999;transition:all .15s}
.img-upload-box:hover{border-color:var(--biz-primary);color:var(--biz-primary);background:#F0FAF6}
.img-upload-box svg{width:26px;height:26px;stroke:currentColor;fill:none;stroke-width:1.6;stroke-linecap:round;stroke-linejoin:round}
</style>

<div class="talent-hero-studio">
  <div class="th-icon">
    <svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
  </div>
  <div>
    <h2>반려동물 사진 촬영 재능나눔</h2>
    <p>전문 사진 촬영 기술로 유기동물의 입양 홍보를 도와주세요.<br>예쁜 사진 한 장이 동물의 새 가족을 만나게 해줄 수 있습니다.</p>
  </div>
</div>

<div class="bt-section">
  <div class="bt-stitle">
    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
    이런 재능나눔을 해보세요
  </div>
  <div class="example-box">
    <h4>사진관이 할 수 있는 재능나눔</h4>
    <div class="ex-item"><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>유기동물 입양 홍보용 프로필 사진 촬영</div>
    <div class="ex-item"><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>보호소 방문 출장 촬영 (단체 사진 포함)</div>
    <div class="ex-item"><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>발견 신고 게시판용 사진 편집·보정 지원</div>
    <div class="ex-item"><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>임시 보호 중인 반려동물 홍보 콘텐츠 제작</div>
  </div>
</div>

<div class="bt-section">
  <div class="bt-stitle">
    <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
    재능나눔 신청서
  </div>
  <div class="bt-grid">
    <div class="bt-group full">
      <label>제목 <span class="req">*</span></label>
      <input type="text" value="${memberInfo.memberName} 반려동물 사진 촬영 재능나눔">
    </div>
    <div class="bt-group">
      <label>나눔 유형 <span class="req">*</span></label>
      <select><option selected>사진 촬영</option></select>
    </div>
    <div class="bt-group">
      <label>모집 수량 <span class="req">*</span></label>
      <input type="number" min="1" value="5" placeholder="마리 또는 건수">
    </div>
    <div class="bt-group">
      <label>진행 일정 <span class="req">*</span></label>
      <input type="text" placeholder="예) 매월 둘째 주 토요일" value="매월 둘째 주 토요일">
    </div>
    <div class="bt-group">
      <label>소요 시간</label>
      <input type="text" placeholder="예) 마리당 20~30분">
    </div>
    <div class="bt-group">
      <label>장소 <span class="req">*</span></label>
      <input type="text" placeholder="업체명 또는 보호소 방문" value="${memberInfo.memberName}">
    </div>
    <div class="bt-group">
      <label>문의 연락처</label>
      <input type="tel" placeholder="010-0000-0000">
    </div>
    <div class="bt-group full">
      <label>상세 설명 <span class="req">*</span></label>
      <textarea placeholder="촬영 내용, 제공 파일 형식, 편집 범위, 신청 방법 등을 적어주세요."></textarea>
    </div>
    <div class="bt-group full">
      <label>대표 이미지 (포트폴리오)</label>
      <div class="img-upload-box">
        <svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
        <span style="font-size:14px">클릭하여 업로드</span>
        <small style="font-size:12px">JPG, PNG (최대 10MB)</small>
      </div>
    </div>
  </div>
  <div class="bt-btn-row">
    <button class="btn-cancel-t" onclick="history.back()">취소</button>
    <button class="btn-submit-t" onclick="alert('재능나눔 신청이 접수되었습니다.\nPetCare 나눔팀이 검토 후 3 영업일 내 안내드립니다.')">신청하기</button>
  </div>
</div>

<div class="bt-section">
  <div class="bt-stitle">
    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
    내 재능나눔 이력
  </div>
  <table class="biz-table">
    <thead><tr><th>등록일</th><th>제목</th><th>유형</th><th>진행 수</th><th>상태</th></tr></thead>
    <tbody>
      <tr><td>2025.05.11</td><td>${memberInfo.memberName} 반려동물 사진 촬영 재능나눔</td><td>사진 촬영</td><td>5건</td><td><span class="bs-badge bs-done">완료</span></td></tr>
      <tr><td>2025.04.13</td><td>${memberInfo.memberName} 반려동물 사진 촬영 재능나눔</td><td>사진 촬영</td><td>5건</td><td><span class="bs-badge bs-done">완료</span></td></tr>
    </tbody>
  </table>
</div>

</main>
<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>
