<%--
  - 박유정 / 2026-07-16 (기본정보), 2026-07-20 (STEP 7·8), 2026-07-21 (STEP 9~11·② 기간정지)
  - GET  /admin/member/detail?id= → ${member}, ${pointList}, ${orderList}
  - STEP 7: POST 정지·복구·강제탈퇴 (위험 영역)
  - STEP 8: 활동 현황 DB 연동
  - STEP 9: 등급 변경 POST /admin/member/grade
  - STEP 10: 포인트 지급·차감 POST /admin/member/point
  - STEP 11: 최근 주문 내역 ${orderList}
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="adminPage"   value="member-list" />
<%@ include file="/WEB-INF/views/admin/common/header.jsp" %>
<%@ include file="/WEB-INF/views/admin/common/sidebar.jsp" %>

<style>
    /* ── 회원 상세 전용 ── */
    .mem-profile-card {
        background:#fff; border:1px solid #E4E6ED; border-radius:12px;
        padding:28px; display:flex; gap:24px; align-items:flex-start;
        margin-bottom:20px;
    }
    .mem-avatar {
        width:88px; height:88px; border-radius:50%;
        object-fit:cover; border:3px solid #E4E6ED; flex-shrink:0;
    }
    .mem-profile-info { flex:1; }
    .mem-name   { font-size:22px; font-weight:800; color:#1A1A2E; margin-bottom:6px; }
    .mem-email  { font-size:14px; color:#999; margin-bottom:12px; }
    .mem-badges { display:flex; gap:8px; flex-wrap:wrap; }
    .mem-badge  { font-size:12px; font-weight:700; padding:4px 12px; border-radius:20px; }
    .mb-role-user  { background:#EEF2FF; color:#3B5BDB; }
    .mb-role-biz   { background:#EAF7F2; color:#1F8464; }
    .mb-role-admin { background:#FEE2E2; color:#DC2626; }
    .mb-active  { background:#DCFCE7; color:#16A34A; }
    .mb-banned  { background:#FEE2E2; color:#DC2626; }
    .mem-profile-actions { display:flex; flex-direction:column; gap:8px; flex-shrink:0; }

    /* 섹션 그리드 */
    .mem-detail-grid { display:grid; grid-template-columns:1fr 1fr; gap:20px; margin-bottom:20px; }
    .mem-info-section { background:#fff; border:1px solid #E4E6ED; border-radius:12px; padding:22px; }
    .mem-info-section.full { grid-column:1/-1; }
    .mis-title {
        font-size:14px; font-weight:800; color:#1A1A2E;
        margin:0 0 16px; padding-bottom:12px;
        border-bottom:1px solid #E4E6ED;
        display:flex; align-items:center; gap:8px;
    }
    .mis-title svg { width:16px; height:16px; stroke:#3B5BDB; fill:none; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; }
    .mis-row { display:flex; justify-content:space-between; align-items:center; padding:9px 0; border-bottom:1px solid #F5F5F5; font-size:14px; }
    .mis-row:last-child { border-bottom:none; }
    .mis-row label { color:#999; font-size:13px; }
    .mis-row span  { color:#1A1A2E; font-weight:600; }

    /* 포인트 관리 */
    .point-summary-row { display:grid; grid-template-columns:repeat(3,1fr); gap:12px; margin-bottom:18px; }
    .point-box { background:#F8F9FF; border:1px solid #E4E6ED; border-radius:8px; padding:16px; text-align:center; }
    .point-box .pb-label { font-size:12px; color:#999; margin-bottom:6px; }
    .point-box .pb-val   { font-size:20px; font-weight:800; color:#3B5BDB; }
    .point-box .pb-unit  { font-size:12px; color:#888; }
    .point-input-row { display:flex; gap:10px; align-items:flex-end; margin-bottom:14px; }
    .point-input-group { display:flex; flex-direction:column; gap:5px; flex:1; }
    .point-input-group label { font-size:12px; font-weight:600; color:#555; }
    .point-input-group select,
    .point-input-group input {
        border:1px solid #E4E6ED; border-radius:8px;
        padding:9px 12px; font-size:14px; color:#1A1A2E;
        outline:none; font-family:inherit;
    }
    .point-input-group select:focus,
    .point-input-group input:focus { border-color:#3B5BDB; }
    .point-input-group input { width:100%; box-sizing:border-box; }
    .btn-point-apply {
        padding:9px 20px; border:none; border-radius:8px;
        background:#3B5BDB; color:#fff;
        font-size:13px; font-weight:700; cursor:pointer;
        white-space:nowrap; flex-shrink:0;
        transition:background .15s;
    }
    .btn-point-apply:hover { background:#2F4AC7; }
    .point-history { border:1px solid #E4E6ED; border-radius:8px; overflow:hidden; }

    /* 등급 변경 셀렉트 */
    .grade-select-row { display:flex; gap:10px; align-items:center; }
    .grade-select-row select {
        flex:1; border:1px solid #E4E6ED; border-radius:8px;
        padding:9px 12px; font-size:14px; color:#1A1A2E; outline:none;
    }
    .grade-select-row select:focus { border-color:#3B5BDB; }

    /* 위험 영역 */
    .danger-zone { border:1px solid #FCA5A5; border-radius:8px; padding:18px; background:#FFF5F5; }
    .danger-zone p { font-size:13px; color:#DC2626; margin:0 0 12px; line-height:1.6; }
    .danger-btns { display:flex; gap:10px; }
</style>

<main class="adm-main">
    <c:if test="${not empty successMsg}">
        <div style="background:#ECFDF5;border:1px solid #BBF7D0;color:#166534;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:14px">${successMsg}</div>
    </c:if>
    <c:if test="${not empty errorMsg}">
        <div style="background:#FEF2F2;border:1px solid #FECACA;color:#B91C1C;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:14px">${errorMsg}</div>
    </c:if>
    <%-- 상단 breadcrumb --%>
    <div style="display:flex;align-items:center;gap:8px;font-size:13px;color:#999;margin-bottom:20px">
        <a href="${contextPath}/admin/member/list" style="color:#999;text-decoration:none">회원 관리</a>
        <span>›</span>
        <span style="color:#1A1A2E;font-weight:600">회원 상세</span>
    </div>

    <%-- 프로필 카드 --%>
    <div class="mem-profile-card">
        <img class="mem-avatar"
             src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=176&q=80&auto=format&fit=crop"
             alt="프로필"
             onerror="this.src='https://placehold.co/88x88/EEF2FF/3B5BDB?text=U'">
                <div class="mem-profile-info">
            <div class="mem-name">${member.memberName}</div>
            <div class="mem-email">${member.email}</div>
            <div class="mem-badges">
                <c:choose>
                    <c:when test="${member.roleType eq 'BIZ'}">
                        <span class="mem-badge mb-role-biz">사업자</span>
                    </c:when>
                    <c:otherwise>
                        <span class="mem-badge mb-role-user">일반회원</span>
                    </c:otherwise>
                </c:choose>
                <c:choose>
                    <c:when test="${member.statusCd eq 'NORMAL'}">
                        <span class="mem-badge mb-active">활성</span>
                    </c:when>
                    <%-- 2026-07-21 박유정 STEP ② — 기간 정지 뱃지 (영구 / ~종료일) --%>
                    <c:when test="${member.statusCd eq 'SUSPENDED'}">
                        <span class="mem-badge mb-banned">
                            <c:choose>
                                <c:when test="${empty member.suspendEndDate}">영구 정지</c:when>
                                <c:otherwise>
                                    정지 (~${member.suspendEndDate.year}.${member.suspendEndDate.monthValue}.${member.suspendEndDate.dayOfMonth})
                                </c:otherwise>
                            </c:choose>
                        </span>
                    </c:when>
                    <c:when test="${member.statusCd eq 'WITHDRAWN'}">
                        <span class="mem-badge" style="background:#F3F4F6;color:#666">탈퇴</span>
                    </c:when>
                    <c:otherwise>
                        <span class="mem-badge">${member.statusCd}</span>
                    </c:otherwise>
                </c:choose>
                <c:choose>
                    <c:when test="${member.gradeCd eq 'GOLD'}">
                        <span class="mem-badge" style="background:#FFF8E1;color:#F59E0B">골드 등급</span>
                    </c:when>
                    <c:when test="${member.gradeCd eq 'SILVER'}">
                        <span class="mem-badge" style="background:#F3F4F6;color:#666">실버 등급</span>
                    </c:when>
                    <c:otherwise>
                        <span class="mem-badge" style="background:#FFF7ED;color:#C2410C">브론즈 등급</span>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
        <div class="mem-profile-actions">
            <a href="${contextPath}/admin/member/list" class="adm-btn gray" style="text-decoration:none;display:inline-flex;align-items:center;gap:6px">
                <svg viewBox="0 0 24 24"><path d="M19 12H5"/><polyline points="12 19 5 12 12 5"/></svg>
                목록으로
            </a>
        </div>
    </div>

    <div class="mem-detail-grid">

        <%-- 기본 정보 — 2026-07-16 박유정 DB 연동 --%>
        <div class="mem-info-section">
            <div class="mis-title">
                <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                기본 정보
            </div>
            <div class="mis-row"><label>회원 ID</label><span>#${member.memberNo}</span></div>
            <div class="mis-row"><label>이름</label><span>${member.memberName}</span></div>
            <div class="mis-row"><label>이메일</label><span>${member.email}</span></div>
            <div class="mis-row"><label>전화번호</label><span>${member.phone}</span></div>
            <div class="mis-row"><label>생년월일</label><span>—</span></div>
            <div class="mis-row"><label>성별</label><span>—</span></div>
            <div class="mis-row"><label>주소</label>
                <span>
                    <c:if test="${not empty member.zipCode}">(${member.zipCode}) </c:if>
                    ${member.addr1} ${member.addr2}
                </span>
            </div>
            <div class="mis-row"><label>가입일</label>
                <span>
                    <c:if test="${not empty member.joinDate}">
                        ${member.joinDate.year}.${member.joinDate.monthValue}.${member.joinDate.dayOfMonth}
                    </c:if>
                </span>
            </div>
            <div class="mis-row"><label>최근 로그인</label>
                <span>
                    <c:if test="${not empty member.lastLoginDate}">
                        ${member.lastLoginDate.year}.${member.lastLoginDate.monthValue}.${member.lastLoginDate.dayOfMonth}
                        ${member.lastLoginDate.hour}:
                        <c:if test="${member.lastLoginDate.minute < 10}">0</c:if>${member.lastLoginDate.minute}
                    </c:if>
                    <c:if test="${empty member.lastLoginDate}">—</c:if>
                </span>
            </div>
            <div class="mis-row"><label>가입 경로</label><span>—</span></div>
        </div>

        <%-- 활동 현황 — 2026-07-20 박유정 STEP 8 DB 연동 --%>
        <div class="mem-info-section">
            <div class="mis-title">
                <svg viewBox="0 0 24 24"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg>
                활동 현황
            </div>
            <div class="mis-row"><label>총 주문 수</label><span>${member.orderCount != null ? member.orderCount : 0}건</span></div>
            <div class="mis-row"><label>총 결제 금액</label><span>${member.totalPayAmount != null ? member.totalPayAmount : 0}원</span></div>
            <div class="mis-row"><label>취소/반품</label><span>${member.cancelCount != null ? member.cancelCount : 0}건</span></div>
            <div class="mis-row"><label>병원 예약</label><span>${member.hospitalResvCount != null ? member.hospitalResvCount : 0}건</span></div>
            <div class="mis-row"><label>커뮤니티 게시글</label><span>${member.postCount != null ? member.postCount : 0}건</span></div>
            <div class="mis-row"><label>신고 횟수</label><span>${member.reportCount != null ? member.reportCount : 0}건</span></div>
            <div class="mis-row"><label>보유 포인트</label><span style="color:#3B5BDB;font-weight:800">${member.pointBalance != null ? member.pointBalance : 0} P</span></div>
            <div class="mis-row"><label>사용 쿠폰</label><span>${member.usedCouponCount != null ? member.usedCouponCount : 0}장</span></div>
            <div class="mis-row"><label>관심 상품</label><span>${member.favoriteCount != null ? member.favoriteCount : 0}개</span></div>
            <div class="mis-row"><label>등록 반려동물</label>
                <span>
                    ${member.petCount != null ? member.petCount : 0}마리
                    <c:if test="${not empty member.petNames}"> (${member.petNames})</c:if>
                </span>
            </div>
        </div>
        <%-- 등급 변경 — 2026-07-21 박유정 STEP 9 DB 연동 --%>
        <div class="mem-info-section">
            <!--HYJ 26.07.28 임시주석 후 활동이력으로 대체-->
            <%-- <div class="mis-title">
                <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                등급 변경
            </div>
            <p style="font-size:13px;color:#999;margin:0 0 14px">
                현재 등급:
                <strong style="color:#F59E0B">
                    <c:choose>
                        <c:when test="${member.gradeCd eq 'GOLD'}">골드</c:when>
                        <c:when test="${member.gradeCd eq 'SILVER'}">실버</c:when>
                        <c:otherwise>브론즈</c:otherwise>
                    </c:choose>
                </strong>
            </p>
            <form method="post" action="${contextPath}/admin/member/grade"
                  class="grade-select-row"
                  onsubmit="return confirm('등급을 변경하시겠습니까?')">
                <input type="hidden" name="memberNo" value="${member.memberNo}">
                <select name="gradeCd" required>
                    <option value="BRONZE" ${member.gradeCd eq 'BRONZE' ? 'selected' : ''}>브론즈</option>
                    <option value="SILVER" ${member.gradeCd eq 'SILVER' ? 'selected' : ''}>실버</option>
                    <option value="GOLD"   ${member.gradeCd eq 'GOLD'   ? 'selected' : ''}>골드</option>
                </select>
                <button type="submit" class="adm-btn blue">변경</button>
            </form>
            <div style="margin-top:14px;font-size:12px;color:#999;line-height:1.6">
                · 브론즈: 기본 등급<br>
                · 실버: 1만 포인트 이상<br>
                · 골드: 5만 포인트 이상
            </div> --%>
            <div class="mis-title">
                <svg viewBox="0 0 24 24"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg>
                활동 이력
            </div>
            <div class="mis-row"><label>게시글 누적</label><span>${member.posts != null ? member.posts : 0}건</span></div>
            <div class="mis-row"><label>댓글 누적</label><span>${member.comments != null ? member.comments : 0}건</span></div>
            <div class="mis-row"><label>관리자 게시글 삭제 누적</label><span>${member.adminPostDelCount != null ? member.adminPostDelCount : 0}건</span></div>
            <div class="mis-row"><label>관리자 댓글 삭제 누적</label><span>${member.adminCommentDelCount != null ? member.adminCommentDelCount : 0}건</span></div>
        </div>
        <%-- 포인트 관리 — 2026-07-21 박유정 STEP 10 DB 연동 --%>
        <div class="mem-info-section">
            <div class="mis-title">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M12 8v4l3 3"/></svg>
                포인트 관리
            </div>
            <div class="point-summary-row">
                <div class="point-box">
                    <div class="pb-label">보유</div>
                    <div class="pb-val">${member.pointBalance != null ? member.pointBalance : 0}<span class="pb-unit"> P</span></div>
                </div>
                <div class="point-box">
                    <div class="pb-label">총 적립</div>
                    <div class="pb-val">${member.totalEarnPoint != null ? member.totalEarnPoint : 0}<span class="pb-unit"> P</span></div>
                </div>
                <div class="point-box">
                    <div class="pb-label">총 사용</div>
                    <div class="pb-val">${member.totalUsePoint != null ? member.totalUsePoint : 0}<span class="pb-unit"> P</span></div>
                </div>
            </div>
            <form method="post" action="${contextPath}/admin/member/point" class="point-input-row">
                <!--HYJ 26.08.05-->
                <input type="hidden" name="_csrf" value="${_csrf}">
                
                <input type="hidden" name="memberNo" value="${member.memberNo}">
                <div class="point-input-group">
                    <label>구분</label>
                    <select name="adjustType" required>
                        <option value="add">지급</option>
                        <option value="sub">차감</option>
                    </select>
                </div>
                <div class="point-input-group" style="flex:2">
                    <label>포인트</label>
                    <input type="number" name="amount" placeholder="0" min="1" required>
                </div>
                <div class="point-input-group" style="flex:2">
                    <label>사유</label>
                    <input type="text" name="reason" placeholder="관리자 지급">
                </div>
                <button type="submit" class="btn-point-apply">처리</button>
            </form>
            <div class="point-history">
                <table class="adm-table" style="font-size:13px">
                    <thead>
                        <tr><th>날짜</th><th>내용</th><th>구분</th><th style="text-align:right">포인트</th></tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty pointList}">
                                <tr><td colspan="4" style="text-align:center;color:#999;padding:20px 0">포인트 이력이 없습니다.</td></tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="p" items="${pointList}">
                                    <tr>
                                        <td>${p.regDate}</td>
                                        <td>${not empty p.reasonDetail ? p.reasonDetail : p.reasonCd}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${p.pointType eq 'EARN'}">
                                                    <span class="adm-badge active">적립</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="adm-badge cancel">차감</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="text-align:right;font-weight:700;
                                            color:${p.pointType eq 'EARN' ? '#3B5BDB' : '#DC2626'}">
                                            ${p.pointType eq 'EARN' ? '+' : '-'}${p.pointAmount} P
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
        <%-- 최근 주문 — 2026-07-21 박유정 STEP 11 DB 연동 --%>
        <div class="mem-info-section full">
            <div class="mis-title">
                <svg viewBox="0 0 24 24"><path d="M6 2L3 6v14a2 2 0 002 2h14a2 2 0 002-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 01-8 0"/></svg>
                최근 주문 내역
            </div>
            <table class="adm-table">
                <thead>
                    <tr><th>주문번호</th><th>상품</th><th>금액</th><th>상태</th><th>주문일</th><th>처리</th></tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty orderList}">
                            <tr>
                                <td colspan="6" style="text-align:center;color:#999;padding:40px 0">
                                    주문 내역이 없습니다.
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="o" items="${orderList}">
                                <tr>
                                    <td>#${o.orderNo}</td>
                                    <td>
                                        ${o.firstProductName}
                                        <c:if test="${o.itemCount != null and o.itemCount > 1}">
                                            외 ${o.itemCount - 1}건
                                        </c:if>
                                    </td>
                                    <td>${o.payAmount != null ? o.payAmount : 0}원</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${o.orderStatus eq 'SHIPPING'}">
                                                <span class="adm-badge shipping">배송중</span>
                                            </c:when>
                                            <c:when test="${o.orderStatus eq 'DELIVERED' or o.orderStatus eq 'DONE'}">
                                                <span class="adm-badge done">배송완료</span>
                                            </c:when>
                                            <c:when test="${o.orderStatus eq 'CANCEL'}">
                                                <span class="adm-badge cancel">취소</span>
                                            </c:when>
                                            <c:when test="${o.orderStatus eq 'PAID'}">
                                                <span class="adm-badge active">결제완료</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="adm-badge">${o.orderStatus}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>${o.orderDate}</td>
                                    <td>
                                        <a href="${contextPath}/admin/store/order-detail?id=${o.orderId}"
                                           class="adm-btn blue" style="text-decoration:none;display:inline-block">
                                            상세
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>

        <%-- 위험 영역 --%>
        <div class="mem-info-section full">
            <div class="mis-title" style="color:#DC2626">
                <svg viewBox="0 0 24 24" style="stroke:#DC2626"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                위험 영역
            </div>
             <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px">

                <%-- 2026-07-21 박유정 STEP ② — 기간 정지 (3일/7일/영구) --%>
                <c:if test="${member.statusCd eq 'NORMAL'}">
                    <div class="danger-zone">
                        <p><strong>계정 정지</strong><br>정지 기간을 선택한 뒤 처리합니다.</p>
                        <form method="post" action="${contextPath}/admin/member/suspend"
                              style="display:flex;gap:8px;align-items:center"
                              onsubmit="return confirm('${member.memberName} 회원을 정지하시겠습니까?')">
                            <!--HYJ 26.08.05-->
                            <input type="hidden" name="_csrf" value="${_csrf}">
                            
                            <input type="hidden" name="memberNo" value="${member.memberNo}">
                            <select name="suspendType" class="adm-filter-select" style="flex:1" required>
                                <option value="DAY3">3일 정지</option>
                                <option value="DAY7">7일 정지</option>
                                <option value="PERMANENT">영구 정지</option>
                            </select>
                            <button type="submit" class="adm-btn red">정지</button>
                        </form>
                    </div>
                </c:if>

                <c:if test="${member.statusCd eq 'SUSPENDED'}">
                    <div class="danger-zone" style="border-color:#86EFAC;background:#F0FDF4">
                        <p><strong>계정 복구</strong><br>정지된 계정을 다시 활성화합니다.</p>
                        <div class="danger-btns">
                            <form method="post" action="${contextPath}/admin/member/restore"
                                  onsubmit="return confirm('${member.memberName} 회원을 복구하시겠습니까?')">
                                <!--HYJ 26.08.05-->
                                <input type="hidden" name="_csrf" value="${_csrf}">  
                                
                                <input type="hidden" name="memberNo" value="${member.memberNo}">
                                <button type="submit" class="adm-btn green">계정 복구</button>
                            </form>
                        </div>
                    </div>
                </c:if>

                <c:if test="${member.statusCd ne 'WITHDRAWN'}">
                    <div class="danger-zone">
                        <p><strong>강제 탈퇴</strong><br>계정을 탈퇴 처리합니다. 이 작업은 되돌릴 수 없습니다.</p>
                        <div class="danger-btns">
                            <form method="post" action="${contextPath}/admin/member/withdraw"
                                  onsubmit="return confirm('정말 강제 탈퇴 처리하시겠습니까?\n이 작업은 되돌릴 수 없습니다.')">
                                <!--HYJ 26.08.05-->
                                <input type="hidden" name="_csrf" value="${_csrf}">  
                                
                                <input type="hidden" name="memberNo" value="${member.memberNo}">
                                <button type="submit" class="adm-btn red">강제 탈퇴</button>
                            </form>
                        </div>
                    </div>
                </c:if>
            </div>
        </div>

    </div><%-- /mem-detail-grid --%>
</main>

<%@ include file="/WEB-INF/views/admin/common/footer.jsp" %>
