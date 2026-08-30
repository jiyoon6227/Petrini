<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="pageId" value="grooming" />
<%@ include file="/WEB-INF/views/common/header.jsp" %>
<style>
  .gdetail-wrap{max-width:var(--inner-width);margin:32px auto 80px;padding:0 20px;display:grid;grid-template-columns:1fr 320px;gap:28px;align-items:flex-start}
  .gdetail-photos{display:grid;grid-template-columns:2fr 1fr 1fr;gap:8px;margin-bottom:24px;border-radius:var(--radius-md);overflow:hidden}
  .gdetail-photos img{width:100%;height:200px;object-fit:cover;display:block}
  .gdetail-photos img:first-child{height:100%;grid-row:span 2}
  .gdetail-head{margin-bottom:16px}
  .gdetail-tags{display:flex;gap:6px;flex-wrap:wrap;margin-bottom:6px}
  .gdtag{font-size:11px;font-weight:700;padding:3px 10px;border-radius:20px}
  .gdtag.type{background:#FDF2F8;color:#DB2777}
  .gdtag.open{background:#DCFCE7;color:#16A34A}
  .gdetail-name{font-size:24px;font-weight:800;color:var(--text-main);margin-bottom:8px}
  .gdetail-rating{display:flex;align-items:center;gap:6px;font-size:15px;font-weight:700;color:var(--text-main)}
  .gdetail-rating svg{width:16px;height:16px;fill:var(--yellow)}
  .gdetail-info-grid{display:grid;grid-template-columns:1fr 1fr;gap:14px;margin-bottom:24px}
  .gdinfo-card{background:var(--bg-page);border-radius:var(--radius-sm);padding:16px}
  .gdinfo-label{font-size:12px;color:var(--text-muted);font-weight:600;margin-bottom:6px;display:flex;align-items:center;gap:5px}
  .gdinfo-label svg{width:13px;height:13px;stroke:var(--text-muted);fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}
  .gdinfo-val{font-size:14px;color:var(--text-main);line-height:1.5}
  .svc-tags{display:flex;flex-wrap:wrap;gap:6px}
  .svc-tag{font-size:12px;background:#fff;border:1px solid var(--border);padding:4px 10px;border-radius:20px;color:var(--text-sub)}
  /* 시술 메뉴 & 가격 */
  .menu-table{width:100%;border-collapse:collapse;margin-bottom:28px;font-size:14px}
  .menu-table th{text-align:left;padding:10px 4px;border-bottom:2px solid var(--border);color:var(--text-muted);font-size:12px;font-weight:700}
  .menu-table td{padding:13px 4px;border-bottom:1px solid var(--border);color:var(--text-sub)}
  .menu-table td.mt-name{color:var(--text-main);font-weight:700}
  .menu-table td.mt-price{color:#DB2777;font-weight:800;text-align:right}
  /* 리뷰 */
  .review-item{border:1px solid var(--border);border-radius:var(--radius-md);padding:16px;margin-bottom:12px}
  .review-item-head{display:flex;justify-content:space-between;margin-bottom:8px}
  .reviewer-name{font-size:14px;font-weight:700;color:var(--text-main)}
  .review-item-stars{display:flex;gap:2px}
  .review-item-stars svg{width:13px;height:13px;fill:var(--yellow)}
  .review-item-date{font-size:12px;color:var(--text-muted)}
  .review-item-text{font-size:14px;color:var(--text-sub);line-height:1.6}
  /* 사이드 예약 카드 */
  .reserve-card{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);padding:24px;position:sticky;top:20px}
  .reserve-card h3{font-size:16px;font-weight:800;margin:0 0 20px;color:var(--text-main)}
  .reserve-info-row{display:flex;justify-content:space-between;font-size:14px;margin-bottom:12px;color:var(--text-sub)}
  .reserve-info-row strong{color:var(--text-main)}
  .btn-gr-reserve-big{width:100%;padding:15px;border:none;border-radius:var(--radius-sm);background:#DB2777;color:#fff;font-size:16px;font-weight:800;cursor:pointer;margin-top:8px;transition:var(--transition)}
  .btn-gr-reserve-big:hover{background:#9D174D}
  .btn-call{width:100%;padding:12px;border:2px solid #DB2777;border-radius:var(--radius-sm);background:#fff;color:#DB2777;font-size:14px;font-weight:700;cursor:pointer;margin-top:10px;display:flex;align-items:center;justify-content:center;gap:6px}
  .btn-call svg{width:16px;height:16px;stroke:currentColor;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}
</style>
<div class="gdetail-wrap">
  <div>
    <div class="gdetail-photos">
      <img src="https://images.unsplash.com/photo-1591946614720-90a587da4a36?w=600&q=70&auto=format&fit=crop" alt="미용실메인" onerror="this.src='https://placehold.co/600x400/FDF2F8/DB2777?text=미용실'">
      <img src="https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?w=300&q=70&auto=format&fit=crop" alt="미용실2" onerror="this.src='https://placehold.co/300x200/FDF2F8/DB2777?text=미용실'">
      <img src="https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=300&q=70&auto=format&fit=crop" alt="미용실3" onerror="this.src='https://placehold.co/300x200/FDF2F8/DB2777?text=미용실'">
    </div>
    <div class="gdetail-head">
      <div class="gdetail-tags"><span class="gdtag type">애견미용실</span><span class="gdtag open">예약가능</span></div>
      <div class="gdetail-name">냥냥 그루밍샵</div>
      <div class="gdetail-rating">
        <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
        4.8 <span style="font-size:13px;color:var(--text-muted);font-weight:400">(96개 리뷰)</span>
      </div>
    </div>
    <div class="gdetail-info-grid">
      <div class="gdinfo-card">
        <div class="gdinfo-label"><svg viewBox="0 0 24 24"><path d="M21 10c0 7-9 13-9 13S3 17 3 10a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/></svg>주소</div>
        <div class="gdinfo-val">서울특별시 마포구 합정동 45-2<br><small style="color:var(--text-muted)">현재 위치에서 0.6km</small></div>
      </div>
      <div class="gdinfo-card">
        <div class="gdinfo-label"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>영업시간</div>
        <div class="gdinfo-val">평일 10:00 ~ 20:00<br>토요일 10:00 ~ 18:00<br>일요일 휴무</div>
      </div>
      <div class="gdinfo-card">
        <div class="gdinfo-label"><svg viewBox="0 0 24 24"><path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07A19.5 19.5 0 013.86 9.87 19.79 19.79 0 01.75 1.22 2 2 0 012.72 0h3a2 2 0 012 1.72 12.84 12.84 0 00.7 2.81 2 2 0 01-.45 2.11L6.91 7.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45c.9.356 1.844.559 2.81.7A2 2 0 0122 16.92z"/></svg>전화번호</div>
        <div class="gdinfo-val">02-3456-7890</div>
      </div>
      <div class="gdinfo-card">
        <div class="gdinfo-label"><svg viewBox="0 0 24 24"><path d="M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78L12 21.23l8.84-8.84a5.5 5.5 0 000-7.78z"/></svg>가능 시술</div>
        <div class="svc-tags">
          <span class="svc-tag">전체미용</span><span class="svc-tag">가위컷</span><span class="svc-tag">위생미용</span>
          <span class="svc-tag">목욕</span><span class="svc-tag">염색</span>
        </div>
      </div>
    </div>

    <div id="kakao-map" style="width:100%;height:280px;border-radius:12px;overflow:hidden;margin-bottom:28px"></div>
    <%@ include file="/WEB-INF/views/common/kakaomap.jsp" %>
    
    <h3 style="font-size:18px;font-weight:800;margin-bottom:16px">시술 메뉴 &amp; 가격</h3>
    <table class="menu-table">
      <thead><tr><th>메뉴</th><th>소요시간</th><th style="text-align:right">가격</th></tr></thead>
      <tbody>
        <tr><td class="mt-name">풀 클립 미용</td><td>90분</td><td class="mt-price">45,000원</td></tr>
        <tr><td class="mt-name">가위컷 스타일링</td><td>120분</td><td class="mt-price">60,000원</td></tr>
        <tr><td class="mt-name">위생 미용</td><td>30분</td><td class="mt-price">15,000원</td></tr>
        <tr><td class="mt-name">기본 목욕 + 드라이</td><td>50분</td><td class="mt-price">20,000원</td></tr>
        <tr><td class="mt-name">부분 염색</td><td>40분</td><td class="mt-price">25,000원</td></tr>
      </tbody>
    </table>

    <h3 style="font-size:18px;font-weight:800;margin-bottom:16px">리뷰 (96)</h3>
    <div class="review-item">
      <div class="review-item-head">
        <div><span class="reviewer-name">김예진</span> <span style="color:var(--text-muted);font-size:12px">· 비숑</span></div>
        <div style="display:flex;flex-direction:column;align-items:flex-end;gap:3px">
          <div class="review-item-stars"><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg></div>
          <span class="review-item-date">2025.06.24</span>
        </div>
      </div>
      <div class="review-item-text">박채원 선생님이 너무 꼼꼼하게 봐주셔서 코코가 훨씬 예뻐졌어요! 다음에도 꼭 다시 방문할게요.</div>
    </div>
    <div class="review-item">
      <div class="review-item-head">
        <div><span class="reviewer-name">최아린</span> <span style="color:var(--text-muted);font-size:12px">· 말티푸</span></div>
        <div style="display:flex;flex-direction:column;align-items:flex-end;gap:3px">
          <div class="review-item-stars"><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg></div>
          <span class="review-item-date">2025.06.20</span>
        </div>
      </div>
      <div class="review-item-text">염색 컬러가 정말 자연스럽게 잘 나왔어요. 망고가 더 사랑스러워졌습니다!</div>
    </div>
  </div>

  <div class="reserve-card">
    <h3>예약하기</h3>
    <div class="reserve-info-row"><span>예약 가능 시간</span><strong>오늘 4슬롯 남음</strong></div>
    <div class="reserve-info-row"><span>평균 소요시간</span><strong>60~90분</strong></div>
    <div class="reserve-info-row"><span>시술 비용</span><strong>15,000원~</strong></div>
    <button class="btn-gr-reserve-big" onclick="location.href='${contextPath}/grooming/reserve?id=${id}'">예약하기</button>
    <button class="btn-call"><svg viewBox="0 0 24 24"><path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07A19.5 19.5 0 013.86 9.87 19.79 19.79 0 01.75 1.22 2 2 0 012.72 0h3a2 2 0 012 1.72 12.84 12.84 0 00.7 2.81 2 2 0 01-.45 2.11L6.91 7.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45c.9.356 1.844.559 2.81.7A2 2 0 0122 16.92z"/></svg>02-3456-7890</button>
  </div>
</div>
<%@ include file="/WEB-INF/views/common/footer.jsp" %>
