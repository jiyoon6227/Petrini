<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="adminPage"   value="biz-list" />
<%@ include file="/WEB-INF/views/admin/common/header.jsp" %>
<%@ include file="/WEB-INF/views/admin/common/sidebar.jsp" %>

<style>
.biz-detail-grid { display:grid; grid-template-columns:1fr 300px; gap:20px; align-items:flex-start; }
.bds { background:#fff; border:1px solid #E4E6ED; border-radius:12px; padding:22px; margin-bottom:20px; }
.bds-title {
    font-size:14px; font-weight:800; color:#1A1A2E;
    margin:0 0 16px; padding-bottom:12px; border-bottom:1px solid #E4E6ED;
    display:flex; align-items:center; gap:8px;
}
.bds-title svg { width:16px; height:16px; stroke:#3B5BDB; fill:none; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; }
.bds-row { display:flex; justify-content:space-between; align-items:flex-start; padding:10px 0; border-bottom:1px solid #F5F5F5; font-size:14px; }
.bds-row:last-child { border-bottom:none; }
.bds-row label { color:#999; font-size:13px; flex-shrink:0; min-width:120px; }
.bds-row span  { color:#1A1A2E; font-weight:600; text-align:right; word-break:break-all; }

/* 업종 아이콘 */
.biz-type-icon {
    width:52px; height:52px; border-radius:12px;
    display:flex; align-items:center; justify-content:center; flex-shrink:0;
    background:#E0F2FE;
}
.biz-type-icon svg { width:26px; height:26px; stroke:#0284C7; fill:none; stroke-width:1.8; stroke-linecap:round; stroke-linejoin:round; }

/* 서류 뷰어 */
.doc-viewer {
    border:1px solid #E4E6ED; border-radius:8px; overflow:hidden;
    margin-bottom:12px;
}
.doc-viewer-head {
    display:flex; justify-content:space-between; align-items:center;
    padding:10px 14px; background:#FAFBFC; border-bottom:1px solid #E4E6ED;
    font-size:13px; font-weight:700; color:#1A1A2E;
}
.doc-viewer img { width:100%; display:block; max-height:220px; object-fit:cover; cursor:zoom-in; }
.doc-viewer-foot { padding:8px 14px; font-size:12px; color:#999; display:flex; justify-content:space-between; }

/* 승인 카드 */
.approve-card { background:#fff; border:1px solid #E4E6ED; border-radius:12px; padding:22px; position:sticky; top:20px; }
.approve-card h3 { font-size:15px; font-weight:800; color:#1A1A2E; margin:0 0 18px; padding-bottom:12px; border-bottom:1px solid #E4E6ED; }
.approve-status-box { background:#FFF8E1; border:1px solid #FDE68A; border-radius:8px; padding:14px; margin-bottom:18px; display:flex; align-items:center; gap:10px; }
.approve-status-box svg { width:20px; height:20px; stroke:#F59E0B; fill:none; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; flex-shrink:0; }
.approve-status-box span { font-size:13px; color:#92400E; font-weight:600; }
.approve-checklist { display:flex; flex-direction:column; gap:8px; margin-bottom:18px; }
.approve-check { display:flex; align-items:center; gap:8px; font-size:13px; color:#555; cursor:pointer; }
.approve-check input[type=checkbox] { width:15px; height:15px; accent-color:#3B5BDB; flex-shrink:0; }
.approve-reject-area { margin-bottom:14px; }
.approve-reject-area label { font-size:13px; font-weight:600; color:#555; display:block; margin-bottom:6px; }
.approve-reject-area textarea {
    width:100%; border:1px solid #E4E6ED; border-radius:8px;
    padding:10px 12px; font-size:13px; color:#1A1A2E;
    outline:none; resize:vertical; min-height:80px; font-family:inherit;
    box-sizing:border-box; line-height:1.6;
}
.approve-reject-area textarea:focus { border-color:#3B5BDB; }
.approve-btn-row { display:flex; flex-direction:column; gap:8px; }
.btn-approve {
    width:100%; padding:13px; border:none; border-radius:8px;
    background:#16A34A; color:#fff; font-size:15px; font-weight:800;
    cursor:pointer; transition:background .15s; display:flex; align-items:center; justify-content:center; gap:8px;
}
.btn-approve:hover { background:#15803D; }
.btn-approve svg { width:16px; height:16px; stroke:#fff; fill:none; stroke-width:2.5; stroke-linecap:round; stroke-linejoin:round; }
.btn-reject {
    width:100%; padding:13px; border:2px solid #DC2626; border-radius:8px;
    background:#fff; color:#DC2626; font-size:15px; font-weight:800;
    cursor:pointer; transition:all .15s; display:flex; align-items:center; justify-content:center; gap:8px;
}
.btn-reject:hover { background:#DC2626; color:#fff; }
.btn-reject svg { width:16px; height:16px; stroke:currentColor; fill:none; stroke-width:2.5; stroke-linecap:round; stroke-linejoin:round; }
</style>

<main class="adm-main">

    <%-- 2026-07-09 장우철 — 처리 결과 메시지 --%>
    <c:if test="${not empty successMsg}">
        <div style="background:#ECFDF5;border:1px solid #BBF7D0;color:#166534;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:14px">${successMsg}</div>
    </c:if>
    <c:if test="${not empty errorMsg}">
        <div style="background:#FEF2F2;border:1px solid #FECACA;color:#B91C1C;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:14px">${errorMsg}</div>
    </c:if>

    <div style="display:flex;align-items:center;gap:8px;font-size:13px;color:#999;margin-bottom:20px">
        <a href="${contextPath}/admin/biz/list" style="color:#999;text-decoration:none">사업자 승인/관리</a>
        <span>›</span>
        <span style="color:#1A1A2E;font-weight:600">${biz.bizName} 상세</span>
    </div>

    <%-- 2026-07-09 장우철 — [변경 후] 상단 헤더 실데이터 --%>
    <div style="display:flex;align-items:center;gap:16px;margin-bottom:24px">
        <div class="biz-type-icon">
            <svg viewBox="0 0 24 24"><path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z"/></svg>
        </div>
        <div>
            <h1 style="font-size:22px;font-weight:800;color:#1A1A2E;margin:0 0 4px">${biz.bizName}</h1>
            <div style="display:flex;gap:8px;align-items:center">
                <span class="adm-badge" style="background:#E0F2FE;color:#0284C7">${biz.bizType}</span>
                <c:choose>
                    <c:when test="${biz.statusCd eq 'PENDING'}"><span class="adm-badge wait">승인 대기</span></c:when>
                    <c:when test="${biz.statusCd eq 'APPROVED'}"><span class="adm-badge active">승인 완료</span></c:when>
                    <c:otherwise><span class="adm-badge" style="background:#FEE2E2;color:#DC2626">반려</span></c:otherwise>
                </c:choose>
                <span style="font-size:12px;color:#999">신청일: ${biz.applyDate}</span>
            </div>
        </div>
    </div>

    <div class="biz-detail-grid">
        <div>
            <div class="bds">
                <div class="bds-title">
                    <svg viewBox="0 0 24 24"><rect x="2" y="7" width="20" height="14" rx="2"/><path d="M16 7V5a2 2 0 00-2-2h-4a2 2 0 00-2 2v2"/></svg>
                    사업자 기본 정보
                </div>
                <div class="bds-row"><label>업체명</label><span>${biz.bizName}</span></div>
                <div class="bds-row"><label>업종</label><span>${biz.bizType}</span></div>
                <div class="bds-row"><label>사업자 등록번호</label><span>${biz.bizRegNo}</span></div>
                <div class="bds-row"><label>대표자명</label><span>${biz.ceoName}</span></div>
                <div class="bds-row"><label>사업장 전화번호</label><span>${biz.phone}</span></div>
                <div class="bds-row"><label>PetCare 계정</label><span>${biz.bizId}</span></div>
            </div>

            <%-- 2026/07/28 장우철 — 정산 계좌 (TB_BUSINESS.SETTLE_* 연동) --%>
            <c:if test="${biz.bizType eq 'STAY' or biz.bizType eq 'STORE'}">
            <div class="bds">
                <div class="bds-title">
                    <svg viewBox="0 0 24 24"><rect x="2" y="5" width="20" height="14" rx="2"/><line x1="2" y1="10" x2="22" y2="10"/></svg>
                    정산 계좌
                    <c:choose>
                        <c:when test="${biz.settleVerifyYn eq 'Y'}">
                            <span style="font-size:12px;font-weight:600;color:#166534;margin-left:6px">인증완료</span>
                        </c:when>
                        <c:otherwise>
                            <span style="font-size:12px;font-weight:500;color:#999;margin-left:6px">미인증</span>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="bds-row">
                    <label>은행</label>
                    <span>
                        <c:choose>
                            <c:when test="${not empty biz.settleBank}">${biz.settleBank}<c:if test="${not empty biz.settleBankCode}"> (${biz.settleBankCode})</c:if></c:when>
                            <c:otherwise><span style="color:#999">—</span></c:otherwise>
                        </c:choose>
                    </span>
                </div>
                <div class="bds-row">
                    <label>계좌번호</label>
                    <span>
                        <c:choose>
                            <c:when test="${not empty biz.settleAccount}">${biz.settleAccount}</c:when>
                            <c:otherwise><span style="color:#999">—</span></c:otherwise>
                        </c:choose>
                    </span>
                </div>
                <div class="bds-row">
                    <label>예금주</label>
                    <span>
                        <c:choose>
                            <c:when test="${not empty biz.settleHolder}">${biz.settleHolder}</c:when>
                            <c:otherwise><span style="color:#999">—</span></c:otherwise>
                        </c:choose>
                    </span>
                </div>
                <c:if test="${biz.settleVerifyYn eq 'Y' and not empty biz.settleVerifyDate}">
                <div class="bds-row"><label>인증일시</label><span>${biz.settleVerifyDate}</span></div>
                </c:if>
                <p style="font-size:12px;color:#999;margin:8px 0 0;line-height:1.5">
                    승인 전 사업자번호로 개인/법인을 구분하고, 예금주(대표자명·법인명)가 맞는지 확인하세요.
                </p>
            </div>
            </c:if>

            <%-- 2026-07-09 장우철 — TB_FILE 제출 서류 (BIZ_AUTH / BIZ_LICENSE) --%>
            <div class="bds">
                <div class="bds-title">
                    <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                    제출 서류
                </div>
                <c:if test="${empty authFiles && empty licenseFiles}">
                    <p style="font-size:13px;color:#999;margin:0">제출된 서류가 없습니다.</p>
                </c:if>
                <c:forEach var="f" items="${authFiles}">
                <div class="doc-viewer">
                    <div class="doc-viewer-head">
                        사업자등록증
                        <a href="${contextPath}/upload/${f.fileUrl}" target="_blank" class="adm-btn blue">원본 보기</a>
                    </div>
                    <div class="doc-viewer-foot">
                        <span>${f.originName}</span>
                        <span>${f.regDate}</span>
                    </div>
                </div>
                </c:forEach>
                <c:forEach var="f" items="${licenseFiles}">
                <div class="doc-viewer">
                    <div class="doc-viewer-head">
                        영업신고증 / 허가증
                        <a href="${contextPath}/upload/${f.fileUrl}" target="_blank" class="adm-btn blue">원본 보기</a>
                    </div>
                    <div class="doc-viewer-foot">
                        <span>${f.originName}</span>
                        <span>${f.regDate}</span>
                    </div>
                </div>
                </c:forEach>
            </div>
        </div>

        <div>
            <div class="approve-card">
                <h3>승인 처리</h3>
                <div class="approve-status-box">
                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                    <span>
                        <c:choose>
                            <c:when test="${biz.statusCd eq 'PENDING'}">관리자 검토 대기 중</c:when>
                            <c:when test="${biz.statusCd eq 'APPROVED'}">승인 완료된 신청입니다</c:when>
                            <c:otherwise>반려된 신청입니다</c:otherwise>
                        </c:choose>
                    </span>
                </div>

                <c:if test="${biz.statusCd eq 'PENDING'}">
                <form method="post" action="${contextPath}/admin/biz/approve" class="approve-btn-row"
                      onsubmit="return confirm('${biz.bizName} 신청을 승인하시겠습니까?')">
                    <!--HYJ 26.08.05-->
                    <input type="hidden" name="_csrf" value="${_csrf}">
                    
                    <input type="hidden" name="bizNo" value="${biz.bizNo}">
                    <!--HYJ 26.07.28 메일조회-->
                    <input type="hidden" name="bizId" value="${biz.bizId}">
                    <button type="submit" class="btn-approve">
                        <svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>
                        승인하기
                    </button>
                </form>
                <form method="post" action="${contextPath}/admin/biz/reject" class="approve-btn-row" style="margin-top:8px"
                      onsubmit="return confirm('반려 처리하시겠습니까?')">
                    <!--HYJ 26.08.05-->
                    <input type="hidden" name="_csrf" value="${_csrf}">
                    
                    <input type="hidden" name="bizNo" value="${biz.bizNo}">
                    <!--HYJ 26.07.28 메일조회-->
                    <input type="hidden" name="bizId" value="${biz.bizId}">
                    <div class="approve-reject-area">
                        <label>반려 사유 (필수)</label>
                        <textarea name="rejectReason" required placeholder="반려 사유를 입력하세요"></textarea>
                    </div>
                    <button type="submit" class="btn-reject">
                        <svg viewBox="0 0 24 24"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                        반려하기
                    </button>
                </form>
                </c:if>

                <button class="adm-btn gray" style="width:100%;padding:11px;font-size:14px;margin-top:8px" onclick="location.href='${contextPath}/admin/biz/list'">목록으로</button>
            </div>
        </div>
    </div>

    <%-- ========== [변경 전] 2026-07-09 장우철 — 더미 상세(행복 동물병원) 목업 보존
         이유: 기존 UI 목업을 삭제하지 않고 참고용으로 남김 ==========
    <div style="display:flex;align-items:center;gap:8px;font-size:13px;color:#999;margin-bottom:20px">
        <a href="${contextPath}/admin/biz/list" style="color:#999;text-decoration:none">사업자 승인/관리</a>
        <span>›</span>
        <span style="color:#1A1A2E;font-weight:600">행복 동물병원 상세</span>
    </div>
    <div style="display:flex;align-items:center;gap:16px;margin-bottom:24px">
        <div class="biz-type-icon">
            <svg viewBox="0 0 24 24"><path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z"/><rect x="9" y="10" width="6" height="11" rx="1"/><line x1="12" y1="13" x2="12" y2="17"/><line x1="10" y1="15" x2="14" y2="15"/></svg>
        </div>
        <div>
            <h1 style="font-size:22px;font-weight:800;color:#1A1A2E;margin:0 0 4px">행복 동물병원</h1>
            <div style="display:flex;gap:8px;align-items:center">
                <span class="adm-badge" style="background:#E0F2FE;color:#0284C7">동물병원</span>
                <span class="adm-badge wait">승인 대기</span>
                <span style="font-size:12px;color:#999">신청일: 2025.06.25 14:32</span>
            </div>
        </div>
    </div>
    <div class="biz-detail-grid">
        <div>
            <div class="bds">
                <div class="bds-title">사업자 기본 정보</div>
                <div class="bds-row"><label>업체명</label><span>행복 동물병원</span></div>
                <div class="bds-row"><label>업종</label><span>동물병원</span></div>
                <div class="bds-row"><label>사업자 등록번호</label><span>123-45-67890</span></div>
                <div class="bds-row"><label>대표자명</label><span>김철수</span></div>
                <div class="bds-row"><label>사업장 전화번호</label><span>02-1234-5678</span></div>
                <div class="bds-row"><label>사업장 주소</label><span>서울특별시 마포구 합정동 123-4</span></div>
            </div>
            <div class="bds">
                <div class="bds-title">담당자 정보</div>
                <div class="bds-row"><label>담당자 이름</label><span>김철수</span></div>
                <div class="bds-row"><label>담당자 연락처</label><span>010-1234-5678</span></div>
                <div class="bds-row"><label>담당자 이메일</label><span>happy@hospital.com</span></div>
                <div class="bds-row"><label>PetCare 계정</label><span>minjun@email.com</span></div>
            </div>
            <div class="bds">
                <div class="bds-title">제출 서류</div>
                <div class="doc-viewer">
                    <div class="doc-viewer-head">사업자등록증
                        <button class="adm-btn blue" onclick="alert('새 창에서 원본 파일을 확인합니다.')">원본 보기</button>
                    </div>
                    <img src="https://images.unsplash.com/photo-1450101499163-c8848c66ca85?w=600&q=70" alt="사업자등록증">
                </div>
                <div class="doc-viewer">
                    <div class="doc-viewer-head">영업신고증
                        <button class="adm-btn blue" onclick="alert('새 창에서 원본 파일을 확인합니다.')">원본 보기</button>
                    </div>
                    <img src="https://images.unsplash.com/photo-1516574187841-cb9cc2ca948b?w=600&q=70" alt="영업신고증">
                </div>
            </div>
            <div class="bds">
                <div class="bds-title">약관 동의 내역</div>
                <div class="bds-row"><label>[필수] 파트너 서비스 이용약관</label><span>동의 · 2025.06.25</span></div>
            </div>
        </div>
        <div>
            <div class="approve-card">
                <h3>승인 처리</h3>
                <div class="approve-status-box"><span>관리자 검토 대기 중</span></div>
                <div class="approve-checklist">
                    <label class="approve-check"><input type="checkbox">사업자등록번호 국세청 인증 확인</label>
                </div>
                <div class="approve-reject-area">
                    <label>반려 사유 (반려 시 필수 입력)</label>
                    <textarea placeholder="반려 사유를 입력하면 신청자에게 이메일로 발송됩니다."></textarea>
                </div>
                <div class="approve-btn-row">
                    <button class="btn-approve" onclick="alert('승인 완료!')">승인하기</button>
                    <button class="btn-reject" onclick="alert('반려 처리되었습니다.')">반려하기</button>
                </div>
            </div>
        </div>
    </div>
    ========== [변경 전] 끝 ========== --%>

</main>

<%@ include file="/WEB-INF/views/admin/common/footer.jsp" %>
