/**
 * 역할: 동물병원·예약 데이터 객체
 *
 * 필드 예시
 * - hospitalId, name, address, phone, rating
 *
 * 참고 테이블
 * - TB_HOSPITAL
 * - TB_RESERVATION
 *
 * DB 컬럼명은 팀 VO 규칙(camelCase)에 맞게 작성
 */

package com.petcare.petcare.hospital.vo;

import java.util.Date;

import com.petcare.petcare.common.external.service.Mapperable;

import lombok.Getter;
import lombok.Setter;

@Getter @Setter
public class HospitalVO implements Mapperable{
    private Long   hospitalId;     // HOSPITAL_ID
    private Long   bizNo;          // BIZ_NO
    private Long   memberNo;       // MEMBER_NO
    private String name;           // HOSPITAL_NAME
    private String phone;          // PHONE
    private String addr;           // ADDR
    private String addrDetail;     // ADDR_DETAIL
    private Double lat;            // LAT
    private Double lng;            // LNG
    private Double avgRating;      // AVG_RATING
    private Long   reviewCnt;      // REVIEW_CNT
    private String statusCd;       // STATUS_CD (PENDING/ACTIVE/INACTIVE)
    private Date   approveDate;    // APPROVE_DATE
    private String description;    // DESCRIPTION  ← 이 줄 추가
    private String hoursJson;      // HOURS_JSON
    private String tagList;       // DEPT_LIST    
    private String thumbPath;
    // 2026/07/16 장우철 고도화작업 — RESV_RULE 통합: 예약 시작 간격(분)
    private Integer resvIntervalMin; // RESV_INTERVAL_MIN
    private Integer resvCapacity;    // RESV_CAPACITY

    // ── 검색 조건 (list 화면용) ──
    private String keyword;        // 지역명·병원명 텍스트 검색
    private String tagFilter;     // 진료과목 (24시간 진료, 특수동물 진료, 입원진료 가능, 호스피텔 가능)
    private String target;         // 진료 대상 (강아지, 고양이, 특수동물)
    private String sort;           // 정렬 (rating, review)

    @Override
    public String getMarkerId()   { return String.valueOf(hospitalId); }
    @Override
    public String getMarkerName() { return name; }
    @Override
    public Double getMarkerLat()  { return lat; }
    @Override
    public Double getMarkerLng()  { return lng; }
}
