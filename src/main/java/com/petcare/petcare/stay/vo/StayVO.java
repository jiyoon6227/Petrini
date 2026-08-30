/**
 * 역할: 펫호텔·예약 데이터 객체
 *
 * 필드 예시
 * - stayId, stayName, address, pricePerNight, rating
 *
 * 참고 테이블
 * - TB_STAY
 * - TB_RESERVATION
 *
 * DB 컬럼명은 팀 VO 규칙(camelCase)에 맞게 작성
 */

package com.petcare.petcare.stay.vo;

import java.util.List;

import com.petcare.petcare.common.external.service.Mapperable;

import lombok.Getter;
import lombok.Setter;


@Getter @Setter
public class StayVO implements Mapperable {
    // ── TB_STAY ──
    private Long   stayId;
    private Long   memberNo;
    private Long   bizNo;
    private String name;
    private String zipcode;
    private String addr;
    private String addrDetail;
    private Double lat;
    private Double lng;
    private String phone;
    private String petPolicy;
    private String refundPolicy;
    private String statusCd;
    private String approveDate;
    private String facilities;    // 쉼표 구분 (예: "주차장,와이파이,수영장")
    private String thumbPath;

    //HYJ 26.07.10 추가컬럼
    private String checkIn;       // CHECK_IN (15:00)
    private String checkOut;      // CHECK_OUT (11:00)
    private String description;   // DESCRIPTION (공간 소개)
    // 2026/08/11 장우철 — PET_FEE NUMBER (추가 1마리당·1박 요금, 0이면 추가비 없음)
    private Long   petFee;

    // 2026-07-28 박유정 — TB_STAY 평균별점·리뷰수 (병원 HospitalVO와 동일)
    private Double avgRating;     // AVG_RATING
    private Long   reviewCnt;     // REVIEW_CNT
 
    // ── 목록용 (SQL에서 계산) ──
    private int    minPrice;      // MIN(PRICE_PER_NIGHT)
    private int    roomCount;     // 객실 수

    // ── 검색 조건 (list 화면용) ──
    private String region;              // 지역 필터 (서울, 경기, 강원, 제주, 부산, 경상, 전라)
    private int    maxPrice;            // 1박 최대 요금 (0이면 제한 없음)
    private String sort;                // 정렬 (review/recommend, priceLow) 2026/08/13 장우철
    private String[] facilityFilter;    // 특화 조건 코드 배열 (LARGEPET, PETYARD 등)

    // ── 상세용 (객실 목록) ──
    private List<StayRoomVO> rooms;

    // ── Mapperble 구현 (카카오맵 마커용) ──
    public String getMarkerId()   { return stayId != null ? String.valueOf(stayId) : "0"; }
    public String getMarkerName() { return name; }
    public Double getMarkerLat()  { return lat; }
    public Double getMarkerLng()  { return lng; }
}
