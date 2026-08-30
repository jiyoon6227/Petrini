<%-- give/report/list.jsp — 분실/보호 게시판 탭 --%>
<%--
  - 박유정 / 2026-07-06~07

  [목록 화면 흐름]
  1. GET /give/report/list?status= → giveReportService.getReportList()
  2. status: 전체 / FINDING(찾는중) / OWNER_FOUND(주인찾음) / RESCUED(구조완료)
  3. TB_POST 목록 + thumbUrl(첫 사진) 표시
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId"      value="give" />
<c:set var="giveTab"     value="report" />

<%@ include file="/WEB-INF/views/give/index.jsp" %>

<style>
  .report-toolbar{display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;flex-wrap:wrap;gap:12px}
  .report-filters{display:flex;gap:8px;flex-wrap:wrap}
  .report-chip{display:inline-block;padding:7px 16px;border:1px solid var(--border);border-radius:50px;font-size:13px;color:var(--text-sub);background:#fff;text-decoration:none;transition:var(--transition)}
  .report-chip:hover,.report-chip.on{border-color:var(--primary);background:var(--primary-light);color:var(--primary-dark);font-weight:600}
  .btn-report-write{padding:9px 20px;border:none;border-radius:50px;background:var(--primary);color:#fff;font-size:14px;font-weight:700;cursor:pointer;display:flex;align-items:center;gap:6px}
  .btn-report-write svg{width:14px;height:14px;stroke:#fff;fill:none;stroke-width:2.5;stroke-linecap:round;stroke-linejoin:round}

  .report-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:18px;margin-bottom:32px}
  .report-card{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);overflow:hidden;transition:var(--transition);cursor:pointer}
  .report-card:hover{box-shadow:var(--shadow-md);transform:translateY(-2px)}
  .report-thumb-wrap{position:relative}
  .report-thumb{width:100%;height:200px;object-fit:cover;display:block}
  .report-status{position:absolute;top:10px;left:10px;font-size:11px;font-weight:700;padding:3px 9px;border-radius:20px}
  .rs-finding{background:#FFF8E1;color:#F59E0B}
  .rs-rescued{background:#DCFCE7;color:#16A34A}
  .rs-returned{background:#EEF2FF;color:#3B5BDB}
  .report-map-pin{position:absolute;bottom:10px;right:10px;background:rgba(0,0,0,.55);color:#fff;font-size:11px;font-weight:600;padding:4px 10px;border-radius:20px;display:flex;align-items:center;gap:4px}
  .report-map-pin svg{width:11px;height:11px;stroke:#fff;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}
  .report-body{padding:14px}
  .report-tags{display:flex;gap:6px;flex-wrap:wrap;margin-bottom:8px}
  .report-tag{font-size:11px;font-weight:700;padding:2px 9px;border-radius:20px;background:var(--primary-light);color:var(--primary-dark)}
  .report-title{font-size:14px;font-weight:700;color:var(--text-main);margin-bottom:5px;line-height:1.4;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
  .report-desc{font-size:12px;color:var(--text-muted);line-height:1.6;margin-bottom:10px;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden}
  .report-meta{display:flex;justify-content:space-between;font-size:12px;color:var(--text-muted)}
  .report-meta-left{display:flex;align-items:center;gap:10px}
  .report-meta-item{display:flex;align-items:center;gap:4px}
  .report-meta-item svg{width:12px;height:12px;stroke:currentColor;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round}
</style>

<div class="give-content">
  <div class="report-toolbar">
    <div class="report-filters">
      <c:url var="urlAll" value="/give/report/list"/>
      <c:url var="urlFinding" value="/give/report/list"><c:param name="status" value="FINDING"/></c:url>
      <c:url var="urlOwner" value="/give/report/list"><c:param name="status" value="OWNER_FOUND"/></c:url>
      <c:url var="urlRescued" value="/give/report/list"><c:param name="status" value="RESCUED"/></c:url>
      <a href="${contextPath}${urlAll}" class="report-chip ${empty status ? 'on' : ''}">전체</a>
      <a href="${contextPath}${urlFinding}" class="report-chip ${status eq 'FINDING' ? 'on' : ''}">찾는 중</a>
      <a href="${contextPath}${urlOwner}" class="report-chip ${status eq 'OWNER_FOUND' ? 'on' : ''}">주인 찾음</a>
      <a href="${contextPath}${urlRescued}" class="report-chip ${status eq 'RESCUED' ? 'on' : ''}">구조 완료</a>
    </div>
    <button class="btn-report-write" onclick="location.href='${contextPath}/give/report/write'">
      <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
      발견 신고하기
    </button>
  </div>

  <div style="font-size:14px;color:var(--text-sub);margin-bottom:16px">
    총 <strong style="color:var(--text-main)">${empty list ? 0 : list.size()}</strong>건의 발견 신고가 있습니다
  </div>

  <c:choose>
    <c:when test="${empty list}">
      <p style="text-align:center;color:var(--text-muted);padding:48px 0">등록된 신고가 없습니다.</p>
    </c:when>
    <c:otherwise>
      <div class="report-grid">
        <c:forEach var="item" items="${list}">
          <div class="report-card" onclick="location.href='${contextPath}/give/report/detail?id=${item.postId}'">
            <div class="report-thumb-wrap">
              <%-- thumbUrl: TB_FILE 첫 번째 사진, 없으면 placeholder --%>
              <img class="report-thumb"
                   src="${not empty item.thumbUrl ? contextPath.concat(item.thumbUrl) : 'https://placehold.co/400x200/EAF7F2/2BAB82?text=발견사진'}"
                   alt="발견사진">
              <c:choose>
                <c:when test="${fn:contains(item.tags, 'OWNER_FOUND')}">
                  <span class="report-status rs-returned">주인 찾음</span>
                </c:when>
                <c:when test="${fn:contains(item.tags, 'RESCUED')}">
                  <span class="report-status rs-rescued">구조 완료</span>
                </c:when>
                <c:otherwise>
                  <span class="report-status rs-finding">찾는 중</span>
                </c:otherwise>
              </c:choose>
              <span class="report-map-pin">
                <svg viewBox="0 0 24 24"><path d="M21 10c0 7-9 13-9 13S3 17 3 10a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/></svg>
                ${item.region}
              </span>
            </div>
            <div class="report-body">
              <div class="report-tags">
                <c:if test="${item.lostSpecies eq 'DOG'}"><span class="report-tag">강아지</span></c:if>
                <c:if test="${item.lostSpecies eq 'CAT'}"><span class="report-tag">고양이</span></c:if>
                <c:if test="${item.lostSpecies eq 'ETC'}"><span class="report-tag">기타</span></c:if>
              </div>
              <div class="report-title">${item.title}</div>
              <div class="report-desc">${item.body}</div>
              <div class="report-meta">
                <div class="report-meta-left">
                  <span class="report-meta-item">#${item.postId}</span>
                </div>
                <span>${item.regDate.year}.${item.regDate.monthValue}.${item.regDate.dayOfMonth}</span>
              </div>
            </div>
          </div>
        </c:forEach>
      </div>
    </c:otherwise>
  </c:choose>

  <div style="display:flex;justify-content:center;gap:5px">
    <button style="width:36px;height:36px;border:1px solid var(--border);border-radius:var(--radius-sm);background:#fff;cursor:pointer">‹</button>
    <button style="width:36px;height:36px;border:1px solid var(--primary);border-radius:var(--radius-sm);background:var(--primary);color:#fff;font-weight:700;cursor:pointer">1</button>
    <button style="width:36px;height:36px;border:1px solid var(--border);border-radius:var(--radius-sm);background:#fff;cursor:pointer">2</button>
    <button style="width:36px;height:36px;border:1px solid var(--border);border-radius:var(--radius-sm);background:#fff;cursor:pointer">›</button>
  </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
