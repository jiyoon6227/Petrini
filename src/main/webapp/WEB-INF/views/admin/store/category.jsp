<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="adminPage"   value="category" />
<%@ include file="/WEB-INF/views/admin/common/header.jsp" %>
<%@ include file="/WEB-INF/views/admin/common/sidebar.jsp" %>

<style>
.cat-layout { display:grid; grid-template-columns:320px 1fr; gap:20px; align-items:flex-start; }

/* 카테고리 트리 */
.cat-tree-card { background:#fff; border:1px solid #E4E6ED; border-radius:12px; overflow:hidden; }
.cat-tree-head {
    display:flex; justify-content:space-between; align-items:center;
    padding:14px 18px; background:#FAFBFC; border-bottom:1px solid #E4E6ED;
    font-size:14px; font-weight:700; color:#1A1A2E;
}
.cat-tree { padding:8px 0; }
.cat-level1 { }
.cat-item1 {
    display:flex; align-items:center; gap:8px;
    padding:10px 18px; cursor:pointer; transition:background .15s;
    font-size:14px; font-weight:700; color:#1A1A2E; border-left:3px solid transparent;
}
.cat-item1:hover { background:#F8F9FF; }
.cat-item1.selected { background:#EEF2FF; border-left-color:#3B5BDB; color:#3B5BDB; }
.cat-item1 svg { width:14px; height:14px; stroke:currentColor; fill:none; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; flex-shrink:0; }
.cat-toggle { margin-left:auto; cursor:pointer; font-size:11px; color:#999; }
.cat-level2 { padding-left:0; }
.cat-item2 {
    display:flex; align-items:center; gap:8px;
    padding:8px 18px 8px 36px; cursor:pointer; transition:background .15s;
    font-size:13px; color:#555; border-left:3px solid transparent;
}
.cat-item2:hover { background:#F8F9FF; color:#3B5BDB; }
.cat-item2.selected { background:#EEF2FF; border-left-color:#3B5BDB; color:#3B5BDB; font-weight:600; }
.cat-item2-dot { width:6px; height:6px; border-radius:50%; background:#ccc; flex-shrink:0; }
.cat-item2.selected .cat-item2-dot { background:#3B5BDB; }
.cat-count { margin-left:auto; font-size:11px; color:#999; background:#F1F3F7; padding:1px 7px; border-radius:20px; }
.cat-divider { height:1px; background:#E4E6ED; margin:6px 12px; }

/* 카테고리 편집 폼 */
.cat-form-card { background:#fff; border:1px solid #E4E6ED; border-radius:12px; padding:22px; margin-bottom:20px; }
.cat-form-title { font-size:14px; font-weight:800; color:#1A1A2E; margin:0 0 18px; padding-bottom:12px; border-bottom:1px solid #E4E6ED; display:flex; align-items:center; gap:8px; }
.cat-form-title svg { width:16px; height:16px; stroke:#3B5BDB; fill:none; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; }
.cat-form-group { display:flex; flex-direction:column; gap:6px; margin-bottom:14px; }
.cat-form-group label { font-size:13px; font-weight:600; color:#555; }
.cat-form-group label .req { color:#DC2626; margin-left:2px; }
.cat-form-group input,
.cat-form-group select { border:1px solid #E4E6ED; border-radius:8px; padding:9px 12px; font-size:14px; color:#1A1A2E; outline:none; font-family:inherit; width:100%; box-sizing:border-box; }
.cat-form-group input:focus,
.cat-form-group select:focus { border-color:#3B5BDB; }
.cat-form-row { display:flex; gap:10px; }
.cat-form-row .cat-form-group { flex:1; }
.cat-btn-row { display:flex; justify-content:flex-end; gap:8px; margin-top:4px; }

/* 카테고리 목록 테이블 */
.cat-table-card { background:#fff; border:1px solid #E4E6ED; border-radius:12px; overflow:hidden; }
.cat-table-head { display:flex; justify-content:space-between; align-items:center; padding:14px 18px; background:#FAFBFC; border-bottom:1px solid #E4E6ED; }
.cat-order-badge { display:inline-flex; align-items:center; justify-content:center; width:24px; height:24px; background:#F1F3F7; border-radius:6px; font-size:12px; font-weight:700; color:#555; }
.cat-drag-hint { font-size:12px; color:#999; }
.cat-drag-hint svg { width:13px; height:13px; stroke:#999; fill:none; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; }
</style>

<main class="adm-main">
    <div class="adm-page-head">
        <div class="adm-page-head-left">
            <h1 class="adm-page-title">상품 카테고리 관리</h1>
            <p class="adm-page-desc">대·소분류 카테고리를 등록하고 순서를 관리하세요.</p>
        </div>
    </div>

    <div class="cat-layout">

        <%-- 왼쪽: 카테고리 트리 --%>
        <div>
            <div class="cat-tree-card">
                <div class="cat-tree-head">
                    카테고리 목록
                    <button class="adm-btn blue" onclick="showAddForm()">
                        <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                        추가
                    </button>
                </div>
                <div class="cat-tree">
                    <%-- 대분류 1 --%>
                    <div class="cat-level1">
                        <div class="cat-item1 selected" onclick="selectCat(this,'사료')">
                            <svg viewBox="0 0 24 24"><path d="M6 2L3 6v14a2 2 0 002 2h14a2 2 0 002-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 01-8 0"/></svg>
                            사료
                            <span class="cat-count" style="margin-left=0px;">82</span>
                            <span class="cat-toggle">▾</span>
                        </div>
                        <div class="cat-level2">
                            <div class="cat-item2" onclick="selectCat(this,'건식 사료')"><div class="cat-item2-dot"></div>건식 사료<span class="cat-count">38</span></div>
                            <div class="cat-item2" onclick="selectCat(this,'습식 사료')"><div class="cat-item2-dot"></div>습식 사료<span class="cat-count">22</span></div>
                        </div>
                    </div>
                    <div class="cat-divider"></div>

                    <%-- 대분류 2 --%>
                    <div class="cat-level1">
                        <div class="cat-item1" onclick="selectCat(this,'간식')">
                            <svg viewBox="0 0 24 24"><rect x="2" y="7" width="20" height="14" rx="2"/><path d="M16 7V5a2 2 0 00-2-2h-4a2 2 0 00-2 2v2"/></svg>
                            간식
                            <span class="cat-count" >64</span>
                            <span class="cat-toggle">▾</span>
                        </div>
                        <div class="cat-level2">
                            <div class="cat-item2" onclick="selectCat(this,'트릿')"><div class="cat-item2-dot"></div>트릿<span class="cat-count">22</span></div>
                            <div class="cat-item2" onclick="selectCat(this,'개껌')"><div class="cat-item2-dot"></div>개껌<span class="cat-count">22</span></div>
                        </div>
                    </div>
                    <div class="cat-divider"></div>

                    <%-- 대분류 3 --%>
                    <div class="cat-level1">
                        <div class="cat-item1" onclick="selectCat(this,'용품')">
                            <svg viewBox="0 0 24 24"><path d="M20.38 3.46L16 2a4 4 0 01-8 0L3.62 3.46a2 2 0 00-1.34 2.23l.58 3.57a1 1 0 00.99.84H6v10c0 1.1.9 2 2 2h8a2 2 0 002-2V10h2.15a1 1 0 00.99-.84l.58-3.57a2 2 0 00-1.34-2.23z"/></svg>
                            용품
                            <span class="cat-count">38</span>
                            <span class="cat-toggle">▾</span>
                        </div>
                        <div class="cat-level2">
                            <div class="cat-item2" onclick="selectCat(this,'하우스 / 침대')"><div class="cat-item2-dot"></div>하우스 / 침대<span class="cat-count">18</span></div>
                            <div class="cat-item2" onclick="selectCat(this,'장난감')"><div class="cat-item2-dot"></div>장난감<span class="cat-count">28</span></div>
                            <div class="cat-item2" onclick="selectCat(this,'목줄 / 하네스')"><div class="cat-item2-dot"></div>목줄 / 하네스<span class="cat-count">18</span></div>
                        </div>
                    </div>
                    <div class="cat-divider"></div>
                </div>
            </div>
        </div>

        <%-- 오른쪽: 편집 폼 + 소분류 테이블 --%>
        <div>
            <%-- 카테고리 편집 폼 --%>
            <div class="cat-form-card" id="cat-form">
                <div class="cat-form-title">
                    <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                    <span id="form-title">카테고리 편집 — 사료 / 간식</span>
                </div>
                <div class="cat-form-row">
                    <div class="cat-form-group">
                        <label>상위 카테고리</label>
                        <select id="parent-cat">
                            <option value="">최상위 (대분류)</option>
                            <option selected>사료 / 간식</option>
                            <option>용품 / 장난감</option>
                            <option>의류 / 패션</option>
                            <option>건강 / 미용</option>
                            <option>여행 / 외출</option>
                        </select>
                    </div>
                    <div class="cat-form-group">
                        <label>정렬 순서</label>
                        <input type="number" value="1" min="1">
                    </div>
                </div>
                <div class="cat-form-group">
                    <label>카테고리명 <span class="req">*</span></label>
                    <input type="text" id="cat-name" value="사료 / 간식" placeholder="카테고리명 입력">
                </div>
                <div class="cat-form-group">
                    <label>설명</label>
                    <input type="text" placeholder="카테고리 간단 설명 (선택)">
                </div>
                <div class="cat-form-row" style="align-items:center;gap:12px">
                    <div class="cat-form-group" style="flex:0;flex-direction:row;align-items:center;gap:8px;margin:0">
                        <label style="margin:0;white-space:nowrap">노출 여부</label>
                        <label class="adm-toggle"><input type="checkbox" checked><span class="adm-toggle-slider"></span></label>
                    </div>
                </div>
                <div class="cat-btn-row">
                    <button class="adm-btn red" onclick="if(confirm('카테고리를 삭제하시겠습니까?'))alert('삭제되었습니다.')">삭제</button>
                    <button class="adm-btn gray" onclick="resetForm()">초기화</button>
                    <button class="adm-btn blue" onclick="alert('저장되었습니다.')">저장</button>
                </div>
            </div>

            <%-- 소분류 목록 --%>
            <div class="cat-table-card">
                <div class="cat-table-head">
                    <span style="font-size:14px;font-weight:700;color:#1A1A2E">
                        사료 / 간식 <span style="font-weight:400;color:#999;font-size:13px">소분류 3개</span>
                    </span>
                    <span class="cat-drag-hint">
                        <svg viewBox="0 0 24 24"><line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/><line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/></svg>
                        드래그로 순서 변경
                    </span>
                </div>
                <table class="adm-table">
                    <thead><tr><th>순서</th><th>카테고리명</th><th>상품 수</th><th>노출</th><th>수정</th></tr></thead>
                    <tbody>
                        <tr>
                            <td><span class="cat-order-badge">1</span></td>
                            <td>건식 사료</td>
                            <td>38개</td>
                            <td><label class="adm-toggle"><input type="checkbox" checked><span class="adm-toggle-slider"></span></label></td>
                            <td><button class="adm-btn blue" onclick="selectCat(null,'건식 사료')">수정</button></td>
                        </tr>
                        <tr>
                            <td><span class="cat-order-badge">2</span></td>
                            <td>습식 사료</td>
                            <td>22개</td>
                            <td><label class="adm-toggle"><input type="checkbox" checked><span class="adm-toggle-slider"></span></label></td>
                            <td><button class="adm-btn blue" onclick="selectCat(null,'습식 사료')">수정</button></td>
                        </tr>
                        <tr>
                            <td><span class="cat-order-badge">3</span></td>
                            <td>간식 / 트릿</td>
                            <td>22개</td>
                            <td><label class="adm-toggle"><input type="checkbox" checked><span class="adm-toggle-slider"></span></label></td>
                            <td><button class="adm-btn blue" onclick="selectCat(null,'간식 / 트릿')">수정</button></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>

<script>
function selectCat(el, name) {
    if(el) {
        document.querySelectorAll('.cat-item1,.cat-item2').forEach(i => i.classList.remove('selected'));
        el.classList.add('selected');
    }
    document.getElementById('form-title').textContent = '카테고리 편집 — ' + name;
    document.getElementById('cat-name').value = name;
}
function showAddForm() {
    document.getElementById('form-title').textContent = '새 카테고리 추가';
    document.getElementById('cat-name').value = '';
}
function resetForm() {
    document.getElementById('cat-name').value = '';
}
</script>

<%@ include file="/WEB-INF/views/admin/common/footer.jsp" %>
