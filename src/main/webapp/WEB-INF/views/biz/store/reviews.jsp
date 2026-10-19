<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="반려동물 쇼핑몰" />
<c:set var="bizPage"      value="reviews" />

<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_store.jsp" %>

<%-- 사업자(쇼핑몰) 리뷰관리: 화면·동작은 공통 조각 review-manage.jsp + biz-review.js --%>
<c:set var="reviewBaseUrl"  value="/biz/store/reviews" />
<c:set var="replyLabel"     value="판매자" />
<c:set var="reviewPageDesc" value="상품 리뷰에 답글을 작성하고 삭제 요청·고객 신고를 확인하세요." />
<c:set var="showThumbnail"  value="${true}" />
<c:set var="showReports"    value="${true}" />
<%@ include file="/WEB-INF/views/biz/common/review-manage.jsp" %>

<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>
