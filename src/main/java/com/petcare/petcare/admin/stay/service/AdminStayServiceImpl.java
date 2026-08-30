/**
 * 역할: 관리자 숙소 관리 Service 구현
 * 2026/08/13 장우철
 */
package com.petcare.petcare.admin.stay.service;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.admin.stay.mapper.AdminStayMapper;
import com.petcare.petcare.admin.stay.vo.AdminStayVO;
import com.petcare.petcare.stay.vo.StayRoomVO;

@Service
public class AdminStayServiceImpl implements AdminStayService {

    @Autowired
    private AdminStayMapper adminStayMapper;

    @Override
    @Transactional(readOnly = true)
    public List<AdminStayVO> getStayList(String statusCd, String keyword) {
        String status = (statusCd == null || statusCd.isBlank() || "ALL".equalsIgnoreCase(statusCd))
                ? null : statusCd.trim().toUpperCase();
        String kw = (keyword == null || keyword.isBlank()) ? null : keyword.trim();
        List<AdminStayVO> list = adminStayMapper.selectStayList(status, kw);
        return list != null ? list : Collections.emptyList();
    }

    @Override
    @Transactional(readOnly = true)
    public Map<String, Integer> getStatusCounts() {
        Map<String, Object> raw = adminStayMapper.selectStayStatusCounts();
        Map<String, Integer> counts = new HashMap<>();
        counts.put("ALL", toInt(raw, "ALL"));
        counts.put("ACTIVE", toInt(raw, "ACTIVE"));
        return counts;
    }

    @Override
    @Transactional(readOnly = true)
    public AdminStayVO getStayDetail(Long stayId) {
        if (stayId == null) {
            return null;
        }
        return adminStayMapper.selectStayDetail(stayId);
    }

    @Override
    @Transactional(readOnly = true)
    public List<StayRoomVO> getRoomList(Long stayId) {
        if (stayId == null) {
            return Collections.emptyList();
        }
        List<StayRoomVO> list = adminStayMapper.selectRoomListByStayId(stayId);
        return list != null ? list : Collections.emptyList();
    }

    private int toInt(Map<String, Object> map, String key) {
        if (map == null || map.get(key) == null) {
            return 0;
        }
        Object v = map.get(key);
        if (v instanceof Number) {
            return ((Number) v).intValue();
        }
        return Integer.parseInt(String.valueOf(v));
    }
}
