<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="동물병원" />
<c:set var="bizPage"      value="reviews" />

<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_hospital.jsp" %>

<%-- 사업자(병원) 리뷰관리: 화면·동작은 공통 조각 review-manage.jsp + biz-review.js --%>
<c:set var="reviewBaseUrl"  value="/biz/hospital/reviews" />
<c:set var="replyLabel"     value="병원 답글" />
<c:set var="reviewPageDesc" value="리뷰 답글을 작성하고 삭제 요청 내역을 확인하세요." />
<c:set var="showThumbnail"  value="${false}" />
<c:set var="showReports"    value="${false}" />
<%@ include file="/WEB-INF/views/biz/common/review-manage.jsp" %>

<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>
