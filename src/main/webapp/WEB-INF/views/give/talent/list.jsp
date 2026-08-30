<%--
  역할: 사용자 재능나눔 목록 (give/talent/list)
  - give/index.jsp 에서 include (가족찾기 > 재능나눔 탭)

  - 박유정 / 2026-07-13~14

  [화면 흐름]
  1. GET /give/talent/list?talentType=...
  2. ${list} — TB_TALENT STATUS_CD=APPROVED (관리자 승인 후 노출)
  3. 카드 클릭 → /give/talent/detail?id=
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId"      value="give" />
<c:set var="giveTab"     value="talent" />

<%@ include file="/WEB-INF/views/give/index.jsp" %>

<div class="give-content">

<style>
    .talent-toolbar { display:flex; justify-content:space-between; align-items:center; margin-bottom:20px; flex-wrap:wrap; gap:12px; }
    .talent-filters { display:flex; gap:8px; flex-wrap:wrap; }
    .talent-chip {
        padding:7px 16px; border:1px solid var(--border); border-radius:50px;
        font-size:13px; color:var(--text-sub); background:#fff; cursor:pointer; transition:var(--transition);
    }
    .talent-chip:hover,.talent-chip.on { border-color:var(--primary); background:var(--primary-light); color:var(--primary-dark); font-weight:600; }
    .btn-talent-write {
        padding:9px 20px; border:none; border-radius:50px;
        background:var(--primary); color:#fff; font-size:14px; font-weight:700;
        cursor:pointer; display:flex; align-items:center; gap:6px;
    }
    .btn-talent-write svg { width:14px; height:14px; stroke:#fff; fill:none; stroke-width:2.5; stroke-linecap:round; stroke-linejoin:round; }

    /* 재능나눔 카드 — 가로형 */
    .talent-list { display:flex; flex-direction:column; gap:16px; margin-bottom:32px; }
    .talent-card {
        background:var(--bg-card); border:1px solid var(--border);
        border-radius:var(--radius-md); padding:22px;
        display:flex; gap:20px; align-items:flex-start;
        transition:var(--transition); cursor:pointer;
    }
    .talent-card:hover { box-shadow:var(--shadow-md); transform:translateY(-1px); }
    .talent-icon {
        width:60px; height:60px; border-radius:var(--radius-md);
        display:flex; align-items:center; justify-content:center; flex-shrink:0;
    }
    .talent-icon svg { width:28px; height:28px; fill:none; stroke-width:1.8; stroke-linecap:round; stroke-linejoin:round; }
    .ti-grooming  { background:#FDF2F8; } .ti-grooming svg  { stroke:#DB2777; }
    .ti-hospital  { background:#E0F2FE; } .ti-hospital svg  { stroke:#0284C7; }
    .ti-photo     { background:#F3E8FF; } .ti-photo svg     { stroke:#9333EA; }
    .ti-transport { background:#FFF7ED; } .ti-transport svg { stroke:#EA580C; }
    .ti-edu       { background:#DCFCE7; } .ti-edu svg       { stroke:#16A34A; }

    .talent-body { flex:1; min-width:0; }
    .talent-tags { display:flex; gap:6px; flex-wrap:wrap; margin-bottom:8px; }
    .talent-tag  { font-size:11px; font-weight:700; padding:3px 9px; border-radius:20px; }
    .tt-grooming { background:#FDF2F8; color:#DB2777; }
    .tt-hospital { background:#E0F2FE; color:#0284C7; }
    .tt-photo    { background:#F3E8FF; color:#9333EA; }
    .tt-transport{ background:#FFF7ED; color:#EA580C; }
    .tt-edu      { background:#DCFCE7; color:#16A34A; }
    .tt-new      { background:#FFF8E1; color:#F59E0B; }

    .talent-title { font-size:16px; font-weight:700; color:var(--text-main); margin-bottom:6px; }
    .talent-desc  { font-size:13px; color:var(--text-muted); line-height:1.6; margin-bottom:10px; display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden; }
    .talent-meta-row { display:flex; gap:16px; flex-wrap:wrap; font-size:13px; color:var(--text-muted); }
    .talent-meta-item { display:flex; align-items:center; gap:5px; }
    .talent-meta-item svg { width:13px; height:13px; stroke:currentColor; fill:none; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; }

    .talent-right { display:flex; flex-direction:column; align-items:flex-end; gap:10px; flex-shrink:0; min-width:140px; }
    .talent-provider { text-align:right; }
    .talent-provider .prov-name { font-size:13px; font-weight:700; color:var(--text-main); }
    .talent-provider .prov-type { font-size:11px; color:var(--text-muted); margin-top:2px; }
    .talent-progress { width:100%; }
    .talent-prog-label { display:flex; justify-content:space-between; font-size:11px; color:var(--text-muted); margin-bottom:4px; }
    .talent-prog-bar   { height:5px; background:var(--border); border-radius:3px; overflow:hidden; }
    .talent-prog-fill  { height:100%; background:var(--primary); border-radius:3px; }
    .talent-apply-btn {
        padding:9px 20px; border:none; border-radius:var(--radius-sm);
        background:var(--primary); color:#fff; font-size:13px; font-weight:700;
        cursor:pointer; transition:var(--transition); white-space:nowrap; width:100%;
    }
    .talent-apply-btn:hover { background:var(--primary-dark); }
    .talent-apply-btn:disabled { background:var(--border); color:var(--text-muted); cursor:not-allowed; }

    /* 사업자 재능나눔 배너 */
    .talent-biz-banner {
        background: linear-gradient(135deg, #1F8464 0%, #2BAB82 100%);
        border-radius:var(--radius-md); padding:24px 28px;
        display:flex; align-items:center; gap:20px;
        margin-bottom:28px; color:#fff;
    }
    .talent-biz-banner svg { width:40px; height:40px; stroke:#fff; fill:none; stroke-width:1.6; stroke-linecap:round; stroke-linejoin:round; flex-shrink:0; }
    .tbz-text h3 { font-size:17px; font-weight:800; margin:0 0 4px; }
    .tbz-text p  { font-size:13px; opacity:.85; margin:0; }
    .btn-biz-talent {
        margin-left:auto; padding:10px 22px; border:2px solid #fff;
        border-radius:50px; background:transparent; color:#fff;
        font-size:14px; font-weight:700; cursor:pointer; flex-shrink:0;
        transition:var(--transition); white-space:nowrap;
    }
    .btn-biz-talent:hover { background:#fff; color:var(--primary-dark); }

    .tt-recruit-open  { background:#DCFCE7; color:#16A34A; }
    .tt-recruit-closed{ background:#F3F4F6; color:#6B7280; }
</style>

    <%-- 사업자 재능나눔 유도 배너 --%>
    <div class="talent-biz-banner">
        <svg viewBox="0 0 24 24"><path d="M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78L12 21.23l8.84-8.84a5.5 5.5 0 000-7.78z"/></svg>
        <div class="tbz-text">
            <h3>사업자 파트너 재능나눔 참여</h3>
            <p>애견미용사·수의사·사진작가 등 전문 기술로 유기동물을 도와주세요.<br>사업자센터에서 재능나눔을 신청하고 브랜드 가치도 높여보세요!</p>
        </div>
        <button class="btn-biz-talent" onclick="location.href='${contextPath}/mypage/biz'">사업자센터에서 신청</button>
    </div>

    <div class="talent-toolbar">
    <div class="talent-filters">
        <c:url var="urlAll" value="/give/talent/list"/>
        <c:url var="urlGrooming" value="/give/talent/list">
            <c:param name="talentType" value="GROOMING"/>
        </c:url>
        <c:url var="urlHospital" value="/give/talent/list">
            <c:param name="talentType" value="HOSPITAL"/>
        </c:url>
        <c:url var="urlPhoto" value="/give/talent/list">
            <c:param name="talentType" value="PHOTO"/>
        </c:url>
        <c:url var="urlTransport" value="/give/talent/list">
            <c:param name="talentType" value="TRANSPORT"/>
        </c:url>
        <c:url var="urlEtc" value="/give/talent/list">
            <c:param name="talentType" value="ETC"/>
        </c:url>

        <a href="${contextPath}${urlAll}"
           class="talent-chip ${empty talentType ? 'on' : ''}">전체</a>
        <a href="${contextPath}${urlGrooming}"
           class="talent-chip ${talentType eq 'GROOMING' ? 'on' : ''}">애견미용</a>
        <a href="${contextPath}${urlHospital}"
           class="talent-chip ${talentType eq 'HOSPITAL' ? 'on' : ''}">병원/건강</a>
        <a href="${contextPath}${urlPhoto}"
           class="talent-chip ${talentType eq 'PHOTO' ? 'on' : ''}">사진 촬영</a>
        <a href="${contextPath}${urlTransport}"
           class="talent-chip ${talentType eq 'TRANSPORT' ? 'on' : ''}">운송 도움</a>
        <a href="${contextPath}${urlEtc}"
           class="talent-chip ${talentType eq 'ETC' ? 'on' : ''}">기타</a>
    </div>
</div>

    <div class="talent-list">

  <c:choose>
    <c:when test="${empty list}">
      <p style="text-align:center;color:var(--text-muted);padding:48px 0">
        등록된 재능나눔이 없습니다.
      </p>
    </c:when>
    <c:otherwise>
      <c:forEach var="item" items="${list}">

        <%-- 카드 1개 = forEach 1바퀴 --%>
        <div class="talent-card"
             onclick="location.href='${contextPath}/give/talent/detail?id=${item.talentId}'">

          <%-- 아이콘 (talentType별) --%>
          <c:choose>
            <c:when test="${item.talentType eq 'GROOMING'}">
              <div class="talent-icon ti-grooming">
                <svg viewBox="0 0 24 24"><path d="M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78L12 21.23l8.84-8.84a5.5 5.5 0 000-7.78z"/></svg>
              </div>
            </c:when>
            <c:when test="${item.talentType eq 'HOSPITAL'}">
              <div class="talent-icon ti-hospital">
                <svg viewBox="0 0 24 24"><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></svg>
              </div>
            </c:when>
            <c:when test="${item.talentType eq 'PHOTO'}">
              <div class="talent-icon ti-photo">
                <svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="12" cy="10" r="3"/><path d="M8.5 21l7-9-7 9z"/></svg>
              </div>
            </c:when>
            <c:when test="${item.talentType eq 'TRANSPORT'}">
              <div class="talent-icon ti-transport">
                <svg viewBox="0 0 24 24"><rect x="1" y="3" width="15" height="13"/><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"/><circle cx="5.5" cy="18.5" r="2.5"/><circle cx="18.5" cy="18.5" r="2.5"/></svg>
              </div>
            </c:when>
            <c:otherwise>
              <div class="talent-icon ti-edu">
                <svg viewBox="0 0 24 24"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c0 2 2 3 6 3s6-1 6-3v-5"/></svg>
              </div>
            </c:otherwise>
          </c:choose>

          <div class="talent-body">
            <div class="talent-tags">
              <c:if test="${item.talentType eq 'GROOMING'}">
                <span class="talent-tag tt-grooming">애견미용</span>
              </c:if>
              <c:if test="${item.talentType eq 'HOSPITAL'}">
                <span class="talent-tag tt-hospital">병원</span>
              </c:if>
              <c:if test="${item.talentType eq 'PHOTO'}">
                <span class="talent-tag tt-photo">사진 촬영</span>
              </c:if>
              <c:if test="${item.talentType eq 'TRANSPORT'}">
                <span class="talent-tag tt-transport">운송</span>
              </c:if>
              <c:if test="${item.talentType eq 'ETC'}">
                <span class="talent-tag tt-edu">기타</span>
              </c:if>
              <span class="talent-tag tt-new">사업자 제공</span>

        <%-- 2026-08-10 박유정 — 모집중/모집마감 뱃지 --%>
        <c:choose>
         <c:when test="${item.statusCd eq 'APPROVED' && item.capacity != null && item.currentCnt != null && item.currentCnt < item.capacity}">
           <span class="talent-tag tt-recruit-open">모집중</span>
          </c:when>
          <c:otherwise>
            <span class="talent-tag tt-recruit-closed">모집마감</span>
         </c:otherwise>
        </c:choose>
            </div>

            <div class="talent-title">${item.title}</div>
            <div class="talent-desc">${item.body}</div>

            <div class="talent-meta-row">
              <div class="talent-meta-item">
                <svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                ${item.schedule}
              </div>
              <div class="talent-meta-item">
                <svg viewBox="0 0 24 24"><path d="M21 10c0 7-9 13-9 13S3 17 3 10a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/></svg>
                ${item.location}
              </div>
              <div class="talent-meta-item">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                ${item.duration}
              </div>
            </div>
          </div>

          <div class="talent-right">
            <div class="talent-provider">
              <div class="prov-name">${item.bizName}</div>
              <div class="prov-type">${item.bizType} · 사업자 파트너</div>
            </div>
            <div class="talent-progress">
              <div class="talent-prog-label">
                <span>신청 현황</span>
                <span>${item.currentCnt} / ${item.capacity}</span>
              </div>
              <div class="talent-prog-bar">
                <c:set var="progPct" value="0"/>
                <c:if test="${item.capacity != null && item.capacity > 0}">
                  <c:set var="progPct" value="${item.currentCnt * 100 / item.capacity}"/>
                </c:if>
                <div class="talent-prog-fill" style="width:${progPct}%"></div>
              </div>
            </div>
            <button class="talent-apply-btn"
                    onclick="event.stopPropagation();location.href='${contextPath}/give/talent/detail?id=${item.talentId}'">
              상세보기
            </button>
          </div>
        </div>

      </c:forEach>
    </c:otherwise>
  </c:choose>

</div>

</div><%-- .give-content --%>
<%@ include file="/WEB-INF/views/common/footer.jsp" %>
