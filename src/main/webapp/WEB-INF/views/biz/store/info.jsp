<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="반려동물 쇼핑몰" />
<c:set var="bizPage"      value="info" />

<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_store.jsp" %>

<%-- 7/3, 사업자(쇼핑몰) 사업자 정보 UI 구성 — 매장 자체 정보와 별개로,
     사업자 등록 정보(대표자명/사업자등록번호/업종/사업장 주소·전화번호/사업자등록증)를 관리하는 화면 --%>
<main class="biz-main">
  <div class="biz-page-head">
    <h1 class="biz-page-title">사업자 정보 등록</h1>
    <p class="biz-page-desc">사업자 등록 정보를 확인하고 수정하세요.</p>
  </div>

  <div class="biz-card">
    <div class="biz-card-head"><span>사업자 정보</span><small>* 표시 항목은 필수 입력입니다</small></div>

    <form id="bizInfoForm" method="post" action="${contextPath}/biz/store/info" enctype="multipart/form-data" style="padding:20px;max-width:640px">
      <!--HYJ 26.08.05-->
      <input type="hidden" name="_csrf" value="${_csrf}">      
      
      <div class="biz-form-fields">
        <div class="biz-form-row">
          <label>상호명<span class="req">*</span></label>
          <input type="text" id="bShopName" name="shopName" value="${info.shopName}" placeholder="상호명을 입력하세요">
        </div>
        <div class="biz-form-row">
          <label>대표자 명<span class="req">*</span></label>
          <input type="text" id="bOwner" name="ceoName" value="${info.ceoName}" placeholder="대표자 명을 입력하세요">
        </div>
        <div class="biz-form-row">
          <label>사업자 등록번호<span class="req">*</span></label>
          <input type="text" id="bRegNo" name="bizRegNo" value="${info.bizRegNo}" placeholder="000-00-00000">
        </div>
        <div class="biz-form-row">
          <label>업종</label>
          <input type="text" value="${info.bizType == 'STAY' ? '반려동물 숙박업' : info.bizType == 'HOSPITAL' ? '동물병원' : '반려용품 판매업'}" readonly style="background:#FAFBFA">
          <small style="color:#E2445C;font-size:12px;margin-top:4px;display:block;font-weight:600">⚠ 업종 변경은 고객센터로 문의해주세요.</small>
        </div>

        <div class="biz-form-row">
          <label>사업장 주소<span class="req">*</span></label>
          <input type="text" id="bAddress" name="addr" value="${info.addr}" placeholder="사업장 주소를 입력하세요">
        </div>
        <div class="biz-form-row">
          <label>상세 주소</label>
          <input type="text" id="bAddressDetail" name="addrDetail" value="${info.addrDetail}" placeholder="상세 주소를 입력하세요">
        </div>
        <div class="biz-form-row">
          <label>사업장 전화번호<span class="req">*</span></label>
          <input type="tel" id="bPhone" name="phone" value="${info.phone}" placeholder="예) 02-000-0000">
        </div>
        <div class="biz-form-row">
          <label>사업자 등록증 첨부</label>
          <div style="display:flex;gap:10px;align-items:center">
            <input type="text" id="bFileName" value="${not empty info.certFileName ? info.certFileName : '등록된 파일 없음'}" readonly style="flex:1;background:#FAFBFA">
            <c:if test="${not empty info.certFileUrl}">
              <a href="${contextPath}/upload/${info.certFileUrl}" target="_blank" class="biz-btn-ghost" style="white-space:nowrap;text-decoration:none;display:inline-flex;align-items:center">보기</a>
            </c:if>
            <button type="button" class="biz-btn-ghost" style="white-space:nowrap" onclick="document.getElementById('bFile').click()">파일선택</button>
            <input type="file" id="bFile" name="certFile" accept="image/*,.pdf" style="display:none">
          </div>
        </div>
      </div>

      <div class="biz-form-actions" style="margin-top:20px">
        <button type="button" class="biz-btn-primary" onclick="saveInfo()">저장</button>
      </div>
    </form>
  </div>
</main>

<div class="biz-toast" id="saveToast">
  <svg viewBox="0 0 24 24" fill="none" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
  사업자 정보가 저장되었습니다.
</div>

<script>
  //지윤 26.07.23 추가: 저장 후 리다이렉트됐을 때 flash 메시지 있으면 토스트 자동으로 띄움
  <c:if test="${not empty msg}">
    window.addEventListener('DOMContentLoaded', function () {
      var toast = document.getElementById('saveToast');
      toast.classList.add('on');
      setTimeout(function () { toast.classList.remove('on'); }, 2200);
    });
  </c:if>

  document.getElementById('bFile').addEventListener('change', function (e) {
    var file = e.target.files[0];
    if (!file) return;
    document.getElementById('bFileName').value = file.name;
  });

  function saveInfo() {
    var required = [
      { id: 'bOwner',   label: '대표자 명' },
      { id: 'bShopName', label: '상호명' },
      { id: 'bRegNo',   label: '사업자 등록번호' },
      { id: 'bAddress', label: '사업장 주소' },
      { id: 'bPhone',   label: '사업장 전화번호' }
    ];
    for (var i = 0; i < required.length; i++) {
      var el = document.getElementById(required[i].id);
      if (!el.value.trim()) {
        alert(required[i].label + '을(를) 입력해주세요.');
        el.focus();
        return;
      }
    }
    document.getElementById('bizInfoForm').submit();
  }
</script>

<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>