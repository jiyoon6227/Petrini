/**
 * 역할: 사업자 동물병원 DB 접근 (MyBatis interface)
 *
 * XML: resources/mybatis/mapper/biz/hospital/BizHospitalMapper.xml
 * namespace: com.petcare.petcare.biz.hospital.mapper.BizHospitalMapper
 *
 * 쿼리 예시
 * - selectReservationList
 * - updateReservationStatus
 * - selectMedicalRecords
 *
 * 참고 테이블
 * - TB_RESERVATION
 * - TB_MEDICAL_RECORD
 * - TB_REVIEW
 *
 * SQL은 XML에만 작성 (@Select 등 어노테이션 사용 X)
 * 메서드명은 Service에서 호출하는 이름과 동일하게
 */

package com.petcare.petcare.biz.hospital.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.biz.vo.DailyStatVO;
import com.petcare.petcare.hospital.vo.HospitalDoctorVO;
import com.petcare.petcare.hospital.vo.HospitalResvExceptionVO;
import com.petcare.petcare.hospital.vo.HospitalReviewVO;
import com.petcare.petcare.hospital.vo.HospitalTreatTypeVO;
import com.petcare.petcare.hospital.vo.HospitalVO;
import com.petcare.petcare.hospital.vo.MedicalRecordVO;
import com.petcare.petcare.hospital.vo.ReservationVO;

import com.petcare.petcare.hospital.vo.ReviewDeleteRequestVO;


@Mapper
public interface BizHospitalMapper {
    HospitalVO selectHospitalByBizId(String bizId);

    int insertHospital(String bizId);

    int updateHospitalInfo(HospitalVO vo);

    List<ReservationVO> selectReservationList(@Param("hospitalId") Long hospitalId,
                                               @Param("tab") String tab) throws Exception;

    ReservationVO selectReservationDetail(@Param("resvId") Long resvId,
                                          @Param("hospitalId") Long hospitalId) throws Exception;

    int updateReservationStatus(@Param("resvId") Long resvId,
                                @Param("hospitalId") Long hospitalId,
                                @Param("statusCd") String statusCd,
                                @Param("rejectReason") String rejectReason) throws Exception;

    List<ReservationVO> selectReservationCalendarList(@Param("hospitalId") Long hospitalId,
                                                        @Param("fromDate") String fromDate,
                                                        @Param("toDate") String toDate) throws Exception;

    int countPendingReservations(@Param("hospitalId") Long hospitalId) throws Exception;

    int countTodayConfirmedReservations(@Param("hospitalId") Long hospitalId) throws Exception;

    String selectHospitalNameById(@Param("hospitalId") Long hospitalId) throws Exception;

    Long selectHospitalMemberNo(@Param("hospitalId") Long hospitalId) throws Exception;

    List<ReservationVO> selectConfirmedWithoutRecord(@Param("hospitalId") Long hospitalId) throws Exception;

    int insertMedicalRecord(MedicalRecordVO record) throws Exception;

    int countMedicalRecordByResvId(@Param("resvId") Long resvId) throws Exception;

    List<MedicalRecordVO> selectMedicalRecords(@Param("hospitalId") Long hospitalId,
                                               @Param("keyword") String keyword,
                                               @Param("periodMonths") Integer periodMonths) throws Exception;

    MedicalRecordVO selectMedicalRecordDetail(@Param("hospitalId") Long hospitalId,
                                              @Param("recordId") Long recordId) throws Exception;

    List<HospitalReviewVO> selectBizHospitalReviews(@Param("hospitalId") Long hospitalId) throws Exception;

    HospitalReviewVO selectBizHospitalReview(@Param("hospitalId") Long hospitalId,
                                             @Param("reviewId") Long reviewId) throws Exception;

    int updateReviewBizReply(@Param("hospitalId") Long hospitalId,
                             @Param("reviewId") Long reviewId,
                             @Param("bizReply") String bizReply) throws Exception;

    // 2026-07-24 박유정 — 리뷰 삭제 요청 INSERT
    int insertReviewDeleteRequest(ReviewDeleteRequestVO vo) throws Exception;

    // 2026-07-24 박유정 — 동일 리뷰 PENDING 중복 요청 방지
    int countPendingReviewDeleteRequest(@Param("reviewId") Long reviewId,
                                        @Param("bizNo") Long bizNo) throws Exception;

    // 2026-07-24 박유정 — 사업자 리뷰관리 삭제요청 탭 목록
    List<ReviewDeleteRequestVO> selectBizReviewDeleteRequests(@Param("hospitalId") Long hospitalId,
                                                              @Param("bizNo") Long bizNo) throws Exception;

    // 2026/07/16 장우철 고도화작업 — 병원 스케줄 (유형·의사·규칙·예외)
    List<HospitalTreatTypeVO> selectTreatTypeList(@Param("hospitalId") Long hospitalId) throws Exception;
    HospitalTreatTypeVO selectTreatType(@Param("hospitalId") Long hospitalId,
                                        @Param("treatTypeId") Long treatTypeId) throws Exception;
    int insertTreatType(HospitalTreatTypeVO vo) throws Exception;
    int updateTreatType(HospitalTreatTypeVO vo) throws Exception;
    int deleteTreatType(@Param("hospitalId") Long hospitalId,
                        @Param("treatTypeId") Long treatTypeId) throws Exception;

    List<HospitalDoctorVO> selectDoctorList(@Param("hospitalId") Long hospitalId) throws Exception;
    HospitalDoctorVO selectDoctor(@Param("hospitalId") Long hospitalId,
                                  @Param("doctorId") Long doctorId) throws Exception;
    int insertDoctor(HospitalDoctorVO vo) throws Exception;
    int updateDoctor(HospitalDoctorVO vo) throws Exception;
    int deleteDoctor(@Param("hospitalId") Long hospitalId,
                     @Param("doctorId") Long doctorId) throws Exception;

    // 2026/07/16 장우철 고도화작업 — 병원 예약 시작 간격
    Integer selectResvIntervalMin(@Param("hospitalId") Long hospitalId) throws Exception;
    int updateResvIntervalMin(@Param("hospitalId") Long hospitalId,
                              @Param("intervalMin") Integer intervalMin) throws Exception;

    // 2026/07/16 장우철 고도화작업 — RESV_RULE 제거, 예외만 유지
    List<HospitalResvExceptionVO> selectResvExceptionList(@Param("hospitalId") Long hospitalId,
                                                          @Param("fromDate") String fromDate,
                                                          @Param("toDate") String toDate) throws Exception;
    HospitalResvExceptionVO selectResvException(@Param("hospitalId") Long hospitalId,
                                                @Param("excId") Long excId) throws Exception;
    int insertResvException(HospitalResvExceptionVO vo) throws Exception;
    int updateResvException(HospitalResvExceptionVO vo) throws Exception;
    int deleteResvException(@Param("hospitalId") Long hospitalId,
                            @Param("excId") Long excId) throws Exception;

   // ── 대시보드 집계 ──
   int countResvByDate(@Param("targetId") Long targetId, @Param("dt") String dt);
   int countCancelByDate(@Param("targetId") Long targetId, @Param("dt") String dt);
   int countDoneByDate(@Param("targetId") Long targetId, @Param("dt") String dt);
   long sumMonthRevenue(@Param("targetId") Long targetId, @Param("dt") String dt);
   List<Map<String, Object>> countByStatus(@Param("targetId") Long targetId);
   List<DailyStatVO> selectDailyStats(@Param("targetId") Long targetId, @Param("days") int days);

   // 지윤 26.08.13 추가: 월별 통계 (최근 N개월)
   List<DailyStatVO> selectMonthlyStats(@Param("targetId") Long targetId, @Param("months") int months);

   // 지윤 26.08.13 추가: 이번 달 진료완료 건수 (매출 대신 상단 카드용)
   int sumMonthDoneCount(@Param("targetId") Long targetId, @Param("dt") String dt);
   List<ReservationVO> selectTodayResvList(@Param("hospitalId") Long hospitalId);
   List<HospitalReviewVO> selectRecentReviews(@Param("hospitalId") Long hospitalId);

}
