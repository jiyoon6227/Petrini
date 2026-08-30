<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:if test="${empty contextPath}"><c:set var="contextPath" value="${pageContext.request.contextPath}" /></c:if>
<c:if test="${empty pageId}"><c:set var="pageId" value="community" /></c:if>

<%@ include file="/WEB-INF/views/common/header.jsp" %>
<style>
  .comm-hero{background:linear-gradient(135deg,#0F766E 0%,#14B8A6 60%,#5EEAD4 100%);padding:40px 0;color:#fff;text-align:center}
  .comm-hero-inner{max-width:var(--inner-width);margin:0 auto;padding:0 20px}
  .comm-hero h1{font-size:28px;font-weight:800;margin:0 0 8px}
  .comm-hero p{font-size:14px;opacity:.85;margin:0}
  .comm-wrap{max-width:var(--inner-width);margin:32px auto 80px;padding:0 20px}
  .comm-tabs{display:flex;gap:0;border-bottom:2px solid var(--border);margin-bottom:24px;flex-wrap:wrap}
  .comm-tab{padding:12px 24px;font-size:15px;font-weight:600;color:var(--text-muted);border:none;background:none;cursor:pointer;border-bottom:2px solid transparent;margin-bottom:-2px;transition:var(--transition);text-decoration:none;display:inline-block}
  .comm-tab.on{color:var(--primary);border-bottom-color:var(--primary)}
  .comm-tab:hover{color:var(--primary)}
  .comm-toolbar{display:flex;justify-content:space-between;align-items:center;margin-bottom:18px}
  .comm-search{display:flex;gap:8px}
  .comm-search input{border:1px solid var(--border);border-radius:50px;padding:9px 18px;font-size:14px;outline:none;width:240px}
  .comm-search input:focus{border-color:var(--primary)}
  .comm-search button{padding:9px 18px;border:none;border-radius:50px;background:var(--primary);color:#fff;font-size:14px;font-weight:600;cursor:pointer}
  .btn-write{padding:9px 20px;border:none;border-radius:50px;background:var(--primary);color:#fff;font-size:14px;font-weight:700;cursor:pointer;display:flex;align-items:center;gap:6px}
  .btn-write svg{width:14px;height:14px;stroke:#fff;fill:none;stroke-width:2.5;stroke-linecap:round;stroke-linejoin:round}
  .comm-card{display:flex;gap:16px;background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);padding:18px;margin-bottom:12px;transition:var(--transition);cursor:pointer}
  .comm-card:hover{box-shadow:var(--shadow-sm);transform:translateY(-1px)}
  .comm-thumb{width:96px;height:96px;border-radius:var(--radius-sm);object-fit:cover;flex-shrink:0}
  .comm-body{flex:1;min-width:0;display:flex;flex-direction:column;justify-content:space-between}
  .comm-category{font-size:11px;font-weight:700;padding:2px 8px;border-radius:20px;display:inline-block;margin-bottom:6px}
  .cat-town{background:#FFF8E1;color:#F59E0B}
  .cat-lost{background:#FEE2E2;color:#DC2626}
  .cat-share{background:#DCFCE7;color:#16A34A}
  .cat-life{background:var(--primary-light);color:var(--primary-dark)}
  .comm-title{font-size:15px;font-weight:700;color:var(--text-main);margin-bottom:6px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
  .comm-preview{font-size:13px;color:var(--text-muted);margin-bottom:10px;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden}
  .comm-meta{display:flex;align-items:center;gap:12px;font-size:12px;color:var(--text-muted)}
  .comm-meta-item{display:flex;align-items:center;gap:4px}
  .comm-meta-item svg{width:13px;height:13px;stroke:currentColor;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round}
  .vet-tab{color:#0284C7 !important}
  .vet-tab.on{border-bottom-color:#0284C7 !important;color:#0284C7 !important}
  .vet-banner{background:linear-gradient(135deg,#EFF6FF,#DBEAFE);border:1px solid #BFDBFE;border-radius:var(--radius-md);padding:20px 24px;display:flex;align-items:center;gap:16px;margin-bottom:20px}
  .vet-banner-icon{width:48px;height:48px;border-radius:50%;background:#0284C7;display:flex;align-items:center;justify-content:center;flex-shrink:0}
  .vet-banner-icon svg{width:24px;height:24px;stroke:#fff}
  .vet-banner-title{font-size:16px;font-weight:800;color:#1E40AF;margin-bottom:2px}
  .vet-banner-desc{font-size:13px;color:#3B82F6}
  .vet-banner-desc strong{color:#1D4ED8}
  .btn-vet-ask{margin-left:auto;flex-shrink:0;padding:10px 18px;border:none;border-radius:50px;background:#0284C7;color:#fff;font-size:14px;font-weight:700;cursor:pointer;display:flex;align-items:center;gap:6px;white-space:nowrap}
  .btn-vet-ask svg{width:14px;height:14px}
  .btn-vet-ask:hover{background:#0369A1}
  .vet-ask-form{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);padding:24px;margin-bottom:20px}
  .vet-ask-title{font-size:16px;font-weight:800;color:var(--text-main);margin-bottom:20px;padding-bottom:14px;border-bottom:1px solid var(--border)}
  .vet-form-row{margin-bottom:14px}
  .vet-form-row label{display:block;font-size:13px;font-weight:600;color:var(--text-sub);margin-bottom:6px}
  .req{color:#FF6B6B}
  .vet-form-grid{display:grid;grid-template-columns:1fr 1fr;gap:14px}
  .vet-input{width:100%;border:1px solid var(--border);border-radius:var(--radius-sm);padding:10px 14px;font-size:14px;outline:none;font-family:inherit;box-sizing:border-box;transition:border-color .15s}
  .vet-input:focus{border-color:#0284C7}
  .vet-textarea{width:100%;border:1px solid var(--border);border-radius:var(--radius-sm);padding:12px 14px;font-size:14px;outline:none;font-family:inherit;box-sizing:border-box;min-height:120px;resize:vertical;line-height:1.6}
  .vet-textarea:focus{border-color:#0284C7}
  .vet-radio-label{display:flex;align-items:center;gap:6px;font-size:14px;color:var(--text-sub);cursor:pointer;padding:8px 16px;border:1px solid var(--border);border-radius:50px}
  .vet-upload-box{border:2px dashed var(--border);border-radius:var(--radius-sm);padding:20px;text-align:center;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:8px;color:var(--text-muted);font-size:13px}
  .vet-upload-box svg{width:20px;height:20px;stroke:currentColor;fill:none;stroke-width:1.6;stroke-linecap:round;stroke-linejoin:round}
  .vet-upload-box:hover{border-color:#0284C7;color:#0284C7}
  .vet-btn-cancel{padding:10px 24px;border:1px solid var(--border);border-radius:var(--radius-sm);background:#fff;color:var(--text-sub);font-size:14px;font-weight:600;cursor:pointer}
  .vet-btn-submit{padding:10px 24px;border:none;border-radius:var(--radius-sm);background:#0284C7;color:#fff;font-size:14px;font-weight:700;cursor:pointer}
  .vet-btn-submit:hover{background:#0369A1}
  .vet-card{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);padding:20px;margin-bottom:12px;transition:var(--transition)}
  .vet-card:hover{box-shadow:var(--shadow-sm)}
  .vet-card-head{display:flex;justify-content:space-between;align-items:center;margin-bottom:8px}
  .vet-card-badges{display:flex;gap:6px}
  .vet-badge{font-size:11px;font-weight:700;padding:2px 8px;border-radius:20px}
  .vet-badge.dog{background:#FEF3C7;color:#D97706}
  .vet-badge.cat{background:#F3E8FF;color:#9333EA}
  .vet-badge.answered{background:#DCFCE7;color:#16A34A}
  .vet-badge.waiting{background:#FEE2E2;color:#DC2626}
  .vet-card-date{font-size:12px;color:var(--text-muted)}
  .vet-card-title{font-size:15px;font-weight:700;color:var(--text-main);margin-bottom:6px}
  .vet-card-preview{font-size:13px;color:var(--text-muted);margin-bottom:12px;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden}
  .vet-answer{background:#EFF6FF;border:1px solid #BFDBFE;border-radius:var(--radius-sm);padding:14px 16px;margin-bottom:12px}
  .vet-answer-head{display:flex;align-items:center;gap:6px;font-size:12px;font-weight:700;color:#1D4ED8;margin-bottom:6px}
  .vet-answer-head svg{width:14px;height:14px;stroke:#1D4ED8}
  .vet-answer-date{color:#93C5FD;font-weight:400;margin-left:auto}
  .vet-answer-text{font-size:13px;color:#1E40AF;line-height:1.7}
  .vet-card-meta{display:flex;align-items:center;gap:12px;font-size:12px;color:var(--text-muted)}
  .vet-meta-item{display:flex;align-items:center;gap:4px}
  .vet-meta-item svg{width:13px;height:13px;stroke:currentColor;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round}
  .vet-meta-item.like svg{fill:var(--accent);stroke:none}
  .vet-select{border:1px solid var(--border);border-radius:50px;padding:8px 14px;font-size:13px;font-family:inherit;outline:none;cursor:pointer}
</style>

<div class="comm-hero">
  <div class="comm-hero-inner">
    <h1>우리애기 건강 고민, 수의사 선생님이 도와드려요!</h1>
    <p>강아지, 고양이와 함께하는 반려생활, 궁금한점 많으시죠?</p>
  </div>
</div>

<div class="comm-wrap">
  <div style="display:flex;justify-content:space-between;align-items:flex-end;margin-bottom:20px">
    <div>
      <h1 style="font-size:24px;font-weight:800;color:var(--text-main);margin-bottom:4px">커뮤니티</h1>
      <p style="font-size:14px;color:var(--text-muted)">반려동물 이야기를 나눠보세요</p>
    </div>
    <%-- 2026-07-16 박유정 — 수의사상담(LIFE) 탭에서는 글쓰기 숨김 --%>
    <c:if test="${boardType ne 'LIFE'}">
      <button class="btn-write" onclick="location.href='${contextPath}/community/write'"><svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>글쓰기</button>
    </c:if>
  </div>
    <%-- 2026-07-16 박유정 — 재능나눔 탭 제거(give 모듈로 이동), 전체·집사생활·무료나눔·수의사상담 --%>
    <div class="comm-tabs">
        <a href="${contextPath}/community"
           class="comm-tab ${empty boardType ? 'on' : ''}">전체</a>
        <a href="${contextPath}/community?boardType=TOWN"
           class="comm-tab ${boardType eq 'TOWN' ? 'on' : ''}">집사생활</a>
        <a href="${contextPath}/community?boardType=SHARE"
           class="comm-tab ${boardType eq 'SHARE' ? 'on' : ''}">무료나눔</a>
        <a href="${contextPath}/community?boardType=LIFE"
           class="comm-tab vet-tab ${boardType eq 'LIFE' ? 'on' : ''}">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:14px;height:14px;vertical-align:-2px;margin-right:4px"><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></svg>
          수의사 상담
        </a>
  </div>
  <div class="comm-content">
