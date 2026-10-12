package com.petcare.petcare.pet.profile.service;

import java.util.List;

import com.petcare.petcare.pet.profile.vo.PetProfileVO;

public interface PetProfileService {

    List<PetProfileVO> getPetList(Long memberNo);

    PetProfileVO getPetDetail(Long petId, Long memberNo);

    /** 성공 시 null, 실패 시 오류 메시지
     * petPhoto 대표사진(선택) */
    String savePet(PetProfileVO vo, Long memberNo,
                   org.springframework.web.multipart.MultipartFile petPhoto);

    /** 성공 시 null, 실패 시 오류 메시지 */
    String deletePet(Long petId, Long memberNo);
}
