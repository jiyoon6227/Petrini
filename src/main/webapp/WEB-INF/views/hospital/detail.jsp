<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="hospital" />
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<style>
  .hdetail-wrap{max-width:var(--inner-width);margin:32px auto 80px;padding:0 20px;display:grid;grid-template-columns:1fr 320px;gap:28px;align-items:flex-start}
  .hdetail-main{}
  .hdetail-photos{display:grid;grid-template-columns:2fr 1fr 1fr;gap:8px;margin-bottom:24px;border-radius:var(--radius-md);overflow:hidden}
  .hdetail-photos img{width:100%;height:200px;object-fit:cover;display:block}
  .hdetail-photos img:first-child{height:100%;grid-row:span 2}
  .hdetail-head{display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:16px}
  .hdetail-tags{display:flex;gap:6px;flex-wrap:wrap;margin-bottom:6px}
  .hdtag{font-size:11px;font-weight:700;padding:3px 10px;border-radius:20px}
  .hdtag.type{background:var(--primary-light);color:var(--primary-dark)}
  .hdtag.open{background:#DCFCE7;color:#16A34A}
  .hdetail-name{font-size:24px;font-weight:800;color:var(--text-main);margin-bottom:8px}
  .hdetail-rating{display:flex;align-items:center;gap:6px;font-size:15px;font-weight:700;color:var(--text-main)}
  .hdetail-rating svg{width:16px;height:16px;fill:var(--yellow)}
  .hdetail-info-grid{display:grid;grid-template-columns:1fr 1fr;gap:14px;margin-bottom:24px}
  .hdinfo-card{background:var(--bg-page);border-radius:var(--radius-sm);padding:16px}
  .hdinfo-label{font-size:12px;color:var(--text-muted);font-weight:600;margin-bottom:6px;display:flex;align-items:center;gap:5px}
  .hdinfo-label svg{width:13px;height:13px;stroke:var(--text-muted);fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}
  .hdinfo-val{font-size:14px;color:var(--text-main);line-height:1.5}
  .dept-tags{display:flex;flex-wrap:wrap;gap:6px}
  .dept-tag{font-size:12px;background:#fff;border:1px solid var(--border);padding:4px 10px;border-radius:20px;color:var(--text-sub)}
  /* 리뷰 */
  .review-item{border:1px solid var(--border);border-radius:var(--radius-md);padding:16px;margin-bottom:12px;overflow:hidden;min-width:0}
  .review-item-head{display:flex;justify-content:space-between;margin-bottom:8px}
  .reviewer-name{font-size:14px;font-weight:700;color:var(--text-main)}
  .review-item-stars{display:flex;gap:2px}
  .review-item-stars svg{width:13px;height:13px;fill:var(--yellow)}
  .review-item-date{font-size:12px;color:var(--text-muted)}
  .review-item-text{font-size:14px;color:var(--text-sub);line-height:1.6;word-break:break-word;overflow-wrap:anywhere}
  /* 2026/08/12 장우철 — 사업자 답글 긴 문자열 줄바꿈 */
  .review-biz-reply{margin-top:10px;padding:10px 12px;background:var(--bg-page);border-radius:8px;font-size:13px;color:var(--text-sub);max-width:100%;box-sizing:border-box;overflow-wrap:anywhere;word-break:break-word}
  .review-biz-reply-text{margin-top:4px;white-space:pre-wrap;line-height:1.6;overflow-wrap:anywhere;word-break:break-word}
  /* 사이드 예약 카드 */
  .reserve-card{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);padding:24px;position:sticky;top:20px}
  .reserve-card h3{font-size:16px;font-weight:800;margin:0 0 20px;color:var(--text-main)}
  .reserve-info-row{display:flex;justify-content:space-between;font-size:14px;margin-bottom:12px;color:var(--text-sub)}
  .reserve-info-row strong{color:var(--text-main)}
  .btn-reserve-big{width:100%;padding:15px;border:none;border-radius:var(--radius-sm);background:var(--primary);color:#fff;font-size:16px;font-weight:800;cursor:pointer;margin-top:8px;transition:var(--transition)}
  .btn-reserve-big:hover{background:var(--primary-dark)}
  .btn-call{width:100%;padding:12px;border:2px solid var(--primary);border-radius:var(--radius-sm);background:#fff;color:var(--primary);font-size:14px;font-weight:700;cursor:pointer;margin-top:10px;display:flex;align-items:center;justify-content:center;gap:6px}
  .btn-call svg{width:16px;height:16px;stroke:currentColor;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}
</style>

<div class="hdetail-wrap">
  <div class="hdetail-main">
    <div class="hdetail-photos">
      <%-- <img src="https://images.unsplash.com/photo-1628009368231-7bb7cfcb0def?w=600&q=70&auto=format&fit=crop" alt="병원메인" onerror="this.src='https://placehold.co/600x400/E0F2FE/0284C7?text=병원'">
      <img src="https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=300&q=70&auto=format&fit=crop" alt="병원2" onerror="this.src='https://placehold.co/300x200/E0F2FE/0284C7?text=병원'">
      <img src="https://images.unsplash.com/photo-1551601651-2a8555f1a136?w=300&q=70&auto=format&fit=crop" alt="병원3" onerror="this.src='https://placehold.co/300x200/E0F2FE/0284C7?text=병원'"> --%>
      <c:forEach var="img" items="${imgList}">
        <div class="swiper-slide">
            <img src="${contextPath}/upload/${img.fileUrl}" alt="${hospital.name}">
        </div>
      </c:forEach>
    </div>
    <div class="hdetail-head">
      <div>
        <div class="hdetail-tags"><span class="hdtag type">동물병원</span><span class="hdtag open">진료중</span></div>
        <div class="hdetail-name">${hospital.name}</div>
        <div class="hdetail-rating">
          <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
          <%-- 2026/07/13 장우철 — TB_HOSPITAL.AVG_RATING / REVIEW_CNT --%>
          <c:choose>
            <c:when test="${not empty hospital.avgRating}">
              <fmt:formatNumber value="${hospital.avgRating}" pattern="0.0"/>
            </c:when>
            <c:otherwise>0.0</c:otherwise>
          </c:choose>
          <span style="font-size:13px;color:var(--text-muted);font-weight:400">
            (<c:out value="${empty hospital.reviewCnt ? 0 : hospital.reviewCnt}"/>개 리뷰)
          </span>
        </div>
      </div>
    </div>
    <div class="hdetail-info-grid">
      <div class="hdinfo-card">
        <div class="hdinfo-label"><svg viewBox="0 0 24 24"><path d="M21 10c0 7-9 13-9 13S3 17 3 10a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/></svg>주소</div>
        <div class="hdinfo-val">${hospital.addr}
          <%-- <br><small style="color:var(--text-muted)">현재 위치에서 0.8km</small> --%>
        </div>
      </div>
      <div class="hdinfo-card">
        <div class="hdinfo-label"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>운영시간</div>
        <input type="hidden" id="hoursJsonData" value='${hospital.hoursJson}'>
        <div class="hdinfo-val" id="hoursArea">등록된 운영시간이 없습니다</div>
      </div>
      <div class="hdinfo-card">
        <div class="hdinfo-label"><svg viewBox="0 0 24 24"><path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07A19.5 19.5 0 013.86 9.87 19.79 19.79 0 01.75 1.22 2 2 0 012.72 0h3a2 2 0 012 1.72 12.84 12.84 0 00.7 2.81 2 2 0 01-.45 2.11L6.91 7.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45c.9.356 1.844.559 2.81.7A2 2 0 0122 16.92z"/></svg>전화번호</div>
        <div class="hdinfo-val">${hospital.phone}</div>
      </div>
      <div class="hdinfo-card">
        <div class="hdinfo-label"><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>병원 특성</div>
        <div class="dept-tags">
          <c:choose>
            <c:when test="${not empty hospital.tagList}">
              <c:forEach var="tag" items="${fn:split(hospital.tagList, ',')}">
                <c:set var="t" value="${fn:trim(tag)}" />
                <c:if test="${t == '24H'}"><span class="dept-tag">24시간 진료</span></c:if>
                <c:if test="${t == 'EXOTIC'}"><span class="dept-tag">특수동물 진료</span></c:if>
                <c:if test="${t == 'HOSPITEL'}"><span class="dept-tag">호스피텔 가능</span></c:if>
                <c:if test="${t == 'INPATIENT'}"><span class="dept-tag">입원 진료</span></c:if>
                <c:if test="${t == 'EMERGENCY'}"><span class="dept-tag">응급 진료</span></c:if>
                <c:if test="${t == 'PARKING'}"><span class="dept-tag">주차 가능</span></c:if>
              </c:forEach>
            </c:when>
            <c:otherwise>
              <span style="font-size:13px;color:var(--text-muted)">등록된 특성이 없습니다</span>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </div>
    <%-- <div style="background:var(--bg-page);border-radius:var(--radius-md);overflow:hidden;height:200px;margin-bottom:28px" id="map">
      <img src="https://images.unsplash.com/photo-1524661135-423995f22d0b?w=900&q=70&auto=format&fit=crop" style="width:100%;height:100%;object-fit:cover" alt="지도" onerror="this.src='https://placehold.co/900x200/EAF7F2/2BAB82?text=카카오맵+위치'">
    </div> --%>
    <div id="kakao-map" style="width:100%;height:280px;border-radius:12px;overflow:hidden;margin-bottom:28px"></div>
    <%@ include file="/WEB-INF/views/common/kakaomap.jsp" %>
    <%-- 2026/07/13 장우철 — 더미 리뷰 제거, TB_REVIEW 실데이터 --%>
    <h3 style="font-size:18px;font-weight:800;margin-bottom:16px">
      진료 리뷰 (<c:out value="${empty hospital.reviewCnt ? 0 : hospital.reviewCnt}"/>)
    </h3>
    <c:if test="${empty reviewList}">
      <p style="font-size:14px;color:var(--text-muted);padding:12px 0">아직 등록된 리뷰가 없습니다.</p>
    </c:if>
    <c:forEach var="rv" items="${reviewList}">
      <div class="review-item">
        <div class="review-item-head">
          <div>
            <span class="reviewer-name"><c:out value="${empty rv.nickname ? '회원' : rv.nickname}"/></span>
            <c:if test="${not empty rv.petName}">
              <span style="color:var(--text-muted);font-size:12px">· <c:out value="${rv.petName}"/>
                <c:if test="${not empty rv.petSpecies}"> (<c:out value="${rv.petSpecies}"/>)</c:if>
              </span>
            </c:if>
          </div>
          <div style="display:flex;flex-direction:column;align-items:flex-end;gap:3px">
            <div class="review-item-stars" style="font-size:13px;color:var(--yellow);font-weight:700">
              ★ <fmt:formatNumber value="${rv.rating}" pattern="0.#"/>
            </div>
            <span class="review-item-date"><fmt:formatDate value="${rv.regDate}" pattern="yyyy.MM.dd"/></span>
          </div>
        </div>
        <div class="review-item-text"><c:out value="${rv.content}"/></div>
        <c:if test="${not empty rv.bizReply}">
          <div class="review-biz-reply">
            <strong>병원 답글</strong>
            <div class="review-biz-reply-text"><c:out value="${rv.bizReply}"/></div>
          </div>
        </c:if>
      </div>
    </c:forEach>
  </div>

  <div class="reserve-card">
    <h3>예약하기</h3>
    <div class="reserve-info-row"><span>오늘 예약 가능</span><strong style="color:var(--primary)">${todayAvailableSlots}슬롯</strong></div>
    <button class="btn-reserve-big" onclick="location.href='${contextPath}/hospital/reserve?id=${hospital.hospitalId}'">예약하기</button>
    <button class="btn-call" onclick="location.href='tel:${hospital.phone}'"><svg viewBox="0 0 24 24"><path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07A19.5 19.5 0 013.86 9.87 19.79 19.79 0 01.75 1.22 2 2 0 012.72 0h3a2 2 0 012 1.72 12.84 12.84 0 00.7 2.81 2 2 0 01-.45 2.11L6.91 7.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45c.9.356 1.844.559 2.81.7A2 2 0 0122 16.92z"/></svg>${hospital.phone}</button>
  </div>
</div>

<script>
  (function() {
      var jsonText = document.getElementById('hoursJsonData').value;
      if (!jsonText || jsonText === '' || jsonText === 'null') return;

      var hours;
      try { hours = JSON.parse(jsonText); } catch(e) { return; }

      var DAYS = ['월','화','수','목','금','토','일','공휴일'];
      var lines = [];

      for (var i = 0; i < DAYS.length; i++) {
          var day  = DAYS[i];
          var info = hours[day];

          if (!info) {
              lines.push('<span style="color:var(--text-muted)">' + day + '  휴무</span>');
              continue;
          }

          var text = day + '  ' + info.open + ' ~ ' + info.close;
          if (info.lunchStart && info.lunchEnd) {
              text += '  <span style="color:var(--text-muted);font-size:12px">(점심 '
                    + info.lunchStart + '~' + info.lunchEnd + ')</span>';
          }
          lines.push(text);
      }

      document.getElementById('hoursArea').innerHTML = lines.join('<br>');
  })();
</script>
<%@ include file="/WEB-INF/views/common/footer.jsp" %>
