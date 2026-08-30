<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
  역할: 사업자(병원) 재능나눔 신청 (biz/hospital/talent)

  - 박유정 / 2026-07-14 STEP 4

  [화면 흐름]
  1. GET /biz/hospital/talent → ${talentList} 이력 + 신청 폼
  2. POST /biz/hospital/talent → GiveTalentService.applyTalent (PENDING)
  3. flash msg / errorMsg — 신청 결과 안내
  4. 승인 후 admin/biz/talent → APPROVED → /give/talent/list 노출

  참고: 미용 등 다른 사업자 talent.jsp 는 더미(alert) — 병원만 DB 연동
--%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath"  value="${pageContext.request.contextPath}" />
<c:set var="bizTypeLabel" value="동물병원" />
<c:set var="bizPage"      value="talent" />
<%@ include file="/WEB-INF/views/biz/common/header.jsp" %>
<%@ include file="/WEB-INF/views/biz/common/sidebar_hospital.jsp" %>
<style>
.bt-wrap{display:flex;flex-direction:column;gap:20px}
.bt-hero{background:linear-gradient(135deg,#1F8464 0%,#2BAB82 100%);border-radius:12px;padding:28px 32px;color:#fff;display:flex;align-items:center;gap:20px}
.bt-hero-icon{width:60px;height:60px;border-radius:14px;background:rgba(255,255,255,.2);display:flex;align-items:center;justify-content:center;flex-shrink:0}
.bt-hero-icon svg{width:30px;height:30px;stroke:#fff;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round}
.bt-hero h2{font-size:20px;font-weight:800;margin:0 0 6px}
.bt-hero p{font-size:13px;opacity:.85;margin:0;line-height:1.6}
.bt-section{background:#fff;border:1px solid #E4E6ED;border-radius:12px;padding:24px}
.bt-stitle{font-size:14px;font-weight:800;color:#1A1A2E;margin:0 0 18px;padding-bottom:12px;border-bottom:1px solid #E4E6ED;display:flex;align-items:center;gap:8px}
.bt-stitle svg{width:16px;height:16px;stroke:#2BAB82;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}
.bt-grid{display:grid;grid-template-columns:1fr 1fr;gap:14px}
.bt-group{display:flex;flex-direction:column;gap:6px}
.bt-group.full{grid-column:1/-1}
.bt-group label{font-size:13px;font-weight:600;color:#555}
.bt-group label .req{color:#FF6B6B;margin-left:2px}
.bt-group input,.bt-group select,.bt-group textarea{border:1px solid #E4E6ED;border-radius:8px;padding:10px 14px;font-size:14px;color:#1A1A2E;outline:none;font-family:inherit;width:100%;box-sizing:border-box;transition:border-color .2s}
.bt-group input:focus,.bt-group select:focus,.bt-group textarea:focus{border-color:#2BAB82}
.bt-group textarea{min-height:100px;resize:vertical;line-height:1.6}
.bt-example-box{background:#F0FAF6;border:1px solid #B6E8D4;border-radius:8px;padding:16px;margin-bottom:0}
.bt-example-box h4{font-size:13px;font-weight:700;color:#1F8464;margin:0 0 10px}
.bt-ex-item{display:flex;align-items:center;gap:8px;font-size:13px;color:#555;margin-bottom:6px}
.bt-ex-item svg{width:14px;height:14px;stroke:#2BAB82;fill:none;stroke-width:2.5;stroke-linecap:round;stroke-linejoin:round;flex-shrink:0}
.bt-btn-row{display:flex;justify-content:flex-end;gap:10px;margin-top:4px}
.btn-bt-cancel{padding:11px 24px;border:1px solid #E4E6ED;border-radius:8px;background:#fff;color:#555;font-size:14px;font-weight:600;cursor:pointer}
.btn-bt-submit{padding:11px 28px;border:none;border-radius:8px;background:#2BAB82;color:#fff;font-size:14px;font-weight:700;cursor:pointer;transition:background .15s}
.btn-bt-submit:hover{background:#1F8464}
.bt-img-box{border:2px dashed #E4E6ED;border-radius:8px;padding:20px;text-align:center;cursor:pointer;display:flex;flex-direction:column;align-items:center;gap:8px;color:#999;transition:all .15s}
.bt-img-box:hover{border-color:#2BAB82;color:#1F8464;background:#F0FAF6}
.bt-img-box svg{width:28px;height:28px;stroke:currentColor;fill:none;stroke-width:1.6;stroke-linecap:round;stroke-linejoin:round}
.bt-img-box img{max-width:100%;max-height:160px;border-radius:8px;object-fit:cover}
.bt-img-box.has-preview{padding:12px}
</style>
<main class="biz-main">
  <c:if test="${not empty msg}">
    <%-- 2026-07-14 박유정 — 신청 성공 flash (BizHospitalController POST redirect) --%>
    <div style="margin-bottom:12px;padding:12px 16px;background:#E8F8F1;color:#1F8464;border-radius:8px;font-size:14px;font-weight:600">${msg}</div>
  </c:if>
  <c:if test="${not empty errorMsg}">
    <div style="margin-bottom:12px;padding:12px 16px;background:#FEF2F2;color:#B91C1C;border-radius:8px;font-size:14px">${errorMsg}</div>
  </c:if>

  <div class="biz-page-head">
    <h1 class="biz-page-title">재능나눔 신청</h1>
    <p class="biz-page-desc">전문 기술로 유기동물을 돕고, 파트너 브랜드 가치도 높여보세요.</p>
  </div>

  <div class="bt-wrap">
    <div class="bt-hero">
      <div class="bt-hero-icon"><svg viewBox="0 0 24 24"><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></svg></div>
      <div><h2>무료 진료 재능나눔</h2><p>수의사의 전문 의료 기술로 유기동물의 건강을 지켜주세요.<br>신청 후 PetCare 나눔팀이 검토하여 나눔 탭에 게시됩니다.</p></div>
    </div>
    <div class="bt-section">
      <div class="bt-stitle"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>이런 재능나눔을 해보세요</div>
      <div class="bt-example-box"><h4>추천 재능나눔 유형</h4>
      <div class="bt-ex-item"><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>유기견 기본 건강검진 (청진, 혈액검사 등)</div>
      <div class="bt-ex-item"><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>예방접종 무료 제공 (DHPPL, 광견병 등)</div>
      <div class="bt-ex-item"><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>중성화 수술 지원</div>
      <div class="bt-ex-item"><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>입양 전 건강 상태 확인 진료 제공</div></div>
    </div>
    <div class="bt-section">
      <div class="bt-stitle"><svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>재능나눔 신청서</div>
      <%-- 2026-07-14 박유정 STEP 4 — POST /biz/hospital/talent (talentType=HOSPITAL 고정) --%>
      <form method="post" action="${contextPath}/biz/hospital/talent" enctype="multipart/form-data">
        <!--HYJ 26.08.05-->
        <input type="hidden" name="_csrf" value="${_csrf}">
        <div class="bt-grid">
          <div class="bt-group full"><label>재능나눔 제목 <span class="req">*</span></label><input type="text" name="title" required value="${memberInfo.memberName} 무료 진료 재능나눔"></div>
          <div class="bt-group"><label>제공 유형 <span class="req">*</span></label><select disabled><option selected>병원/건강</option></select></div>
          <div class="bt-group"><label>모집 수량 <span class="req">*</span></label><input type="number" name="capacity" min="1" value="10" required></div>
          <div class="bt-group"><label>진행 일정 <span class="req">*</span></label><input type="text" name="schedule" required value="매월 마지막 일요일"></div>
          <div class="bt-group"><label>소요 시간</label><input type="text" name="duration" placeholder="예) 1~2시간"></div>
          <div class="bt-group"><label>장소 <span class="req">*</span></label><input type="text" name="location" required value="${memberInfo.memberName}"></div>
          <div class="bt-group"><label>문의 연락처</label><input type="tel" name="contact" placeholder="02-0000-0000"></div>
          <div class="bt-group full"><label>상세 설명 <span class="req">*</span></label><textarea name="body" required placeholder="제공 서비스 내용, 신청 방법, 대상 동물, 주의사항 등을 작성해 주세요."></textarea></div>
          <div class="bt-group full">
            <label>대표 이미지</label>
            <%-- 2026-08-10 박유정 — FileService 업로드 연동 (선택, 최대 10MB) --%>
            <label class="bt-img-box" id="talentThumbBox" for="talentThumbInput">
              <input type="file" name="thumbImage" id="talentThumbInput" accept="image/jpeg,image/png,image/webp,image/*" style="display:none">
              <span id="talentThumbPlaceholder">
                <svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                <span style="font-size:14px">클릭하여 업로드</span>
                <small style="font-size:12px">JPG, PNG, WebP (최대 10MB, 선택)</small>
              </span>
              <img id="talentThumbPreview" src="" alt="미리보기" style="display:none">
            </label>
          </div>
        </div>
        <div class="bt-btn-row">
          <button type="button" class="btn-bt-cancel" onclick="history.back()">취소</button>
          <button type="submit" class="btn-bt-submit">신청하기</button>
        </div>
      </form>
    </div>
    <%-- 2026-08-10 박유정 — STEP 6: 참여 신청자 목록 + 확인 --%>
    <div class="bt-section">
      <div class="bt-stitle">
        <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87"/><path d="M16 3.13a4 4 0 010 7.75"/></svg>
        참여 신청자
      </div>
      <table class="biz-table">
        <thead>
          <tr>
            <th>신청일</th>
            <th>재능나눔 제목</th>
            <th>닉네임</th>
            <th>연락처</th>
            <th>메시지</th>
            <th>상태</th>
            <th>처리</th>
          </tr>
        </thead>
        <tbody>
          <c:choose>
            <c:when test="${empty applyList}">
              <tr>
                <td colspan="7" style="text-align:center;color:#999;padding:24px 0">
                  아직 참여 신청이 없습니다.
                </td>
              </tr>
            </c:when>
            <c:otherwise>
              <c:forEach var="apply" items="${applyList}">
                <tr>
                  <td>${apply.regDate}</td>
                  <td>${apply.talentTitle}</td>
                  <td>${apply.nickname}</td>
                  <td>${apply.phone}</td>
                  <td>
                    <c:choose>
                      <c:when test="${not empty apply.message}">${apply.message}</c:when>
                      <c:otherwise><span style="color:#999">-</span></c:otherwise>
                    </c:choose>
                  </td>
                  <td>
                    <c:choose>
                      <c:when test="${apply.statusCd eq 'PENDING'}">
                        <span class="bs-badge bs-wait">확인 대기</span>
                      </c:when>
                      <c:when test="${apply.statusCd eq 'CONFIRMED'}">
                        <span class="bs-badge bs-done">확인 완료</span>
                      </c:when>
                      <c:otherwise>
                        <span class="bs-badge bs-cancel">${apply.statusCd}</span>
                      </c:otherwise>
                    </c:choose>
                  </td>
                  <td>
                    <c:if test="${apply.statusCd eq 'PENDING'}">
                      <form method="post" action="${contextPath}/biz/hospital/talent/confirm" style="display:inline">
                      <input type="hidden" name="_csrf" value="${_csrf}">
                        <input type="hidden" name="applyId" value="${apply.applyId}">
                        <button type="submit" class="biz-btn primary" style="padding:6px 12px;font-size:13px"
                                onclick="return confirm('이 신청을 확인하시겠습니까?')">확인</button>
                      </form>
                    </c:if>
                    <c:if test="${apply.statusCd eq 'CONFIRMED'}">
                      <span style="color:#999;font-size:13px">처리됨</span>
                    </c:if>
                  </td>
                </tr>
              </c:forEach>
            </c:otherwise>
          </c:choose>
        </tbody>
      </table>
    </div>
    <%-- 2026-07-14 박유정 — 사업자 본인 재능나눔 이력 (getTalentListByBizId) --%>
    <div class="bt-section">
      <div class="bt-stitle">
        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
        내 재능나눔 이력
      </div>
      <table class="biz-table">
        <thead>
          <tr>
            <th>등록일</th>
            <th>제목</th>
            <th>유형</th>
            <th>진행 수</th>
            <th>상태</th>
            <th>관리</th>
          </tr>
        </thead>
        <tbody>
          <c:choose>
            <c:when test="${empty talentList}">
              <tr>
                <td colspan="6" style="text-align:center;color:#999;padding:24px 0">
                  신청 이력이 없습니다.
                </td>
              </tr>
            </c:when>
            <c:otherwise>
              <c:forEach var="item" items="${talentList}">
                <tr>
                  <td>${item.regDate}</td>
                  <td>${item.title}</td>
                  <td>병원/건강</td>
                  <td>${item.currentCnt} / ${item.capacity}</td>
                  <td>
                    <c:choose>
                      <c:when test="${item.statusCd eq 'PENDING'}">
                        <span class="bs-badge bs-wait">승인 대기</span>
                      </c:when>
                      <c:when test="${item.statusCd eq 'APPROVED'}">
                        <span class="bs-badge bs-done">게시 중</span>
                      </c:when>
                      <c:when test="${item.statusCd eq 'REJECTED'}">
                        <span class="bs-badge bs-cancel">반려</span>
                      </c:when>
                      <c:when test="${item.statusCd eq 'DONE'}">
                        <span class="bs-badge bs-done">완료</span>
                      </c:when>
                    </c:choose>
                  </td>
                  <td>
                    <%-- 2026-08-10 박유정 — 게시 중일 때만 수동 모집 마감 --%>
                    <c:if test="${item.statusCd eq 'APPROVED'}">
                      <form method="post" action="${contextPath}/biz/hospital/talent/close" style="display:inline">
                        <input type="hidden" name="_csrf" value="${_csrf}">
                        <input type="hidden" name="talentId" value="${item.talentId}">
                        <button type="submit" class="biz-btn" style="padding:4px 10px;font-size:12px"
                                onclick="return confirm('모집을 마감하시겠습니까?')">모집 마감</button>
                      </form>
                    </c:if>
                    <c:if test="${item.statusCd ne 'APPROVED'}">
                      <span style="color:#999;font-size:12px">-</span>
                    </c:if>
                  </td>
                </tr>
              </c:forEach>
            </c:otherwise>
          </c:choose>
        </tbody>
      </table>
    </div>

  </div><%-- bt-wrap --%>
</main>
<script>
(function () {
  var input = document.getElementById('talentThumbInput');
  var preview = document.getElementById('talentThumbPreview');
  var placeholder = document.getElementById('talentThumbPlaceholder');
  var box = document.getElementById('talentThumbBox');
  if (!input || !preview) return;
  input.addEventListener('change', function () {
    var file = input.files && input.files[0];
    if (!file) {
      preview.style.display = 'none';
      preview.src = '';
      placeholder.style.display = '';
      box.classList.remove('has-preview');
      return;
    }
    if (file.size > 10 * 1024 * 1024) {
      alert('이미지는 10MB 이하만 등록할 수 있습니다.');
      input.value = '';
      return;
    }
    var reader = new FileReader();
    reader.onload = function (e) {
      preview.src = e.target.result;
      preview.style.display = 'block';
      placeholder.style.display = 'none';
      box.classList.add('has-preview');
    };
    reader.readAsDataURL(file);
  });
})();
</script>
<%@ include file="/WEB-INF/views/biz/common/footer.jsp" %>

