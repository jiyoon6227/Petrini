/**
 * 역할: 사업자 동물병원 비즈니스 로직 (interface)
 *
 * 담당 화면
 * - biz/hospital/dashboard.jsp 대시보드
 * - biz/hospital/reserve.jsp  예약 관리
 * - biz/hospital/records.jsp  진료 기록
 * - biz/hospital/talent.jsp   재능나눔
 * - biz/hospital/reviews.jsp  리뷰 관리
 * - biz/hospital/contract.jsp 계약 관리
 * - biz/hospital/info.jsp     병원 정보
 *
 * 구현할 기능 예시
 * - 예약 목록·상태 변경
 * - 진료 기록 관리
 * - 리뷰·정산·계약 조회
 *
 * 연결
 * - 구현: BizHospitalServiceImpl
 * - 호출: BizHospitalController
 * - DB: BizHospitalMapper
 *
 * 참고 테이블
 * - TB_RESERVATION
 * - TB_MEDICAL_RECORD
 * - TB_REVIEW
 */

package com.petcare.petcare.biz.hospital.service;

import java.util.List;

import com.petcare.petcare.hospital.vo.HospitalDoctorVO;
import com.petcare.petcare.hospital.vo.HospitalResvExceptionVO;
import com.petcare.petcare.hospital.vo.HospitalReviewVO;
import com.petcare.petcare.hospital.vo.HospitalTreatTypeVO;
import com.petcare.petcare.hospital.vo.HospitalVO;
import com.petcare.petcare.hospital.vo.MedicalRecordVO;
import com.petcare.petcare.hospital.vo.ReservationVO;
import com.petcare.petcare.hospital.vo.ReviewDeleteRequestVO;

public interface BizHospitalService {

    HospitalVO getHospitalByBizId(String bizId);

    // 2026-07-10 장우철 — 승인됐는데 TB_HOSPITAL 없으면 껍데기 생성 후 반환
    HospitalVO resolveHospitalByBizId(String bizId);

    void updateHospitalInfo(HospitalVO vo);

    // 2026-07-10 장우철 — 병원 예약 1차 (F4~F7) 사업자 Service
    List<ReservationVO> getReservationList(Long hospitalId, String tab) throws Exception;

    ReservationVO getReservationDetail(Long hospitalId, Long resvId) throws Exception;

    // 2026/07/11 장우철 — cancelReason: CANCEL 일 때 필수
    void updateReservationStatus(Long hospitalId, Long resvId, String statusCd, String cancelReason) throws Exception;

    List<ReservationVO> getCalendarReservations(Long hospitalId, String fromDate, String toDate) throws Exception;

    // 2026/07/11 장우철 — 사이드바 배지용 PENDING 건수
    int countPendingReservations(Long hospitalId) throws Exception;

    // 2026/07/11 장우철 — 사이드바 캘린더 배지: 오늘 CONFIRMED
    int countTodayConfirmedReservations(Long hospitalId) throws Exception;

    // 2026/07/13 장우철 — 진료완료 + 진료기록 동시 저장
    void completeReservationWithRecord(Long hospitalId, MedicalRecordVO record) throws Exception;

    // 2026/07/13 장우철 — 진료기록 목록
    List<MedicalRecordVO> getMedicalRecords(Long hospitalId, String keyword, Integer periodMonths) throws Exception;

    MedicalRecordVO getMedicalRecordDetail(Long hospitalId, Long recordId) throws Exception;

    // 2026/07/13 장우철 — 작성 모달용 확정·미기록 예약
    List<ReservationVO> getConfirmedWithoutRecord(Long hospitalId) throws Exception;

    // 2026/07/14 장우철 — 사업자 리뷰관리
    List<HospitalReviewVO> getBizHospitalReviews(Long hospitalId) throws Exception;

    void saveReviewBizReply(Long hospitalId, Long reviewId, String bizReply) throws Exception;

    // 2026-07-24 박유정 — 리뷰 삭제 요청 (사업자→관리자)
    void requestReviewDelete(Long hospitalId, Long bizNo, Long reviewId, String requestReason) throws Exception;

    List<ReviewDeleteRequestVO> getBizReviewDeleteRequests(Long hospitalId, Long bizNo) throws Exception;

    // 2026/07/16 장우철 고도화작업 — 병원 스케줄 CRUD
    List<HospitalTreatTypeVO> getTreatTypeList(Long hospitalId) throws Exception;
    void saveTreatType(Long hospitalId, HospitalTreatTypeVO vo) throws Exception;
    void deleteTreatType(Long hospitalId, Long treatTypeId) throws Exception;

    List<HospitalDoctorVO> getDoctorList(Long hospitalId) throws Exception;
    void saveDoctor(Long hospitalId, HospitalDoctorVO vo) throws Exception;
    void deleteDoctor(Long hospitalId, Long doctorId) throws Exception;

    // 2026/07/16 장우철 고도화작업 — RESV_RULE 제거, 간격은 병원 컬럼
    Integer getResvIntervalMin(Long hospitalId) throws Exception;
    void saveResvIntervalMin(Long hospitalId, Integer intervalMin) throws Exception;

    List<HospitalResvExceptionVO> getResvExceptionList(Long hospitalId, String fromDate, String toDate) throws Exception;
    void saveResvException(Long hospitalId, HospitalResvExceptionVO vo) throws Exception;
    void deleteResvException(Long hospitalId, Long excId) throws Exception;

   // ── HYJ 26.08.06 대시보드 ──
   com.petcare.petcare.biz.vo.BizDashboardVO getDashboardData(Long hospitalId, int chartDays) throws Exception;

   // 지윤 26.08.13 추가: 일간/월간 버튼 전환용 - 차트 데이터만 따로 조회
   java.util.List<com.petcare.petcare.biz.vo.DailyStatVO> getChartData(Long hospitalId, String period);
   java.util.List<com.petcare.petcare.hospital.vo.ReservationVO> getTodayResvList(Long hospitalId);
   java.util.List<com.petcare.petcare.hospital.vo.HospitalReviewVO> getRecentReviews(Long hospitalId);

}
