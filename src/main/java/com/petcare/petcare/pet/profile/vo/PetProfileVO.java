/**
 * 역할: 반려동물 프로필 데이터 객체
 *
 * - 장우철 / 2026/07/11 — TB_PET 기본 필드
 * - 박유정 / 2026-07-28 — FUR_COLOR, NEUTER_YN, TRAITS, MEMO
 *
 * 참고 테이블: TB_PET
 *
 * [SPECIES]
 * - DOG / CAT / ETC
 *
 * [NEUTER_YN]
 * - Y / N / U (미확인)
 */

package com.petcare.petcare.pet.profile.vo;

import java.time.LocalDate;
import java.time.LocalDateTime;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PetProfileVO {

    // ── TB_PET 컬럼 ────────────────────────────────────────────

    private Long petId;             // PET_ID — 반려동물 번호 (PK)
    private Long memberNo;          // MEMBER_NO — 보호자 회원 FK
    private String petName;         // PET_NAME — 이름
    private String species;         // SPECIES — 종 (DOG/CAT/ETC)
    private String breed;           // BREED — 품종
    private String gender;          // GENDER — 성별 (M/F)
    private LocalDate birthDate;    // BIRTH_DATE — 생년월일
    private Integer age;            // AGE — 나이
    private Double weight;          // WEIGHT — 체중 (kg)
    private String furColor;        // FUR_COLOR — 털 색상
    private String neuterYn;        // NEUTER_YN — 중성화 (Y/N/U)
    private String traits;          // TRAITS — 성격/특징 (쉼표 구분)
    private String memo;            // MEMO — 메모
    private String isRepresent;     // IS_REPRESENT — 대표 반려동물 (Y/N)
    private String photoUrl;        // PHOTO_URL — 사진 URL
    private String delYn;           // DEL_YN — 삭제 여부 (Y=소프트삭제)
    private LocalDateTime regDate;  // REG_DATE — 등록일

    // ── 폼 전용 (DB 미저장) ────────────────────────────────────

    private String kind;            // (폼) — 화면용 종 (dog/cat → DOG/CAT 변환)
}
