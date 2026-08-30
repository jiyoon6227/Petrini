/**
 * 역할: 동물병원 DB 접근 (MyBatis interface)
 *
 * XML: resources/mybatis/mapper/hospital/HospitalMapper.xml
 * namespace: com.petcare.petcare.hospital.mapper.HospitalMapper
 *
 * 쿼리 예시
 * - selectHospitalList
 * - selectHospitalDetail
 * - insertReservation
 *
 * 참고 테이블
 * - TB_HOSPITAL
 * - TB_RESERVATION
 *
 * SQL은 XML에만 작성 (@Select 등 어노테이션 사용 X)
 * 메서드명은 Service에서 호출하는 이름과 동일하게
 */

package com.petcare.petcare.hospital.mapper;

import java.util.Date;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.hospital.vo.HospitalDoctorVO;
import com.petcare.petcare.hospital.vo.HospitalPetVO;
import com.petcare.petcare.hospital.vo.HospitalResvExceptionVO;
import com.petcare.petcare.hospital.vo.HospitalResvHoldVO;
import com.petcare.petcare.hospital.vo.HospitalTimeBlockVO;
import com.petcare.petcare.hospital.vo.HospitalTreatTypeVO;
import com.petcare.petcare.hospital.vo.HospitalReviewVO;
import com.petcare.petcare.hospital.vo.HospitalVO;
import com.petcare.petcare.hospital.vo.ReservationVO;


@Mapper
public interface HospitalMapper {
    //MyBatis가 @Mapper가 붙은 인터페이스를 보고 자동으로 구현체(XML)를 만들어줌
    List<HospitalVO> selectHospitalList() throws Exception;
    List<HospitalVO> selectHospitalListBySearch(HospitalVO searchVO) throws Exception;
    HospitalVO selectHospitalById(Long hospitalId) throws Exception;

    // 2026-07-10 장우철 — 병원 예약 1차 (F0~F3) 유저 측 Mapper
    List<HospitalPetVO> selectPetListByMemberNo(Long memberNo) throws Exception;
    int insertReservation(ReservationVO vo) throws Exception;
    ReservationVO selectReservationById(Long resvId) throws Exception;

    // 2026/07/16 장우철 — 예약 제출: 진료유형·의사 조회, 겹침 검사
    HospitalTreatTypeVO selectTreatType(@Param("hospitalId") Long hospitalId,
                                        @Param("treatTypeId") Long treatTypeId) throws Exception;
    HospitalDoctorVO selectDoctor(@Param("hospitalId") Long hospitalId,
                                  @Param("doctorId") Long doctorId) throws Exception;
    int countOverlappingReservations(@Param("hospitalId") Long hospitalId,
                                     @Param("doctorId") Long doctorId,
                                     @Param("resvDate") Date resvDate,
                                     @Param("resvTime") String resvTime,
                                     @Param("endTime") String endTime) throws Exception;

    // 2026/07/16 장우철 — 예약 UI: 활성 유형·의사·예외·점유·선점
    List<HospitalTreatTypeVO> selectActiveTreatTypeList(@Param("hospitalId") Long hospitalId) throws Exception;
    List<HospitalDoctorVO> selectActiveDoctorList(@Param("hospitalId") Long hospitalId) throws Exception;
    Integer selectResvIntervalMin(@Param("hospitalId") Long hospitalId) throws Exception;
    List<HospitalResvExceptionVO> selectResvExceptionsByDate(@Param("hospitalId") Long hospitalId,
                                                             @Param("resvDate") Date resvDate) throws Exception;
    List<HospitalTimeBlockVO> selectOccupiedReservationBlocks(@Param("hospitalId") Long hospitalId,
                                                              @Param("doctorId") Long doctorId,
                                                              @Param("resvDate") Date resvDate) throws Exception;
    List<HospitalTimeBlockVO> selectOccupiedHoldBlocks(@Param("hospitalId") Long hospitalId,
                                                       @Param("doctorId") Long doctorId,
                                                       @Param("resvDate") Date resvDate) throws Exception;
    int countOverlappingWithHolds(@Param("hospitalId") Long hospitalId,
                                  @Param("doctorId") Long doctorId,
                                  @Param("resvDate") Date resvDate,
                                  @Param("resvTime") String resvTime,
                                  @Param("endTime") String endTime,
                                  @Param("excludeHoldId") Long excludeHoldId) throws Exception;
    int deleteExpiredHolds() throws Exception;
    int deleteHoldsByMember(@Param("hospitalId") Long hospitalId,
                            @Param("memberNo") Long memberNo) throws Exception;
    int insertResvHold(HospitalResvHoldVO hold) throws Exception;
    HospitalResvHoldVO selectResvHoldById(@Param("holdId") Long holdId) throws Exception;
    int deleteResvHoldById(@Param("holdId") Long holdId) throws Exception;

    // 2026/07/20 장우철 — 동시예약 방지: 의사 행 비관적 락
    Long lockDoctorForUpdate(@Param("hospitalId") Long hospitalId,
                             @Param("doctorId") Long doctorId) throws Exception;

    // 2026/07/20 장우철 — hold 최종 제출 시 선점 행 락
    HospitalResvHoldVO selectResvHoldByIdForUpdate(@Param("holdId") Long holdId) throws Exception;

    // 2026/07/13 장우철 — 병원 상세 리뷰 목록 (REVIEW_TYPE=HOSPITAL)
    List<HospitalReviewVO> selectHospitalReviews(Long hospitalId) throws Exception;
}
