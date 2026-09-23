/* PetCare - main.js */

    /* =============================================
       HERO SLIDER
       ============================================= */
function initHeroSlider() {
    const slides = document.querySelectorAll('.hero-slide');

    // 배너가 없으면 종료
    if (!slides.length) {
        return;
    }

    let current = 0;
    let autoTimer = null;

    function goTo(idx) {
        slides[current].classList.remove('active');
        current = (idx + slides.length) % slides.length;
        slides[current].classList.add('active');
    }

    function stopAuto() {
        if (autoTimer) {
            clearInterval(autoTimer);
            autoTimer = null;
        }
    }

    function startAuto() {
        // 배너가 2개 이상일 때만 자동 슬라이드
        if (slides.length < 2) return;
        stopAuto();
        autoTimer = setInterval(function () {
            goTo(current + 1);
        }, 4500);
    }

    const btnPrev = document.querySelector('.btn-prev');
    const btnNext = document.querySelector('.btn-next');

    if (btnPrev) {
        btnPrev.onclick = function () {
            goTo(current - 1);
            startAuto();
        };
    }

    if (btnNext) {
        btnNext.onclick = function () {
            goTo(current + 1);
            startAuto();
        };
    }

    goTo(0);
    startAuto();
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
