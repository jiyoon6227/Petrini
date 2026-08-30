<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="adminPage"   value="cms-terms" />
<%@ include file="/WEB-INF/views/admin/common/header.jsp" %>
<%@ include file="/WEB-INF/views/admin/common/sidebar.jsp" %>

<style>
    .terms-layout { display:grid; grid-template-columns:240px 1fr; gap:20px; align-items:flex-start; }
    
    /* 약관 탭 목록 */
    .terms-nav { background:#fff; border:1px solid #E4E6ED; border-radius:12px; overflow:hidden; }
    .terms-nav-head { padding:14px 18px; background:#FAFBFC; border-bottom:1px solid #E4E6ED; font-size:14px; font-weight:700; color:#1A1A2E; }
    .terms-nav-item {
        display:flex; align-items:center; justify-content:space-between;
        padding:12px 18px; cursor:pointer; transition:background .15s;
        border-left:3px solid transparent; font-size:14px; color:#555;
        border-bottom:1px solid #F5F5F5;
    }
    .terms-nav-item:last-child { border-bottom:none; }
    .terms-nav-item:hover { background:#F8F9FF; color:#3B5BDB; }
    .terms-nav-item.active { background:#EEF2FF; border-left-color:#3B5BDB; color:#3B5BDB; font-weight:700; }
    .terms-nav-item .terms-version { font-size:11px; color:#999; }
    .terms-nav-item.active .terms-version { color:#8B9CF7; }
    
    /* 약관 편집 영역 */
    .terms-editor-card { background:#fff; border:1px solid #E4E6ED; border-radius:12px; overflow:hidden; }
    .terms-editor-head { display:flex; justify-content:space-between; align-items:center; padding:16px 20px; background:#FAFBFC; border-bottom:1px solid #E4E6ED; }
    .terms-editor-head h3 { font-size:15px; font-weight:800; color:#1A1A2E; margin:0; }
    .terms-meta-row { display:flex; gap:20px; align-items:center; padding:14px 20px; border-bottom:1px solid #E4E6ED; background:#FAFBFC; flex-wrap:wrap; }
    .terms-meta-item { display:flex; align-items:center; gap:8px; font-size:13px; color:#555; }
    .terms-meta-item label { color:#999; font-weight:600; white-space:nowrap; }
    .terms-meta-item input,
    .terms-meta-item select { border:1px solid #E4E6ED; border-radius:6px; padding:6px 10px; font-size:13px; color:#1A1A2E; outline:none; font-family:inherit; }
    .terms-meta-item input:focus,
    .terms-meta-item select:focus { border-color:#3B5BDB; }
    .terms-toolbar { background:#F8F9FF; border-bottom:1px solid #E4E6ED; padding:10px 16px; display:flex; gap:6px; flex-wrap:wrap; }
    .tb-btn { padding:5px 10px; border:1px solid #E4E6ED; border-radius:5px; background:#fff; font-size:12px; font-weight:600; color:#555; cursor:pointer; transition:all .15s; }
    .tb-btn:hover { border-color:#3B5BDB; color:#3B5BDB; }
    .terms-textarea { width:100%; min-height:400px; border:none; padding:20px; font-size:14px; color:#1A1A2E; outline:none; resize:vertical; font-family:inherit; line-height:1.8; box-sizing:border-box; }
    .terms-footer { display:flex; justify-content:space-between; align-items:center; padding:14px 20px; border-top:1px solid #E4E6ED; background:#FAFBFC; }
    .terms-footer-left { font-size:12px; color:#999; }
    
    /* 버전 히스토리 */
    .history-card { background:#fff; border:1px solid #E4E6ED; border-radius:12px; overflow:hidden; margin-top:20px; }
    .history-head { padding:14px 18px; background:#FAFBFC; border-bottom:1px solid #E4E6ED; font-size:14px; font-weight:700; color:#1A1A2E; }
</style>

<main class="adm-main">
    <div class="adm-page-head">
        <div class="adm-page-head-left">
            <h1 class="adm-page-title">이용약관 관리</h1>
            <p class="adm-page-desc">서비스 이용약관 및 개인정보처리방침을 관리하세요.</p>
        </div>
    </div>

    <div class="terms-layout">

        <%-- 왼쪽: 약관 목록 --%>
        <div>
            <div class="terms-nav">
                <div class="terms-nav-head">약관 목록</div>
                <div class="terms-nav-item active" onclick="selectTerms(this,'서비스 이용약관')">
                    서비스 이용약관
                    <span class="terms-version">v2.3</span>
                </div>
                <div class="terms-nav-item" onclick="selectTerms(this,'개인정보처리방침')">
                    개인정보처리방침
                    <span class="terms-version">v1.8</span>
                </div>
                <div class="terms-nav-item" onclick="selectTerms(this,'위치기반서비스 이용약관')">
                    위치기반서비스
                    <span class="terms-version">v1.2</span>
                </div>
                <div class="terms-nav-item" onclick="selectTerms(this,'마케팅 정보 수신 동의')">
                    마케팅 수신 동의
                    <span class="terms-version">v1.0</span>
                </div>
                <div class="terms-nav-item" onclick="selectTerms(this,'사업자 파트너 이용약관')">
                    파트너 이용약관
                    <span class="terms-version">v1.1</span>
                </div>
            </div>
        </div>

        <%-- 오른쪽: 편집 --%>
        <div>
            <div class="terms-editor-card">
                <div class="terms-editor-head">
                    <h3 id="terms-title">서비스 이용약관</h3>
                    <div style="display:flex;align-items:center;gap:8px">
                        <span style="font-size:12px;color:#999">현재 버전: <strong style="color:#3B5BDB">v2.3</strong></span>
                        <span class="adm-badge active">적용 중</span>
                    </div>
                </div>
                <div class="terms-meta-row">
                    <div class="terms-meta-item">
                        <label>시행일</label>
                        <input type="date" value="2025-06-01">
                    </div>
                    <div class="terms-meta-item">
                        <label>버전</label>
                        <input type="text" value="v2.3" style="width:70px">
                    </div>
                    <div class="terms-meta-item">
                        <label>상태</label>
                        <select>
                            <option selected>적용 중</option>
                            <option>임시저장</option>
                            <option>예약 발행</option>
                        </select>
                    </div>
                    <div class="terms-meta-item">
                        <label>필수 동의</label>
                        <label class="adm-toggle"><input type="checkbox" checked><span class="adm-toggle-slider"></span></label>
                    </div>
                </div>
                <div class="terms-toolbar">
                    <button class="tb-btn"><strong>B</strong></button>
                    <button class="tb-btn"><em>I</em></button>
                    <button class="tb-btn"><u>U</u></button>
                    <button class="tb-btn">H1</button>
                    <button class="tb-btn">H2</button>
                    <button class="tb-btn">H3</button>
                    <button class="tb-btn">목록</button>
                    <button class="tb-btn">번호목록</button>
                    <button class="tb-btn">표</button>
                    <button class="tb-btn">링크</button>
                </div>
                <textarea class="terms-textarea">제1조 (목적)
이 약관은 PetCare(이하 "회사")가 운영하는 PetCare 서비스(이하 "서비스")의 이용 조건 및 절차, 회사와 이용자의 권리, 의무 및 책임 사항 등을 규정함을 목적으로 합니다.

제2조 (용어의 정의)
① "서비스"란 회사가 제공하는 반려동물 관련 통합 플랫폼 서비스를 의미합니다.
② "이용자"란 이 약관에 따라 회사가 제공하는 서비스를 이용하는 회원 및 비회원을 말합니다.
③ "회원"이란 회사에 개인정보를 제공하여 회원 등록을 한 자로서, 회사의 정보를 지속적으로 제공받으며 서비스를 계속적으로 이용할 수 있는 자를 말합니다.

제3조 (약관의 효력 및 변경)
① 이 약관은 서비스 화면에 게시하거나 기타의 방법으로 이용자에게 공지함으로써 효력을 발생합니다.
② 회사는 합리적인 사유가 발생할 경우 이 약관을 변경할 수 있으며, 변경된 약관은 공지사항을 통해 공시합니다.

제4조 (서비스의 제공)
① 회사는 다음과 같은 서비스를 제공합니다.
  1. 반려동물 관련 상품 쇼핑 서비스
  2. 동물병원 예약 서비스
  3. 반려동물 동반 여가 예약 서비스
  4. 커뮤니티 서비스
  5. 유기동물 입양 정보 서비스
  6. 기타 회사가 정하는 서비스</textarea>
                <div class="terms-footer">
                    <div class="terms-footer-left">마지막 수정: 2025.06.01 · 수정자: 관리자</div>
                    <div style="display:flex;gap:8px">
                        <button class="adm-btn gray" onclick="alert('임시저장 되었습니다.')">임시저장</button>
                        <button class="adm-btn blue" onclick="if(confirm('약관을 저장하고 즉시 적용하시겠습니까?\n이용자에게 고지 후 시행됩니다.'))alert('저장 및 적용 완료되었습니다.')">저장 &amp; 적용</button>
                    </div>
                </div>
            </div>

            <%-- 버전 히스토리 --%>
            <div class="history-card">
                <div class="history-head">버전 히스토리</div>
                <table class="adm-table">
                    <thead><tr><th>버전</th><th>시행일</th><th>수정자</th><th>변경 내용</th><th>상태</th><th></th></tr></thead>
                    <tbody>
                        <tr><td><strong>v2.3</strong></td><td>2025.06.01</td><td>관리자</td><td>제4조 서비스 항목 추가 (유기동물 입양 서비스)</td><td><span class="adm-badge active">적용 중</span></td><td><button class="adm-btn gray">보기</button></td></tr>
                        <tr><td>v2.2</td><td>2025.03.01</td><td>관리자</td><td>제6조 개인정보 관련 조항 보완</td><td><span class="adm-badge" style="background:#F1F3F7;color:#999">만료</span></td><td><button class="adm-btn gray">보기</button></td></tr>
                        <tr><td>v2.1</td><td>2025.01.01</td><td>관리자</td><td>사업자 파트너 관련 조항 신설</td><td><span class="adm-badge" style="background:#F1F3F7;color:#999">만료</span></td><td><button class="adm-btn gray">보기</button></td></tr>
                        <tr><td>v2.0</td><td>2024.12.01</td><td>관리자</td><td>약관 전면 개정</td><td><span class="adm-badge" style="background:#F1F3F7;color:#999">만료</span></td><td><button class="adm-btn gray">보기</button></td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>

<script>
function selectTerms(el, name) {
    document.querySelectorAll('.terms-nav-item').forEach(i => i.classList.remove('active'));
    el.classList.add('active');
    document.getElementById('terms-title').textContent = name;
}
</script>

<%@ include file="/WEB-INF/views/admin/common/footer.jsp" %>
