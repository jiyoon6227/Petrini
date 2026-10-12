package com.petcare.petcare.pet.health.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.hospital.vo.MedicalRecordVO;

@Mapper
public interface PetHealthMapper {

    // 내 반려동물 진료기록 (visitDate DESC)
    List<MedicalRecordVO> selectMedicalRecordsByMember(
            @Param("memberNo") Long memberNo,
            @Param("petId") Long petId);
}
