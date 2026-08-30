package com.petcare.petcare.common.external.service;

public interface Mapperable {
    String getMarkerId();    // 마커 고유 ID
    String getMarkerName();  // 마커에 표시할 이름
    Double getMarkerLat();   // 위도
    Double getMarkerLng();   // 경도    
}
