<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="mypage" />
<c:set var="sec" value="notifications" />

<%@ include file="/WEB-INF/views/common/header.jsp" %>
<link rel="stylesheet" href="${contextPath}/resources/css/mypage.css">

<div class="mypage-wrap">
<%@ include file="/WEB-INF/views/mypage/sidebar.jsp" %>
<div class="mypage-content">

<%-- 2026-07-09 장우철 — 알림함 TB_NOTIFICATION 목록 연동 (이메일/푸시 API 없이 DB만) --%>
<div class="mp-section active">
    <h2 class="mp-title">알림함</h2>
    <p class="mp-desc">주문, 예약, 공지 알림을 확인하세요.</p>
    <%-- 2026-07-10 장우철 — 전체 읽음 / 전체 삭제 POST 연동 --%>
    <c:if test="${not empty msg}">
        <div style="background:#EFF6FF;border:1px solid #BFDBFE;color:#1D4ED8;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:14px">${msg}</div>
    </c:if>
    <div class="noti-actions">
        <form method="post" action="${contextPath}/mypage/notifications/read-all" style="display:inline">
            <!--HYJ 26.08.05-->
            <input type="hidden" name="_csrf" value="${_csrf}">
            
            <button type="submit" class="btn-sm">전체 읽음</button>
        </form>
        <form method="post" action="${contextPath}/mypage/notifications/delete-all" style="display:inline"
              onsubmit="return confirm('알림을 모두 삭제할까요?');">
            <!--HYJ 26.08.05-->
            <input type="hidden" name="_csrf" value="${_csrf}">
            
            <button type="submit" class="btn-sm danger">전체 삭제</button>
        </form>
    </div>
    <div class="mp-tab-bar" id="notiTabBar">
        <button type="button" class="mp-tab on" data-filter="ALL">전체</button>
        <button type="button" class="mp-tab" data-filter="ORDER">주문</button>
        <button type="button" class="mp-tab" data-filter="RESERVE">예약</button>
        <button type="button" class="mp-tab" data-filter="STOCK">재고</button>
        <button type="button" class="mp-tab" data-filter="NOTICE">공지</button>
    </div>
    <div class="noti-list" id="notiList">
        <c:choose>
        <c:when test="${empty list}">
            <p class="mp-empty" style="padding:40px 0;text-align:center;color:var(--text-muted)">받은 알림이 없습니다.</p>
        </c:when>
        <c:otherwise>
            <c:forEach var="item" items="${list}">
                <c:set var="iconClass" value="notice" />
                <c:set var="tabGroup" value="NOTICE" />
                <c:choose>
                    <c:when test="${item.notiType eq 'ORDER'}">
                        <c:set var="iconClass" value="order" />
                        <c:set var="tabGroup" value="ORDER" />
                    </c:when>

                    <c:when test="${item.notiType eq 'RESERVE'}">
                        <c:set var="iconClass" value="resv" />
                        <c:set var="tabGroup" value="RESERVE" />
                    </c:when>

                    <c:when test="${item.notiType eq 'STOCK'}">
                        <c:set var="iconClass" value="stock" />
                        <c:set var="tabGroup" value="STOCK" />
                    </c:when>

                    <c:when test="${item.notiType eq 'COMMUNITY'}">
                        <c:set var="iconClass" value="chat" />
                        <c:set var="tabGroup" value="NOTICE" />
                    </c:when>

                    <c:otherwise>
                        <c:set var="iconClass" value="notice" />
                        <c:set var="tabGroup" value="NOTICE" />
                    </c:otherwise>
                </c:choose>
                <div class="noti-item ${item.isRead ne 'Y' ? 'unread' : ''}"
                     data-noti-type="${tabGroup}"
                     style="cursor:pointer"
                     onclick="location.href='${contextPath}/mypage/notifications/detail?notiId=${item.notiId}'">
                    <div class="noti-dot ${item.isRead eq 'Y' ? 'read' : ''}"></div>
                    <div class="noti-icon ${iconClass}">
                        <c:choose>
                        <c:when test="${iconClass eq 'order'}">
                            <svg viewBox="0 0 24 24"><path d="M6 2L3 6v14a2 2 0 002 2h14a2 2 0 002-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 01-8 0"/></svg>
                        </c:when>
                        <c:when test="${iconClass eq 'resv'}">
                            <svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="3" y1="10" x2="21" y2="10"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="16" y1="2" x2="16" y2="6"/></svg>
                        </c:when>

                        <c:when test="${iconClass eq 'chat'}">
                            <svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg>
                        </c:when>

                        <c:when test="${iconClass eq 'stock'}">
                            <svg viewBox="0 0 24 24"><path d="M21 8L12 3 3 8l9 5 9-5z"/><path d="M3 8v8l9 5 9-5V8"/><path d="M12 13v8"/></svg>
                        </c:when>
                        
                        <c:otherwise>
                            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                        </c:otherwise>

                        </c:choose>
                    </div>
                    <div class="noti-body">
                        <div class="noti-msg"><b>${item.title}</b><br>${item.content}</div>
                        <div class="noti-time">
                            <fmt:formatDate value="${item.regDate}" pattern="yyyy.MM.dd HH:mm"/>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </c:otherwise>
        </c:choose>
    </div>
</div>

<%--
[변경 전 더미 UI] 2026-07-09 장우철
    <div class="noti-list">
        <div class="noti-item unread" ... onclick="...detail?type=order"> ... </div>
        ...
    </div>
--%>

<script>
(function() {
    var tabBar = document.getElementById('notiTabBar');
    if (!tabBar) return;
    tabBar.querySelectorAll('.mp-tab').forEach(function(tab) {
        tab.addEventListener('click', function() {
            tabBar.querySelectorAll('.mp-tab').forEach(function(t) { t.classList.remove('on'); });
            this.classList.add('on');
            var filter = this.getAttribute('data-filter');
            document.querySelectorAll('#notiList .noti-item').forEach(function(item) {
                var type = item.getAttribute('data-noti-type');
                item.style.display = (filter === 'ALL' || filter === type) ? '' : 'none';
            });
        });
    });
})();
</script>

</div><%-- /mypage-content --%>
</div><%-- /mypage-wrap --%>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
