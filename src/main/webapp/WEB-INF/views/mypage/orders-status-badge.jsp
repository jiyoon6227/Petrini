<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- 2026/08/13 장우철 — 주문내역/상세 공통 상태 뱃지 --%>
<c:choose>
  <c:when test="${o.statusBadge == 'CANCEL_REQUEST'}"><span class="badge-status badge-cancel">결제취소신청</span></c:when>
  <c:when test="${o.statusBadge == 'REFUND_DONE'}"><span class="badge-status badge-cancel">환불완료</span></c:when>
  <c:when test="${o.statusBadge == 'PARTIAL_REFUND'}"><span class="badge-status badge-cancel">부분환불</span></c:when>
  <c:when test="${o.statusBadge == 'REFUND_PROGRESS'}"><span class="badge-status badge-cancel">환불진행중</span></c:when>
  <c:when test="${o.statusBadge == 'PAID'}"><span class="badge-status badge-ready">결제완료</span></c:when>
  <c:when test="${o.statusBadge == 'READY'}"><span class="badge-status badge-ready">배송준비</span></c:when>
  <c:when test="${o.statusBadge == 'SHIPPING'}"><span class="badge-status badge-ready">배송중</span></c:when>
  <c:when test="${o.statusBadge == 'CONFIRMED'}"><span class="badge-status badge-done">구매확정</span></c:when>
  <c:when test="${o.statusBadge == 'DONE'}"><span class="badge-status badge-done">배송완료</span></c:when>
  <c:when test="${o.statusBadge == 'CANCEL'}"><span class="badge-status badge-cancel">취소완료</span></c:when>
  <c:when test="${o.orderStatus == 'PAID'}"><span class="badge-status badge-ready">결제완료</span></c:when>
  <c:when test="${o.orderStatus == 'READY'}"><span class="badge-status badge-ready">배송준비</span></c:when>
  <c:when test="${o.orderStatus == 'SHIPPING'}"><span class="badge-status badge-ready">배송중</span></c:when>
  <c:when test="${o.orderStatus == 'DONE' && o.confirmYn == 'Y'}"><span class="badge-status badge-done">구매확정</span></c:when>
  <c:when test="${o.orderStatus == 'DONE'}"><span class="badge-status badge-done">배송완료</span></c:when>
  <c:when test="${o.orderStatus == 'CANCEL'}"><span class="badge-status badge-cancel">취소완료</span></c:when>
</c:choose>
