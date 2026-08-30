/**
 * 역할: 관리자 숙소 예약 DB
 * 2026/07/31 장우철
 */
package com.petcare.petcare.admin.reservation.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.admin.reservation.vo.AdminStayReservationVO;

@Mapper
public interface AdminReservationMapper {

    List<AdminStayReservationVO> selectStayReservationList(@Param("statusCd") String statusCd,
                                                           @Param("keyword") String keyword);

    Map<String, Object> selectStayReservationStatusCounts();

    AdminStayReservationVO selectStayReservationDetail(@Param("resvId") Long resvId);
}
