/* PetCare - main.js */

    /* =============================================
       HERO SLIDER
       ============================================= */
function initHeroSlider() {
    const slides   = document.querySelectorAll('.hero-slide');
    const dots     = document.querySelectorAll('.slide-dot');
    const indicator = document.querySelector('.slide-indicator');

    // 슬라이드가 없으면 아무것도 안 함(배너 0개일 때)
    if (!slides.length) {
        return;
    }
    
    let current = 0;
    let autoTimer = null;

    function goTo(idx) {
        slides[current].classList.remove('active');
        if (dots[current]) dots[current].classList.remove('active');
        current = (idx + slides.length) % slides.length;
        slides[current].classList.add('active');
        if (dots[current]) dots[current].classList.add('active');
        if (indicator) {
            indicator.textContent = (current + 1) + ' / ' + slides.length;
        }
    }
    function startAuto() {
        stopAuto();  // 중복 타이머 방지 (나중에 다시 호출할 때 중요)
        autoTimer = setInterval(function () {
            goTo(current + 1);
        }, 4500);
    }
    function stopAuto() {
        if (autoTimer) {
            clearInterval(autoTimer);
            autoTimer = null;
        }
    }
    var btnPrev  = document.querySelector('.btn-prev');
    var btnNext  = document.querySelector('.btn-next');
    var btnPause = document.querySelector('.btn-pause');
    if (btnPrev) {
        btnPrev.onclick = function () {
            stopAuto();
            goTo(current - 1);
            startAuto();
        };
    }
    if (btnNext) {
        btnNext.onclick = function () {
            stopAuto();
            goTo(current + 1);
            startAuto();
        };
    }
    if (btnPause) {
        btnPause.onclick = function () {
            if (this.textContent === '❚❚') {
                stopAuto();
                this.textContent = '▶';
            } else {
                startAuto();
                this.textContent = '❚❚';
            }
        };
    }
    for (var i = 0; i < dots.length; i++) {
        (function (index) {
            dots[index].onclick = function () {
                stopAuto();
                goTo(index);
                startAuto();
            };
        })(i);
    }
    goTo(0);      // 첫 슬라이드로 맞춤
    startAuto();  // 자동 넘김 시작
}

/* =============================================
   페이지 로드 시 실행
   ============================================= */
   document.addEventListener('DOMContentLoaded', function () {
    /* LAZY IMAGE FALLBACK */
    document.querySelectorAll('img').forEach(function (img) {
        img.addEventListener('error', function () {
            img.src = 'https://placehold.co/400x300/EAF7F2/2BAB82?text=PetCare';
        });
    });
});
