/**
 * 역할: 마이페이지 건강수첩 비즈니스 로직 (interface)
 *
 * 담당 화면
 * - mypage/health.jsp  건강수첩 (병원 진료기록 타임라인)
 *
 * 데이터 소스: TB_MEDICAL_RECORD (사업자 진료완료 시 저장)
 *
 * 2026/07/14 장우철
 */

package com.petcare.petcare.pet.health.service;

import java.util.List;

import com.petcare.petcare.hospital.vo.MedicalRecordVO;

public interface PetHealthService {

    /** 선택된 반려견의 진료기록 (MEMO 태그 파싱 포함) */
    List<MedicalRecordVO> getHealthRecords(Long memberNo, Long petId) throws Exception;
}
