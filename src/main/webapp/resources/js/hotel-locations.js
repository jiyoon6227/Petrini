/**
 * 전국 시·도 → 시/군/구 → 동/읍/면 3단 연동 (행정구역 JSON 기반)
 */
(function () {
  const SIDO_ORDER = [
    '서울특별시', '부산광역시', '대구광역시', '인천광역시', '광주광역시', '대전광역시', '울산광역시',
    '세종특별자치시', '경기도', '강원특별자치도', '충청북도', '충청남도',
    '전북특별자치도', '전라남도', '경상북도', '경상남도', '제주특별자치도'
  ];

  let hotelLocations = null;

  function normalizeKoreaLocations(raw) {
    const out = {};
    for (const [sido, level2] of Object.entries(raw)) {
      out[sido] = {};
      for (const [cityKey, level3] of Object.entries(level2)) {
        const city = (cityKey || '').trim();
        if (Array.isArray(level3)) {
          const label = city || sido;
          out[sido][label] = level3;
          continue;
        }
        if (!level3 || typeof level3 !== 'object') continue;
        for (const [guKey, dongs] of Object.entries(level3)) {
          const gu = (guKey || '').trim();
          if (!Array.isArray(dongs)) continue;
          let label;
          if (city && gu) label = city + ' ' + gu;
          else if (gu) label = gu;
          else if (city) label = city;
          else continue;
          out[sido][label] = dongs;
        }
      }
    }
    return out;
  }

  function fillSelect(select, placeholder, items) {
    select.innerHTML = '';
    const defaultOpt = document.createElement('option');
    defaultOpt.value = '';
    defaultOpt.textContent = placeholder;
    select.appendChild(defaultOpt);
    items.forEach(function (item) {
      const opt = document.createElement('option');
      opt.value = item;
      opt.textContent = item;
      select.appendChild(opt);
    });
  }

  function sortSido(keys) {
    return keys.slice().sort(function (a, b) {
      const ai = SIDO_ORDER.indexOf(a);
      const bi = SIDO_ORDER.indexOf(b);
      if (ai === -1 && bi === -1) return a.localeCompare(b, 'ko');
      if (ai === -1) return 1;
      if (bi === -1) return -1;
      return ai - bi;
    });
  }

  window.onHotelRegionChange = function () {
    const region = document.getElementById('hotelRegion').value;
    const guSelect = document.getElementById('hotelGu');
    const dongSelect = document.getElementById('hotelDong');

    fillSelect(dongSelect, '동/읍/면', []);
    dongSelect.disabled = true;

    if (!region || !hotelLocations) {
      fillSelect(guSelect, '시/군/구', []);
      guSelect.disabled = true;
      return;
    }

    const guList = Object.keys(hotelLocations[region] || {}).sort(function (a, b) {
      return a.localeCompare(b, 'ko');
    });
    fillSelect(guSelect, '시/군/구', guList);
    guSelect.disabled = guList.length === 0;
  };

  window.onHotelGuChange = function () {
    const region = document.getElementById('hotelRegion').value;
    const gu = document.getElementById('hotelGu').value;
    const dongSelect = document.getElementById('hotelDong');

    if (!region || !gu || !hotelLocations) {
      fillSelect(dongSelect, '동/읍/면', []);
      dongSelect.disabled = true;
      return;
    }

    const dongList = (hotelLocations[region][gu] || []).slice().sort(function (a, b) {
      return a.localeCompare(b, 'ko');
    });
    fillSelect(dongSelect, '동/읍/면', dongList);
    dongSelect.disabled = dongList.length === 0;
  };

  function initRegionSelect() {
    const regionSelect = document.getElementById('hotelRegion');
    if (!regionSelect || !hotelLocations) return;
    fillSelect(regionSelect, '전체', sortSido(Object.keys(hotelLocations)));
  }

  function initHotelLocations(contextPath) {
    const url = (contextPath || '') + '/resources/data/korea-locations.json';
    return fetch(url)
      .then(function (res) {
        if (!res.ok) throw new Error('location data load failed');
        return res.json();
      })
      .then(function (raw) {
        hotelLocations = normalizeKoreaLocations(raw);
        initRegionSelect();
      })
      .catch(function () {
        hotelLocations = {};
        initRegionSelect();
      });
  }

  document.addEventListener('DOMContentLoaded', function () {
    const dataEl = document.getElementById('hotelPageData');
    const contextPath = dataEl ? dataEl.getAttribute('data-context-path') || '' : '';
    initHotelLocations(contextPath);
  });
})();
