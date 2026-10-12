/**
 * 역할: 관리자 숙소 관리 DB
 */
package com.petcare.petcare.admin.stay.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.admin.stay.vo.AdminStayVO;
import com.petcare.petcare.stay.vo.StayRoomVO;

@Mapper
public interface AdminStayMapper {

    List<AdminStayVO> selectStayList(@Param("statusCd") String statusCd,
                                     @Param("keyword") String keyword);

    Map<String, Object> selectStayStatusCounts();

    AdminStayVO selectStayDetail(@Param("stayId") Long stayId);

    List<StayRoomVO> selectRoomListByStayId(@Param("stayId") Long stayId);
}
