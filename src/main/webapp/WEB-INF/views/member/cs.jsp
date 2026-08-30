<%--
  역할: 고객센터 메인
  - 박유정 / 2026-07-22 — 정지 회원 접근 허용 화면 (스타일은 petcare.css)
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="cs" />

<%@ include file="/WEB-INF/views/common/header.jsp" %>

<main class="cs-page">
<div class="cs-hero">
    <div class="cs-wrap" style="margin:0 auto;padding:0 20px">
        <h1>고객센터</h1>
        <p>PetCare 이용 중 궁금한 점을 빠르게 해결해 드립니다</p>
    </div>
</div>

<div class="cs-wrap">
    <%-- 2026-07-24 박유정 — 정지 회원이 다른 메뉴 접근 시 인터셉터 리다이렉트 안내 --%>
    <c:if test="${param.restricted eq '1'}">
        <div class="cs-restricted-notice" role="alert">
            정지된 회원은 고객센터만 이용할 수 있습니다.
        </div>
    </c:if>
    <div class="cs-contact">
        <div class="cs-contact-card">
            <svg viewBox="0 0 24 24"><path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07 19.5 19.5 0 01-6-6 19.79 19.79 0 01-3.07-8.67A2 2 0 014.11 2h3a2 2 0 012 1.72c.127.96.361 1.903.7 2.81a2 2 0 01-.45 2.11L8.09 9.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0122 16.92z"/></svg>
            <h3>전화 문의</h3>
            <p>평일 09:00 ~ 18:00</p>
            <strong>1588-0000</strong>
        </div>
        <div class="cs-contact-card">
            <svg viewBox="0 0 24 24"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
            <h3>이메일 문의</h3>
            <p>24시간 접수</p>
            <strong>help@petcare.kr</strong>
        </div>
        <div class="cs-contact-card">
            <svg viewBox="0 0 24 24"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg>
            <h3>1:1 문의</h3>
            <p>문의 내역 확인 및 작성</p>
            <strong><a href="${contextPath}/member/cs/inquiry" style="color:var(--primary);text-decoration:none">문의하기 →</a></strong>
        </div>
    </div>

    <%-- 2026-08-11 박유정 — FAQ DB 연동 (TB_FAQ, VISIBLE_YN=Y) --%>
    <section class="cs-section">
        <h2 class="cs-section-title">자주 묻는 질문</h2>
        <c:choose>
            <c:when test="${empty faqList}">
                <p style="color:var(--text-muted);font-size:14px;padding:12px 0">
                    등록된 FAQ가 없습니다.
                </p>
            </c:when>
            <c:otherwise>
                <c:forEach var="faq" items="${faqList}">
                    <div class="cs-faq-item">
                        <button type="button" class="cs-faq-q" onclick="this.parentElement.classList.toggle('open')">
                            <c:out value="${faq.question}"/>
                            <span>+</span>
                        </button>
                        <div class="cs-faq-a"><c:out value="${faq.answer}"/></div>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </section>

    <%-- 2026-08-11 박유정 — 공지사항 DB 연동 (TB_NOTICE, VISIBLE_YN=Y) --%>
    <section class="cs-section">
        <h2 class="cs-section-title">공지사항</h2>
        <div class="cs-notice-list">
            <c:choose>
                <c:when test="${empty noticeList}">
                    <p style="color:var(--text-muted);font-size:14px;padding:12px 0">
                        등록된 공지가 없습니다.
                    </p>
                </c:when>
                <c:otherwise>
                    <c:forEach var="n" items="${noticeList}">
                        <a href="${contextPath}/member/cs/notice?id=${n.noticeId}" class="cs-notice-item">
                            <span class="cs-notice-badge${n.noticeTypeCd eq 'INFO' ? ' info' : ''}">
                                <c:choose>
                                    <c:when test="${n.noticeTypeCd eq 'INFO'}">안내</c:when>
                                    <c:otherwise>공지</c:otherwise>
                                </c:choose>
                            </span>
                            <span class="cs-notice-title"><c:out value="${n.title}"/></span>
                            <span class="cs-notice-date">
                                <fmt:formatDate value="${n.regDate}" pattern="yyyy.MM.dd"/>
                            </span>
                        </a>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>
    </section>
</div>
</main>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
