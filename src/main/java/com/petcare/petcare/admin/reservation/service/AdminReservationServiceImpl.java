/**
 * 역할: 관리자 숙소 예약 관리 Service 구현
 * 2026/07/31 장우철
 */
package com.petcare.petcare.admin.reservation.service;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.admin.reservation.mapper.AdminReservationMapper;
import com.petcare.petcare.admin.reservation.vo.AdminStayReservationVO;
import com.petcare.petcare.stay.service.StayFullCancelService;

@Service
public class AdminReservationServiceImpl implements AdminReservationService {

    @Autowired
    private AdminReservationMapper adminReservationMapper;
    @Autowired
    private StayFullCancelService stayFullCancelService;

    @Override
    @Transactional(readOnly = true)
    public List<AdminStayReservationVO> getStayReservationList(String statusCd, String keyword) {
        String status = (statusCd == null || statusCd.isBlank() || "ALL".equalsIgnoreCase(statusCd))
                ? null : statusCd.trim().toUpperCase();
        String kw = (keyword == null || keyword.isBlank()) ? null : keyword.trim();
        List<AdminStayReservationVO> list = adminReservationMapper.selectStayReservationList(status, kw);
        return list != null ? list : Collections.emptyList();
    }

    @Override
    @Transactional(readOnly = true)
    public Map<String, Integer> getStatusCounts() {
        Map<String, Object> raw = adminReservationMapper.selectStayReservationStatusCounts();
        Map<String, Integer> counts = new HashMap<>();
        counts.put("ALL", toInt(raw, "ALL"));
        counts.put("PENDING", toInt(raw, "PENDING"));
        counts.put("CONFIRMED", toInt(raw, "CONFIRMED"));
        counts.put("CHECKIN", toInt(raw, "CHECKIN"));
        counts.put("CHECKOUT", toInt(raw, "CHECKOUT"));
        counts.put("DONE", toInt(raw, "DONE"));
        counts.put("CANCEL", toInt(raw, "CANCEL"));
        return counts;
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

    @Override
    @Transactional(readOnly = true)
    public AdminStayReservationVO getStayReservationDetail(Long resvId) {
        if (resvId == null) {
            return null;
        }
        return adminReservationMapper.selectStayReservationDetail(resvId);
    }

    @Override
    @Transactional
    public void cancelStayReservation(Long resvId, String cancelReason) throws Exception {
        // stayId null = 관리자 전체 권한 · 전액 환불
        stayFullCancelService.cancelWithFullRefund(resvId, null, cancelReason, "관리자");
    }
}
