/**
 * 역할: 관리자 정산 서비스 구현체
 * 2026/07/30 장우철 — 숙소
 * 2026/08/05 장우철 — 쇼핑 STORE S11
 */
package com.petcare.petcare.admin.settlement.service;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.admin.settlement.mapper.AdminSettlementMapper;
import com.petcare.petcare.admin.settlement.vo.AdminStayRequestVO;
import com.petcare.petcare.admin.settlement.vo.AdminStaySettlementVO;
import com.petcare.petcare.admin.settlement.vo.AdminStoreRequestVO;
import com.petcare.petcare.mypage.notify.service.MypageNotifyService;
import com.petcare.petcare.settlement.mapper.StaySettlementMapper;
import com.petcare.petcare.settlement.mapper.StoreSettlementMapper;
import com.petcare.petcare.settlement.service.SettlementBatchService;
import com.petcare.petcare.settlement.service.StaySettlementService;
import com.petcare.petcare.settlement.service.StoreSettlementService;
import com.petcare.petcare.settlement.vo.SettlementBatchResultVO;
import com.petcare.petcare.settlement.vo.StaySettlementItemVO;
import com.petcare.petcare.settlement.vo.StaySettlementVO;
import com.petcare.petcare.settlement.vo.StoreSettlementItemVO;
import com.petcare.petcare.settlement.vo.StoreSettlementVO;

@Service
public class AdminSettlementServiceImpl implements AdminSettlementService {

    @Autowired
    private AdminSettlementMapper adminSettlementMapper;

    @Autowired
    private StaySettlementService staySettlementService;

    @Autowired
    private StoreSettlementService storeSettlementService;

    @Autowired
    private StaySettlementMapper staySettlementMapper;

    @Autowired
    private StoreSettlementMapper storeSettlementMapper;

    @Autowired
    private MypageNotifyService mypageNotifyService;

    @Autowired
    @Lazy
    private SettlementBatchService settlementBatchService;

    @Override
    public boolean isReady() {
        return adminSettlementMapper.ping() == 1;
    }

    @Override
    public int countStaySettlements(Long bizNo) {
        return adminSettlementMapper.countStaySettlements(bizNo);
    }

    @Override
    public List<AdminStaySettlementVO> getStaySettlementList(String statusCd) {
        String status = (statusCd == null || statusCd.isBlank() || "all".equalsIgnoreCase(statusCd))
                ? null : statusCd.toLowerCase();
        List<AdminStaySettlementVO> list = adminSettlementMapper.selectStaySettlementList(status);
        return list == null ? new ArrayList<>() : list;
    }

    @Override
    public List<StaySettlementItemVO> getStaySettlementItems(Long settleId) {
        if (settleId == null) {
            return new ArrayList<>();
        }
        List<StaySettlementItemVO> items = adminSettlementMapper.selectStaySettlementItems(settleId);
        return items == null ? new ArrayList<>() : items;
    }

    @Override
    @Transactional
    public int payStaySettlement(Long settleId) {
        if (settleId == null) {
            throw new IllegalArgumentException("settleId 가 없습니다.");
        }
        AdminStaySettlementVO row = adminSettlementMapper.selectStaySettlementById(settleId);
        int updated = adminSettlementMapper.updateStaySettlementPaid(settleId);
        if (updated > 0 && row != null) {
            notifyStayPaid(row);
        }
        return updated;
    }

    @Override
    @Transactional
    public int payStaySettlements(List<Long> settleIds) {
        if (settleIds == null || settleIds.isEmpty()) {
            throw new IllegalArgumentException("선택된 정산이 없습니다.");
        }
        int updated = 0;
        for (Long id : settleIds) {
            if (id == null) {
                continue;
            }
            updated += payStaySettlement(id);
        }
        return updated;
    }

    private void notifyStayPaid(AdminStaySettlementVO row) {
        try {
            Long memberNo = staySettlementMapper.selectMemberNoByBizNo(row.getBizNo());
            mypageNotifyService.sendStaySettlementPaidNotification(
                    memberNo,
                    row.getBizName(),
                    formatDate(row.getPeriodStart()),
                    formatDate(row.getPeriodEnd()),
                    row.getRequestType(),
                    row.getSettleAmount());
        } catch (Exception e) {
            // 알림 실패해도 지급 처리는 유지
        }
    }

    @Override
    public int countStayMidRequestsRequested() {
        return adminSettlementMapper.countStayRequestsRequested();
    }

    @Override
    public List<AdminStayRequestVO> getStayRequestList(String statusCd) {
        String status = (statusCd == null || statusCd.isBlank() || "all".equalsIgnoreCase(statusCd))
                ? null : statusCd.toLowerCase();
        List<AdminStayRequestVO> list = adminSettlementMapper.selectStayRequestList(status);
        return list == null ? new ArrayList<>() : list;
    }

    @Override
    @Transactional
    public StaySettlementVO approveStayMidRequest(Long requestId) {
        if (requestId == null) {
            throw new IllegalArgumentException("requestId 가 없습니다.");
        }
        return staySettlementService.approveMidSettlementRequest(requestId);
    }

    @Override
    @Transactional
    public void rejectStayMidRequest(Long requestId, String rejectReason) {
        if (requestId == null) {
            throw new IllegalArgumentException("requestId 가 없습니다.");
        }
        staySettlementService.rejectMidSettlementRequest(requestId, rejectReason);
    }

    // ===== STORE =====

    @Override
    public int countStoreSettlements(Long bizNo) {
        return adminSettlementMapper.countStoreSettlements(bizNo);
    }

    @Override
    public List<AdminStaySettlementVO> getStoreSettlementList(String statusCd) {
        String status = (statusCd == null || statusCd.isBlank() || "all".equalsIgnoreCase(statusCd))
                ? null : statusCd.toLowerCase();
        List<AdminStaySettlementVO> list = adminSettlementMapper.selectStoreSettlementList(status);
        return list == null ? new ArrayList<>() : list;
    }

    @Override
    public List<StoreSettlementItemVO> getStoreSettlementItems(Long settleId) {
        if (settleId == null) {
            return new ArrayList<>();
        }
        List<StoreSettlementItemVO> items = adminSettlementMapper.selectStoreSettlementItems(settleId);
        return items == null ? new ArrayList<>() : items;
    }

    @Override
    @Transactional
    public int payStoreSettlement(Long settleId) {
        if (settleId == null) {
            throw new IllegalArgumentException("settleId 가 없습니다.");
        }
        AdminStaySettlementVO row = adminSettlementMapper.selectStoreSettlementById(settleId);
        int updated = adminSettlementMapper.updateStoreSettlementPaid(settleId);
        if (updated > 0 && row != null) {
            notifyStorePaid(row);
        }
        return updated;
    }

    @Override
    @Transactional
    public int payStoreSettlements(List<Long> settleIds) {
        if (settleIds == null || settleIds.isEmpty()) {
            throw new IllegalArgumentException("선택된 정산이 없습니다.");
        }
        int updated = 0;
        for (Long id : settleIds) {
            if (id == null) {
                continue;
            }
            updated += payStoreSettlement(id);
        }
        return updated;
    }

    private void notifyStorePaid(AdminStaySettlementVO row) {
        try {
            Long memberNo = storeSettlementMapper.selectMemberNoByBizNo(row.getBizNo());
            mypageNotifyService.sendStoreSettlementPaidNotification(
                    memberNo,
                    row.getBizName(),
                    formatDate(row.getPeriodStart()),
                    formatDate(row.getPeriodEnd()),
                    row.getRequestType(),
                    row.getSettleAmount());
        } catch (Exception e) {
            // 알림 실패해도 지급 처리는 유지
        }
    }

    @Override
    public int countStoreMidRequestsRequested() {
        return adminSettlementMapper.countStoreRequestsRequested();
    }

    @Override
    public List<AdminStoreRequestVO> getStoreRequestList(String statusCd) {
        String status = (statusCd == null || statusCd.isBlank() || "all".equalsIgnoreCase(statusCd))
                ? null : statusCd.toLowerCase();
        List<AdminStoreRequestVO> list = adminSettlementMapper.selectStoreRequestList(status);
        return list == null ? new ArrayList<>() : list;
    }

    @Override
    @Transactional
    public StoreSettlementVO approveStoreMidRequest(Long requestId) {
        if (requestId == null) {
            throw new IllegalArgumentException("requestId 가 없습니다.");
        }
        return storeSettlementService.approveMidSettlementRequest(requestId);
    }

    @Override
    @Transactional
    public void rejectStoreMidRequest(Long requestId, String rejectReason) {
        if (requestId == null) {
            throw new IllegalArgumentException("requestId 가 없습니다.");
        }
        storeSettlementService.rejectMidSettlementRequest(requestId, rejectReason);
    }

    // ===== S12 =====

    @Override
    public SettlementBatchResultVO createMonthlySettlements(String settleMonth) {
        return settlementBatchService.createMonthlySettlements(settleMonth);
    }

    @Override
    public SettlementBatchResultVO autoPayWaitingSettlements() {
        return settlementBatchService.autoPayWaitingSettlements();
    }

    @Override
    @Transactional
    public int markStaySettlementFail(Long settleId) {
        if (settleId == null) {
            throw new IllegalArgumentException("settleId 가 없습니다.");
        }
        return adminSettlementMapper.updateStaySettlementFail(settleId);
    }

    @Override
    @Transactional
    public int markStoreSettlementFail(Long settleId) {
        if (settleId == null) {
            throw new IllegalArgumentException("settleId 가 없습니다.");
        }
        return adminSettlementMapper.updateStoreSettlementFail(settleId);
    }

    private String formatDate(Date d) {
        if (d == null) {
            return "-";
        }
        return new SimpleDateFormat("yyyy-MM-dd").format(d);
    }
}
