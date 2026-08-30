/**
 * 2026/07/11 장우철 — 반려동물 프로필 비즈니스 로직
 *
 * 담당 화면: mypage/pets.jsp
 */

package com.petcare.petcare.pet.profile.service;

import java.util.List;

import com.petcare.petcare.pet.profile.vo.PetProfileVO;

public interface PetProfileService {

    List<PetProfileVO> getPetList(Long memberNo);

    PetProfileVO getPetDetail(Long petId, Long memberNo);

    /** 성공 시 null, 실패 시 오류 메시지
     * 2026/08/11 장우철 — petPhoto 대표사진(선택) */
    String savePet(PetProfileVO vo, Long memberNo,
                   org.springframework.web.multipart.MultipartFile petPhoto);

    /** 성공 시 null, 실패 시 오류 메시지 */
    String deletePet(Long petId, Long memberNo);
}
