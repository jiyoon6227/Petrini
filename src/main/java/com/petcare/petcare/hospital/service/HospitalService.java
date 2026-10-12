package com.petcare.petcare.hospital.service;

import java.util.Date;
import java.util.List;
import java.util.Map;

import com.petcare.petcare.hospital.vo.HospitalDoctorVO;
import com.petcare.petcare.hospital.vo.HospitalPetVO;
import com.petcare.petcare.hospital.vo.HospitalReviewVO;
import com.petcare.petcare.hospital.vo.HospitalTreatTypeVO;
import com.petcare.petcare.hospital.vo.HospitalVO;
import com.petcare.petcare.hospital.vo.ReservationVO;

public interface HospitalService {
    List<HospitalVO> getHospitalList() throws Exception;
    List<HospitalVO> getHospitalListBySearch(HospitalVO searchVO) throws Exception;
    HospitalVO getHospitalById(Long hospitalId) throws Exception;

    // 병원 예약
    List<HospitalPetVO> getPetListForReserve(Long memberNo) throws Exception;
    Long createHospitalReservation(ReservationVO vo) throws Exception;
    ReservationVO getReservationById(Long resvId) throws Exception;

    // 예약 UI: 가능시간·선점
    List<HospitalDoctorVO> getActiveDoctorsForReserve(Long hospitalId) throws Exception;
    List<HospitalTreatTypeVO> getActiveTreatTypesForReserve(Long hospitalId) throws Exception;
    List<String> getAvailableReserveTimes(Long hospitalId, Long doctorId, Long treatTypeId,
                                          Date resvDate) throws Exception;
    Long createReserveHold(Long hospitalId, Long memberNo, Long doctorId, Long treatTypeId,
                           Date resvDate, String resvTime) throws Exception;

    // 만료 hold 일괄 삭제 (스케줄·예약 API 공용)
    int cleanupExpiredHolds() throws Exception;

    // 2단계 이전 클릭 시 본인 hold 해제
    void releaseMemberReserveHolds(Long hospitalId, Long memberNo) throws Exception;

    // 정기 휴무일 여부 (예약 날짜 선택)
    Map<String, Object> checkReserveDate(Long hospitalId, Date resvDate) throws Exception;

    // 병원 상세 리뷰 목록
    List<HospitalReviewVO> getHospitalReviews(Long hospitalId) throws Exception;
}
