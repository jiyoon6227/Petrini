<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
  역할: 관리자 재능나눔 승인 관리 (admin/biz/talent)

  - 박유정 / 2026-07-13~14

  [화면 흐름]
  1. GET /admin/biz/talent?status=PENDING|APPROVED|REJECTED
  2. ${list} + ${statusCounts} — TB_TALENT 상태별 목록
  3. PENDING 카드 → POST /admin/biz/talent/approve | /reject
  4. APPROVED 승인 시 /give/talent/list 자동 노출

  [model]
  - list, status, statusCounts, successMsg, errorMsg
--%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="adminPage"   value="biz-talent" />
<%@ include file="/WEB-INF/views/admin/common/header.jsp" %>
<%@ include file="/WEB-INF/views/admin/common/sidebar.jsp" %>

<style>
/* ── 탭 ── */
.talent-tab-bar {
    display:flex; gap:0; align-items:flex-end;
    border-bottom:2px solid #E4E6ED; margin-bottom:20px;
}
.talent-tab {
    padding:10px 22px; font-size:14px; font-weight:600;
    color:#999; background:none; cursor:pointer;
    border:none; border-bottom:2px solid transparent;
    margin-bottom:-2px; transition:all .15s;
    text-decoration:none; display:inline-flex; align-items:center;
    box-sizing:border-box;
}
.talent-tab:link,
.talent-tab:visited { color:#999; text-decoration:none; }
.talent-tab:hover { color:#3B5BDB; }
.talent-tab.on { color:#3B5BDB; border-bottom-color:#3B5BDB; font-weight:700; }

/* ── 신청 카드 ── */
.ta-card {
    background:#fff; border:1px solid #E4E6ED;
    border-radius:12px; overflow:hidden;
    margin-bottom:16px; transition:box-shadow .2s;
}
.ta-card:hover { box-shadow:0 4px 16px rgba(0,0,0,.07); }
.ta-head {
    display:flex; align-items:center; gap:14px;
    padding:16px 20px; border-bottom:1px solid #E4E6ED; background:#FAFBFC;
}
.ta-biz-icon {
    width:44px; height:44px; border-radius:10px;
    display:flex; align-items:center; justify-content:center; flex-shrink:0;
}
.ta-biz-icon svg { width:22px; height:22px; fill:none; stroke-width:1.8; stroke-linecap:round; stroke-linejoin:round; }
.ta-biz-name  { font-size:15px; font-weight:800; color:#1A1A2E; }
.ta-biz-type  { font-size:12px; color:#999; margin-top:2px; }
.ta-date      { margin-left:auto; font-size:12px; color:#999; flex-shrink:0; }

.ta-body {
    display:grid; grid-template-columns:repeat(4,1fr);
    border-bottom:1px solid #E4E6ED;
}
.ta-field { padding:14px 18px; border-right:1px solid #E4E6ED; }
.ta-field:last-child { border-right:none; }
.ta-field label { font-size:11px; color:#999; font-weight:600; display:block; margin-bottom:4px; }
.ta-field span  { font-size:13px; color:#1A1A2E; font-weight:500; }

.ta-desc {
    padding:14px 18px; border-bottom:1px solid #E4E6ED;
    font-size:13px; color:#555; line-height:1.7;
    border-left:3px solid #3B5BDB; margin:0 18px 0;
    background:#F8F9FF; border-radius:0 6px 6px 0;
    margin:12px 18px; border-left:3px solid #3B5BDB;
    padding:12px 14px;
}

.ta-foot {
    display:flex; justify-content:space-between; align-items:center;
    padding:12px 18px;
}
.ta-reject-wrap { display:flex; gap:8px; align-items:center; }
.ta-reject-input {
    border:1px solid #E4E6ED; border-radius:6px;
    padding:7px 12px; font-size:13px; color:#333;
    outline:none; width:260px; display:block; font-family:inherit;
}
.ta-reject-input:focus { border-color:#3B5BDB; }
.ta-action-btns { display:flex; gap:8px; }
</style>

<main class="adm-main">
    <div class="adm-page-head">
        <div class="adm-page-head-left">
            <h1 class="adm-page-title">재능나눔 승인 관리</h1>
            <p class="adm-page-desc">사업자가 신청한 재능나눔을 검토하고 승인하면 나눔 탭에 게시됩니다.</p>
        </div>
    </div>

    <%-- 플로우 안내 --%>
    <div style="display:flex;align-items:center;gap:0;margin-bottom:24px;background:#fff;border:1px solid #E4E6ED;border-radius:12px;overflow:hidden">
        <div style="flex:1;padding:16px 20px;text-align:center;border-right:1px solid #E4E6ED">
            <div style="font-size:12px;color:#999;margin-bottom:4px">STEP 1</div>
            <div style="font-size:14px;font-weight:700;color:#1A1A2E">사업자 신청</div>
            <div style="font-size:12px;color:#999;margin-top:2px">사업자센터에서 신청서 작성</div>
        </div>
        <div style="color:#C7D2FE;font-size:20px;padding:0 4px">›</div>
        <div style="flex:1;padding:16px 20px;text-align:center;border-right:1px solid #E4E6ED;background:#EEF2FF">
            <div style="font-size:12px;color:#3B5BDB;margin-bottom:4px;font-weight:700">STEP 2 (현재)</div>
            <div style="font-size:14px;font-weight:800;color:#3B5BDB">관리자 승인</div>
            <div style="font-size:12px;color:#3B5BDB;margin-top:2px">내용 검토 후 승인·반려</div>
        </div>
        <div style="color:#C7D2FE;font-size:20px;padding:0 4px">›</div>
        <div style="flex:1;padding:16px 20px;text-align:center">
            <div style="font-size:12px;color:#999;margin-bottom:4px">STEP 3</div>
            <div style="font-size:14px;font-weight:700;color:#1A1A2E">나눔 탭 게시</div>
            <div style="font-size:12px;color:#999;margin-top:2px">/give?tab=talent 자동 노출</div>
        </div>
    </div>

    <c:if test="${not empty successMsg}">
        <div style="background:#ECFDF5;border:1px solid #BBF7D0;color:#166534;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:14px">
            ${successMsg}
        </div>
    </c:if>
    <c:if test="${not empty errorMsg}">
        <div style="background:#FEF2F2;border:1px solid #FECACA;color:#B91C1C;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:14px">
            ${errorMsg}
        </div>
    </c:if>

    <%-- 탭 --%>
    <%-- 재능나눔 상태 탭 — DB 건수 연동 (admin/biz/list.jsp 패턴) --%>
    <div class="talent-tab-bar">
        <a href="${contextPath}/admin/biz/talent?status=PENDING"
           class="talent-tab ${status eq 'PENDING' ? 'on' : ''}">
            승인 대기
            <span style="background:#EEF2FF;color:#3B5BDB;font-size:11px;padding:1px 7px;border-radius:20px;margin-left:4px">
                ${statusCounts.PENDING}
            </span>
        </a>
        <a href="${contextPath}/admin/biz/talent?status=APPROVED"
           class="talent-tab ${status eq 'APPROVED' ? 'on' : ''}">
            게시 중
            <span style="background:#DCFCE7;color:#16A34A;font-size:11px;padding:1px 7px;border-radius:20px;margin-left:4px">
                ${statusCounts.APPROVED}
            </span>
        </a>
        <a href="${contextPath}/admin/biz/talent?status=REJECTED"
           class="talent-tab ${status eq 'REJECTED' ? 'on' : ''}">
            반려
            <span style="background:#F1F3F7;color:#999;font-size:11px;padding:1px 7px;border-radius:20px;margin-left:4px">
                ${statusCounts.REJECTED}
            </span>
        </a>
    </div>

    <%-- 승인 대기 목록 (PENDING 탭에서만) --%>
    <c:if test="${status eq 'PENDING'}">
    <c:choose>
        <c:when test="${empty list}">
            <p style="text-align:center;color:#999;padding:48px 0">
                승인 대기 중인 재능나눔이 없습니다.
            </p>
        </c:when>
        <c:otherwise>
            <c:forEach var="item" items="${list}">
                <%-- 카드 1개 = DB 1건 --%>
                <div class="ta-card">
                    <div class="ta-head">
                        <c:set var="iconBg" value="#FDF2F8"/>
                        <c:set var="iconStroke" value="#DB2777"/>
                        <c:if test="${item.talentType eq 'HOSPITAL'}">
                            <c:set var="iconBg" value="#E0F2FE"/>
                            <c:set var="iconStroke" value="#0284C7"/>
                        </c:if>
                        <c:if test="${item.talentType eq 'PHOTO'}">
                            <c:set var="iconBg" value="#F3E8FF"/>
                            <c:set var="iconStroke" value="#9333EA"/>
                        </c:if>
                        <c:if test="${item.talentType eq 'TRANSPORT'}">
                            <c:set var="iconBg" value="#FFF7ED"/>
                            <c:set var="iconStroke" value="#EA580C"/>
                        </c:if>
                        <div class="ta-biz-icon" style="background:${iconBg}">
                            <svg viewBox="0 0 24 24" stroke="${iconStroke}">
                                <path d="M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78L12 21.23l8.84-8.84a5.5 5.5 0 000-7.78z"/>
                            </svg>
                        </div>
                        <div>
                            <div class="ta-biz-name">${item.bizName}</div>
                            <div class="ta-biz-type">${item.bizType} · ${item.location}</div>
                        </div>
                        <span class="adm-badge wait" style="margin-left:12px">승인 대기</span>
                        <span class="ta-date">신청일: ${item.regDate}</span>
                    </div>
                    <div class="ta-body">
                        <div class="ta-field">
                            <label>나눔 유형</label>
                            <span>
                                <c:choose>
                                    <c:when test="${item.talentType eq 'GROOMING'}">애견미용</c:when>
                                    <c:when test="${item.talentType eq 'HOSPITAL'}">병원/건강</c:when>
                                    <c:when test="${item.talentType eq 'PHOTO'}">사진 촬영</c:when>
                                    <c:when test="${item.talentType eq 'TRANSPORT'}">운송</c:when>
                                    <c:otherwise>기타</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                        <div class="ta-field"><label>제목</label><span>${item.title}</span></div>
                        <div class="ta-field"><label>진행 일정</label><span>${item.schedule}</span></div>
                        <div class="ta-field"><label>모집 수량</label><span>${item.capacity}</span></div>
                    </div>
                    <div class="ta-desc">${item.body}</div>
                    <div class="ta-foot">
                        <div style="font-size:13px;color:#555">
                            제공 장소: ${item.location} &nbsp;·&nbsp; 문의: ${item.contact}
                        </div>
                        <div class="ta-reject-wrap">
                            <form method="post" action="${contextPath}/admin/biz/talent/reject"
                                  style="display:flex;gap:8px;align-items:center"
                                  onsubmit="return confirm('반려하시겠습니까?')">
                                <!--HYJ 26.08.05-->
                                <input type="hidden" name="_csrf" value="${_csrf}">  
                                
                                <%-- 2026-07-14 박유정 — AdminBizController.rejectTalent --%>
                                <input type="hidden" name="talentId" value="${item.talentId}">
                                <input type="text" name="rejectReason" class="ta-reject-input"
                                       placeholder="반려 사유 입력" required
                                       style="display:block;width:260px">
                                <button type="submit" class="adm-btn gray">반려</button>
                            </form>
                            <form method="post" action="${contextPath}/admin/biz/talent/approve"
                                  style="display:inline"
                                  onsubmit="return confirm('승인하시겠습니까?\n나눔 탭에 게시됩니다.')">
                                <!--HYJ 26.08.05-->
                                <input type="hidden" name="_csrf" value="${_csrf}">  
                                
                                <%-- 2026-07-14 박유정 — AdminBizController.approveTalent → /give/talent/list 노출 --%>
                                <input type="hidden" name="talentId" value="${item.talentId}">
                                <button type="submit" class="adm-btn green">승인 → 나눔 탭 게시</button>
                            </form>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </c:otherwise>
    </c:choose>
      
    </c:if>

    <%-- 게시 중 --%>
    <%-- 게시 중 (APPROVED) --%>
    <c:if test="${status eq 'APPROVED'}">
        <c:choose>
            <c:when test="${empty list}">
                <p style="text-align:center;color:#999;padding:48px 0">
                    게시 중인 재능나눔이 없습니다.
                </p>
            </c:when>
            <c:otherwise>
                <table class="adm-table">
                    <thead>
                        <tr>
                            <th>업체명</th><th>유형</th><th>제목</th>
                            <th>진행 수량</th><th>게시일</th><th>상태</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="item" items="${list}">
                            <tr>
                                <td>${item.bizName}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${item.talentType eq 'GROOMING'}">애견미용</c:when>
                                        <c:when test="${item.talentType eq 'HOSPITAL'}">병원/건강</c:when>
                                        <c:when test="${item.talentType eq 'PHOTO'}">사진 촬영</c:when>
                                        <c:when test="${item.talentType eq 'TRANSPORT'}">운송</c:when>
                                        <c:otherwise>기타</c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${item.title}</td>
                                <td>${item.currentCnt} / ${item.capacity}</td>
                                <td>${item.approveDate}</td>
                                <td><span class="adm-badge active">게시 중</span></td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>
    </c:if>

    <%-- 반려 --%>
    <%-- 반려 (REJECTED) --%>
    <c:if test="${status eq 'REJECTED'}">
        <c:choose>
            <c:when test="${empty list}">
                <p style="text-align:center;color:#999;padding:48px 0">
                    반려된 재능나눔이 없습니다.
                </p>
            </c:when>
            <c:otherwise>
                <table class="adm-table">
                    <thead>
                        <tr>
                            <th>업체명</th><th>유형</th><th>제목</th>
                            <th>반려 사유</th><th>신청일</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="item" items="${list}">
                            <tr>
                                <td>${item.bizName}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${item.talentType eq 'GROOMING'}">애견미용</c:when>
                                        <c:when test="${item.talentType eq 'HOSPITAL'}">병원/건강</c:when>
                                        <c:when test="${item.talentType eq 'PHOTO'}">사진 촬영</c:when>
                                        <c:when test="${item.talentType eq 'TRANSPORT'}">운송</c:when>
                                        <c:otherwise>기타</c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${item.title}</td>
                                <td>${item.rejectReason}</td>
                                <td>${item.regDate}</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>
    </c:if>
</main>


<%@ include file="/WEB-INF/views/admin/common/footer.jsp" %>
