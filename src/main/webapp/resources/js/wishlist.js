(function () {
    var SELECTORS = '.wish-btn, .stay-wish-btn, .product-wish, .btn-wish-detail, .hospital-wish, .wish-heart';

    function getContextPath() {
        return window.__CONTEXT_PATH__ || '';
    }

    function resolveId(btn) {
        if (btn.dataset.wishId) {
            return btn.dataset.wishId;
        }

        var card = btn.closest('.stay-card, .product-card, .wish-card, .hospital-card');
        if (!card) {
            return null;
        }

        var onclick = card.getAttribute('onclick') || '';
        var match = onclick.match(/id=(\d+)/);
        if (!match) {
            return null;
        }

        if (card.classList.contains('stay-card')) {
            return 'stay:' + match[1];
        }
        if (card.classList.contains('product-card')) {
            return 'store:' + match[1];
        }
        if (card.classList.contains('hospital-card')) {
            return 'hospital:' + match[1];
        }
        return null;
    }

    function parseWish(id) {
        if (!id || id.indexOf(':') < 0) {
            return null;
        }
        var parts = id.split(':');
        var prefix = parts[0];
        var targetId = parts[1];
        var favType = 'PRODUCT';
        if (prefix === 'stay' || prefix === 'hotel') {
            favType = 'LODGE';
        } else if (prefix === 'hospital') {
            favType = 'HOSPITAL';
        } else if (prefix === 'store') {
            favType = 'PRODUCT';
        } else {
            favType = prefix.toUpperCase();
        }
        return { favType: favType, targetId: targetId, id: id };
    }

    function setActive(btn, active) {
        btn.classList.toggle('wish-active', active);
        btn.classList.toggle('wished', active);
        btn.setAttribute('aria-pressed', active ? 'true' : 'false');

        var svg = btn.querySelector('svg');
        if (svg) {
            svg.style.fill = active ? '#FF6B6B' : 'none';
            svg.style.stroke = active ? '#FF6B6B' : '';
        }

        if (btn.classList.contains('btn-wish-detail')) {
            btn.style.borderColor = active ? '#FF6B6B' : '';
            btn.style.color = active ? '#FF6B6B' : '';
        }
    }

    function syncButton(btn, keySet) {
        var id = resolveId(btn);
        if (!id) {
            return;
        }
        btn.dataset.wishId = id;
        if (keySet) {
            setActive(btn, keySet[id] === true);
        }
    }

    function toggle(btn) {
        var id = resolveId(btn);
        var parsed = parseWish(id);
        if (!parsed) {
            return;
        }

        var fetchFn = window.csrfFetch || fetch;
        fetchFn(getContextPath() + '/mypage/wishlist/toggle', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'favType=' + encodeURIComponent(parsed.favType)
                + '&targetId=' + encodeURIComponent(parsed.targetId)
        })
            .then(function (res) { return res.json(); })
            .then(function (data) {
                if (data && data.loginRequired) {
                    location.href = getContextPath() + '/login';
                    return;
                }
                if (!data || !data.ok) {
                    alert((data && data.message) || '찜 처리에 실패했습니다.');
                    return;
                }
                setActive(btn, !!data.active);
                var grid = document.getElementById('wishlistGrid');
                if (grid && grid.getAttribute('data-server') === 'true' && !data.active) {
                    var card = btn.closest('.wish-card');
                    if (card) {
                        card.remove();
                    }
                    var countEl = document.getElementById('wishCount');
                    var left = grid.querySelectorAll('.wish-card').length;
                    if (countEl) {
                        countEl.textContent = left;
                    }
                    if (left === 0) {
                        grid.innerHTML = '<div class="search-empty" style="grid-column:1/-1;padding:48px 20px;text-align:center;color:var(--text-muted);">찜한 상품이 없습니다.</div>';
                    }
                }
            })
            .catch(function () {
                alert('찜 처리에 실패했습니다.');
            });
    }

    function bindButtons(root, keySet) {
        (root || document).querySelectorAll(SELECTORS).forEach(function (btn) {
            if (btn.dataset.wishBound === 'true') {
                syncButton(btn, keySet);
                return;
            }

            btn.dataset.wishBound = 'true';
            btn.setAttribute('type', btn.getAttribute('type') || 'button');
            btn.setAttribute('aria-label', btn.getAttribute('aria-label') || '찜하기');
            syncButton(btn, keySet);

            btn.addEventListener('click', function (e) {
                e.preventDefault();
                e.stopPropagation();
                toggle(btn);
            });
        });
    }

    function loadKeysAndBind() {
        var fetchFn = window.csrfFetch || fetch;
        fetchFn(getContextPath() + '/mypage/wishlist/keys')
            .then(function (res) { return res.json(); })
            .then(function (data) {
                var keySet = {};
                var keys = (data && data.keys) || [];
                for (var i = 0; i < keys.length; i++) {
                    keySet[keys[i]] = true;
                }
                bindButtons(document, keySet);
            })
            .catch(function () {
                bindButtons(document, {});
            });
    }

    document.addEventListener('DOMContentLoaded', loadKeysAndBind);

    window.PetcareWishlist = {
        bind: bindButtons,
        toggle: toggle
    };
})();
