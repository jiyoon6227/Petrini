/**
 * 2026/07/11 장우철 — 반려동물 프로필 DB 접근
 *
 * XML: resources/mybatis/mapper/pet/profile/PetProfileMapper.xml
 * 참고 테이블: TB_PET
 */

package com.petcare.petcare.pet.profile.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.pet.profile.vo.PetProfileVO;

@Mapper
public interface PetProfileMapper {

    List<PetProfileVO> selectPetList(@Param("memberNo") Long memberNo);

    PetProfileVO selectPetDetail(@Param("petId") Long petId,
                                 @Param("memberNo") Long memberNo);

    int countPetsByMember(@Param("memberNo") Long memberNo);

    /** PENDING / CONFIRMED 건수 — 있으면 삭제 불가 */
    int countActiveReservationsByPetId(@Param("petId") Long petId);

    /** 전체 예약 건수 — 0이면 물리삭제, 있으면 소프트삭제 */
    int countAllReservationsByPetId(@Param("petId") Long petId);

    int insertPet(PetProfileVO vo);

    int updatePet(PetProfileVO vo);

    // 2026/08/11 장우철 — 대표사진 PHOTO_URL 갱신
    int updatePetPhotoUrl(@Param("petId") Long petId,
                          @Param("memberNo") Long memberNo,
                          @Param("photoUrl") String photoUrl);

    int deletePet(@Param("petId") Long petId,
                  @Param("memberNo") Long memberNo);

    int softDeletePet(@Param("petId") Long petId,
                      @Param("memberNo") Long memberNo);

    int promoteFirstRepresent(@Param("memberNo") Long memberNo);
}
