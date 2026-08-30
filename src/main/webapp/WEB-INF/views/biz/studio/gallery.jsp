<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath"  value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="애완동물 사진관" />
<c:set var="bizPage"      value="gallery" />
<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_studio.jsp" %>
<main class="biz-main">
    <div class="biz-page-head">
        <h1 class="biz-page-title">포트폴리오 갤러리</h1>
    </div>
    
<style>
.gal-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:14px}
.gal-item{position:relative;border-radius:10px;overflow:hidden;aspect-ratio:1/1;cursor:pointer}
.gal-item img{width:100%;height:100%;object-fit:cover;display:block;transition:transform .3s}
.gal-item:hover img{transform:scale(1.05)}
.gal-overlay{position:absolute;inset:0;background:rgba(0,0,0,.45);opacity:0;transition:opacity .2s;display:flex;align-items:center;justify-content:center;gap:8px}
.gal-item:hover .gal-overlay{opacity:1}
.gal-overlay button{padding:6px 14px;border:1px solid #fff;border-radius:20px;background:transparent;color:#fff;font-size:12px;font-weight:600;cursor:pointer}
.gal-add{border:2px dashed var(--biz-border);border-radius:10px;aspect-ratio:1/1;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:8px;cursor:pointer;transition:all .15s;color:#999}
.gal-add:hover{border-color:var(--biz-primary);color:var(--biz-primary);background:#F0FAF6}
.gal-add svg{width:28px;height:28px;stroke:currentColor;fill:none;stroke-width:1.6;stroke-linecap:round;stroke-linejoin:round}
</style>
<div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:18px">
  <span style="font-size:14px;color:#555">총 <strong>24</strong>장의 작품이 등록되어 있습니다.</span>
  <select class="biz-filter-select"><option>최신순</option><option>강아지</option><option>고양이</option></select>
</div>
<div class="gal-grid">
  <div class="gal-item">
    <img src="https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=400&q=70&auto=format&fit=crop" alt="작품" onerror="this.src='https://placehold.co/400x400/F3E8FF/9333EA?text=사진'">
    <div class="gal-overlay"><button>대표 설정</button><button>삭제</button></div>
  </div>
  <div class="gal-item">
    <img src="https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400&q=70&auto=format&fit=crop" alt="작품" onerror="this.src='https://placehold.co/400x400/F3E8FF/9333EA?text=사진'">
    <div class="gal-overlay"><button>대표 설정</button><button>삭제</button></div>
  </div>
  <div class="gal-item">
    <img src="https://images.unsplash.com/photo-1552053831-71594a27632d?w=400&q=70&auto=format&fit=crop" alt="작품" onerror="this.src='https://placehold.co/400x400/F3E8FF/9333EA?text=사진'">
    <div class="gal-overlay"><button>대표 설정</button><button>삭제</button></div>
  </div>
  <div class="gal-item">
    <img src="https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=400&q=70&auto=format&fit=crop" alt="작품" onerror="this.src='https://placehold.co/400x400/F3E8FF/9333EA?text=사진'">
    <div class="gal-overlay"><button>대표 설정</button><button>삭제</button></div>
  </div>
  <div class="gal-add" onclick="alert('사진 업로드')">
    <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
    <span style="font-size:13px;font-weight:600">사진 추가</span>
  </div>
</div>

</main>
<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>
