<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath"  value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="애견미용실" />
<c:set var="bizPage"      value="talent" />
<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_grooming.jsp" %>
<style>
.bt-wrap{display:flex;flex-direction:column;gap:20px}
.bt-hero{background:linear-gradient(135deg,#1F8464 0%,#2BAB82 100%);border-radius:12px;padding:28px 32px;color:#fff;display:flex;align-items:center;gap:20px}
.bt-hero-icon{width:60px;height:60px;border-radius:14px;background:rgba(255,255,255,.2);display:flex;align-items:center;justify-content:center;flex-shrink:0}
.bt-hero-icon svg{width:30px;height:30px;stroke:#fff;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round}
.bt-hero h2{font-size:20px;font-weight:800;margin:0 0 6px}
.bt-hero p{font-size:13px;opacity:.85;margin:0;line-height:1.6}
.bt-section{background:#fff;border:1px solid #E4E6ED;border-radius:12px;padding:24px}
.bt-stitle{font-size:14px;font-weight:800;color:#1A1A2E;margin:0 0 18px;padding-bottom:12px;border-bottom:1px solid #E4E6ED;display:flex;align-items:center;gap:8px}
.bt-stitle svg{width:16px;height:16px;stroke:#2BAB82;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}
.bt-grid{display:grid;grid-template-columns:1fr 1fr;gap:14px}
.bt-group{display:flex;flex-direction:column;gap:6px}
.bt-group.full{grid-column:1/-1}
.bt-group label{font-size:13px;font-weight:600;color:#555}
.bt-group label .req{color:#FF6B6B;margin-left:2px}
.bt-group input,.bt-group select,.bt-group textarea{border:1px solid #E4E6ED;border-radius:8px;padding:10px 14px;font-size:14px;color:#1A1A2E;outline:none;font-family:inherit;width:100%;box-sizing:border-box;transition:border-color .2s}
.bt-group input:focus,.bt-group select:focus,.bt-group textarea:focus{border-color:#2BAB82}
.bt-group textarea{min-height:100px;resize:vertical;line-height:1.6}
.bt-example-box{background:#F0FAF6;border:1px solid #B6E8D4;border-radius:8px;padding:16px;margin-bottom:0}
.bt-example-box h4{font-size:13px;font-weight:700;color:#1F8464;margin:0 0 10px}
.bt-ex-item{display:flex;align-items:center;gap:8px;font-size:13px;color:#555;margin-bottom:6px}
.bt-ex-item svg{width:14px;height:14px;stroke:#2BAB82;fill:none;stroke-width:2.5;stroke-linecap:round;stroke-linejoin:round;flex-shrink:0}
.bt-btn-row{display:flex;justify-content:flex-end;gap:10px;margin-top:4px}
.btn-bt-cancel{padding:11px 24px;border:1px solid #E4E6ED;border-radius:8px;background:#fff;color:#555;font-size:14px;font-weight:600;cursor:pointer}
.btn-bt-submit{padding:11px 28px;border:none;border-radius:8px;background:#2BAB82;color:#fff;font-size:14px;font-weight:700;cursor:pointer;transition:background .15s}
.btn-bt-submit:hover{background:#1F8464}
.bt-img-box{border:2px dashed #E4E6ED;border-radius:8px;padding:20px;text-align:center;cursor:pointer;display:flex;flex-direction:column;align-items:center;gap:8px;color:#999;transition:all .15s}
.bt-img-box:hover{border-color:#2BAB82;color:#1F8464;background:#F0FAF6}
.bt-img-box svg{width:28px;height:28px;stroke:currentColor;fill:none;stroke-width:1.6;stroke-linecap:round;stroke-linejoin:round}
</style>
<main class="biz-main">
  <div class="biz-page-head">
    <h1 class="biz-page-title">재능나눔 신청</h1>
    <p class="biz-page-desc">전문 기술로 유기동물을 돕고, 파트너 브랜드 가치도 높여보세요.</p>
  </div>
  <div class="bt-wrap">
    <div class="bt-hero">
      <div class="bt-hero-icon"><svg viewBox="0 0 24 24"><path d="M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78L12 21.23l8.84-8.84a5.5 5.5 0 000-7.78z"/></svg></div>
      <div><h2>애견미용 재능나눔</h2><p>전문 미용 기술로 유기견들이 더 예쁜 모습으로 새 가족을 만날 수 있게 도와주세요.<br>신청 후 PetCare 나눔팀이 검토하여 나눔 탭에 게시됩니다.</p></div>
    </div>
    <div class="bt-section">
      <div class="bt-stitle"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>이런 재능나눔을 해보세요</div>
      <div class="bt-example-box"><h4>추천 재능나눔 유형</h4>
      <div class="bt-ex-item"><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>보호소 유기견 전체 미용 (컷, 드라이, 발톱 정리)</div>
      <div class="bt-ex-item"><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>입양 전 그루밍 — 더 예쁜 모습으로 새 가족 만나기</div>
      <div class="bt-ex-item"><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>매월 정기 목욕 + 기본 미용 제공</div>
      <div class="bt-ex-item"><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>임시 보호 중인 반려동물 미용 지원</div></div>
    </div>
    <div class="bt-section">
      <div class="bt-stitle"><svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>재능나눔 신청서</div>
      <div class="bt-grid">
        <div class="bt-group full"><label>재능나눔 제목 <span class="req">*</span></label><input type="text" value="${memberInfo.memberName} 애견미용 재능나눔"></div>
        <div class="bt-group"><label>제공 유형 <span class="req">*</span></label><select><option selected>애견미용</option></select></div>
        <div class="bt-group"><label>모집 수량 <span class="req">*</span></label><input type="number" min="1" value="10"></div>
        <div class="bt-group"><label>진행 일정 <span class="req">*</span></label><input type="text" value="매월 마지막 일요일"></div>
        <div class="bt-group"><label>소요 시간</label><input type="text" placeholder="예) 1~2시간"></div>
        <div class="bt-group"><label>장소 <span class="req">*</span></label><input type="text" value="${memberInfo.memberName}"></div>
        <div class="bt-group"><label>문의 연락처</label><input type="tel" placeholder="02-0000-0000"></div>
        <div class="bt-group full"><label>상세 설명 <span class="req">*</span></label><textarea placeholder="제공 서비스 내용, 신청 방법, 대상 동물, 주의사항 등을 작성해 주세요."></textarea></div>
        <div class="bt-group full"><label>대표 이미지</label><div class="bt-img-box"><svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg><span style="font-size:14px">클릭하여 업로드</span><small style="font-size:12px">JPG, PNG (최대 10MB)</small></div></div>
      </div>
      <div class="bt-btn-row">
        <button class="btn-bt-cancel" onclick="history.back()">취소</button>
        <button class="btn-bt-submit" onclick="alert('재능나눔 신청이 접수되었습니다.\nPetCare 나눔팀이 검토 후 3 영업일 내 안내드립니다.')">신청하기</button>
      </div>
    </div>
    <div class="bt-section">
      <div class="bt-stitle"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>내 재능나눔 이력</div>
      <table class="biz-table">
        <thead><tr><th>등록일</th><th>제목</th><th>유형</th><th>진행 수</th><th>상태</th></tr></thead>
        <tbody>
          <tr><td>2025.05.25</td><td>${memberInfo.memberName} 애견미용 재능나눔</td><td>애견미용</td><td>10건</td><td><span class="bs-badge bs-done">승인완료</span></td></tr>
          <tr><td>2025.04.27</td><td>${memberInfo.memberName} 애견미용 재능나눔</td><td>애견미용</td><td>8건</td><td><span class="bs-badge bs-done">완료</span></td></tr>
        </tbody>
      </table>
    </div>
  </div>
</main>
<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>
