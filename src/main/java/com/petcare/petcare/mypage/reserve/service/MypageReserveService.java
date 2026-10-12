package com.petcare.petcare.mypage.reserve.service;

import java.util.List;

import com.petcare.petcare.mypage.reserve.vo.MypageReserveVO;
import com.petcare.petcare.mypage.reserve.vo.StayReviewRegisterResult;

public interface MypageReserveService {

    // typeFilter(전체/병원/숙소)
    List<MypageReserveVO> getMyReservationList(Long memberNo, String statusFilter, String typeFilter);

    // resvType=TALENT 시 재능나눔 신청 상세
    MypageReserveVO getMyReservationDetail(Long memberNo, Long resvId, String resvType);

    // 재능나눔 참여 신청 취소
    void cancelTalentApply(Long memberNo, Long applyId);

    // DONE 예약에 한해 병원 리뷰·별점 등록
    void addHospitalReview(Long memberNo, Long resvId, Double rating, String content);
    
    // 유저 숙소 취소 + 위약금 계산 저장
    // CONFIRMED + 체크인 전만 가능
    void cancelStayReservation(Long memberNo, Long resvId, String cancelReason);

    // DONE 예약에 한해 숙소 리뷰·별점·포인트 등록
    // 평점 갱신·사업자 알림·포인트 적립 결과 반환
    StayReviewRegisterResult addStayReview(Long memberNo, Long resvId, Double rating, String content,
                                           Long currentPointBalance);
}
