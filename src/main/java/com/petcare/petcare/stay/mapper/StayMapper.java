/**
 * 역할: 펫호텔 DB 접근 (MyBatis interface)
 *
 * XML: resources/mybatis/mapper/stay/StayStayMapper.xml
 * namespace: com.petcare.petcare.stay.mapper.StayStayMapper
 *
 * 쿼리 예시
 * - selectStayList
 * - selectStayDetail
 * - insertReservation
 *
 * 참고 테이블
 * - TB_STAY
 * - TB_RESERVATION
 *
 * SQL은 XML에만 작성 (@Select 등 어노테이션 사용 X)
 * 메서드명은 Service에서 호출하는 이름과 동일하게
 */

package com.petcare.petcare.stay.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;

import com.petcare.petcare.stay.vo.ReservationVO;
import com.petcare.petcare.stay.vo.StayPetVO;
import com.petcare.petcare.stay.vo.StayReviewVO;
import com.petcare.petcare.stay.vo.StayRoomVO;
import com.petcare.petcare.stay.vo.StayVO;


@Mapper
public interface StayMapper {
    // 숙소 목록 (최저가 포함)
    List<StayVO> selectStayList();

    // 숙소 검색 목록 (필터 조건 적용)
    List<StayVO> selectStayListBySearch(StayVO searchVO);
    
    // 숙소 상세
    StayVO selectStayById(Long stayId);

    // 해당 숙소의 객실 목록
    List<StayRoomVO> selectRoomsByStayId(Long stayId);

    // 2026/08/13 장우철 — 객실 상태 확인 (운영중지/종료 예약 차단)
    StayRoomVO selectRoomById(Long roomId); 
    
    // 예약
    List<StayPetVO> selectPetListByMemberNo(Long memberNo);
    void insertReservation(ReservationVO vo);
    ReservationVO selectReservationById(Long resvId);

    List<StayReviewVO> selectStayReviews(Long stayId) throws Exception;

    // HYJ 26.07.20 가용성 체크
    StayRoomVO selectRoomForUpdate(Long roomId);
    int countOverlappingReservation(Map<String, Object> param);

    // HYJ 26.07.20 예약 상태 변경
    void updateReservationStatus(Map<String, Object> param);

    // 지윤 26.08.07: 예약에 쿠폰·포인트 사용 내역 기록
    void updateReservationPaymentInfo(Map<String, Object> param);

    // HYJ 26.07.20 결제
    void insertPayment(Map<String, Object> param);

    // HYJ 26.07.21 포인트 사용
    Long selectMemberPointBalance(Long memberNo);
    // 2026/07/27 장우철 — 잔액 부족이면 0건
    int deductMemberPointBalance(Map<String, Object> param);
    void insertPointHistory(Map<String, Object> param);

    // 2026-07-28 박유정 — 숙소 소유 사업자 회원번호 (예약 알림용)
    Long selectStayMemberNo(Long stayId);

    // HYJ 26.07.20 스케줄러 — 체크아웃 지난 CONFIRMED → DONE 일괄 변경
    int updateConfirmedToDone();

    // 2026/08/07 장우철 — DONE 전환 대상 조회 (알림용, UPDATE 전에 호출)
    List<ReservationVO> selectCheckoutDueForDone();

    // HYJ 26.07.28 스케줄러 — 30분 경과 PENDING → CANCEL 자동 취소
    int cancelExpiredPending();
}
