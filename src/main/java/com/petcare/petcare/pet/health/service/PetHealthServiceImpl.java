/**
 * 역할: PetHealthService 구현체
 *
 * 2026/07/14 장우철 — 건강수첩 = TB_MEDICAL_RECORD 회원 조회 + MEMO 태그 파싱
 */

package com.petcare.petcare.pet.health.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.hospital.util.MedicalRecordMemoParser;
import com.petcare.petcare.hospital.vo.MedicalRecordVO;
import com.petcare.petcare.pet.health.mapper.PetHealthMapper;

@Service
public class PetHealthServiceImpl implements PetHealthService {

    @Autowired
    private PetHealthMapper petHealthMapper;

    @Override
    @Transactional(readOnly = true)
    public List<MedicalRecordVO> getHealthRecords(Long memberNo, Long petId) throws Exception {
        if (memberNo == null) {
            return List.of();
        }
        List<MedicalRecordVO> list = petHealthMapper.selectMedicalRecordsByMember(memberNo, petId);
        // 2026-07-28 박유정 — MEMO 태그 파싱 공통 유틸(MedicalRecordMemoParser) 사용
        for (MedicalRecordVO r : list) {
            MedicalRecordMemoParser.parse(r);
        }
        return list;
    }
}
