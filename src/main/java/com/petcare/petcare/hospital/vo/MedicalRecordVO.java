/**
 * 역할: 진료기록(TB_MEDICAL_RECORD) 데이터 객체
 *
 * 2026/07/13 장우철 — 사업자 진료완료 모달·진료기록관리
 */

package com.petcare.petcare.hospital.vo;

import java.util.Date;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class MedicalRecordVO {

    private Long recordId;
    private Long hospitalId;
    private Long resvId;
    private Long petId;
    private Long memberNo;
    private Date visitDate;
    private String symptoms;
    private String diagnosis;
    private String prescription;
    private String memo;
    private String vetName;
    private Date regDate;

    // 목록/모달 표시용 조인
    private String petName;
    private String petSpecies;
    private String petBreed;
    private String petAge;
    private String memberName;
    private String hospitalName;

    // 화면용(스키마 외) — MEMO 에 보조 저장하거나 폼에서만 사용
    private String treatType;   // 진료 유형
    private String weight;
    private String temperature;
    private String examItems;
    private String heartRate;
    private String breathRate;
    private String nextVisit;
}
