<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId"      value="mypage" />
<c:set var="sec"         value="health" />

<%@ include file="/WEB-INF/views/common/header.jsp" %>
<link rel="stylesheet" href="${contextPath}/resources/css/mypage.css">

<style>
/* ── 건강수첩 전용 ── */
.health-pet-tabs {
    display: flex;
    gap: 10px;
    margin-bottom: 24px;
    flex-wrap: wrap;
}
.health-pet-tab {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 10px 18px;
    border: 2px solid var(--border);
    border-radius: 50px;
    background: var(--bg-card);
    cursor: pointer;
    transition: var(--transition);
    text-decoration: none;
    color: var(--text-sub);
    font-size: 14px;
    font-weight: 600;
}
.health-pet-tab:hover { border-color: var(--primary); color: var(--primary-dark); }
.health-pet-tab.active { border-color: var(--primary); background: var(--primary-light); color: var(--primary-dark); }
.health-pet-tab img {
    width: 32px; height: 32px;
    border-radius: 50%; object-fit: cover;
}
.health-pet-tab .tab-name  { font-size: 14px; font-weight: 700; }
.health-pet-tab .tab-breed { font-size: 11px; color: var(--text-muted); font-weight: 400; }

.health-pet-profile {
    display: flex;
    align-items: center;
    gap: 20px;
    background: var(--bg-page);
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    padding: 20px 24px;
    margin-bottom: 24px;
}
.health-pet-avatar {
    width: 80px; height: 80px;
    border-radius: 50%;
    object-fit: cover;
    border: 3px solid #fff;
    box-shadow: var(--shadow-sm);
    flex-shrink: 0;
}
.health-pet-info { flex: 1; }
.health-pet-name { font-size: 20px; font-weight: 800; color: var(--text-main); margin-bottom: 4px; }
.health-pet-meta { font-size: 13px; color: var(--text-muted); }
.health-pet-stats {
    display: flex;
    gap: 24px;
    margin-left: auto;
    flex-shrink: 0;
}
.hps-item { text-align: center; }
.hps-label { font-size: 11px; color: var(--text-muted); margin-bottom: 4px; }
.hps-val   { font-size: 18px; font-weight: 800; color: var(--primary-dark); }
.hps-unit  { font-size: 11px; color: var(--text-sub); }

.health-timeline { position: relative; }
.health-timeline::before {
    content: '';
    position: absolute;
    left: 19px; top: 0; bottom: 0;
    width: 2px;
    background: var(--border);
}
.health-record {
    display: flex;
    gap: 20px;
    margin-bottom: 16px;
    position: relative;
}
.health-record-dot {
    width: 40px; height: 40px;
    border-radius: 50%;
    background: var(--primary-light);
    border: 2px solid var(--primary);
    display: flex; align-items: center; justify-content: center;
    flex-shrink: 0;
    z-index: 1;
}
.health-record-dot svg {
    width: 18px; height: 18px;
    stroke: var(--primary); fill: none;
    stroke-width: 1.8; stroke-linecap: round; stroke-linejoin: round;
}
.health-record-card {
    flex: 1;
    background: var(--bg-card);
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    overflow: hidden;
    transition: var(--transition);
}
.health-record-card:hover { box-shadow: var(--shadow-sm); }
.health-record-head {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 14px 18px;
    border-bottom: 1px solid var(--border);
    background: var(--bg-page);
}
.health-record-date    { font-size: 13px; color: var(--text-muted); }
.health-record-hospital{ font-size: 14px; font-weight: 700; color: var(--text-main); margin-left: 10px; }
.health-record-type {
    font-size: 11px; font-weight: 700;
    padding: 3px 10px; border-radius: 20px;
}
.type-check   { background: #E0F2FE; color: #0284C7; }
.type-treat   { background: #DCFCE7; color: #16A34A; }
.type-vaccine { background: #F3E8FF; color: #9333EA; }
.type-surgery { background: #FEE2E2; color: #DC2626; }

.health-record-body { padding: 16px 18px; }
.health-record-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 12px;
    margin-bottom: 12px;
}
.hrg-item label { font-size: 11px; color: var(--text-muted); font-weight: 600; display: block; margin-bottom: 3px; }
.hrg-item span  { font-size: 14px; color: var(--text-main); }
.health-record-memo {
    background: var(--bg-page);
    border-radius: var(--radius-sm);
    padding: 10px 14px;
    font-size: 13px;
    color: var(--text-sub);
    line-height: 1.6;
    border-left: 3px solid var(--primary);
}
.health-record-memo label { font-size: 11px; color: var(--text-muted); font-weight: 600; display: block; margin-bottom: 4px; }
.health-record-foot {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 10px 18px;
    border-top: 1px solid var(--border);
    font-size: 12px;
    color: var(--text-muted);
}
.health-next-visit {
    display: flex; align-items: center; gap: 5px;
    color: var(--primary); font-weight: 600;
}
.health-next-visit svg {
    width: 13px; height: 13px;
    stroke: currentColor; fill: none;
    stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
}

.health-empty {
    display: flex; flex-direction: column;
    align-items: center; gap: 14px;
    padding: 60px 20px; text-align: center;
}
.health-empty-icon {
    width: 64px; height: 64px; border-radius: 50%;
    background: var(--primary-light);
    display: flex; align-items: center; justify-content: center;
}
.health-empty-icon svg {
    width: 30px; height: 30px;
    stroke: var(--primary); fill: none;
    stroke-width: 1.6; stroke-linecap: round; stroke-linejoin: round;
}
.health-empty p { font-size: 14px; color: var(--text-muted); margin: 0; }
.health-empty a { color: var(--primary); font-weight: 700; text-decoration: none; }
@media (max-width: 720px) {
    .health-pet-profile { flex-wrap: wrap; }
    .health-pet-stats { margin-left: 0; width: 100%; justify-content: space-around; }
    .health-record-grid { grid-template-columns: 1fr; }
}
</style>

<div class="mypage-wrap">
<%@ include file="/WEB-INF/views/mypage/sidebar.jsp" %>

<div class="mypage-content">
<div class="mp-section active">
    <%-- 2026/07/14 장우철 — 건강수첩: TB_MEDICAL_RECORD 연동 --%>
    <h2 class="mp-title">건강수첩</h2>
    <p class="mp-desc">병원에서 작성한 진료 기록을 확인하세요.</p>

    <c:choose>
        <c:when test="${empty petList}">
            <div class="health-empty">
                <div class="health-empty-icon">
                    <svg viewBox="0 0 24 24"><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></svg>
                </div>
                <p>등록된 반려동물이 없습니다.</p>
                <p><a href="${contextPath}/mypage/pets">반려동물 등록하기</a></p>
            </div>
        </c:when>
        <c:otherwise>
            <%-- 반려동물 탭 --%>
            <div class="health-pet-tabs">
                <c:forEach var="p" items="${petList}">
                    <a href="${contextPath}/mypage/health?petId=${p.petId}"
                       class="health-pet-tab${selectedPet != null && selectedPet.petId == p.petId ? ' active' : ''}">
                        <c:choose>
                            <c:when test="${not empty p.photoUrl}">
                                <img src="${p.photoUrl}" alt="<c:out value='${p.petName}'/>"
                                     onerror="this.src='https://placehold.co/32x32/EAF7F2/2BAB82?text=PET'">
                            </c:when>
                            <c:otherwise>
                                <img src="https://placehold.co/32x32/EAF7F2/2BAB82?text=${fn:escapeXml(p.petName)}"
                                     alt="<c:out value='${p.petName}'/>">
                            </c:otherwise>
                        </c:choose>
                        <div>
                            <div class="tab-name"><c:out value="${p.petName}"/></div>
                            <div class="tab-breed"><c:out value="${empty p.breed ? '-' : p.breed}"/></div>
                        </div>
                    </a>
                </c:forEach>
            </div>

            <c:if test="${selectedPet != null}">
                <%-- 선택된 반려동물 프로필 --%>
                <div class="health-pet-profile">
                    <c:choose>
                        <c:when test="${not empty selectedPet.photoUrl}">
                            <img class="health-pet-avatar" src="${selectedPet.photoUrl}"
                                 alt="<c:out value='${selectedPet.petName}'/>"
                                 onerror="this.src='https://placehold.co/80x80/EAF7F2/2BAB82?text=PET'">
                        </c:when>
                        <c:otherwise>
                            <img class="health-pet-avatar"
                                 src="https://placehold.co/80x80/EAF7F2/2BAB82?text=${fn:escapeXml(selectedPet.petName)}"
                                 alt="<c:out value='${selectedPet.petName}'/>">
                        </c:otherwise>
                    </c:choose>
                    <div class="health-pet-info">
                        <div class="health-pet-name"><c:out value="${selectedPet.petName}"/></div>
                        <div class="health-pet-meta">
                            <c:out value="${empty selectedPet.breed ? '-' : selectedPet.breed}"/>
                            ·
                            <c:choose>
                                <c:when test="${selectedPet.gender eq 'M'}">수컷</c:when>
                                <c:when test="${selectedPet.gender eq 'F'}">암컷</c:when>
                                <c:otherwise>-</c:otherwise>
                            </c:choose>
                            <c:if test="${not empty selectedPet.birthDate}">
                                · <c:out value="${selectedPet.birthDate}"/>생
                            </c:if>
                            <c:if test="${not empty selectedPet.age}">
                                (<c:out value="${selectedPet.age}"/>살)
                            </c:if>
                        </div>
                    </div>
                    <div class="health-pet-stats">
                        <div class="hps-item">
                            <div class="hps-label">최근 체중</div>
                            <div class="hps-val">
                                <c:choose>
                                    <c:when test="${not empty latestWeight}">
                                        <c:out value="${latestWeight}"/><span class="hps-unit"> kg</span>
                                    </c:when>
                                    <c:otherwise>-<span class="hps-unit"> kg</span></c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <div class="hps-item">
                            <div class="hps-label">최근 체온</div>
                            <div class="hps-val">
                                <c:choose>
                                    <c:when test="${not empty latestTemp}">
                                        <c:out value="${latestTemp}"/><span class="hps-unit"> ℃</span>
                                    </c:when>
                                    <c:otherwise>-<span class="hps-unit"> ℃</span></c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <div class="hps-item">
                            <div class="hps-label">총 방문</div>
                            <div class="hps-val"><c:out value="${visitCount}"/><span class="hps-unit"> 회</span></div>
                        </div>
                    </div>
                </div>

                <%-- 진료 타임라인 --%>
                <c:choose>
                    <c:when test="${empty recordList}">
                        <div class="health-empty">
                            <div class="health-empty-icon">
                                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                            </div>
                            <p>아직 병원 진료 기록이 없습니다.</p>
                            <p>예약·방문 후 병원에서 진료를 완료하면 여기에 표시됩니다.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="health-timeline">
                            <c:forEach var="r" items="${recordList}">
                                <c:set var="typeLabel" value="${empty r.treatType ? '진료' : r.treatType}"/>
                                <c:set var="typeCss" value="type-treat"/>
                                <c:choose>
                                    <c:when test="${typeLabel eq '정기검진'}"><c:set var="typeCss" value="type-check"/></c:when>
                                    <c:when test="${typeLabel eq '예방접종'}"><c:set var="typeCss" value="type-vaccine"/></c:when>
                                    <c:when test="${typeLabel eq '수술'}"><c:set var="typeCss" value="type-surgery"/></c:when>
                                    <c:otherwise><c:set var="typeCss" value="type-treat"/></c:otherwise>
                                </c:choose>
                                <div class="health-record">
                                    <div class="health-record-dot">
                                        <svg viewBox="0 0 24 24"><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></svg>
                                    </div>
                                    <div class="health-record-card">
                                        <div class="health-record-head">
                                            <div>
                                                <span class="health-record-date">
                                                    <c:choose>
                                                        <c:when test="${not empty r.visitDate}">
                                                            <fmt:formatDate value="${r.visitDate}" pattern="yyyy.MM.dd"/>
                                                        </c:when>
                                                        <c:otherwise>-</c:otherwise>
                                                    </c:choose>
                                                </span>
                                                <span class="health-record-hospital"><c:out value="${r.hospitalName}"/></span>
                                            </div>
                                            <span class="health-record-type ${typeCss}"><c:out value="${typeLabel}"/></span>
                                        </div>
                                        <div class="health-record-body">
                                            <div class="health-record-grid">
                                                <div class="hrg-item">
                                                    <label>주증상</label>
                                                    <span><c:out value="${empty r.symptoms ? '-' : r.symptoms}"/></span>
                                                </div>
                                                <div class="hrg-item">
                                                    <label>진단명</label>
                                                    <span><c:out value="${empty r.diagnosis ? '-' : r.diagnosis}"/></span>
                                                </div>
                                                <div class="hrg-item">
                                                    <label>처방</label>
                                                    <span><c:out value="${empty r.prescription ? '-' : r.prescription}"/></span>
                                                </div>
                                                <div class="hrg-item">
                                                    <label>체중 / 체온</label>
                                                    <span>
                                                        <c:choose>
                                                            <c:when test="${not empty r.weight or not empty r.temperature}">
                                                                <c:out value="${empty r.weight ? '-' : r.weight}"/> kg
                                                                /
                                                                <c:out value="${empty r.temperature ? '-' : r.temperature}"/> ℃
                                                            </c:when>
                                                            <c:otherwise>-</c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                </div>
                                                <c:if test="${not empty r.examItems}">
                                                    <div class="hrg-item">
                                                        <label>검사 항목</label>
                                                        <span><c:out value="${r.examItems}"/></span>
                                                    </div>
                                                </c:if>
                                            </div>
                                            <c:if test="${not empty r.memo}">
                                                <div class="health-record-memo">
                                                    <label>수의사 메모</label>
                                                    <c:out value="${r.memo}"/>
                                                </div>
                                            </c:if>
                                        </div>
                                        <div class="health-record-foot">
                                            <span>
                                                담당:
                                                <c:choose>
                                                    <c:when test="${not empty r.vetName}"><c:out value="${r.vetName}"/> 수의사</c:when>
                                                    <c:otherwise>-</c:otherwise>
                                                </c:choose>
                                            </span>
                                            <c:if test="${not empty r.nextVisit}">
                                                <span class="health-next-visit">
                                                    <svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="3" y1="10" x2="21" y2="10"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="16" y1="2" x2="16" y2="6"/></svg>
                                                    다음 방문 권장: <c:out value="${r.nextVisit}"/>
                                                </span>
                                            </c:if>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </c:if>
        </c:otherwise>
    </c:choose>
</div>
</div><%-- /mypage-content --%>
</div><%-- /mypage-wrap --%>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
