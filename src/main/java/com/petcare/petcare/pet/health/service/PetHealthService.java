package com.petcare.petcare.pet.health.service;

import java.util.List;

import com.petcare.petcare.hospital.vo.MedicalRecordVO;

public interface PetHealthService {

    /** 선택된 반려견의 진료기록 (MEMO 태그 파싱 포함) */
    List<MedicalRecordVO> getHealthRecords(Long memberNo, Long petId) throws Exception;
}
