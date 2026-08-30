/**
 * 역할: 마이페이지 건강수첩 DB 접근 (MyBatis)
 *
 * XML: resources/mybatis/mapper/pet/health/PetHealthMapper.xml
 *
 * 2026/07/14 장우철 — TB_MEDICAL_RECORD 회원·반려견별 조회
 */

package com.petcare.petcare.pet.health.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.hospital.vo.MedicalRecordVO;

@Mapper
public interface PetHealthMapper {

    // 2026/07/14 장우철 — 내 반려동물 진료기록 (visitDate DESC)
    List<MedicalRecordVO> selectMedicalRecordsByMember(
            @Param("memberNo") Long memberNo,
            @Param("petId") Long petId);
}
