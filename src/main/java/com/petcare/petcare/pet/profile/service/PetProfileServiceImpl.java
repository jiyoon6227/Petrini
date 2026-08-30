/**
 * 2026/07/11 장우철 — PetProfileService 구현
 * 2026/08/11 장우철 — 대표사진 Multipart 업로드 → TB_PET.PHOTO_URL
 */

package com.petcare.petcare.pet.profile.service;

import java.time.LocalDate;
import java.time.Period;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.interceptor.TransactionAspectSupport;
import org.springframework.web.multipart.MultipartFile;

import com.petcare.petcare.file.service.FileService;
import com.petcare.petcare.file.vo.FileVO;
import com.petcare.petcare.pet.profile.mapper.PetProfileMapper;
import com.petcare.petcare.pet.profile.vo.PetProfileVO;

@Service
public class PetProfileServiceImpl implements PetProfileService {

    private static final Logger log = LoggerFactory.getLogger(PetProfileServiceImpl.class);

    @Autowired
    private PetProfileMapper petProfileMapper;

    @Autowired
    private FileService fileService;

    @Override
    public List<PetProfileVO> getPetList(Long memberNo) {
        return petProfileMapper.selectPetList(memberNo);
    }

    @Override
    public PetProfileVO getPetDetail(Long petId, Long memberNo) {
        return petProfileMapper.selectPetDetail(petId, memberNo);
    }

    @Override
    @Transactional
    public String savePet(PetProfileVO vo, Long memberNo, MultipartFile petPhoto) {
        String err = validate(vo);
        if (err != null) {
            return err;
        }

        vo.setMemberNo(memberNo);
        vo.setSpecies(mapSpecies(vo.getKind() != null ? vo.getKind() : vo.getSpecies()));
        vo.setAge(calcAge(vo.getBirthDate(), vo.getAge()));

        if (vo.getPetId() == null) {
            int count = petProfileMapper.countPetsByMember(memberNo);
            vo.setIsRepresent(count == 0 ? "Y" : "N");
            petProfileMapper.insertPet(vo);
            return savePetPhoto(vo.getPetId(), memberNo, petPhoto);
        }

        PetProfileVO existing = petProfileMapper.selectPetDetail(vo.getPetId(), memberNo);
        if (existing == null) {
            return "반려동물을 찾을 수 없습니다.";
        }
        petProfileMapper.updatePet(vo);
        return savePetPhoto(vo.getPetId(), memberNo, petPhoto);
    }

    /** 2026/08/11 장우철 — FileService 업로드 후 PHOTO_URL 저장 (선택) */
    private String savePetPhoto(Long petId, Long memberNo, MultipartFile petPhoto) {
        if (petId == null || memberNo == null || petPhoto == null || petPhoto.isEmpty()) {
            return null;
        }
        String contentType = petPhoto.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            return "이미지 파일만 업로드할 수 있습니다.";
        }
        // 대략 5MB
        if (petPhoto.getSize() > 5L * 1024 * 1024) {
            return "사진은 최대 5MB까지 업로드할 수 있습니다.";
        }
        try {
            FileVO file = fileService.uploadFile(petPhoto, "PET", petId);
            String path = file.getFileUrl() == null ? "" : file.getFileUrl().replace('\\', '/');
            String photoUrl = path.startsWith("/upload/") ? path : "/upload/" + path;
            petProfileMapper.updatePetPhotoUrl(petId, memberNo, photoUrl);
            return null;
        } catch (Exception e) {
            log.warn("pet photo upload failed (petId={}): {}", petId, e.toString());
            return "사진 업로드에 실패했습니다. 다시 시도해 주세요.";
        }
    }

    @Override
    @Transactional
    public String deletePet(Long petId, Long memberNo) {
        if (petId == null) {
            return "잘못된 요청입니다.";
        }
        PetProfileVO existing = petProfileMapper.selectPetDetail(petId, memberNo);
        if (existing == null) {
            return "반려동물을 찾을 수 없습니다.";
        }
        if (petProfileMapper.countActiveReservationsByPetId(petId) > 0) {
            return "진행 중인 예약(대기/확정)이 있어 삭제할 수 없습니다.";
        }

        boolean wasRepresent = "Y".equalsIgnoreCase(existing.getIsRepresent());
        try {
            int affected;
            // 과거 예약(완료/취소)이 있으면 FK 때문에 물리삭제 불가 → 소프트 삭제
            if (petProfileMapper.countAllReservationsByPetId(petId) > 0) {
                affected = petProfileMapper.softDeletePet(petId, memberNo);
            } else {
                affected = petProfileMapper.deletePet(petId, memberNo);
            }
            if (affected == 0) {
                return "삭제에 실패했습니다. 다시 시도해 주세요.";
            }
            if (wasRepresent) {
                petProfileMapper.promoteFirstRepresent(memberNo);
            }
            return null;
        } catch (DataAccessException e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            return "연결된 데이터가 있어 삭제할 수 없습니다.";
        }
    }

    private String validate(PetProfileVO vo) {
        if (vo.getPetName() == null || vo.getPetName().isBlank()) {
            return "이름을 입력해 주세요.";
        }
        if (vo.getPetName().trim().length() > 30) {
            return "이름은 30자 이내로 입력해 주세요.";
        }
        String kind = vo.getKind() != null ? vo.getKind() : vo.getSpecies();
        if (kind == null || kind.isBlank()) {
            return "종류를 선택해 주세요.";
        }
        if (vo.getBreed() == null || vo.getBreed().isBlank()) {
            return "품종을 선택해 주세요.";
        }
        if (vo.getGender() == null || vo.getGender().isBlank()) {
            return "성별을 선택해 주세요.";
        }
        if (!"M".equals(vo.getGender()) && !"F".equals(vo.getGender())) {
            return "성별 값이 올바르지 않습니다.";
        }
        if (vo.getWeight() != null && (vo.getWeight() < 0 || vo.getWeight() > 200)) {
            return "체중을 확인해 주세요.";
        }
        return null;
    }

    private String mapSpecies(String kind) {
        if (kind == null) {
            return "ETC";
        }
        return switch (kind.trim().toLowerCase()) {
            case "dog" -> "DOG";
            case "cat" -> "CAT";
            default -> "ETC";
        };
    }

    private Integer calcAge(LocalDate birthDate, Integer fallbackAge) {
        if (birthDate != null) {
            int years = Period.between(birthDate, LocalDate.now()).getYears();
            return Math.max(years, 0);
        }
        return fallbackAge;
    }
}
