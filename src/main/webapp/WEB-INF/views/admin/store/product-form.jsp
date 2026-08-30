<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="adminPage"   value="product-list" />
<c:set var="isEdit" value="${param.mode eq 'edit'}" />
<%@ include file="/WEB-INF/views/admin/common/header.jsp" %>
<%@ include file="/WEB-INF/views/admin/common/sidebar.jsp" %>

<style>
.pf-breadcrumb{font-size:13px;color:#999;margin-bottom:20px;display:flex;align-items:center;gap:8px}
.pf-breadcrumb a{color:#999;text-decoration:none}
.pf-breadcrumb a:hover{color:#3B5BDB}
.pf-form-card{background:#fff;border:1px solid #E4E6ED;border-radius:12px;padding:28px;margin-bottom:20px}
.pf-section-title{font-size:15px;font-weight:800;color:#1A1A2E;margin:0 0 20px;padding-bottom:14px;border-bottom:1px solid #E4E6ED}
.pf-grid{display:grid;grid-template-columns:1fr 1fr;gap:16px 20px}
.pf-field{display:flex;flex-direction:column;gap:6px}
.pf-field.full{grid-column:1/-1}
.pf-field label{font-size:13px;font-weight:600;color:#555}
.pf-field label .req{color:#DC2626;margin-left:2px}
.pf-field input,.pf-field select,.pf-field textarea{
    border:1px solid #E4E6ED;border-radius:8px;padding:10px 14px;
    font-size:14px;color:#1A1A2E;outline:none;font-family:inherit;
}
.pf-field input:focus,.pf-field select:focus,.pf-field textarea:focus{border-color:#3B5BDB}
.pf-field textarea{min-height:120px;resize:vertical}
.pf-img-preview{width:120px;height:120px;border:1px dashed #E4E6ED;border-radius:10px;overflow:hidden;display:flex;align-items:center;justify-content:center;background:#FAFBFC}
.pf-img-preview img{width:100%;height:100%;object-fit:cover}
.pf-img-row{display:flex;gap:16px;align-items:flex-start}
.pf-actions{display:flex;gap:10px;justify-content:flex-end;padding-top:8px}
@media(max-width:768px){.pf-grid{grid-template-columns:1fr}}
</style>

<main class="adm-main">
    <div class="pf-breadcrumb">
        <a href="${contextPath}/admin/store/product-list">상품 관리</a>
        <span>›</span>
        <span style="color:#1A1A2E;font-weight:600">${isEdit ? '상품 수정' : '상품 등록'}</span>
    </div>

    <div class="adm-page-head">
        <div class="adm-page-head-left">
            <h1 class="adm-page-title">${isEdit ? '상품 수정' : '상품 등록'}</h1>
            <p class="adm-page-desc">${isEdit ? '상품 정보를 수정합니다.' : '새 상품을 등록합니다.'}</p>
        </div>
    </div>

    <form id="productForm" onsubmit="return false;">
        <div class="pf-form-card">
            <h3 class="pf-section-title">기본 정보</h3>
            <div class="pf-grid">
                <div class="pf-field full">
                    <label>상품명 <span class="req">*</span></label>
                    <input type="text" name="productName" placeholder="상품명을 입력하세요"
                           value="${isEdit ? '노즈워크 매트 오렌지' : ''}">
                </div>
                <div class="pf-field">
                    <label>카테고리 <span class="req">*</span></label>
                    <select name="category">
                        <option value="">선택</option>
                        <option ${isEdit ? 'selected' : ''}>사료/간식</option>
                        <option>용품/장난감</option>
                        <option>의류/패션</option>
                        <option>건강/미용</option>
                    </select>
                </div>
                <div class="pf-field">
                    <label>판매 사업자 <span class="req">*</span></label>
                    <select name="bizId">
                        <option value="">선택</option>
                        <option ${isEdit ? 'selected' : ''}>펫마켓스토어</option>
                        <option>펫프렌즈</option>
                        <option>댕댕마트</option>
                    </select>
                </div>
                <div class="pf-field">
                    <label>판매가 (원) <span class="req">*</span></label>
                    <input type="number" name="price" placeholder="0" value="${isEdit ? '18500' : ''}">
                </div>
                <div class="pf-field">
                    <label>재고 수량 <span class="req">*</span></label>
                    <input type="number" name="stock" placeholder="0" value="${isEdit ? '88' : ''}">
                </div>
                <div class="pf-field">
                    <label>판매 상태</label>
                    <select name="saleStatus">
                        <option ${isEdit ? 'selected' : ''}>판매중</option>
                        <option>품절</option>
                        <option>판매중지</option>
                    </select>
                </div>
                <div class="pf-field">
                    <label>승인 상태</label>
                    <select name="approveStatus">
                        <option>승인 대기</option>
                        <option ${isEdit ? 'selected' : ''}>승인</option>
                        <option>반려</option>
                    </select>
                </div>
            </div>
        </div>

        <div class="pf-form-card">
            <h3 class="pf-section-title">상품 이미지</h3>
            <div class="pf-img-row">
                <div class="pf-img-preview" id="imgPreview">
                    <c:choose>
                    <c:when test="${isEdit}">
                        <img src="https://images.unsplash.com/photo-1583337130417-3346a1be7dee?w=200&q=70&auto=format&fit=crop" alt="상품">
                    </c:when>
                    <c:otherwise>
                        <span style="font-size:12px;color:#999">미리보기</span>
                    </c:otherwise>
                    </c:choose>
                </div>
                <div class="pf-field" style="flex:1">
                    <label>대표 이미지</label>
                    <input type="file" accept="image/*" id="productImage">
                    <p style="font-size:12px;color:#999;margin-top:6px">JPG, PNG · 최대 5MB</p>
                </div>
            </div>
        </div>

        <div class="pf-form-card">
            <h3 class="pf-section-title">상품 상세</h3>
            <div class="pf-field">
                <label>상품 설명</label>
                <textarea name="description" placeholder="상품 상세 설명을 입력하세요">${isEdit ? '반려견의 후각 자극을 돕는 노즈워크 매트입니다. 오렌지 컬러로 집안 인테리어와도 잘 어울립니다.' : ''}</textarea>
            </div>
        </div>

        <div class="pf-actions">
            <a href="${contextPath}/admin/store/product-list" class="adm-btn gray" style="padding:10px 24px;text-decoration:none">취소</a>
            <button type="button" class="adm-btn blue" style="padding:10px 24px"
                    onclick="alert('${isEdit ? '수정' : '등록'} 처리되었습니다.'); location.href='${contextPath}/admin/store/product-list'">
                ${isEdit ? '수정 완료' : '등록하기'}
            </button>
        </div>
    </form>
</main>

<script>
document.getElementById('productImage').addEventListener('change', function() {
    if (!this.files || !this.files[0]) return;
    var reader = new FileReader();
    reader.onload = function(e) {
        document.getElementById('imgPreview').innerHTML = '<img src="' + e.target.result + '" alt="미리보기">';
    };
    reader.readAsDataURL(this.files[0]);
});
</script>

<%@ include file="/WEB-INF/views/admin/common/footer.jsp" %>
