/**
 * 역할: 관리자 숙소 관리 Service
 * 2026/08/13 장우철
 */
package com.petcare.petcare.admin.stay.service;

import java.util.List;
import java.util.Map;

import com.petcare.petcare.admin.stay.vo.AdminStayVO;
import com.petcare.petcare.stay.vo.StayRoomVO;

public interface AdminStayService {

    List<AdminStayVO> getStayList(String statusCd, String keyword);

    Map<String, Integer> getStatusCounts();

    AdminStayVO getStayDetail(Long stayId);

    List<StayRoomVO> getRoomList(Long stayId);
}
