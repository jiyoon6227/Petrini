(function () {
    function getBasePath() {
        return window.__CONTEXT_PATH__ || '';
    }

    function goSearch() {
        var input = document.querySelector('.header-search .search-input');
        if (!input) {
            return;
        }

        var keyword = input.value.trim();
        if (!keyword) {
            input.focus();
            return;
        }

        window.location.href = getBasePath() + '/search?q=' + encodeURIComponent(keyword);
    }

    document.addEventListener('DOMContentLoaded', function () {
        var input = document.querySelector('.header-search .search-input');
        var button = document.querySelector('.header-search .search-btn');

        if (button) {
            button.setAttribute('type', 'button');
            button.addEventListener('click', goSearch);
        }

        if (input) {
            input.addEventListener('keydown', function (e) {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    goSearch();
                }
            });

            var params = new URLSearchParams(window.location.search);
            var currentKeyword = params.get('q');
            if (currentKeyword && window.location.pathname.indexOf('/search') >= 0) {
                input.value = currentKeyword;
            }
        }
    });
})();
