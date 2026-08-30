<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
  역할: 사용자 재능나눔 상세 (give/talent/detail)

  - 박유정 / 2026-07-13~14
  - 2026-08-10 박유정 — STEP 4: 모집중/마감, 참여 신청 폼
  2. ${talent} — APPROVED(모집중) 또는 DONE(모집마감) 노출
  [화면 흐름]
  1. GET /give/talent/detail?id=번호
  2. ${talent} — APPROVED 글만 노출 (미승인·반려 시 목록 redirect)
--%>

<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<c:set var="pageId"      value="give" />

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>

  .tld-wrap{max-width:900px;margin:32px auto 80px;padding:0 20px;display:grid;grid-template-columns:1fr 300px;gap:28px;align-items:flex-start}

  .tld-back{display:inline-flex;align-items:center;gap:6px;font-size:13px;color:var(--text-muted);text-decoration:none;margin-bottom:20px;transition:var(--transition)}

  .tld-back:hover{color:var(--primary)}

  .tld-back svg{width:14px;height:14px;stroke:currentColor;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}

  .tld-header{display:flex;gap:18px;align-items:flex-start;margin-bottom:22px}

  .tld-icon{width:72px;height:72px;border-radius:var(--radius-md);display:flex;align-items:center;justify-content:center;flex-shrink:0}

  .tld-icon svg{width:34px;height:34px;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round}

  .ti-grooming{background:#FDF2F8}.ti-grooming svg{stroke:#DB2777}

  .ti-hospital{background:#E0F2FE}.ti-hospital svg{stroke:#0284C7}

  .ti-photo{background:#F3E8FF}.ti-photo svg{stroke:#9333EA}

  .ti-transport{background:#FFF7ED}.ti-transport svg{stroke:#EA580C}

  .ti-edu{background:#DCFCE7}.ti-edu svg{stroke:#16A34A}

  .tld-header-info{}

  .tld-tags{display:flex;gap:6px;flex-wrap:wrap;margin-bottom:8px}

  .tld-tag{font-size:12px;font-weight:700;padding:3px 10px;border-radius:20px}

  .tlt-grooming{background:#FDF2F8;color:#DB2777}

  .tlt-hospital{background:#E0F2FE;color:#0284C7}

  .tlt-photo{background:#F3E8FF;color:#9333EA}

  .tlt-transport{background:#FFF7ED;color:#EA580C}

  .tlt-edu{background:#DCFCE7;color:#16A34A}

  .tlt-biz{background:var(--primary-light);color:var(--primary-dark)}

  .tld-title{font-size:22px;font-weight:800;color:var(--text-main);margin-bottom:6px;line-height:1.3}

  .tld-provider{font-size:14px;color:var(--text-muted)}

  .tld-provider strong{color:var(--text-main)}

  .tld-section{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);padding:20px;margin-bottom:16px}

  .tld-section h3{font-size:15px;font-weight:800;color:var(--text-main);margin:0 0 14px;display:flex;align-items:center;gap:8px}

  .tld-section h3 svg{width:16px;height:16px;stroke:var(--primary);fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}

  .tld-info-grid{display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:16px}

  .tld-info-row{background:var(--bg-page);border-radius:var(--radius-sm);padding:12px 14px}

  .tld-info-row label{font-size:11px;color:var(--text-muted);font-weight:600;display:block;margin-bottom:4px}

  .tld-info-row span{font-size:14px;font-weight:600;color:var(--text-main)}

  .tld-desc{font-size:14px;color:var(--text-sub);line-height:1.8;margin:0;white-space:pre-line}

  .talent-apply-card{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);padding:24px;position:sticky;top:20px}

  .talent-apply-card h3{font-size:16px;font-weight:800;color:var(--text-main);margin:0 0 16px}

  .tac-provider-box{background:var(--primary-light);border-radius:var(--radius-sm);padding:14px;margin-bottom:18px;display:flex;align-items:center;gap:12px}

  .tac-provider-box img{width:44px;height:44px;border-radius:50%;object-fit:cover;flex-shrink:0}

  .tac-prov-name{font-size:14px;font-weight:700;color:var(--text-main)}

  .tac-prov-type{font-size:12px;color:var(--text-muted)}

  .tac-badge{display:inline-flex;align-items:center;gap:4px;font-size:11px;font-weight:700;background:var(--primary);color:#fff;padding:2px 8px;border-radius:20px;margin-top:3px}

  .tac-badge svg{width:10px;height:10px;stroke:#fff;fill:none;stroke-width:2.5;stroke-linecap:round;stroke-linejoin:round}

  .tac-info-row{display:flex;justify-content:space-between;font-size:14px;color:var(--text-sub);margin-bottom:10px;gap:12px}

  .tac-info-row span:last-child{font-weight:700;color:var(--text-main);text-align:right}

  .tac-divider{height:1px;background:var(--border);margin:14px 0}

  .tac-status-badge{display:inline-block;font-size:12px;font-weight:800;padding:4px 10px;border-radius:20px;margin-bottom:12px}
  
  .tac-status-open{background:#DCFCE7;color:#16A34A}

  .tac-status-closed{background:#F3F4F6;color:#6B7280}

  .tac-apply-form{margin-top:12px}
  
  .tac-apply-form textarea{width:100%;min-height:80px;border:1px solid var(--border);border-radius:8px;padding:10px;font-size:14px;box-sizing:border-box;resize:vertical}
  
  .tac-apply-btn{width:100%;margin-top:10px;padding:12px;border:none;border-radius:8px;background:var(--primary);color:#fff;font-size:15px;font-weight:700;cursor:pointer}
  
  .tac-apply-btn:disabled{background:#D1D5DB;cursor:not-allowed}
  
  .tac-alert{padding:10px 12px;border-radius:8px;font-size:13px;font-weight:600;margin-bottom:12px}
  
  .tac-alert.ok{background:#DCFCE7;color:#166534}
  
  .tac-alert.err{background:#FEE2E2;color:#B91C1C}
  
  .tac-alert.info{background:#EFF6FF;color:#1D4ED8}

</style>

<div class="tld-wrap">

  <div>

    <a href="${contextPath}/give/talent/list" class="tld-back"><svg viewBox="0 0 24 24"><path d="M19 12H5"/><polyline points="12 19 5 12 12 5"/></svg>재능나눔 목록으로</a>

    <div class="tld-header">

      <c:choose>

        <c:when test="${talent.talentType eq 'GROOMING'}">

          <div class="tld-icon ti-grooming"><svg viewBox="0 0 24 24"><path d="M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78L12 21.23l8.84-8.84a5.5 5.5 0 000-7.78z"/></svg></div>

        </c:when>

        <c:when test="${talent.talentType eq 'HOSPITAL'}">

          <div class="tld-icon ti-hospital"><svg viewBox="0 0 24 24"><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></svg></div>

        </c:when>

        <c:when test="${talent.talentType eq 'PHOTO'}">

          <div class="tld-icon ti-photo"><svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="12" cy="10" r="3"/><path d="M8.5 21l7-9-7 9z"/></svg></div>

        </c:when>

        <c:when test="${talent.talentType eq 'TRANSPORT'}">

          <div class="tld-icon ti-transport"><svg viewBox="0 0 24 24"><rect x="1" y="3" width="15" height="13"/><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"/><circle cx="5.5" cy="18.5" r="2.5"/><circle cx="18.5" cy="18.5" r="2.5"/></svg></div>

        </c:when>

        <c:otherwise>

          <div class="tld-icon ti-edu"><svg viewBox="0 0 24 24"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c0 2 2 3 6 3s6-1 6-3v-5"/></svg></div>

        </c:otherwise>

      </c:choose>

      <div class="tld-header-info">

        <div class="tld-tags">

          <c:if test="${talent.talentType eq 'GROOMING'}"><span class="tld-tag tlt-grooming">애견미용</span></c:if>

          <c:if test="${talent.talentType eq 'HOSPITAL'}"><span class="tld-tag tlt-hospital">병원</span></c:if>

          <c:if test="${talent.talentType eq 'PHOTO'}"><span class="tld-tag tlt-photo">사진 촬영</span></c:if>

          <c:if test="${talent.talentType eq 'TRANSPORT'}"><span class="tld-tag tlt-transport">운송</span></c:if>

          <c:if test="${talent.talentType eq 'ETC'}"><span class="tld-tag tlt-edu">기타</span></c:if>

          <span class="tld-tag tlt-biz">사업자 파트너 제공</span>

        </div>

        <div class="tld-title">${talent.title}</div>

        <div class="tld-provider">제공: <strong>${talent.bizName}</strong> · ${talent.bizType} 사업자 파트너</div>

      </div>

    </div>

    <div class="tld-section">

      <h3><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>기본 정보</h3>

      <div class="tld-info-grid">

        <div class="tld-info-row"><label>서비스 유형</label>

          <span>

            <c:choose>

              <c:when test="${talent.talentType eq 'GROOMING'}">애견미용</c:when>

              <c:when test="${talent.talentType eq 'HOSPITAL'}">병원/건강</c:when>

              <c:when test="${talent.talentType eq 'PHOTO'}">사진 촬영</c:when>

              <c:when test="${talent.talentType eq 'TRANSPORT'}">운송 도움</c:when>

              <c:otherwise>기타</c:otherwise>

            </c:choose>

          </span>

        </div>

        <div class="tld-info-row"><label>진행 일정</label><span>${talent.schedule}</span></div>

        <div class="tld-info-row"><label>장소</label><span>${talent.location}</span></div>

        <div class="tld-info-row"><label>소요시간</label><span>${talent.duration}</span></div>

        <div class="tld-info-row"><label>정원</label><span>${talent.capacity}</span></div>

        <div class="tld-info-row"><label>잔여</label>

          <span style="color:var(--primary-dark);font-weight:800">

            <c:choose>

              <c:when test="${talent.capacity != null && talent.currentCnt != null}">

                ${talent.capacity - talent.currentCnt}

              </c:when>

              <c:otherwise>-</c:otherwise>

            </c:choose>

          </span>

        </div>

      </div>

    </div>

    <div class="tld-section">

      <h3><svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>서비스 상세</h3>

      <p class="tld-desc">${talent.body}</p>

    </div>

  </div>

  <div class="talent-apply-card">

    <h3>제공자 정보</h3>

        <%-- 2026-08-10 박유정 — 모집중/모집마감 뱃지 --%>
    <c:choose>
      <c:when test="${recruitmentOpen}">
        <span class="tac-status-badge tac-status-open">${recruitmentLabel}</span>
      </c:when>
      <c:otherwise>
        <span class="tac-status-badge tac-status-closed">${recruitmentLabel}</span>
      </c:otherwise>
    </c:choose>
    <%-- 신청 결과 메시지 (redirect 후 1회) --%>
    <c:if test="${not empty msg}">
      <div class="tac-alert ok">${msg}</div>
    </c:if>
    <c:if test="${not empty errorMsg}">
      <div class="tac-alert err">${errorMsg}</div>
    </c:if>

    <div class="tac-provider-box">

      <c:choose>

        <c:when test="${not empty talent.thumbUrl}">

          <img src="${contextPath}${talent.thumbUrl}" alt="${talent.bizName}"

               onerror="this.src='https://placehold.co/44x44/EAF7F2/2BAB82?text=Biz'">

        </c:when>

        <c:otherwise>

          <img src="https://placehold.co/44x44/EAF7F2/2BAB82?text=Biz" alt="${talent.bizName}">

        </c:otherwise>

      </c:choose>

      <div>

        <div class="tac-prov-name">${talent.bizName}</div>

        <div class="tac-prov-type">${talent.bizType} · ${talent.location}</div>

        <span class="tac-badge"><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>인증 파트너</span>

      </div>

    </div>

    <div class="tac-info-row"><span>진행 일정</span><span>${talent.schedule}</span></div>

    <div class="tac-info-row"><span>신청 현황</span><span style="color:var(--primary-dark);font-weight:800">${talent.currentCnt} / ${talent.capacity}</span></div>

    <div class="tac-info-row"><span>진행 장소</span><span>${talent.location}</span></div>

    <div class="tac-divider"></div>

    <%-- 2026-08-10 박유정 — 참여 신청 UI (STEP 4) --%>
    <c:choose>

      <%-- 1) 이미 신청함 --%>
      <c:when test="${not empty myApply}">
        <div class="tac-alert info">
          <c:choose>
            <c:when test="${myApply.statusCd eq 'CONFIRMED'}">
              병원에서 확인 완료되었습니다.
            </c:when>
            <c:otherwise>
              신청 완료 · 병원 확인 대기 중입니다.
            </c:otherwise>
          </c:choose>
        </div>
      </c:when>

      <%-- 2) 모집중 + 아직 신청 안 함 --%>
      <c:when test="${recruitmentOpen}">
        <c:choose>
          <c:when test="${isLoggedIn}">
            <form class="tac-apply-form" method="post" action="${contextPath}/give/talent/apply">
            <input type="hidden" name="_csrf" value="${_csrf}">
              <input type="hidden" name="talentId" value="${talent.talentId}">
              <label style="font-size:13px;font-weight:600;color:var(--text-sub)">신청 메시지 (선택)</label>
              <textarea name="message" placeholder="간단한 메시지를 남겨주세요."></textarea>
              <button type="submit" class="tac-apply-btn">참여 신청하기</button>
            </form>
          </c:when>
          <c:otherwise>
            <a href="${contextPath}/login" class="tac-apply-btn" style="display:block;text-align:center;text-decoration:none;line-height:1.2">
              로그인 후 신청하기
            </a>
          </c:otherwise>
        </c:choose>
      </c:when>

      <%-- 3) 모집마감 --%>
      <c:otherwise>
        <div class="tac-alert err">모집이 마감되었습니다.</div>
      </c:otherwise>

    </c:choose>

    <div class="tac-divider"></div>
    <div class="tac-info-row"><span>문의 연락처</span><span style="color:var(--primary);font-weight:800">${talent.contact}</span></div>
    <div style="font-size:12px;color:var(--text-muted);margin-top:14px;line-height:1.6">
      · 무료 재능나눔 서비스입니다.<br>
      · 일정은 제공 사업자와 조율해 주세요.
    </div>
  </div> 
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>

