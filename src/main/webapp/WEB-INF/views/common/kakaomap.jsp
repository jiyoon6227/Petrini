<%--
  common/kakaomap.jsp — 카카오맵 공통 초기화 (compile-time <%@ include %> 전용)

  ※ <%@ page %> / <%@ taglib %> 선언 없음
     — 포함하는 JSP 페이지가 이미 선언하고 있으므로 중복 선언 불필요
     — 중복 선언 시 JSP 컴파일 오류(Whitelabel Error) 발생

  컨테이너 div :  id="kakao-map"  (고정)

  Model 에서 읽는 값 (KakaoMapService 로 세팅):
    kakaoJsApiKey   Kakao JS API 키
    mapLat       초기 중심 위도
    mapLng       초기 중심 경도
    bizName      있으면 → 단일 마커 + 인포윈도우 (서비스 상세/목록 페이지)
                 없으면 → 마커 생략   (petmap 등 다중 마커 페이지)

  include 후 JS 전역:
    window.kakaoMap  – kakao.maps.Map
    window.kakaoPs   – kakao.maps.services.Places  (장소 검색 등에 사용)
--%>
<script type="text/javascript"
  src="//dapi.kakao.com/v2/maps/sdk.js?appkey=${kakaoJsApiKey}&autoload=true&libraries=services">
</script>
<script>
  kakao.maps.load(function () {
      var el = document.getElementById('kakao-map');
      if (!el) { console.warn('[kakaomap] #kakao-map 컨테이너를 찾을 수 없습니다.'); return; }

      var lat = '${mapLat}' || '37.5665';
      var lng = '${mapLng}' || '126.9780';

      var coords = new kakao.maps.LatLng(parseFloat(lat), parseFloat(lng));
      var map    = new kakao.maps.Map(el, { center: coords, level: 6 });
      
      map.addControl(new kakao.maps.MapTypeControl(), kakao.maps.ControlPosition.TOPRIGHT);
      map.addControl(new kakao.maps.ZoomControl(),    kakao.maps.ControlPosition.RIGHT);
  
      /* 전역 노출 */
      window.kakaoMap = map;
      window.kakaoPs  = new kakao.maps.services.Places();
  
      /* bizName 있을 때만 단일 마커 + 인포윈도우 */
      if ('${bizName}'.trim()) {
          var marker = new kakao.maps.Marker({ position: coords, map: map });
          new kakao.maps.InfoWindow({
              content: '<div style="padding:8px 14px;font-size:13px;font-weight:800;'
                     + 'color:#1A1A2E;white-space:nowrap;">${bizName}</div>'
          }).open(map, marker);
      }

      /* 다중 마커 — markersJson 있을 때 */
      var markersJson = '${markersJson}';
      if (markersJson && markersJson !== '[]') {
        console.log("=================================markersJson");
          var places = JSON.parse(markersJson);
          var bounds = new kakao.maps.LatLngBounds();

          for (var i = 0; i < places.length; i++) {
          var h = places[i];
          var pos    = new kakao.maps.LatLng(h.lat, h.lng);
          var marker = new kakao.maps.Marker({ position: pos, map: map });
          bounds.extend(pos);

          var infowindow = new kakao.maps.InfoWindow({
              content: '<div style="padding:8px 12px;font-size:13px;font-weight:800;'
                     + 'color:#1A1A2E;white-space:nowrap;">'
                     + '<a href="${pageContext.request.contextPath}/hospital/detail?id=' + h.id + '" '
                     + 'style="color:inherit;text-decoration:none">' + h.name + '</a></div>'
          });

          // kakao.maps.event.addListener(marker, 'click', function() {
          //     infowindow.open(map, marker);
          // });
          (function(m, iw) {
              kakao.maps.event.addListener(m, 'mouseover', function() {
                  iw.open(map, m);
              });
              kakao.maps.event.addListener(m, 'mouseout', function() {
                  iw.close();
              });
          })(marker, infowindow);
      }

      // 모든 마커가 보이도록 지도 범위 자동 조정
      map.setBounds(bounds);
      }
  });
</script>
