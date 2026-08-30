<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- ===================================================================
     광고 배너 (DB 연동 버전)
     - 다른 JSP에서 <%@ include file="/WEB-INF/views/common/ad-banner.jsp" %> 로 삽입
     - pageId 변수(store, hospital, stay, grooming)를 POSITION_CD로 매핑
     - /api/banners?position=STORE 등으로 해당 위치 배너만 조회
     - 2026-08-06 박유정 — store/list.jsp 연동, 이미지 URL 처리
     - 2026-08-07 박유정 — API imageUrl 직접 사용, 로드 실패 시 placeholder
==================================================================== --%>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<style>
  .adv-wrap{max-width:var(--inner-width);margin:24px auto 40px;padding:0 20px}
  .adv-banner{position:relative;border-radius:var(--radius-md);overflow:hidden;height:140px;box-shadow:var(--shadow-sm)}
  .adv-track{display:flex;height:100%;transition:transform .5s ease}
  .adv-slide{min-width:100%;height:100%;position:relative;display:flex;align-items:center;text-decoration:none}
  .adv-slide img{position:absolute;inset:0;width:100%;height:100%;object-fit:cover;z-index:0}
  .adv-slide-overlay{position:relative;z-index:1;padding:0 36px;color:#fff;max-width:60%}
  .adv-eyebrow{font-size:11px;font-weight:700;opacity:.85;letter-spacing:.3px;margin-bottom:6px;display:block}
  .adv-headline{font-size:19px;font-weight:800;line-height:1.4;margin:0;text-shadow:0 1px 6px rgba(0,0,0,.25)}
  .adv-label{position:absolute;top:10px;right:12px;z-index:2;font-size:10px;font-weight:700;color:rgba(255,255,255,.92);background:rgba(0,0,0,.38);padding:3px 9px;border-radius:20px;letter-spacing:.4px}
  .adv-sponsor{position:absolute;bottom:10px;right:14px;z-index:2;font-size:11px;color:rgba(255,255,255,.8)}
  .adv-dots{position:absolute;bottom:10px;left:36px;z-index:2;display:flex;gap:5px}
  .adv-dot{width:6px;height:6px;border-radius:50%;background:rgba(255,255,255,.45);cursor:pointer;transition:var(--transition)}
  .adv-dot.active{width:16px;border-radius:4px;background:#fff}
  .adv-nav{position:absolute;top:50%;transform:translateY(-50%);z-index:2;width:28px;height:28px;border-radius:50%;border:none;background:rgba(0,0,0,.28);color:#fff;font-size:14px;cursor:pointer;display:flex;align-items:center;justify-content:center;opacity:0;transition:opacity .2s}
  .adv-banner:hover .adv-nav{opacity:1}
  .adv-nav:hover{background:rgba(0,0,0,.5)}
  .adv-nav.prev{left:10px}
  .adv-nav.next{right:10px}
  @media (max-width:640px){
    .adv-banner{height:108px}
    .adv-slide-overlay{padding:0 20px;max-width:75%}
    .adv-headline{font-size:15px}
    .adv-dots{left:20px}
    .adv-slide-overlay,
    .adv-sponsor,
    .adv-label {
    display: none;
}
  }
</style>

<div class="adv-wrap" id="advWrap" style="display:none">
  <div class="adv-banner" id="advBanner">
    <div class="adv-track" id="advTrack"></div>
    <button class="adv-nav prev" id="advPrev" aria-label="이전 광고">&#8249;</button>
    <button class="adv-nav next" id="advNext" aria-label="다음 광고">&#8250;</button>
    <div class="adv-dots" id="advDots"></div>
  </div>
</div>

<script>
(function(){
  // pageId → POSITION_CD 매핑
  var pageMap = {
    'store':    'STORE',
    'hospital': 'HOSPITAL',
    'stay':     'STAY',
    'grooming': 'GROOMING'
  };
  var pageId = '${pageId}';
  var position = pageMap[pageId] || pageId.toUpperCase();
  var ctx = '${contextPath}';

  // 2026-08-07 박유정 — API가 내려준 URL 우선 (없으면 클라이언트에서 조합)
  function resolveImgSrc(url) {
    if (!url) return '';
    var path = String(url).replace(/\\/g, '/');
    if (path.indexOf('http://') === 0 || path.indexOf('https://') === 0) return path;
    if (ctx && path.indexOf(ctx + '/') === 0) return path;
    if (path.indexOf('/upload/') === 0) return ctx + path;
    if (path.indexOf('upload/') === 0) return ctx + '/' + path;
    return ctx + '/upload/' + path;
  }

  fetch(ctx + '/api/banners?position=' + position)
    .then(function(res) { return res.json(); })
    .then(function(list) {
      if (!list || list.length === 0) return;

      var track = document.getElementById('advTrack');
      var dots  = document.getElementById('advDots');
      var slideCount = 0;

// 슬라이드 생성
for (var i = 0; i < list.length; i++) {
    var b = list[i];
    var imgSrc = resolveImgSrc(b.imageUrl);
    if (!imgSrc) continue;

    var slide = document.createElement('a');
    slide.className = 'adv-slide';
    slide.href = b.linkUrl || '#';

    slide.innerHTML =
        '<img src="' + imgSrc + '" alt="' + (b.title || '').replace(/"/g, '&quot;') + '"' +
        // 2026-08-07 박유정 — 로드 실패 시 AD placeholder
        ' onerror="this.src=\'https://placehold.co/1160x140/2BAB82/ffffff?text=AD\'">';

    track.appendChild(slide);

    // 도트 생성
    var dot = document.createElement('span');
    dot.className = 'adv-dot' + (slideCount === 0 ? ' active' : '');
    dot.setAttribute('data-i', slideCount);
    dots.appendChild(dot);
    slideCount++;
}

      if (slideCount === 0) return;

      // 배너 영역 표시
      document.getElementById('advWrap').style.display = 'block';

      // 슬라이더 로직
      var allDots = dots.querySelectorAll('.adv-dot');
      var total = slideCount;
      var idx = 0;
      var timer;

      function go(n) {
        idx = (n + total) % total;
        track.style.transform = 'translateX(-' + (idx * 100) + '%)';
        for (var j = 0; j < allDots.length; j++) {
          if (j === idx) { allDots[j].classList.add('active'); }
          else { allDots[j].classList.remove('active'); }
        }
      }
      function next() { go(idx + 1); }
      function startAuto() { timer = setInterval(next, 5000); }
      function stopAuto() { clearInterval(timer); }

      document.getElementById('advPrev').addEventListener('click', function() { go(idx - 1); stopAuto(); startAuto(); });
      document.getElementById('advNext').addEventListener('click', function() { go(idx + 1); stopAuto(); startAuto(); });
      for (var k = 0; k < allDots.length; k++) {
        allDots[k].addEventListener('click', function() { go(parseInt(this.getAttribute('data-i'), 10)); stopAuto(); startAuto(); });
      }

      var banner = document.getElementById('advBanner');
      banner.addEventListener('mouseenter', stopAuto);
      banner.addEventListener('mouseleave', startAuto);

      if (total > 1) startAuto();
    });
})();
</script>
