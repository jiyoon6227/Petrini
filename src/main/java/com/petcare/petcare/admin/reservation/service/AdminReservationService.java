/**
 * 역할: 관리자 숙소 예약 관리 Service
 * 2026/07/31 장우철
 */
package com.petcare.petcare.admin.reservation.service;

import java.util.List;
import java.util.Map;

import com.petcare.petcare.admin.reservation.vo.AdminStayReservationVO;

public interface AdminReservationService {

    List<AdminStayReservationVO> getStayReservationList(String statusCd, String keyword);

    Map<String, Integer> getStatusCounts();

    AdminStayReservationVO getStayReservationDetail(Long resvId);

    /** 관리자 취소 = 전액 환불 */
    void cancelStayReservation(Long resvId, String cancelReason) throws Exception;
}
