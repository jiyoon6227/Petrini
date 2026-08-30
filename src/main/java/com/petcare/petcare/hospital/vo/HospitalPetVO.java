/**
 * 역할: 병원 예약 화면용 반려동물 목록 VO
 *
 * 참고 테이블: TB_PET
 */

package com.petcare.petcare.hospital.vo;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class HospitalPetVO {

    // 2026-07-10 장우철 — 유저 예약 폼 펫 선택 목록 (F2)
    private Long    petId;
    private String  petName;
    private String  species;
    private String  breed;
    private Integer age;
}
