/**
 * 역할: 마이페이지 예약 DB 접근 (MyBatis interface)
 *
 * XML: resources/mybatis/mapper/mypage/reserve/MypageReserveMapper.xml
 */

package com.petcare.petcare.mypage.reserve.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.hospital.vo.HospitalReviewVO;
import com.petcare.petcare.mypage.reserve.vo.MypageReserveVO;
import com.petcare.petcare.stay.vo.StayReviewVO;

@Mapper
public interface MypageReserveMapper {

    // 2026/07/11 장우철 — 회원 예약 목록 (병원 중심, 2차)
    // 2026/07/21 장우철 — typeFilter(전체/병원/숙소) 추가
    List<MypageReserveVO> selectMyReservationList(@Param("memberNo") Long memberNo,
                                                    @Param("statusFilter") String statusFilter,
                                                    @Param("typeFilter") String typeFilter);

    // 2026/07/11 장우철 — 회원 예약 상세 (본인 건만)
    MypageReserveVO selectMyReservationDetail(@Param("memberNo") Long memberNo,
                                              @Param("resvId") Long resvId);

    // 2026-08-10 박유정 — 재능나눔 참여 신청 목록 (마이페이지 예약내역)
    List<MypageReserveVO> selectMyTalentApplyList(@Param("memberNo") Long memberNo,
                                                  @Param("statusFilter") String statusFilter);

    // 2026-08-10 박유정 — 재능나눔 참여 신청 상세 (마이페이지 예약내역)
    MypageReserveVO selectMyTalentApplyDetail(@Param("memberNo") Long memberNo,
                                            @Param("applyId") Long applyId);

    // 2026/07/13 장우철 — 예약당 병원 리뷰 1건 여부
    int countHospitalReviewByResvId(@Param("resvId") Long resvId,
                                    @Param("memberNo") Long memberNo);

    // 2026/07/13 장우철 — 병원 리뷰 INSERT (REVIEW_TYPE=HOSPITAL)
    int insertHospitalReview(HospitalReviewVO review);

    // 2026/07/13 장우철 — 병원 소유 회원번호 (리뷰 알림)
    Long selectHospitalMemberNo(@Param("hospitalId") Long hospitalId);

    // 2026/07/13 장우철 — 리뷰 알림용 닉네임
    String selectMemberNickname(@Param("memberNo") Long memberNo);

    // 2026/07/13 장우철 — TB_HOSPITAL 평균별점·리뷰수 갱신
    int updateHospitalRatingSummary(@Param("hospitalId") Long hospitalId);

    // 2026-07-28 박유정 — TB_STAY 평균별점·리뷰수 갱신
    int updateStayRatingSummary(@Param("stayId") Long stayId);

    // HYJ 26.07.20 — 숙소 리뷰 중복 확인
    int countStayReviewByResvId(@Param("resvId") Long resvId,
    @Param("memberNo") Long memberNo);

    // HYJ 26.07.20 — 숙소 리뷰 INSERT (REVIEW_TYPE=STAY)
    int insertStayReview(StayReviewVO review);

    // HYJ 26.07.20 — 숙소 소유 사업자 회원번호
    Long selectStayMemberNo(@Param("stayId") Long stayId);

    // HYJ 26.07.21 — 리뷰 포인트 적립
    void insertReviewPoint(java.util.Map<String, Object> param);
    void addMemberPointBalance(java.util.Map<String, Object> param);
    Long selectMemberPointBalance(@Param("memberNo") Long memberNo);

    // 2026/07/31 장우철 — 유저 숙소 취소 (1-4·1-6)
    int updateStayUserCancel(@Param("resvId") Long resvId,
                             @Param("memberNo") Long memberNo,
                             @Param("rejectReason") String rejectReason,
                             @Param("cancelFeeAmt") Long cancelFeeAmt,
                             @Param("refundAmt") Long refundAmt);

    java.util.Map<String, Object> selectDonePaymentByResvId(@Param("resvId") Long resvId);

    int updatePaymentRefundByResvId(@Param("resvId") Long resvId,
                                    @Param("refundAmt") Long refundAmt);
}
